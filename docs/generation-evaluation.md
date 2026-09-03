# Generation evaluation baseline

## Scope

This baseline covers English-alpha library version `1.0.0` and fixture schema version `1`. The executable corpus is `test/fixtures/generation_cases.v1.json`.

Each case has a stable `id`, the seven structured request dimensions, `expectedKernelId`, and `expectedIdea`. Those golden fields pin deterministic selection and content for library version `1.0.0`. Optional `risk` and `clarity` fields encode unsafe-request and ambiguity behavior. `coverage` tags name the boundary under test, and tests require those tags to match the corresponding semantic field. `expectFallback: true` requires an honest-boundary fallback; all other cases must select a compatible specific kernel.

## Pass/fail criteria

The baseline passes only when:

- at least 12 scenarios are evaluated;
- all supported values for every structured request dimension appear in the corpus;
- every non-fallback result is compatible with all structured request dimensions;
- every result passes the idea-only safety policy;
- every result passes the non-generic quality policy;
- every result matches its expected kernel ID and exact idea baseline;
- high-risk fabrication requests and ambiguous requests select a fallback;
- at least six distinct kernels are selected across the corpus;
- an unsupported combination reaches the explicit honest-boundary fallback;
- immediate regeneration does not return the previous kernel;
- the same first request remains deterministic across fresh clients.

## Current result

- 15 scenarios execute successfully.
- All supported values across intent, action, timing, relationship, obligation, context, and tone are represented.
- Compatibility, safety, fallback, deterministic-first-result, and no-immediate-repeat gates pass.
- The diversity gate selects at least six distinct kernels.

Run:

```sh
flutter test test/generation_fixtures_test.dart \
  test/local_excuse_engine_test.dart \
  test/idea_safety_policy_test.dart \
  test/idea_quality_policy_test.dart \
  test/idea_client_test.dart
```

## Known weaknesses

- The corpus is intentionally small and synthetic; it is not evidence of human-perceived usefulness.
- Every specific kernel narrows timing, relationship, obligation, or cause-relevant context; metadata is asserted by test.
- Fallback regeneration alternates between the two fallback kernels; the spec requires only no immediate repeat, so alternation (including two-way flip-flop) is accepted behavior.
- The current prototype UI maps free-text and legacy controls into structured requests with simple local heuristics. The Excuse Shop flow should collect those dimensions directly.
- Tone support is selection metadata, not a general rewriting system. Some compatible ideas may feel less strongly styled than their requested tone.
- English content has not yet undergone accessibility review, moderated user testing, or native-device QA.
