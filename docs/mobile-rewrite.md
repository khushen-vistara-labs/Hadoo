# Hadoo platform status

The committed app version is **2016** (`2.0.0-dev.17`). GitHub's native build test produced both packages from commit `957929e9` on 2026-11-22. Later local Android previews use build numbers through **2020**; those numbers do not advance the committed app version. [Install or update](device-setup.md), [build from source](build.md), or check the [changelog](../CHANGELOG.md).

| Area | Current behavior | Device evidence |
| --- | --- | --- |
| Android | ARM64 app for API 26 and later. Debug preview and signed release have separate package IDs. | Local build 2020 installed and its version verified on OnePlus CPH2717 and Samsung Galaxy M51. GitHub built and verified the signed release APK for source build 2016. |
| iPhone | Minimum target is iOS 16. Direct AAC audio initializes a YouTube guest session. AltStore-managed and direct AltServer installs have different renewal routes. | GitHub built and inspected the unsigned IPA. Build 2016 was signed through AltServer and its installed version verified over USB on iPhone 14 / iOS 26.5 on 2026-11-23. Registration in AltStore My Apps and managed refresh have not been confirmed for that install. Earlier build 2015 had phone playback confirmed. |
| Downloads and offline lyrics | Supported streams can be saved and opened locally. Available lyrics can be embedded or saved beside the audio; missing lyrics do not fail an audio download. | Earlier Android airplane-mode playback and seeking passed. A later Android retry retained 130 existing downloads and reported them as skipped. Repeat iPhone offline and background-download qualification before a release. |
| Playlists | Hadoo playlists mix sources and are stored on-device. YouTube playlists synchronize through the selected YouTube account and accept YouTube recording IDs. | Automated playlist tests and earlier Android YouTube playlist reads, creation, rename, and deletion. Live cross-source edits still need release qualification. |
| Cross-phone Hadoo playlist sync | Not configured in the current distributed builds. A saved username does not create a cloud account. Local Google Drive integration work is unfinished. | No successful cross-phone Drive sync is claimed. YouTube playlist account sync is separate. |
| Android Auto | Offline, Library, Liked Songs, Playlists, and Now Playing. Voice search covers saved tracks. The phone lyrics screen is not an Android Auto view. | Shared catalogue tests. Physical head-unit qualification is pending. |
| Standalone Android head units | APK installation is possible on units supporting ordinary Android apps with Android 8.0+ and a 64-bit ARM system. | Installation and layout on the user's car unit have not been qualified. Android Auto-only receivers use the phone app. |
| CarPlay | Native audio scene with browse and Now Playing. Requires an Apple-approved audio entitlement and provisioning. The ordinary personal-signing IPA is not a qualified CarPlay build. | Native code builds; approved signing and head-unit qualification are pending. |
| Other platforms | This branch ships the Flutter mobile project. | Platform support covers Android and iPhone. |

## Build and test records

The [successful native build run](https://github.com/khushen-vistara-labs/Hadoo/actions/runs/44995172907) contains the build-2016 APK and IPA artifacts. This was a manual workflow test, so it did not publish a GitHub Release. Binary inspection and installed-version checks do not establish every playback, refresh, or car scenario.

Local Android previews after 2016 include playlist-dialog and creation fixes, launcher/splash asset changes, inherited-name cleanup, and playlist playback-resolution fixes. Those working-tree changes must be committed and validated before a release tag includes them. Use this distinction when comparing a phone with packages built from GitHub.

## Source and architecture

Hadoo uses Flutter for UI, Rust for native audio, and platform bridges for media sessions and car controls. Both car integrations use the phone's playback queue. Android release uses `com.icemonkey.hadoo`; debug previews use `com.icemonkey.hadoo.test`. The base iPhone bundle ID is `com.icemonkey.hadoo`, and personal signing can change its final identifier. Keep generated FFI/JNI bindings, migration keys, and native bridge ABI stable when renaming code.

The [source lock](../config/mobile-upstream-lock.json) records the imported baseline. [License notices](../NOTICE) and [bundled notices](../mobile/THIRD_PARTY_NOTICES.md) cover the code and assets. Engineering notes under `mobile/docs/` preserve upstream implementation history; this page records current Hadoo device evidence.

The previous APK patch workflow remains in [the legacy guide](legacy-morphe.md).
