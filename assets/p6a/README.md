# P6A Material Lab — source texture

`material-atlas.png` is an **AI-generated painted source atlas**, created with the
built-in `imagegen` tool on 2026-10-06 for this spike. It is not an approved final
art asset or a set of artist-authored PBR scans. No concept-board pixels were used
as textures. The full prompt is in `generation-prompt.txt`.

Quadrants: Soil / fresh Clay / Sandstone / clean ivory Bone. Bone Film is **not**
baked into this image: the original dynamic P4 map and spot coverage remain the
sole film mask. Candidate B uses one mirrored, inset sample; C adds a wall sample
and broad shader variation. Color grading, roughness and subtle derivative bump
are in `shaders/p6a_materials.gdshaderinc`. No authored normal/roughness maps yet:
scalar roughness plus luminance variation and derived bump are the cheap proof.

Actual output: **1254×1254 RGB**, 3,097,732 bytes on disk (the prompt requested
1024×1024; the delivered dimensions are retained). A quadrant is 627×627 before
the sampling inset. Conservative texture budget: **8 MiB RGBA8 including
mipmaps** (6 MiB RGB8; isolated allocation not measured); shared by B/C and
preloaded by the lab, including in P5/A comparisons.

Lossless import + mipmaps, no resize. Mirrored quadrant sampling is deliberate
temporary seam handling, not a claim that the source is perfectly tileable.
Production would need genuine repeatable tiles, calibrated microheight/roughness,
and review at all zooms. One shared atlas for all blocks, no texture rebake after
an excavation action. The shader adapter is restricted to the lab scene.
