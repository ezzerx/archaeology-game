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

## Active work

Active branch: `prototype/p6a-visual-spike`  
PR: **#9 — P6A Visual Direction / Production Spike** (DRAFT)

P6A-1 Material Lab is complete and human-reviewed.

Result:
- the dynamic B-17 surface can support authored material rendering without breaking gameplay;
- none of P5/A/B/C is accepted as the final visual direction;
- B-style authored materials plus C-style projection/large-scale breakup remain useful technical hypotheses only.

## Next authorized action

**P6A1.5 — Soil Foundation Spike** is next.

Purpose:
> decide the basic gameplay role of Soil before investing in the P6A2 Hero Lookdev.

Compare:
1. current thicker structural Soil;
2. preferred thin loose-overburden model:
   Brush away surface dirt → reveal dirty/patinated Clay/Sandstone → structural excavation.

This spike should stay small. Do not turn it into final Soil particles/VFX/polish.

## P6A2 status

`P6A2 — Hero Lookdev / Target Match` is designed and documented on the active P6A branch, but **execution is paused until the Soil Foundation Spike is decided**.

The canonical P6A2 visual target pack is also prepared on the active branch.

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
- the hidden-cluster guard is not a perfect human visual-completeness oracle;
- final in-matrix vs extracted vs mounted/hybrid specimen destination remains a Macro Game Design question.

## Gameplay freeze during P6A

Unless a specifically authorized spike says otherwise:
- do not retune the P4 tool baselines;
- do not redesign P5 progression;
- do not reopen fragment/Forceps work;
- do not start museum/intake/meta implementation.

P6A is currently about defining a credible visual-production pipeline.

## Key pointers

- Stable mental model: `docs/ORCHESTRATION_HANDOFF.md`
- Documentation rules: `docs/DOCUMENTATION_POLICY.md`
- Durable decisions: `docs/brain/decisions.md`
- Roadmap: `docs/ROADMAP.md`
- Visual direction: `docs/ART_DIRECTION.md`
- Future systems / Soil hypothesis: `docs/FUTURE_SYSTEMS.md`
- P6A active implementation and reports live on PR #9 / `prototype/p6a-visual-spike`.

## Source precedence

1. Antoine's newest explicit instruction.
2. This status file for current phase/gate.
3. Active phase brief/report.
4. `docs/brain/decisions.md`.
5. Durable product docs.
6. Archived/historical reports.
