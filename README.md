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

The Node and Flutter suites cover deterministic local generation, guardrails rejecting ready-to-send messages, and the unchanged API response contract.

## Privacy And Safety

- Generation is local-only. There are no API keys, model settings, external services, or generation network requests.
- Situation text is held only in the active text field or local API request. The Flutter app does not persist or log it.
- The app labels output as an idea and applies guardrails that reject greetings, sign-offs, quotes, and first-person copy.
- Copy and Share operate only after an idea is shown. Sharing uses the operating system share sheet.

## Limitations

- This is an MVP, not a production safety or content-moderation system.
- The curated deterministic generator is intentionally generic and may not fit every situation.
- No authentication, analytics, saved history, localization, accessibility audit, or release signing is included.
- `public/` is a temporary vanilla-browser harness for the Node API, not the Flutter product UI and not a deployment target.
- Android and iOS are the delivery platforms; web is only for local development/testing.
