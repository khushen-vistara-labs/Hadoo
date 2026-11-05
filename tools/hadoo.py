#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-only
"""Build a personal Hadoo APK using pinned, unmodified Morphe tools."""
from __future__ import annotations

import argparse
import contextlib
import datetime as dt
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import urllib.error
import urllib.request
import zipfile

ROOT = Path(__file__).resolve().parents[1]
LOCAL = ROOT / ".hadoo-local"
DEFAULTS_PATCH = "Hadoo defaults"
DEFAULTS_BUNDLE = "hadoo-defaults.mpp"


class HadooError(Exception):
    """An actionable build failure, safe to show without a traceback."""


def read_json(path: Path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, ValueError) as exc:
        raise HadooError(f"Cannot read {path}: {exc}") from exc


def write_json(path: Path, value) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2) + "\n", encoding="utf-8")


def sha256(path: Path) -> str:
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest() if hasattr(hashlib, "file_digest") else _hash_stream(stream)


def _hash_stream(stream) -> str:
    digest = hashlib.sha256()
    for chunk in iter(lambda: stream.read(1024 * 1024), b""):
        digest.update(chunk)
    return digest.hexdigest()


def validate_config(profile: dict, lock: dict) -> None:
    if lock.get("schema_version") != 1:
        raise HadooError("Unsupported upstream lock schema.")
    if not isinstance(profile.get("name"), str) or not profile["name"].strip():
        raise HadooError("The profile needs a nonempty app name.")
    available = {item["name"]: set(item["options"]) for item in lock["available_patches"]}
    selected = profile.get("patches", [])
    if not selected or len(selected) != len(set(selected)):
        raise HadooError("Select at least one patch; duplicate patch names are not allowed.")
    unknown = set(selected) - available.keys()
    if unknown:
        raise HadooError("Unknown patch names: " + ", ".join(sorted(unknown)))
    required = {"Custom branding", "Change header", "GmsCore support", "Downloads", "Remove background playback restrictions"}
    if missing := required - set(selected):
        raise HadooError("Required Hadoo patches are missing: " + ", ".join(sorted(missing)))
    for name, keys in {"Custom branding": {"customName", "customIcon", "appIcon"}, "Change header": {"custom"}}.items():
        if not keys <= available[name]:
            raise HadooError(f"The pinned {name} options have changed; review the lock file.")
    for component in ("desktop", "patches"):
        artifact = lock[component]
        expected_prefix = f"https://github.com/MorpheApp/morphe-{'desktop' if component == 'desktop' else 'patches'}/releases/download/v{artifact['version']}/"
        if not artifact["url"].startswith(expected_prefix) or Path(artifact["filename"]).name != artifact["filename"]:
            raise HadooError(f"Invalid {component} release location.")
        if not re.fullmatch(r"[a-f0-9]{64}", artifact["sha256"]):
            raise HadooError(f"Invalid {component} SHA-256.")


def configuration() -> tuple[dict, dict]:
    profile = read_json(ROOT / "config/hadoo.json")
    lock = read_json(ROOT / "config/upstream-lock.json")
    validate_config(profile, lock)
    return profile, lock


def process_env(java: Path | None = None) -> dict[str, str]:
    env = os.environ.copy()
    env["MORPHE_DATA_DIR"] = str(LOCAL / "morphe-data")
    if java:
        env["JAVA_HOME"] = str(java.parent.parent)
        env["PATH"] = str(java.parent) + os.pathsep + env.get("PATH", "")
    return env


def run(command: list[str], *, java: Path | None = None, capture: bool = False, timeout: int = 60) -> str:
    try:
        result = subprocess.run(command, cwd=ROOT, env=process_env(java), check=False,
                                text=True, stdout=subprocess.PIPE if capture else None,
                                stderr=subprocess.STDOUT if capture else None, timeout=timeout)
    except FileNotFoundError as exc:
        raise HadooError(f"Required executable not found: {command[0]}") from exc
    except subprocess.TimeoutExpired as exc:
        raise HadooError(f"{Path(command[0]).name} exceeded its {timeout}s timeout; no installation was attempted.") from exc
    if result.returncode:
        # Do not print the command line: signing arguments can contain passwords.
        if capture and result.stdout:
            print(result.stdout, file=sys.stderr)
        raise HadooError(f"{Path(command[0]).name} failed (exit {result.returncode}). See the output above.")
    return result.stdout or ""


