# Excuse Me MVP

A local, privacy-first MVP that returns one concise excuse **idea**, never a ready-to-send message.

## Run

Requires Node.js 18 or newer. No package installation is needed.

```sh
npm start
```

Open `http://localhost:3000`.

## Test

```sh
npm test
```

Tests use Node's built-in test runner and cover validation, deterministic fallback generation, provider opt-in, output guardrails, and the HTTP API.

## Provider configuration

The app uses deterministic local generation by default. It makes no network request unless `OPENAI_COMPATIBLE_API_KEY` is explicitly set. Copy `.env.example` values into your shell or environment manager; `.env` is not loaded automatically and is ignored by Git.

Optional variables:

- `OPENAI_COMPATIBLE_API_KEY`: enables the provider.
- `OPENAI_COMPATIBLE_BASE_URL`: defaults to `https://api.openai.com/v1`.
- `OPENAI_COMPATIBLE_MODEL`: defaults to `gpt-4o-mini`.
- `PORT`: defaults to `3000`.

Provider responses are discarded in favor of the local fallback if they contain greetings, sign-offs, quotes/dialogue, first-person copy, or invalid formatting.

## Privacy

Requests are processed only in memory. The server creates no database, files, analytics, or request logs, and validation errors never echo submitted content. Enabling a provider sends the submitted fields to that provider; leave its key unset for fully local generation.

## Issue Mapping

The remote GitHub issues were unavailable from this environment (the repository issues API returned 404 and `gh` is not installed). This milestone implements the requested coding-issue scope:

- Single-screen situation, relationship, urgency, and tone form.
- `POST /api/generate` yielding exactly one concise idea.
- Deterministic local fallback and opt-in OpenAI-compatible provider.
- Guardrails, browser loading/validation/error/regenerate states, and privacy-first handling.

## Flutter Migration Boundary

The reusable product boundary is the JSON HTTP contract: `POST /api/generate` accepts `{ situation, relationship, urgency, tone }` and returns `{ idea }` or `{ error }`. A Flutter client can replace `public/` while retaining this backend contract, validation semantics, and provider/guardrail policy. The current vanilla UI deliberately contains no business logic beyond calling that API.
