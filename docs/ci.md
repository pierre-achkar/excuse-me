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

### Secrets required for release signing (future)

When release builds are needed, the following protected secrets must be
configured in the GitHub repository settings:

- **Android release signing**: A base64-encoded keystore file, keystore
  password, key alias, and key password. These should be stored as
  repository or environment secrets and injected only in release workflow
  jobs. The workflow should decode the keystore to a temporary file and
  clean it up in a post-step.

- **iOS release signing**: A base64-encoded `.p12` certificate, a
  base64-encoded provisioning profile, and the certificate password.
  These should be stored as repository or environment secrets and decoded
  to temporary files during the build step. The workflow should use
  `security import` to add the certificate to the temporary keychain and
  specify the provisioning profile in the Xcode build command.

**Never name, reference, or expose secret values in workflow logs or
documentation.** Use GitHub's secret masking and avoid `echo` commands
that interpolate secret variables into log output.

### Validation script

`tests/ci_workflow_test.sh` validates the checked-in workflow's expected triggers,
job-scoped runners and commands, dependencies, cache paths, and absence of
signing secrets/artifacts using standard shell tools. It does not replace the
GitHub Actions parser; the hosted workflow run is the authoritative YAML and
execution check. Run the local structural checks with:

```bash
bash tests/ci_workflow_test.sh
```
