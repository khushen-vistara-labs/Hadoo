# Install or update Hadoo

Hadoo's current source preview is build **2016**. The Android preview targets ARM64 phones on Android 8.0 (API 26) or later. The iPhone project targets iOS 16 or later. See [platform status](mobile-rewrite.md) for the devices tested.

Get matching artifacts from [GitHub Releases](https://github.com/khushen-vistara-labs/Hadoo/releases) when available, or follow [Build from source](build.md). A GitHub source ZIP contains code. Choose an APK for Android or an IPA for signing on iPhone.

## Android

1. Transfer the APK to your phone and open it from Files or Downloads. If Android asks, enable **Allow from this source** for the app opening the file. You can turn the permission off after installation.
2. Install the APK, open **Hadoo**, and tap **Start listening**. Search for a song to confirm that the installation can reach YouTube Music.

For USB installation, enable USB debugging, connect and unlock the phone, and accept the computer's authorization prompt. Add Android Platform Tools to your PATH, then use these commands from the repository root. [Android Platform Tools](https://developer.android.com/tools/releases/platform-tools)

```sh
adb devices
adb install -r mobile/build/app/outputs/flutter-apk/app-full-debug.apk
```

Use a build with the **same package ID and signing key** to keep data in an existing install. Local debug APKs use `com.icemonkey.hadoo.test` and the debug key on the computer that built them. Release builds use `com.icemonkey.hadoo` and the maintainer's release key. If you have an existing preview, use the same build computer and key for subsequent debug updates. See [Android install errors](troubleshooting.md#android-installation) before removing any existing copy.

## iPhone

Build 2015 was installed through AltStore Classic, which signs the IPA with your Apple Account for personal use. To build your own IPA, use the [iPhone build and packaging steps](build.md#iphone).

1. Install AltServer on your computer. Plug in your unlocked iPhone, tap **Trust** when prompted, and use **AltServer → Install AltStore** to select the iPhone. [macOS instructions](https://faq.altstore.io/altstore-classic/how-to-install-altstore-macos) · [Windows instructions](https://faq.altstore.io/altstore-classic/how-to-install-altstore-windows)
2. If prompted, trust the developer account in **Settings → General → VPN & Device Management**. Turn on [Developer Mode](https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device) and confirm it after the phone restarts.
3. Save the Hadoo IPA to Files. In AltStore, open **My Apps → +**, select the IPA, and wait for Hadoo to appear in My Apps. Use the same Apple Account for AltStore and the Hadoo install.
4. Launch Hadoo from the Home Screen. You can unplug the phone once the app is installed.

### Refresh or update on iPhone

With a free Apple Account, the signature lasts seven days from a successful signing or refresh. In **AltStore → My Apps**, check the countdown and tap **Refresh All** while your iPhone can reach AltServer. For the standard setup, use the same Wi-Fi network or a USB connection to the computer. AltStore can also attempt refreshes in the background. Sign in again if prompted, then verify that the countdown reset. [AltStore Classic refresh guide](https://faq.altstore.io/altstore-classic/your-altstore)

If Hadoo expires, keep it installed and refresh it in AltStore. If AltStore also expires, reinstall **AltStore over its existing copy** with AltServer and the same Apple Account, then open it and refresh Hadoo. An expired signature prevents launch. Keeping the existing app and signing identity gives the in-place update access to its saved data. [AltServer recovery guide](https://faq.altstore.io/altstore-classic/altserver)

To update Hadoo itself, open the newer IPA using **My Apps → +** with the same signing account and base bundle ID. To run a build you built from source directly through Xcode, see [Build from source](build.md#sign-with-xcode).

## Earlier Hadoo installs

The earlier patched APK has a separate identity and private app storage. Account sessions, downloads, and playlists from that app require separate handling. See the [legacy guide](legacy-morphe.md) before changing or removing that installation.
