# Excuse Me — Design System v1

Companion to M1.2 (linguistic and social structure of excuse ideas). This document covers visual and interaction design only. It assumes the M1.2 functional model as given.

Status: agreed in session. Character sprite direction locked, palette derived from it, card layout locked. Screen-level layouts for collection and settings still open.

---

## 1. Product principles

Three constraints drive every decision below.

**The output is a seed, not a message.** M1.2 specifies one atomic claim, deliberately incomplete, which the user rephrases in their own voice. Nothing in the UI may look like a finished, sendable message — no send button, no message bubble, no copy-to-clipboard as the primary action. The card is an object you own, not a text you dispatch.

**Reduce shame, don't amplify it.** The user arrives mid-guilt. A blank "explain why you're bailing" text field makes them stare at their own excuse-making. Everything is tap-based; the app never asks them to type a justification. Playfulness is the shame-reduction mechanism: a toy reads as lower stakes than a tool.

**Short, self-contained sessions.** Enter, four taps, receive card, leave. No lingering task, no inbox, no streak pressure. The collection is browsable outside a session but never nags.

---

## 2. The flow

```
  shop entry
      │
      ▼
  4-beat dialogue with the owner
      │   beat 1  situation   → intent, action, context, obligation
      │   beat 2  timing      → timing
      │   beat 3  who         → audience and relationship
      │   beat 4  tone        → channel and tone
      ▼
  card reveal  (atomic claim + optional repair)
      │
      ▼
  exit — session ends

  collection  ← opened independently, any time
```

### Why four beats, not eight

M1.2 defines eight input dimensions. Asking each one separately would make a form in costume. Several dimensions are not independent: choosing "a dinner I can't face" simultaneously fixes intent, action, context and obligation. So one tap fills a cluster.

| Beat | Question | M1.2 fields filled |
|---|---|---|
| 1 | What's the damage? | Intent, Action, Context, Obligation |
| 2 | When's the reckoning? | Timing |
| 3 | Who's on the other end? | Audience and relationship |
| 4 | How loud do you want this? | Channel and tone |

That is seven of eight in four taps. The eighth, **repair preference**, is optional in M1.2 and does not get a beat. It surfaces on the card as an offered choice, and only when the situation warrants it (high obligation, or a repeat cancellation on the same person).

### Interaction rule: dialogue tree, not chat

The owner speaks one short line. The user taps one of 2–5 reaction chips. The owner reacts in character, then the next line appears. No free text input anywhere in the flow. This keeps it as fast as a form while reading as conversation.

---

## 3. The two-layer rule

The app has two visual registers, and the boundary between them is deliberate.

**Pixel layer — the shop scene and the cards.** 8-bit sprite art, hard dark outlines, flat saturated fills, chunky borders, pixel typeface for names and stamps. Glitch treatment (chromatic slices, scanline artifacts) belongs here and nowhere else.

**Clean layer — everything else.** Collection, card detail, settings, onboarding. Modern, quiet, generous whitespace, no pixel typeface, no glitch. Shares only the violet accent with the pixel layer.

Rationale: pixel art everywhere becomes wallpaper and stops being special. Confining it to the shop and the cards means the aesthetic marks the *moment of magic*, and the surrounding app stays legible and ages better.

Practical consequence: pixel art assets must never be scaled to non-integer multiples, and the pixel typeface is never used for anything longer than three words.

---

## 4. Color

### Pixel world — shop and cards

| Token | Hex | Use |
|---|---|---|
| `pixel.violet` | `#7F5BD6` | Owner cloak and hood, card header, primary pixel fill |
| `pixel.violet-dark` | `#6144B8` | Shading on violet, hood interior |
| `pixel.teal` | `#3FB6A0` | Cloak trim, family tag, secondary pixel fill |
| `pixel.glow` | `#FCDE5A` | Owner's eyes, cigarette ember highlight, rarity stamp text, sparkles |
| `pixel.ember` | `#E8593C` | Cigarette tip, warnings inside the pixel layer |
| `pixel.outline` | `#1A1622` | Every sprite outline, all pixel-layer text on light fills |

Discipline: sprites use these six and nothing else. New sprite work does not introduce new hues; it recombines these. `pixel.glow` is the scarcest — it marks the owner's eyes and the rarity stamp, so it must not appear as ordinary decoration.

### Paper — card surfaces

| Token | Hex | Use |
|---|---|---|
| `paper.body` | `#FAEEDA` | Card body behind the claim |
| `paper.panel` | `#EDEAE2` | Card art panel background, sprite sheet background |
| `paper.divider` | `#DCD2B8` | Card footer rule, 3px, hard edge |
| `paper.meta` | `#8A7B5E` | Collection number, small card labels |
| `paper.skin` | `#F0C08A` | Sprite skin tone only — never a UI surface |

### Clean chrome — collection, settings, onboarding