def java_major(output: str) -> int:
    match = re.search(r'(?:openjdk|java) version "(\d+)', output)
    return int(match[1]) if match else 0


def find_java() -> Path:
    candidates = []
    for env_key in ("HADOO_JAVA_HOME", "JAVA_HOME"):
        if value := os.environ.get(env_key):
            candidates.append(Path(value) / "bin/java")
    if current := shutil.which("java"):
        candidates.append(Path(current))
    candidates += [Path("/opt/homebrew/opt/openjdk@21/bin/java"), Path("/usr/local/opt/openjdk@21/bin/java"),
                   Path("/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/java")]
    candidates += sorted(Path("/Library/Java/JavaVirtualMachines").glob("*/Contents/Home/bin/java"))
    for candidate in candidates:
        if not candidate.is_file():
            continue
        try:
            probe = subprocess.run([str(candidate), "-version"], capture_output=True, text=True, timeout=10)
            if probe.returncode == 0 and java_major(probe.stdout + probe.stderr) >= 21:
                return candidate.resolve()
        except (OSError, subprocess.TimeoutExpired):
            continue
    raise HadooError("Java 21+ is required. Install a JDK and set HADOO_JAVA_HOME to its home directory.")


def find_sdk_tools() -> dict[str, str]:
    roots = [Path(v).expanduser() for k in ("ANDROID_HOME", "ANDROID_SDK_ROOT") if (v := os.environ.get(k))]
    roots += [Path.home() / "Library/Android/sdk", Path.home() / "Android/Sdk"]
    if local_app_data := os.environ.get("LOCALAPPDATA"):
        roots.append(Path(local_app_data) / "Android/Sdk")
    suffix = ".exe" if os.name == "nt" else ""
    for root in roots:
        versions = sorted((root / "build-tools").glob("*"), key=lambda p: tuple(int(x) for x in re.findall(r"\d+", p.name)), reverse=True)
        for version in versions:
            aapt = version / f"aapt2{suffix}"
            signer = version / ("apksigner.bat" if os.name == "nt" else "apksigner")
            if aapt.is_file() and signer.is_file():
                adb = root / "platform-tools" / f"adb{suffix}"
                return {"aapt2": str(aapt), "apksigner": str(signer), "adb": str(adb) if adb.is_file() else shutil.which("adb") or ""}
    aapt, signer = shutil.which("aapt2"), shutil.which("apksigner")
    if aapt and signer:
        return {"aapt2": aapt, "apksigner": signer, "adb": shutil.which("adb") or ""}
    raise HadooError("Android SDK Build-Tools are required (aapt2 and apksigner). Install them through Android Studio and set ANDROID_HOME.")


def download_verified(artifact: dict, directory: Path) -> Path:
    directory.mkdir(parents=True, exist_ok=True)
    target = directory / artifact["filename"]
    if target.exists():
        if sha256(target) != artifact["sha256"]:
            raise HadooError(f"Checksum mismatch for cached {target.name}. Remove that file and rerun setup.")
        return target
    request = urllib.request.Request(artifact["url"], headers={"User-Agent": "Hadoo-local-builder/1.0"})
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(dir=directory, delete=False, suffix=".part") as output:
            temporary = Path(output.name)
            print(f"Downloading {artifact['filename']}…", flush=True)
            with urllib.request.urlopen(request, timeout=60) as source:
                if not source.url.startswith("https://"):
                    raise HadooError("Refusing an insecure download redirect.")
                shutil.copyfileobj(source, output)
        if sha256(temporary) != artifact["sha256"]:
            raise HadooError(f"Checksum mismatch for {artifact['filename']}; downloaded file discarded.")
        temporary.replace(target)
        return target
    except (OSError, urllib.error.URLError) as exc:
        raise HadooError(f"Could not download {artifact['filename']}: {exc}. Rerun setup when connected.") from exc
    finally:
        if temporary:
            temporary.unlink(missing_ok=True)


