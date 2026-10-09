# B-17 Fossil Mesh Lookdev — proposed next visual spike (2026-10-09)

**Status: strongly desired by Antoine; concept and technical approach recorded, but NO implementation GO yet.**
This is a *fossil still inside the excavated preparation block*, not a mounted museum skeleton.

## Why

After the first promising friend playtest, the current flat/heightfield-presented Bone has become an obvious visual limitation. A properly modeled/textured **3D fossil skeleton with believable anatomical volume** should substantially improve the sense of discovery, material quality and overall look.

Current code facts:
- `scripts/fossil_field.gd` authors partial B-17 anatomy on a 1024×640 raster: skull, vertebrae/tail, ribs and hind limb.
- Each occupied cell has an immutable **Bone ceiling** and anatomical component ID; this is the physical safety/exposure authority.
- `scripts/fossil_state.gd` owns exposure and Condition; `scripts/bone_surface_film.gd` owns cleaning; `shaders/surface_debug.gdshader` currently colors the **same displaced matrix heightfield** when Bone is exposed.
- `scripts/excavation_block.gd` and `scripts/relief_surface.gd` share the current heightfield, picking and texture upload. Inserting a free-standing Tripo skeleton mesh as a full visible prop would violate occlusion, exposure and geometry alignment.

## Suggested two-track strategy

### First: a focused visual pilot (preferred near-term)

Produce an authored **B-17-fitted 3D fossil**:
- start from a human-approved 3D-ready anatomical/art reference matching the *actual partial B-17 pose and component arrangement*, not just any dinosaur skeleton;
- Tripo/Blender are possible source-asset tools, but an automatically generated skeleton is **not** trusted without inspection/correction of slender ribs, joints, teeth, vertebrae and pose;
- inspect a small targeted skull/rib or vertebra patch first, then expand if real gameplay exposure works;
- keep the existing CPU Bone field/exposure/Condition/Bone Film completely authoritative;
- make any visual mesh reveal/clip from the **real exposed cell mask and actual matrix height**, not a fake global reveal animation;
- no Bone mesh through intact Clay/Sandstone, no z-fighting/obvious hovering, no new picking collisions or tool occlusion;
- allow Bone Film and damage variation to affect the visible 3D material without changing their gameplay rules.

Technical acceptance:
- all P5 exposure/cleanliness/condition/reset/Archive results identical at same inputs;
- precise progressive revelation, including partial edges/cavities and zoom 1×/3×;
- actual mouse-ray picking stays on the existing working surface;
- Material, Bone Film, task lighting and weathering coherent with P6A2 art;
- performance/draw-call/triangle/texture budgets measured.

If visual-only overlay cannot satisfy these constraints, **stop the pilot and redesign the authority link**; do not pretend an unrelated statically visible skeleton mesh is a solved upgrade.

### Later: mesh-authored Bone field (more robust, deeper architecture)

For eventual multiple realistic specimens, a promising system is **author 3D anatomy first**, then bake/project its topmost Bone surface, 2D occupancy and component IDs into the existing CPU-compatible fossil-ceiling maps. That keeps Bone exposure, work clamp, shader and picking in sync, but is a much larger migration requiring independent oracles. It is not implicitly authorized by the initial visual pilot.

## Relationship to mastery/readability

A better 3D skeleton will not alone solve:
- 94% Cleanliness that looks fully clean;
- progressive Condition damage;
- visible dust removal by Brush.

These should be designed to **work through the same Bone Film and Condition data**, so the eventual fossil visual remains legible and reactive. Coordinate with P6A3.1 rather than duplicating those systems.

## Suggested sequencing

1. **P6A3.1 Mastery/Readability quick fixes** (existing plan).
2. **Focused B-17 Fossil Mesh Lookdev spike** (proposed addition, separate GO).
3. Dedicated **Sound Design & Music** pass.
4. **Interactive Task Light** spike.
5. New human playtest and decide whether the mesh direction is visually worth scaling.

This order is a proposal, not automatic authorization. Keep jacket/footprint, Clay surface breakup, structural stratigraphy, P6B and P7 out of the mesh visual pilot.
