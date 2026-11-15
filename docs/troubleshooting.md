# Troubleshooting

## Playback and search

- **A song says unavailable, requires verification, or returns HTTP 403.** Check your network and retry the Song result once. Switch between Wi-Fi and mobile data if appropriate. If YouTube Music itself asks for sign-in or verification, complete that in the provider's own interface. A result may still be restricted by the provider. Try an available alternate recording or an enabled source.
- **An iPhone loads the video instead of song audio.** Choose the **Songs** filter and open the Song result. Check **Settings → About** for build 2015 or later. Build 2015 added guest-session initialization for direct audio on iOS.
- **Global Search finds a track that cannot play.** Global Search supplies metadata. Check **Settings → Online sources → Playback search priority** and whether an enabled provider has the recording.
- **Recommendations or playlists are missing.** Reconnect YouTube Music in **Settings → Data → Accounts** and refresh Home or Library. Check the Google account or channel selected during sign-in. Hadoo playlists are on the device. YouTube playlists are tied to the selected account.
- **A track cannot be added to a YouTube playlist.** Use a YouTube Music result for the same recording or add the original to a **Hadoo playlist**. A result that already exists in the YouTube playlist shows a duplicate message.

## Downloads

Check free space and any media access prompt, then retry the download on a stable network. A saved track should appear under **Downloads**. If it plays only while online, check that the download completed and try opening the saved item directly. On Android, also check access to the folder Hadoo uses for the current install.

## Android installation

- **Device is missing or unauthorized.** Unlock it, use a USB data cable, enable USB debugging, and accept the computer's fingerprint on the device. Run `adb devices` again. Use `adb -s SERIAL install -r PATH_TO_APK` when several devices are listed.
- **Signature mismatch or update incompatible.** Get the APK signed by the same key as the installed package. A debug key from a different computer may produce this error. Keep the existing copy while you recover the key or export your data.
- **Version downgrade.** Install a newer build with the same package ID and key. Check the installed build number in **Settings → About**.
- **Package unsupported.** Use the ARM64 Android preview on an ARM64 device running Android 8.0 or later.

## iPhone signing and refresh

- **Hadoo shows “No Longer Available”.** Check the countdown in **AltStore → My Apps** and follow the [refresh and recovery steps](device-setup.md#refresh-or-update-on-iphone).
- **AltStore cannot find AltServer.** Open AltServer on the computer and try USB with the phone unlocked and trusted. For Wi-Fi, use the same network and follow the [AltServer troubleshooting guide](https://faq.altstore.io/altstore-classic/troubleshooting-guide).
- **Developer Mode is missing.** Connect and start pairing with the Mac first, then look in **Settings → Privacy & Security → Developer Mode**. Restart and confirm the prompt.
- **Apple sign-in or anisette error.** Use a current AltServer from the official site, reopen it, and retry with the same Apple Account. Enter any Apple verification code locally in AltStore or AltServer.
- **An IPA needs signing.** Select it inside AltStore, or run the target through Xcode with your signing team.

## Report a problem

Open a [GitHub issue](https://github.com/khushen-vistara-labs/Hadoo/issues) with the build number, OS version, device model, steps, and exact error. For playback, include the public track link, source, and whether the provider's own app can play it. If you share Hadoo's logs, review them first and remove signed URLs, session data, local paths, and other private details.
