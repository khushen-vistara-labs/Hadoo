# Hadoo mobile

The Flutter and Rust app for Android and iPhone. The [main README](../README.md) covers setup for listeners. Use the [build guide](../docs/build.md) for tools, builds, tests, and signing, and the [platform status](../docs/mobile-rewrite.md) for device evidence.

## Source layout

- `lib/features/hadoo/` contains Hadoo's streaming-first UI and playlist actions.
- `lib/features/discovery/` contains source lookup, account adapters, audio resolution, and the playback cache.
- `lib/services/player_service.dart` coordinates the queue and players.
- `rust/` holds the native audio engine. Keep `flick`, `rust_lib_flick_player`, and `com.mossapps.flick` stable for generated bindings and native channels.
- `android/` and `ios/` contain phone and car integrations. For CarPlay, see `ios/Runner/HadooCarPlay.swift` and the [build instructions](../docs/build.md#carplay).
- `test/` contains Dart and Flutter tests. Run `../hadoo check` for the focused CI suite.

Regenerate app icons from the original Hadoo mark with `dart run tool/gen_hadoo_branding.dart` from this directory.

The [source lock](../config/mobile-upstream-lock.json) records the imported version. The [engineering records](docs/README.md) preserve upstream context. Use the [Hadoo docs index](../docs/README.md) for current setup instructions, and preserve [third-party notices](THIRD_PARTY_NOTICES.md) when distributing.
