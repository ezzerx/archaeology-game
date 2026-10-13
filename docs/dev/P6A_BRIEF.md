# P6A — Visual Direction / Production Spike

**Status:** authorized after human closure of P5  
**Date:** 2026-10-05  
**Base:** `main@6ae107d9b55718f34f4e18d8317551a5476e41c0`  
**Branch:** `prototype/p6a-visual-spike`  
**Scope:** prove the in-engine visual-production pipeline on one representative gameplay slice before scaling P6B.

## Product objective

P6A must answer:

> **Can the real, dynamically excavated B-17 gameplay look close to the approved concept direction while remaining readable, reproducible and performant?**

This is not a full art pass and not mass asset production.

The output should be one convincing **hero slice** and a documented pipeline that can be repeated in P6B.

## Source precedence

1. Antoine's newest explicit decisions.
2. This brief.
3. `docs/brain/decisions.md` / `status.md`.
4. `docs/ART_DIRECTION.md`.
5. `docs/VISUAL_REFERENCES.md`.
6. older prototype visuals are historical.

Canonical reference board:
`docs/visual-references/archaeologygame-v0.1-visual-reference-board.jpg`

Recent concept direction from the design conversation should be treated as directional:
- warm natural-history preparation workshop;
- irregular plaster jackets / varied block identities;
- layered Clay/Sandstone/Bone treatment;
- incoming gameplay blocks begin **closed/unprepared** even if concept art shows already revealed fossils;
- museum exterior/main-menu seasonal variants are a later P6 concern, not the first spike.

## Freeze gameplay

Do NOT retune P4/P5 gameplay while doing P6A.

Keep:
- Soft Brush 40 / 0.70 / 1.25;
- Chisel 22 / 0.64 / 2.25 @4.5 Hz;
- Air Blower 60 / residue clear2.5;
- Precision Pick 11 / 0.44 / 1.75 @6 Hz, Bone-safe;
- current Bone Film behavior;
- fracture/debris;
- camera / zoom / pan / picking;
- deterministic B-17 geometry;
- P5 85/85 museum standard,95/95 Fine Preparation and qualitative Condition.

Known P5 watchpoints are deferred and must not become hidden P6A scope:
- Cleanliness can decrease when newly exposed dirty Bone expands the denominator.
- Completion coverage is not a perfect visual-completeness oracle.
- in-matrix vs extraction vs mounted/hybrid display remains Macro Game Design.

---

# P6A-1 — Material Lab FIRST

Create a separate representative **P6A Material Lab** scene / mode using the real B-17 dynamic excavation data and rendering path.

It should allow controlled comparison of:
- current P5 rendering;
- Candidate A;
- Candidate B;
- Candidate C if useful.

The same camera, geometry and excavation state must be comparable across candidates.

Provide fixed presets / test states showing in one representative slice:
- intact surface;
- Soil / surface dirt;
- Soil→Clay contact area;
- fresh Clay interior;
- Sandstone;
- fracture/cavity;
- dirty Bone Film;
- clean Bone.

The purpose is to choose the rendering/authoring pipeline before producing environment assets.

## Candidate approaches to test

Do not overbuild all of them. Use the cheapest representative implementation necessary to compare:

### A — mostly procedural shader
Procedural noise / masks / variation in Godot.

### B — authored textures + dynamic masks
Artist-controlled albedo/roughness/normal detail combined with the existing dynamic excavation masks/height.

### C — hybrid
Authored material bases + shader variation + separate static meshes for jacket/borders/support props.

**Current hypothesis:** hybrid is likely strongest, but P6A must prove it rather than assume it.

## Material targets

The result must clearly distinguish without UI:
- loose/surface dirt;
- Clay;
- Sandstone;
- dirty Bone;
- clean Bone.

Target impression:
> **warm illustration brought to life**

Not:
- photoreal;
- visibly low-poly;
- flat debug colors;
- exaggerated cartoon.

---

# P6A-2 — Contact patina experiment

Test the already-canonized visual-only contact treatment:

### Soil → Clay
- thin dirty/browned Clay surface skin at the interface;
- cleaner/more saturated orange Clay once cut into.

