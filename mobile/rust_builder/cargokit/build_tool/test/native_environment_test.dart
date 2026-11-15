// Run with: dart run test/native_environment_test.dart
import 'dart:io';

import 'package:build_tool/src/android_environment.dart';
import 'package:build_tool/src/builder.dart';
import 'package:build_tool/src/options.dart';
import 'package:build_tool/src/rustup.dart';
import 'package:build_tool/src/target.dart';
import 'package:build_tool/src/util.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

void check(bool condition, String message) {
  if (!condition) throw StateError(message);
}

Future<void> main() async {
  final temp = Directory.systemTemp.createTempSync('native sdk with spaces ');
  try {
    final host = Platform.isWindows
        ? 'windows-x86_64'
        : Platform.isMacOS
            ? 'darwin-x86_64'
            : 'linux-x86_64';
    final toolchain = path.join(
        temp.path, 'ndk', '28.2.13676358', 'toolchains', 'llvm', 'prebuilt', host);
    final ar = File(path.join(toolchain, 'bin', 'llvm-ar'));
    ar.parent.createSync(recursive: true);
    ar.writeAsStringSync('');

    for (final triple in ['aarch64-linux-android', 'armv7-linux-androideabi']) {
      final env = await AndroidEnvironment(
        sdkPath: temp.path,
        ndkVersion: '28.2.13676358',
        minSdkVersion: 24,
        targetTempDir: temp.path,
        target: Target.forRustTriple(triple)!,
      ).buildEnvironment();
      final clangTriple = triple.startsWith('armv7')
          ? 'armv7a-linux-androideabi'
          : triple;
      final libraryTriple = triple.startsWith('armv7')
          ? 'arm-linux-androideabi'
          : triple;
      final bindgen = env['BINDGEN_EXTRA_CLANG_ARGS_$triple']!;
      check(bindgen.contains('--target=${clangTriple}24'), 'bindgen API/ABI');
      check(bindgen.contains('"--sysroot='), 'quoted bindgen sysroot');
      check(bindgen.contains(libraryTriple), 'target-specific system headers');
      check(!env.containsKey('BINDGEN_EXTRA_CLANG_ARGS'), 'no host pollution');
      check(env['CFLAGS_$triple']!.contains('--sysroot='), 'C sysroot');
      check(env['CC_SHELL_ESCAPED_FLAGS'] == '1', 'cc-rs path quoting');
      check(env['CXXFLAGS_$triple'] == env['CFLAGS_$triple'], 'C++ sysroot');

      TestRunCommandArgs? invocation;
      testRunCommandOverride = (args) {
        invocation = args;
        return TestRunCommandResult();
      };
      AndroidEnvironment.clangLinkerWrapper(['object with spaces.o'],
          environment: env);
      check(invocation!.arguments[0] == '--target=${clangTriple}24', 'link ABI');
      check(invocation!.arguments[1] ==
          '--sysroot=${env['_CARGOKIT_NDK_LINK_SYSROOT']}', 'single sysroot arg');
      check(invocation!.arguments.contains('-Wl,--no-undefined'),
          'missing native symbols must fail the link');
      check(invocation!.arguments.last == 'object with spaces.o', 'argv intact');
      testRunCommandOverride = null;
    }

    // Use a real failing child process: the test override intentionally does
    // not exercise runCommand's failure handling. Dart rejects Clang flags.
    try {
      AndroidEnvironment.clangLinkerWrapper([], environment: {
        '_CARGOKIT_NDK_LINK_CLANG': Platform.resolvedExecutable,
        '_CARGOKIT_NDK_LINK_TARGET': '--not-a-dart-option',
        '_CARGOKIT_NDK_LINK_SYSROOT': temp.path,
      });
      throw StateError('linker failure was swallowed');
    } on CommandFailedException catch (error) {
      check(error.result.exitCode != 0, 'nonzero linker exit');
    }

    final options = CargokitCrateOptions.parse(loadYamlNode('''
cargo:
  release:
    toolchain: 1.98.0
    extra_flags: [--locked, --features, uac2]
'''));
    check(options.cargo[BuildConfiguration.release]!.toolchain == '1.98.0',
        'pinned toolchain parsing');
    testRunCommandOverride = (args) {
      if (args.arguments.join(' ') == 'toolchain list') {
        return TestRunCommandResult(
            stdout: '1.98.0-x86_64-unknown-linux-gnu (default)\n');
      }
      check(args.arguments.contains('1.98.0-x86_64-unknown-linux-gnu'),
          'query installed pinned toolchain');
      return TestRunCommandResult(stdout: 'aarch64-linux-android\n');
    };
    check(Rustup().installedTargets('1.98.0')!.contains('aarch64-linux-android'),
        'reuse installed numbered toolchain');
    stdout.writeln('Native environment checks passed (arm64, armv7, linker failure, Rust pin).');
  } finally {
    testRunCommandOverride = null;
    temp.deleteSync(recursive: true);
  }
}
