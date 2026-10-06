# Orchestration Handoff — ArchaeologyGame

**Purpose:** give a new ChatGPT orchestration conversation the same product mental model and decision discipline as the current one.

**Last audited:** 2026-10-06.

## 1. Product in one paragraph

ArchaeologyGame is a cosy, tactile fossil-preparation game set in the back rooms of a natural-history museum. The player is a **specimen preparator/restorer**, not an adventurer avatar: specimens arrive at the museum workshop as excavation blocks, the player removes surface dirt and matrix, reveals and cleans Bone, documents the specimen, then archives the preparation for the museum. Whether future specimens remain in-matrix, are extracted, or contribute to mounted exhibits is intentionally still a Macro Game Design decision. The core fantasy is **quiet scientific craft and discovery**. No open world, no controllable character; the tabletop/workbench is the gameplay space.

Long-term diegetic loop:

> **museum assigns specimen → preparation workshop → excavation / cleaning / identification → archive → collection / exhibition update → next specimen**

## 2. North Star

The central product question remains:

> **Est-ce que j’ai envie de continuer à gratter alors que je sais déjà ce qu’il y a dessous ?**

Do not compensate for weak excavation feel with more content, progression or UI.

P5 adds a second behavioral test:

> **After “Preparation Complete”, does the player voluntarily choose to keep cleaning?**

## 3. Live project state

Do **not** cache the live phase in this handoff.

Read `docs/brain/status.md` for:
- validated phases;
- active branch / PR;
- current gate;
- next authorized action;
- accepted watchpoints/blockers.

This handoff is intentionally for the **stable mental model**, not day-to-day status.

Documentation roles are defined in `docs/DOCUMENTATION_POLICY.md`.

## 4. Source precedence

When documents conflict, use this order:

1. **Antoine’s newest explicit decision in the current conversation**
2. **`docs/brain/status.md` for live phase / gate / next authorized action**
3. **active phase brief / report / active PR**
4. `docs/brain/decisions.md`
5. `docs/CONCEPT.md`, `GAMEPLAY_LOOP.md`, `ART_DIRECTION.md`, `MUSEUM_SYSTEM.md`, `FUTURE_SYSTEMS.md`, `ROADMAP.md`
6. older phase reports / archived prototype text as historical context

`PROTOTYPE_V0_1_SPEC.md` is foundational but contains historical sections superseded by later phase decisions. Never resurrect an older rule merely because it is still written there.

## 5. P4 gameplay baseline — do not casually retune

### Tools

| Tool | Radius | Power | Falloff | Role |
|---|---:|---:|---:|---|
| Soft Brush | 40 | 0.70 | 1.25 | Soil + Bone Film / mess cleanup |
| Chisel | 22 | 0.64 | 2.25 | bulk Clay/Sandstone fracture |
| Air Blower | 60 | 0 | 1.00 | eject loose mess / dust |
| Precision Pick | 11 | 0.44 | 1.75 | fast precise structural finishing |

Chisel cadence 4.5 Hz. Pick cadence 6 Hz. Blower residue clear 2.5. Pick is Bone-safe in the current prototype.

### Player grammar

> **attached material vs mess**

- Soil → Brush
- bulk hard matrix → Chisel
- precise attached remnants near Bone → Pick
- loose mess → Brush / Blower

Tiny isolated hard remnants may detach into brushable mess under the bounded P4 rule. Do not give Brush general hard-matrix excavation.

### Bone

Three distinct concepts:

> **Exposure ≠ Cleanliness ≠ Condition**

- Exposure = structure revealed
- Cleanliness = adhered Bone Surface Film removed
- Condition = damage state

Newly exposed Bone carries an adhered dirt film. Brush removes it; Blower/Pick do not. Bone Condition is global. First direct damaging Chisel contact is protected **per anatomical component**: Skull / Spine / Ribs / Hind Limb. Main skeleton totals remain 32,290 cells.

### Material / debris

- Chisel fracture spectacle is intentionally strong and transient.
- Clay/Sandstone persistent Matrix crumbs use lightweight bounded physics.
- Blower cleanup is gameplay evacuation: sufficient jet engagement removes logical crumbs and shows a short ejection FX.
- Soil currently has **no persistent grains and no persistent Fine Dust**. This is explicitly provisional and deferred.
- deterministic P4-V1 verticality is **effort-aware, not depth-only**.

## 6. Known “last 20%” — deliberately deferred

These are **not P4 blockers**:

- Soil semantics were reworked in P6A1.5: thin, partial overburden is preferred over thick structural Soil. Final particles/VFX/tuning remain future polish.
- Matrix debris is good enough but may have a better future solution.
- occasional visual ambiguity: Pick-removable attached remnant vs Brush-removable mess.
- Bone dirt can still resemble Sandstone in some views.
- dust can reduce block-edge/depth readability.

Important P6 rule:
**before redesigning Bone Film, test color only**. Antoine likes the current spot/pattern shape.