def tool_paths(lock: dict) -> tuple[Path, Path]:
    return tuple(LOCAL / "tools" / lock[key]["filename"] for key in ("desktop", "patches"))


def validate_tool_cache(lock: dict) -> tuple[Path, Path]:
    paths = tool_paths(lock)
    for component, path in zip(("desktop", "patches"), paths):
        if not path.is_file():
            raise HadooError("Build tools are missing. Run ./hadoo setup first.")
        if sha256(path) != lock[component]["sha256"]:
            raise HadooError(f"Checksum mismatch for {path.name}; refusing to execute it.")
    return paths


def patch_inventory(java: Path, lock: dict) -> str:
    desktop, patches = validate_tool_cache(lock)
    return run([str(java), "-jar", str(desktop), "list-patches", "--patches", str(patches),
                "--filter-package-name", lock["source"]["package"], "--with-options", "--with-versions"], java=java, capture=True)


def check_inventory(text: str, profile: dict) -> None:
    inventory = {}
    current = None
    for line in text.splitlines():
        if line.startswith("Name: "):
            current = line.removeprefix("Name: ").strip()
            inventory[current] = set()
        elif current and line.strip().startswith("Key: "):
            inventory[current].add(line.strip().removeprefix("Key: ").strip())
    if missing := set(profile["patches"]) - inventory.keys():
        raise HadooError("The actual patch bundle is missing: " + ", ".join(sorted(missing)))
    for patch, keys in {"Custom branding": {"customName", "customIcon", "appIcon"}, "Change header": {"custom"}}.items():
        if not keys <= inventory.get(patch, set()):
            raise HadooError(f"The actual {patch} options do not match this builder.")


def read_defaults() -> dict:
    morphe = read_json(ROOT / "config/phone-settings.json")
    native = read_json(ROOT / "config/native-settings.json")
    if not isinstance(morphe, dict) or not morphe:
        raise HadooError("Morphe defaults must be a nonempty settings object.")
    for key, value in morphe.items():
        if not re.fullmatch(r"morphe_[a-z0-9_]+", key) or type(value) not in (bool, str) or value == "":
            raise HadooError(f"Unsupported Morphe default: {key}")
    if not isinstance(native, dict) or set(native) != {"pref_key_dont_play_video", "pref_key_dont_play_nma_video"} or any(type(v) is not bool for v in native.values()):
        raise HadooError("Native defaults must explicitly select both supported audio-only preferences.")
    return {"morphe": morphe, "native": native}


def property_value(value: str) -> str:
    result = []
    for char in value:
        if char in "\\\n\r\t":
            result.append({"\\": "\\\\", "\n": "\\n", "\r": "\\r", "\t": "\\t"}[char])
        elif char == " ":
            result.append("\\ ")
        elif 0x20 <= ord(char) < 0x7f:
            result.append(char)
        else:
            encoded = char.encode("utf-16-be")
            result.extend(f"\\u{int.from_bytes(encoded[i:i+2], 'big'):04x}" for i in range(0, len(encoded), 2))
    return "".join(result)


def defaults_properties(defaults: dict) -> str:
    lines = []
    for group in ("morphe", "native"):
        for key, value in sorted(defaults[group].items()):
            kind = "boolean" if type(value) is bool else "string"
            text = str(value).lower() if type(value) is bool else value
            lines.append(f"{group}.{kind}.{key}={property_value(text)}")
    return "\n".join(lines) + "\n"


