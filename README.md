# Hadoo

Private personal-use music app scaffold built with Expo development builds, React Native, TypeScript, Expo Router, Zustand, TanStack Query, AsyncStorage persistence, and a modular source-provider architecture.

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

## Notes

- This project targets Expo development builds, not Expo Go.
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