### Clay → Sandstone
- subtler optional version.

This is visual only:
- no extra gameplay thickness;
- no resistance change;
- no picking change.

The preferred future Soil redesign is **not** implemented here. P6A may visually explore the idea of thin surface overburden, but gameplay Soil remains unchanged during this spike.

---

# P6A-3 — Bone readability

Known problem:
Bone Film / Sandstone can still be too similar.

First experiment must be:
> **color/material-property change only**

Do not alter Bone Film spot pattern/density/shape first; Antoine likes the current pattern.

Test:
- dirty Bone;
- partially cleaned Bone;
- clean Bone;
- adjacent Sandstone.

Goal:
player can distinguish all three instantly while excavating.

No supernatural glow.

---

# P6A-4 — Lighting

Only after material candidates show promise, establish a candidate canonical lighting setup:

- warm key/task lamp, roughly3200–3800K in spirit;
- restrained cooler fill;
- strong enough cavity/depth cues;
- Bone catches light slightly differently from stone;
- no overblown bloom;
- no darkness that hides tool/material language.

Test at:
- overview;
- 2×;
- 3× zoom;
- active Brush/Chisel/Pick;
- dusty and cleaned states.

Gameplay readability wins over screenshot beauty.

---

# P6A-5 — Jacket / outer silhouette spike

Do **not** rewrite the excavation geometry into unconstrained free-form blocks.

Test the preferred low-risk approach:

> **dynamic excavation core + static / authored jacket shell**

Create only enough prototypes to judge the visual language, e.g.:
1. current rectangular baseline;
2. compact irregular plaster jacket;
3. elongated/asymmetric jacket.

Jacket identity may include:
- broken plaster edges;
- straps / reinforcement;
- support foam / cradle;
- chipped matrix border.

Incoming specimen state must remain **closed**. Do not expose the fossil just to match concept art.

Goal:
different preparations can eventually have visual identity without sacrificing readable excavation.

---

# P6A-6 — Asset pipeline proof

Before broad asset creation, prove one end-to-end static-asset workflow.

Suggested minimum:
- 1 tool asset (e.g. Brush);
- 1 jacket/support asset;
- 1 workshop prop (lamp, tray or equivalent).

Evaluate:
> Blender / authoring tool → UV/material → export → Godot → lighting → final in-game render

Document:
- source tool;
- export format/settings;
- texture resolution;
- material setup;
- naming;
- scale;
- iteration time;
- common failure points.

Do not canonize Blender or another tool merely by assumption; use the workflow that actually proves cheapest and most reproducible.

---

# P6A-7 — UI sample only

Do not redesign the entire UI yet.

Create only one representative sample of the future visual language using the minimal P5 HUD content:
- specimen identity;
- Reveal;
- Clean;
- Condition / completion state.

Direction:
**natural-history field notebook / museum prep paperwork**

Possible materials:
- warm paper;
- card stock;
- wood;
- small brass details;
- bottle-green accents.

The fossil must remain visually dominant.

This sample exists to prove that the UI language belongs to the same world as the workshop, not to finalize every state.

---

# P6A-8 — Hero slice

Assemble the winning candidates into one playable hero slice:

- real B-17 excavation;
- chosen material pipeline;
- candidate canonical lighting;
- representative jacket;
- at least one production-style tool/prop;
- small UI sample;
- existing dust/fracture effects adapted enough to belong visually.

Play actual interactions:
- Brush;
- Chisel;
- Blower;
- Pick;
- Bone reveal;
- Bone cleaning;
- zoom/pan.

A static screenshot is not sufficient.

---

# Evaluation gates

P6A passes only if the selected pipeline scores well on all five:

## 1. Fidelity
Does it genuinely approach the approved concept direction?

## 2. Gameplay readability
Can the player instantly read material, cavity, dirty Bone, clean Bone and tool result?

## 3. Dynamic compatibility
Does the look survive real excavation, deformation, fracture, dust and zoom?

## 4. Performance
No unacceptable regression. Preserve smooth capped gameplay and measure representative GPU/CPU cost.

