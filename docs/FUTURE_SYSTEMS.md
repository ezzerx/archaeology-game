# Future Systems — Confirmed Post-Core Directions

**Status:** confirmed future product directions, intentionally not implemented during the current V0.1 core validation.

These systems are considered part of the intended game direction if the excavation core passes validation. Their detailed design, balancing and production scope remain open and will receive dedicated brainstorming/specification later.

## 1. Variable / Generated Excavation Blocks — confirmed future feature

A finished game must not repeat the exact same stratigraphy at the same depths on every excavation.

The current deterministic prototype block exists for debugging and validation only.

### Product intent

Future excavation blocks should be generated or assembled from a deterministic seed / authored ruleset so that the player must **read the material in front of them** instead of memorizing a fixed sequence such as:

> Soil for N seconds → Clay at depth X → Sandstone at depth Y.

Variation may include:

- changing layer thicknesses;
- irregular / sloped interfaces;
- local pockets or lenses of material;
- areas where a harder material intrudes into a softer layer;
- varying fossil depth;
- varying fossil position and orientation where compatible with the fossil system;
- optional later materials and geological features.

### Design rule

Randomness must be **controlled and plausible**, not noise for its own sake.

The system should produce blocks that are:

- readable;
- reproducible by seed;
- testable;
- completable;
- compatible with intended tool progression;
- capable of difficulty bands.

The player should learn to identify materials and choose tools, not learn a fixed timer/depth script.

### When to prototype

Do not implement during P3/P4/P5 core validation.

After the core V0.1 is proven, create a dedicated variability prototype using multiple seeds / authored variants and test whether repeated excavation stays interesting.

A likely validation set is approximately 10–20 generated test blocks before scaling content production.

## 2. Equipment Progression — confirmed future pillar

Collection alone should not carry the entire long-term motivation.

A second progression axis should let the player improve and expand the archaeological toolkit.

### Product intent

Prefer **functional unlocks and specialization** over simple numerical upgrades.

Examples to explore later:

- wider brush vs fine brush;
- different brush stiffness;
- precision chisel tip vs wider chisel;
- powered / pneumatic tools with greater risk;
- precision blower nozzle;
- variable air pressure;
- preservation / stabilization equipment.

Avoid a shallow progression made only of:

> Tool Level 1 → +10% power → Level 2 → +20% power.

Upgrades should ideally create new choices, trade-offs or techniques.

The final economy, unlock currencies, prices, upgrade tree and progression speed are **not yet defined**.

## 3. Expertise / Site Progression — confirmed future pillar

The player should gradually gain access to more demanding excavations.

Possible future progression:

- beginner sites with forgiving Soil / Clay;
- intermediate sites with harder matrix and more delicate exposure;
- advanced sites with hard rock, thin bones or complex geometry;
- rare expeditions / exceptional specimens.

The exact system may be framed as museum prestige, scientific reputation, funding, expertise or another diegetic progression mechanism.

This deserves a dedicated design workshop after the excavation core and initial visual pipeline are validated.

## 4. Long-term motivation model

Current intended structure:

```text
EXCAVATION
   |
   +--> FOSSILS / PARTS --> MUSEUM COLLECTION
   |
   +--> RESOURCES / PROGRESS --> EQUIPMENT
   |
   +--> PRESTIGE / EXPERTISE --> NEW SITES / COMPLEXITY
```

The systems should reinforce one another without turning the excavation into a grind.

## 5. Scope rule

These directions are **certain future product pillars**, but their implementation is conditional on the core loop succeeding.

Do not pull them into P3, P4 or P5 simply because they are now documented.

First validate:

1. discovering a fossil;
2. excavation game feel;
3. one complete excavation loop;
4. visual direction / production pipeline.

Then design replayability and long-term progression with dedicated prototypes.
