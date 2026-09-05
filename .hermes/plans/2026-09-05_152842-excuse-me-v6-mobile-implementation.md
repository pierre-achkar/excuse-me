# Excuse Me v6 Mobile Shop Experience Implementation Plan

> **For Hermes:** Implement this plan task-by-task with strict RED → GREEN → REFACTOR and an independent review after each vertical slice.

**Goal:** Replace the current four-step Flutter shop page with the locked v6 mobile experience: a full-screen curiosity shop, Excusee’s six-dimension conversation, physical progress tokens, reactive atmosphere, search and handover choreography, and one post-result tone-adjustable excuse card.

**Architecture:** Keep semantic request state and deterministic kernel selection separate from presentation randomness. A typed `ShopFlowController` owns the conversation state, history, cancellation epoch, and injected presentation randomizer; `ShopScene`, `ConversationHUD`, and `ResultCard` render that state. The existing local engine remains offline and deterministic, while tone is moved out of kernel selection into a post-result transformation.

**Tech Stack:** Flutter/Dart, existing Material shell, local `CustomPainter` pixel scene, bundled/local assets only, Flutter localization from ARB, `flutter_test`, no backend, no AI, no network runtime dependency, no new state-management package unless implementation proves the existing structure insufficient.

---

## Review of the supplied v6 artifacts

### Confirmed product changes from the current branch

The current Flutter implementation in `lib/ui/excuse_shop_page.dart` is still the earlier four-step flow:

```text
damage → timing → audience → delivery
```

v6 changes this to six semantic dimensions:

```text
intent → action → context → timing → relationship → obligation
```

Additional required changes:

- Context moves before timing.
- Action choices depend on intent.
- Timing choices depend on action.
- `Explain missed commitment` skips the timing question and automatically records `Already happened`.
- Tone is removed from the six-question traversal and becomes a post-result transformation.
- The user never selects an excuse family.
- The shop occupies the whole viewport during the interaction; the current clean `AppBar`/canvas presentation is not sufficient.
- Entry copy is randomized as curated pairs, not independent strings.
- Outfit, search copy, search motion, handover copy, handover motion, ambient mood, and strange events are presentation-only randomness.
- Six physical counter tokens replace the visible `Step n of 4` indicator.
- Search is a short scene beat, not a spinner.
- Back and restart must be disabled only during search/handover, with stale asynchronous callbacks cancelled safely.
- Result card remains the primary artifact; copy/share must not become the primary action.
- Reduced motion must remove the choreography while preserving clear state changes.

### Prototype issues not to copy into production

- The HTML loads Google Fonts at runtime. Flutter production must use bundled licensed fonts or an explicit offline-safe fallback.
- The HTML uses `Math.random()` directly. Production must inject presentation randomness so tests can prove no immediate repeats and semantic output remains stable.
- The HTML leaves restart active during the asynchronous search callback. A restart during search can allow stale callbacks to mutate the new session. Flutter must use a cancellation/session epoch and lock both Back and Restart during the bounded transition, as specified.
- The HTML contains example kernel wording. The Flutter app must not silently replace the repository’s explicit placeholder content with unapproved authored output. Kernel IDs, family selection, safety checks, and placeholder status remain authoritative.
- The HTML’s inline SVG wizard must be translated into an offline Flutter rendering strategy; it must not create a runtime SVG/font/network dependency.
- The HTML’s `KEEP CARD` button has no collection implementation. Its behavior must be decided before production wiring.

---

## Current context and invariants

- Repository: `/opt/data/work/excuse-me`
- Starting branch: `feat/complete-excuse-shop-journey`
- Starting commit: `a963395`
- Current branch is clean and pushed.
- Previous verification baseline: full Flutter test suite passed with 107 tests; `flutter analyze`, web release build, and `git diff --check` passed. Rerun all gates after v6 changes.
- Existing semantic model: `lib/domain/excuse_request.dart`
- Existing user-facing option catalog: `lib/domain/shop_selection.dart`
- Existing deterministic kernel model: `lib/domain/excuse_kernel.dart`
- Existing local selection engine: `lib/services/local_excuse_engine.dart`
- Existing rich-result boundary: `lib/services/idea_client.dart`
- Existing monolithic UI: `lib/ui/excuse_shop_page.dart`
- Existing theme tokens: `lib/ui/shop_theme.dart`
- Existing localization source: `lib/l10n/app_en.arb`
- Existing runtime sprite: `assets/design/shop-owner-sprite.png`
- Supplied v6 source files to preserve unchanged under repository design documentation:
  - `attachments/excuse-me-v6-design-and-conversation-spec.md`
  - `attachments/excuse-me-v6-developer-handoff.html`

