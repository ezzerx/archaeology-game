# P3 — Fossil / Exposure / Bone Contact

**Status:** authorized after human validation of P2  
**Date:** 2026-10-01  
**Engine:** Godot 4.7.2 stable Standard, GDScript  
**Gate:** P4 must not start before human validation of P3

## Goal

Introduce the first real fossil into the excavation block and prove the most important discovery transition in the prototype:

> material → unexpected hard/ivory shape → bone detection → careful exposure

P3 validates:

- a fossil hidden beneath the matrix;
- progressive structural exposure;
- precise contact against bone;
- a protected first contact;
- specimen condition;
- component exposure tracking.

P3 does **not** implement final sound/VFX, classification, fragments, objectives, museum progression or final art.

## Runtime FPS cap — explicit user decision

Normal interactive runs launched with F5 must be capped at **240 FPS**.

Reason: the uncapped P2 prototype drove the RTX 5080 to 100% GPU utilization unnecessarily.

Requirements:

- set the normal game/runtime cap to **240 FPS**;
- keep physics at 60 Hz;
- verify the official Godot setting / implementation used;
- benchmark scripts may explicitly override the cap when measuring headroom;
- ordinary playtest sessions must restore/respect the 240 cap;
- record observed GPU utilization / frame behavior qualitatively in P3_REPORT if convenient.

Do **not** optimize the 1.31M-triangle surface solely because of this observation yet. First validate whether the 240 FPS cap is sufficient. If Antoine still sees undesirable GPU load, the cap will be lowered in a later explicit decision.

## North-star moment for P3

The prototype should now produce this sequence, even with placeholder visuals:

1. Player works through Soil / Clay / Sandstone.
2. Chisel approaches hidden fossil.
3. Structural excavation reaches the fossil ceiling and stops.
4. A distinct ivory region begins to appear.
5. A one-time debug notification says **Bone detected**.
6. The first hidden contact causes no damage.
7. Continuing to hit already exposed bone with the Chisel reduces specimen condition.
8. Brush / Blower can work safely around the exposed fossil.
9. Excavating surrounding matrix makes the bone stand proud of the cavity.

If this moment is not readable in greybox form, P3 is not complete.

## Fossil representation — preferred prototype direction

P1/P2 use a one-height-per-column heightfield. P3 should preserve that architecture rather than introduce a second destruction engine.

Preferred approach:

- add a static fossil field aligned to the excavation map;
- per fossil texel, store at least:
  - whether bone exists;
  - fossil/bone ceiling height;
  - component id;
- structural excavation in bone cells may descend only to the bone ceiling;
- once the matrix height reaches that ceiling, the cell is considered structurally exposed;
- non-bone neighboring cells remain excavatable below the fossil ceiling, allowing the fossil shape to emerge in relief;
- the shader renders exposed bone with a distinct warm ivory placeholder material.

This creates an embedded fossil using the existing heightfield and exact P1 picking.

If Codex finds a simpler native approach that preserves all P3 requirements, it may choose it, but it must document the choice in:

`docs/dev/P3_FOSSIL_DECISION.md`

Do not add voxels, CSG, skeletal physics or a general 3D destructible-mesh engine.

## Specimen B-17

Use the canonical prototype specimen:

**Specimen B-17**

Classification remains unknown in P3.

The fossil should be recognizable as a small theropod-like fossil from above, but remains placeholder / procedural-greybox art.

Required components:

- Skull
- Vertebrae / spine
- Rib section
- Hind limb
- a few minor isolated bones if useful

The component map must be deterministic.

Do not use an external dinosaur asset or copyrighted model.

A simple authored field built from native/procedural shapes is acceptable.

The player must not see a full preview/silhouette before excavation.

## Fossil field / authored layout

This is **not** procedural content generation.

Create one deterministic test fossil layout.

The fossil may be authored through:

- masks/maps;
- simple geometric field primitives;
- editor-authored data;
- another deterministic lightweight method.

Avoid expensive mutable full-resolution maps where static data is sufficient.

Static fossil maps may be uploaded once and remain unchanged.

## Bone ceiling

Each bone cell has a maximum excavation depth / minimum structural height.

Example:

`surface_height >= bone_ceiling_height`

The surface operation must clamp removal at that ceiling.

Important:

- tool work must never tunnel through bone;
- a large delta / high power must not skip past the bone ceiling;
- material work remaining after reaching bone is discarded for that cell;
- surrounding non-bone matrix can continue below it.

