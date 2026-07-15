# Standalone Android Build

This guide produces an Android build that runs on the phone without Metro and without a USB connection to your Mac after installation.

## What Changes Between Dev And Standalone

- `npm run android` installs a development build and connects it to Metro
- `npm run android:release` builds a release APK with the JavaScript bundle embedded in the app
- `npm run android:install-release` installs that release APK on a connected Android device

Once the release APK is installed, the app launches directly on the phone and does not require the Mac at runtime.

## Local Standalone Install

Build the release APK:

```bash
npm run android:release
```

Install it on a USB-connected device:

```bash
npm run android:install-release
```

APK output:

```text
android/app/build/outputs/apk/release/Hadoo.apk
```

After that first install, you can disconnect the cable and open the app normally on the phone.

## Proper Release Signing

The project supports a real Android upload keystore through Gradle properties. Add these values to `~/.gradle/gradle.properties` or your local Gradle environment:

```properties
HADOO_UPLOAD_STORE_FILE=/absolute/path/to/your-upload-key.keystore
HADOO_UPLOAD_STORE_PASSWORD=your-store-password
HADOO_UPLOAD_KEY_ALIAS=your-key-alias
HADOO_UPLOAD_KEY_PASSWORD=your-key-password
```

If those properties are not set, the release build falls back to the debug keystore so you can still test standalone installs on your own device. That fallback is not appropriate for store distribution.

## Store Bundle

To build an Android App Bundle for Play Store style distribution:

```bash
npm run android:bundle-release
```

AAB output:

```text
android/app/build/outputs/bundle/release/app-release.aab
```

## Notes

- This app already fetches remote content directly from internet endpoints and does not appear to depend on a local API server.
- Expo updates are disabled in the Android manifest, so the release build runs the embedded bundle from the APK itself.