def prepare_defaults(java: Path, lock: dict) -> Path:
    desktop, _ = validate_tool_cache(lock)
    defaults = read_defaults()
    destination = LOCAL / "defaults"
    classes = destination / "classes"
    if classes.exists():
        shutil.rmtree(classes)
    classes.mkdir(parents=True)
    javac = java.with_name("javac" + java.suffix)
    if not javac.is_file():
        raise HadooError("A Java 21+ JDK with javac is required to build the Hadoo defaults add-on.")
    # Morphe's add-on contract limits bundled class files to Java 17.
    run([str(javac), "--release", "17", "-cp", str(desktop), "-d", str(classes),
         str(ROOT / "tools/HadooDefaultsPatch.java")], java=java)
    (classes / "hadoo-defaults.properties").write_text(defaults_properties(defaults), encoding="ascii")
    bundle = destination / DEFAULTS_BUNDLE
    with zipfile.ZipFile(bundle, "w", compression=zipfile.ZIP_DEFLATED) as archive:
        for file in sorted(classes.rglob("*")):
            if file.is_file():
                entry = zipfile.ZipInfo(file.relative_to(classes).as_posix(), (1980, 1, 1, 0, 0, 0))
                entry.compress_type = zipfile.ZIP_DEFLATED
                archive.writestr(entry, file.read_bytes())
    inventory = run([str(java), "-jar", str(desktop), "list-patches", "--patches", str(bundle)], java=java, capture=True)
    if f"Name: {DEFAULTS_PATCH}\n" not in inventory:
        raise HadooError("The compiled Hadoo defaults add-on was not recognized by Morphe.")
    return bundle


def options_document(profile: dict, lock: dict, branding: Path, addon: Path | None = None) -> list[dict]:
    entries = {p["name"]: {"enabled": p["name"] in profile["patches"], "options": {key: None for key in p["options"]}} for p in lock["available_patches"]}
    entries["Custom branding"]["options"] = {"customName": profile["name"], "customIcon": str(branding / "icons"), "appIcon": "custom"}
    entries["Change header"]["options"] = {"custom": str(branding / "header")}
    document = [{"meta": {"source": lock["patches"]["filename"], "sha256": lock["patches"]["sha256"]}, "patches": entries}]
    if addon is not None:
        document.append({"meta": {"source": DEFAULTS_BUNDLE, "sha256": sha256(addon)},
                         "patches": {DEFAULTS_PATCH: {"enabled": True, "options": {}}}})
    return document


def prepare(java: Path, profile: dict, lock: dict) -> Path:
    destination = LOCAL / "branding"
    run([str(java), "-Djava.awt.headless=true", str(ROOT / "tools/Branding.java"),
         str(ROOT / profile["mark"]), str(ROOT / profile["logo"]), str(destination)], java=java)
    options = LOCAL / "options.json"
    addon = prepare_defaults(java, lock)
    write_json(options, options_document(profile, lock, destination, addon))
    return options


def setup(profile: dict, lock: dict) -> None:
    java = find_java()
    for key in ("desktop", "patches"):
        download_verified(lock[key], LOCAL / "tools")
    check_inventory(patch_inventory(java, lock), profile)
    prepare(java, profile, lock)
    print("Verified Morphe Desktop " + lock["desktop"]["version"] + " and patches " + lock["patches"]["version"] + ".")
    print("Hadoo branding, embedded defaults and patch options are ready.")


def parse_badging(text: str) -> dict:
    match = re.search(r"^package: name='([^']+)' versionCode='([^']+)' versionName='([^']*)'", text, re.MULTILINE)
    if not match:
        raise HadooError("Could not read APK identity. Supply a complete, original APK, not an APK bundle or split.")
    if re.search(r"^package:.*\bsplit='", text, re.MULTILINE):
        raise HadooError("A split APK cannot be patched alone. Supply a complete, original APK.")
    return {"package": match[1], "version_code": match[2], "version": match[3]}


def parse_certificates(text: str) -> set[str]:
    # Google Play's source-stamp certificate identifies the distributor, not the
    # app signing identity. APK signing-key rotation can expose several signers.
    signer_lines = "\n".join(line for line in text.splitlines() if re.match(r"(?:Signer #\d+|V\d+(?:\.\d+)? Signer:)", line))
    return {s.lower() for s in re.findall(r"certificate SHA-256 digest:\s*([a-fA-F0-9]{64})", signer_lines)}


