# Maintenance and release preparation

`trunk` is the active Hadoo source branch. Use [Contributing](../CONTRIBUTING.md) for changes and [Build from source](build.md) for a clean setup. The current development preview is **2016**.

## Versioning

Update the version in `mobile/pubspec.yaml` and the entry in [CHANGELOG.md](../CHANGELOG.md) for each published build. The integer after `+` becomes the Android version code and iPhone build number. Increase it for updates. The iPhone build uses the numeric marketing version (such as `2.0.0`) for its platform metadata.

## Automatic GitHub releases

GitHub's **Release APK and IPA** workflow builds both platforms when you publish a release, including a pre-release. It checks out the release tag's exact commit. Update `mobile/pubspec.yaml` and the changelog before creating that tag so each update has a higher build number.

1. Commit the version and source changes to `trunk`.
2. Open **GitHub → Releases → Draft a new release**, create a tag from that commit, and publish it.
3. Follow **Actions → Release APK and IPA**. Once both builds finish, the workflow attaches the Android APK, unsigned iPhone IPA, matching source archive, installation notes, and SHA-256 checksums to that release.

Use **Actions → Release APK and IPA → Run workflow** with an existing release tag to retry its builds. Leaving the tag blank tests `trunk` and keeps packages in the Actions run's downloadable artifacts. Each retry builds the same version and commit. GitHub retains those test artifacts for 14 days.

The Android artifact is `Hadoo-<version>-arm64.apk`, signed with the persistent release key. Its package ID is `com.icemonkey.hadoo`. It installs separately from the `com.icemonkey.hadoo.test` previews previously installed from this computer. The `full-metadata.json` asset supports Hadoo's Android update checker for published stable releases.

The iPhone artifact is `Hadoo-unsigned.ipa` for iOS 16 and later. Transfer it to the phone and import it in **AltStore → My Apps → +** to get an AltStore-managed installation. Direct **AltServer → Sideload .ipa** installations are not added to My Apps and require manual renewal. Both routes sign with the user's Apple Account; neither makes the unsigned IPA permanently installable. See [iPhone installation and refresh](device-setup.md#iphone). App Store and TestFlight distribution use Apple's separate signing and submission process.

The workflow packages the source committed in the tag. Files changed only in a local working tree and APKs installed manually with an overridden build number are not automatically included. Compare the tag, `mobile/pubspec.yaml`, package metadata, and device build number when reporting a release.

The iPhone output is a standalone IPA, not an AltStore source feed. Refreshing an installed copy renews its signature; users download and import a new IPA to update its Hadoo version. The Android `full-metadata.json` is for the Android updater.

## Android release signing

The Android job reads four repository secrets from **Settings → Secrets and variables → Actions**. Keep `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, and `ANDROID_KEY_PASSWORD` together when backing up or migrating signing. Their values stay out of the repository and downloaded packages. The job removes its temporary keystore after the build. Replacing this key changes which existing installations can accept updates.

The maintainer computer's generated key backup is in the ignored `.hadoo-local/signing/` directory: `hadoo-release.p12` and `hadoo-release-credentials.json`. Keep a private backup of both files outside disposable build caches. Never publish them or add them to Git.

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
5. Publish the intended tag as a GitHub Release, marking previews as pre-releases. Verify both jobs passed and the workflow attached the APK, IPA, source, installation notes, and checksums. Never commit APKs, IPAs, tools, signing keys, account sessions, service logs, or music to the repository.

## CI and device evidence

**Hadoo checks** analyzes the app and runs focused Dart/Flutter regressions. The header screenshot has separate macOS and Linux references because those hosts rasterize the bundled fonts differently. CI pins Ubuntu 24.04 and Flutter 3.47.1 and keeps failed comparison images for seven days. Review the image before updating a reference; keep normal CI comparisons strict. See [validation instructions](../CONTRIBUTING.md#validate-changes).

**Release APK and IPA** compiles, signs the Android package, inspects the native bundles, and uploads packages. A successful native build does not prove the widget suite, iPhone refresh, offline playback, or car hardware behavior. Record those checks separately in [platform status](mobile-rewrite.md).

Use [platform status](mobile-rewrite.md) to publish what has actually been checked. For the earlier APK patch workflow, use the [legacy guide](legacy-morphe.md).
