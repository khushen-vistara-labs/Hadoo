# Hadoo platform status

The current development preview is **2015** (`2.0.0-dev.16`). [Install it](device-setup.md), [build it from source](build.md), or check the [changelog](../CHANGELOG.md).

| Area | Current behavior | Device evidence |
| --- | --- | --- |
| Android | ARM64 app for API 26 and later. The preview updates the Hadoo test package. | Build 2015 installed in place over build 2008 on a CPH2717. Anonymous search and audio, account recommendations, and playlist reads were verified on earlier previews. |
| iPhone | Minimum target is iOS 16. Direct AAC audio initializes a YouTube guest session before requesting a stream. AltStore Classic can sign the preview. | Build 2015 installed on iPhone 14 running iOS 26.5. YouTube playback was confirmed on the phone. Ishaare and Dhoond were fetched and decoded in full using Hadoo's resolver in a Mac test. |
| Downloads | Supported streams can be saved and opened from Downloads. | Cold airplane-mode launch, Android playback, and seeking were verified on an earlier preview. Repeat download and background queue qualification for iPhone before a release. |
| Playlists | **Hadoo playlists** can mix sources and are stored on-device. **YouTube playlists** sync to the connected account and accept YouTube recording IDs. | Automated tests cover playback and playlist operations. Older Android testing confirmed real YouTube playlist reads, creation, rename, and deletion. Test live cross-source and YouTube track edits for release sign-off. |
| Android Auto | Uses Android's media service with Offline, Library, Liked Songs, and Playlists. Voice search covers saved tracks. | Shared catalogue tests. Physical head-unit qualification is pending. |
| CarPlay | Native audio scene with library browse and Now Playing. Requires an Apple-approved audio entitlement for the signing identity. | Native code builds. Approved signed head-unit qualification is pending. |
| Other platforms | This branch ships the Flutter mobile project. | Platform support currently covers Android and iPhone. |

## Source and architecture

Hadoo uses Flutter for the UI, Rust for native audio, and platform bridges for media sessions and car controls. Both car interfaces use the phone's playback queue. The public app identity is `com.icemonkey.hadoo`. Keep the internal Dart package, native namespaces, and bridge ABI stable when building from source.

The [source lock](../config/mobile-upstream-lock.json) records the imported baseline. [License notices](../NOTICE) and [bundled notices](../mobile/THIRD_PARTY_NOTICES.md) cover the code and assets. Engineering notes under `mobile/docs/` supply historical context. The status table above records Hadoo device checks.

The previous APK patch workflow remains in [the legacy guide](legacy-morphe.md).
