# Run from Windows (or WSL via powershell.exe -File):
# powershell.exe -NoProfile -File tool/test_cargokit_launcher.ps1
# Uses only Windows PowerShell/.NET and cmd.exe; no Dart/Rust SDK is invoked.
param(
    [string]$TempRoot = (Join-Path (Split-Path $PSScriptRoot -Parent) 'build')
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $TempRoot -PathType Container)) {
    throw "Temporary parent directory must already exist: $TempRoot"
}
$root = Join-Path (Resolve-Path -LiteralPath $TempRoot).Path ('cargokit launcher test ' + [guid]::NewGuid())
$launcher = Join-Path $root 'cargokit\run_build_tool.cmd'
$dartDir = Join-Path $root 'fake flutter\bin\cache\dart-sdk\bin'

try {
    New-Item -ItemType Directory -Path (Join-Path $root 'cargokit\build_tool'), $dartDir | Out-Null
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot '..\rust_builder\cargokit\run_build_tool.cmd') -Destination $launcher
    Set-Content -LiteralPath (Join-Path $root 'cargokit\build_tool\fixture.txt') -Value 'isolated package'

    # A batch-file fake would transfer control out of the launcher (no CALL).
    # Real console executables are necessary to exercise its errorlevel handling.
    Add-Type -OutputAssembly (Join-Path $dartDir 'dart.exe') -OutputType ConsoleApplication -TypeDefinition @'
using System;
using System.Diagnostics;
using System.IO;

