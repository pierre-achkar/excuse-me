# Release Signing

**Product:** Excuse Me
**Supports:** GitHub issue #17 (secure, non-secret release signing boundary)
**Gate status:** Boundary is implemented and tested locally; **no real signing secret, keystore, certificate, provisioning profile, or Apple team identity is stored in this repository.** Produce and use such material only with your own credentials and the tooling below.

This document is the exact secret contract for release signing. It is written so that every credential-bearing step is owned, audited, and reversible, and so that nothing private must ever be guessed or hardcoded into the repository.

---

## Non-goals and honest scope

- This repository is **release-boundary-only**. It provides fail-closed Gradle signing, a manual GitHub Actions release job targeting a `release` environment, placeholder-based iOS archive/export automation, and this contract. Configure the `release` environment in GitHub with required reviewers and environment secrets before using the workflow.
- The **signed iOS path and the Android Gradle execution with a real keystore are NOT tested here** because they require user-owned credentials, an Apple team identity, and (for iOS) a macOS host. We implement the non-secret boundary and document the steps rather than pretend a signed build was produced.
- Hosted CI (`ci.yml`) builds only the **debug-signed** Android APK and the **no-codesign** iOS bundle. It never touches release material. See `docs/ci.md`.

---

## 1. Android release signing secret contract

### Required secret inputs

| Input | Where it lives | Who provides |
|---|---|---|
| `storeFile` | Local `android/key.properties` (git-ignored) pointing at a local keystore | Release owner |
| Keystore (`.jks`/`.keystore`) | Local disk, **never committed** | Release owner |
| `storePassword` | `android/key.properties` or an Android secret | Release owner |
| `keyAlias` | `android/key.properties` or an Android secret | Release owner |
| `keyPassword` | `android/key.properties` or an Android secret | Release owner |

### Local template

`android/key.properties.example` is the safe, fake-only template. Copy it to the git-ignored `android/key.properties` and replace every `CHANGE_ME` with your private values:

```sh
cp android/key.properties.example android/key.properties
# edit android/key.properties
```

### Fail-closed behavior

`android/app/build.gradle.kts` reads signing from `android/key.properties`. When a **release** assembly is requested and any required property or the keystore file is missing, the Gradle build throws and fails **closed** — it never silently falls back to debug keys. Debug and profile builds (`flutter build apk --debug`) are **unaffected** and never require signing material, preserving the offline/dev path.

### What is never committed

Ignored in `.gitignore` and `android/.gitignore`: `android/key.properties`, `local.properties`, keystore/certificate extensions (`.jks`, `.keystore`, `.p12`, `.pfx`, `.cer`, `.crt`, `.pem`), and generated release artifacts (`*.apk`, `*.aab`).

---

## 2. Apple certificate / provisioning contract (iOS)

> Signed iOS is **not configured with any real credential** here. The names below are explicit placeholders, and `scripts/ios-sign.sh` automates the macOS steps with temporary, fail-closed handling. Nothing in the repository contains a team identifier, certificate, or provisioning profile.

### Ownership

One named **iOS release owner** is responsible for the Apple Developer team, the distribution certificate, the provisioning profile(s), and TestFlight/App Store credentials. That owner is the single point of contact for rotation and recovery.

### Required inputs (placeholders you must supply)

| Input | Placeholder name | Notes |
|---|---|---|
| Distribution certificate `.p12` | `IOS_DISTRIBUTION_P12_B64` (base64) | Export from Keychain; never commit |
| Certificate password | `IOS_DISTRIBUTION_P12_PASSWORD` | Never commit |
| Provisioning profile `.mobileprovision` | `IOS_PROVISIONING_PROFILE_B64` (base64) | For the app store distribution profile |
| Apple team identifier | External `IOS_TEAM_ID` environment variable for `scripts/ios-sign.sh`, or a local Xcode setting | **Not** added to this repo |

### How the boundary stays honest

- `ios-sign.sh` (see below) uses a **temporary** keychain and profile path under a system temp directory, cleans them up with a `trap`, and **fails closed** when any required secret/environment variable or resource is missing. It validates the team ID, bundle ID, provisioning-profile UUID, and profile name before using them in paths or plist commands, archives with explicit Xcode signing settings, and exports the signed IPA to the ignored `build/ios/release/` directory.
- The `.xcconfig` `TeamID.xcconfig` is **git-ignored**; only a `TeamID.xcconfig.example` with a `CHANGE_ME` placeholder is committed.
- No `.p12`, `.mobileprovision`, `.cer`, `.pem`, or `.provisionprofile` file is committed.