## 5. Production cost
Can this quality be reproduced across future blocks/assets without heroic manual work?

A beautiful one-off pipeline that cannot scale fails P6A.

---

# Deliverables

P6A should produce:

1. Material Lab / comparison scene or equivalent controlled harness.
2. Selected material/rendering pipeline with rejected alternatives documented.
3. Candidate canonical lighting rig.
4. Bone/Sandstone readability decision.
5. Contact-patina result.
6. Jacket-shell approach result.
7. One proven static-asset import pipeline.
8. One small UI-language sample.
9. One playable hero slice.
10. Performance measurements.
11. Production notes / estimated iteration cost.
12. Screenshots/video captures for human review.
13. `docs/dev/P6A_REPORT.md`.

## Human gate

Do not start P6B automatically.

Antoine must review the hero slice and answer:

- Does this finally look like **our game**?
- Are materials immediately readable while playing?
- Is the Bone reveal more beautiful without becoming less clear?
- Does the jacket/lighting/workshop language approach the concepts?
- Does the visual upgrade preserve the satisfying P4/P5 interactions?
- Is the pipeline believable to scale?

If no: iterate P6A.
If yes: canonize the pipeline and authorize P6B.

---

# Out of scope

Do NOT implement in P6A:
- full museum gallery;
- Specimen Intake;
- crate opening;
- full seasonal menu system;
- macro progression;
- equipment progression;
- multiple fossils;
- procedural block generation;
- final extraction/mounting model;
- full Soil gameplay redesign;
- mass asset production;
- full P6B UI restyle;
- P7 tuning.

## Stop rule

P6A is a **spike**.

Prove the recipe first.
Do not decorate the whole kitchen before the recipe works.


## P6A2 — Hero Lookdev prepared, pending geometry foundation — 2026-10-06

Human review of P6A-1: the Material Lab proved integration feasibility but none of
P5/A/B/C is close enough to the desired art direction.

P6A2 is fully designed as the later target-match task, but it is **not currently executable**. P6A1.5 Soil semantics were resolved first, and P6A1.6 Natural Matrix Geometry must now be human-decided before Hero Lookdev begins.

Execution source:
- [P6A2_BRIEF](P6A2_BRIEF.md)
- [P6A2 canonical visual target guide](../visual-references/P6A2_VISUAL_TARGETS.md)

P6A-1's B/C findings are starting hypotheses only. Once P6A1.6 passes its human gate, P6A2 must target the reference pack directly through one small playable Hero Lookdev patch. P6B remains blocked until explicit human approval.


## P6A1.5 — Soil Foundation Spike prerequisite — 2026-10-06

Human review identified a sequencing risk: P6A2 lookdev should not build production art around the current thick Soil while Soil is explicitly considered provisional.

Current order:
> P6A-1 Material Lab ✅ → **P6A1.5 Soil Foundation Spike** → P6A2 Hero Lookdev → human gate → P6B

P6A1.5 is intentionally small:
- compare current thick Soil to the preferred thin loose-overburden model;
- decide Soil role/thickness/tool grammar only;
- preserve P4/P5 gameplay elsewhere;
- do not implement final Soil particles/VFX/polish.

P6A2 remains prepared but blocked until this decision.


## P6A1.6 — Natural Matrix Geometry prerequisite — 2026-10-06

P6A1.5 Soil semantics are now human-approved: thin irregular surface overburden is preferred, with irregular dirty contact deposits rather than uniform recolor.

Before P6A2 executes, the project must resolve one newly exposed foundation issue:

> the underlying Clay/Sandstone starting surface still reads as a broad horizontal plane.

Current order:
> P6A-1 Material Lab ✅ → P6A1.5 Soil Foundation ✅ → **P6A1.6 Natural Matrix Geometry** → P6A2 Hero Lookdev → human visual gate → P6B.

Execution source:
- [P6A1.6 Natural Matrix Geometry Brief](P6A16_NATURAL_GEOMETRY_BRIEF.md)

P6A1.6 must stay focused on deterministic matrix topography. It must not become final jacket generation, procedural block generation, P6A2 material lookdev or P7 tuning.
