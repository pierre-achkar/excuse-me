# Excuse Me — Core Shop Conversation & Interaction Specification v6

Status: developer handoff for the mobile implementation.

This document combines the current M1.2 decision model with the agreed pixel-shop design direction and the refined Excusee conversation.

---

## 1. Product idea

The user does **not** fill out a form. They enter a strange pixel curiosity shop and speak with **Excusee**, the shopkeeper.

The functional model remains structured and deterministic, but the user experiences it as a short conversation:

```text
Enter shop
   ↓
Intent
   ↓
Action
   ↓
Context
   ↓
Timing
   ↓
Relationship
   ↓
Obligation
   ↓
Excusee searches the shop
   ↓
Family + kernel selected internally
   ↓
Excusee hands over one card
```

The user never chooses an excuse family directly.

The output is one **atomic excuse idea**, not a ready-to-send message.

---

## 2. Character

### Name

The shop owner is always called:

```text
EXCUSEE
```

Use `Excusee` in prose and accessibility labels.

### Character tone

Excusee is:

- relaxed;
- dry;
- slightly mysterious;
- amused but not mocking;
- helpful without celebrating deception;
- concise.

He should sound like someone who has seen this kind of social trouble many times.

### Visual character direction

Excusee is an old wizard/curiosity-shop merchant:

- oversized crooked hat;
- long beard;
- partly obscured face;
- robe with patches and trim;
- staff, lantern, card or other merchant prop;
- friendly-mysterious, never horror.

On every fresh entry or restart, use a different clothing palette while preserving the same silhouette and identity.

Current outfit presets:

1. Storm scholar
2. Amethyst dealer
3. Moss keeper
4. Ember archivist
5. Midnight broker

Do not repeat the immediately previous outfit when alternatives exist.

---

## 3. Conversation order

The final agreed order is:

```text
Intent → Action → Context → Timing → Relationship → Obligation
```

Context is intentionally moved before timing because it is fundamental to understanding the situation.

Obligation is the last question because it acts as Excusee's final calibration before choosing a card.

---

# 4. Screen-by-screen conversation

## 4.1 Shop entry

The opening is randomized on every fresh entry or restart.

Opening text must be stored as **curated pairs**. Do not randomize the first and second sentence independently.

Examples:

| Main line | Supporting line |
|---|---|
| Well, well. What happened? | Let's see what I've got for you. |
| Back again? What happened? | I might have something for you. |
| Oh. You've got that look. What happened? | Let's see what we can find. |
| Hmm. Trouble? | I may have just the thing. |
| Come in, come in. What happened? | Let's find you something. |
| Well, this looks promising. What happened? | I'm sure I've got something around here. |
| Alright. What happened this time? | Let's have a look at the shelves. |
| You look like you need something. | Tell me just enough. I'll do the digging. |

Primary action:

```text
I NEED AN EXCUSE
```

This button stays direct. Excusee carries the personality; user choices should prioritize clarity.

---

## 4.2 Intent

### Excusee

> **Now then… what's the situation?**

### Choices

| Display text | Internal value |
|---|---|
| I NEED OUT | Get out of plans |
| I NEED MORE TIME | Buy time |
| I ALREADY MESSED UP | Recover from a situation |

---

## 4.3 Action

The leading question must change based on Intent.

### If `Get out of plans`

Excusee:

> **Ah. An escape. What's the plan?**

Choices:

| Display | Internal |
|---|---|
| Cancel something | Cancel |
| Say no | Decline |
| Leave early | Leave early |
| Back out | Back out |

### If `Buy time`

Excusee:

> **Buying some time, are we? How?**

Choices:

| Display | Internal |
|---|---|
| Move it to another time | Reschedule |
| Delay it | Delay |
| Don't commit yet | Avoid committing |

### If `Recover from a situation`

Excusee:

> **Ah. Damage already done. What happened?**

Choices:

| Display | Internal |
|---|---|
| I'm late | Explain lateness |
| I didn't show | Explain absence |
| I missed it completely | Explain missed commitment |

---

## 4.4 Context

### Excusee

> **What kind of thing is it?**