public class FakeTool {
    public static int Main(string[] args) {
        string trace = Environment.GetEnvironmentVariable("FAKE_TRACE");
        if (Path.GetFileNameWithoutExtension(Environment.GetCommandLineArgs()[0]) == "cargo") {
            File.AppendAllText(trace, "cargo\n");
            Console.Error.WriteLine("fake cargo: missing libclang.dll; exit 101");
            return 101;
        }
        string stage = args[0] == "pub" ? "pub" : args[0] == "compile" ? "compile" : "run";
        int count = 0;
        if (File.Exists(trace)) {
            foreach (string line in File.ReadAllLines(trace)) {
                if (line == stage) ++count;
            }
        }
        File.AppendAllText(trace, stage + "\n");
        string[] codes = Environment.GetEnvironmentVariable("FAKE_" + stage.ToUpper()).Split(',');
        int code = int.Parse(codes[Math.Min(count, codes.Length - 1)]);
        if (stage == "compile" && code == 0) File.WriteAllText("bin/build_tool_runner.dill", "fixture");
        if (stage == "run" && (args.Length != 3 || args[1] != "build-gradle" || args[2] != "argument with spaces")) {
            Console.Error.WriteLine("Launcher did not preserve arguments");
            return 99;
        }
        if (code == -1) {
            var start = new ProcessStartInfo(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "cargo.exe"));
            start.UseShellExecute = false;
            using (var cargo = Process.Start(start)) {
                cargo.WaitForExit();
                // Cargokit's runCommand throws; runMain logs and exits 1.
                return cargo.ExitCode == 0 ? 0 : 1;
            }
        }
        if (code != 0) Console.Error.WriteLine("fake dart " + stage + ": exit " + code);
        return code;
    }
}
'@
    Copy-Item -LiteralPath (Join-Path $dartDir 'dart.exe') -Destination (Join-Path $dartDir 'cargo.exe')

    function Invoke-Launcher($work, $pub, $compile, $run) {
        $start = New-Object System.Diagnostics.ProcessStartInfo
        $start.FileName = $env:ComSpec
        $start.Arguments = '/d /s /c ""' + $launcher + '" build-gradle "argument with spaces""'
        $start.WorkingDirectory = $work
        $start.UseShellExecute = $false
        $start.RedirectStandardOutput = $true
        $start.RedirectStandardError = $true
        $start.EnvironmentVariables['FLUTTER_ROOT'] = Join-Path $root 'fake flutter'
        $start.EnvironmentVariables['CARGOKIT_TOOL_TEMP_DIR'] = $work
        $start.EnvironmentVariables['FAKE_TRACE'] = Join-Path $work 'trace.txt'
        $start.EnvironmentVariables['FAKE_PUB'] = $pub
        $start.EnvironmentVariables['FAKE_COMPILE'] = $compile
        $start.EnvironmentVariables['FAKE_RUN'] = $run
        $process = [System.Diagnostics.Process]::Start($start)
        try {
            $stdout = $process.StandardOutput.ReadToEndAsync()
            $stderr = $process.StandardError.ReadToEndAsync()
            $process.WaitForExit()
            return [pscustomobject]@{
                Code = $process.ExitCode
                Output = $stdout.Result + $stderr.Result
            }
        } finally {
            $process.Dispose()
        }
    }

    $cases = @(
        @{ Name = 'cold success'; Cold = $true; Run = '0'; Code = 0; Trace = 'pub,compile,run' }
        @{ Name = 'cached success'; Run = '0'; Code = 0; Trace = 'run' }
        @{ Name = 'cached cargo failure'; Run = '-1'; Code = 1; Trace = 'run,cargo' }
        @{ Name = 'direct exit 101'; Run = '101'; Code = 101; Trace = 'run' }
        @{ Name = 'cold pub failure'; Cold = $true; Pub = '11'; Run = '0'; Code = 11; Trace = 'pub' }
        @{ Name = 'cold compile failure'; Cold = $true; Compile = '12'; Run = '0'; Code = 12; Trace = 'pub,compile' }
        @{ Name = 'cold cargo failure'; Cold = $true; Run = '-1'; Code = 1; Trace = 'pub,compile,run,cargo' }
        @{ Name = 'snapshot retry success'; Run = '253,0'; Code = 0; Trace = 'run,pub,compile,run' }
        @{ Name = 'snapshot retry cargo failure'; Run = '253,-1'; Code = 1; Trace = 'run,pub,compile,run,cargo' }
        @{ Name = 'snapshot retry pub failure'; Pub = '11'; Run = '253,0'; Code = 11; Trace = 'run,pub' }
        @{ Name = 'snapshot retry compile failure'; Compile = '12'; Run = '253,0'; Code = 12; Trace = 'run,pub,compile' }
        @{ Name = 'snapshot retry only once'; Run = '253,253'; Code = 253; Trace = 'run,pub,compile,run' }
    )
    $failures = 0
    foreach ($case in $cases) {
        $work = Join-Path $root $case.Name
        New-Item -ItemType Directory -Path (Join-Path $work '.dart_tool') | Out-Null
        # Prime a valid cached package listing/kernel without touching real outputs.
        $prime = Invoke-Launcher $work '0' '0' '0'
        if ($prime.Code -ne 0) { throw "Fixture setup failed: $($prime.Output)" }
        Remove-Item -LiteralPath (Join-Path $work 'trace.txt')
        if ($case.Cold) { Remove-Item -LiteralPath (Join-Path $work 'bin\build_tool_runner.dill') }
        $pub = if ($case.Pub) { $case.Pub } else { '0' }
        $compile = if ($case.Compile) { $case.Compile } else { '0' }
        $result = Invoke-Launcher $work $pub $compile $case.Run
        $trace = (Get-Content -LiteralPath (Join-Path $work 'trace.txt')) -join ','
        if ($result.Code -eq $case.Code -and $trace -eq $case.Trace) {
            Write-Output "PASS $($case.Name): exit=$($result.Code), calls=$trace"
        } else {
            ++$failures
            Write-Output "FAIL $($case.Name): exit=$($result.Code) (expected $($case.Code)), calls=$trace (expected $($case.Trace))"
            Write-Output $result.Output
        }
    }
    Write-Output "$($cases.Count - $failures)/$($cases.Count) cases passed"
} finally {
    if (Test-Path -LiteralPath $root) { Remove-Item -LiteralPath $root -Recurse -Force }
}
if ($failures -ne 0) { exit 1 }
