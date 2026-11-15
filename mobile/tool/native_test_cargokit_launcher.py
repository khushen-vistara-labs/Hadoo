#!/usr/bin/env python3
"""Isolated Unix Cargokit exit-code regression; requires Python 3 and bash."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


LAUNCHER = Path(__file__).resolve().parents[1] / "rust_builder/cargokit/run_build_tool.sh"
FAKE_DART = r'''#!/usr/bin/env python3
import os
from pathlib import Path
import sys

stage = {"pub": "pub", "compile": "compile"}.get(sys.argv[1], "run")
counter = Path(stage + ".count")
count = int(counter.read_text()) + 1 if counter.exists() else 1
counter.write_text(str(count))
codes = os.environ[stage.upper() + "_CODES"].split(",")
code = int(codes[min(count - 1, len(codes) - 1)])
if stage == "compile" and code == 0:
    Path("bin/build_tool_runner.dill").touch()
sys.exit(code)
'''


class NativeLauncherTests(unittest.TestCase):
    def run_case(self, pub, compile_, run, expected, counts):
        with tempfile.TemporaryDirectory(prefix="native launcher spaces ") as folder:
            root = Path(folder)
            dart = root / "flutter/bin/cache/dart-sdk/bin/dart"
            dart.parent.mkdir(parents=True)
            dart.write_text(FAKE_DART)
            dart.chmod(0o755)
            work = root / "runner"
            env = dict(os.environ, FLUTTER_ROOT=str(root / "flutter"),
                       CARGOKIT_TOOL_TEMP_DIR=str(work), PUB_CODES=pub,
                       COMPILE_CODES=compile_, RUN_CODES=run)
            result = subprocess.run(["bash", str(LAUNCHER), "build-gradle"],
                                    env=env, capture_output=True, text=True)
            self.assertEqual(result.returncode, expected, result.stdout + result.stderr)
            actual = tuple(int((work / (stage + ".count")).read_text())
                           if (work / (stage + ".count")).exists() else 0
                           for stage in ("pub", "compile", "run"))
            self.assertEqual(actual, counts)

    def test_success(self):
        self.run_case("0", "0", "0", 0, (1, 1, 1))

    def test_native_failure(self):
        self.run_case("0", "0", "17", 17, (1, 1, 1))

    def test_initial_pub_failure(self):
        self.run_case("11", "0", "0", 11, (1, 0, 0))

    def test_initial_compile_failure(self):
        self.run_case("0", "12", "0", 12, (1, 1, 0))

    def test_retry_success(self):
        self.run_case("0", "0", "253,0", 0, (2, 2, 2))

    def test_retry_native_failure(self):
        self.run_case("0", "0", "253,19", 19, (2, 2, 2))

    def test_retry_pub_failure_does_not_run_stale_kernel(self):
        self.run_case("0,11", "0", "253,0", 11, (2, 1, 1))

    def test_retry_compile_failure_does_not_run_stale_kernel(self):
        self.run_case("0", "0,12", "253,0", 12, (2, 2, 1))

    def test_invalid_snapshot_retried_only_once(self):
        self.run_case("0", "0", "253", 253, (2, 2, 2))


if __name__ == "__main__":
    unittest.main()