Bone may have slightly varying top height so the fossil is not a perfectly flat ivory sticker.

## Bone visual

Placeholder only, but clearly different from matrix.

Target:

- warm ivory / beige;
- smoother and slightly less rough than sandstone;
- catches light differently;
- no supernatural glow;
- no final texture;
- no external asset.

As surrounding matrix is removed below the bone ceiling, exposed bone should visibly protrude.

The fossil must read as **bone**, not just another geological layer.

## First contact protection

Canonical rule:

**The first structural contact with hidden bone is safe.**

Implementation semantics:

- when excavation reaches bone ceiling for a previously hidden bone cell, clamp at the ceiling;
- do not damage condition during that reveal/contact;
- mark that bone cell exposed;
- emit a bone-contact / reveal event;
- a one-time specimen-level notification may display:
  - `Bone detected`
  - `Delicate material underneath`

The notification is debug UI only.

No final sound, particle burst or music cue in P3 — those belong to P4.

## Exposed-bone damage / specimen condition

Specimen condition starts at:

**100%**

P3 target behavior:

- Soft Brush on exposed bone: 0 damage;
- Air Blower on exposed bone: 0 damage;
- Chisel direct impact on already exposed bone: about **-3 percentage points per direct impact**.

Define “direct impact” simply and predictably.

Preferred rule:

- if the Chisel impact center resolves to an already exposed bone cell, apply one condition hit;
- do not subtract damage per bone texel inside the whole footprint;
- one scheduled Chisel impact can produce at most one condition penalty.

Condition is global for B-17 in P3.

Clamp 0–100%.

No Game Over.

No permanent fossil destruction.

No broken-bone visual states yet.

## Tool behavior at bone

### Soft Brush

- never lowers bone cells below the ceiling;
- no condition damage;
- can continue clearing residue;
- may excavate compatible non-bone material in its footprint.

### Chisel

- can excavate matrix until bone ceiling;
- the reveal/contact that first exposes a hidden cell is protected;
- direct impact center on already exposed bone damages condition;
- bone height never decreases.

### Air Blower

- no structural change;
- no damage;
- clears residue exactly as P2.

## Exposure tracking

Track at least:

- total fossil exposure percentage;
- per-component exposure percentage;
- exposed bone cell count / total bone cell count.

Definition for P3:

A bone cell is structurally exposed when matrix height has reached the bone ceiling within a small deterministic epsilon.

Do not tie structural exposure to classification or objectives.

Optional but useful:

- track “visually clean” separately if residue is below a threshold, but do not turn that into P5 progression yet.

## Component events

Prepare small, decoupled events/signals for future P5 use.

Examples:

- `bone_first_contact`
- `bone_cell_exposed`
- `bone_component_exposure_changed`
- `bone_condition_changed`

Do not create the full discovery/objective/classification systems.

Avoid emitting per-frame notification spam.

Specimen-level `Bone detected` should trigger once.

Component threshold notifications are optional debug information only.

## Debug UI

F1 should add:

- Specimen B-17
- overall exposure %
- current hovered bone? yes/no
- component under cursor
- component exposure %
- bone ceiling height
- surface height
- bone exposed? yes/no
- specimen condition %
- last bone event / last damage event if useful

Keep the existing tool/material/residue/performance data.

A minimal debug specimen panel is allowed.

Do not build final dossier UI.

## Debug visual views

Keep F2 existing views.

Add a fossil debug view only if useful, for example:

- fossil occupancy / component ids;
- bone ceiling.

Do not expose this view in ordinary playtest by default.

## Residue interaction

P2 residue remains placeholder.

P3 must ensure:

- residue may visually veil exposed bone;
- Blower can clear it;
- residue never changes fossil geometry or condition;
- fossil exposure state does not become nondeterministic because of R8 quantization.

Structural exposure and residue are separate concepts.

## Reset

R must restore exactly:

- pristine height;
- zero residue;
- fossil exposure state;
- condition = 100%;
- first-contact notification state;
- component exposure counters;
- Chisel cadence/input state.

The static fossil field and stratigraphy remain identical.

Selected tool may remain selected as in P2.

## Performance

Normal F5 runtime: **240 FPS cap**.

Benchmark:

- preserve P0/P1/P2 benchmarks;
- add P3 benchmark phases around fossil exposure;
- measure normal excavation over matrix;
- reveal along fossil boundary;
- repeated Chisel impacts on exposed bone;
- Brush/Blower over exposed bone.

