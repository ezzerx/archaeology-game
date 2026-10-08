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

### Soil / loose-overburden redesign — P6A1.5 direction accepted

The former thick structural Soil layer is no longer the preferred direction. P6A1.5 human review accepts Soil as a **thin loose dirt / overburden layer sitting on top of the real matrix**, rather than a deep material the player excavates for several centimeters. Exact thickness/coverage remain tunable.

Target tactile sequence:

> **brush away loose surface dirt → reveal the dirty contact surface of Clay/Sandstone → switch to Chisel/Pick for structural excavation**

The visual **contact patina** remains after the loose surplus is removed, so the newly uncovered matrix initially looks weathered/dirty; cutting into it reveals its fresher interior color. This creates three readable states:

1. loose surface dirt / overburden — Brush;
2. contact patina on the matrix — visual surface history, material still identifiable;
3. fresh Clay/Sandstone interior — structural excavation.

This hypothesis should be tested in a future excavation-polish pass, not pulled into P5. If Soil becomes thin, verticality must remain interesting through matrix geometry, Clay/Sandstone distribution and fossil burial rather than relying on thick Soil depth.

### Natural matrix topography — next foundation spike

P6A1.5 exposed a new issue: once Soil becomes thin and substrate-driven, the top of the Clay/Sandstone matrix still reads too much like a horizontal plane.

Next foundation direction:
- deterministic broad relief in the matrix itself;
- shallow bowls/cavities, low ridges, local shelves/steps and irregular interfaces;
- preserve readable excavation and deterministic QA;
- remain independent of the fossil silhouette except for safety/validation;
- keep the future outer jacket/block silhouette system separate.

This becomes P6A1.6 and should be human-tested before P6A2 Hero Lookdev.

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

## 6. Specimen destination / conservation bridge — macro-design question

A future macro-design workshop must decide how prepared specimens transition from the preparation bench into the museum.

Open models to compare:

- **in-matrix display:** the prepared slab/jacket itself becomes the finished museum object;
- **extractable specimen:** selected bones/fragments are removed from matrix and conserved separately;
- **mounted skeleton contribution:** recovered elements progressively populate a museum mount / armature;
- **hybrid rules:** different specimen classes use different destinations.

A short **conservation / mounting / finishing** ritual is a strong candidate for bridging preparation and exhibition (for example final cleaning, consolidant/resin, simple support placement), but it must remain brief and ceremonial rather than add another 10–15 minute gameplay phase.

This is intentionally unresolved until the post-P5 macro game design workshop. P5's dormant two-fragment Forceps experiment is a mechanic test, not a commitment that all major anatomy must become removable.

## 7. Long-term motivation model

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

## 8. Scope rule

These directions are **certain future product pillars**, but their implementation is conditional on the core loop succeeding.

Do not pull seeded generation or progression into P3, P4 or P5 simply because they are documented. Only the deterministic macro-verticality foundation is explicitly authorized early, in P4-V1.

First validate:

1. discovering a fossil;
2. excavation game feel;
3. one complete excavation loop;
4. visual direction / production pipeline.

Then design replayability and long-term progression with dedicated prototypes.

## 9. Mastery achievements as an in-world museum room — concept to study

**Status:** future meta-design idea captured for later workshop; not active P6A scope and not yet a locked production system.

Preferred direction to explore:
- avoid requiring a separate global "Hardcore" mode just to create high-skill play;
- keep the normal/cozy game fully playable as-is;
- layer **optional mastery conditions** onto normal preparation so players who want challenge can self-select harder goals.

Examples of meaningful mastery conditions:
- 95/95 preparation plus **Excellent** Condition;
- no Bone damage / pristine preparation;
- precision-focused constraints tied to careful tool use;
- specimen-specific mastery goals;
- other challenges that reward skill and care rather than extra grind or simply spending longer.

The goal is to let the same preparation systems support two readings:
- relaxed/cozy completion for players who want it;
- high-precision mastery for players who enjoy pushing the mechanics.

### Physical achievement room / gallery

A strong museum-facing presentation idea is to make achievements **diegetic and visible in the museum**, rather than only a menu list.