If gameplay polish is reopened after P5/P6, create a **new named phase** (TBD), not “P4.2”.

## 7. P5 mental model

P5 is the first time the prototype becomes a complete “game session”.

Current target flow:

> **Prepare B-17 → reveal and clean →85/85: Ready to archive → Archive OR optional cleaning →95/95: one Fine Preparation star → Museum records updated → Prepare Another Block**

One card shows global Exposure/Cleanliness. Completion is latched and leaves tools active. Keep Cleaning records a voluntary choice without resetting anything. A new dirty revelation may lower cleanliness without revoking earned completion/star. Condition remains independent and active, shown qualitatively in the single card and archive; exact values stay in debug. Classification can briefly notify discoveries. Neither is another completion requirement.

Archive captures current values, locks tools and offers another block. Separate completion/archive snapshots and actions/time remain in F1. Another Block repeats deterministic B-17 for P5; the future museum/crate loop is not implemented. Historical fragment code is dormant, reachable only through explicit test setup.

The gate is human comprehension and desire to continue, not automated test success. Launch and play without brief/developer coordinates; use only the seven retest steps in the current report afterward.

## 8. Narrative baseline

Current canon, until a better idea appears:

> **The player is employed by a natural-history museum as a specimen preparator/restorer.**

The museum is:
- narrative employer;
- physical setting;
- destination of prepared specimens;
- future meta-progression/collection.

Menu direction:
- exterior/front view of the museum;
- pressing Play implies entering the building;
- gameplay happens in the preparation workshop;
- gallery/collection shows the result of the work.

No avatar navigation.

Working-title shortlist lives in `docs/NAMING_IDEAS.md`.
**Bone by Bone** is a strong current candidate, not the final title.

## 9. Visual direction

Canonical:
> **2.5D stylized — tabletop — near-vertical orthographic camera**

Not pixel art, not photorealism, not visibly low-poly, not exaggerated cartoon.

Emotional target:
> **a warm illustration brought to life**

Identity:
**earth + stone + Bone + warm lamp + scientific equipment + natural-history museum**

Visual references:
- canonical 2×2 board in `docs/visual-references/archaeologygame-v0.1-visual-reference-board.jpg`
- manifest: `docs/VISUAL_REFERENCES.md`

The ChatGPT Project also contains the canonical board. Recent museum-exterior/menu generations are exploratory concept work, **not yet a versioned canonical image**. Their text direction is canonized; if exact pixels matter later, ask Antoine to re-provide/select the image or version one explicitly.

### P6 reserved ideas

P6A first, then P6B.

Already canonized for P6:
- museum façade/menu → preparation workshop → gallery visual continuity;
- **thin Soil overburden**: partial surface dirt follows the substrate; Brush reveals the real Clay/Sandstone work surface;
- **contact patina**: original Clay/Sandstone stays readable under irregular dirty deposits/stains; never a uniformly darker material band;
- **natural matrix topography before Hero Lookdev**: broad deterministic undulations, shallow bowls/cavities, ridges and local shelves/steps so the underlying matrix does not start as a flat plane;
- Bone dirt vs Sandstone readability: **try color/material-property changes before redesigning the current film pattern**;
- seasonal museum menu direction: same façade/composition, seasonal ambience (snow/flakes, autumn leaves, etc.), subtle animation rather than a different building.

P6A2 has a dedicated visual target pack and usage guide on the active P6A branch. The new images define style/material/lighting targets, not literal scene layouts.

### P6A foundation state to preserve

Before production Hero Lookdev, the project deliberately resolves geometry/gameplay foundations that would otherwise invalidate art work:

1. P6A-1 Material Lab proved authored/hybrid rendering can coexist with the real dynamic B-17 surface; none of A/B/C is the final art target.
2. P6A1.5 human review prefers thin irregular Soil overburden and irregular deposit-style contact patina.
3. The next foundation risk is the overly planar Clay/Sandstone starting surface; P6A1.6 Natural Matrix Geometry is intended to introduce deterministic macro relief/cavities before P6A2.
4. P6A2 then targets one small real playable Hero Patch against the canonical P6A2 visual-reference pack before any P6B scaling.

Do not conflate **internal matrix topography** with **future outer jacket/block silhouette variation**.

## 10. Long-term confirmed pillars

### Newly locked macro-loop pillars

- **Specimen Intake via physical crates:** future work selection is a crate queue with partially informative scientific/logistics labels (site/origin, period, matrix, difficulty, curator/provenance note, exceptional status). A short satisfying opening ritual bridges selection and preparation. Special crates may create strong anticipation, but never paid loot-box logic or unfair collection blocking.
- **Museum as living visual memory:** each prepared/acquired piece should visibly alter the gallery/exhibit. Missing parts remain physically missing. The museum should feel more alive because of the player's work, inspired by the satisfaction of filling the museum in Animal Crossing. Prefer visible completion over abstract XP bars; starting partly filled is a strong candidate.
- Target macro loop: **crate queue → anticipation/opening → preparation → archive → visible museum update → next crate**.