Critical requirement:

P3 fossil logic must not introduce a new heavy full-resolution mutable texture unless justified.

Prefer static fossil data + existing dynamic height/residue states.

At 60 FPS physics, bone checks should be local to the affected region.

## Automated tests

All P0/P1/P2 tests must remain green.

Add P3 tests covering at least:

- deterministic fossil field;
- fossil bounds inside excavation area;
- bone ceiling never below floor / above intact surface;
- component IDs valid;
- structural removal clamps at bone ceiling;
- huge work delta cannot tunnel through bone;
- non-bone neighbor can excavate below adjacent bone;
- first reveal causes no damage;
- repeated Chisel impact center on exposed bone reduces condition once per impact;
- Brush causes zero condition damage;
- Blower causes zero condition damage;
- condition clamped 0–100;
- overall exposure correct;
- per-component exposure correct;
- one-time first-contact event;
- reset restores exposure / condition exactly;
- tool switching / focus behavior remains correct around bone;
- picking stays aligned on bone relief and adjacent cavity;
- 240 FPS runtime cap configuration exists and does not alter 60 Hz physics.

## Scope exclusions

P3 must NOT implement:

- real dinosaur classification;
- Unknown → Theropod progression UI;
- specimen dossier final UI;
- fragment recovery;
- two collectible fragments;
- objectives;
- Preparation Complete;
- Keep Cleaning;
- final sound;
- final particles;
- final debris;
- camera feedback;
- final tool models;
- hands;
- final dust rendering;
- museum;
- save system;
- economy;
- Steam;
- procedural fossil generation;
- production fossil asset pipeline.

These belong to P4/P5/P6 or later.

## Human acceptance test

Antoine must test P3 locally.

### A — Discovery

1. Start from pristine block.
2. Use the tools naturally to reach the fossil.
3. Observe whether the first ivory shape feels like a real hidden object appearing from the matrix.
4. Confirm the `Bone detected` debug event triggers once.

Key question:

> Did I instantly understand that I had hit something different from rock?

### B — Geometry

- excavate around an exposed bone;
- make matrix lower than the bone;
- confirm bone stands proud of cavity;
- cursor/picking remains aligned on bone and surrounding slopes;
- no z-fighting / flicker / holes.

### C — Protection

- first contact with hidden bone causes no condition loss;
- after exposure, hit the same bone directly with Chisel;
- condition drops approximately 3% per direct impact;
- Brush/Blower remain safe.

### D — Exposure

Expose different portions of skull/spine/ribs/limb.

F1 percentages should increase logically.

No large percentage jumps from one tiny contact.

### E — Residue

Generate residue over bone, then Blower it away.

Bone geometry/exposure/condition remain stable.

### F — Reset

Damage condition and expose several components.

Press R.

Everything returns pristine and 100%.

### G — GPU / FPS cap

With normal F5 play:

- verify FPS never intentionally exceeds ~240 due to the runtime cap;
- observe Task Manager / NVIDIA overlay GPU usage for 2–3 minutes;
- report whether the previous 100% GPU behavior is materially reduced.

Do not optimize further unless the capped run is still undesirable.

## Acceptance criteria

P3 is complete only if:

- [ ] P0/P1/P2 tests pass;
- [ ] one deterministic fossil exists;
- [ ] fossil is fully hidden initially;
- [ ] excavation reveals ivory bone progressively;
- [ ] fossil cells cannot be excavated through;
- [ ] surrounding matrix can go below bone;
- [ ] Bone detected occurs once;
- [ ] first hidden contact is protected;
- [ ] Chisel can damage already exposed bone;
- [ ] Brush/Blower do not damage bone;
- [ ] condition tracked 0–100;
- [ ] overall exposure works;
- [ ] component exposure works;
- [ ] reset is exact;
- [ ] picking remains aligned;
- [ ] runtime F5 cap is 240 FPS;
- [ ] normal local interaction remains responsive;
- [ ] automated tests pass;
- [ ] `P3_FOSSIL_DECISION.md` exists;
- [ ] `P3_REPORT.md` exists;
- [ ] no P4/P5 system is implemented;
- [ ] branch pushed and PR opened;
- [ ] PR remains unmerged.

## Final gate

P4 is forbidden until Antoine has personally tested P3 and explicitly authorized the merge / next phase.
