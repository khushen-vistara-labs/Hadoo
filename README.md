# Hadoo

Personal music app for searching, organizing, and playing tracks across modular source providers, built with Expo development builds, React Native, TypeScript, Expo Router, Zustand, TanStack Query, and AsyncStorage persistence.

## Run

Install dependencies:

```bash
npm install
```

Start Metro for a development build:

```bash
npm run start
```

Run Android:

```bash
npm run android
```

Run iOS on macOS with Xcode:

```bash
npm run ios
```

### Running On A Real Android Device

This app does not run in Expo Go. It uses Expo development builds and native modules.

For the shortest path on an Android phone with USB debugging enabled:

```bash
npm install
npm run android
```

If your phone is already connected by USB and developer options are enabled, that command will build the native app, install it on the device, and connect it to Metro.

Detailed device setup and troubleshooting lives in [docs/running-on-android-device.md](/Users/icemonkey/code/Hadoo/docs/running-on-android-device.md).

### Building A Standalone Android App

If you want the phone app to run without your Mac, build and install the release APK instead of the Expo dev client:

```bash
npm run android:release
npm run android:install-release
```

That produces a bundled Android app that does not connect to Metro at runtime.

Release signing and APK / AAB details live in [docs/standalone-android-build.md](/Users/icemonkey/code/Hadoo/docs/standalone-android-build.md).

## Contributing

Contributor requirements for commit messages, PR titles, PR template sections, required checks, and code owners are documented in [CONTRIBUTING.md](/Users/icemonkey/code/Hadoo/CONTRIBUTING.md).

## Notes

- This project targets Expo development builds, not Expo Go.
- Android release builds bundle the JavaScript so the installed release APK can run without Metro.
- `react-native-track-player` is wired through `index.js` and `src/modules/player/playbackService.ts`.
- Experimental providers are isolated under `src/modules/sources/` and can return clean failures without crashing the UI.
- State persistence uses AsyncStorage through Zustand middleware.

## Structure

- `app/`: expo-router screens and navigation
- `src/components/`: reusable UI and player components
- `src/modules/player/`: playback setup, background service, player store, player service
- `src/modules/sources/`: provider adapters and source registry
- `src/modules/library/`, `playlists/`, `settings/`: persisted feature stores
- `src/data/`: mock tracks, playlists, query client
- `src/types/`: shared domain types
