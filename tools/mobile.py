#!/usr/bin/env python3
"""Build the standalone Flutter app. Morphe is an explicit legacy command."""
import argparse
import json
import os
import re
from pathlib import Path
import runpy
import shutil
import subprocess
import sys
import tempfile
import urllib.parse

ROOT = Path(__file__).resolve().parent.parent
APP = ROOT / "mobile"
LOCAL = ROOT / ".hadoo-local"


def environment():
    env = dict(os.environ)
    env.setdefault("XDG_CONFIG_HOME", str(LOCAL / "xdg"))
    env.setdefault("FLUTTER_SUPPRESS_ANALYTICS", "true")
    for key, directory in (("PUB_CACHE", "pub-cache"), ("CARGO_HOME", "cargo"),
                           ("RUSTUP_HOME", "rustup"), ("ANDROID_HOME", "android-sdk"),
                           ("GRADLE_USER_HOME", "gradle")):
        if (LOCAL / directory).is_dir():
            env.setdefault(key, str(LOCAL / directory))
    if (LOCAL / "cargo/bin").is_dir():
        env["PATH"] = str(LOCAL / "cargo/bin") + os.pathsep + env.get("PATH", "")
    jdk = Path("/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home")
    if jdk.is_dir():
        env.setdefault("JAVA_HOME", str(jdk))
    return env


def flutter():
    explicit = os.environ.get("FLUTTER_BIN")
    if explicit:
        return explicit
    local = LOCAL / "sdk/flutter/bin/flutter"
    return str(local) if local.is_file() else shutil.which("flutter")


def run(args, env, cwd=APP):
    print("hadoo > " + " ".join(str(arg) for arg in args), flush=True)
    return subprocess.call([str(arg) for arg in args], cwd=cwd, env=env)


def prepare_ios(env):
    """Use upstream's verified native archives outside GitHub Actions too."""
    LOCAL.mkdir(exist_ok=True)
    env.setdefault("LOKAL_IOS_NATIVE_ARCHIVE_CACHE", str(LOCAL / "ios-native-archives"))
    with tempfile.NamedTemporaryFile(dir=LOCAL, mode="w+", suffix=".env") as bridge:
        staging = dict(env, GITHUB_ENV=bridge.name)
        for script in ("ios_prepare_ffmpeg.py", "ios_prepare_smb.py"):
            result = run([sys.executable, APP / "tool" / script], staging)
            if result:
                return result
        bridge.seek(0)
        for line in bridge:
            key, separator, value = line.strip().partition("=")
            if separator and key in ("FFMPEG_KIT_IOS_URL", "LOKAL_FFMPEG_IOS_SHA256"):
                env[key] = value
    # CocoaPods skips prepare_command for an already-installed development
    # pod. Stage its generated frameworks explicitly after verified cleanup.
    config = APP / ".dart_tool/package_config.json"
    packages = json.loads(config.read_text())["packages"]
    package = next(p for p in packages if p["name"] == "ffmpeg_kit_flutter_new_audio")
    uri = urllib.parse.urlparse(urllib.parse.urljoin(config.as_uri(), package["rootUri"]))
    if uri.scheme != "file":
        raise RuntimeError("FFmpeg must resolve to the locked local package")
    plugin = Path(urllib.parse.unquote(uri.path))
    return run(["/bin/bash", plugin / "scripts/setup_ios.sh"], env, cwd=plugin / "ios")


def main():
    if sys.argv[1:2] == ["legacy"]:
        sys.argv = [sys.argv[0]] + sys.argv[2:]
        runpy.run_path(str(ROOT / "tools/hadoo.py"), run_name="__main__")
        return 0
    parser = argparse.ArgumentParser(description="Hadoo standalone music app (Android / iOS)")
    subs = parser.add_subparsers(dest="command", required=True)
    for command in ("doctor", "setup", "check", "test", "analyze"):
        subs.add_parser(command)
    subs.add_parser("legacy", help="Archived Morphe builder; see docs/legacy-morphe.md")
    build = subs.add_parser("build")
    build.add_argument("platform", choices=("android", "ios"), nargs="?", default="android")
    build.add_argument("--release", action="store_true")
    build.add_argument("--carplay", action="store_true", help="Use Apple's restricted CarPlay audio entitlement")
    launch = subs.add_parser("run")
    launch.add_argument("platform", choices=("android", "ios"), nargs="?", default="android")
    launch.add_argument("--device")
    args = parser.parse_args()
    env = environment()
    sdk = flutter()
    if args.command == "doctor":
        print("Hadoo 2.0 — standalone Flutter / Rust, no Morphe or microG required")
        print("Flutter:", sdk or "missing (install Flutter 3.47.1+ or set FLUTTER_BIN)")
        print("Android SDK:", env.get("ANDROID_HOME", "use flutter doctor to locate"))
        print("Rust:", shutil.which("rustc", path=env.get("PATH")) or "missing (Rust 1.98+ required)")
        return run([sdk, "doctor"], env) if sdk else 1
    if not sdk:
        parser.exit(1, "Flutter 3.47.1+ is required. Install it or set FLUTTER_BIN. See mobile/README.md.\n")
    if args.command == "setup":
        return run([sdk, "pub", "get"], env)
    if args.command in ("check", "analyze"):
        result = run([sdk, "analyze", "--no-pub", "--no-fatal-infos", "--no-fatal-warnings"], env)
        if result or args.command == "analyze":
            return result
    if args.command in ("check", "test"):
        return run([sdk, "test", "--no-pub", "test/hadoo", "test/services/android_auto_catalog_test.dart",
                    "test/discovery", "test/features/updates"], env)
    if args.command == "build":
        if args.carplay and args.platform != "ios":
            parser.error("--carplay applies to iOS builds")
        if args.carplay:
            env["XCODE_XCCONFIG_FILE"] = str(APP / "ios/HadooCarPlay.xcconfig")
        if args.platform == "android":
            return run([sdk, "build", "apk", "--release" if args.release else "--debug",
                        "--flavor", "full", "--target-platform", "android-arm64"], env)
        result = prepare_ios(env)
        if result:
            return result
        # Produces an unsigned artifact. Signing/installation is explicit in Xcode.
        version = re.search(r"(?m)^version:\s*(\d+\.\d+\.\d+)", (APP / "pubspec.yaml").read_text())
        if not version:
            raise RuntimeError("pubspec.yaml must declare a three-part marketing version")
        return run([sdk, "build", "ios", "--release", "--no-codesign",
                    "--build-name", version.group(1)], env)
    if args.command == "run":
        command = [sdk, "run"]
        if args.platform == "android":
            command += ["--flavor", "full"]
        if args.device:
            command += ["--device-id", args.device]
        return run(command, env)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
