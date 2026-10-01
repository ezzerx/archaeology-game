# ArchaeologyGame — Roadmap

No calendar is committed. Each gate depends on human validation of the previous one.

The canonical phase numbering remains the simple **P0 → P7** sequence from `PROTOTYPE_V0_1_SPEC.md`.

## Core prototype gates

| Gate | Purpose | Status / exit condition |
|---|---|---|
| **P0 — Interaction** | Mouse mapping, editable surface, debug foundation | ✅ validated |
| **P1 — Material / Relief** | Real cavities, stratigraphy, material resistance | ✅ validated |
| **P2 — Tools** | Soft Brush, Chisel, Air Blower with distinct roles | ✅ validated |
| **P3 — Fossil** | Hidden fossil, progressive exposure, bone contact / condition | ✅ validated & merged |
| **P4 — Game Feel** | Material reactions, fracture/chunks, particles/debris placeholders, tool presence, sound/feedback | ▶ active — excavation must begin to feel satisfying without full production DA |
| **P5 — UI & Progression** | Objectives, specimen dossier, classification, fragments, completion card, one complete excavation loop | One session must make sense end-to-end |
| **P6 — Art Pass** | Reproduce and validate the canonical visual direction in-engine, then apply it to the V0.1 slice | DA must become coherent, reproducible and performant |
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

Take one representative slice close to target quality and prove the production pipeline before scaling.

Questions to answer:

- final balance between 3D, 2.5D and illustrated assets;
- Soil / Clay / Sandstone / Bone material authoring;
- warm natural-history lighting setup;
- table, tools, notebook and scientific prop pipeline;
- cavity / layer-boundary visual treatment;
- integration of dust/particles without hiding discoveries;
- UI language: paper / wood / brass / field notebook;
- asset workflow: Blender, image generation, texture tools, manual paintover, Higgsfield or alternatives;
- style reproducibility across future blocks/fossils;
- GPU budget on representative Steam hardware.

P6A is not a separate roadmap gate. It is the **first substep of P6**.

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