Hard invariants:

- No backend, AI/model call, account, API key, network runtime dependency, or free-form situation persistence.
- No situation text or generated content in analytics, logs, or persistent storage.
- No fabricated medical, family, legal, financial, identity, death, emergency, screenshot, notification, or evidence claims.
- Output remains an atomic idea/direction, not a ready-to-send message.
- Excuse family and kernel remain engine-selected.
- Presentation randomness cannot change the semantic request or selected kernel.
- No release credentials, signing artifacts, certificates, provisioning profiles, team identifiers, or passwords in the repository.
- Current placeholder content remains visibly placeholder-safe until the separate content-authoring milestone.

---

## Proposed file structure

Create the following focused production boundaries unless code inspection during implementation shows an existing equivalent:

```text
lib/domain/shop_selection.dart                 # v6 typed option catalogs and pure mapping
lib/domain/shop_flow.dart                      # step/history/presentation state value objects
lib/services/local_excuse_engine.dart          # base kernel selection and tone rendering boundary
lib/services/idea_client.dart                  # rich result with post-result tone capability
lib/ui/excuse_shop_page.dart                   # composition/root lifecycle only
lib/ui/shop_flow_controller.dart               # state transitions, history, cancellation epoch
lib/ui/shop_scene.dart                         # full-viewport pixel shop composition
lib/ui/shop_scene_painter.dart                 # wall, arch, floor, counter and shelves
lib/ui/shop_curiosity_painter.dart             # dense deterministic curiosities
lib/ui/shop_excusee_painter.dart               # dynamic-palette wizard silhouette
lib/ui/shop_event_layer.dart                   # transient event animation layer
lib/ui/shop_presentation.dart                  # moods, outfits, copy IDs, randomizer
lib/ui/conversation_hud.dart                   # dialogue, choice grid, nav, progress tokens
lib/ui/result_card.dart                        # card wrapper, tones, repair, actions
lib/l10n/app_en.arb                           # all v6 copy and semantics
assets/design/                                 # exact v6 sources and runtime artwork only

test/shop_flow_model_test.dart                 # option catalogs and pure mappings
test/shop_flow_controller_test.dart            # state machine/back/restart/cancellation
test/shop_presentation_test.dart               # seeded randomness/no-repeat invariants
test/tone_transformation_test.dart             # same kernel across tones
test/shop_scene_test.dart                      # scene structure, moods, events, semantics
test/six_dimension_shop_test.dart              # end-to-end conversation tracer
test/result_card_test.dart                     # card/tone/repair/action behavior
```

The existing `test/four_beat_shop_test.dart` may be renamed to `test/six_dimension_shop_test.dart` once the new tracer replaces the old contract. Do not leave tests asserting obsolete four-step or delivery-before-result behavior.

---

## Ordered implementation tasks

### Task 1: Preserve v6 design sources and establish the new branch

**Objective:** Make the supplied v6 files reproducible repository references before translating them.

**Files:**
- Create: `docs/design/excuse-me-v6-design-and-conversation-spec.md`
- Create: `docs/design/excuse-me-v6-developer-handoff.html`
- Create: `.hermes/plans/2026-09-05_152842-excuse-me-v6-mobile-implementation.md`

**Steps:**

1. Copy the two supplied files byte-for-byte into `docs/design/`.
2. Record SHA-256 values for the two source copies and confirm the copies are unchanged.
3. Create a new implementation branch from `feat/complete-excuse-shop-journey`, for example `feat/excuse-me-v6-shop-experience`.
4. Keep this plan linked from the branch/PR description when the implementation begins.

