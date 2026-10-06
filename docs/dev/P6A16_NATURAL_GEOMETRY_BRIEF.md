# P6A1.6 — Natural Matrix Geometry Spike

**Status:** authorized after human approval of P6A1.5 Soil semantics  
**Date:** 2026-10-06  
**Branch:** `prototype/p6a-visual-spike`  
**PR:** #9 remains DRAFT  
**Scope:** replace the overly planar starting Clay/Sandstone substrate with deterministic natural macro topography before P6A2 Hero Lookdev.

## Why this spike exists

P6A1.5 proved that the preferred Soil role is:

> **thin irregular surface overburden → Brush → real Clay/Sandstone matrix → structural excavation**

Human review is positive on that direction and on the corrected dirty-deposit contact patina.

The new problem is now obvious:

> once the thin Soil is removed, the underlying Clay/Sandstone still reads too much like a broad horizontal plane.

P6A2 should not spend production lookdev effort on geometry that already feels wrong.

The purpose of P6A1.6 is therefore to establish one believable, gameplay-safe **natural matrix topography baseline** first.

---

# Product target

The starting matrix should feel like a real irregular fossil-bearing block rather than a rectangle filled with flat horizontal layers.

Desired visual/topographic language:

- broad undulations;
- shallow bowls / open cavities;
- low ridges;
- local shelves / steps;
- imperfect material transitions;
- subtle asymmetry;
- some areas higher/lower than others before the player touches the block.

This is **real gameplay geometry**, not only normal-map/shader noise.

The terrain should remain readable from the near-top-down camera.

---

# Critical distinction

This spike concerns:

> **internal Clay/Sandstone matrix topography**

It does **not** solve:

> **future outer jacket / block silhouette variation**

The dynamic work area may still use the current outer rectangular footprint during the spike.

P6A2 later tests a static/authored jacket shell around the dynamic core.

Do not turn P6A1.6 into a free-form block-shape system.

---

# Canonical starting point

Preserve the human-preferred P6A1.5 semantics:

- Soil is thin and partial;
- Soil follows the matrix surface;
- exact Soil thickness/coverage remain tunable;
- Brush is the Soil-removal tool;
- contact patina = original material + irregular dirty deposits;
- Clay remains orange;
- Sandstone remains identifiable;
- no uniform dark patina band.

Use the P6A1.5 candidate as the foundation for the natural-geometry candidate.

---

# A/B comparison

Provide a controlled comparison:

## A — current substrate
Thin P6A1.5 Soil over the existing relatively planar matrix.

## B — natural matrix geometry
Same Soil semantics, camera, tools, fossil and gameplay systems, but with richer deterministic matrix topography.

Switching A/B should reset the controlled fixture while preserving comparable framing.

The human review must be able to judge the geometry difference without P6A2 texture/lighting work muddying the result.

---

# Geometry design rules

## 1. Macro first

Prefer a small number of broad authored/deterministic forms over high-frequency noise.

Good:
- broad basin;
- gentle ridge;
- shallow depression;
- local shelf;
- low mound;
- sloped transition;
- imperfect interface.

Bad:
- noisy acne;
- repeated sine waves;
- obvious procedural terrain;
- many tiny bumps that will later be normal-map detail;
- random jaggedness everywhere.

## 2. Heightfield-compatible cavities only

The current excavation authority is a heightfield.

Therefore “cavities” in this spike means:
- shallow open bowls/depressions;
- concave areas visible from above;
- eroded-looking pockets;
- local shelves/steps.

Do not attempt:
- overhangs;
- tunnels;
- enclosed caves;
- side-facing geometry that the heightfield cannot represent safely.

## 3. Independent of fossil silhouette

Do not sculpt the matrix to reveal or trace the hidden dinosaur.

The macro topography should be authored/deterministic from geological fields independent of the Bone mask.

Bone data may be used only to validate:
- no initial exposure;
- safe burial;
- reasonable work budgets;
- no impossible/unreachable preparation.

The player should not be able to infer the fossil outline from the starting relief.

## 4. Natural layer relationship

The top Soil/Clay surface and Clay/Sandstone interface do not need to remain parallel.

Allow broad differences in thickness and local slope where they improve the natural feel.

However:
- no impossible inversions;
- no floating layers;
- no crossing Bone ceilings;
- material identity must remain readable.

## 5. Preserve work-budget sanity

P4-V1.1 established:
> **generation / verticality must be effort-aware, not depth-only**

Any matrix-topography candidate must measure the existing material-weighted work above Bone, not just visual height.

Use the established relative oracle where applicable:
- Clay work weight ×3
- Sandstone work weight ×5.333…

Compare the Bone population distribution (median / P90 / P95 / maximum) against the current baseline.

