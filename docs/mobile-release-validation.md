# Mobile Release Validation

**Protocol version:** 1.0.2
**Product:** Excuse Me
**Gate status:** NOT PASSED until both Android and iOS records are complete

This document is the versioned manual validation protocol for GitHub issue #16. It
covers the checks that hosted CI cannot prove: installation, real-device behavior,
accessibility, offline behavior, privacy inspection, and release evidence.

A compile-only result is not a device result. Do not mark a device check as passed
from `flutter build`, an emulator-only run, or a screenshot of a simulator.
The hosted debug-signed Android APK and no-codesign iOS bundle are CI compilation
evidence, not installable release candidates for this gate. Physical validation
requires an installable candidate produced by the approved signing/release path.

## Release-candidate record

Create one record for each Android and iOS candidate. Keep the record with the
release work item or pull request.

| Field | Android | iOS |
|---|---|---|
| Validation date (UTC) |  |  |
| Tester |  |  |
| App version |  |  |
| Build number |  |  |
| Source commit |  |  |
| Artifact filename |  |  |
| Artifact SHA-256 |  |  |
| Device model |  |  |
| OS version |  |  |
| Network state during offline checks |  |  |
| Result (`PASS`, `FAIL`, or `BLOCKED`) |  |  |
| Evidence links |  |  |
| Follow-up issue(s) |  |  |

Calculate artifact checksums locally and record the output; never paste signing
secrets, provisioning data, private device identifiers, or user situation text into
this document.

```sh
sha256sum <android-artifact>
shasum -a 256 <ios-artifact>
```

## Release gate rules

- [ ] All automated checks are green for the exact source commit.
- [ ] Android has a complete `PASS` record.
- [ ] iOS has a complete `PASS` record.
- [ ] No `FAIL` or unresolved `BLOCKED` item remains.
- [ ] Evidence identifies the exact artifact, source commit, device, and OS.
- [ ] Any failed candidate is withdrawn before store submission.
- [ ] A rollback target and owner are recorded before submission.

A platform is `PASS` only when every mandatory item in its platform checklist is
`PASS`. If a device, OS, or required capability is unavailable, use `BLOCKED` and
stop the release gate; do not convert it to `PASS` by inference.

### Item result notation

The unchecked boxes are a checklist, not evidence by themselves. For every item,
record a result and evidence reference in the release record or an attached copy
of the checklist using this form:

```text
Result: PASS | FAIL | BLOCKED — Evidence: E-...
```

`PASS` means the expected behavior was observed and evidence is attached. `FAIL`
means the required behavior was not observed or a defect was found. `BLOCKED`
means the item could not be executed or evidenced because a required capability
was unavailable. Use `[x]` only as an optional shorthand after recording `PASS`;
never use a checked box alone to represent `FAIL` or `BLOCKED`.

## Automated preflight evidence

Separate hosted CI evidence from local automated checks and manual candidate
inspection. Link each result to the correct run or evidence record; do not cite a
hosted CI run for a check it does not execute.

### Hosted GitHub Actions

- [ ] Hosted `Analyze & Format` job passes.
- [ ] Hosted `Flutter Test` job passes.
- [ ] Hosted Android debug-signed build passes.
- [ ] Hosted iOS `--no-codesign` build passes.

### Local automated checks

- [ ] `flutter analyze` is clean.
- [ ] `flutter test` is green.
- [ ] `npm test` is green for the development-only browser harness.
- [ ] `bash tests/ci_workflow_test.sh` passes its structural checks.

### Candidate metadata

- [ ] The candidate uses the approved version and build number.
- [ ] The exact source commit, artifact filename, and artifact checksum are
      recorded for each platform.

The hosted workflow is authoritative for YAML execution and the macOS iOS build.
The local shell validator in `tests/ci_workflow_test.sh` is structural support; it
is not a substitute for hosted CI or a device test.

## Shared functional checklist