### Preferred future exploration directions

These are strong current hypotheses, not final implementations:

- **Crate identity > crate geometry:** use labels, seals, reinforcement, wear and special handling cues to signal provenance/rarity/exceptional status; different crate shapes are optional and low priority.
- **Specimen Intake screen baseline:** Variant A is the preferred prototype: fixed/semi-fixed receiving-room view with several directly selectable crates, plus subtle hero-focus on the current crate and a concise scientific dossier/clipboard. No avatar navigation.
- **Crate opening grammar:** direct mouse manipulation with a small modular set of believable actions (pull straps, flip latches, crowbar lever, lift lid, remove protection). Usually 2–3 short interactions; vary crate hardware rather than repeat one animation. Opening reveals a closed/unprepared block, never already-exposed bones.
- **Prepared-block silhouette variation:** test visually different outer block/jacket silhouettes while keeping preparation readable; this is separate from the current internal-matrix topography spike. Avoid jumping immediately to unconstrained free-form excavation geometry.
- **Soil baseline after P6A1.5:** thin removable loose overburden/dirt is preferred over deep Soil. Brush reveals a dirty/contact-patinated Clay/Sandstone surface; structural excavation reveals fresh matrix interior. Exact thickness/coverage remain tunable.
- **Preparation → museum bridge remains open:** Macro Game Design must compare in-matrix display, extractable bones, mounted-skeleton contribution and hybrid specimen rules. A short conservation/mounting ritual is promising, but never as another long 10–15 minute phase. P5 Forceps fragments do not commit the final extraction model.

Do not pull these into P5/P6 without explicit authorization:

- seeded/controlled variable excavation blocks;
- equipment specialization/progression;
- expertise/site progression;
- museum collection/meta;
- later content diversification (e.g. minerals/geodes remains brainstorm-level unless separately canonized).

Future block generation must preserve:
> **effort-aware variability, not depth-only randomness**

## 11. Orchestration workflow

Antoine’s preferred split:

- **During a phase:** implementation/testing stays in Codex.
- **Between phases:** return to ChatGPT orchestration for product review, human-gate decision, merge/canonization, next brief.

The orchestrator should:
- protect product intent;
- challenge premature workarounds;
- keep the phase scope narrow;
- treat human playtest feedback as the gate;
- inspect the live PR before merge;
- update Brain/decisions/status after durable decisions;
- never infer human validation from automated tests.

Reusable rule learned in P3/P4:

> **Do not create an earlier-phase workaround for a problem a planned later phase is explicitly expected to reshape unless it blocks current validation.**

## 11.5 Future release / studio context

If the game proves itself, Antoine wants a **commercial studio brand** that can carry credibility into future projects and strengthen CV/LinkedIn positioning. A separate legal company is not required merely to use a studio identity; legal/tax structure can be revisited closer to release/revenue.

Steam/release work is a later production phase, not current P6A scope. See `docs/FUTURE_RELEASE_BUSINESS.md`.

## 12. How to resume in a new conversation

The new orchestrator should immediately:

1. read this file;
2. read `AGENTS.md`;
3. read `docs/brain/status.md` + `decisions.md`;
4. inspect the active PR and branch, not only `main`;
5. read the active phase brief/report;
6. ask for / consume Antoine’s latest human-test feedback;
7. only then decide merge, correction pass or next phase.

At every resume:
- trust `docs/brain/status.md` for the live phase and next authorized action;
- inspect the active PR named there;
- read only the active brief/report before deciding what to execute;
- never resurrect a historical STOP instruction from an old report.

## 13. What “same wavelength” means

When making a product decision, preserve these priorities:

1. **tactile/satisfying excavation**
2. **clear material/tool language**
3. **quiet scientific discovery / museum-preparation fantasy**
4. **player desire to voluntarily continue cleaning**
5. **functional progression that supports the core, not replaces it**
6. **art production only when it becomes the highest-leverage risk**

The project should feel like **careful preparation of a real museum specimen**, not a generic digging game, simulator dashboard, or adventure RPG.


### New-chat resume behavior

When Antoine opens a new orchestration conversation in this Project:

1. read `docs/brain/status.md`;
2. inspect the active PR/branch named there;
3. read the active brief/report;
4. recover the Project visual references when relevant;
5. do not ask Antoine to restate already-canonized context unless a source is genuinely missing.

Implementation prompts for Codex should be delivered as **one single fenced block**, ready to copy in one click.

As of the 2026-10-06 handoff, the expected next execution request is the **P6A1.6 Natural Matrix Geometry** mission. Its prepared brief lives on the active P6A branch at:
`docs/dev/P6A16_NATURAL_GEOMETRY_BRIEF.md`

If the live `status.md` still names P6A1.6 when the new chat starts and Antoine asks to launch it, produce the Codex prompt directly from that brief rather than redesigning the mission from scratch.
