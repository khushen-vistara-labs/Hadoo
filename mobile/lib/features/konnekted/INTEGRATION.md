# T2 — Konnekted shell handoff

## Entry point

```dart
import 'package:flick/features/konnekted/konnekted_shell.dart';

// In the EXISTING _RootRouter, keep the onboarding branch:
final child = onboardingComplete
    ? const KonnektedShell()
    : const OnboardingScreen();
```

T2 changes only `lib/features/konnekted/**` and `test/konnekted/**`.
`app/app.dart`, Android, dependencies, and bootstrap are owned by main.
No swarm-board tool was available; this is the T2 status record.

## Keep in root/main

- Keep native/database/player initialization, restoration, and the existing
  `ProviderScope` from the imported app's bootstrap.
- Keep `_RootRouter`'s `onboardingCompletedProvider` branch. Do not bypass it by
  replacing `MaterialApp.home` directly with this shell.
- Keep the preference-driven `AppConstants.setAnimationsEnabled`,
  `AppHaptics.setEnabled`, and `MediaQuery.disableAnimations` propagation. System
  reduced motion must continue to override the in-app animation preference.
- Keep `rootNavigatorKey`, localization delegates, supported locales,
  `LocaleController.instance.bind`, the existing theme/font fallbacks, system-bar
  configuration, and `ConnectionNoticeHost`.
- Mount only one shell. `KonnektedShell` owns the existing global
  `nestedNavigatorKey`, which the inherited full player uses to open album/artist
  detail routes after closing itself.

## Already preserved inside this shell

`KonnektedRuntime` is mounted once inside the shell's Scaffold and preserves:

- Equalizer initialization and update-check initialization/online refresh.
- `installWidgetSync`, `WidgetIntentHandler.attach/detach`, and queue intents.
- Playback persistence, widget background/killed sync, player pause/resume,
  background-library-sync notifications, and app-log flushing.
- Paused-track Last.fm/ListenBrainz scrobbling and resume queue flushing through
  the existing providers. No new online service or credential flow is added.
- Library deletion refresh, metadata warmup notification/action, and
  `FloatingScanProgress`.
- External playback handoff into the inherited full player.
- Playback-desync recovery action.
- Listening activity recording, milestone/streak dialogs, the existing What's
  New preference listener, and the existing tutorial overlay/auto-start.
- The real `UsbBitPerfectPrompt`, including its inherited per-device decline,
  auto-engage, and Undo behavior. Do not mount a second copy in root.

The obsolete full-screen PageView, auto-collapsing legacy bar, and eager tab
mounting are replaced by lazy tab creation, a nested navigator, and a glass dock
whose actual height is reserved in layout. PageStorage retains home/library
scroll positions. Back first pops a nested route, then returns to Listen, then
uses the existing double-back-to-exit convention.

## Data and destinations

- Listen: live repository-backed recent history (deduplicated and bounded),
  `favoritesProvider`, and unfiltered `songsProvider` library data sorted by
  added date. Tapping a song passes the real shelf as the playback queue.
- Flow hero → `package:flick/features/flow/flow_screen.dart`, `const FlowScreen()`.
- Explore → `package:flick/features/search/screens/search_screen.dart`,
  `const SearchScreen()`; mounted only after selecting Explore. Its online
  section uses the canonical Online sources settings, including HTTP music
  add-ons.
- Library → inherited songs, albums, artists, folders, playlists, favorites,
  recently played, recently added, scanning/library settings, and the inherited
  listening hub (smart mixes and recaps remain accessible).
- Mini player → inherited full player via `NavigationHelper`; lyrics remain in
  that player's lyric controls. Play/pause, next (when there is room), progress,
  and queue use real playback providers. A missing current song hides the bar.
- Settings → real audio/DSP, EQ, USB output/diagnostics, queue, lyric settings,
  library settings, and all inherited settings.
- Flick's old numeric navigation requests are translated to the corresponding
  destination; they are not interpreted as Konnekted's four tab indices.

## Verification performed

Using the Windows Flutter SDK via `cmd.exe /c`:

```text
dart format lib/features/konnekted test/konnekted
flutter analyze --no-pub lib/features/konnekted test/konnekted
flutter test --no-pub test/konnekted
```

- Scoped analysis: **no issues** (both companion screen exports resolved).
- Focused tests: **8 passed**. Covers empty-library import/Flow navigation,
  320px/200% text layouts, error/retry, shelf queue payloads, absent-player lazy
  behavior, dock semantics/actions, history initial/live reads and cancellation,
  and recent-added sorting without mutating source data.
- Tests use overridden provider/repository boundaries and pure components; they
  do not bootstrap native audio or Isar.

## Remaining integration/device checks

- Main should run full-repository checks and the APK build after integration.
  This task did not perform a physical-device, native-audio, widget-intent, USB,
  or end-to-end navigation smoke test.
- Legacy settings still expose Flick bottom-bar layout/customization options.
  Those apply to the old bar, not this fixed four-destination dock. A future
  settings migration should hide/relabel them or add an explicit Konnekted dock
  configuration. Core player/audio/library settings remain routed unchanged.
- The inherited tutorial is functional with registered dock/mini-player anchors
  and translated song/settings navigation. Its localized prose still describes
  Flick's old tab names and long-press bar customization; main's branding/copy
  migration should update that prose. New shell copy is currently English.
- Hardware bit-perfect behavior is inherited, not proven by these UI tests.
