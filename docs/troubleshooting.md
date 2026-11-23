# Troubleshooting

## Playback and search

- **A song says unavailable, requires verification, or returns HTTP 403.** Check your network and retry the Song result once. Switch between Wi-Fi and mobile data if appropriate. If YouTube Music itself asks for sign-in or verification, complete that in the provider's own interface. A result may still be restricted by the provider. Try an available alternate recording or an enabled source.
- **An iPhone loads the video instead of song audio.** Choose the **Songs** filter and open the Song result. Check **Settings → About** for build 2015 or later. Build 2015 added guest-session initialization for direct audio on iOS.
- **Global Search finds a track that cannot play.** Global Search supplies metadata. Check **Settings → Online sources → Playback search priority** and whether an enabled provider has the recording.
- **Recommendations or playlists are missing.** Reconnect YouTube Music in **Settings → Data → Accounts** and refresh Home or Library. Check the Google account or channel selected during sign-in. Hadoo playlists are on the device. YouTube playlists are tied to the selected account.
- **A track cannot be added to a YouTube playlist.** Use a YouTube Music result for the same recording or add the original to a **Hadoo playlist**. A result that already exists in the YouTube playlist shows a duplicate message.

## Downloads

Check free space and any media access prompt, then retry the download on a stable network. A saved track should appear under **Downloads**. If it plays only while online, check that the download completed and try opening the saved item directly. On Android, also check access to the folder Hadoo uses for the current install.

- **Retry shows zero downloaded and many skipped.** The counters describe the current run. Existing files and duplicate playlist entries are skipped. Check the separate **Unavailable/Failed** count and open the saved track from Downloads. A playlist's online result and its downloaded library entry are different playback routes.
- **Downloads seem missing after installing another APK.** Compare the package ID. The debug preview (`com.icemonkey.hadoo.test`), release app (`com.icemonkey.hadoo`), and earlier patched app have separate private storage. Opening a different install does not migrate their libraries.
- **Offline lyrics are missing.** Audio can finish downloading even when the lyrics lookup fails. Open the saved song online and check/save available lyrics, or supply a matching local lyrics file. See [offline lyrics](user-guide.md#offline-lyrics).

## Playlist sync

YouTube playlists use the selected YouTube account. Hadoo playlists are on-device in the current distributed builds. A saved username does not create a Hadoo cloud account. **Google Drive sync is unavailable for this build** means the build lacks a configured integration; reconnecting YouTube cannot enable it. Downloads and local audio need separate copies on each phone. See [playlist types](user-guide.md#choose-a-playlist-type).

## USB headphone volume on Android

Exclusive USB sends audio directly to the DAC, so the phone’s media volume buttons have no effect. Use the DAC’s volume control or Hadoo’s volume slider when the route supports it. A fixed-volume bit-perfect route may provide neither.

To use the phone’s buttons, open **Settings → Advanced output → USB DAC**, turn off **Auto Bit-perfect for USB DACs**, and choose **just_audio / ExoPlayer** under **Playback Engine**. Let the engine restart if prompted. If the current track still uses the old route, reconnect the headphones and restart playback.

## Android installation

- **Device is missing or unauthorized.** Unlock it, use a USB data cable, enable USB debugging, and accept the computer's fingerprint on the device. Run `adb devices` again. Use `adb -s SERIAL install -r PATH_TO_APK` when several devices are listed.
- **Signature mismatch or update incompatible.** Get the APK signed by the same key as the installed package. A debug key from a different computer may produce this error. Keep the existing copy while you recover the key or export your data.
- **Version downgrade.** Install a newer build with the same package ID and key. Check the installed build number in **Settings → About**.
- **Package unsupported.** Use the ARM64 Android preview on an ARM64 device running Android 8.0 or later.

## iPhone signing and refresh

- **Hadoo shows “No Longer Available”.** Its signing may have expired. For an AltStore-managed install, check **My Apps** and refresh. For a direct AltServer install, repeat the direct installation using the same Apple Account. Follow the [refresh and recovery steps](device-setup.md#refresh-or-update-on-iphone).
- **Hadoo works but is missing from AltStore → My Apps.** A direct **AltServer → Sideload .ipa** install is not registered in AltStore. Import the IPA on the iPhone using **My Apps → +** to put it under AltStore's management. This does not remove the signing requirement or seven-day limit for free accounts.
- **The IPA is not in the iPhone's file picker.** First extract the `hadoo-ios` artifact ZIP. Copy the resulting `.ipa` to the iPhone; a file on the Mac does not automatically appear on the phone. Open the blue **Files** app and use **Browse → Downloads**, iCloud Drive, or **On My iPhone → Hadoo** if it was copied into Hadoo's shared folder. Close and reopen that folder to refresh it. Then navigate to the same location from AltStore's **My Apps → + → Browse**. See [transfer and import steps](device-setup.md#install-through-altstore-classic).
- **AltStore cannot find AltServer.** Open AltServer on the computer and try USB with the phone unlocked and trusted. For Wi-Fi, use the same network and follow the [AltServer troubleshooting guide](https://faq.altstore.io/altstore-classic/troubleshooting-guide).
- **Developer Mode is missing.** Connect and start pairing with the Mac first, then look in **Settings → Privacy & Security → Developer Mode**. Restart and confirm the prompt.
- **Apple sign-in or anisette error.** Use a current AltServer from the official site, reopen it, and retry with the same Apple Account. Enter any Apple verification code locally in AltStore or AltServer.
- **An IPA needs signing.** Select it inside AltStore, or run the target through Xcode with your signing team.
- **About only says 2.0.0.** That is the iPhone marketing version. Build **2016** distinguishes this package from earlier 2.0.0 builds. Signing refreshes do not increment the Hadoo build number.
- **Two Hadoo icons appear after changing installation methods.** The final signed bundle IDs differ. Keep the original app and its data while checking signing identity and backup/export options; the copies do not share private storage.

## GitHub checks and downloads

**Hadoo checks** runs Dart analysis and widget/service regressions. **Release APK and IPA** compiles and inspects native packages separately. One can fail while the other passes. Open the failed job's log for the actual error; a deprecation warning alone is not the failure cause. Failed screenshot comparisons are attached as `flutter-golden-diffs` for seven days. [Validation and screenshot references](../CONTRIBUTING.md#validate-changes)

A manual release-workflow test without a release tag keeps its packages under the run's **Artifacts**; it does not publish a GitHub Release. Missing release attachments after a published release need the release workflow's result checked. See [automatic releases](maintenance.md#automatic-github-releases).

## Report a problem

Open a [GitHub issue](https://github.com/khushen-vistara-labs/Hadoo/issues) with the build number, OS version, device model, steps, and exact error. For playback, include the public track link, source, and whether the provider's own app can play it. If you share Hadoo's logs, review them first and remove signed URLs, session data, local paths, and other private details.
