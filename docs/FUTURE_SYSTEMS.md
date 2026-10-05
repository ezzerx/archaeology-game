# Future Systems — Confirmed Post-Core Directions

**Status:** confirmed future product directions. The deterministic verticality foundation is advanced to P4-V1; seeded generation and progression remain post-core.

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

### Block silhouette / prepared-block identity — direction to test

Beyond internal stratigraphy, future specimens should test **different outer block/jacket silhouettes** so every preparation does not begin from the same perfect rectangle. Preferred first approach: preserve a readable/controlled work surface and vary the visible outer mass — compact, elongated, chipped, asymmetric, plaster-jacketed, etc. This is a direction to prototype, not a requirement to move immediately to fully free-form excavation geometry.

The goal is identity and anticipation, not extra friction.

### Soil / loose-overburden redesign — preferred hypothesis to test

The current thick structural Soil layer is considered provisional. A preferred future experiment is to reinterpret Soil as a **thin loose dirt / overburden layer sitting on top of the real matrix**, rather than a deep material the player excavates for several centimeters.

Target tactile sequence:

> **brush away loose surface dirt → reveal the dirty contact surface of Clay/Sandstone → switch to Chisel/Pick for structural excavation**

The visual **contact patina** remains after the loose surplus is removed, so the newly uncovered matrix initially looks weathered/dirty; cutting into it reveals its fresher interior color. This creates three readable states:

1. loose surface dirt / overburden — Brush;
2. contact patina on the matrix — visual surface history, material still identifiable;
3. fresh Clay/Sandstone interior — structural excavation.

This hypothesis should be tested in a future excavation-polish pass, not pulled into P5. If Soil becomes thin, verticality must remain interesting through matrix geometry, Clay/Sandstone distribution and fossil burial rather than relying on thick Soil depth.

### When to prototype

**Decision, 2026-10-04:** prototype the **deterministic macro-verticality foundation** in P4-V1, because layer thickness and fossil burial directly change core excavation. One authored B-17 block, broad smooth interfaces and a shared burial field; identical every launch/reset. [Brief](dev/P4V_BRIEF.md) · [Report](dev/P4V_REPORT.md).

This exception does not move procedural generation into P4. Do not add seeds, random variants, multiple blocks or a site generator during P4-V1/P5. P4-V2 debris physics requires a separate authorization after the V1 human test.

After the core V0.1 is proven, create a dedicated variability prototype using multiple seeds / authored variants and test whether repeated excavation stays interesting.

A likely validation set is approximately 10–20 generated test blocks before scaling content production.

**Effort-aware rule confirmed in P4-V1.1, 2026-10-04:** “Verticality / generation must be effort-aware, not depth-only.” A future seed must satisfy material-weighted work budgets as well as geometric invariants. Measure the entire Bone population (median, P90, P95, maximum), not just selected discovery points. Deeper Bone can mean more Soil/Clay rather than an excessive column of the slowest material. Keep the geological field broad and independent of the fossil mask; use Bone only to validate its distribution. The current relative oracle is Clay above Bone ×3 + Sandstone above Bone ×5.333… in mm, not a time prediction. P4-V prototype budgets are documented in [P4V_BRIEF](dev/P4V_BRIEF.md); final tuning remains P7.

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

## 4. Specimen Intake / Crate Queue — confirmed macro-loop direction

The next excavation should be selected through a **physical specimen-crate queue**, not a generic level-select grid.

Each crate provides partial pre-opening information (origin/site, geological period, expected matrix, preparation difficulty, curator note and exceptional/rare status where appropriate) while preserving the exact specimen as a discovery. A short crate-opening ritual should bridge selection and preparation.

Design intent:

> **choose crate → anticipate → open → reveal block/dossier → prepare specimen**

The rarity/specialness signal exists to create anticipation and prioritization, not to support paid loot-box mechanics. Core collection progress must remain targetable and fair.

Crate visual identity is also a direction to explore: different markings, seals, reinforcement, labels, wear, museum handling tags or presentation cues may communicate provenance / rarity / exceptional status before opening. Exact crate shapes are not a priority; **identity through visual treatment** is the stronger current direction.

### Crate-opening interaction grammar — preferred direction

The opening ritual should use a small **modular set of tactile direct-manipulation interactions** instead of repeating one identical animation every time. Example modules:

- pull/remove transport straps with the mouse;
- flip/open metal latches;
- insert a crowbar at a lid seam and drag downward to lever the lid open;
- lift/slide the lid directly;
- remove a final protective wrapping / padding layer before the block reveal.

Do not stack every interaction on every crate. A crate should typically require only **2–3 short actions** so the ritual stays satisfying after many repetitions. The crate's visible construction must clearly communicate what can be manipulated. Variation should come from believable crate hardware / provenance, not arbitrary minigame randomness.

Preferred structure:

> **transport restraint (optional) → closure interaction → lid opening → optional protection reveal → closed fossil block/jacket**

The block revealed by opening remains **closed/unprepared**: the crate reveals the next job, while fossil/bone discovery remains exclusive to the preparation gameplay.

### Intake interaction baseline — preferred prototype

For the future in-game **Specimen Intake** screen, use **Variant A as the baseline**: a readable fixed / semi-fixed view of the museum receiving room with several crates visible at once. Borrow selected strengths from the other explored directions:

- from the more cinematic variant: a stronger visual focus / subtle camera or lighting emphasis on the currently selected crate;
- from the dossier-oriented variant: a concise scientific intake card / clipboard with provenance, period, expected matrix, preparation difficulty and curator notes.

The player should select crates directly in the room rather than navigate a generic level-select grid. No controllable avatar or unnecessary walking is introduced.

## 5. Museum as visible completion / permanent memory — confirmed macro-loop direction

The museum is not merely a stats screen. It should physically reflect completed work: recovered/prepared pieces appear in exhibitions, missing pieces remain visibly absent, and the gallery becomes a persistent record of the player's career.

The core motivational target is similar to the pleasure of filling a museum collection in *Animal Crossing*: each contribution makes the place feel more alive and more personally authored.

Prefer visible exhibit change over abstract XP bars. Some exhibits may start partially complete so the player enters an existing institution and immediately has near-term completion goals.

## 6. Long-term motivation model

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

## 7. Scope rule

These directions are **certain future product pillars**, but their implementation is conditional on the core loop succeeding.

Do not pull seeded generation or progression into P3, P4 or P5 simply because they are documented. Only the deterministic macro-verticality foundation is explicitly authorized early, in P4-V1.

First validate:

1. discovering a fossil;
2. excavation game feel;
3. one complete excavation loop;
4. visual direction / production pipeline.

Then design replayability and long-term progression with dedicated prototypes.
