# Material Column — feasibility review (2026-10-09)

**Type:** static architecture evaluation of Claude's proposed N-slot, per-cell material stack. **No implementation GO.**
Reviewed on branch `prototype/p6a-visual-spike`, baseline commit `be34fe7a79f6321e328522fe72cdb2599e8c2456`.
This does **not** overrule `docs/brain/status.md`.

## Verdict

**Feasible, with substantial architectural, performance and game-design reservations.**
Claude correctly identifies the valuable target: material heterogeneity by location/depth, rather than memorizing three universal layers. Keeping the current **one editable height scalar per cell** is the right way to reuse the proved excavation engine, picking and Bone-ceiling semantics. But N-slot columns are not a quick variant of the existing 3-layer implementation.

**Recommendation:** do not implement in P6A3.1, 3D Fossil Lookdev, Sound Design or the lighting spike. Place a separate material-variability architecture/prototype **after P7/V0.1 core validation and before the post-core seeded Block Variability Prototype**. Make final N / representation choice only after simpler authored variability tests.

## Current implementation confirmed (live source)

| Contract | Current code / details |
| --- | --- |
| Height authority | `scripts/working_surface.gd`: `PackedFloat32Array _heights` + RF height image, 1024×640 map, monotone excavation |
| Hardcoded strata | `scripts/stratigraphy.gd`: exactly 3 definitions, RGF boundary image and packed **2 floats/cell** |
| Tool integration | `scripts/working_surface.gd:apply_segment`: explicit upper/lower branches and Vector3 effectiveness / resistance |
| Other work path | `scripts/stratigraphy.gd:remove_work` and `hard_work_to_bone` encode 3 layers |
| Tool data | `scripts/tool_definition.gd`: Vector3 effectiveness; material IDs loose_soil / compact_clay / sandstone |
| Fracture | `scripts/material_fracture.gd`: layer-specific stress/patches, `Vector3i(..., layer)` grouping and bottoms |
| Debris/remnants | `scripts/loose_debris.gd`, `scripts/micro_remnant.gd`: 1/2 hard-layer assumptions, counters/caps |
| Events/VFX/audio | `scripts/material_feedback.gd`: `last_removed` Vector3 and layer-coded branches; `scripts/material_audio.gd`, `scripts/reaction_profile.gd` |
| Shader | `shaders/surface_debug.gdshader`: boundary RG, 3-way material choice, Bone/Film masking; `scripts/p6a/hero_patch.gd` composes additional P6A2 material include `shaders/p6a2_materials.gdshaderinc` at runtime |
| Fossil | `scripts/fossil_field.gd`, `scripts/fossil_state.gd`: CPU ceiling/occupancy/exposure authority independent of stratum, but must stay compatible with any new work path |
| P6 geometry & Soil | `scripts/p6a/natural_matrix_profile.gd` and Soil Foundation: the accepted **thin loose Soil** and patchy contact deposits must not accidentally revert to thick structural Soil |

This is **not** a pure data model refactor. Rendering, physics feedback, per-tool behavior, visual material language and performance witnesses all depend on the legacy semantic layer number.

## Representation evaluation

### Claude's proposed N slots (e.g. 5 or 6)

Per 1024×640 column:
- ordered continuous vertical interface heights;
- material ID for each slot, varying spatially;
- pinched/zero-thickness slots for local lenses and discontinuities.

**Valid for columnar 2.5D geology**, including locally pinched lenses and different materials at a comparable depth, **provided** generated shapes are coherent, interfaces remain ordered and 2D IDs do not create grid/checkerboard artifacts.

Limits and invariants:
- only one editable surface height per column remains: true caves, overhangs, disconnected sub-surface voids and nested 3D structures remain impossible without a different engine representation;
- the material ID is **discrete** and should use nearest/cell-exact lookup for CPU/GPU parity, while interface height interpolation must match existing triangle/render/picking contracts;
- zero-width slots must be safely skipped without negative thickness, division by zero, or material flicker;
- distinguish **slot_index** (geological order) from stable **material_id** (properties, VFX, sound). They cannot remain the same integer;
- adjacent slots with the same material should collapse logically, or at least avoid a fake interface reaction;
- do not construct geologically implausible arbitrary inversions just because the model allows them;
- prefer preserving thin Soil as an explicit overburden/surface state rather than blindly adding it as a generic centimeter-thick hard stratum.

### Memory / GPU estimate — illustrative, not measured

Map size = **655,360 cells**.

Current two float32 boundaries: `655,360 × 2 × 4 B = 5 MiB` CPU data (and comparable raw GPU texture storage before driver allocations).

For six material slots, five float32 boundaries require **12.5 MiB**; six byte material IDs require **3.75 MiB**: **~16.25 MiB raw payload** for each resident copy, before staging duplication, alignment/packing and GPU representation. A pair of RGBAF textures plus one ID texture may cost more depending on allocation. This alone is not catastrophic, but GDScript hot-loop work and extra shader texture reads are more important.

Compatibility/OpenGL 3.3 is the current production baseline. Godot's Compatibility renderer does not support compute shaders; implement a CPU-precomputed static geological field plus regular shader sampling, not an assumed GPU compute pipeline. See:
- https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html
- https://docs.godotengine.org/en/stable/classes/class_image.html

