# P6A2 — Hero Lookdev / Target Match

**Status:** authorized after P6A-1 human review
**Date:** 2026-10-06
**Branch:** `prototype/p6a-visual-spike`
**PR:** #9 remains DRAFT
**Scope:** prove that the real gameplay can become visually attractive by matching a small playable hero patch to the canonical P6A2 reference pack.

## Why this phase exists

P6A-1 proved that the dynamic B-17 surface can accept authored materials without
breaking gameplay, but none of P5/A/B/C is close enough to the desired art quality.

P6A2 is deliberately different:

> **Do not compare cheap rendering architectures anymore. Build one small piece of the real game to a convincing target quality.**

If we cannot get a small playable patch materially closer to the visual target,
do not scale production. Reconsider the art/rendering pipeline first.

## Mandatory sources

Read:
1. `docs/visual-references/P6A2_VISUAL_TARGETS.md`
2. the six images described there;
3. `docs/ART_DIRECTION.md`
4. `docs/dev/P6A_REPORT.md`
5. `docs/brain/status.md` and `decisions.md`

Image-access preflight is mandatory. If PRIMARY references cannot be inspected,
STOP rather than improvising from prose.

## Core objective

Produce **one playable Hero Lookdev patch** using real B-17 excavation data that makes
Antoine reasonably say:

> "If the whole game looked like this, I would be confident in the art direction."

The patch does not need to make the whole scene finished.

## Starting pipeline hypothesis

P6A-1 findings are guidance, not canon:

- use **authored material bases** as the artistic foundation (B direction);
- keep useful **wall/projection protection / large-scale breakup** from C;
- procedural noise may support variation, but must not define the art style;
- do not reuse the one-pass P6A-1 atlas as production quality.

The actual P6A2 result must be judged against the target images, not against A/B/C.

---

# 1. Select a representative Hero Patch

Choose one fixed B-17 region that can show together, or through controlled presets:

- plaster/jacket boundary;
- Soil / surface dirt;
- Clay;
- Sandstone / compact matrix;
- a cavity/fractured face;
- dirty Bone;
- clean Bone.

The region must use the real dynamic excavation pipeline.

Provide fixed camera/state presets so before/after iterations are comparable.

---

# 2. Production-style material lookdev

Build a first credible material family for at least:

- surface Soil/dirt;
- Clay;
- Sandstone / compact matrix;
- plaster jacket;
- Bone / Bone Film treatment sufficient to keep the family coherent.

Priority is the **whole material language**, not a standalone Bone beautification task.

Each structural material should be able to use dedicated information where useful:
- albedo/base color;
- normal detail;
- roughness;
- optional micro-height/AO if justified.

Avoid deriving every property from one RGB image.

## Multi-scale breakup

Eliminate the P6A-1 wallpaper effect.

Materials should combine:
- micro detail;
- meso-scale variation;
- macro variation across the patch;
- restrained shader variation / tint;
- projection appropriate to top faces and walls.

No obvious recognizable tile should remain at 1x–3x.

## Authoring tools

Use the lowest-friction workflow that achieves the target.

Permitted:
- Blender;
- Material Maker if installed/useful;
- generated source imagery;
- scripted image processing;
- Godot shader work;
- manual/Adobe cleanup if it materially helps.

Document exactly which tool is used for which artifact.

---

# 3. Jacket-shell prototype

Create **one** representative static/authored plaster jacket shell around the dynamic
excavation core.

Goal:
- break the "rectangular heightfield" perception;
- add chipped plaster edge, thickness and object identity;
- preserve all dynamic excavation inside.

Do not build multiple jackets or a procedural jacket system.

Preferred test:
> dynamic core + static authored shell

The shell must not interfere with picking or gameplay.

---

# 4. Lighting lookdev

Create a P6A2 candidate lighting rig based on the visual pack:

- warm task-lamp/key;
- restrained cooler/neutral fill if useful;
- readable cavity/contact shadows;
- Bone and rock respond differently without glow;
- warm cozy presentation without hiding materials.

Do not rely on heavy post-processing to fake material quality.

Evaluate at overview, 2x and 3x.

---

# 5. Compatibility vs Forward+ A/B

Run one controlled renderer comparison on the same Hero Patch.

Do NOT switch the project permanently just because Forward+ has more features.

Measure whether Forward+ materially improves our ability to reach the target:
- lighting;
- shadows/contact depth;
- material response;
- decals/normal/roughness options if actually used;
- performance.

If the visual gain is weak, keep Compatibility.
If the gain is substantial and production-relevant, document a concrete migration
recommendation for human approval.

No renderer switch is canonized without Antoine.

---

# 6. Material transitions

Test visually:

- thin dusty/dirty surface -> Clay;
- dirty contact Clay -> fresher Clay interior;
- Clay -> Sandstone where present;
- matrix -> dirty Bone;
- dirty Bone -> clean Bone.

The already-approved contact-patina idea may be used.

Do not rewrite Soil gameplay here.

---

# 7. Gameplay survival test

The Hero Patch must still look good while actually using:

- Brush;
- Chisel;
- Blower;
- Precision Pick;
- Bone Film cleaning;
- fracture/chunks/debris;
- zoom/pan.

Do not accept a look that only works in a static screenshot.

---

# 8. What NOT to do

Do NOT:

- build the whole workshop;
- finish the UI;
- implement museum/intake/crates;
- make multiple fossils;
- build multiple jacket families;
- redesign P5 progression;
- solve extraction/mounting;
- do P7 tuning;
- mass-produce P6B assets;
- chase perfect Bone anatomy.

The point is to prove **art quality + production recipe** on a small real gameplay patch.

---

# 9. Required comparison captures

Produce consistent screenshots for human review:

1. P6A-1 best current baseline (B/C) on the same state.
2. P6A2 Hero Patch — overview.
3. P6A2 Hero Patch — 2x.
4. P6A2 Hero Patch — 3x.
5. material close-up showing Soil/Clay/Sandstone/Bone.
6. dirty Bone -> partially cleaned -> clean.
7. jacket boundary.
8. Compatibility vs Forward+ if both are viable.

Where practical, include the relevant reference image beside/in the report as a link,
but never alter/crop the target image to make the comparison look better.

---

# 10. Evaluation rubric

P6A2 is a visual gate, not just a technical gate.

Human review should score:

### Material quality
Does the surface feel authored and tactile rather than wallpaper?

### Style match
Does it belong to the cozy/stylized/warm world of the P6A2 references?

### Readability
Can Soil / Clay / Sandstone / dirty Bone / clean Bone be read while playing?

### Depth
Do cavities, broken faces and jacket edges have convincing visual depth?

### Scalability
Is the authoring recipe repeatable for future blocks/material families?

### Dynamic survival
Does the look hold up under excavation and at 3x?

### Performance
Is the cost acceptable for a desktop Steam target?

P6A2 passes only if the answer is materially positive on all seven.

---

# 11. Deliverables

Create/update:
- `docs/dev/P6A2_REPORT.md`
- source material/texture notes;
- Hero Patch scene/harness or controlled mode;
- one jacket-shell source/export;
- material source assets and dedicated maps;
- lighting configuration;
- renderer A/B evidence;
- performance evidence;
- screenshots listed above.

The report must state:
- what changed visually;
- exact authoring pipeline;
- exact renderer;
- which reference each decision is trying to match;
- known gaps from the targets;
- what would be required to scale to P6B.

## STOP

After the Hero Patch and report:
- stop;
- do not start P6B;
- do not scale the workshop;
- wait for Antoine's explicit visual verdict.
