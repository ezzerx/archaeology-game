# P3 Design Review — Precision Around Bone

**Status:** required P3 follow-up before merge  
**Date:** 2026-10-01  
**Branch:** `prototype/p3-fossil`  
**PR:** #4  
**P4 remains blocked.**

## Human feedback

P3 succeeds at the most important qualitative point:

> Once bone is perceived, the player wants to continue revealing it.

Three follow-up observations were reported:

1. Bone is currently difficult to distinguish from Clay in the greybox. This is primarily a DA/readability issue and is **not a P3 blocker**. It should be addressed in P4/P6 with material contrast, lighting, sound and discovery feedback rather than production art now.
2. Precision excavation around bone needs **camera zoom**.
3. The current Chisel/Bone Condition interaction makes damage too difficult to avoid. Because hard matrix above/around bone requires the Chisel, the player is frequently forced to strike the same area again after exposure. A careful player should be able to fully reveal a fossil while keeping condition near 100%.

Items 2 and 3 are gameplay issues and must be fixed before merging P3.

## Design decision A — Precision zoom

Add player-facing zoom to the fixed-orientation orthographic camera.

Requirements:

- mouse wheel controls zoom during normal play;
- camera orientation remains fixed at the canonical ~84°;
- no rotation;
- zoom range approximately **1.0× to 2.5–3.0×**, exposed as configurable values;
- smooth interpolation;
- strongly prefer **zoom toward cursor** so the excavation point under the mouse remains visually anchored;
- no input mismatch after resize/focus changes;
- picking remains exact at all zoom levels;
- provide a simple reset-to-default-view action if useful.

The current mouse-wheel debug tuning must move to clearly documented **developer-only controls** so normal play can reserve the wheel for zoom.

Do not add a full free-camera/navigation system in P3.

## Design decision B — Bone precision margin

The Chisel must not be the tool required to remove the final millimetres directly against hidden bone.

Add a configurable **precision margin / safety envelope** above each bone ceiling.

Suggested starting value:

- about **1.5–2.5 mm** of real block depth;
- start at **2.0 mm** and tune locally.

### Hidden bone + Chisel

For a bone-occupied cell that is not yet exposed:

- Chisel can remove bulk matrix normally;
- when the cell reaches `bone_ceiling + precision_margin`, Chisel structural removal on that cell clamps there;
- Chisel cannot cross the precision margin and therefore cannot accidentally expose/damage that hidden cell;
- reaching the precision margin may emit a one-time / throttled **delicate material nearby** debug event so the player understands why progress stopped.

No additional mutable full-resolution map is required if this state can be derived from current height + static bone ceiling.

### Precision finishing with Soft Brush

Soft Brush gains a **near-bone precision rule**:

- normally its P2 material effectiveness remains unchanged;
- on a bone-occupied cell inside the precision margin, Brush is allowed to remove the remaining thin matrix even if the geological material is Clay or Sandstone;
- removal rate should be deliberately slower / controlled;
- Brush clamps at the exact bone ceiling;
- Brush never damages condition.

This represents delicately clearing loosened / thin matrix around a fossil and gives the player a safe finishing tool.

The rule must apply only in the local near-bone margin, not make Brush generally effective on Clay/Sandstone.

### Exposed bone + Chisel

Once the bone cell is structurally exposed:

- Chisel direct impact centred on exposed bone may still apply the existing condition penalty (prototype target ~-3 points/impact);
- one scheduled impact = at most one damage event;
- surrounding matrix may still be chiselled with the centre off bone;
- bone height never changes.

This preserves Bone Condition as a meaningful consequence of careless behaviour while making **100% condition realistically achievable**.

## Discovery event semantics

The exact wording/UI remains debug-only.

Recommended behavior:

- reaching the Chisel precision margin can emit a subtle `delicate_material_nearby` / equivalent event;
- actual `bone_first_contact` / structural exposure occurs when Brush reaches the bone ceiling;
- specimen-level `Bone detected` should not spam.

If implementation simplicity strongly favors keeping the current event name, preserve one-time semantics and document it. Do not build P4 audio/VFX here.

## Bone readability

Do not spend P3 on final materials.

A small greybox-only contrast tweak is acceptable if necessary for testing, but the real solution belongs to:

- P4: sound, particles, discovery feedback, local readability;
- P6: final material, palette, lighting and art direction.

## Acceptance criteria for P3 follow-up

Before P3 can merge:

- [ ] normal mouse wheel zoom works;
- [ ] zoom remains precise at block center, edges, cavity slopes and bone;
- [ ] zoom does not alter the canonical camera orientation;
- [ ] debug tuning no longer conflicts with normal zoom;
- [ ] Chisel stops hidden bone cells at the configurable precision margin;
- [ ] Brush can safely remove only the final near-bone matrix through Clay/Sandstone;
- [ ] Brush cannot generally excavate Clay/Sandstone away from bone;
- [ ] a careful player can expose a meaningful region of fossil with **100% condition**;
- [ ] Chisel can still damage already exposed bone intentionally/carelessly;
- [ ] surrounding non-bone matrix remains fully excavatable;
- [ ] reset restores all precision/discovery state;
- [ ] P0/P1/P2/P3 regression tests remain green;
- [ ] new automated tests cover precision-margin clamp and safe Brush finishing;
- [ ] runtime cap stays 240 FPS / physics 60 Hz;
- [ ] P4/P5 remain unimplemented.

## Human retest

Antoine should specifically test:

1. zoom into a rib/skull edge and excavate precisely;
2. Chisel toward hidden bone until it stops at the safety margin;
3. switch to Brush and reveal the bone without condition loss;
4. trace a longer exposed section using Brush and surrounding Chisel work;
5. confirm condition can stay at 100%;
6. deliberately hit exposed bone with Chisel and confirm condition decreases;
7. zoom in/out while moving across cavities and verify cursor/picking alignment.

P3 remains open until this retest passes.
