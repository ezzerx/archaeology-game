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

## Delivery verification

The final runtime source is `a0ae7f6ed85e227d1c5994b6f6d2be13b7105acb`.
Official Windows export: 94,717,301-byte portable ZIP, SHA-256
`a5692c2a28f0fa085b466c0c6545b34eadd72282ded3b7604cb9a69207b2cad2`.
PE x64 signature, ZIP CRC and multipart SHA-256 all verified. The exported PCK
passes 10 Linux-engine smoke checks, including actual main scene, imported skull,
2K atlas, F6 and F7 transitions, retained coverage and matrix-height preservation.
Windows execution remains unverified. Export helpers: `tools/p6a32/export_native.py`
and `Export-Playtest.ps1`; repo launch: `Launch-P6A32-Fossil-Mesh.ps1`.

Three steady-state software-render budget checks pass: 49 → 51 draw calls and
2,653,318 → 2,674,093 primitives with mesh off/on (exactly 20,775 additional
triangles). Resident texture monitor: 159,009,275 bytes in both states because
the source asset remains loaded while hidden. Ten frame samples per state under
llvmpipe are extremely slow and affected by simultaneous cloud work; do not
project these frame timings onto the reference PC. Physics 60 Hz / render cap
240 remain set. Initial budget guard failure was a QA fixture/session flush
ordering issue; settling the fixture before the baseline resolves it. It was
not a native trajectory regression.

The site landing page now opens the screenshot review directly. Its local
browser check confirms no canvas, engine script, WASM/PCK or native ZIP download
on opening the review, and no mobile horizontal overflow. Enlarged details use
the original screenshot images within SVG viewports; complete screenshots are
linked and lossless originals remain in evidence. Owner-only access is preserved.

Private screenshot/native delivery succeeded: Site source commit
`0ada9a0247a6191e8925d132078076566b0fbc8f`, deployment
`appgdep_6ace44f191c4819195fe2ad76f96050a`.
Review: https://archeology-private-playtest.toitou2.chatgpt.site/review.html#crane
Native: https://archeology-private-playtest.toitou2.chatgpt.site/native.html
