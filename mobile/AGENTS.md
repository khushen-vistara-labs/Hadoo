# Konnekted2

Android music player: Flutter / Riverpod / Isar over Flick's Rust / Symphonia / Oboe / UAC2 engine. The public product is Konnekted; the internal `flick` Dart package and native namespace intentionally remain stable for generated FFI/JNI compatibility.

## Rules
- Preserve native PCM/DSD paths. Never describe DSP-processed or Android-mixed audio as bit-perfect.
- Do not replace USB transport with a mock. Hardware validation is separate from unit tests.
- New online services are opt-in. Never commit account tokens, signing keys, local SDK paths, or private logs.
- Preserve upstream licenses. This fusion is GPL-3.0; MIT-derived Flick code retains its original attribution in THIRD_PARTY_NOTICES.md.
- Keep the feature status document honest: source reuse is not proof of a device test or full Konnekted parity.

# Flutter deesign System Rules

You are performing a comprehensive UI/UX overhaul of this existing Flutter mobile application. The core logic, state management, and services must remain intact, but all presentation layers (Widgets, Screens, Themes) are being updated to an elite, dark-mode-first, motion-heavy aesthetic.

## 1. Redesign Strategy (Preserve Logic, Swap View)
- **Do Not Touch:** Business logic, BLoC/Riverpod/Provider files, API repositories, and data models unless explicitly instructed.
- **Isolate the UI:** Separate UI presentation from logic. If logic is tangled in old UI files, safely extract it into the new layout.
- **Theme Injection:** All design values must derive from a global dark theme class (`AppTheme`). Do not hardcode colors in individual components.

## 2. Global Aesthetics (The New Look)
- **Colors:** Deep obsidian backgrounds (`0xFF0D0D12`), frosted glass overlays, and neon accent highlights (e.g., electric violet, cyber cyan).
- **Surfaces:** Use `BackdropFilter` for card structures. Apply a subtle 1px border gradient to simulate light highlights on edges.
- **Transitions:** Every page transition and modal must be custom and fluid (using `PageRouteBuilder` with `Curves.easeInOutCubic`).

## 3. Workflow for Screen Refactoring
When asked to redesign a specific screen, follow this workflow:
1. **Analyze:** Read the existing screen file to identify state dependencies and current logic hooks.
2. **Draft Layout:** Create a visually premium layout mapping out the original functional requirements.
3. **Integrate Logic:** Re-bind the existing state triggers (e.g., `onPressed: () => context.read<Bloc>().add(...)`) exactly as they were in the original file.
4. **Deliver:** Present the refactored widget clean, modularized, and ready to swap.
5. 

## Checks
```
flutter pub get
flutter analyze
flutter test
# Host cargo tests need libclang.dll for vendored bindgen crates; Android
# validation is performed through Cargokit during the APK build.
cargo test --lib --manifest-path rust/Cargo.toml
flutter build apk --debug --flavor full --target-platform android-arm64
# Windows: actual applied-plugin guard and launcher exit-code regression
android\gradlew.bat -p android verifyBuiltInKotlin
powershell.exe -NoProfile -File tool/test_cargokit_launcher.ps1
```

See README.md and docs/BUILD.md for prerequisites and exact validated scope.