def validate_source(info: dict, certificates: set[str], lock: dict) -> None:
    source = lock["source"]
    if info["package"] != source["package"]:
        raise HadooError("Supply the original YouTube Music APK. An already patched APK or another app cannot be used.")
    if info["version"] not in source["supported_versions"]:
        raise HadooError(f"Unsupported YouTube Music {info['version']}. Use {source['recommended_version']} (supported: {', '.join(source['supported_versions'])}).")
    if not certificates or not certificates <= set(source["certificate_sha256"]):
        raise HadooError("The source APK's signing certificate does not match the official fingerprints in Morphe's pinned metadata.")


def inspect_apk(path: Path, java: Path, sdk: dict) -> tuple[dict, set[str]]:
    if not path.is_file() or path.suffix.lower() != ".apk":
        raise HadooError(f"Original APK not found: {path}. Supply a .apk file on this computer.")
    try:
        with zipfile.ZipFile(path) as archive:
            if not {"AndroidManifest.xml", "classes.dex"} <= set(archive.namelist()):
                raise HadooError("The APK is missing its manifest or DEX bytecode.")
            if corrupt := archive.testzip():
                raise HadooError(f"Corrupt APK entry: {corrupt}")
    except zipfile.BadZipFile as exc:
        raise HadooError("The input is not a readable APK archive.") from exc
    info = parse_badging(run([sdk["aapt2"], "dump", "badging", str(path)], java=java, capture=True))
    certs = parse_certificates(run([sdk["apksigner"], "verify", "--print-certs", str(path)], java=java, capture=True))
    return info, certs


def patch_arguments(java: Path, lock: dict, options: Path, source: Path, output: Path, report: Path, key: Path) -> list[str]:
    desktop, patches = tool_paths(lock)
    command = [str(java), "-Xmx3g", "-jar", str(desktop), "patch", "--patches", str(patches),
               "--patches", str(LOCAL / "defaults" / DEFAULTS_BUNDLE),
               "--options-file", str(options), "--bytecode-mode", "FULL", "--keystore", str(key),
               "--signer", "Hadoo", "--out", str(output), "--result-file", str(report),
               "--temporary-files-path", str(output.parent / "scratch")]
    for variable, flag in (("HADOO_KEYSTORE_PASSWORD", "--keystore-password"),
                           ("HADOO_KEY_PASSWORD", "--keystore-entry-password"),
                           ("HADOO_KEY_ALIAS", "--keystore-entry-alias")):
        if value := os.environ.get(variable):
            command.extend([flag, value])
    command.append(str(source))
    return command


def validate_patch_report(report: dict, profile: dict) -> None:
    if report.get("success") is not True or report.get("failedPatches"):
        raise HadooError("Morphe reported a failed patch; no installation was attempted.")
    if missing := (set(profile["patches"]) | {DEFAULTS_PATCH}) - set(report.get("appliedPatches", [])):
        raise HadooError("The build skipped required patches: " + ", ".join(sorted(missing)))


def signing_key(explicit: str | None, allow_new: bool) -> Path:
    key = Path(explicit).expanduser().resolve() if explicit else LOCAL / "signing/morphe.keystore"
    if not key.is_file() and not allow_new:
        raise HadooError("Import your Morphe Manager signing key with ./hadoo import-key /path/to/exported.keystore. This is required to update your installed app. Use build --new-key only for a separately signed build.")
    if explicit and not key.is_file():
        raise HadooError("The specified keystore does not exist; refusing to create a key at that path.")
    key.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    return key


@contextlib.contextmanager
def build_lock():
    path = LOCAL / "build.lock"
    LOCAL.mkdir(parents=True, exist_ok=True)
    try:
        fd = os.open(path, os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o600)
    except FileExistsError as exc:
        raise HadooError("Another build is running. If it was interrupted, remove .hadoo-local/build.lock after checking it has stopped.") from exc
    try:
        with os.fdopen(fd, "w") as stream:
            stream.write(str(os.getpid()))
        yield
    finally:
        path.unlink(missing_ok=True)


