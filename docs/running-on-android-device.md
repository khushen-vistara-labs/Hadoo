# Running On A Real Android Device

This project runs as an Expo development build. It does not run inside Expo Go because it depends on native modules such as `react-native-track-player`.

This guide covers the development-build workflow. If you want an install that runs on the phone without Metro or a USB cable, use the standalone release flow in [standalone-android-build.md](/Users/icemonkey/code/Hadoo/docs/standalone-android-build.md).

## Prerequisites

- A Mac with Android SDK / platform tools installed
- A USB cable connected to your Android phone
- Developer options enabled on the phone
- USB debugging enabled on the phone

## First Run

From the project root:

```bash
npm install
npm run android
```

That command uses `expo run:android` and will:

- build the Android app
- install it on the connected device
- start the Metro bundler for the dev client

## Verify Device Detection

If the build does not see the phone, check ADB:

```bash
adb devices
```

Expected result:

- your device serial appears in the list
- the device state is `device`

If the phone shows an RSA authorization prompt, approve it and run `adb devices` again.

## If ADB Shows Nothing

Restart the ADB server:

```bash
adb kill-server
adb start-server
adb devices
```

Also verify these on the phone:

- the USB mode is not charge-only
- USB debugging is still enabled
- the RSA trust prompt was accepted

## After The First Install

Once the app is installed on the phone, you can usually just start Metro with:

```bash
npm run start
```

Then open the installed app on the device.

If you want to avoid the USB cable during development, you can keep using the installed dev client and start Metro on the same Wi-Fi network. The app still depends on Metro in that mode, so it is not fully standalone.

## iOS

For iOS simulator or device builds on macOS:

```bash
npm run ios
```

## Project Scripts

- `npm run start`: starts Expo in dev-client mode
- `npm run android`: builds and runs the Android native app
- `npm run android:release`: builds a standalone release APK
- `npm run android:install-release`: installs the standalone release APK on a connected device
- `npm run android:bundle-release`: builds a release AAB for store distribution
- `npm run ios`: builds and runs the iOS native app