Use a fresh install where the item says `fresh`; use an upgrade install only when
explicitly testing an upgrade. The production Flutter flow uses fixed mission,
situation, and tone choices and has no free-text situation field. Use those
synthetic fixed choices only. Do not enter real private situations into test
devices, screenshots, logs, or bug reports.

### Installation and launch

- [ ] Fresh install completes without an unexpected permission prompt.
- [ ] App launches to the Excuse Shop without a crash or blank screen.
- [ ] App title and primary navigation are visible.
- [ ] Cold start and warm start both succeed.
- [ ] Backgrounding and returning to the app do not crash or corrupt the flow.

### Generation flow

- [ ] Mission choices are visible and selectable.
- [ ] Situation choices are visible and selectable.
- [ ] Tone choices are visible and selectable.
- [ ] Brewing state is visible and resolves to one idea.
- [ ] Output is an idea, not a ready-to-send first-person message.
- [ ] A failed generation shows a recoverable error state if the test client is
      configured to fail.
- [ ] Regenerate completes and does not immediately repeat the previous kernel.
- [ ] Start-new flow clears the previous selection and returns to missions.

### Copy and share

- [ ] Copy is available only after an idea is shown.
- [ ] Copy places the displayed idea on the platform clipboard.
- [ ] Copy confirmation is visible and does not expose extra content.
- [ ] Share opens the native platform share sheet.
- [ ] Share is available only after an idea is shown.
- [ ] The tester cancels the share sheet; no real message is sent.
- [ ] Copy and share work after a fresh generation and after regeneration.

### Offline and privacy behavior

- [ ] Enable airplane mode or otherwise disable network access before launch.
- [ ] Launch succeeds while offline.
- [ ] Mission, situation, tone, generation, regeneration, copy, and share flows
      complete while offline.
- [ ] No network permission or cleartext configuration is introduced by the
      candidate.
- [ ] Run the complete fixed-choice flow and inspect platform logs after the flow;
      no fixed-choice selection, generated idea, or analytics payload appears.
- [ ] If log correlation requires a marker, place it only in the test harness or
      log filter, never in app input. If no supported external marker exists,
      mark only that correlation subcheck `BLOCKED` rather than inventing input.
- [ ] Confirm that no account, identifier, advertising ID, or arbitrary event
      properties are requested.
- [ ] Confirm analytics remains the no-op implementation unless a separately
      approved provider is explicitly under test.
- [ ] Reset the device or remove test-only harness data after testing.

### Accessibility and resilience

- [ ] Enable TalkBack on Android or VoiceOver on iOS.
- [ ] Every mission, situation, tone, and result action has a meaningful spoken
      label and role.
- [ ] Focus order follows the visual task order.
- [ ] The focused control remains visible while navigating.
- [ ] Increase system text size to the platform's large-text setting used for QA.
- [ ] No clipping, overlap, inaccessible control, or horizontal scrolling appears
      at the selected text size.
- [ ] Error, brewing, result, and empty/start-new states remain understandable.
- [ ] Reduce-motion or the platform animation-reduction setting does not block the
      flow.
- [ ] Portrait orientation remains usable; supported orientation changes do not
      lose selections or crash.

## Android checklist

**Required evidence:** device model, Android version, install method, artifact
checksum, screenshots or screen recording with all situation text redacted, and
log inspection result.

- [ ] Install an installable candidate APK by direct sideload for pre-signing
      validation, or install the AAB through Google Play Internal testing after
      release signing and the Google Play setup are complete. Do not use the
      hosted CI debug APK as a release candidate.
- [ ] Verify the application ID is `com.pierreachkar.excuse_me`.
- [ ] Verify the displayed version and build number match the candidate record.
- [ ] Inspect the merged manifest in the candidate APK/AAB with Android Studio
      APK Analyzer or an equivalent tool; confirm there is no `INTERNET`
      permission, no cleartext traffic allowance, and no unexpected permission.
