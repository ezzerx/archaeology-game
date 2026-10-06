# Statut canonique

**Date:** 2026-10-06  
**Projet:** ArchaeologyGame (working title)  
**Source unique du statut courant:** ce fichier. Voir aussi `docs/DOCUMENTATION_POLICY.md`.

## Phases

- P0 Interaction ✅
- P1 Material / Relief ✅
- P2 Tools ✅
- P3 Fossil ✅
- P4 Game Feel / Verticality / Debris / Bone preparation ✅
- P5 Complete preparation session ✅ human-validated and merged
- **P6A Visual Direction / Production Spike ▶ active**
- P6B V0.1 Art Pass — not started
- P7 Tuning — not started

## Active branch / PR

Active branch: `prototype/p6a-visual-spike`  
PR: **#9 — P6A Visual Direction / Production Spike** (DRAFT)

P6A-1 Material Lab is complete and human-reviewed.

P6A1.5 Soil Foundation Spike is also human-reviewed.

## P6A1.5 human verdict

Antoine prefers the thin-overburden candidate.

Accepted direction:
- Soil = thin, partial, irregular surface dirt / overburden;
- Soil follows the substrate instead of creating a flat independent top plane;
- Brush removes the superficial dirt quickly;
- Clay/Sandstone is the real structural work surface;
- exact spike thickness/coverage values remain tunable, not final production constants.

Contact patina direction:
- original Clay/Sandstone color remains visible;
- contact history appears as irregular dirty deposits/stains;
- no uniform dark band / full-material recolor.

Visual quality of the spike is **not** approved as final art; only the Soil semantics and patina language are accepted.

Report on active branch:
`docs/dev/P6A15_SOIL_REPORT.md`

## Current gate / next authorized action

**P6A1.6 — Natural Matrix Geometry Spike** is next.

Reason:
with thin Soil, the remaining weakness is now obvious: the underlying Clay/Sandstone surface still reads too much like a broad horizontal plane.

Goal:
- create deterministic natural macro relief in the starting matrix;
- introduce broad undulations, shallow cavities/bowls, ridges, local shelves/steps and imperfect transitions;
- make Soil conform to that substrate;
- keep the excavation readable and gameplay-safe.

This is **internal matrix topography**, not the future outer jacket/block-silhouette system.

Detailed brief on active branch: `docs/dev/P6A16_NATURAL_GEOMETRY_BRIEF.md`.

Do not start P6A2 before this geometry spike receives human review.

## P6A2 status

`P6A2 — Hero Lookdev / Target Match` is prepared and documented on the active P6A branch, with a canonical reference pack.

Execution remains **blocked until P6A1.6 Natural Matrix Geometry is human-decided**.

P6A2 visual intent:
- cozy, warm, stylized natural-history preparation lab;
- authored tactile materials;
- irregular plaster jacket around the dynamic core;
- strong material readability;
- real lighting/lookdev rather than P6A-1 wallpaper-like test textures.

Do not start P6B before explicit human approval of the P6A2 Hero Patch.

## P5 closure baseline

Current prototype session:
- four tools: Brush / Chisel / Blower / Precision Pick;
- museum standard: global Exposure >=85% + Cleanliness >=85% + hidden-cluster guard;
- optional Fine Preparation at95/95;
- Condition shown qualitatively: Excellent / Good / Fair / Damaged;
- Archive or optional further cleaning;
- dormant fragment/Forceps experiment is not part of normal play.

Accepted P5 watchpoints, not blockers:
- Cleanliness may decrease when newly exposed dirty Bone enlarges the exposed-Bone denominator;
- hidden-cluster coverage is not a perfect human visual-completeness oracle;
- final in-matrix vs extracted vs mounted/hybrid specimen destination remains a Macro Game Design question.

## Gameplay freeze during P6A

Unless a specifically authorized spike says otherwise:
- do not retune the P4 tool baselines;
- do not redesign P5 progression;
- do not reopen fragment/Forceps work;
- do not start museum/intake/meta implementation.

P6A is currently about proving the geometry + visual-production foundation before art scaling.

## Key pointers

- Stable mental model: `docs/ORCHESTRATION_HANDOFF.md`
- Documentation rules: `docs/DOCUMENTATION_POLICY.md`
- Durable decisions: `docs/brain/decisions.md`
- Roadmap: `docs/ROADMAP.md`
- Gameplay loop: `docs/GAMEPLAY_LOOP.md`
- Visual direction: `docs/ART_DIRECTION.md`
- Future systems / Soil hypothesis: `docs/FUTURE_SYSTEMS.md`
- Active P6A implementation and reports live on PR #9 / `prototype/p6a-visual-spike`.

## Source precedence

1. Antoine's newest explicit instruction.
2. This status file for current phase/gate.
3. Active phase brief/report.
4. `docs/brain/decisions.md`.
5. Durable product docs.
6. Archived/historical reports.
