# Build Hadoo from source

The app lives in `mobile/`. Run the commands in this guide from the repository root unless a step says otherwise.

```sh
git clone --branch trunk https://github.com/khushen-vistara-labs/Hadoo.git
cd Hadoo
```

## Prerequisites

- Git, Python 3, and [Flutter 3.47.1](https://docs.flutter.dev/install/archive) or a compatible newer version with Dart 3.13+.
- [Rust 1.98+](https://rustup.rs/) with Cargo on your PATH. Flutter invokes Rust for the audio library.
- Android builds use Android SDK API 37, Build Tools 36.0.0, NDK 28.2.13676358, and JDK 17 or 21. The project includes its Gradle wrapper.
- iPhone builds use macOS, full Xcode with the iOS platform installed, and [CocoaPods](https://cocoapods.org/). Rust's iPhone target is `aarch64-apple-ios`.

The doctor command checks your toolchain. The setup command resolves the locked Flutter dependencies.

```sh
./hadoo doctor
./hadoo setup
```

On Windows PowerShell, substitute `py -3 tools/mobile.py` for `./hadoo` in the Android commands. Set `FLUTTER_BIN` if Flutter is installed outside PATH. Keep machine-specific configuration out of Git.

## Android

In Android Studio, open **SDK Manager** and install Command-line Tools. Point `ANDROID_HOME` at the SDK location shown there. Add the SDK's `platform-tools` and `cmdline-tools/latest/bin` directories to PATH. Install the platform, build tools, NDK, and Platform Tools through SDK Manager or with these commands. [Android Studio](https://developer.android.com/studio)

```sh
sdkmanager --licenses
sdkmanager 'platform-tools' 'platforms;android-37.0' 'build-tools;36.0.0' 'ndk;28.2.13676358'
rustup target add aarch64-linux-android
```

Use the API 37 package name shown by `sdkmanager --list` if your SDK uses `platforms;android-37`. If the SDK installed a real `android-37.0` directory and Gradle specifically asks for `android-37`, create an alias in the SDK. This command does that on macOS and Linux.

```sh
if [ -d "$ANDROID_HOME/platforms/android-37.0" ] && [ ! -e "$ANDROID_HOME/platforms/android-37" ]; then
  ln -s android-37.0 "$ANDROID_HOME/platforms/android-37"
fi
```

On Windows, run `New-Item -ItemType Junction -Path "$env:ANDROID_HOME/platforms/android-37" -Target "$env:ANDROID_HOME/platforms/android-37.0"` in PowerShell if the real `android-37.0` directory exists and the alias is missing. The alias must reference API 37.

```sh
./hadoo build android
adb install -r mobile/build/app/outputs/flutter-apk/app-full-debug.apk
```

The default build is a debug-signed ARM64 APK for Android 8.0 and later. It uses the preview application ID `com.icemonkey.hadoo.test`. Keep the same signing key for in-place updates. See [installation issues](troubleshooting.md#android-installation) and [release signing](maintenance.md#android-release-signing).

## iPhone

1. Open Xcode and install its iOS platform. Verify the active toolchain with `xcodebuild -version`. If the terminal points to Command Line Tools only, choose the full Xcode installation with `xcode-select`.
2. Check that `pod --version` works. Install the iPhone Rust target, then build the app.

```sh
rustup target add aarch64-apple-ios
./hadoo setup
./hadoo build ios
```

This stages pinned FFmpeg and SMB dependencies, then produces the unsigned device bundle at `mobile/build/ios/iphoneos/Runner.app`. Keep the computer online while it downloads dependencies and compiles. The version comes from `mobile/pubspec.yaml`.

### Package an IPA for AltStore

Run this after a successful build, from the repository root. The archive preserves the app bundle and its included license files.

```sh
stage="$(mktemp -d)"
ipa="$PWD/Hadoo-unsigned.ipa"
mkdir -p "$stage/Payload"
ditto mobile/build/ios/iphoneos/Runner.app "$stage/Payload/Hadoo.app"
rm -f "$ipa"
(cd "$stage" && zip -qry "$ipa" Payload)
unzip -tq "$ipa"
rm -rf "$stage"
```

Follow the [AltStore installation steps](device-setup.md#iphone) to sign the IPA and install it.

### Sign with Xcode

After running the build above, open `mobile/ios/Runner.xcworkspace` in Xcode. Connect the phone and enable Developer Mode. In the **Runner** target's **Signing & Capabilities**, enable automatic signing and select your own team. If Apple declines the bundle identifier, choose a unique one and keep it for future updates. Select your iPhone and click **Run**. [Apple's device signing instructions](https://developer.apple.com/documentation/xcode/building-and-running-an-app)

### CarPlay

`./hadoo build ios --carplay` selects the restricted audio-entitlement configuration. Your Apple developer team needs CarPlay audio approval and a provisioning profile for the app ID that contains that entitlement. Configure signing for the entitlement before installing on a phone. Use the normal iPhone build for AltStore personal signing. [Apple's entitlement requirements](https://developer.apple.com/documentation/carplay/requesting-carplay-entitlements)

## Checks

```sh
./hadoo check
```

This runs Dart analysis and the Hadoo, car catalog, discovery, playback, and update checks in CI. For a more targeted test, run `flutter test --no-pub <test-path>` inside `mobile/`. Run `flutter test --no-pub` there for the full Flutter suite. Native and device checks are listed in [Maintenance](maintenance.md#release-checklist).
