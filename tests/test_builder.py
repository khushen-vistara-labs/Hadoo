# SPDX-License-Identifier: GPL-3.0-only
"""Exercise input validation, artifact integrity, signing and Android resource contracts."""
import copy
import importlib.util
import json
from pathlib import Path
import os
import struct
import subprocess
import tempfile
import unittest
from unittest import mock
import xml.etree.ElementTree as ET

SPEC = importlib.util.spec_from_file_location("hadoo_builder", Path(__file__).resolve().parents[1] / "tools/hadoo.py")
h = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(h)


class BuilderTests(unittest.TestCase):
    def setUp(self):
        self.profile, self.lock = h.configuration()

    def test_source_requires_original_package_supported_version_and_official_signer(self):
        info = {"package": self.lock["source"]["package"], "version": "9.30.53"}
        trusted = {self.lock["source"]["certificate_sha256"][0]}
        h.validate_source(info, trusted, self.lock)
        for bad_info, certs in [({**info, "package": self.lock["output"]["package"]}, trusted),
                                ({**info, "version": "0.0.0"}, trusted), (info, set()),
                                (info, {"0" * 64}), (info, trusted | {"0" * 64})]:
            with self.subTest(info=bad_info, certs=certs), self.assertRaises(h.HadooError):
                h.validate_source(bad_info, certs, self.lock)

    def test_badging_parser_and_split_rejection(self):
        text = "package: name='com.google.android.apps.youtube.music' versionCode='93053240' versionName='9.30.53' platformBuildVersionName='15'\n"
        self.assertEqual(h.parse_badging(text)["version"], "9.30.53")
        for bad in ("not an apk", text.rstrip() + " split='config.arm64_v8a'\n"):
            with self.assertRaises(h.HadooError):
                h.parse_badging(bad)

    def test_certificate_parser_handles_multiple_signers(self):
        a, b = "A" * 64, "b" * 64
        text = f"Signer #1 certificate SHA-256 digest: {a}\nSigner #2 certificate SHA-256 digest: {b}"
        self.assertEqual(h.parse_certificates(text), {a.lower(), b})

    def test_rotated_apk_signers_are_distinct_from_google_play_source_stamp(self):
        a, b, stamp = "a" * 64, "b" * 64, "c" * 64
        text = f"V3.1 Signer: (minSdkVersion=33) certificate SHA-256 digest: {a}\nV3.0 Signer: (minSdkVersion=24) certificate SHA-256 digest: {b}\nSource Stamp Signer: certificate SHA-256 digest: {stamp}"
        self.assertEqual(h.parse_certificates(text), {a, b})

    def test_cached_tool_corruption_is_rejected_without_execution_or_network(self):
        with tempfile.TemporaryDirectory() as directory:
            p = Path(directory) / "tool.jar"
            p.write_bytes(b"unexpected executable")
            artifact = {"filename": p.name, "sha256": "0" * 64}
            with mock.patch.object(h.urllib.request, "urlopen") as download:
                with self.assertRaisesRegex(h.HadooError, "Checksum mismatch"):
                    h.download_verified(artifact, p.parent)
                download.assert_not_called()

    def test_verified_cached_tool_needs_no_network(self):
        with tempfile.TemporaryDirectory() as directory:
            p = Path(directory) / "tool.jar"
            p.write_bytes(b"a pinned artifact")
            with mock.patch.object(h.urllib.request, "urlopen") as download:
                self.assertEqual(h.download_verified({"filename": p.name, "sha256": h.sha256(p)}, p.parent), p)
                download.assert_not_called()

    def test_unknown_or_duplicate_patch_names_fail(self):
        for patches in (self.profile["patches"] + ["invented patch"], self.profile["patches"] * 2, []):
            profile = {**self.profile, "patches": patches}
            with self.assertRaises(h.HadooError):
                h.validate_config(profile, self.lock)

    def test_untrusted_download_locations_and_malformed_hashes_fail(self):
        for edit in ({"url": "https://example.com/tool.jar"}, {"filename": "../tool.jar"}, {"sha256": "latest"}):
            lock = copy.deepcopy(self.lock)
            lock["desktop"].update(edit)
            with self.assertRaises(h.HadooError):
                h.validate_config(self.profile, lock)

    def test_options_disable_unselected_patches_and_bind_to_bundle_hash(self):
        destination = Path("/tmp/Hadoo assets with spaces")
        document = h.options_document(self.profile, self.lock, destination)
        self.assertEqual(document[0]["meta"]["sha256"], self.lock["patches"]["sha256"])
        selected = {name for name, item in document[0]["patches"].items() if item["enabled"]}
        self.assertEqual(selected, set(self.profile["patches"]))
        branding = document[0]["patches"]["Custom branding"]["options"]
        self.assertEqual(branding, {"customName": "Hadoo", "customIcon": str(destination / "icons"), "appIcon": "custom"})
        self.assertEqual(json.loads(json.dumps(document)), document)

    def test_real_bundle_inventory_must_include_branding_options(self):
        inventory = "\n".join("Name: " + name for name in self.profile["patches"])
        with self.assertRaisesRegex(h.HadooError, "options"):
            h.check_inventory(inventory, self.profile)
        inventory = inventory.replace("Name: Custom branding", "Name: Custom branding\n Key: customName\n Key: customIcon\n Key: appIcon")
        inventory = inventory.replace("Name: Change header", "Name: Change header\n Key: custom")
        h.check_inventory(inventory, self.profile)

    def test_patch_command_keeps_paths_with_spaces_in_single_arguments(self):
        with mock.patch.dict(os.environ, {}, clear=True):
            command = h.patch_arguments(Path("/jdk/bin/java"), self.lock, Path("/tmp/my options.json"), Path("/tmp/my input.apk"),
                                        Path("/tmp/my output/Hadoo.apk"), Path("/tmp/my report.json"), Path("/private/key.keystore"))
        self.assertIn("/tmp/my options.json", command)
        self.assertEqual(command[-1], "/tmp/my input.apk")
        self.assertEqual(command[command.index("--bytecode-mode") + 1], "FULL")
        self.assertNotIn("--force", command)
        self.assertNotIn("--continue-on-error", command)
        self.assertNotIn("--install", command)
        self.assertNotIn("--unsigned", command)

    def test_missing_signing_key_cannot_silently_create_a_new_identity(self):
        with tempfile.TemporaryDirectory() as directory, mock.patch.object(h, "LOCAL", Path(directory)):
            with self.assertRaisesRegex(h.HadooError, "Import your Morphe Manager"):
                h.signing_key(None, False)
            self.assertFalse((Path(directory) / "signing/morphe.keystore").exists())

    def test_partial_or_failed_patches_cannot_be_promoted_to_latest_build(self):
        valid = {"success": True, "failedPatches": [], "appliedPatches": self.profile["patches"]}
        h.validate_patch_report(valid, self.profile)
        for bad in ({**valid, "success": False}, {**valid, "failedPatches": ["Downloads"]},
                    {**valid, "appliedPatches": ["Custom branding"]}, {}):
            with self.subTest(report=bad), self.assertRaises(h.HadooError):
                h.validate_patch_report(bad, self.profile)

    def test_key_import_does_not_overwrite_another_key(self):
        with tempfile.TemporaryDirectory() as directory, mock.patch.object(h, "LOCAL", Path(directory) / "local"):
            source = Path(directory) / "export.keystore"
            source.write_bytes(b"private key bytes")
            h.import_key(str(source))
            target = h.LOCAL / "signing/morphe.keystore"
            self.assertEqual(target.read_bytes(), source.read_bytes())
            self.assertEqual(target.stat().st_mode & 0o777, 0o600)
            source.write_bytes(b"a different key")
            with self.assertRaisesRegex(h.HadooError, "different signing key"):
                h.import_key(str(source))
            self.assertEqual(target.read_bytes(), b"private key bytes")

    def test_concurrent_build_is_refused_and_lock_is_released_on_failure(self):
        with tempfile.TemporaryDirectory() as directory, mock.patch.object(h, "LOCAL", Path(directory)):
            with self.assertRaisesRegex(RuntimeError, "simulated"):
                with h.build_lock():
                    with self.assertRaisesRegex(h.HadooError, "Another build"):
                        with h.build_lock():
                            self.fail("second build acquired a live lock")
                    raise RuntimeError("simulated failure")
            self.assertFalse((Path(directory) / "build.lock").exists())

    def test_install_rejects_modified_or_external_latest_artifact(self):
        with tempfile.TemporaryDirectory() as directory, mock.patch.object(h, "LOCAL", Path(directory)):
            apk = Path(directory) / "builds/run/Hadoo.apk"
            apk.parent.mkdir(parents=True)
            apk.write_bytes(b"signed apk")
            h.write_json(Path(directory) / "latest-build.json", {"apk": str(apk), "sha256": h.sha256(apk)})
            self.assertEqual(h.latest_apk(), apk.resolve())
            apk.write_bytes(b"tampered apk")
            with self.assertRaises(h.HadooError):
                h.latest_apk()
            external = Path(directory) / "external.apk"
            external.write_bytes(b"external apk")
            h.write_json(Path(directory) / "latest-build.json", {"apk": str(external), "sha256": h.sha256(external)})
            with self.assertRaises(h.HadooError):
                h.latest_apk()

    def test_generated_android_resources_have_correct_dimensions_and_transparency(self):
        java = h.find_java()
        with tempfile.TemporaryDirectory() as directory:
            out = Path(directory)
            original_hashes = {name: h.sha256(h.ROOT / "assets/images" / name) for name in ("hadoo-mark.png", "hadoo-logo.png")}
            subprocess.run([str(java), "-Djava.awt.headless=true", str(h.ROOT / "tools/Branding.java"),
                            str(h.ROOT / "assets/images/hadoo-mark.png"), str(h.ROOT / "assets/images/hadoo-logo.png"), str(out)],
                           check=True, capture_output=True, text=True, timeout=45)
            for density, size, notification in zip(("mdpi", "hdpi", "xhdpi", "xxhdpi", "xxxhdpi"), (108, 162, 216, 324, 432), (24, 36, 48, 72, 96)):
                for layer in ("background", "foreground"):
                    data = (out / f"icons/mipmap-{density}/morphe_adaptive_{layer}_custom.png").read_bytes()
                    self.assertEqual(data[:8], b"\x89PNG\r\n\x1a\n")
                    self.assertEqual(struct.unpack(">II", data[16:24]), (size, size))
                    self.assertEqual(data[25], 6, "Adaptive layers must support alpha")
                data = (out / f"icons/drawable-{density}/morphe_notification_icon_custom.png").read_bytes()
                self.assertEqual(struct.unpack(">II", data[16:24]), (notification, notification))
            for density, dims in zip(("hdpi", "xhdpi", "xxhdpi", "xxxhdpi"), ((121, 36), (160, 48), (240, 72), (320, 96))):
                data = (out / f"header/drawable-{density}/morphe_header_custom_dark.png").read_bytes()
                self.assertEqual(struct.unpack(">II", data[16:24]), dims)
            vector = ET.parse(out / "icons/drawable/morphe_adaptive_monochrome_custom.xml").getroot()
            self.assertEqual(vector.tag, "vector")
            self.assertTrue(vector.find("path").get("{http://schemas.android.com/apk/res/android}pathData"))
            for name, expected in original_hashes.items():
                self.assertEqual(h.sha256(h.ROOT / "assets/images" / name), expected)

    def test_branding_preserves_thin_strokes_and_removes_color_fringes(self):
        java = h.find_java()
        with tempfile.TemporaryDirectory() as directory:
            subprocess.run([str(java.parent / "javac"), "-d", directory,
                            str(h.ROOT / "tools/Branding.java"), str(h.ROOT / "tests/BrandingQualityTest.java")],
                           check=True, capture_output=True, text=True, timeout=45)
            subprocess.run([str(java), "-Djava.awt.headless=true", "-cp", directory, "BrandingQualityTest"],
                           check=True, capture_output=True, text=True, timeout=30)

    def test_local_artifacts_are_git_ignored(self):
        names = [".hadoo-local/input/original.apk", ".hadoo-local/signing/morphe.keystore", ".hadoo-local/legacy-2026-11-03/app.json", "accidental.apk", "accidental.jks", "accidental.pem"]
        result = subprocess.run(["git", "check-ignore", "--stdin"], input="\n".join(names) + "\n", cwd=h.ROOT, capture_output=True, text=True)
        self.assertEqual(set(result.stdout.splitlines()), set(names))


if __name__ == "__main__":
    unittest.main()
