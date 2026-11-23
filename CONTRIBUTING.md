# Contributing to Hadoo

Use `trunk` as the base and start with the [build guide](docs/build.md). Changes to the Flutter and Rust app live in `mobile/`. Read [mobile/AGENTS.md](mobile/AGENTS.md) for native audio and platform integration constraints.

## Validate changes

```sh
./hadoo setup
./hadoo check
```

Analysis reports existing warnings and fails on compiler errors. The default test set covers Hadoo, the shared car catalogue, discovery, YouTube resolution, and downloads. Run the relevant tests and build for each platform you change. State which checks were on a physical device.

Run release-helper checks from the root with `python3 -m unittest discover -s tools -p 'test_release.py' -v`. Native package jobs are separate from the Flutter analysis/test job; neither result substitutes for the other.

The terminal-header screenshot uses `mobile/test/hadoo/goldens/macos/` and `goldens/linux/` references. macOS and Linux rasterize the bundled fonts differently. CI pins Ubuntu 24.04 and Flutter 3.47.1 and compares pixels strictly. On failure, download the `flutter-golden-diffs` artifact from that run within seven days and inspect the actual, expected, and diff images.

For an intentional visual change, run `flutter test --update-goldens test/hadoo/header_test.dart` inside `mobile/` on the matching host, inspect the resulting image, and commit the reviewed reference. Update both host references when the UI changes. Add a reviewed reference before validating on another host OS. Normal CI never regenerates or relaxes the references automatically.

## Open a pull request

Use a Conventional Commits title and the pull request template. Include the problem, behavior change, checks, and remaining platform limitations. Update the [listener guides](docs/README.md) when labels or setup steps change. Preserve license notices, and record any newly imported revision in `config/mobile-upstream-lock.json`.

Keep signing keys, packages, SDK downloads, personal account data, logs, and music outside Git. Follow the [release checklist](docs/maintenance.md#release-checklist) when preparing artifacts. For bugs, see [what to include in a report](docs/troubleshooting.md#report-a-problem).
