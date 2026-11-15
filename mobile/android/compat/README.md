# Built-in Kotlin build overlays

`rive_native.gradle` replaces only the Android build script of the locked
`rive_native` **0.1.11** package. Its published build script unconditionally
applies `kotlin-android`; even the inspected `0.2.0-dev.3` prerelease does so.
The app retains its stable Rive dependency rather than switching to a prerelease.

The settings-level override keeps the original package `projectDir`, so Kotlin
sources, manifests, assets, JNI libraries, and the `rive_native:setup` command
remain the published implementation. It does not edit shared Pub-cache files,
disable compilation, or suppress warnings. Java/Kotlin target 11, minSdk 21,
compileSdk 35, and native setup dependency hooks are preserved. The app's NDK
version is used explicitly.

Upstream: [rive_native 0.1.11](https://pub.dev/packages/rive_native/versions/0.1.11),
`android/build.gradle`; MIT-licensed by Rive Inc. This small app-specific script
uses the same setup contract; no native Rive source is vendored.

The version guard in `android/settings.gradle.kts` intentionally rejects a new
Rive version until its build script is checked. Remove the guard and overlay
once an upstream stable release supports built-in Kotlin, then run:

```text
android\gradlew.bat -p android verifyBuiltInKotlin
flutter build apk --debug --flavor full --target-platform android-arm64 --no-pub
```

The verification task checks actual applied plugins across all Android modules;
it is not a text search for warning strings.

## Home widget

`home_widget.gradle` adapts the locked **home_widget 0.10.0** build script to
built-in Kotlin only. Upstream already guards the legacy plugin application,
but Flutter 3.47's `getSubprojectPluginState` scans Groovy declarations by regex
without evaluating the guard. The overlay removes the declaration entirely and
explicitly preserves JVM target 1.8, minSdk 23, compileSdk 35, source paths,
Glance, WorkManager, core and coroutine dependencies. AGP supplies the aligned
Kotlin standard library instead of the old explicit 1.9.0 runtime pin.

The same version guard and no-cache-edit policy apply. Remove the overlay after
a published build script no longer needs this migration bridge. Upstream source:
[home_widget 0.10.0](https://pub.dev/packages/home_widget/versions/0.10.0),
`android/build.gradle`.
