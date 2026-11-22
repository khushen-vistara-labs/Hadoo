#!/usr/bin/env python3
"""Build and package the tagged Hadoo source for GitHub Releases."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import plistlib
import re
import shutil
import subprocess
import sys
import tempfile
import zipfile

import mobile

ROOT = Path(__file__).resolve().parent.parent
APP = ROOT / "mobile"
sys.path.insert(0, str(APP / "tool"))
from ci_release import SECRETS, metadata, signing_material


def version():
    return metadata((APP / "pubspec.yaml").read_text(), flavor="full")


def run(args, *, env=None, cwd=APP):
    subprocess.run([str(arg) for arg in args], cwd=cwd, env=env, check=True)


def digest(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def commit():
    return subprocess.check_output(
        ["git", "rev-parse", "HEAD"], cwd=ROOT, text=True,
    ).strip()


def write_metadata():
    values = {**version(), "commit": commit(), "tag": os.environ.get("RELEASE_TAG", "")}
    if values["tag"]:
        run(["git", "check-ref-format", "refs/tags/" + values["tag"]], cwd=ROOT)
    with open(os.environ["GITHUB_OUTPUT"], "a") as output:
        for key, value in values.items():
            if "\n" in value or "\r" in value:
                raise ValueError("Invalid release metadata")
            output.write(f"{key}={value}\n")


def source(output):
    output.mkdir(parents=True, exist_ok=True)
    run([
        "git", "archive", "--format=tar.gz", "--prefix=Hadoo/",
        "--output", output / "Hadoo-source.tar.gz", "HEAD",
    ], cwd=ROOT)
    shutil.copyfile(APP / "LICENSE", output / "LICENSE")
    shutil.copyfile(APP / "THIRD_PARTY_NOTICES.md", output / "THIRD_PARTY_NOTICES.md")
    shutil.copyfile(ROOT / "NOTICE", output / "NOTICE")
    (output / "INSTALL.txt").write_text(
        "Android: install Hadoo-*-arm64.apk on Android 8.0+ with a 64-bit ARM system.\n"
        "The release package is com.icemonkey.hadoo. It installs separately from\n"
        "the locally installed com.icemonkey.hadoo.test previews.\n\n"
        "iPhone: import Hadoo-unsigned.ipa into AltStore Classic or another\n"
        "compatible signing tool. The IPA requires your Apple Account signing\n"
        "before installation on iOS 16+. Downloading it alone does not install it.\n\n"
        "SHA256SUMS.txt verifies the downloads. Hadoo-source.tar.gz contains\n"
        "the matching repository source, including native code and licenses.\n"
    )


def verify_apk(apk, info, env, certificate):
    tools = Path(env["ANDROID_HOME"]) / "build-tools/36.0.0"
    public_env = {key: value for key, value in env.items() if key not in SECRETS}
    signature = subprocess.check_output(
        [str(tools / "apksigner"), "verify", "--print-certs", str(apk)],
        env=public_env, text=True,
    )
    signers = re.findall(r"Signer #\d+ certificate SHA-256 digest: ([0-9a-fA-F]+)", signature)
    if [signer.lower() for signer in signers] != [certificate]:
        raise ValueError("APK signing certificate differs from the release key")
    badging = subprocess.check_output(
        [str(tools / "aapt"), "dump", "badging", str(apk)], env=public_env, text=True,
    )
    expected = (
        "name='com.icemonkey.hadoo'",
        f"versionCode='{info['build_number']}'",
        f"versionName='{info['version']}'",
    )
    if not all(value in badging.splitlines()[0] for value in expected):
        raise ValueError("APK package or version differs from release metadata")
    with zipfile.ZipFile(apk) as archive:
        if archive.testzip() is not None:
            raise ValueError("APK contains a corrupt entry")
        native = {name for name in archive.namelist() if name.startswith("lib/") and name.endswith(".so")}
        if {name.split("/")[1] for name in native} != {"arm64-v8a"}:
            raise ValueError("APK must contain ARM64 native libraries only")
        for library in ("libapp.so", "libflutter.so", "librust_lib_flick_player.so"):
            if f"lib/arm64-v8a/{library}" not in native:
                raise ValueError(f"APK is missing {library}")


def android(output):
    info = version()
    env = mobile.environment()
    with tempfile.TemporaryDirectory(prefix="hadoo-release-signing-") as temporary:
        with signing_material(env, Path(temporary) / "key") as signing_env:
            certificate = hashlib.sha256(subprocess.check_output([
                "keytool", "-exportcert", "-keystore", signing_env["ANDROID_KEYSTORE_PATH"],
                "-alias", signing_env["ANDROID_KEY_ALIAS"],
                "-storepass:env", "ANDROID_KEYSTORE_PASSWORD",
            ], env=signing_env)).hexdigest()
            run([
                mobile.flutter(), "build", "apk", "--release", "--flavor", "full",
                "--target-platform", "android-arm64", "--build-name", info["version"],
                "--build-number", info["build_number"],
            ], env=signing_env)
        apk = APP / "build/app/outputs/flutter-apk/app-full-release.apk"
        verify_apk(apk, info, env, certificate)
    output.mkdir(parents=True, exist_ok=True)
    target = output / f"Hadoo-{info['version']}-arm64.apk"
    shutil.copyfile(apk, target)
    (output / "full-metadata.json").write_text(json.dumps({
        "version": info["version"], "versionCode": int(info["build_number"]),
        "flavor": "full", "abis": ["arm64-v8a"], "sha256": digest(target),
        "signingCertificateSha256": certificate, "commit": commit(),
    }, indent=2) + "\n")


def ios(output):
    info = version()
    env = mobile.environment()
    if mobile.prepare_ios(env):
        raise RuntimeError("iPhone native dependency preparation failed")
    run([
        mobile.flutter(), "build", "ios", "--release", "--no-codesign",
        "--build-name", info["version"].split("-")[0],
        "--build-number", info["build_number"],
    ], env=env)
    app = APP / "build/ios/iphoneos/Runner.app"
    actual = plistlib.loads((app / "Info.plist").read_bytes())
    if (actual["CFBundleIdentifier"] != "com.icemonkey.hadoo" or
            actual["CFBundleVersion"] != info["build_number"] or
            actual["CFBundleShortVersionString"] != info["version"].split("-")[0]):
        raise ValueError("iPhone bundle identity or version differs from release metadata")
    run([
        sys.executable, APP / "tool/ios_package.py", app,
        output / "Hadoo-unsigned.ipa",
    ], env=env)


def checksums(output):
    files = sorted(path for path in output.iterdir()
                   if path.is_file() and path.name != "SHA256SUMS.txt")
    if not files:
        raise ValueError("No release assets to checksum")
    (output / "SHA256SUMS.txt").write_text("".join(
        f"{digest(path)}  {path.name}\n" for path in files
    ))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("metadata", "source", "android", "ios", "checksums"))
    parser.add_argument("--output", type=Path, default=ROOT / "dist/release")
    args = parser.parse_args()
    if args.command == "metadata":
        write_metadata()
    else:
        actions = {"source": source, "android": android, "ios": ios, "checksums": checksums}
        actions[args.command](args.output.resolve())


if __name__ == "__main__":
    main()