### Choices

| Display | Internal |
|---|---|
| SOCIAL | Social |
| PERSONAL | Personal |
| WORK / STUDY | Work or Study |
| PRACTICAL | Practical |

Context is deliberately simple. Do not add playful wording to both the question and labels.

---

## 4.5 Timing

Timing choices depend on Action.

### Standard future actions

Applies to:

- Cancel
- Decline
- Back out
- Reschedule
- Delay
- Avoid committing

Excusee:

> **Alright. How close are we cutting it?**

Choices:

| Display | Internal |
|---|---|
| PLENTY OF TIME | In advance |
| IT'S TODAY | Today |
| LAST MINUTE | Last minute |

### Leave early

Excusee:

> **Planning your escape, or already there?**

Choices:

| Display | Internal |
|---|---|
| PLANNING AHEAD | In advance |
| I'M THERE NOW | Happening now |

### Explain lateness / explain absence

Excusee:

> **And when did this go wrong?**

Choices:

| Display | Internal |
|---|---|
| RIGHT NOW | Happening now |
| ALREADY HAPPENED | Already happened |

### Explain missed commitment

There is no timing question.

Set:

```text
timing = Already happened
```

automatically and continue to Relationship.

Never ask a question when the model already knows the only possible answer.

---

## 4.6 Relationship

### Excusee

> **Alright. Who are we dealing with?**

### Choices

| Display | Internal |
|---|---|
| SOMEONE CLOSE | Close |
| SOMEONE I KNOW | Casual |
| SOMEONE FORMAL | Formal |

---

## 4.7 Obligation

This is the final question.

### Excusee

> **How much trouble if you vanish?**

### Choices

| Display | Internal |
|---|---|
| BARELY ANY | Low |
| THEY'LL NOTICE | Medium |
| QUITE A LOT | High |

The answer changes family/kernel eligibility and repair priority.

---

# 5. Search sequence

After Obligation, there are no more questions.

Excusee switches from conversation to physical action inside the shop.

## Random search lines

Use a curated random pool such as:

- Don't touch anything.
- Stay right there.
- Hmm... I know I've got one somewhere.
- Give me a second.
- Ah. I think I know just the thing.
- Wait here.
- Let me check the back.

Avoid immediately repeating the same search line across sessions where possible.

## Random search animations

Pick one independently:

1. Excusee turns his back and searches a shelf.
2. Excusee briefly disappears into the back room.
3. Excusee ducks behind the counter.
4. Excusee rummages left/right behind the counter.

At the same time:

- trigger one strange shelf/background event;
- temporarily shift ambient color;
- allow the shop to settle into the selected family's mood before the card appears.

Suggested duration: approximately 1–2 seconds total.

This is an experience beat, not a loading spinner.

---

# 6. Handover sequence

Excusee reappears/turns around with the selected card.

## Random handover lines

Use a curated pool:

- This should do.
- Here. Try this one.
- Ah. There we are.
- Found you something.
- This one should fit.
- Handle with care.
- Use it wisely.
- I think this one's yours.
- Here you go.
- That'll do nicely.

Avoid immediate repetition.

## Random card handover motion

Possible variants:

- slide across counter;
- float briefly toward the user;
- extend/offer forward;
- small stepped drop/flick onto the counter.

The line and animation are selected independently.

---

# 7. Shop visual system

## Two-layer rule

### Pixel layer

Used for:

- shop scene;
- Excusee;
- shelves and curiosities;
- dialogue frame;
- excuse card wrapper;
- card name, rarity and tags;
- environmental effects.

### Clean language layer

Used for:

- actual dialogue text;
- atomic excuse text;
- later collection/settings/detail screens.

The shop is not a clean app with pixel decoration. During generation, the **whole viewport is the shop**.

---

# 8. Core design tokens

## Pixel world

| Token | Hex | Use |
|---|---|---|
| Violet | `#7F5BD6` | Primary magical accent, card header |
| Violet dark | `#6144B8` | Shadow/shading |
| Teal | `#3FB6A0` | Secondary magical accent, family tag |
| Glow | `#FCDE5A` | Lamps, eyes, rarity, magical highlights |
| Ember | `#E8593C` | Warnings, hot accents |
| Outline | `#1A1622` | Pixel outlines |