**Verification:** Source hashes match their attachments; no production code changes are included in this task.

---

### Task 2: Replace the old damage catalog with six typed conversation dimensions

**Objective:** Make every user choice a typed v6 option, with no semantic parsing from labels.

**Files:**
- Modify: `lib/domain/shop_selection.dart`
- Modify: `lib/domain/excuse_request.dart`
- Modify: `lib/domain/excuse_kernel.dart` only where timing/output capability types require it
- Test: `test/shop_flow_model_test.dart`
- Update: `test/fixtures/generation_cases.v1.json` and dependent engine tests

**Required model:**

- `ShopIntentOption`: `id`, localization key, `ExcuseIntent`.
- `ShopActionOption`: `id`, localization key, parent intent, `ExcuseAction`.
- `ShopContextOption`: `id`, localization key, `ExcuseContext`.
- `ShopTimingOption`: `id`, localization key, `ExcuseTiming`.
- `ShopRelationshipOption`: `id`, localization key, `RelationshipKind`.
- `ShopObligationOption`: `id`, localization key, `ObligationLevel`.
- A pure `requestForV6Selections(...)` constructor that accepts the six typed values and applies the automatic timing value when the action is `explainMissedCommitment`.

**Semantic migration:**

- Add explicit timing values for `happeningNow` and `alreadyHappened`, or define a documented compatibility mapping from the current `alreadyLate`/`alreadyMissed` values. Prefer the v6 semantic names in the user-facing model and update kernel compatibility sets deliberately.
- Remove tone from the semantic six-dimension traversal. If the existing engine contract needs a compatibility tone, make it an explicit presentation/default field and exclude it from the base kernel-selection key; do not let a default tone silently exclude a kernel.
- Keep the legacy `ShopMission`, `ShopSituation`, and old option exports only until all callers migrate, then delete them in a cleanup task.

**RED tests:** Assert catalog sizes, parent-intent filtering, the complete typed request, context-before-timing order, conditional timing choices, and automatic timing for missed commitments.

**GREEN implementation:** Add the smallest typed catalog and mapper that satisfies those tests.

**Verification:** Focused model tests pass; no option label is parsed back into a domain enum.

---

### Task 3: Separate base kernel selection from post-result tone transformation

**Objective:** Ensure changing tone never changes the selected family or kernel ID.

**Files:**
- Modify: `lib/domain/excuse_request.dart`
- Modify: `lib/domain/excuse_kernel.dart`
- Modify: `lib/services/local_excuse_engine.dart`
- Modify: `lib/services/idea_client.dart`
- Modify: `lib/data/curated_kernel_repository.dart` only for explicit compatibility metadata
- Create: `test/tone_transformation_test.dart`
- Update: `test/idea_client_test.dart`, `test/local_excuse_engine_test.dart`, `test/m1_2_excuse_system_test.dart`

**Required behavior:**

1. Base selection filters safety and all six semantic dimensions, ranks families, and selects exactly one stable kernel ID.
2. Result metadata contains stable kernel ID, family, playful name, placeholder status, and available tone variants/capabilities.
3. Selecting a post-result tone renders a variant of the same kernel or a clearly labeled placeholder fallback; it never calls the kernel selector with a different semantic request.
4. Tone eligibility follows the v6 rules:
   - Formal or high obligation: Low-key, Nice.
   - Medium obligation: Low-key, Nice, Funny.
   - Low-obligation Social and non-Formal: all available tones.
   - Other: Low-key, Nice, Funny.
5. The local engine remains deterministic for the same six-dimension request and regeneration still excludes the previous kernel ID.

Do not copy the HTML’s example wording into the curated repository unless separately approved. Keep the existing placeholder safety and quality policy active.

**RED tests:** Generate one request, change tone repeatedly, and assert stable kernel ID/family; assert eligible-tone sets; assert formal/high-obligation suppression; assert placeholder safety.

**GREEN implementation:** Split kernel selection from tone rendering with a typed result capability. Preserve the existing `IdeaClient.generate` compatibility path for old fakes where possible.

**Verification:** Focused tone/engine tests pass, then all existing local engine and privacy tests pass.

---