| Token | Hex | Use |
|---|---|---|
| `ui.canvas` | `#FBFAF7` | App background |
| `ui.surface` | `#FFFFFF` | Cards, sheets, rows |
| `ui.hairline` | `#E7E4DD` | Dividers, 1px |
| `ui.text-primary` | `#241F2E` | Headings and body |
| `ui.text-secondary` | `#6B6558` | Meta, counts, captions |
| `ui.accent` | `#7F5BD6` | The single shared token — buttons, active states, links |

`ui.accent` is intentionally identical to `pixel.violet`. It is the one thread stitching the two layers together, and the only accent in the clean layer.

### Dark mode

The clean layer inverts normally: canvas `#161320`, surface `#1F1B2A`, hairline `#2E2939`, primary text `#F4F1F6`, secondary `#A09AAF`, accent stays `#7F5BD6`. The pixel layer does **not** invert. Sprites and cards keep their own fixed colors in both modes, exactly as a physical trading card would; only the chrome around them changes.

### Contrast notes

- `pixel.outline` on `paper.body` — very high contrast, the card's workhorse pairing.
- `pixel.glow` on `pixel.outline` — passes for the rarity stamp at 9px because the stamp is short and always paired with its position and border.
- `pixel.outline` on `pixel.violet` — used for the card name; verified adequate. Never put `paper.meta` on `pixel.violet`.

---

## 5. Typography

Two families, sharply distinct by role.

**Press Start 2P** — pixel layer only. Card names, rarity stamps, family and tone tags. Never above 11px, never longer than three words, never for the claim itself. It carries the 8-bit register; used for anything substantial it becomes unreadable and childish.

**Inter Tight** — everything else, including inside the pixel layer wherever real language appears. The owner's dialogue, the reaction chips, the atomic claim, all clean-layer text.

The deliberate mix on the card — pixel name in the header, humane sans for the claim — is the system's signature. It says: the wrapper is a game, the content is real.

| Role | Family | Size / line-height | Weight |
|---|---|---|---|
| Card name | Press Start 2P | 11px / 1.5 | 400 |
| Rarity stamp | Press Start 2P | 9px / 1.4 | 400 |
| Family and tone tags | Press Start 2P | 8px / 1.4 | 400 |
| Owner dialogue | Inter Tight | 19px / 1.4 | 400 |
| The claim | Inter Tight | 16–18px / 1.45 | 400 |
| Reaction chips | Inter Tight | 14px / 1.3 | 400 |
| Chrome titles | Inter Tight | 20px / 1.3 | 500 |
| Chrome body | Inter Tight | 16px / 1.5 | 400 |
| Chrome meta | Inter Tight | 12px / 1.4 | 400 |

Weights are limited to 400 and 500. No bold anywhere — emphasis comes from size, color and the family switch.

Sentence case throughout, including tags and stamps. No all-caps labels.

---

## 6. Space, shape, border

Pixel layer and clean layer use different shape languages on purpose.

| Token | Pixel layer | Clean layer |
|---|---|---|
| Base unit | 4px, but pixel art snaps to its own 26px sprite grid | 4px |
| Spacing scale | 8 / 12 / 16 / 24 | 4 / 8 / 12 / 16 / 24 / 32 / 48 |
| Radius | 4px maximum, or 0 | 12px cards, 8px controls, 999px pills |
| Border | 6px solid `pixel.outline` on cards, 3px on internal rules | 1px `ui.hairline` |
| Elevation | None ever — depth comes from outline weight | None — depth from surface vs canvas |

No drop shadows anywhere in the app, in either layer. The pixel layer would be broken by them and the clean layer doesn't need them.

Touch targets: 44px minimum, 48px for reaction chips since they are the primary interaction in the flow.

---

## 7. Motion

One orchestrated moment, not scattered effects.

- **Card reveal** — the single showpiece. 400ms, the card arriving from the owner's hand. Pixel-appropriate: stepped easing (`steps(6)`) rather than smooth curves, so it looks like frames rather than a CSS transition.
- **Chip selection** — 120ms, immediate scale-down feedback on press. Fast, because it happens 4 times per session.
- **Dialogue line change** — 180ms crossfade. The owner's sprite may hold a 2-frame idle animation at ~600ms per frame.
- **Glitch** — intermittent, unpredictable, never on a loop the user can predict. 60–100ms chromatic slice bursts, roughly once every 8–20 seconds, only in the shop scene.
- Everything in the clean layer: 200ms ease-out or nothing.

`prefers-reduced-motion` disables the glitch entirely and reduces the card reveal to a crossfade.

---

## 8. Components

### 8.1 Owner stage

The shop scene. Owner sprite at integer scale, shelf silhouettes behind, dialogue line below, chips at the bottom within thumb reach. The sprite must have room to hold its idle animation without reflowing the text beneath it, so the stage has a fixed height.

The owner is partly obscured by design — hood up, face in shadow, eyes and cigarette ember as the only readable features. He is cool and mysterious, not threatening. That distinction is a real risk in execution: darker palettes and sharper silhouettes tip him into horror quickly. The current sprite keeps him readable and friendly-adjacent by using the full saturated palette rather than near-black, and by his relaxed offering posture.

### 8.2 Reaction chip

