# Install or update Hadoo

Hadoo runs on **Android 8.0+ with a 64-bit ARM system** and **iOS 16+**. It is a standalone app; installing the current app does not require the older APK patcher or microG. See [platform status](mobile-rewrite.md) for build numbers and device checks.

Get matching artifacts from [GitHub Releases](https://github.com/khushen-vistara-labs/Hadoo/releases) when available, or follow [Build from source](build.md). A GitHub source ZIP contains code. Choose an APK for Android or an IPA for signing on iPhone.

Published releases automatically build their APK and IPA. Allow the **Release APK and IPA** Actions run to finish before downloading. Choose `Hadoo-<version>-arm64.apk` for an Android phone or compatible Android head unit. Choose `Hadoo-unsigned.ipa` for signing through AltStore Classic on iPhone. The included `INSTALL.txt` and `SHA256SUMS.txt` identify the installation requirements and download checksums.

If a build was tested through **Actions → Release APK and IPA** without publishing a release, open the successful run's **Artifacts**. Download `hadoo-android` or `hadoo-ios`, signing in to GitHub if requested. Extract the ZIP to find the APK or IPA. The source archive and artifact ZIP are not installers. Test artifacts are retained for 14 days; release attachments remain with the release.

An iPhone can show version **2.0.0** while Android shows a development suffix. Compare the **build number** to identify an update: the current committed app version is `2.0.0-dev.17+2016`, and its iPhone package is **2.0.0, build 2016**. Later local Android previews have their own build numbers.

## Android

1. Transfer the APK to your phone and open it from Files or Downloads. If Android asks, enable **Allow from this source** for the app opening the file. You can turn the permission off after installation.
2. Install the APK, open **Hadoo**, and tap **Start listening**. Search for a song to confirm that the installation can reach YouTube Music.

For USB installation, enable USB debugging, connect and unlock the phone, and accept the computer's authorization prompt. Add Android Platform Tools to your PATH, then use these commands from the repository root. [Android Platform Tools](https://developer.android.com/tools/releases/platform-tools)

```sh
adb devices
adb install -r mobile/build/app/outputs/flutter-apk/app-full-debug.apk
```

For a downloaded release APK, substitute its actual path. Use `adb -s SERIAL install -r PATH_TO_APK` when more than one Android device is connected.

Use a build with the **same package ID and signing key** to keep data in an existing install. Local debug APKs use `com.icemonkey.hadoo.test` and the debug key on the computer that built them. Release builds use `com.icemonkey.hadoo` and the maintainer's release key. If you have an existing preview, use the same build computer and key for subsequent debug updates. See [Android install errors](troubleshooting.md#android-installation) before removing any existing copy.

### Android head units and Android Auto

An infotainment unit that runs ordinary Android apps can install the APK using its file manager if it meets the same Android version and ARM64 requirements. A receiver that only supports Android Auto cannot install the APK itself; install Hadoo on the Android phone and connect that phone. The ordinary app's layout on standalone head units still needs device testing. Set up the connection while parked. See [car playback](user-guide.md#in-the-car).

## iPhone

The downloaded IPA is unsigned. An Apple Account signs it before iOS can install and run it. There is no separate Hadoo account required for this. Hadoo does not receive your Apple signing password. To build an IPA yourself, use the [iPhone build guide](build.md#iphone).

### Install through AltStore Classic

Use this route to put Hadoo in **AltStore → My Apps** and manage its signing countdown and refreshes there.

1. Install AltServer on your computer. Plug in your unlocked iPhone, tap **Trust** when prompted, and use **AltServer → Install AltStore** to select the iPhone. [macOS instructions](https://faq.altstore.io/altstore-classic/how-to-install-altstore-macos) · [Windows instructions](https://faq.altstore.io/altstore-classic/how-to-install-altstore-windows)
2. If prompted, trust the developer account in **Settings → General → VPN & Device Management**. Turn on [Developer Mode](https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device) and confirm it after the phone restarts.
3. Put the actual `.ipa` file in the iPhone's **Files** app. Download and extract it on the phone, save it to an accessible iCloud Drive folder, or accept an AirDrop transfer and save it to Files. A file downloaded on the Mac is not automatically copied to the iPhone.
4. Keep AltServer running. In AltStore on the iPhone, open **My Apps → + → Browse**, navigate to the IPA's location, and select it. Use the same Apple Account as AltStore. Complete any Apple verification locally in AltStore or AltServer.
5. Wait for Hadoo to appear in **My Apps** with its expiration countdown, then launch it from the Home Screen. This confirms that AltStore manages that installation.

If Hadoo is already installed, Finder's iPhone **Files → Hadoo** section can transfer the IPA over USB. That folder appears on the phone as **Files → Browse → On My iPhone → Hadoo**. Close and reopen the folder if its listing is stale. Recent files in AltStore's picker may not include a newly transferred file; navigate through Browse. See [missing IPA troubleshooting](troubleshooting.md#iphone-signing-and-refresh).

### Direct installation through AltServer

AltServer on the computer can also sign and install an IPA directly. On macOS, hold **Option** while clicking its menu-bar icon, then choose **Sideload .ipa → your iPhone**, select the IPA on the Mac, and sign in to Apple. On Windows, hold **Shift** when clicking AltServer's icon. [AltServer's direct-install instructions](https://faq.altstore.io/release-notes/altserver)

This route does **not** register Hadoo in AltStore's **My Apps**. A successful direct install is still signed and still expires. With a free Apple Account, repeat the direct installation every seven days, keeping the same signing account and installed copy. To move to AltStore-managed refreshes, import the IPA through **My Apps → +** on the phone; installing AltStore alone does not import existing apps.

### Refresh or update on iPhone

With a free Apple Account, the signature lasts seven days from a successful signing or refresh. For an **AltStore-managed** installation, check **My Apps** and tap **Refresh All** while the iPhone can reach AltServer. Use the same Wi-Fi network or a USB connection to the computer. Background refresh is best-effort; check the countdown rather than assuming it ran. A **direct AltServer** installation needs another direct installation instead. [AltStore Classic refresh guide](https://faq.altstore.io/altstore-classic/your-altstore)

If Hadoo expires, keep it installed and use the renewal method for its installation route. If AltStore also expires, reinstall **AltStore over its existing copy** with AltServer and the same Apple Account, then refresh its managed apps. An expired signature prevents launch. [AltServer recovery guide](https://faq.altstore.io/altstore-classic/altserver)

Refreshing renews the installed version; it does not download a newer Hadoo build. To update, download the newer IPA and import it using the same route and account. A GitHub release is not automatically an AltStore catalogue/source entry. Keep the existing copy and back up important app data before changing signing accounts or installers: personal signing can change the final bundle ID, and a different ID installs separately. For Xcode installation, see [Build from source](build.md#sign-with-xcode).

## Earlier Hadoo installs

The earlier patched APK has a separate identity and private app storage. Account sessions, downloads, and playlists from that app require separate handling. See the [legacy guide](legacy-morphe.md) before changing or removing that installation.
