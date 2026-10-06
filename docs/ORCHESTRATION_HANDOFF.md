# Orchestration Handoff — ArchaeologyGame

**Purpose:** give a new ChatGPT orchestration conversation the same product mental model and decision discipline as the current one.

**Last audited:** 2026-10-05.

## 1. Product in one paragraph

ArchaeologyGame is a cosy, tactile fossil-preparation game set in the back rooms of a natural-history museum. The player is a **specimen preparator/restorer**, not an adventurer avatar: specimens arrive at the museum workshop as excavation blocks, the player removes Soil / Clay / Sandstone, reveals and cleans Bone, recovers pieces, updates a scientific dossier, then archives the prepared specimen for the museum collection. The core fantasy is **quiet scientific craft and discovery**. No open world, no controllable character; the tabletop/workbench is the gameplay space.

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
2. **active phase brief** (`docs/dev/Pn_BRIEF.md`)
3. **active phase report / active PR**
4. `docs/brain/decisions.md`
5. `docs/brain/status.md`
6. `docs/CONCEPT.md`, `GAMEPLAY_LOOP.md`, `ART_DIRECTION.md`, `MUSEUM_SYSTEM.md`, `ROADMAP.md`
7. older phase reports / old prototype text as historical context

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

- Soil needs a richer redesign eventually.
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
- **layer contact patina**:
  - Soil → Clay: dirty/browned Clay surface skin, cleaner orange Clay underneath;
  - Clay → Sandstone: subtler optional variant;
  - visual only, no gameplay thickness/resistance/picking.
- Bone dirt vs Sandstone readability: **try color-only first**.

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
- **Prepared-block silhouette variation:** test visually different block/jacket silhouettes while keeping preparation readable; avoid jumping immediately to unconstrained free-form geometry.
- **Soil redesign:** preferred hypothesis is a thin removable loose-overburden/dirt layer rather than deep Soil. Brush reveals a dirty/contact-patinated Clay/Sandstone surface; structural excavation then reveals fresh matrix interior. If adopted, preserve verticality through matrix/fossil depth rather than thick Soil.
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

## 12. How to resume in a new conversation

The new orchestrator should immediately:

1. read this file;
2. read `AGENTS.md`;
3. read `docs/brain/status.md` + `decisions.md`;
4. inspect the active PR and branch, not only `main`;
5. read the active phase brief/report;
6. ask for / consume Antoine’s latest human-test feedback;
7. only then decide merge, correction pass or next phase.

As of this audit:
- inspect PR #8;
- P5 code is delivered;
- wait for Antoine’s end-to-end test;
- no P6 yet.

## 13. What “same wavelength” means

When making a product decision, preserve these priorities:

1. **tactile/satisfying excavation**
2. **clear material/tool language**
3. **quiet scientific discovery / museum-preparation fantasy**
4. **player desire to voluntarily continue cleaning**
5. **functional progression that supports the core, not replaces it**
6. **art production only when it becomes the highest-leverage risk**

The project should feel like **careful preparation of a real museum specimen**, not a generic digging game, simulator dashboard, or adventure RPG.