def build(args, profile: dict, lock: dict) -> None:
    java, sdk = find_java(), find_sdk_tools()
    source = Path(args.apk).expanduser().resolve()
    info, certs = inspect_apk(source, java, sdk)
    validate_source(info, certs, lock)
    key = signing_key(args.keystore, args.new_key)
    validate_tool_cache(lock)
    check_inventory(patch_inventory(java, lock), profile)
    with build_lock():
        options = prepare(java, profile, lock)
        stamp = dt.datetime.now(dt.timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
        output_dir = LOCAL / "builds" / stamp
        output_dir.mkdir(parents=True)
        output = output_dir / "Hadoo.apk"
        report = output_dir / "patch-result.json"
        print(f"Building Hadoo from verified YouTube Music {info['version']}…", flush=True)
        try:
            run(patch_arguments(java, lock, options, source, output, report, key), java=java, timeout=1200)
        finally:
            if key.is_file():
                key.chmod(0o600)
        validate_patch_report(read_json(report), profile)
        addon = LOCAL / "defaults" / DEFAULTS_BUNDLE
        defaults_check = run([str(java), "-Xmx2g", "-cp", os.pathsep.join((str(tool_paths(lock)[0]), str(addon))),
                              "app.hadoo.patches.HadooDefaultsPatch", "verify", str(output)], java=java, capture=True)
        print(defaults_check.strip())
        built, built_certs = inspect_apk(output, java, sdk)
        if built["package"] != lock["output"]["package"] or not built_certs:
            raise HadooError("Output package or signature verification failed; no installation was attempted.")
        badging = run([sdk["aapt2"], "dump", "badging", str(output)], java=java, capture=True)
        labels = re.findall(r"^(?:application-label|launchable-activity).*", badging, re.MULTILINE)
        if not any(profile["name"] in label for label in labels):
            raise HadooError("The patched APK does not expose the Hadoo launcher name; no installation was attempted.")
        manifest = {"name": profile["name"], "built_at": stamp, "input": {**info, "sha256": sha256(source), "certificate_sha256": sorted(certs)},
                    "output": {**built, "filename": "Hadoo.apk", "sha256": sha256(output), "certificate_sha256": sorted(built_certs)},
                    "upstream": {k: {"version": lock[k]["version"], "sha256": lock[k]["sha256"]} for k in ("desktop", "patches")},
                    "patches": profile["patches"] + [DEFAULTS_PATCH],
                    "defaults": {**read_defaults(), "bundle_sha256": sha256(addon),
                                 "source_sha256": sha256(ROOT / "tools/HadooDefaultsPatch.java"), "apk_verified": True},
                    "device_tested": False}
        write_json(output_dir / "build.json", manifest)
        shutil.copy2(addon, output_dir / DEFAULTS_BUNDLE)
        for filename in ("LICENSE", "NOTICE"):
            shutil.copy2(ROOT / filename, output_dir / filename)
        shutil.copytree(ROOT / "third_party", output_dir / "third_party")
        write_json(LOCAL / "latest-build.json", {"apk": str(output), "sha256": manifest["output"]["sha256"]})
        print(f"Verified and signed APK: {output}")
        print("Install explicitly with ./hadoo install. Playback and downloads still require device testing.")


def import_key(source_arg: str) -> None:
    source = Path(source_arg).expanduser().resolve()
    if not source.is_file() or source.stat().st_size == 0:
        raise HadooError("Select the nonempty keystore file exported from Morphe Manager.")
    target = LOCAL / "signing/morphe.keystore"
    target.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    if target.exists():
        if sha256(source) == sha256(target):
            print("This signing key is already imported.")
            return
        raise HadooError("A different signing key already exists. Use build --keystore /path/to/key to select another without overwriting it.")
    with target.open("xb") as output:
        output.write(source.read_bytes())
    target.chmod(0o600)
    print("Signing key imported into ignored local storage. It will never be added to build reports.")


def latest_apk() -> Path:
    record = read_json(LOCAL / "latest-build.json")
    apk = Path(record["apk"]).resolve()
    if not apk.is_relative_to((LOCAL / "builds").resolve()) or not apk.is_file() or sha256(apk) != record["sha256"]:
        raise HadooError("The latest build is missing or changed. Build again before installing.")
    return apk


def install(args) -> None:
    java, sdk = find_java(), find_sdk_tools()
    apk = latest_apk()
    adb = sdk["adb"]
    if not adb:
        raise HadooError("Install Android SDK Platform-Tools to use adb, or copy the APK to your phone.")
    command = [adb] + (["-s", args.serial] if args.serial else [])
    output = run(command + ["install", "-r", str(apk)], java=java, capture=True, timeout=180)
    print(output.strip())


def doctor(profile: dict, lock: dict) -> None:
    issues = []
    print(f"{profile['name']} — personal YouTube Music build")
    for label, callback in (("Java 21+", find_java), ("Android SDK", find_sdk_tools)):
        try:
            print(f"OK  {label}: {callback()}")
        except HadooError as exc:
            issues.append(str(exc))
            print(f"NEEDED  {exc}")
    try:
        validate_tool_cache(lock)
        print("OK  Pinned Morphe tools and SHA-256 checksums")
    except HadooError as exc:
        print(f"NEXT  {exc}")
    key = LOCAL / "signing/morphe.keystore"
    print("OK  Imported signing key" if key.is_file() else "NEXT  Import the signing key exported from your phone's Morphe Manager")
    print("NEXT  ./hadoo build /path/to/original-youtube-music.apk")
    print("Supported stable versions: " + ", ".join(lock["source"]["supported_versions"]))
    if issues:
        raise HadooError("Install the missing prerequisites above, then rerun doctor.")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Build your personal Hadoo-branded YouTube Music APK locally.")
    commands = parser.add_subparsers(dest="command", required=True)
    for name, help_text in (("doctor", "Check Java, Android tools and local setup"), ("setup", "Download and verify pinned Morphe tools; prepare branding"),
                            ("prepare", "Export branding and patch options without network access"), ("patches", "Check the profile against the real patch bundle"),
                            ("check", "Run offline repository tests")):
        commands.add_parser(name, help=help_text)
    builder = commands.add_parser("build", help="Patch and sign an original YouTube Music APK")
    builder.add_argument("apk", help="Path to a complete, unpatched YouTube Music APK")
    builder.add_argument("--keystore", help="Use this existing signing key without importing it")
    builder.add_argument("--new-key", action="store_true", help="Allow creation of a new key; it cannot update a differently signed app")
    importer = commands.add_parser("import-key", help="Import your Morphe Manager keystore into ignored local storage")
    importer.add_argument("path")
    installer = commands.add_parser("install", help="Install the last verified build with adb install -r")
    installer.add_argument("--serial", help="ADB device serial, required when several devices are connected")
    args = parser.parse_args(argv)
    try:
        profile, lock = configuration()
        if args.command == "doctor":
            doctor(profile, lock)
        elif args.command == "setup":
            setup(profile, lock)
        elif args.command == "prepare":
            print("Prepared patch options: " + str(prepare(find_java(), profile, lock)))
        elif args.command == "patches":
            java = find_java()
            inventory = patch_inventory(java, lock)
            check_inventory(inventory, profile)
            prepare_defaults(java, lock)
            print(f"Verified {len(profile['patches'])} upstream patches, branding options and the local Hadoo defaults add-on.")
        elif args.command == "build":
            build(args, profile, lock)
        elif args.command == "import-key":
            import_key(args.path)
        elif args.command == "install":
            install(args)
        elif args.command == "check":
            run([sys.executable, "-m", "unittest", "discover", "-s", "tests", "-v"], timeout=180)
        return 0
    except (HadooError, OSError, ValueError) as exc:
        print(f"Hadoo: {exc}", file=sys.stderr)
        return 1
    except KeyboardInterrupt:
        print("\nHadoo: interrupted.", file=sys.stderr)
        return 130


if __name__ == "__main__":
    raise SystemExit(main())