### Task 4: Add the v6 flow controller and presentation randomizer

**Objective:** Centralize semantic navigation, history, randomized copy, and transition cancellation.

**Files:**
- Create: `lib/domain/shop_flow.dart`
- Create: `lib/ui/shop_flow_controller.dart`
- Create: `lib/ui/shop_presentation.dart`
- Test: `test/shop_flow_controller_test.dart`
- Test: `test/shop_presentation_test.dart`

**Controller state:**

```text
entry
intent
action
context
timing
relationship
obligation
search
handover
result
error
```

The controller owns selected typed options, the six-dimension request, result, history, current mood/event, outfit, opening pair, search line/motion, handover line/motion, selected tone, and a monotonically increasing session epoch.

**Presentation randomizer:**

- Inject `Random` in tests; use a production random source in the app.
- Store opening pairs as paired copy IDs, never as independently randomized sentences.
- Avoid immediate repeats for outfit, search line, handover line, and strange event where alternatives exist.
- Choose search line and search motion independently; choose handover line and handover motion independently.
- Keep all random presentation state out of `ExcuseRequest.selectionKey` and kernel selection.

**Transition rules:**

- Intent → Action.
- Action → Context using only actions valid for the selected intent.
- Context → Timing except missed commitment, which sets `alreadyHappened` and proceeds to Relationship.
- Timing → Relationship.
- Relationship → Obligation.
- Obligation → Search; no further question.
- Search/handover increments and captures the session epoch. Any delayed callback checks that epoch before mutating state.
- Back returns to the prior semantic question and clears only later selections. Back and Restart are disabled during search/handover.
- Restart creates a new opening/outfit and clears all semantic and result state.

**RED tests:** Test every branch, automatic timing, back restoration, restart reset, no-repeat invariants with a seeded RNG, and stale callback rejection after restart.

**GREEN implementation:** Implement the smallest controller and randomizer with no Flutter rendering dependencies.

**Verification:** Pure controller/randomizer tests pass independently of widget layout.

---

### Task 5: Translate the HTML shop into a full-viewport Flutter scene

**Objective:** Make the shop itself the visual product surface rather than a clean form with pixel decoration.

**Files:**
- Create: `lib/ui/shop_scene.dart`
- Create: `lib/ui/shop_scene_painter.dart`
- Create: `lib/ui/shop_curiosity_painter.dart`
- Create: `lib/ui/shop_excusee_painter.dart`
- Create: `lib/ui/shop_event_layer.dart`
- Modify: `lib/ui/shop_theme.dart`
- Modify: `pubspec.yaml` only if new local runtime assets/fonts are approved
- Test: `test/shop_scene_test.dart`
- Update: `test/design_system_test.dart`

**Scene composition:**

- Pixel wall, arch, beams, lamps, floor, rug, counter, sign, shelves, charms, mist, dust, and dense non-repeating curiosities.
- Curiosity pool includes bottles, eye jars, keys, masks, clocks, skull-like relics, crystals, cages, plants, mushrooms, books, scrolls, teeth, feathers, orbs, devices, and card stacks.
- `CustomPainter` uses integer-friendly grid coordinates and the v6 tokens; static environment is separate from transient event animation.
- `ShopExcuseePainter` draws the same wizard silhouette with outfit palette tokens for Storm scholar, Amethyst dealer, Moss keeper, Ember archivist, and Midnight broker. Use the v6 inline SVG as the geometry reference, translated to a local painter or deterministically rasterized local assets; do not fetch artwork at runtime.
- Ambient mood is a scene-local palette: violet, teal, ember, blue, gold, void. It changes visual feedback only and cannot alter semantic selection.
- The scene is `Semantics`-labeled as the Excuse shop; decorative curiosities and effects are excluded from the accessibility traversal.

**Responsive rules:**

- Scene fills the available upper viewport and respects SafeArea boundaries.
- Mobile HUD is vertically scrollable without making the scene or primary action unreachable.
- Preserve normal v6 dimensions at normal height; provide a compact-height path rather than shrinking all text.
- Do not use a clean `AppBar` during the core shop interaction. Back and Restart belong to the HUD.

