# B-17 mesh — preparation, 2026-10-13

Preparation evidence retained below. Antoine subsequently supplied the GLB;
current candidate and remaining limits are in `P6A32_TRIPO_SKULL_PILOT_REPORT.md`.

Antoine authorizes the visual fossil pilot before a combined native home test.
The intended pipeline is ImageGen → Tripo Max Studio → Blender → Godot.
This report records preparation only; it does not approve a new fossil asset.

## Asset handoff

- ImageGen reference: `art/source/p6a32/b17-imagegen-reference.png`, derived from
  the actual partial B-17 field layout. It is an art guide, not a geometry bake
  or an anatomical validation.
- The shared Firecrawl browser reached guest Tripo Studio once, but the user's
  interactive link failed. Subsequent creation was explicitly blocked by
  insufficient Firecrawl credits. This says nothing about the Tripo Max balance.
- No Studio generation, API generation, API login or paid processing was run.
  CLI doctor only reported no configured Tripo API key; Studio/API accounts and
  credits remain separate.
- Antoine selected manual generation in his own Studio and will return a GLB
  with textures (ZIP accepted for an export containing multiple files).
- Owner-private handoff: https://archeology-private-playtest.toitou2.chatgpt.site/fossil.html
  The page has the original PNG, optional prompt and simple export instructions.

## Independent technical preparation

`tools/p6a32/export_b17_field.gd` exports the immutable ceilings and component
IDs from the native field. `build_binding_probe.py` makes closed technical
volumes matching that field. These volumes are not Tripo assets or final art.
Blender 4.3.2 reduced the probe to 68,238 triangles across skull, spine, ribs
and hind limb. Source generation is reproducible from the native field; local
high-resolution GLB, intermediate data and `.blend` are scratch artifacts.
Blender here is 4.3.2; this does not claim the earlier 5.2.2 production setup.

The separate pilot scene inherits P6A3.1. F6 switches its probe presentation.
The mesh material reads the same height, Bone ceilings, Film mask and Condition
as the game. Hidden-cell fragments are discarded and mesh shadows are disabled
to prevent hidden anatomy appearing through shadows. There are no added picking
colliders or writes to gameplay state. P6A3.1 toggles and native debug views are
retained. No matrix/tool/audio gameplay files are changed.

## Validation and remaining gate

Godot 4.7.2 headless scene smoke exited successfully with no shader errors after
correcting a conflicting uniform name. The first regression run found the stale full-resolution import (341,198
triangles); a completed editor reimport corrected the cache. The editor's local TCP listener was blocked by the sandbox, and an intermediate
scratch `.blend` was initially scanned before excluding the scratch directory.
These are not graphics or gameplay acceptance results.

`tests/run_p6a32_binding.gd` reuses the established native trajectories and
state hashes, then verifies presentation toggles, triangle budget, lack of
colliders, shared textures and Condition reset. Result after reimport: **141 checks, zero failures**, including all native
P6A3.1 trajectories. Evidence: `docs/dev/evidence/p6a32/binding.json` and
`probe-budget.json`. The imported runtime count is **68,238 triangles**.
This headless run does not prove graphical occlusion, edge coverage or visual quality.

Still required: inspect the returned Tripo GLB; verify/correct empty skull and
rib spaces; fit a bounded skull/rib patch in Blender; prove no hidden fragments,
holes, hovering or z-fighting at partial exposure and 1×/3× zoom; check actual
mouse picking; compare Film/Condition visually; capture evidence and measure
runtime cost. Whole-field mesh replacement is not accepted yet. The present
pilot suppresses the exposed heightfield under the mesh and therefore needs
particular scrutiny for silhouette gaps before it may be shipped.

The published Windows build remains P6A3.1. Do not replace it with this technical
probe, and do not claim the ImageGen reference is an in-engine improvement.

## Studio settings recorded from Antoine’s UI

See `docs/dev/TRIPO_STUDIO_IMAGE_TO_3D_SETTINGS.md` for exact visible option
labels, the B-17 source profile (HD / H3.1 / Ultra / triangles / 200k / 4K /
PBR / remove lighting, completion/8K/parts/multiview off), and how to adjust
future iterations. These are recommendations, not a generation already run.
