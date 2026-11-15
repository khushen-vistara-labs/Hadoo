# Contributing to Hadoo

Use `trunk` as the base and start with the [build guide](docs/build.md). Changes to the Flutter and Rust app live in `mobile/`. Read [mobile/AGENTS.md](mobile/AGENTS.md) for native audio and platform integration constraints.

## Validate changes

```sh
./hadoo setup
./hadoo check
```

Analysis reports existing warnings and fails on compiler errors. The default test set covers Hadoo, the shared car catalogue, discovery, YouTube resolution, and downloads. Run the relevant tests and build for each platform you change. State which checks were on a physical device.

## Open a pull request

Use a Conventional Commits title and the pull request template. Include the problem, behavior change, checks, and remaining platform limitations. Update the [listener guides](docs/README.md) when labels or setup steps change. Preserve license notices, and record any newly imported revision in `config/mobile-upstream-lock.json`.

Keep signing keys, packages, SDK downloads, personal account data, logs, and music outside Git. Follow the [release checklist](docs/maintenance.md#release-checklist) when preparing artifacts. For bugs, see [what to include in a report](docs/troubleshooting.md#report-a-problem).