**RED tests:** Assert scene keys, owner semantics, local sprite/painter presence, six counter token placeholders, and no conventional progress-bar widget. Exercise normal and short viewports.

**GREEN implementation:** Build the static scene and dynamic mood/outfit/event inputs, then add transient effects.

**Verification:** Widget structure, semantics, light/dark chrome, and compact-height tests pass. Visual simulator review is required later; code/tests alone do not close the visual gate.

---

### Task 6: Implement the v6 Conversation HUD and six physical progress tokens

**Objective:** Render the exact v6 dialogue and choices with readable language typography and stable semantics.

**Files:**
- Create: `lib/ui/conversation_hud.dart`
- Modify: `lib/ui/excuse_shop_page.dart`
- Modify: `lib/l10n/app_en.arb`
- Regenerate: `lib/l10n/app_localizations.dart`, `lib/l10n/app_localizations_en.dart`
- Update: `test/localization_test.dart`, `test/excuse_shop_test.dart`

**Copy to implement:**

- Entry: randomized curated opening pair plus `I NEED AN EXCUSE`.
- Intent: `Now then… what's the situation?` with `I NEED OUT`, `I NEED MORE TIME`, `I ALREADY MESSED UP`.
- Action: exact contextual questions and choices from v6.
- Context: `What kind of thing is it?` with `SOCIAL`, `PERSONAL`, `WORK / STUDY`, `PRACTICAL`.
- Timing: exact action-specific questions and choices; skip missed commitment timing.
- Relationship: `Alright. Who are we dealing with?`.
- Obligation: `How much trouble if you vanish?`.
- Search/handover copy from curated local pools.

Use localization keys for all copy and semantics. Keep `EXCUSEE` as the pixel-layer speaker label and `Excusee` in prose/accessibility labels.

**Progress:** Render six counter tickets/tokens for Intent, Action, Context, Timing, Relationship, Obligation. When timing is automatic, its token becomes complete even though no timing question was shown. Do not render a visible linear progress bar or `Step n of 4` text.

**Interaction:** Every choice is at least 44 px, targeting approximately 48 px. Use stable keys based on option IDs and clear semantic labels. `ensureVisible` and scroll-frame pumps must be included in widget tests.

**RED tests:** Assert exact v6 questions/labels, contextual action/timing branches, automatic timing, no old four-step copy, no free-form field, semantics, and physical token behavior.

**GREEN implementation:** Wire the HUD to the controller and typed option catalogs.

**Verification:** Localization generation succeeds; focused and full widget tests pass.

---

### Task 7: Implement ambient reactions, search, and handover choreography

**Objective:** Turn the final choice into a short physical shop event rather than a loading spinner.

**Files:**
- Modify: `lib/ui/shop_flow_controller.dart`
- Modify: `lib/ui/shop_scene.dart`
- Modify: `lib/ui/shop_event_layer.dart`
- Modify: `lib/ui/excuse_shop_page.dart`
- Test: `test/shop_scene_test.dart`
- Test: `test/shop_flow_controller_test.dart`

**Required choreography:**

- Every semantic selection triggers an ambient color transition and one strange event.
- Event pool: eye opens, book levitates, clock spins, bottles rattle, key moves, cage flashes, portal flickers, shadow crosses, moths/dust, sign glitches, crystals/orbs flare.
- On Obligation completion, enter Search with one curated search line, one independently chosen search motion, one event, and void/dark mood.
- Keep total search/handover beat approximately 1–2 seconds, using bounded animations rather than a spinner.
- Select the family mood only after the result kernel is selected, before the handover card settles.
- Select handover line and handover motion independently.
- Back and Restart are disabled during this short irreversible transition; reduced motion removes choreography/delays while preserving search/handover state text and final card.
- Use a session epoch/cancellation token so Restart cannot be overwritten by a late callback.

**RED tests:** Assert event/mood changes after choices, no immediate event/copy repeats with seeded randomness, search state has no spinner-only contract, controls are locked during transition, reduced motion reaches the result immediately, and stale callbacks are ignored.

**GREEN implementation:** Use small `AnimationController`/`AnimatedBuilder` boundaries or equivalent Flutter primitives; avoid a global animation controller and avoid animating semantic text for decoration.

