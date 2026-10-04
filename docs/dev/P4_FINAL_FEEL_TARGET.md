# P4 Final Feel — A/B Composition Target

**Status:** P4 Final Feel component micro-fix: one protected direct contact per fossil component, with unchanged human-validated baselines, on `prototype/p4-game-feel`

**Date:** 2026-10-04
**PR:** #5 remains draft / unmerged  
**P5 remains blocked**

## Purpose

The A/B tests show that the latest build is not automatically the best-feeling build.

This pass deliberately composes the strongest behaviors from earlier P4 snapshots before any verticality / debris-physics experiment.

The final human test supplied the baselines below. This lock prepares P4 for closure; a separate **P4-V Verticality / Debris Physics Spike** still requires explicit authorization.

## Human-validated resource baseline — final lock

**P4 human-validated baseline — tuning final deferred to P7.**

| Tool | Radius | Power | Falloff |
|---|---:|---:|---:|
| Soft Brush | 40 | 0.70 | 1.25 |
| Chisel | 22 | 0.64 | 2.25 |
| Air Blower | 60 | 0 | 1.00 |
| Precision Pick | 7 | 0.24 | 1.50 |

These are persisted in the tool resources and loaded without debug adjustments at launch; specimen reset retains those values. Existing in-session debug/reset behavior is unchanged. Blower `residue_clear = 2.5`, cadences (Chisel 4.5 Hz, Pick 6 Hz), effectiveness, residue generation, Bone damage, material resistances and fracture thresholds remain unchanged. The resource lock established these values and the pre-impact eligibility rule; the subsequent component micro-fix preserves every resource and only scopes protection by component, with READY/USED in the existing F1 panel.

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

### First protected DIRECT contact per fossil component, on Bone already exposed before impact
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

`FossilState.first_contact` remains the discovery/UI state. Protection is **one protected direct contact per fossil component**. `direct_contact_consumed` is a five-byte array indexed by `FossilField.Component`: NONE is unused, then **Skull / Spine / Ribs / Hind Limb**. Reset clears all flags. B-17 therefore has **four protected contacts maximum per reset**, one for each component; all ribs share RIBS and all vertebrae share SPINE. A new cell, individual rib/vertebra or revealed area grants no extra protection.

`apply_impact` still snapshots `was_exposed_before_impact` before any mutation. Only a powered damaging-tool impact whose exact centre was already exposed in that snapshot can consume the protection of `field.component_ids[index]`. Its event sets `bone_protected_contact = true`, with zero damage and the small tik. Every later direct hit anywhere on that same component retains the existing three-point damage and big DING. Pick, Brush and Blower never consume protection. **Bone Condition remains global to the specimen**, with no additional bars: Skull → Skull → Ribs → Ribs gives **100 → 97 → 97 → 94**.

This component rule is a **P4 baseline, open to reevaluation during P7 tuning**. The existing F1 component rows show READY/USED for developer inspection only. Material audio, events, tools, fracture and all other feel remain unchanged.

An impact that first reveals Bone, **even at its own centre**, never consumes any component protection, never sets `bone_protected_contact`, does no damage and keeps worked-material audio. The old centre-reveal consumption rule is abandoned. Post-impact exposure, newly exposed cells, discovery and exposure counts never decide consumption. Within a fresh component: hidden centre revealed → material sound / condition unchanged / protection available; next visible-centre hit → small tik / condition unchanged / that component consumed; following hit → DING / −3 global condition. Reset rearms all four protections.

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
| Corrected locked rule | One protected direct contact per fossil component: small tik and zero damage on the first already-visible centre hit for Skull, Spine, Ribs and Hind Limb. All reveals keep material audio and do not spend protection. Later direct hits on that component reduce global condition by three and play the large Bone clack. |

Transient pieces start at the estimated top of the removed plate (`volume / cells` above the new floor), move outward at 0.09–0.14 m/s and upward at 0.035–0.10 m/s, then expire after **0.51–0.69 s**. Four existing MultiMesh pools, 48 slots each; no persistent conversion or new physics. This replaces E's at-most-three 1.2–2.4 mm chips.

Persistent **quantities are unchanged**: at most two crumbs per 24×24-texel bucket, 8% retention, 0.02 capacity per crumb; overflow feeds fine dust. Only hard-crumb presentation grows. Soil keeps its 1.4 mm / 14% dimensions. Blower still changes zero structural height and zero condition; `debris_ejected` is intact.

## Targeted performance correction — 2026-10-04

Human Brush/Soil input reported <10 FPS. Before fixing, compare identical inputs with proxy on/off, stationary, moving over intact Soil and moving in an excavated area, at 1×/3×. Measure controller edit, WorkingSurface, proxy, height/residue uploads and particle/debris feedback separately. [P4_REPORT](P4_REPORT.md) records the measured regression and distinguishes it from the unreproduced <10 FPS report.

Priority: fluidity, stable A/B angle, exact readable work point, then reasonable anti-clipping. `ToolRoot/Tip` stays at the exact hit; `ToolRoot/Body` uses static meshes and a vertical offset. Split meshes/normals only at initialization. At most twelve height probes per changed pose; no runtime mesh reconstruction, face scanning, heightfield area scan or vertex-array duplication. Recoil moves only Body and reuses clearance. Small rare intersections or a separated tip/body in extreme cavities are accepted prototype limits.

Performance gate: at least 60 FPS locally; paired proxy on/off throughput and a CPU test of bounded probes/static geometry prevent a hardware-dependent FPS-only regression test. The proxy correction preserved gameplay/tool tuning; the final lock subsequently persists only the human-validated baselines above. Chisel spectacle, Blower, debris rules, Soil/Pick behavior, Dust and camera remain unchanged.

Limits: transient launch height is an average from the removed patch, not reconstructed fragments; flight does not collide with changing terrain. [P4_REPORT](P4_REPORT.md#retest-humain--exactement-trois-points) retains three short checks for closure: baseline Brush performance, centre-reveal Bone protection and Chisel/Blower/Pick sanity.

Measurements and evidence: [P4_REPORT](P4_REPORT.md). **STOP after delivery. P4-V and P5 remain blocked; PR #5 remains draft and unmerged.**
