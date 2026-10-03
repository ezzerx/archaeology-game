# P4 Final Feel — A/B Composition Target

**Status:** authorized human-design pass on `prototype/p4-game-feel`  
**Date:** 2026-10-03  
**PR:** #5 remains draft / unmerged  
**P5 remains blocked**

## Purpose

The A/B tests show that the latest build is not automatically the best-feeling build.

This pass deliberately composes the strongest behaviors from earlier P4 snapshots before any verticality / debris-physics experiment.

After this pass, Antoine will retest the core feel. Only if this composition is validated should the project move to a separate **P4-V Verticality / Debris Physics Spike**.

## Human A/B findings

### Chisel

**Version A had the best Chisel impact feeling.**

The reduction in chunks on later builds reduced fun and perceived force.

The problem was not the transient spectacle itself. The problem appeared when too much debris remained persistently and overloaded the scene.

Target:

> **Restore strong transient fracture spectacle without restoring persistent clutter.**

Keep:
- current fracture logic / material distinction;
- marks → cracks → chunks;
- current Bone Condition semantics.

Restore:
- more / larger transient break-off pieces similar in feel to P4-A.

Do not make those chunks persist as cleanup-state by default.

### Air Blower

**Version B had the best Blower feeling.**

Reason:
- debris visibly flew out of the excavation area;
- cleanup felt physical;
- the loop `break → blow → clean` was satisfying.

Target:

> Blower should feel as satisfying as Chisel.

Restore a visible amount of small movable debris/particles that can be blown outward, while keeping persistent clutter bounded.

### Soil

Latest-version Soil feel is preferred.

Keep it unless a regression is necessary to solve another target.

### Precision Pick

Latest-version Precision Pick concept is preferred.

It should remain:
- very small footprint;
- effective on Clay/Sandstone details;
- safe on Bone for the P4 prototype;
- poor for bulk work because of footprint, not because each hit is painfully weak.

### Tool visual angle

Earlier fixed tool angles were preferred to normal-following orientation.

Keep a stable camera-relative angle.

Solve clipping by offset/lift/shape placement rather than continuous orientation changes.

## Bone audio rule — new target

Replace the current repeated reveal-vs-hit semantics with:

### First protected bone contact only
- one small distinct Bone `tik`;
- zero damage;
- Bone detected.

### Later damaging direct hit on exposed bone
- strong Bone hit sound;
- condition damage.

### All other impacts
- play the MATERIAL sound.

Important consequence:

If the player strikes Sandstone beside Bone and the fracture reveals additional Bone cells after the first specimen discovery, the audible impact should remain **Sandstone**, not the small Bone reveal sound.

This prevents near-Bone Sandstone excavation from being dominated by Bone audio.

## Debris model

Separate **spectacle** from **persistent cleanup**.

### Transient fracture chunks
- can be numerous enough to feel powerful;
- can be visually substantial;
- should move away / fall / expire;
- are not persistent cleanup-state;
- should not permanently clutter the work area.

### Persistent mess
Keep restrained:
- fine dust;
- only enough small physical-looking debris to make cleanup satisfying.

The exact parameter balance must be tested, not inferred from “less debris is cleaner.”

## No verticality / real debris gravity in this pass

Do **not** add the new macro-stratigraphy or dynamic terrain-aware debris gravity yet.

Those are the next experiment:

### P4-V — Verticality / Debris Physics Spike

Planned questions:
- meaningful macro variation in layer thickness/depth;
- fossil depth variation within one deterministic block;
- debris gravity sampling the heightfield beneath moving pieces;
- falling/bouncing/sliding into cavities;
- Blower impulses moving debris through the relief.

P4-V is explicitly **not authorized until the P4 Final Feel composition is human-tested**.

## Final Feel acceptance target

The build should make these loops satisfying:

```text
Brush Soil
→ Chisel hard matrix with strong break spectacle
→ occasional Blower cleanup with visibly flying debris
→ Precision Pick around Bone
→ Brush/Blower cleanup
```

The player should not need to Blower constantly.

Chisel should feel powerful.

Blower should feel physically rewarding.

Near-Bone Sandstone should sound like Sandstone except:
- first protected Bone contact;
- actual damaging direct Bone hit.

## Scope

Do not:
- start P4-V;
- add macro-stratigraphy;
- add terrain-aware gravity;
- add Forceps;
- add P5 objectives/classification/completion;
- perform final tuning;
- start P6 art work.

PR #5 stays draft and unmerged until human validation.
