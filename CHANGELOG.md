# Changelog

## Documentation and CI · 2026-11-23

- Document Android APK installation, package/signing identity, compatible standalone head units, Android Auto, and release versus test-artifact downloads.
- Distinguish AltStore-managed IPA imports from direct AltServer installs, seven-day personal signing, file transfer, refresh, and version updates. Record the verified iPhone build 2016 installation without claiming AltStore registration.
- Explain playlist sync availability, download retry/skipped counters, offline lyrics, and remaining car qualification. Record local Android build-2020 coverage separately from the committed source version.
- Maintain separate Linux and macOS header screenshot references and retain failed CI comparison images. App version/build numbers are unchanged by these documentation and test changes.

## 2.0.0-dev.17 (build 2016) · 2026-11-16

- Android keeps the phone’s volume buttons available for USB headphones on standard playback. Automatic exclusive USB is now opt-in.
- **Queue** in the full player opens a dedicated page with room to browse and reorder upcoming songs.
- The full-player **Lyrics** toolbar gives the title its own line on phones and wraps actions on narrow displays.

## 2.0.0-dev.16 (build 2015) · 2026-11-16

- iPhone now initializes a YouTube guest session before fetching direct audio. Verified complete AAC downloads and decoding for Ishaare and Dhoond on the Mac, and playback on iPhone 14.
- Hadoo playlists live on the device and can hold tracks from different sources. The playlist picker labels them separately from YouTube playlists.
- YouTube Music account recommendations and playlist syncing are available. Search has Songs, Videos, and Playlists filters, and the playlist picker checks for existing YouTube recordings before adding them.
- Android ARM64 preview and the matching iPhone device build compile. Android build 2015 was installed over the earlier preview.

See [platform status](docs/mobile-rewrite.md) for remaining device checks and [installation](docs/device-setup.md) for signing and updates.

## Earlier Hadoo Android builds

Earlier releases use the [legacy Android APK patch workflow](docs/legacy-morphe.md).