### Hot-path rules

Precompute packed per-cell interfaces and material IDs; use contiguous typed arrays.
Never perform per-cell dictionary lookup, Resource calls, dynamic object allocation, arbitrary Image.get_pixel calls, or shader recompilation inside the brush/chisel hot path.

Piecewise work must spend resistance/effectiveness on **every crossed slot**, respect an impassable material, support Pick `stop_at_initial_layer`, and preserve Bone-ceiling clamp, exposure, Film and Condition exactly. MaterialFracture currently has a separate path and requires equivalent treatment.

Preserve CPU/GPU agreement for material lookup at pixel centers, boundaries and steep/near-zero lenses. Compare against a native independent oracle as well as controlled side-by-side captures.

## Major risk areas and required measurements

1. **Performance:** worst-case long Brush sweeps, repeated Chisel fracture clusters, Pick near interfaces/Bone, debris/micro-remnant detach, 1×/3× GPU shader cost; compare frame P95, edit CPU P95, draw calls, image upload/memory against frozen P5/P6A3 witness on same hardware. Frame budget at 240 FPS is 4.17 ms; earlier P6 benchmark already had action-frame P95s above that. Do not confuse high-end GPU average with CPU edit safety.
2. **Gameplay identity:** doubling the number of materials does not automatically improve the game. Every added material needs readable silhouette/albedo, tool strategy, distinct VFX/Foley and effort budgets.
3. **Completion/safety:** measure effort-to-Bone across *all* fossil cells (median/P90/P95/max), possible impassable regions, hidden-cluster coverage and no accidental exposure/damage bypass.
4. **Rendering:** avoid nearest-sampled IDs mixed with filtered heights producing false outlines/seams; preserve patina and distinct Bone/Film shading under Hero/Compatibility.
5. **Migration:** old tests, debugging presets, authored fixture B, P5 UI/event logs and progression accounting must remain valid; do not relabel old layer-index quantities as material IDs silently.

## Safer incremental alternatives, in preferred order

**A — Author a small set of distinct blocks using current three geological roles.**
Different thicknesses, depth gradients, Clay/Sandstone distribution and fossil placements per block; keep loose Soil semantics. This tests whether repeated preparation actually needs deeper column mechanics before rewriting the engine. Very low core risk; generator yet to be built.

**B — Separate a global material catalog from the three existing *slots*.**
Each authored block may select three compatible material types (e.g. choose among different structural matrix variants), while the same 3-slot geometry remains. Medium effort: VFX/audio/render mapping and semantic contracts still need care. Do not allow meaningless material/role combinations.

**C — Enable per-cell material ID overrides within the existing slots.**
Can produce lateral facies/pockets, with two continuous boundaries and local slot materials, before N slots. More complex than B because material lookup, rendering and fracture consistency must migrate; does not represent every vertically bounded lens.

**D — Full N-slot material columns.**
Only when authored B/C tests prove extra vertically stacked material changes are worth the engineering cost. N≈4–6 is a hypothesis, not a fixed design requirement.

## Proposed implementation stages (size / complexity)

| Stage | Work | Size |
| --- | --- | --- |
| 0. Preflight / oracle | Map all current 0/1/2 consumers, freeze golden gameplay/visual/perf baselines, choose N data encoding | M |
| A. 3-material N-slot equivalence | Generalize `Stratigraphy` + all CPU editing paths (including fracture/remnants) without new content. Byte-equivalent or explicitly justified numerical behavior. | **L** |
| B. Data-driven consumers/render | Material table, typed tool-effectiveness lookup, removed-by-material accounting, reaction/debris/audio lookup, GPU textures/shaders/hero includes. | **L / XL** |
| C. Authored variability witness | One thin/short lens or hard pocket with valid pinching, safe Bone and work-budget checks; side-by-side feel review. | **M / L** |
| D. Seeded procedural blocks | Constraint-based generator, validation across many seeds / anatomical cells, art variety and player tests | **XL** |

A and B may require interleaved migration for runnable intermediate states. Total **XL**, not a one-prompt polish ticket.

## Open design questions for the eventual workshop

- How many *meaningfully distinct* material families does the first game need? Are three enough if their **distribution** varies?
- Is soil always a separate thin Brush layer, or can new loose materials share its role?
- Must an identical material repeat at several depths in one vertical column, or only vary sideways?
- Do players read material differences via color, tool resistance, sound, fracture or all four?
- What share of blocks should include intrusions/lenses, and how do we prevent bad random seeds from becoming a tedious grind?
- Are the eventual fossil geometry/ceiling assets authored per specimen or rasterized from 3D mesh, and how does that interact with generated geology?
- What is the target performance hardware beyond the RTX 5080 development PC?

## Recommendation to the orchestrator

Keep the **product ambition** of non-predictable geology. Do not canonize N slots as the final architecture yet. After current P6A sensory/mastery and P7 core validation, prototype a few **authored varied three-material blocks** and test repeated play. If the UX genuinely requires more than three vertical intervals, authorize the isolated Material Column refactor with fixed behavior regression oracles **before** developing the seeded generator. Avoid solving unknown future design requirements with an oversized refactor today.
