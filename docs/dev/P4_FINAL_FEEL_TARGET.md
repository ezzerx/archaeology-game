# P4 Final Feel — A/B Composition Target

**Status:** Final Feel targeted bugfix: Brush proxy performance and first direct Bone contact; human retest pending on `prototype/p4-game-feel`

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

### First protected DIRECT bone contact only
- one small distinct Bone `tik`;
- zero damage;
- Bone detected.

### Later damaging direct hit on exposed bone
- strong Bone hit sound;
- condition damage.

### All other impacts
- play the MATERIAL sound.

Important consequence:

If the player strikes Sandstone beside Bone and the fracture reveals Bone cells, including the very first discovery, the audible impact remains **Sandstone**. Discovery never consumes direct-contact protection.

`FossilState.first_contact` remains the discovery/UI state. A separate `first_direct_contact_consumed` starts false and resets with the specimen. Only a powered damaging-tool impact whose exact centre reaches exposed Bone can consume it. Its event sets `bone_protected_contact = true`, with zero damage and the small tik. Later hits on an already exposed centre retain the existing three-point damage and big DING. Pick, Brush and Blower never consume protection.

An impact that first reveals Bone at its own centre may consume protection safely; an off-centre reveal cannot. Once protection is consumed, revealing another previously hidden centre remains damage-free on that uncovering impact, retaining the historical condition rule and worked-material sound.

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

## Implementation — 2026-10-04

The local A/B worktrees identify **A = `42ec46d`**, **B = `c25b44f`**, and the recent simplification **E = `f527139`**. These are the composition references, not branches to merge or reset over the current work.

| Source | Final Feel composition |
|---|---|
| A: Chisel spectacle | 3–6 mm transient pieces, Clay height 24% / Stone 70% of width, depth 100%; 1–5 pieces per broken patch according to removed cells (`ceil(cells / 10)`). |
| B: visible cleanup | Hard crumbs use 4.5 mm nominal maximum width and 32% height; existing directional flight and boundary ejection retained. |
| A/B: tool silhouette | Fixed Euler `(0.5, 0, -0.62)` for every tool; exact static tip and static body with cheap vertical translation. |
| Recent E | Soil/Brush/audio, contextual dust and dirty Bone ivory, Pick micro-impacts, local retention budget, camera, fracture and Bone Condition preserved. |
| Corrected locked rule | Small Bone tik only on the first direct damaging-tool contact per specimen/reset, with zero damage. Discovery alone keeps material audio and does not spend protection. Large Bone clack only when a later direct Chisel hit actually reduces condition. |

Transient pieces start at the estimated top of the removed plate (`volume / cells` above the new floor), move outward at 0.09–0.14 m/s and upward at 0.035–0.10 m/s, then expire after **0.51–0.69 s**. Four existing MultiMesh pools, 48 slots each; no persistent conversion or new physics. This replaces E's at-most-three 1.2–2.4 mm chips.

Persistent **quantities are unchanged**: at most two crumbs per 24×24-texel bucket, 8% retention, 0.02 capacity per crumb; overflow feeds fine dust. Only hard-crumb presentation grows. Soil keeps its 1.4 mm / 14% dimensions. Blower still changes zero structural height and zero condition; `debris_ejected` is intact.

## Targeted performance correction — 2026-10-04

Human Brush/Soil input reported <10 FPS. Before fixing, compare identical inputs with proxy on/off, stationary, moving over intact Soil and moving in an excavated area, at 1×/3×. Measure controller edit, WorkingSurface, proxy, height/residue uploads and particle/debris feedback separately. [P4_REPORT](P4_REPORT.md) records the measured regression and distinguishes it from the unreproduced <10 FPS report.

Priority: fluidity, stable A/B angle, exact readable work point, then reasonable anti-clipping. `ToolRoot/Tip` stays at the exact hit; `ToolRoot/Body` uses static meshes and a vertical offset. Split meshes/normals only at initialization. At most twelve height probes per changed pose; no runtime mesh reconstruction, face scanning, heightfield area scan or vertex-array duplication. Recoil moves only Body and reuses clearance. Small rare intersections or a separated tip/body in extreme cavities are accepted prototype limits.

Performance gate: at least 60 FPS locally; paired proxy on/off throughput and a CPU test of bounded probes/static geometry prevent a hardware-dependent FPS-only regression test. Gameplay/tool tuning, Chisel spectacle, Blower, debris quantities, Soil, Pick, Dust and camera remain unchanged.

Limits: transient launch height is an average from the removed patch, not reconstructed fragments; flight does not collide with changing terrain. Human retest is now **exactly three points** in [P4_REPORT](P4_REPORT.md#retest-humain--exactement-trois-points): Brush performance, Bone protection, quick Chisel/Blower/Pick sanity.

Measurements and evidence: [P4_REPORT](P4_REPORT.md). **STOP after delivery. P4-V and P5 remain blocked; PR #5 remains draft and unmerged.**
