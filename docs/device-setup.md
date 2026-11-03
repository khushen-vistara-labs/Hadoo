# Device setup

## Use your existing patched app's signing identity

1. On your phone open **Morphe Manager → Settings → Signing key → Export**.
2. Save `Morphe.keystore` to Downloads and copy it to your computer.
3. Run `./hadoo import-key /path/to/Morphe.keystore`.
4. Keep that original exported file backed up privately. A settings export does
   not include the keystore.

Hadoo stores the imported copy at `.hadoo-local/signing/morphe.keystore` with
owner-only file permissions. It refuses to overwrite a different key.

For a key with custom credentials, set `HADOO_KEYSTORE_PASSWORD`,
`HADOO_KEY_PASSWORD`, and `HADOO_KEY_ALIAS` in your local shell before building.
Do not commit shell exports or include credentials in issue reports. Manager's
standard exported key normally works without overrides.

## Copy the original APK over USB

Enable USB debugging in Android developer options, connect the phone, and accept
its USB debugging authorization. Check `adb devices` for the device.

```sh
mkdir -p .hadoo-local/input
adb pull '/sdcard/Download/your-original-youtube-music.apk' .hadoo-local/input/youtube-music.apk
./hadoo setup
./hadoo build .hadoo-local/input/youtube-music.apk
./hadoo install
```

Use a full APK signed by Google. Hadoo rejects unsupported versions, patched
inputs, standalone split APKs and unrecognized signing certificates. It accepts
Google's signing-key rotation while distinguishing the Google Play distribution
source stamp from APK signing certificates.

## Install and check

`./hadoo install` targets the last verified build, checks its saved checksum, and
uses `adb install -r`. Add `--serial DEVICE` if more than one phone is connected.
Android refuses a mismatched signature; Hadoo never resolves this by uninstalling
an app or clearing its data. Import the matching Manager keystore and rebuild.

Keep microG installed. The Hadoo build uses the normal Morphe package identity
and does not need a separate Google account or separate microG installation.

The previous React Native Hadoo app can remain installed until you decide what
to do with its local playlists and downloads. Its package is separate.

After installation select the Custom header in the app's Morphe settings. Then
test songs, next/previous, lock-screen controls, background playback and real
offline downloads. Retain an older working APK in local storage for troubleshooting.

Reference: [Morphe signing and backup guide](https://github.com/MorpheApp/morphe-manager/blob/main/docs/backup-and-keystore.md).
