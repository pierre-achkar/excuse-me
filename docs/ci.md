# CI Documentation

## Workflow: `.github/workflows/ci.yml`

Triggers on **pull requests** and **pushes to `main`**.
All jobs use `permissions: contents: read` (least privilege).

### Jobs

| Job | Runner | Purpose |
|-----|--------|---------|
| `analyze` | `ubuntu-latest` | Formatting + static analysis |
| `test` | `ubuntu-latest` | Full `flutter test` suite |
| `android-build` | `ubuntu-latest` | Debug-signed APK build without release signing secrets |
| `ios-build` | `macos-latest` | Unsigned release iOS build |

#### Job dependency graph

```
analyze ──┬──> test
          ├──> android-build
          └──> ios-build
```

`test`, `android-build`, and `ios-build` run in parallel after `analyze`
passes. This gives fast feedback: a format or lint failure blocks all
downstream jobs without wasting runner minutes.

### Dependency caching

Each job explicitly caches the pub dependency directory (`~/.pub-cache`)
keyed on `pubspec.lock`. `subosito/flutter-action@v2` provisions the Flutter
SDK and its built-in cache is enabled for Flutter dependencies.

### No-release-signing validation

**Android**: `flutter build apk --debug` produces a debug-signed APK using
Flutter's default debug keystore. It does not use release signing secrets.
This validates Dart/Flutter compilation, Android resource linking, and plugin
integration; it is not a release artifact.

**iOS**: `flutter build ios --release --no-codesign` compiles the release
binary without codesigning. No Apple Developer certificate or provisioning
profile is required. This validates the Xcode build phase (resource
compilation, asset catalog processing, Swift bridging) without identity
credentials.

### Secrets required for release signing

Release signing runs only through the **protected manual release workflow**
`.github/workflows/release.yml` (workflow_dispatch only, `contents: read`,
scoped to the protected `release` environment). It is separate from the CI
workflow above and never runs automatically. See
`docs/release-signing.md` for the exact secret contract, ownership, rotation,
recovery, and revocation, and `tests/release_workflow_test.sh` for the
structural checks.

- **Android release signing**: Base64-encoded keystore file, keystore
  password, key alias, and key password as repository or `release`
  environment secrets (`ANDROID_KEYSTORE_B64`, `ANDROID_KEYSTORE_PASSWORD`,
  `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`). The workflow decodes the
  keystore to the runner temp directory and cleans it up via a trap,
  checks for missing secrets (fail closed), and uploads only the signed
  `.aab`. Locally, the git-ignored `android/key.properties` (see
  `android/key.properties.example`) drives the fail-closed Gradle signing.

- **iOS release signing**: Not wired into any CI/release workflow. The
  non-secret boundary is `scripts/ios-sign.sh` plus the git-ignored
  `ios/TeamID.xcconfig` (see `ios/TeamID.xcconfig.example`). It automates
  temporary keychain/profile handling on macOS with cleanup traps and
  fail-closed checks. No certificate, provisioning profile, or team
  identifier is committed.

**Never name, reference, or expose secret values in workflow logs or
documentation.** Use GitHub's secret masking and avoid `echo` commands
that interpolate secret variables into log output.

`docs/release-signing.md` documents the Android secret contract, the Apple
certificate/provisioning contract, ownership, rotation, recovery, emergency
revocation, non-secret local verification, and the remaining Mac/credential
blockers.

### Validation scripts

`tests/ci_workflow_test.sh` validates the checked-in CI workflow's expected triggers,
job-scoped runners and commands, dependencies, cache paths, and absence of
signing secrets/artifacts using standard shell tools. It does not replace the
GitHub Actions parser; the hosted workflow run is the authoritative YAML and
execution check.

`tests/release_workflow_test.sh` validates the protected manual release workflow's
manual-only trigger, least-privilege permissions, protected release environment,
fail-closed missing-secret guards, runner-temp decoding, cleanup traps,
signed-Android-only scope, and absence of secret/artifact leakage.

`tests/ios_sign_test.sh` validates that `scripts/ios-sign.sh` fails closed
without real secrets and contains no embedded credentials or team id.

Run the local structural checks with:

```bash
bash tests/ci_workflow_test.sh
bash tests/release_workflow_test.sh
bash tests/ios_sign_test.sh
```

These are structural support only; the hosted workflow run remains the
authoritative YAML and execution check.
