# ArchaeologyGame — Roadmap

> This file defines phase purposes and sequencing. **Live status is authoritative only in `docs/brain/status.md`.**

No calendar is committed. Each gate depends on human validation of the previous one.

The canonical phase numbering remains the simple **P0 → P7** sequence from `PROTOTYPE_V0_1_SPEC.md`.

## Core prototype gates

| Gate | Purpose | Status / exit condition |
|---|---|---|
| **P0 — Interaction** | Mouse mapping, editable surface, debug foundation | ✅ validated |
| **P1 — Material / Relief** | Real cavities, stratigraphy, material resistance | ✅ validated |
| **P2 — Tools** | Soft Brush, Chisel, Air Blower with distinct roles | ✅ validated |
| **P3 — Fossil** | Hidden fossil, progressive exposure, bone contact / condition | ✅ validated & merged |
| **P4 — Game Feel** | Material reactions, fracture/chunks, debris, tool presence, sound/feedback, Bone preparation, verticality | ✅ human-validated & merged |
| **P5 — UI & Progression** | One complete preparation session, minimal progress UI, archive/continue choice | ✅ human-validated; greybox intentionally accepted |
| **P6 — Art Pass** | Reproduce and validate the canonical visual direction in-engine, then apply it to the V0.1 slice | ▶ P6A next: prove the visual-production pipeline before scaling |
| **P7 — Tuning** | No new systems: tune speed, resistance, radii, sounds, dust, feedback and discovery rhythm | V0.1 ready for external playtest |

## Development principle — Pareto before production art

The project should advance gameplay as far as practical using greybox / placeholder assets before making DA the main bottleneck.

The rule is:

> **Use the cheapest 20% of visual work that unlocks 80% of gameplay validation.**

This means:

- P0–P3 stay technical / greybox;
- P4 adds only the sensory feedback required to judge the excavation loop;
- P5 builds the complete loop and functional UI without demanding final art;
- P6 becomes the dedicated visual-production milestone once DA has higher leverage than another gameplay system;
- P7 tunes the complete slice after the art pass because visuals/audio can change perceived timing and readability.

Do not postpone all visual thinking until P6: P4 must make interactions readable and satisfying enough to test. But do not spend production-art effort in P4/P5 unless it materially improves gameplay validation.

## P6 — Art Pass

P6 remains a single numbered phase so the roadmap stays consistent.

Internally it has two ordered substeps:

### P6A — Visual Direction / Production Spike

P6A is intentionally split into small visual/gameplay-risk spikes before scaling.

Current intended order:
1. **P6A-1 Material Lab** — completed; technical feasibility proven, no final visual winner.
2. **P6A1.5 Soil Foundation Spike** — completed; thin irregular surface overburden direction preferred.
3. **P6A1.6 Natural Matrix Geometry Spike** — next; fix the overly planar Clay/Sandstone substrate before lookdev.
4. **P6A2 Hero Lookdev / Target Match** — push one real B-17 patch toward the canonical visual target pack.
5. Human visual gate.
6. P6B only after explicit approval.

### P6A1.5 — Soil Foundation Spike

Purpose:
- compare current thick structural Soil with the preferred thin loose-overburden model;
- decide only the **role / thickness / tool grammar** needed before lookdev;
- do not turn this into final Soil VFX, debris or P7 tuning.

Exit:
> one Soil semantic baseline is chosen for P6A2.

### P6A1.6 — Natural Matrix Geometry Spike

Purpose:
- replace the broad planar starting matrix impression with deterministic natural macro relief;
- test shallow cavities/bowls, ridges, shelves/steps and broad undulations;
- keep the richer topography compatible with Soil-overburden, tools, Bone safety, picking and effort-aware budgets;
- keep outer block/jacket silhouette variation out of this spike.

Exit:
> one natural matrix-topography baseline is human-approved for P6A2.

### P6A scope after the geometry decision

Take one representative slice close to target quality and prove the production pipeline before scaling.

Questions to answer:

- final balance between 3D, 2.5D and illustrated assets;
- Soil / Clay / Sandstone / Bone material authoring;
- warm natural-history lighting setup;
- table, tools, notebook and scientific prop pipeline;
- museum façade/menu → preparation workshop → collection/gallery visual continuity;
- cavity / layer-boundary visual treatment;
- contact patina / weathering at layer interfaces, with Soil → Clay as the primary P6 target and Clay → Sandstone as a subtler experiment;
- integration of dust/particles without hiding discoveries;
- UI language: paper / wood / brass / field notebook;
- asset workflow: Blender, image generation, texture tools, manual paintover, Higgsfield or alternatives;
- style reproducibility across future blocks/fossils;
- GPU budget on representative Steam hardware.

P6A is not a separate roadmap gate. It is the **first substep of P6**.

### P6A3.1 — Friend Playtest Feedback / Mastery Readability

A short focused follow-up after the first friend playtest.

Targets:
- make displayed 100% attainable without fake 99% stalls;
- smaller visual Chisel crosshair with unchanged real effect radius;
- improve Bone dirty/clean readability near full Cleanliness;
- visible dust response while brushing Bone Film;
- clearer Bone Condition presentation and first visual damage language.

No broad retuning, new tool or audio overhaul in this substep.

### P6A-Sound — Dedicated Sound Design & Music Pass

Treat audio as a real quality pillar:
- satisfying tactile Foley per tool/material;
- controlled variation and layering;
- repeated-use fatigue testing;
- Brush/Blower continuous interaction handling;
- restrained preparation music.

### P6A-Light — Interactive Task Light Spike

Test player-controlled lamp direction as a possible relief-reading mechanic:
- move/orient the task light;
- reveal crevices and height changes through shadows;
- preserve the validated cozy lighting language;
- human-test whether the interaction adds skill/value.

### P6B — V0.1 Art Pass

Once P6A proves the direction and pipeline, apply it to the complete V0.1 slice:

- table;
- lamp;
- textures/materials;
- fossil visual treatment;
- tool visuals;
- notebook / props;
- functional UI restyle;
- palette;
- lighting;
- composition.

Do not start mass asset production for the full game here.

## V0.1 validation

After P7, run the first serious external playtest wave.

North Star:

> **Est-ce que j’ai envie de continuer à gratter alors que je sais déjà ce qu’il y a dessous ?**

If the answer is weak, tune/fix the core before adding long-term content systems.

## Post-core confirmed systems

Once the V0.1 core passes:

### Block Variability Prototype

Create multiple seed-based / controlled variants so excavation does not become a memorized fixed-depth sequence.

See [FUTURE_SYSTEMS.md](FUTURE_SYSTEMS.md).

### Meta Progression Prototype

Dedicated brainstorm/prototype for:

- equipment unlocks / specialization;
- museum / collection progression;
- expertise / site access;
- difficulty bands and long-term motivation.

These are confirmed future pillars, but their detailed design is intentionally deferred.

### Future Excavation Polish — name TBD

A later dedicated gameplay-polish phase may be opened **after P5/P6 give more context**. It is intentionally not named `P4.2` and is not scheduled yet.

Known candidates:
- richer Soil behavior/feedback;
- further debris/mess refinement;
- Pick-vs-Brush readability around Bone;
- Bone dirt vs Sandstone differentiation;
- dust/relief readability.

These are the remaining “last 20%”, not blockers for leaving P4.

## Later production


After the above are validated:

- reproducible content pipeline;
- additional fossils;
- generated / authored block families;
- museum expansion;
- progression balancing;
- save system;
- Steam production requirements;
- optimization across representative hardware;
- full content scaling.

## Rules

- If excavation is not satisfying, fix excavation before adding content.
- If another gameplay pass has more leverage than art, do gameplay first.
- When DA becomes the dominant product risk, P6 becomes the priority.
- If the target DA cannot be reproduced consistently, fix the art pipeline before scaling assets.
- Do not let procedural variability hide weak base gameplay.
- Prefer functional tool progression over pure percentage upgrades.
- Keep deterministic seeds / fixtures for QA even when production blocks become variable.
- Record every human gate in the Brain and reports.