The current shop intentionally uses brighter derived variants during ambient mood shifts.

## Card paper

| Token | Hex |
|---|---|
| Body | `#FAEEDA` |
| Art panel | `#EDEAE2` |
| Divider | `#DCD2B8` |
| Meta | `#8A7B5E` |
| Skin | `#F0C08A` |

## Typography

### Press Start 2P

Use only for short pixel-layer labels:

- speaker label;
- card name;
- rarity;
- family/tone tags;
- tiny status text.

Do not use for real sentences.

### Inter Tight

Use for:

- Excusee's dialogue;
- choices;
- atomic excuse;
- all substantial language.

Weights: 400 and 500 only.

---

# 9. Shop environment

The shop should feel dense, bright, strange and alive.

Shelves should contain many non-repeating curiosities:

- bottles;
- jars with eyes;
- keys;
- masks;
- clocks;
- skull-like relics;
- crystals;
- cages;
- plants;
- mushrooms;
- books;
- scrolls;
- teeth;
- feathers;
- orbs;
- odd devices;
- stacked cards.

The goal is a **curiosity shop**, not decorative shelves.

---

# 10. Reactive environment

Every user selection should trigger two things:

1. a brief ambient color transition;
2. one strange environmental event.

Current event pool:

- eye in jar opens;
- book levitates;
- clock spins;
- bottles rattle;
- key moves;
- cage flashes;
- portal flickers;
- shadow crosses room;
- moths/dust cross scene;
- sign glitches;
- crystals/orbs flare.

Avoid predictable event order and immediate repetition.

## Example mood mapping

| Selection type | Example mood |
|---|---|
| Need out | Violet |
| Need more time | Teal |
| Already messed up | Ember |
| Someone close | Gold |
| Someone formal | Blue |
| High obligation | Ember |
| Social | Violet |
| Personal | Gold |
| Work / study | Teal |
| Practical | Blue |
| Search | Void/dark |
| Result | Selected family mood |

These colors are experiential feedback. They do not change the semantic model.

---

# 11. Progress

Do not show a conventional progress bar.

Progress should exist as physical objects accumulating on the counter.

There are six model dimensions:

```text
Intent
Action
Context
Timing
Relationship
Obligation
```

If Timing is automatically resolved, its counter token should still appear as completed.

---

# 12. Result card

The card remains the central artifact.

Structure:

```text
┌────────────────────────────────┐
│ playful name          [rarity] │
├────────────────────────────────┤
│                                │
│       pixel illustration       │
│                                │
├────────────────────────────────┤
│ THE IDEA                       │
│ Atomic excuse idea             │
│                                │
│ ────────────────────────────── │
│ [family] [tone]       no. 014  │
└────────────────────────────────┘
```

Rules:

- outer border: 6–7px pixel outline;
- width at reference size: ~300px;
- atomic idea uses Inter Tight;
- idea must remain concise;
- family is internal but may appear as a card type/tag;
- rarity is independent of appropriateness or tone;
- no message-bubble styling;
- no primary send/share/copy action.

---

# 13. Tone after the result

Tone is **not part of the six-question traversal**.

It is a post-result transformation of the same kernel.

Examples:

```text
Low-key
Nice
Funny
Dramatic
Unhinged
```

Only show tones appropriate to the situation.

Suggested eligibility:

- Formal or High obligation → Low-key, Nice
- Medium obligation → Low-key, Nice, Funny
- Low-obligation Social and non-Formal → all tones
- Other → Low-key, Nice, Funny

Changing tone must not silently change the underlying excuse family/kernel.

---

# 14. Repair

Repair is not asked as a question.

Surface it on the result only when warranted.

Examples:

- High obligation → acknowledge inconvenience + concrete next step.
- Recover-from-a-situation → own the miss briefly + smallest useful repair.
- Last-minute + medium obligation → brief apology, no extra story.

Repeated failures should favor repair rather than escalating the excuse.

---

# 15. Internal request model