- [ ] Repeat the shared functional checklist on a physical Android device.
- [ ] Repeat accessibility checks with TalkBack enabled.
- [ ] Capture redacted Android log inspection results from the fixed-choice flow;
      record any correlation limitation as `BLOCKED`.
- [ ] Uninstall the candidate and confirm no unexpected app data remains.
- [ ] If upgrading, install the previous approved build first, then verify the
      upgrade does not break launch or the core flow.

## iOS checklist

**Required evidence:** device model, iOS version, installation channel, artifact
checksum or archive identifier, screenshots or screen recording with all situation
text redacted, and console inspection result.

- [ ] Install the signed candidate through TestFlight when the Apple release path
      is available, or through a signed direct Xcode install on a registered QA
      device before TestFlight is configured. Do not use the hosted no-codesign
      bundle as an installable release candidate.
- [ ] Verify the bundle identifier matches the release configuration.
- [ ] Verify the displayed version and build number match the candidate record.
- [ ] Inspect the built app's `Info.plist` and entitlements; confirm there is no
      `NSAppTransportSecurity` arbitrary-load or exception configuration, no
      unexpected usage-description key, and no unexpected network entitlement.
- [ ] Repeat the shared functional checklist on a physical iOS device.
- [ ] Repeat accessibility checks with VoiceOver enabled.
- [ ] Capture redacted Xcode/device-console inspection results from the
      fixed-choice flow; record any correlation limitation as `BLOCKED`.
- [ ] Uninstall the candidate and confirm no unexpected app data remains.
- [ ] If upgrading, install the previous approved build first, then verify the
      upgrade does not break launch or the core flow.

## Evidence index

Use stable links to the release issue, pull request, CI run, and redacted evidence.
Do not store private situation text or unredacted screenshots in the repository.

| Evidence ID | Platform | Check(s) covered | Link or location | Reviewer | Result |
|---|---|---|---|---|---|
| E-001 | Android | Hosted CI |  |  |  |
| E-002 | Android | Local automated checks |  |  |  |
| E-003 | Android | Candidate metadata and merged manifest |  |  |  |
| E-004 | Android | Install and launch |  |  |  |
| E-005 | Android | Generation, regenerate, copy, share |  |  |  |
| E-006 | Android | Offline and privacy inspection |  |  |  |
| E-007 | Android | TalkBack and large text |  |  |  |
| E-008 | iOS | Hosted CI |  |  |  |
| E-009 | iOS | Local automated checks |  |  |  |
| E-010 | iOS | Candidate metadata, Info.plist, and entitlements |  |  |  |
| E-011 | iOS | Install and launch |  |  |  |
| E-012 | iOS | Generation, regenerate, copy, share |  |  |  |
| E-013 | iOS | Offline and privacy inspection |  |  |  |
| E-014 | iOS | VoiceOver and large text |  |  |  |

## Rollback and release stop

Before submission, record the last approved build as the rollback target. A
candidate with a failed or blocked platform gate must not be submitted.

1. Mark the affected platform and the overall gate `FAIL` or `BLOCKED`.
2. Link the failure evidence and create or update a GitHub issue.
3. Stop TestFlight/App Store or Google Play submission of the candidate.
4. Keep the last approved build available in its pre-release channel.
5. If the candidate was distributed internally, remove or halt its rollout and
   direct testers to the last approved build.
6. Fix the issue on a new commit/build number; do not overwrite the evidence for
   the failed candidate.
7. Rerun the complete affected platform checklist and the shared privacy checks.
8. Record the rollback decision, owner, timestamp, and replacement build.

For a store release, the exact portal action depends on the release state: remove
an unreleased build from review, stop an internal rollout, or submit a corrective
version. Credentials and portal access belong in the release operation, never in
this repository.

## Current execution status

This protocol is prepared, but the physical-device gate is **not executed in the
current Linux environment**. Android and iOS device access, and interactive macOS
access for device installation, must be provided before issue #16 can be closed.
