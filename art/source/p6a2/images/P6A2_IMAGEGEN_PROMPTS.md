# P6A2 ImageGen v02 prompt specification

Generation date: 2026-10-07.

Primary visual-language reference:
`docs/visual-references/p6a2/02-material-closeup.jpg`

Secondary reference:
`docs/visual-references/p6a2/01-gameplay-target.jpg`

The rejected P6A Material Lab atlas was deliberately NOT used as a reference.

## Common instruction

Create one diffuse-color source for a warm stylized 2.5D paleontology-preparation game. Hand-worked, tactile mineral feel; restrained; neither hyperreal photo nor exaggerated cartoon nor pixel art.

Requested: RGB sRGB, square 2048×2048, representing a 24×24 cm material patch, orthographic/perpendicular, one material only, intended to tile on X/Y, no central motif, no obvious periodic pattern.

Role: painted/albedo source only. Show intrinsic color, inclusions and pores by restrained color variation. No baked lighting, cast shadow, AO, reflection, hotspot, light gradient or vignette. No frame, text, tool, fossil anatomy, lamp or scenery. Do not copy the reference composition/geometry/lighting.

Actual ImageGen output for the selected set: **1254×1254**, documented without upscaling claims.

## Clay

Target file stem: `p6a2_clay_albedo_source_v02`

Palette direction: `#985932`, `#B5683B`, `#C78049`.

Compact natural terracotta/orange clay; grain 0.3–1 mm, rare mineral marks 1–3 mm, soft chromatic areas 10–35 mm.

Avoid marble, painted swirls, large cracked plates, lava, moss, large stones, black camouflage spots.

## Sandstone

Target file stem: `p6a2_sandstone_albedo_source_v02`

Palette direction: `#51483B`, `#6B5B46`, `#857055`.

Dark/desaturated compact mineral brown, clearly darker than Clay/Bone. Angular grain 0.5–2 mm, inclusions 2–6 mm, occasional fine mineral discontinuities, fracture-capable material feel.

Avoid white limestone, black/white granite, repeating strata, fake lit blocks, canyons/large holes, Clay-orange color.

## Soil

Target file stem: `p6a2_soil_albedo_source_v02`

Palette direction: `#3E2B1C`, `#59402A`, `#745536`.

Warm dark loose surface earth; grains/aggregates 0.4–2 mm, a few fragments up to 3 mm, irregular dispersion.

Avoid pebbles/paving, thick cross-section, roots, leaves, grass, large rocks.

## Bone

Target file stem: `p6a2_bone_albedo_source_v02`

Palette direction: `#B7A57F`, `#C5B38E`, `#D2C29D`.

Clean fossilized old ivory, warmer than plaster but not pure white; subtle pores 0.15–0.7 mm, very rare mineral inclusions below 1 mm, fine irregular striation.

Avoid bone silhouettes/anatomy, skulls, teeth, flesh, varnish, porcelain, pure white, baked dirt/Film/cleaning pattern.

## Plaster

Target file stem: `p6a2_plaster_albedo_source_v02`

Palette direction: `#AAA79D`, `#BCB7AB`, `#D3D0C5`.

Warm chalky grey plaster, less yellow than Bone; grains 0.2–1 mm, plaster irregularities 3–12 mm, rare subtle short fibers.

Avoid ivory/bone pores, marble, separate tiles/stones, drawn rim, large shadowed cracks, full uniform weave.
