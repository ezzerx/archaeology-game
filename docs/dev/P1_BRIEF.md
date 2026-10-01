# P1 — Material System / Excavatable Relief

**Status:** authorized after human validation of P0  
**Date:** 2026-10-01  
**Engine:** Godot 4.7.2 stable Standard, GDScript  
**Gate:** P2 must not start before human validation of P1

## Goal

Transform the P0 scalar working surface into a real **excavatable material surface** with visible depth, stratigraphy and distinct resistance.

P1 must prove that the player can carve a convincing cavity into the block while preserving precise mouse-to-surface interaction.

P1 is still a technical/gameplay prototype. It is **not** an art pass and does not implement the final tools.

## Canonical P1 outcomes

1. Surface state has explicit depth / height semantics.
2. Excavation creates visible depressions / cavities, not only a color change.
3. Picking remains visually aligned with the rendered surface at shallow and deep excavated regions.
4. Three core materials exist:
   - Loose Soil
   - Compact Clay
   - Sandstone
5. Hard Rock may be included only as a small secondary region if it does not expand scope.
6. Materials have clearly different resistance under one generic debug excavation tool.
7. Layer transitions are spatially readable and deterministic.
8. Reset returns the exact initial stratigraphy / height state.
9. P0 input robustness remains intact.
10. Normal interaction remains compatible with 60 FPS on the local test PC.

## Data model guidance

Prefer preserving the P0 principle of a **single runtime-dirty scalar surface map** if practical.

A strong default model is:

- P0's 1→0 scalar becomes normalized `surface_height` or equivalent;
- static stratigraphy data defines per-cell material boundaries;
- current material is derived from height against those boundaries;
- material definitions provide resistance and debug color;
- static boundary / region maps should not be re-uploaded every frame.

This is guidance, not a mandatory implementation if a simpler tested native approach is superior.

Do not encode fossils or dust in P1.

## Relief / picking decision

This is the main technical decision of P1.

Before full implementation, assess native Godot approaches such as:

- shader-displaced subdivided surface + height-aware analytical/iterative picking;
- CPU-updated heightfield mesh / collision;
- another native approach that preserves precision and performance.

Do not over-engineer a general voxel/destruction engine.

Select the simplest approach that satisfies:

- convincing visible cavities;
- precise cursor contact;
- deterministic reset;
- local updates;
- reasonable 60 FPS headroom;
- compatibility with P2 physical tools later.

Document the choice and rejected alternatives in `docs/dev/P1_RELIEF_DECISION.md`.

The P0 flat collider may remain as a broad interaction bound, but final hit coordinates for P1 must correspond closely to the displaced visible surface. A tool marker must not visibly float above or cut through a deep cavity.

## Test stratigraphy

Use one deterministic authored/test block.

Suggested vertical sequence:

**Loose Soil → Compact Clay → Sandstone**

with a small optional Hard Rock region.

Boundaries should be slightly irregular so layer transitions do not look like perfectly flat Photoshop bands, but P1 must not introduce a procedural-content system.

Suggested palette for debug readability:

- Loose Soil: warm brown
- Compact Clay: muted red/ochre
- Sandstone: light beige
- Hard Rock: dark grey

These are debug colors, not production textures.

## Generic P1 excavation tool

Continue using a generic debug tool rather than implementing Soft Brush / Chisel / Air Blower.

It should expose:

- radius
- base removal power
- falloff

Actual removal rate is modified by the current material's resistance.

The same gesture should make Loose Soil disappear clearly faster than Clay, and Clay faster than Sandstone.

The tool remains a technical instrument and should not gain final tool animations, audio or FX.

## Material definitions

Create a lightweight configurable representation, e.g. `MaterialDefinition`, with only properties needed now:

- id
- display/debug name
- resistance
- debug color
- optional minimum/maximum tuning values if technically useful

Do not add audio, particles or final tool compatibility fields unless P1 genuinely needs them.

## Debug requirements

F1 should additionally expose, at minimum:

- current surface height / excavation depth;
- current material;
- material resistance;
- visible/picked surface position;
- tool radius / power / falloff;
- CPU edit timing;
- FPS.

Useful debug views may include:

- height map;
- material / layer view;
- normals / relief view if helpful.

R must restore the exact initial block.

## Scope exclusions

P1 must NOT implement:

- Soft Brush final;
- Chisel final;
- Air Blower final;
- dust gameplay;
- particles / debris polish;
- audio;
- fossil geometry;
- bone detection;
- bone condition;
- fragments;
- objectives;
- classification;
- museum;
- save system;
- economy;
- Steam integration;
- final textures / props / UI;
- procedural block generation.

## Tests

Preserve all P0 tests and add coverage for:

- deterministic initial stratigraphy;
- height/depth bounds;
- reset;
- current-material resolution at layer boundaries;
- resistance affecting removal rate;
- no tunneling below minimum surface;
- mapping/picking over excavated height;
- edge behavior;
- transformed block if still supported;
- normal and fast strokes;
- consistency between rendered/debug height and CPU state where testable.

Run Godot import, automated tests and a local graphical session.

## Acceptance criteria

P1 is complete only if:

- [ ] P0 behavior still passes;
- [ ] the block visibly develops cavities;
- [ ] cavities have perceivable depth and local shading/normal response;
- [ ] the cursor/tool marker follows the visible surface with no obvious offset;
- [ ] Loose Soil, Clay and Sandstone can be reached through excavation;
- [ ] their resistance differences are obvious with the same debug tool;
- [ ] layer transitions are deterministic and readable;
- [ ] R restores the pristine block exactly;
- [ ] normal strokes remain responsive at 60 FPS locally;
- [ ] automated tests pass;
- [ ] `P1_RELIEF_DECISION.md` exists;
- [ ] `P1_REPORT.md` exists;
- [ ] no P2+ feature has been implemented;
- [ ] branch is pushed and PR opened toward `main`, but not merged.

## Human test gate

Antoine must test P1 locally before merge.

The key questions are:

1. Does it actually feel like I am digging downward rather than erasing a texture?
2. Does the mouse stay exactly where I expect inside a cavity?
3. Can I immediately feel that soil, clay and sandstone resist differently?
4. Does carving curves / spirals / edges remain smooth?
5. Is there any visible lag or mismatch between data and geometry?

If these fail, fix P1 before P2.
