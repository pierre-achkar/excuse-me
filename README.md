# Excuse Me MVP

Cross-platform Flutter MVP for Android and iOS. It returns one concise excuse **idea**, not a ready-to-send message. Web is supported only as a development and test target, not a product deployment target.

## Flutter Run

Install a current Flutter SDK, then fetch packages and run on an Android emulator, Android device, or iOS simulator/device:

```sh
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

`API_BASE_URL` is optional. When omitted, or when the API cannot be reached, the app uses its deterministic on-device fallback. The fallback does not incorporate the submitted situation text.

Device URLs differ:

- Android emulator: `http://10.0.2.2:3000`
- iOS simulator: `http://localhost:3000`
- Physical device: `http://<your-computer-LAN-IP>:3000`
- Flutter web development: `http://localhost:3000`

Use HTTPS for a physical iOS device or any non-development API. The unencrypted local Node server is intended only for local development; without a reachable API the app still works through its on-device fallback.

Start the compatible local API in a separate terminal:

```sh
npm start
```

The API contract is unchanged: `POST /api/generate` accepts JSON `{ situation, relationship, urgency, tone }` and returns `{ idea }`. The server permits this endpoint from a Flutter web development origin.

## Flutter Test

```sh
flutter test
flutter analyze
```

The Flutter tests cover the result flow, deterministic offline fallback, and guardrails rejecting ready-to-send messages. The Node server suite remains available with:

```sh
npm test
```

## Privacy And Safety

- Situation text is held only in the active text field/request. The Flutter app does not persist or log it.
- The app labels output as an idea and applies guardrails that reject greetings, sign-offs, quotes, and first-person copy before falling back locally.
- Copy and Share operate only after an idea is shown. Sharing uses the operating system share sheet.
- Enabling the server's optional provider can send submitted fields to that provider. Leave its key unset for local server generation.

## Limitations

- This is an MVP, not a production safety or content-moderation system.
- The deterministic fallback is intentionally generic and may not fit every situation.
- Android currently permits cleartext HTTP solely to connect to the local development server; production API traffic must use HTTPS and tighten this setting before release.
- No authentication, analytics, saved history, localization, accessibility audit, or release signing is included.
- `public/` is a temporary vanilla-browser harness for the Node API, not the Flutter product UI and not a deployment target.
- Android and iOS are the delivery platforms; web is only for local development/testing.

## Server Configuration

Requires Node.js 18 or newer. The server uses local generation by default and makes no provider request unless `OPENAI_COMPATIBLE_API_KEY` is set. Optional variables are `OPENAI_COMPATIBLE_BASE_URL`, `OPENAI_COMPATIBLE_MODEL`, and `PORT` (default `3000`).
