# P3 Design Review — Scope Clarification

**Status:** required P3 follow-up before merge  
**Date:** 2026-10-01  
**Branch:** `prototype/p3-fossil`  
**PR:** #4  
**P4 remains blocked.**

## Human feedback

P3 succeeds at the most important qualitative point:

> Once bone is perceived, the player wants to continue revealing it.

Three observations were reported:

1. Bone is currently difficult to distinguish from Clay in the greybox.
2. Precision excavation around bone needs **camera zoom**.
3. Bone Condition is currently difficult to preserve because the prototype Chisel still removes matrix in a point-by-point heightfield manner.

## Scope correction

Observation 3 is real, but **must not be prematurely solved inside P3 with a new precision-margin mechanic**.

The original V0.1 design already expects later gameplay/game-feel work to change how materials react:

- Clay should break / peel in pieces;
- Sandstone should crack and detach chunks;
- Chisel should feel impact-based rather than like a pixel eraser;
- P4 owns debris, fracture feedback, tool physicality and material reaction.

Therefore the current unavoidable-damage behavior may be partly an artifact of an unfinished P4 interaction model.

### Design rule

> Do not add an earlier-phase workaround for a problem that a later already-planned phase is explicitly expected to reshape, unless the problem blocks validation of the current phase.

P3 only needs to prove:

- fossil can be hidden and progressively exposed;
- bone cannot be excavated through;
- first contact can be detected/protected;
- condition can decrease from a direct Chisel hit on exposed bone;
- exposure/picking/reset are technically correct.

P3 does **not** need to solve the final skill model for preserving 100% condition.

## Required P3 change — Precision zoom

Camera zoom remains a valid P3 requirement because it is an independent precision/navigation need and will remain useful regardless of the final Chisel fracture model.

Add player-facing zoom to the fixed-orientation orthographic camera.

Requirements:

- mouse wheel controls zoom during normal play;
- camera orientation remains fixed at the canonical ~84°;
- no rotation;
- configurable range, approximately **1.0× to 2.5–3.0×**;
- smooth interpolation;
- strongly prefer zoom toward cursor so the excavation point remains visually anchored;
- picking remains exact at every zoom level;
- resize/focus behavior remains robust;
- move existing wheel-based debug tuning to developer-only bindings;
- no free-camera system.

## Bone Condition — defer final avoidance model to P4

Keep the existing P3 semantics for now:

- first hidden contact protected;
- Brush / Blower safe;
- direct Chisel hit on already exposed bone can reduce condition;
- bone cannot be excavated through.

Document explicitly in P3_REPORT that:

- **condition balance is not final**;
- a careful 100%-condition excavation is not yet an acceptance criterion;
- P4 must revisit condition avoidance after Chisel/material fracture behavior exists.

Do not add the previously proposed 2 mm precision margin or near-bone Brush override in P3 unless a later explicit decision re-authorizes it.

## P4 design target carried forward

P4 should reassess Bone Condition only after implementing the intended material reactions:

- impact marks / cracks;
- clay pieces / plates;
- sandstone chunk detachment;
- physical-looking Chisel interaction;
- debris / residue / feedback;
- clearer bone contact cues.

At that point, evaluate whether:

- chunk fracture naturally makes careful excavation possible;
- fracture propagation should stop or weaken near bone;
- a safety margin is still needed;
- a precision tool / technique is needed later;
- damage amount / rules need retuning.

No solution is canonized yet.

## Bone readability

Bone-vs-Clay readability is not a P3 blocker.

Real solution belongs mainly to:

- P4: sound, particles, contact feedback, material readability;
- P6: final bone/clay material, roughness, lighting, palette and art direction.

A tiny greybox contrast tweak is allowed only if required for testing.

## P3 acceptance criteria after this clarification

Before P3 can merge:

- [ ] normal mouse-wheel zoom works;
- [ ] zoom remains precise at center, edges, cavity slopes and bone;
- [ ] camera orientation remains fixed;
- [ ] debug tuning no longer conflicts with normal zoom;
- [ ] existing fossil reveal/contact/condition logic remains correct;
- [ ] first hidden contact remains protected;
- [ ] Chisel can still damage already exposed bone;
- [ ] Brush / Blower remain safe;
- [ ] reset remains exact;
- [ ] P0/P1/P2/P3 regression tests remain green;
- [ ] runtime cap stays 240 FPS / physics 60 Hz;
- [ ] P3_REPORT clearly records Bone Condition avoidance as a P4 design issue;
- [ ] no P4 system is implemented yet.

## Human retest

Antoine should test:

1. zoom into skull/rib details;
2. excavate while zoomed and verify precise picking;
3. zoom in/out around cavities and bone;
4. confirm first contact / exposure still works;
5. confirm Chisel still damages already exposed bone;
6. confirm Brush / Blower remain safe;
7. judge only whether P3's discovery/exposure tech works — **not yet whether 100% condition is fairly achievable**.

P3 remains open until this zoom retest passes.
