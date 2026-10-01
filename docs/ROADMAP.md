# ArchaeologyGame — Roadmap

No calendar is committed. Each gate depends on human validation of the previous one.

## Core prototype gates

| Gate | Purpose | Status / exit condition |
|---|---|---|
| **P0 — Interaction** | Mouse mapping, editable surface, debug foundation | ✅ validated |
| **P1 — Material / Relief** | Real cavities, stratigraphy, material resistance | ✅ validated |
| **P2 — Tools** | Soft Brush, Chisel, Air Blower with distinct roles | ✅ validated |
| **P3 — Fossil** | Hidden fossil, progressive exposure, bone contact / condition | ▶ active |
| **P4 — Game Feel** | Dust, particles, debris, audio, physical tool presence, discovery feedback | Must make excavation satisfying |
| **ART0 — Visual Direction & Production Spike** | Take one small slice near target quality and validate the visual production pipeline | Must prove the target DA is achievable, coherent and performant |
| **P5 — One Complete Excavation Loop** | Objectives, identification, fragments, Preparation Complete / Keep Cleaning, minimal usable UI | One full session should make sense end-to-end |
| **V0.1 Gate** | Human playtest of the complete core | Core must pass the North Star test |

## Why ART0 happens before a full art pass

The visual direction is a core product risk, not decoration.

We should **not** wait until late production to discover how the game will actually look.

However, doing finished art before the excavation mechanics and game feel are stable would create expensive rework.

Therefore:

- P0–P3 use greybox / debug visuals;
- P4 begins the sensory visual language of the interaction itself;
- after P4, ART0 produces one intentionally polished representative slice;
- P5 can then build its UI / complete loop using a validated visual language;
- later production art scales a known pipeline instead of inventing one.

## ART0 — expected questions

ART0 should answer:

- What is the final balance between 3D, 2.5D and illustrated assets?
- How are Soil / Clay / Sandstone / Bone authored and shaded?
- What lighting setup creates the warm natural-history atmosphere?
- How are the table, props and tools modeled / textured?
- What is the final visual treatment of cavities and material boundaries?
- How do particles / dust integrate without obscuring discovery?
- What is the UI production language: paper / wood / brass / scientific notebook?
- Which tools belong in the asset pipeline: Blender, image generation, texture generation, manual paintover, etc.?
- Can the style be reproduced consistently for dozens of blocks / fossils?
- What is the GPU budget on realistic Steam hardware?

ART0 is a **pipeline and style validation**, not mass asset production.

## Post-core confirmed systems

Once V0.1 passes:

### Block Variability Prototype

Create multiple seed-based / controlled variants to ensure repeated excavation does not become a memorized fixed depth sequence.

See [FUTURE_SYSTEMS.md](FUTURE_SYSTEMS.md).

### Meta Progression Prototype

Brainstorm and prototype:

- equipment unlocks / specialization;
- museum / collection progression;
- expertise / site access;
- difficulty bands and long-term motivation.

These are confirmed future pillars but intentionally deferred until the core exists.

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
- full art production / content scaling.

## Rules

- If excavation is not satisfying, fix excavation before adding content.
- If the target DA cannot be reproduced consistently, fix the art pipeline before scaling assets.
- Do not let procedural variability hide weak base gameplay.
- Prefer functional tool progression over pure percentage upgrades.
- Keep deterministic seeds / fixtures for QA even when production blocks become variable.
- Record every human gate in the Brain and reports.
