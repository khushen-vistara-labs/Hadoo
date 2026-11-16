# Maintenance and release preparation

`trunk` is the active Hadoo source branch. Use [Contributing](../CONTRIBUTING.md) for changes and [Build from source](build.md) for a clean setup. The current development preview is **2016**.

## Versioning

Update the version in `mobile/pubspec.yaml` and the entry in [CHANGELOG.md](../CHANGELOG.md) for each published build. The integer after `+` becomes the Android version code and iPhone build number. Increase it for updates. The iPhone build uses the numeric marketing version (such as `2.0.0`) for its platform metadata.

## Android release signing

Use a keystore you control. Configure `ANDROID_KEYSTORE_PATH`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, and `ANDROID_KEY_PASSWORD` in your terminal or secret manager. Alternatively, create the ignored file `mobile/android/key.properties` with `storeFile`, `storePassword`, `keyAlias`, and `keyPassword`. Use an absolute keystore path. Keep a recoverable private backup of the key.

```sh
./hadoo build android --release
apksigner verify --verbose mobile/build/app/outputs/flutter-apk/app-full-release.apk
```

Use `apksigner` from the installed Android Build Tools. The release application ID is `com.icemonkey.hadoo`. A different signing key, application ID, or older version code can prevent an in-place update.

## iPhone packaging

Use the [iPhone build guide](build.md#iphone) for an unsigned device build and IPA. Install a personally signed copy for device qualification. Keep the signed package for any distinct distribution channel separate. App Store and TestFlight distribution require the Apple Developer Program and applicable review and signing steps.

## Release checklist

1. Run `./hadoo check` and build from a clean checkout on the release toolchains. Record the source commit and build number.
2. Verify install and in-place update on Android and iPhone. Check basic playback, queue changes, screen-off audio, signed-in recommendations, each playlist type, airplane-mode download playback, and a sign-out/sign-in cycle.
3. Test car claims on the corresponding head unit. Include cold launch, browse, track selection, steering-wheel controls, and reconnect. Record which tests ran and which devices were used.
4. Validate archive integrity and the installed package version. Keep licenses and notices in the app and deliver the corresponding source and lockfiles with the artifact. Review the terms for any separately licensed SDK before public distribution.
5. If publishing binaries, attach them deliberately to a GitHub Release with per-platform install steps, SHA-256 checksums, and known limitations. Mark previews as pre-releases. Never commit APKs, IPAs, tools, signing keys, account sessions, service logs, or music to the repository.

Use [platform status](mobile-rewrite.md) to publish what has actually been checked. For the earlier APK patch workflow, use the [legacy guide](legacy-morphe.md).