Full-width stacked buttons, left-aligned text, `ui.surface` fill with a 1px outline, 48px tall, 8px gap. Left-aligned rather than centred because chips carry phrases, not labels, and phrases read better ranged left. 2–5 per beat.

Chip copy is written in the user's voice, not the system's — "a dinner I can't face", not "Dinner". The chips are the user talking back to the owner.

### 8.3 Excuse card

The central artifact. Structure, top to bottom:

```
┌────────────────────────────────┐
│ card name            [rarity]  │  violet header, pixel type
├────────────────────────────────┤
│                                │
│        pixel illustration      │  paper.panel, 150px
│                                │
├────────────────────────────────┤
│  the claim                     │  small label, paper.meta
│  Your phone died and you       │  Inter Tight, the hero content
│  never saw the messages.       │
│  ────────────────────────────  │  3px paper.divider
│  [family]  [tone]     no. 014  │  pixel tags + collection number
└────────────────────────────────┘
```

6px `pixel.outline` border, 300px wide at base.

Slot rules:

- **Name** — a short playful handle for the kernel (M1.2 `playful_name`). Max three words, so it fits at 11px pixel type.
- **Rarity stamp** — abstract tiers (common, uncommon, rare, legendary). Deliberately *not* the tone word, so rarity stays a collection mechanic independent of social meaning.
- **Illustration** — one pixel scene per kernel, drawn from the six pixel-world colors on `paper.panel`.
- **Claim** — the atomic claim from the M1.2 engine. Inter Tight, never pixel type. This is the only place in the app where the actual excuse content lives.
- **Family tag** — one of the seven M1.2 families, functioning as the card's type. `pixel.teal` fill.
- **Tone tag** — Low-key, Nice, Funny, Dramatic or Unhinged. Sits beside the family tag in the footer.
- **Collection number** — position in the kernel library, for the collecting instinct.
- **Repair** — when the situation warrants one, an optional offered line appears below the footer. Not present on most cards.

### 8.4 Collection

Clean layer. Grid of owned cards, dimmed placeholders for unowned ones so the set is visibly incomplete. Filterable by family and by rarity. A count, not a streak. Tapping a card opens it full-size with its claim readable.

No pressure mechanics: no daily goals, no "you haven't visited in 3 days". The collection rewards the user for having used the app, never for using it more.

---

## 9. Families, tones, rarity

**Seven families** (M1.2), functioning as card types:

Capacity and wellbeing · Care and family · Work and study · Money and logistics · Planning failure · Boundary and preference · Absurd and dramatic

Each family gets a fixed pixel icon and keeps it everywhere — card footer, collection filter, shop shelf.

**Five tones** (M1.2), chosen in beat 4 and shown on the card:

Low-key · Nice · Funny · Dramatic · Unhinged

**Rarity** is abstract and independent: common, uncommon, rare, legendary. It is a collection mechanic only and carries no social-appropriateness meaning. Keeping rarity decoupled from tone matters — otherwise "Unhinged" reads as *better*, which would push users toward socially riskier excuses to complete their collection. Rarity should be assigned to make the set satisfying to complete, not to reward escalation.

---

## 10. Copy voice

**The owner** is dry, brief, a little conspiratorial, never mean and never encouraging you to lie more. Short lines — one sentence, occasionally two. He does not moralise, but he also does not celebrate. He is a shopkeeper, not an accomplice cheering you on.

**The chips** are the user's voice: casual, first person, a bit resigned.

**The claim** is plain and low-detail, per M1.2 — no invented names, places, diagnoses, deaths or emergencies. Its plainness is a feature; ornament would make it look like a script to read aloud.

**Empty and failure states** get direction, not mood. An empty collection says what to do, not that it is lonely.

---

## 11. Safety carried into the UI

These follow from M1.2 §9 and constrain the design directly.

- No send, share or copy action as a primary button anywhere in the flow. The card is received, not dispatched.
- Nothing in the UI presents the claim as a ready-to-send message: no message-bubble styling, no recipient field, no messaging-app chrome.
- Absurd and dramatic is visually separated from the real-world families so playful invention is never mistaken for a genuine emergency claim.
- Repeat cancellations on the same person surface a repair-oriented direction rather than a bigger excuse. This must not be styled as a scolding — it is offered, quiet, and easy to skip.
- No fabricated evidence features. No fake screenshots, fake call logs, fake notifications. This is a hard product boundary, not a backlog item.

---

## 12. Open items

1. Owner sprite needs a real pixel artist. The SVG in this package is a direction-setting placeholder, not a shippable asset. It needs an idle animation (2 frames) and 4 reaction poses, one per beat.
2. Per-kernel illustrations — 60+ needed if the library reaches that size. Consider whether family-level illustrations suffice for v1, with unique art only for rarer cards.
3. Shop environment art — shelves, counter, background. Currently only sketched as silhouettes.
4. Name collision: an "Excuse Me" already exists on Google Play in this exact niche. Worth resolving before any visual identity is finalised, since the wordmark depends on it.
5. Rarity distribution across the kernel library is unassigned.
6. Collection and settings screens have tokens but no layouts.
