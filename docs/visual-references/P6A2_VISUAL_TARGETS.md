# P6A2 — Canonical Visual Target Guide

**Status:** canonical visual-reference instructions for P6A2 look-development.
**Decision date:** 2026-10-06.

These images are **not literal scene blueprints**. Each image has a specific job.
Codex must use the assigned job only and must not copy unrelated composition,
props, anatomy or staging just because they appear in a reference.

## Access preflight — mandatory

The image files are currently stored as ChatGPT Project sources / conversation assets.
Before P6A2 implementation begins, the executing Codex session must be able to inspect
all PRIMARY references directly.

Preferred durable repo location if copied locally:

`docs/visual-references/p6a2/`

Expected filenames:

- `00-style-north-star.png`
- `01-gameplay-target.png`
- `02-material-closeup.png`
- `03-closed-block.png`
- `04-progression-states.png`
- `05-workbench-target.png`

If the local Codex session cannot access the images from Project sources and the files
are not present in the repo, **STOP and ask Antoine to provide/copy them**. Do not
replace them with guessed web references or proceed from prose alone.

---

# Reference hierarchy

## PRIMARY A — Gameplay target
**Project source:** `fouille_fossile_sous_la_lampe_dorée.png`
**Expected repo copy:** `01-gameplay-target.png`

### What this image controls
This is the **primary P6A2 gameplay look target**.

Use it for:
- perceived quality of the excavation block;
- warm stylized rendering;
- readable Clay / Sandstone / Bone separation;
- believable irregular plaster-jacket silhouette;
- chipped edges, crumbs and material depth;
- top-down / slight-angle gameplay-compatible presentation;
- balance between detail and readability.

### Do NOT copy literally
- exact dinosaur anatomy;
- exact prop placement;
- full surrounding workshop composition;
- exact block dimensions;
- any non-gameplay decorative clutter.

The implementation must remain the real B-17 gameplay scene and camera.

---

## PRIMARY B — Material close-up
**Project source:** `fossile_de_dinosaure_en_excavation.png`
**Expected repo copy:** `02-material-closeup.png`

### What this image controls
This is the **material-quality and material-separation target**.

Use it for:
- Soil/dust surface language;
- orange Clay;
- darker compact Sandstone / matrix;
- dirty Bone versus clean Bone;
- roughness differences;
- micro/meso-scale surface detail;
- crumbs, chipped faces and believable fractured material;
- the feeling that materials have volume rather than wallpaper.

### Do NOT copy literally
- macro camera composition;
- exact skull geometry;
- brush/pick placement;
- photographic-looking depth of field if it harms gameplay readability.

This reference is about **how materials feel up close**, not scene layout.

---

## PRIMARY C — Style north star
**Project source:** `Fouille Fossile sur Établi de Paléontologue.png`
**Expected repo copy:** `00-style-north-star.png`

### What this image controls
This defines the high-level emotional and artistic target:

- cozy;
- warm;
- inviting;
- stylized but believable;
- natural-history museum preparation lab;
- soft painterly / handcrafted feeling;
- warm ivory, earth, stone and plaster palette;
- gentle golden task-light atmosphere.

### Do NOT copy literally
This image is **not** the gameplay layout target.

Do not reproduce:
- the entire workshop;
- all props;
- its exact camera;
- its exact fossil presentation.

Use it to answer:
> "Does this look and feel like the same game world?"

---

# Supporting references

## SUPPORT D — Closed specimen block
**Project source:** `mystère_paléontologique_en_laboratoire.png`
**Expected repo copy:** `03-closed-block.png`

Use for:
- incoming specimen identity;
- irregular jacket silhouette;
- plaster/strap/support language;
- closed/unprepared starting state;
- anticipation before excavation.

Do not implement crate/intake gameplay or multiple jacket families in P6A2.
This supports the first jacket-shell prototype only.

## SUPPORT E — Visual progression states
**Project source:** `étapes_de_préparation_d_un_fossile_de_dinosaure.png`
**Expected repo copy:** `04-progression-states.png`

Use for:
- visual continuity from intact -> early reveal -> dirty revealed Bone -> prepared;
- making excavation progress visually legible;
- avoiding a look that only works in one final screenshot.

Do not copy the 2x2 infographic layout into the game.

## SUPPORT F — Workbench/world framing
**Project source:** `atelier_de_fouilles_paléontologiques_chaleureuses.png`
**Expected repo copy:** `05-workbench-target.png`

Use later in P6A2 hero-patch assembly for:
- warm desk material;
- lamp mood;
- restrained museum-lab props;
- overall world cohesion.

Do not expand P6A2 into full workshop production.

---

# Existing project board

The existing canonical board remains background context:
`docs/visual-references/archaeologygame-v0.1-visual-reference-board.jpg`

For P6A2, when it conflicts with the newer target set:
1. gameplay readability / current mechanics;
2. P6A2 Gameplay Target;
3. P6A2 Material Close-up;
4. P6A2 Style North Star;
5. supporting P6A2 references;
6. older board.

---

# Shared visual rules extracted from the pack

Codex should target:

- **stylized cozy material realism**, not photorealism;
- richer authored materials, not flat color or obvious repeated wallpaper;
- material variation at multiple scales;
- warm ivory Bone, never glowing clinical white;
- clear Clay / Sandstone / Bone separation without UI;
- visible roughness and surface-depth differences;
- soft but readable shadows and cavity depth;
- chipped, irregular plaster-jacket edge around the dynamic excavation core;
- warm task-light feel;
- restrained surrounding detail so the fossil remains dominant.

Avoid:

- obvious tiling/repetition;
- noisy procedural texture for its own sake;
- flat debug-like surfaces;
- over-dark cinematic lighting;
- excessive DOF inside the playable work area;
- literal copying of generated props/anatomy;
- changing gameplay rules to match concept art.

---

# Evaluation rule

The references are a **visual target**, not evidence that every depicted feature must
be implemented.

P6A2 succeeds when a small real playable patch of B-17 is materially closer to these
references in:
- material richness;
- warmth;
- depth;
- readability;
- jacket identity;
- lighting response;

while preserving the existing excavation mechanics.
