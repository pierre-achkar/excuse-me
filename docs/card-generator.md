# Procedural collectible cards

`lib/ui/excuse_card.dart` contains one Flutter `ExcuseCard` layout and a versioned `CardDesignGenerator`. The header, badge, art panel, idea, family tag and edition mark follow the supplied HTML. All artwork is native vector geometry rendered with crisp pixel edges; no generated bitmap assets or network requests are required.

Pass an existing `GeneratedIdea` with a permanent, unique `kernelId`, `playfulName`, `family` and `idea`. New IDs get designs automatically. The generator combines 13 reusable object illustrations, 12 header palettes, four panel tints, four background patterns, seeded decorative placement and a 32-bit maker's mark. Family restricts automatic motifs to appropriate objects. Existing cards have optional illustration overrides; those are metadata, not separate widgets.

`CardDesignGenerator.generate(id: ..., family: ..., illustration: ..., color: ..., rarity: ...)` allows explicit art direction. Rarity currently uses a deterministic cosmetic distribution (5% rare, 15% uncommon, 80% common), independent of excuse selection. It is not a gameplay rarity or quality ranking.

Keep IDs permanent. Tone and wording are excluded from the visual seed. Do not change generator version or hashing after publishing a catalog unless intentionally changing its appearance. Missing IDs fall back to the card name or a generic local identity; production catalog entries must have IDs. The compact edition is a hash, not a sequential catalog number or a database key. Hash collisions are possible: validate the full catalog when importing it. Tests exercise 1,000 synthetic IDs; they do not add 1,000 excuses to the content database.

The gallery PNG uses sample text to compare artwork. The mobile result PNG uses the real local engine. Further visual variety can be added by extending the shared motif library while retaining the common card structure.
