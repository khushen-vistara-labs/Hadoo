# Contributing

Hadoo is a local patch/build project for a user-supplied YouTube Music APK.
Use Python 3.10+ and a Java 21+ JDK. No Node.js, Expo, Gradle project, or Python
packages are needed for Hadoo's own tooling.

Run these checks before opening a pull request:

```sh
./hadoo check
./hadoo setup
./hadoo patches
```

GitHub Actions runs the offline tests, exports the branding and checks the
profile against the actual checksum-pinned Morphe bundle. It never builds or
publishes a proprietary APK and never needs a signing key.

Use Conventional Commits for commits and PR titles, for example
`feat(build): support a reviewed upstream release`. Local commit checks live in
`.husky/commit-msg`; enable them with `git config core.hooksPath .husky`.
Complete every section of the PR template. Code owners are in `.github/CODEOWNERS`.

Keep changes to `config/upstream-lock.json` explicit and reviewed. Obtain hashes
from the official GitHub release asset metadata, check upstream compatibility,
and exercise setup plus a complete local APK build when a suitable input exists.
Do not automatically follow latest releases or bypass APK version checks.

Keep originals in `assets/images/` unchanged when changing the resource exporter.
Review `.hadoo-local/branding/preview.png` after generating new density resources.

Never commit APKs, downloaded tools, signing keys, credentials, exported account
data, local backups or music. These belong under the ignored `.hadoo-local/`
directory. See `NOTICE`, `LICENSE`, and `third_party/` for attribution.