---

## 3. Secret rotation

Rotate on suspicion of compromise, on personnel change, and on a fixed schedule (at least annually).

### Android
1. Generate a new keystore with `keytool` (or Android Studio). Use a new alias and strong passwords.
2. Publish the app update signed with the **new** key to the store (Google Play key/cert upgrades).
3. Move `android/key.properties` to reference the new key; keep the old file only if needed for an in-progress release, then delete it.
4. Update every secret store that references the old values.

### iOS
1. In Apple Developer, regenerate the distribution certificate and provisioning profile (revoke the old certificate **after** the new one is in place and a successful build exists).
2. Update the secret values and local Keychain/xcconfig.
3. Remove the old `.p12` from all machines and secret stores.

---

## 4. Recovery

- **Lost Android keystore:** Without the original keystore you cannot sign an update for an existing app identity on that channel. If you still have the key/cert stored in a safe backup (Keychain, encrypted drive, password manager), restore it. Otherwise use Play App Signing if enabled (Google holds your upload key) or rekey per the store's upgrade flow and note the identity change.
- **Lost iOS certificate/profile:** Regenerate in Apple Developer, re-import locally, rebuild, and resubmit. Apple allows new distribution certificates; keep the account-level App ID and bundle identifier (`com.pierreachkar.excuseMe`).
- **Lost password on a backup:** keep passwords in your password manager; do not store them next to the keystore or in the repo.

---

## 5. Emergency revocation

- **Android:** Immediately rotate the keystore and contact Google Play support to flag a compromised signing identity; revoke and stop any in-flight uploads.
- **iOS:** In Apple Developer, revoke the compromised distribution certificate immediately (this invalidates signatures), revoke and regenerate the provisioning profile, and notify the release owner. Downgrade or disable any exposed secret, rotate all related passwords, and audit logs for exfiltration.

---

## 6. Non-secret local verification

You can verify configuration and privacy invariants **without** any secret, keystore, certificate, macOS, or Apple identity:

```sh
flutter analyze
flutter test
bash tests/ci_workflow_test.sh     # validates CI workflow structure
bash tests/release_workflow_test.sh # validates the protected release workflow structure
```

`test/release_signing_config_test.dart` asserts:
- `key.properties` and keystore/certificate extensions and release artifacts are git-ignored.
- A fake-only `android/key.properties.example` exists with `CHANGE_ME` placeholders.
- Release Gradle signing reads all required properties (fail-closed) and no longer reuses the debug signing config.
- No checked-in Android source contains a quoted literal secret.

`tests/release_workflow_test.sh` asserts the release workflow is manual-only, least-privilege, release-environment-scoped, validates and propagates explicit build inputs, decodes under the runner temp dir, fails closed on missing secrets, uses cleanup traps, produces only a signed Android artifact, and leaks no secret.

`scripts/ios-sign.sh` expects the four iOS environment variables listed above plus
the optional `IOS_BUNDLE_ID` and `IOS_OUTPUT_DIR` values. On macOS it creates the
temporary signing context, runs `flutter build ios --release --config-only`,
archives and exports the signed IPA with `xcodebuild`, then removes the temporary
keychain and provisioning profile. Its signed execution is not tested in this
Linux environment.

---

## 7. Remaining Mac / credential blockers

The following **cannot be completed in this environment** without user-owned credentials or a macOS host:

1. Creating and testing a real Android keystore and running a signed `flutter build appbundle --release` (needs Android SDK + real keystore). The Gradle fail-closed path is implemented but **not executed** here.
2. Importing an Apple distribution certificate/provisioning profile and producing a signed iOS build or TestFlight upload (needs macOS + Apple Developer account). The helper produces an IPA but does not upload it to TestFlight.
3. Running `scripts/ios-sign.sh` end-to-end.

All of the above are implemented as safe, non-secret boundaries (fail-closed, placeholder-based, cleanup-guarded) and documented rather than guessed.
