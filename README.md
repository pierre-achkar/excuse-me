# Excuse Me MVP

Cross-platform Flutter MVP for Android and iOS. It returns one concise excuse **idea**, not a ready-to-send message. Web is supported only as a development and test target, not a product deployment target.

There is no AI integration. Generation is a curated, deterministic local process with no network dependency and no external service configuration.

## Flutter Run

Install a current Flutter SDK, fetch packages, and run on an Android emulator, Android device, iOS simulator, or iOS device:

```sh
flutter pub get
flutter run
```

The Flutter app generates ideas on-device. Submitted situation text is not sent over the network.

## Local Excuse Engine

The product generation path uses the versioned English-alpha kernel library in `lib/data/curated_kernel_repository.dart`. A structured request captures intent, action, timing, relationship, obligation, context, and tone. The engine filters compatible kernels, makes a stable deterministic selection, avoids the immediately previous kernel during regeneration, and uses an explicit honest-boundary fallback when no specific kernel fits.

Each kernel also carries construction metadata for content review: family, cause type, responsibility strategy, audience, linguistic features, repair options, and prohibited high-risk claims. The app returns idea directions rather than ready-to-send first-person messages.

The Flutter product UI now uses the Excuse Shop flow to collect the mission, situation, and tone directly. The current conventional form is bridged to this schema by a small local mapper for the development API and browser harness.

## Local API

Requires Node.js 18 or newer. The local API preserves the existing `POST /api/generate` contract for development tooling and the browser harness:

```sh
npm start
```

`POST /api/generate` accepts JSON `{ situation, relationship, urgency, tone }` and returns `{ idea }`. Its generator is deterministic and local; it makes no network calls.

## Tests

```sh
npm test
flutter test
flutter analyze
```

The Node and Flutter suites cover deterministic local generation, complete request compatibility, safe fallback behavior, no-immediate-repeat regeneration, guardrails rejecting ready-to-send messages, versioned evaluation fixtures, and the unchanged API response contract. See `docs/generation-evaluation.md` for the baseline gates and known weaknesses.

## Analytics

Analytics is **disabled by default**. No analytics provider is approved or wired in as a dependency; the app ships with a `NoOpAnalyticsClient` that records nothing to disk or network. Enabling analytics requires a provider to be explicitly vetted and injected as an `AnalyticsClient` implementation.

### Event allowlist

The analytics boundary is deliberately narrow. The `AnalyticsClient` interface accepts exactly one call — `record(AnalyticsEvent)` — and the `AnalyticsEvent` enum contains only six values:

- `app_open` — recorded once when the Excuse Shop initializes.
- `generation_completed` — recorded after the client returns a generated idea.
- `regenerate` — recorded when regeneration is requested.
- `copy` — recorded after a successful clipboard copy.
- `share` — recorded when the share sheet is requested.
- `return_use` — recorded when the app resumes from a non-active lifecycle state.

The `record` API accepts **only the event enum**. It accepts no maps, strings, free-form properties, situation text, generated output, identity fields, advertising identifiers, or account data. There is no event-properties, identify, or track-with-payload API. This is enforced by the type signature, and privacy tests assert that passing a string, map, or generated output is rejected.

### Failure isolation

Analytics recording is non-blocking. Every `record` call is wrapped so that a failing provider can never break or crash the generation, copy, share, or resume flows.

### Data retention and opt-out

No user data, generated ideas, situation text, or identifiers are ever collected, persisted, or transmitted. If a provider is later approved, this section must be updated to state the provider-specific retention window and an in-app opt-out control; neither exists today because analytics is disabled by default.

### Disabled by default

`main.dart` constructs the app with `const NoOpAnalyticsClient()`. Tests inject a fake recorder to prove the allowlist and event timing without touching a real provider. Until a provider is approved, no analytics code beyond the interface, the enum, and the no-op shim is compiled into shipped behavior.

## Localization

The app ships with English-only localization using Flutter's generated localization (`flutter gen-l10n`). Configuration lives in `l10n.yaml`, the English template source is `lib/l10n/app_en.arb`, and the generated `AppLocalizations` class is wired into the `MaterialApp` via `localizationsDelegates` and `supportedLocales` (see `lib/app.dart`).

Every user-visible string in the Excuse Shop UI and app shell is extracted into localization resources, including missions, situations, tones, brewing text, result actions, errors, semantics labels, and SnackBar text. The repository also adds `flutter_localizations` (SDK) as a dependency and `flutter: generate: true` so the localization code is generated during build.

Domain enums and generation logic stay non-UI: the structured `ExcuseRequest`/`ExcuseKernel` enums, the curated kernel repository, and the local generation engine are not localized, and the request text sent to the client keeps stable English cues so keyword matching remains deterministic regardless of display locale.

Widget tests cover English localization rendering, RTL-direction safety, and larger text-scaling safety without layout overflow (see `test/localization_test.dart`).

## CI

`.github/workflows/ci.yml` runs on pull requests and pushes to `main`. It checks Dart formatting, runs `flutter analyze`, runs the full `flutter test` suite, builds a debug-signed Android APK without release signing secrets on `ubuntu-latest`, and builds an unsigned iOS release bundle without codesigning on `macos-latest`. Validation is deliberately free of release signing: no release keystore, certificate, provisioning profile, or signing secrets are used. See `docs/ci.md` for job details and the secrets required later for release signing.

## Privacy And Safety

- Generation is local-only. There are no API keys, model settings, external services, or generation network requests.
- Situation text is held only in the active text field or local API request. The Flutter app does not persist or log it.
- The app labels output as an idea and applies guardrails that reject greetings, sign-offs, quotes, and first-person copy.
- Copy and Share operate only after an idea is shown. Sharing uses the operating system share sheet.

## Limitations

- This is an MVP, not a production safety or content-moderation system.
- The curated deterministic library is an English-alpha baseline. Its 15 synthetic fixtures do not establish human-perceived usefulness or complete scenario coverage.
- No authentication, saved history, accessibility audit, approved analytics provider, or release signing is included. The analytics boundary is present but disabled by default; see the Analytics section above.
- `public/` is a temporary vanilla-browser harness for the Node API, not the Flutter product UI and not a deployment target.
- Android and iOS are the delivery platforms; web is only for local development/testing.