The UI should produce this model:

```text
intent
action
context
timing
relationship
obligation
```

Example:

```json
{
  "intent": "Get out of plans",
  "action": "Cancel",
  "context": "Social",
  "timing": "Today",
  "relationship": "Close",
  "obligation": "Medium"
}
```

The engine then:

```text
1. filters unsafe/incompatible kernels
2. ranks excuse families
3. ranks compatible kernels inside those families
4. selects exactly one kernel
5. returns one atomic idea
6. optionally returns a repair direction
```

The user never sees family selection as a question.

---

# 16. Mobile implementation notes

The supplied HTML is a behavioral/reference prototype, not production architecture.

For Flutter, split the implementation roughly into:

```text
ShopScene
 ├─ BackWall / Arch
 ├─ ShelfLayer
 ├─ CuriosityProps
 ├─ AmbientEffects
 ├─ ExcuseeSprite
 ├─ Counter
 └─ CardRevealLayer

ConversationHUD
 ├─ SpeakerLabel
 ├─ DialogueText
 ├─ ChoiceGrid
 └─ Back / Restart controls

ShopFlowController
 ├─ ExcuseRequest state
 ├─ currentStep
 ├─ history
 ├─ copy randomization
 ├─ outfit randomization
 ├─ environmental event randomization
 └─ family/kernel request

ResultCard
 ├─ CardHeader
 ├─ Illustration
 ├─ AtomicIdea
 ├─ FamilyTag
 ├─ ToneTag
 ├─ Number
 └─ OptionalRepair
```

Recommended implementation rule:

**Keep semantic state separate from presentation randomness.**

For example:

```text
semantic:
  action = Cancel

presentation:
  ambient_event = eye_opens
  mood = violet
  Excusee_outfit = moss_keeper
  search_line = "Don't touch anything."
```

A random shop event must never alter which kernel is selected.

---

# 17. Accessibility and motion

- Minimum touch target: 44px; primary choices target ~48px.
- Real language must remain readable; do not put dialogue in the pixel font.
- Respect `prefers-reduced-motion`.
- Reduced motion removes glitches, levitation, camera bumps and search choreography; state changes remain clear through color/static composition.
- Every choice must have a clear text label; environmental animation is supplementary.
- Back and restart must always be available except while the short search/handover transition is actively running.

---

# 18. Safety constraints

- Output one idea, not a ready-to-send message.
- Do not invent names, locations, diagnoses, deaths, emergencies or evidence.
- No fake screenshots, call logs or notifications.
- No primary send/share/copy behavior.
- Absurd/dramatic content must stay clearly playful and low-stakes.
- High-obligation/formal scenarios suppress socially risky options.
- Repeat failures trigger repair-oriented behavior rather than stronger excuses.

---

# 19. Prototype behavior covered by the HTML

The accompanying HTML demonstrates:

- dense curiosity-shop environment;
- random Excusee outfit on entry/restart;
- randomized curated opening pair;
- revised six-layer order;
- contextual Action dialogue;
- Context before Timing;
- contextual Timing dialogue;
- automatic timing skip for missed commitments;
- revised Relationship and Obligation language;
- one random strange event per selection;
- ambient color changes per selection;
- randomized search line;
- randomized Excusee search motion;
- family/kernel selection;
- randomized handover line;
- randomized card handover animation;
- optional post-result tone;
- conditional repair;
- back/restart behavior;
- reduced-motion fallback.

---

## Final locked core flow

```text
EXCUSEE
randomized opening
        ↓
[I NEED AN EXCUSE]
        ↓
"Now then… what's the situation?"
        ↓
Intent
        ↓
context-specific Action question
        ↓
Action
        ↓
"What kind of thing is it?"
        ↓
Context
        ↓
context-specific Timing question
        ↓
Timing
        ↓
"Alright. Who are we dealing with?"
        ↓
Relationship
        ↓
"How much trouble if you vanish?"
        ↓
Obligation
        ↓
randomized search line + animation
        ↓
internal family/kernel selection
        ↓
randomized handover line + animation
        ↓
ONE EXCUSE CARD
```