**Verification:** Widget motion-boundary tests pass. Later simulator review must inspect the full moving flow, not only screenshots.

---

### Task 8: Replace the result surface with the v6 card, tone controls, repair, and bounded actions

**Objective:** Make the result a handed-over collectible artifact with post-result tone transformation.

**Files:**
- Create: `lib/ui/result_card.dart`
- Modify: `lib/ui/excuse_shop_page.dart`
- Modify: `lib/l10n/app_en.arb`
- Update: `test/result_card_test.dart`
- Update: `test/repair_direction_test.dart`
- Update: `test/excuse_shop_test.dart`

**Card structure:**

- Pixel wrapper with 6–7 px outline at reference scale.
- Violet header with playful name and rarity.
- Paper art panel with a family-specific local illustration/symbol.
- Paper body with `THE IDEA` and one concise atomic idea/direction.
- Divider, family tag, selected tone tag, and card number.
- Optional repair section derived only from the typed request and result metadata.
- No message bubble styling.
- Primary actions must be artifact-oriented: another card/regenerate, keep/finish, and new session. Copy/share cannot dominate the result.

**Tone behavior:**

- Tone buttons appear only after the card exists.
- Buttons use the pure v6 eligibility function.
- Changing tone updates the same card/kernel and does not re-run semantic selection.
- Tone changes are accessible as selected buttons and preserve the atomic idea boundary.

**Reveal:**

- Card handover and card reveal use one bounded stepped transition vocabulary.
- Reduced motion uses zero-duration/static composition.
- The card must remain reachable at short height and large text scaling.

**RED tests:** Assert exact card structure, stable kernel ID across tone changes, tone eligibility, conditional repair, no primary send/share/copy, result action semantics, reveal in-progress/completed states, and result recovery/error behavior.

**GREEN implementation:** Build `ResultCard` against the rich result boundary, then connect controller actions.

**Verification:** Result-card, repair, reduced-motion, short-height, and accessibility tests pass.

---

### Task 9: Migrate and clean the root page

**Objective:** Reduce `ExcuseShopPage` to composition and lifecycle, eliminating stale four-step logic.

**Files:**
- Modify: `lib/ui/excuse_shop_page.dart`
- Modify: `lib/app.dart` only if the v6 shell needs a different background/theme mode
- Modify: `lib/main.dart` only if dependency injection needs the controller/random source
- Delete or retire: obsolete private painters and old four-step render helpers after callers migrate
- Update: `test/widget_test.dart`, `test/analytics_widget_test.dart`, `test/excuse_shop_test.dart`

**Required root responsibilities:**

- Provide `LocalIdeaClient` and no-op analytics.
- Create/dispose the controller and animation resources.
- Compose `ShopScene`, `ConversationHUD`, and `ResultCard`.
- Forward allowlisted analytics events only; never pass selection text, request payloads, result text, random presentation state, or identifiers.
- Preserve inline error recovery and new-session behavior.

**Verification:** No old `damage`, `audience`, `delivery`, `Step 1 of 4`, or pre-result tone flow remains in production UI. Existing fake `IdeaClient` implementations continue to compile or are migrated explicitly.

---

### Task 10: Complete regression, accessibility, and offline verification

**Objective:** Prove the v6 journey on the available Linux toolchain before Mac handoff.

**Files:**
- Update/add all focused tests above.
- Update: `test/offline_architecture_test.dart`
- Update: `test/release_signing_config_test.dart` only if asset/config changes touch its invariants.
- Update: repository design/source documentation if new runtime asset provenance is added.

**Test matrix:**

- Intent/action/context/timing/relationship/obligation branches.
- Automatic timing for missed commitments.
- Back from every question and result.
- Restart from entry and during/after search.
- Search/handover error and stale callback behavior.
- Base selection determinism and regeneration exclusion.
- Tone transformation keeps kernel/family stable.
- Repair only when warranted.
- Reduced motion.
- Normal height, short height, RTL safety, and 1.3x/2x/3x text scaling.
- Semantics labels, focus order, touch target reachability, and no free-form text input.
- No network permission/runtime dependency; no situation/generated-content analytics payload.
- Local artwork/font packaging and exact source-copy checks.

