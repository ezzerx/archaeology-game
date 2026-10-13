# P6A3.2 — actual Tripo skull pilot, 2026-10-13

Antoine supplied the textured Tripo GLB after choosing manual Studio generation.
The ImageGen → Tripo Studio → Blender → Godot pipeline is now represented by an
actual bounded skull candidate. It is not a complete replacement skeleton or
approved final artwork. PR #11 is stacked on draft #10; no merge is authorized.

## Source and fit

- Uploaded original: `art/source/p6a32/b17-tripo-original.glb`, 15,383,008 bytes,
  SHA-256 `daf9aaf3715f7cdc7cf4f85bd614eb9377adf9b577961064e5fdf5b6922c270a`.
  189,252 triangles; albedo, normal and roughness/metallic atlas, each 4096².
- Studio options from Antoine’s screenshot are recorded in
  `TRIPO_STUDIO_IMAGE_TO_3D_SETTINGS.md`; a requested setting is not automatically
  verified by the GLB. Its metadata identifies Tripo, not the exact model version.
- Blender 4.3.2 inspection found open skull/rib spaces and no ground slab. The
  source is standing/front oriented, so the fitted subset is laid on the table.
- The extracted skull has 37,776 source triangles. A documented planar landmark
  fit follows existing B-17 authoring coordinates and immutable Bone ceilings;
  depth is reduced for the current shallow preparation block. Neither Bone data
  nor gameplay picking is regenerated from this asset.
- Working master: `art/source/p6a32/b17-tripo-skull-fitted.blend`.
  Runtime: `assets/p6a32/b17_tripo_skull.glb`, **20,775 triangles**, 2K textures.
  Original full-detail GLB preserved unchanged. Source files excluded from Godot
  import/export with `.gdignore`; runtime texture extraction is tracked normally.

## Presentation link

`scenes/p6a32_fossil_mesh.tscn` inherits the P6A3.1 candidate. **F6 compares the
Tripo skull with the existing Bone look without resetting the preparation.**
F7/F8/debug views retain the inherited look controls; non-mesh comparisons hide
the skull consumer. No new picking colliders or writes to exposure, cleanliness,
Condition, presets, session or Archive rules are introduced.

The mesh samples live native height, component/ceiling, Film and residue data.
Hidden cells use the exact exposure epsilon and are discarded. It draws only
Skull cells; no silhouette hints from mesh shadows are allowed. Condition wear
uses the native global value, and the marker consumes the actual cursor state.
The Tripo UV albedo and normal atlas supply surface detail, with restrained tint
and normal strength under the accepted lamp. Material roughness/Film remain
presentation consumers rather than a second cleaning/damage authority.

A 4× projection and conservative edge erosion define where the existing Bone
surface may be suppressed. Of **7,756 Skull cells, 4,497** are covered by the
candidate; the other **3,259 retain the existing Bone presentation**. There is no
blanket removal of native Bone outside the model silhouette. The historical
68k field-generated probe remains technical source only and is not the pilot
scene’s model or the exported game asset.

## Evidence

- **142 functional/regression checks pass** on the real Tripo pilot: inherited
  native trajectories and hashes, F6 state preservation, collision absence,
  imported budget, real UV textures, shared maps, coverage bounds, Condition/reset.
- **17 graphical checks pass** on the final toned version at 1280×720: intact
  matrix, exact half-Skull exposure, before/after geometry, actual camera-ray
  picking equality, Condition 85/70 and overview. Additional full-viewport PNG
  comparison: **zero changed pixels** with mesh on/off under intact matrix.
- Final evidence: `docs/dev/evidence/p6a32/tripo-tests.json`, `tripo-visual.json`,
  `hidden-viewport-comparison.json`, source/budget/coverage manifests and PNGs.
- Renderer: Godot 4.7.2 Compatibility / Mesa llvmpipe. Software rendering and a
  fixed QA fixture are not proof of home-PC performance or human play feel.
- Graphical captures are controlled native states, not a recorded complete playthrough.
  The clean comparison uses the existing rectangular Hero fixture (15% global
  reveal), so it deliberately does not show a fully excavated complete skeleton.

## Limits and next work

The skull is more detailed, but silhouette fitting is visibly rough. Native
cell edges and the transition to fallback Bone remain visible at close zoom;
the current authority constrains the source’s natural shape. Mineral cracks in
the source texture are not local damage measurements. Bones are not destructible.
No claim that the raw Tripo skeleton is ready to drop into the block is made.

First home review: F6 at 1×/3× during excavation, partial edges, Film removal,
Condition, picking/contact alignment and reset/Archive. Watch specifically for
unwanted holes, floating, z-fighting or inconsistent cursor contact. Reject the
candidate if those occur. The other bones remain the accepted current look.
Fit a bounded rib patch next only if the skull approach is visually useful;
do not silently migrate to a mesh-authored Bone field to hide fit problems.

Windows portable packaging and the private comparison page are the delivery
targets. Windows execution must be checked at home; Linux tests and PE/ZIP
verification cannot establish it. Audio is unchanged; Claude is reserved for
the future dedicated sound pass.