Do not accidentally create a visually nice block with extreme hard-material excavation over one anatomical region.

## 6. No initial Bone reveal

At reset:
- no main Bone cell should begin exposed;
- Soil-free patches may reveal Clay/Sandstone only;
- all Bone ceilings remain respected.

---

# Geometry architecture

Prefer the simplest deterministic architecture that could plausibly survive into the production block generator later.

Good candidates:
- a small set of broad smooth analytical lobes / ridges / basins;
- low-frequency deterministic fields;
- localized authored masks / shapes;
- combinations of the above with bounded amplitudes.

Avoid a large procedural-generation framework.

This is one B-17 authored prototype, not seed generation.

Centralize all candidate parameters:
- amplitude;
- location;
- radius/scale;
- interface influence;
- any blend/falloff.

Document final ranges in millimeters.

---

# Soil interaction

The thin Soil must sit on top of the new matrix topography:

> `visible start height ≈ new matrix surface + small local Soil thickness`

The Soil must not fill depressions up to a common flat altitude.

Small extra accumulation in depressions may be explored only if extremely simple and bounded, but it is not required for this spike.

The key human signal is:
> the starting surface already inherits the natural shape below.

---

# Material transitions

Keep the corrected P6A1.5 contact-patina language.

If geometry exposes more local interface:
- Clay stays visibly Clay;
- Sandstone stays visibly Sandstone;
- dirty deposits may collect visually in creases;
- patina remains visual-only.

Do not begin P6A2 production material authoring here.

---

# Gameplay preservation

Preserve:
- Brush;
- Chisel;
- Blower;
- Precision Pick;
- Bone Surface Film;
- fracture/debris behavior;
- Bone Condition/protection;
- camera/zoom/pan;
- CPU picking authority;
- P5 progression;
- 240 FPS cap /60 Hz physics.

Do not retune P4 tools merely to compensate for geometry.

If geometry creates an actual accessibility problem, report it rather than hiding it through tool changes.

---

# Required fixtures / comparisons

At minimum provide:

1. reset overview A vs B;
2. Soil removed, matrix-only overview A vs B;
3. representative 2× / 3× close-up of a basin/ridge/shelf;
4. one controlled excavation path through new relief;
5. one representative Bone-area preparation showing ceilings remain correct;
6. optional Clay/Sandstone interface witness if the new relief makes it useful.

No P6A2 textures or final lighting are required to pass this spike.

---

# Validation / tests

Add targeted validation for:

- deterministic reset;
- same fossil occupancy/component IDs/totals;
- no initial Bone exposure;
- all initial matrix heights remain above Bone ceilings;
- no material-interface inversion;
- new relief has a documented meaningful min/max and distribution;
- broad-form slope/relief rather than only micro noise;
- Soil candidate conforms to the new substrate;
- Brush stops correctly at matrix;
- Chisel/Pick still edit the intended materials;
- CPU picking agrees with rendered triangles;
- P5 progression remains unaffected;
- no idle/per-frame geometry reconstruction;
- effort-weighted Bone burial budgets remain within documented acceptable deltas;
- full relevant P0–P5 regression remains green.

Run representative graphical/performance checks at 1× and 3×.

---

# Human review questions

Antoine should be able to answer:

1. Does B immediately feel less like a flat slab?
2. Does the block look more natural even before final textures?
3. Are the shallow cavities/ridges/shelves believable rather than procedural noise?
4. Does thin Soil now gain more life because it follows interesting matrix relief?
5. After Soil removal, does Clay/Sandstone feel like a real irregular work surface?
6. Is excavation still readable and satisfying?
7. Do any pockets/slopes feel annoying or inaccessible?
8. Does the relief reveal or telegraph the fossil shape too much?
9. Is the geometry varied enough to be a credible foundation for P6A2?
10. Choose: A current substrate / B natural geometry / targeted correction.

---

# Non-goals

Do NOT:
- start P6A2 materials/lighting;
- model the final jacket;
- change outer block silhouette;
- build procedural seeds;
- redesign fossil anatomy;
- add overhangs/caves;
- retune P4 tools;
- redesign Soil semantics again unless geometry exposes a blocking issue;
- implement final Soil particles/debris;
- start P6B.

---

# Deliverables

Create:
- `docs/dev/P6A16_NATURAL_GEOMETRY_REPORT.md`;
- controlled A/B scene or mode;
- comparison captures/evidence;
- centralized geometry parameters;
- work-budget comparison;
- regression/performance evidence;
- short human retest checklist.

Update:
- `docs/brain/status.md`;
- `docs/brain/decisions.md` only for durable implementation choices.

## STOP

After delivering B and the report:
- stop;
- do not start P6A2;
- wait for Antoine's explicit human geometry verdict.