**Commands:**

```bash
cd /opt/data/work/excuse-me
DART=/opt/data/flutter/bin/dart
FLUTTER=/opt/data/flutter/bin/flutter
"$DART" format lib test
"$FLUTTER" test
"$FLUTTER" analyze
"$FLUTTER" build web --release --no-wasm-dry-run
git diff --check
```

A web build verifies compilation and asset packaging only. It does not replace iOS simulator or physical-device validation.

---

### Task 11: Mac/Xcode handoff and visual motion gate

**Objective:** Validate the actual mobile artifact on Mr. Achkar’s Mac after the implementation branch is pushed.

**Preparation on Linux:**

- Push the v6 implementation branch only after automated gates pass.
- Provide exact branch name, commit SHA, and checkout commands.
- Do not configure Apple signing or claim iOS execution from Linux.

**First Mac checkpoint:**

```bash
cd /path/to/excuse-me
git fetch origin
git switch --track origin/feat/excuse-me-v6-shop-experience
flutter pub get
open ios/Runner.xcworkspace
```

Run in the iOS Simulator first. Physical iPhone testing requires Mr. Achkar’s local Apple team/signing configuration in Xcode and is a separate gate.

**Simulator review:**

- Fresh entry and restart produce a changed outfit/opening without immediate repetition.
- Every six-dimension branch is exercised.
- Context appears before timing.
- Missed commitment skips timing and still fills the timing token.
- Ambient events visibly react to selections.
- Search and handover feel like a 1–2 second shop action, not a spinner.
- Tone changes preserve the same card/kernel.
- Repair appears only when warranted.
- Back/restart behavior is correct, including transition lock.
- Light/dark chrome, safe areas, Dynamic Island/home indicator, short height, Dynamic Type XL, VoiceOver, and Reduce Motion are checked.
- Record the full moving flow in a release build; screenshots alone do not prove motion quality.

Overall release validation remains blocked until required Android and iOS device evidence exists.

---

## Acceptance criteria

The v6 implementation is complete only when all are true:

- [ ] The exact v6 source artifacts are preserved in the repository.
- [ ] The user-facing traversal is Intent → Action → Context → Timing → Relationship → Obligation.
- [ ] Action and timing are context-sensitive; missed commitment timing is automatic.
- [ ] The user never chooses an excuse family.
- [ ] Tone is post-result and cannot change kernel/family selection.
- [ ] The whole interaction is a dense, reactive pixel curiosity shop.
- [ ] Excusee has the five non-repeating outfit palettes.
- [ ] Opening pairs, search lines/motions, handover lines/motions, and strange events are curated and no-immediate-repeat randomized.
- [ ] Semantic state is separated from presentation randomness.
- [ ] Six physical progress tokens are used instead of a conventional progress bar.
- [ ] Search/handover is a bounded physical scene beat with safe cancellation.
- [ ] Result card has the specified pixel/paper structure and optional repair.
- [ ] Atomic idea and placeholder/safety boundaries remain intact.
- [ ] All controls have accessible labels and minimum touch targets.
- [ ] Reduced motion, short screens, large text, RTL, errors, back, restart, and regeneration are tested.
- [ ] No runtime network dependency or sensitive analytics payload is introduced.
- [ ] `flutter test`, `flutter analyze`, web build, formatting, and diff checks pass.
- [ ] Mac/Xcode simulator validation is performed before calling the mobile slice ready.
- [ ] Physical Android/iOS release validation remains explicitly separate and fail-closed.

---

## Resolved product decisions

1. **Typography:** Bundle exact `Press Start 2P` and `Inter Tight` font files in the offline app. Fonts are build-time/local assets only; the runtime must not fetch Google Fonts.
2. **Content:** Treat the example kernel and tone wording embedded in the supplied HTML as the initial production content. Preserve the atomic-idea boundary and run the existing safety policy; these remain idea directions, not ready-to-send messages.
3. **Card action:** Implement `KEEP CARD` as a temporary local visual confirmation (`KEPT`) with no persistence. Collection/history remains a later slice.