Concept:
- a small achievement/mastery room, gallery or side space in the museum;
- earned achievements appear as physical display objects;
- locked achievements still have visible placeholders so the player can imagine the completed room and feel motivated to pursue them;
- presentation could use medals, old preparation tools, museum plaques, certificates, decorative scientific trophies, small symbolic specimen displays, framed awards, or similar objects;
- empty mounts, silhouettes, plaques or display cases can communicate missing achievements without turning the space into a generic checklist.

This creates a visual completion fantasy:
> the player can literally see the room filling with evidence of their mastery.

Some achievements could be semi-secret / easter-egg-like:
- only a suggestive title, plaque, silhouette or clue is visible before unlock;
- discovery should feel playful, not obscure or punitive.

### Design guardrails

- Do not lock core fossils, story or essential museum content behind mastery achievements.
- Rewards should mainly be prestige, visible museum completion, decoration/cosmetics or optional recognition.
- Prefer a smaller set of **meaningful** achievements over dozens of trivial counters.
- Avoid grind achievements such as "use Brush 500 times" unless they genuinely represent an interesting behavior.
- Success conditions should reward precision, care, discovery or mastery of the preparation system.
- A later "Expert Contract" or explicit hardcore challenge layer can still be explored if the player base wants more, but it is not required for this concept to work.

This idea should be revisited during the future **Macro Game Design / Museum & long-term motivation** workshop, after the current core visual/playtest work is stable.



## 10. Sensory polish, tool identity and pacing — future production directions

**Status:** product-quality directions surfaced by the first convincing friend-playtest-quality Hero build. Not active implementation scope unless explicitly authorized.

### Tool visual identity

The current Brush / Chisel / Blower / Pick models still read as prototype/dev tools. Future art production should give each one a coherent Archeo preparation-workbench identity:
- believable paleontology/preparation form language;
- readable silhouette at gameplay scale;
- warm, handcrafted / professional museum-lab character;
- visual hierarchy that makes tools feel like objects the player enjoys using, not debug gizmos.

### Satisfying tactile Foley as a quality pillar

Audio should be treated as a major contributor to satisfaction. The earlier word
"ASMR" described the desired **satisfaction/detail**, not the literal aesthetic.

Target:
- realistic, close, tactile, material-specific brushing/scraping/chipping/blowing Foley;
- satisfying short transients and believable material response;
- strong differentiation between Soil, Clay, Sandstone and Bone interactions;
- layered variation so repeated actions do not sound mechanically looped;
- careful balance so the experience stays cozy rather than fatiguing;
- restrained preparation music that supports focus while keeping tool/material
  sounds in the foreground.

This deserves a dedicated Sound Design & Music pass instead of being left as
end-of-project garnish.

### Non-destructive material response

Even when an action does not remove the contacted material, the game can still acknowledge the touch visually/audio-visually.

Example to prototype later:
- Brush on Clay: no structural excavation, but a tiny local colored dust/powder puff or subtle residue response.

Design intent:
> preserve the tool rule while making the world feel reactive.

This is best thought of as **material reactivity / game feel / juice**, not persistence.

### Interactive task light as relief-reading mechanic

Friend playtest feedback suggests that a fixed light direction can make some
cavities and relief harder to read. Explore a future dedicated spike where the
player can reposition/orient the preparation lamp and intentionally change shadow
direction to inspect the specimen.

Design goals:
- improve reading of crevices, steps and shallow relief;
- keep manipulation simple and bounded rather than fiddly;
- preserve the cozy task-light art direction;
- use the visible workbench lamp as the natural interaction affordance if viable;
- test whether this creates meaningful preparation skill rather than mere settings UI.

Do not turn this into a required mechanic until a focused human playtest proves
that moving the light is useful and pleasant.

### Pacing and possible higher-power tool

Current playtest feedback: overall excavation can feel somewhat slow.

Decision order:
1. first address pacing through P7 fine tuning of existing timings/effort;
2. do not add an extra tool merely to hide poor tuning;
3. if a satisfying pace still requires another layer, explore a **higher-power excavation tool** with meaningful trade-offs (higher risk, lower precision, stronger debris/damage potential, limited safe use near Bone, etc.);
4. in that model, Chisel can become the middle tool between safe/fine work and fast/risky removal.

Any such tool must create a new decision, not just be “Chisel but faster.”
