# Maintenance

## Local and published files

Everything generated or private belongs under `.hadoo-local/`: tools, original
APKs, build outputs, signing keys, scratch files and backups. `.gitignore` also
excludes common APK, keystore and private-key extensions elsewhere.

GitHub Actions checks Hadoo's source and patch compatibility only. It has no APK
input, no device connection and no signing key. There is no automatic APK release
or publishing workflow.

## Upstream updates

1. Read the Morphe Desktop and Morphe Patches release notes and confirm they use
   compatible patcher versions.
2. Choose exact stable releases. Obtain each asset's SHA-256 from official GitHub
   release metadata and verify the downloaded bytes independently.
3. Update `config/upstream-lock.json`, including the YouTube Music package's
   supported stable versions, signing certificates and option keys from that
   exact patch release's `patches-list.json`.
4. Run `./hadoo setup`, `./hadoo check`, `./hadoo patches`, then a complete local
   build from a supported original APK. Test the result on your device.
5. Keep the same signing key so the new build can update the previous build.

Failed patches stop the build. Hadoo does not pass `--force` or
`--continue-on-error`. It uses full bytecode rebuilding rather than stripping
classes aggressively. Service-side playback failures may still require a
reviewed upstream update.

## Embedded defaults

`config/phone-settings.json` and `config/native-settings.json` are build inputs.
`tools/HadooDefaultsPatch.java` compiles against the checksum-pinned Desktop JAR
into an independent local MPP; the upstream MPP remains unchanged. The add-on
uses Java 17 class files as required by Morphe's patch loader.

The add-on runs after upstream patch execution. It changes Morphe constructor
defaults while restoring any shared bytecode registers, changes the startup
animation default getter, and sets fallback arguments in YouTube Music's native
account-aware boolean preferences wrapper. Native saved values still take
precedence. Unsupported constructors, enum values or native getter shapes fail
the build. The finished APK is inspected independently and its default profile,
add-on SHA-256 and source hash are recorded in `build.json`.

When updating upstream, test a fresh install and confirm that changing the
audio preference off survives restart and reinstall-as-update. Do not clear an
existing user's app data to test fresh defaults; use a disposable emulator.

## Earlier Hadoo implementation

The migration preserved the old working tree, including uncommitted changes and
local build dependencies, at `.hadoo-local/legacy-2026-11-03/`. The original two
logo PNGs were copied without changing their bytes. The backup also contains the
previous Git HEAD, working-tree status, binary diff and logo checksums.

This backup is local to the migration machine and is not part of a fresh clone.
Committed versions remain in Git history. No history was rewritten. To inspect
the previous implementation, use a separate worktree or the local backup; do not
restore files over the rebuilt project without first saving current changes.
