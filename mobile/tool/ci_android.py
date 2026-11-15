"""Ubuntu Actions prerequisites. All mutable tool state lives under RUNNER_TEMP."""

import ctypes
import json
import os
from pathlib import Path
import re
import subprocess
import sys

RUST = "1.98.0"
NDK = "28.2.13676358"
HOST = "x86_64-unknown-linux-gnu"
# Lokal ships ARM64 binaries only, for both release and debug Flutter builds.
TARGETS = ("aarch64-linux-android",)


def export(values):
    with open(os.environ["GITHUB_ENV"], "a", encoding="utf-8") as stream:
        for name, value in values.items():
            if "\n" in str(value) or "\r" in str(value):
                raise ValueError("Invalid multiline environment path")
            stream.write(f"{name}={value}\n")


def environment():
    root = Path(os.environ["RUNNER_TEMP"]).resolve()
    paths = {
        "PUB_CACHE": root / "konnekted-pub",
        "CARGO_HOME": root / "konnekted-cargo",
        "RUSTUP_HOME": root / "konnekted-rustup",
        "GRADLE_USER_HOME": root / "konnekted-gradle",
        "ANDROID_HOME": root / "konnekted-android",
        "ANDROID_SDK_ROOT": root / "konnekted-android",
    }
    for path in paths.values():
        path.mkdir(parents=True, exist_ok=True)
    export({**paths, "RUSTUP_TOOLCHAIN": RUST,
            "CARGO_BUILD_JOBS": "2", "CARGO_INCREMENTAL": "0",
            "GRADLE_OPTS": "-Dorg.gradle.daemon=false -Dorg.gradle.workers.max=2"})


def output(*args):
    return subprocess.check_output(args, text=True).strip()


def setup():
    flutter = json.loads(output("flutter", "--version", "--machine"))
    if (flutter["frameworkVersion"] != "3.47.1"
            or flutter["dartSdkVersion"].split()[0] != "3.13.1"):
        raise ValueError("Expected Flutter 3.47.1 / Dart 3.13.1")
    extension = (Path(os.environ["FLUTTER_ROOT"]) / "packages/flutter_tools/gradle"
                 / "src/main/kotlin/FlutterExtension.kt").read_text()
    if not re.search(r'ndkVersion\s*(?::\s*String)?\s*=\s*"' + re.escape(NDK) + '"', extension):
        raise ValueError("Flutter's NDK default no longer matches the pinned NDK")

    sdk = Path(os.environ["ANDROID_HOME"])
    platform = sdk / "platforms/android-37"
    # SDK 37 is distributed as 37.0; the app intentionally uses compileSdk = 37.
    if not platform.exists():
        if not (sdk / "platforms/android-37.0/android.jar").is_file():
            raise ValueError("Android platform 37.0 is missing")
        platform.symlink_to("android-37.0", target_is_directory=True)
    ndk = sdk / "ndk" / NDK
    if not (ndk / "source.properties").is_file():
        raise ValueError("Pinned Android NDK is missing")

    libraries = sorted(Path("/usr/lib").glob("llvm-*/lib/libclang.so"))
    if not libraries:
        raise ValueError("libclang-dev did not provide a host libclang.so")
    libclang = libraries[-1]
    ctypes.CDLL(str(libclang))  # Verify a loadable host library, not the NDK driver.
    export({"LIBCLANG_PATH": libclang.parent, "ANDROID_NDK_HOME": ndk,
            "ANDROID_NDK_ROOT": ndk})

    subprocess.run(["rustup", "toolchain", "install", RUST, "--profile", "minimal", "--no-self-update",
                    "--target", ",".join(TARGETS)], check=True)
    # Cargokit pins the same numbered toolchain for debug/profile/release.
    if output("rustup", "run", RUST, "rustc", "--version").split()[1] != RUST:
        raise ValueError("Rust did not resolve to the pinned compiler")
    installed = output("rustup", "target", "list", "--toolchain", RUST, "--installed").splitlines()
    if not set(TARGETS).issubset(installed):
        raise ValueError("Cargokit is missing required Android targets")
    if "precompiled_binaries:" in Path("rust/cargokit.yaml").read_text():
        raise ValueError("Re-evaluate source-build policy before enabling precompiled engine binaries")
    print(f"Flutter 3.47.1 / Dart 3.13.1 / Rust {RUST} / NDK {NDK}; LIBCLANG_PATH={libclang.parent}")


if __name__ == "__main__":
    try:
        {"environment": environment, "setup": setup}[sys.argv[1]]()
    except (ValueError, OSError, subprocess.CalledProcessError) as error:
        sys.exit(f"Android CI setup failed: {error}")
