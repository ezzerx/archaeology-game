# P6A2 ImageGen material sources — selected set v02

Selected on 2026-10-07 by the Archeo orchestrator after direct comparison with:
- `docs/visual-references/p6a2/02-material-closeup.jpg` (primary)
- `docs/visual-references/p6a2/01-gameplay-target.jpg` (secondary)

These files replace the rejected P6A Material Lab atlas as the visual source for the P6A2 material correction.

## Important source facts

ImageGen returned **1254 × 1254** square RGB images, not the requested 2048 × 2048.
No upscale is presented as a genuine 2048 source.

A 2×2 visual tile check found no obvious hard seam on the selected images, but ImageGen does not prove mathematically exact edge identity. Re-check repeat behavior in the real Godot material at 1× and 3×.

The ChatGPT outputs were PNG originals. The current chat-to-GitHub binary bridge cannot preserve those original PNG bytes directly, so this folder versions **high-quality 1254 px JPEG mirrors (quality 95)** for Codex access. Original PNG dimensions and SHA256 values are recorded below. Treat the mirrors as lookdev sources, not archival replacements for the original PNG bytes.

Do not claim the repo mirrors are the original PNG files.

## Selection review

| Material | Repo mirror | Original PNG size | Original PNG SHA256 | Review |
| --- | --- | ---: | --- | --- |
| Clay | `p6a2_clay_albedo_source_v02.jpg` | 1254×1254 | `abd891964f124a811ebb16a1419e61e4f2dd6dcf8d80c9ad4d3140707c719929` | **Accepted.** Strong terracotta identity, fine mineral/grain variation, no marble/camouflage reading. |
| Sandstone | `p6a2_sandstone_albedo_source_v02.jpg` | 1254×1254 | `fc273023b594fa80531ec27dbc339977fd09284cf0defc24156679812ef62641` | **Accepted with material-side correction.** Grain/fracture language is useful, but source is a little too light/golden versus reference; darken/desaturate locally rather than regenerate unless the in-engine test still misses. |
| Soil | `p6a2_soil_albedo_source_v02.jpg` | 1254×1254 | `ece447dd6d4171d26768d820436bf813aae0983c54c7bfb7ac1675f3c14e714d` | **Accepted.** Dark warm loose granular earth and good separation from Clay. |
| Bone | `p6a2_bone_albedo_source_v02.jpg` | 1254×1254 | `b39a3dbc545c43f2b1f66d04dc6c2bdedb50a58294cfafddf4073a0ab9b19404` | **Accepted with material-side correction.** Good porous old-ivory detail, but slightly too yellow/bright; cool/desaturate modestly in Godot while preserving separation from plaster. |
| Plaster | `p6a2_plaster_albedo_source_v02.jpg` | 1254×1254 | `3a6966eb7c5414178910ea5de2579b9a3013017559d5997f926aa2ed3c7a776d` | **Accepted.** Chalky warm grey, clearly distinct from Bone, useful irregular plaster character. |

## Integration intent

These are **albedo/color sources only**:
- no gameplay mask;
- no authoritative height;
- no physical displacement;
- no baked task-light direction should be inferred from them.

The desired final quality comes from:
1. coherent material albedo,
2. restrained roughness / normal treatment,
3. real P6A1 geometry and later surface breakup where authorized,
4. the P6A2 local task light.

Runtime derivatives should live under:
`assets/p6a2/textures/<material>/`

The selected sources should be evaluated in the real Hero Patch at 1× and 3× before any claim of final material approval.
