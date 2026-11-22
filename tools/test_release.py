"""Regression checks for release identity, signatures and downloadable assets."""

import hashlib
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
import zipfile

import release


class ApkVerificationTest(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.apk = Path(self.temporary.name) / "Hadoo.apk"
        self.info = {"version": "2.0.0-dev.18", "build_number": "2021"}
        self.certificate = "a" * 64
        self.signature = f"Signer #1 certificate SHA-256 digest: {self.certificate}\n"
        self.badging = (
            "package: name='com.icemonkey.hadoo' versionCode='2021' "
            "versionName='2.0.0-dev.18'\n"
        )
        self.env = {"ANDROID_HOME": self.temporary.name,
                    "ANDROID_KEYSTORE_PASSWORD": "private-value"}
        self.write_apk()

    def write_apk(self, abi="arm64-v8a", *, rust=True):
        with zipfile.ZipFile(self.apk, "w") as archive:
            libraries = ["libapp.so", "libflutter.so"]
            if rust:
                libraries.append("librust_lib_flick_player.so")
            for library in libraries:
                archive.writestr(f"lib/{abi}/{library}", b"fixture")

    def verify(self):
        with patch.object(release.subprocess, "check_output", side_effect=[
            self.signature, self.badging,
        ]) as commands:
            release.verify_apk(self.apk, self.info, self.env, self.certificate)
        for call in commands.call_args_list:
            self.assertNotIn("ANDROID_KEYSTORE_PASSWORD", call.kwargs["env"])

    def test_the_verified_release_keeps_signing_credentials_out_of_inspection(self):
        self.verify()

    def test_another_signer_is_rejected(self):
        self.signature = self.signature.replace(self.certificate, "b" * 64)
        with self.assertRaisesRegex(ValueError, "certificate"):
            self.verify()

    def test_a_debug_package_cannot_be_published_as_a_release(self):
        self.badging = self.badging.replace("com.icemonkey.hadoo'", "com.icemonkey.hadoo.test'")
        with self.assertRaisesRegex(ValueError, "package or version"):
            self.verify()

    def test_the_native_version_must_match_the_release(self):
        self.badging = self.badging.replace("versionCode='2021'", "versionCode='2016'")
        with self.assertRaisesRegex(ValueError, "package or version"):
            self.verify()

    def test_an_incompatible_abi_is_rejected(self):
        self.write_apk("armeabi-v7a")
        with self.assertRaisesRegex(ValueError, "ARM64"):
            self.verify()

    def test_an_apk_without_the_audio_engine_is_rejected(self):
        self.write_apk(rust=False)
        with self.assertRaisesRegex(ValueError, "missing librust"):
            self.verify()


class ChecksumTest(unittest.TestCase):
    def test_retry_replaces_the_manifest_without_hashing_the_old_manifest(self):
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            asset = directory / "Hadoo.apk"
            asset.write_bytes(b"first")
            release.checksums(directory)
            asset.write_bytes(b"second")
            release.checksums(directory)
            expected = hashlib.sha256(b"second").hexdigest()
            self.assertEqual((directory / "SHA256SUMS.txt").read_text(),
                             f"{expected}  Hadoo.apk\n")

    def test_empty_assets_fail_before_publication(self):
        with tempfile.TemporaryDirectory() as temporary:
            with self.assertRaisesRegex(ValueError, "No release assets"):
                release.checksums(Path(temporary))


if __name__ == "__main__":
    unittest.main()
