# P4 — Game Feel / Material Reactions

**Status:** authorized after human validation and merge of P3  
**Date:** 2026-10-02  
**Engine:** Godot 4.7.2 stable Standard  
**Renderer:** keep current Compatibility renderer unless a concrete P4 blocker requires a documented decision  
**Gate:** P5 must not start before human validation of P4

**Corrective addendum — 2026-10-03:** Antoine explicitly authorized a fourth prototype tool, Precision Pick, and a split between transient chunks, locally budgeted persistent crumbs and dominant fine dust. This supersedes the original three-tool scope below. Preserve the human-validated Chisel fracture, existing tool values, bone sounds, Brush audio and camera. Current implementation, tests and retest gate: [P4_REPORT](P4_REPORT.md) and [P4_MATERIAL_REACTION_DECISION](P4_MATERIAL_REACTION_DECISION.md). PR #5 stays draft; no merge or P5.

## Goal

P4 must answer:

> **Does excavating the block begin to feel tactile, readable and satisfying rather than like editing a heightmap?**

P3 proved that discovering hidden bone creates the desire to continue. P4 now improves the *moment-to-moment action* without starting the final art pass.

This is a **gameplay/game-feel milestone**, not production DA.

## Core design principle

The current tools may keep using the P1/P2/P3 heightfield as the authoritative geometry, but the visible/material response should no longer feel like a pixel eraser.

Especially for the Chisel:

> **impact → mark/crack → local break/chunk removal → debris/feedback**

rather than:

> impact → smooth circular pixels disappear.

The implementation may simulate fracture rather than build true rigid-body destruction.

## P4 priorities

In order:

1. Material-specific reaction behavior.
2. Chisel fracture / chunk feeling.
3. Tool physicality and feedback.
4. Audio differentiation.
5. Dust / particles / debris.
6. Bone-contact readability.
7. Reassess whether Bone Condition damage is now avoidable through careful play.
8. Preserve all P0–P3 precision, zoom and performance guarantees.

Do not spend P4 on final table props, final textures, final UI skin or museum presentation.

## Material response

### Loose Soil

Target feeling: loose, granular, forgiving.

- Brush remains the natural primary tool.
- Continuous removal can remain smooth.
- Add small soil particles / dust tied to actual removed depth.
- Brush movement should read visually as sweeping rather than drilling.
- Chisel may disturb it but should not become the preferred tool.

### Compact Clay

Target feeling: dense, cohesive, capable of peeling/chipping.

The Chisel should not simply erase a round patch every impact.

Preferred prototype behavior:

- impacts create local stress / marks;
- repeated or sufficiently strong impacts cause an irregular **clay chip / plate** to detach;
- the detached area produces a discrete height drop rather than a perfectly smooth circle;
- particles/debris communicate the break.

The exact fracture simulation is open. Prefer a deterministic, inexpensive model.

### Sandstone

Target feeling: hard, brittle, cracking.

Preferred behavior:

- Chisel impact creates a visible/readable crack or stress state;
- one or several impacts can release an irregular **stone chunk**;
- chunks should generally be smaller/harder than Clay plates;
- breaking Sandstone should feel materially different from Clay.

Do not build a general-purpose destructible-mesh/voxel engine.

## Fracture architecture

Codex must first review the cheapest architecture compatible with the current heightfield.

Preferred families of solution include:

- coarse local fracture/stress map;
- deterministic pre-partitioned fracture cells / Voronoi-like patches;
- local seeded masks generated from an impact;
- another lightweight deterministic approach.

Requirements:

- heightfield remains authoritative;
- fracture is local to the active footprint/region;
- deterministic enough for testing;
- reset exact;
- no per-frame whole-map simulation;
- no giant new mutable full-resolution texture unless justified;
- chunk removal must respect material boundaries and the fossil bone ceiling;
- huge impacts may not tunnel through bone.

Document the chosen model in:

`docs/dev/P4_MATERIAL_REACTION_DECISION.md`

## Bone interaction / condition review

P3 deliberately left Bone Condition balance unresolved.

Do **not** reintroduce the discarded P3 2 mm safety margin or near-bone Brush override by default.

First evaluate the new material/chunk behavior.

P4 must answer:

> **Can careful play now reveal bone without condition loss being structurally unavoidable?**

Rules retained:

- first hidden bone contact is protected;
- bone remains structurally indestructible in V0.1;
- Brush and Blower do not damage bone;
- direct careless Chisel contact on already exposed bone may damage condition.

After material reactions exist, tune only enough to make the risk model coherent.

Acceptance target is qualitative, not final P7 balance:

- condition loss should come from a readable player mistake / risky direct impact;
- normal careful excavation should **not inevitably drive the specimen to 0%**;
- Antoine should be able to expose a meaningful fossil region while retaining high condition.

If fracture alone does not solve this, document the evidence and propose the smallest additional mechanic for review **before implementing a new protection rule**.

## Physical tool presence

Use placeholder geometry only.

### Brush

- simple visible brush/tool proxy follows the interaction point;
- mild visual lag/inertia allowed, while actual interaction stays exact;
- simple bristle/contact response is desirable but not required if expensive;
- no hands/arms.

### Chisel

- visible placeholder tool;
- small recoil/impact animation at cadence;
- contact point remains exact;
- impact animation must not alter simulation timing.

### Blower

- simple visible nozzle/tool proxy;
- airflow/dust response should make its role obvious;
- no hand model.

Final meshes/materials belong to P6.

## Particles / debris

Use restrained placeholder particles.

Required families:

- Soil dust/grains;
- Clay chips;
- Sandstone fragments;
- Blower air/dust movement;
- small bone-contact cue if useful, but no supernatural glow.

Rules:

- particles spawn from **actual material work/removal**, not merely from mouse movement;
- particle density scales with interaction intensity/removal;
- avoid obscuring bone discovery;
- bounded lifetime and count;
- particles/debris are visual feedback, not authoritative gameplay state.

A few simple temporary rigid-body fragments are acceptable if cheap, but gameplay must not depend on them.

## Audio

P4 must introduce functional placeholder sound design.

Each interaction family should be recognizably different even before P6:

- Brush + Soil;
- Brush + Clay;
- Chisel + Clay;
- Chisel + Sandstone;
- Bone contact;
- Air Blower.

Use simple generated/procedural/placeholder sounds if production samples are unavailable.

Requirements:

- variations to avoid obvious single-sample repetition;
- slight pitch/volume variation;
- Chisel sound tied to actual impact cadence;
- Brush sound intensity responds to movement/removal;
- bone contact has a clearly distinct timbre;
- no music requirement in P4.

No copyrighted/external assets with unclear license.

## Dust / residue

P2 residue remains the gameplay/debug state.

P4 may improve how it is visualized:

- local dust veil;
- particles;
- transient visual accumulation;
- blower-clearing feedback.

Do not make particles authoritative.

Blower must continue to alter residue without structural excavation.

## Lighting / readability

Only minimum gameplay-readable lighting work.

Allowed:

- improve local cavity shadows/readability;
- warm key light prototype;
- make exposed bone catch light slightly differently;
- improve Bone-vs-Clay contrast enough for testing.

Do not perform the P6 art pass.

P4 should make bone **readable**, not final-looking.

## Zoom and input

P3 zoom is canonical and must remain intact:

- wheel = zoom 1×–3×;
- Home = overview;
- Shift+wheel = dev power;
- Ctrl+wheel = dev falloff;
- Alt+wheel = dev radius;
- F6/F7 fallback;
- fixed ~84° orientation;
- exact picking throughout.

P4 tool visuals must not interfere with the actual picking point.

## Runtime / performance

Normal F5:

- max 240 FPS;
- physics 60 Hz.

Performance target remains at least a comfortable 60 FPS interaction budget on the current test machine, while retaining the 240 cap for normal runtime.

Measure separately:

- particles off/on if useful;
- Soil brushing;
- Clay breaking;
- Sandstone breaking;
- Chisel near/exposed bone;
- Blower over dust/residue;
- zoom 1× and 3×.

Do not optimize the 1.31M-triangle surface unless P4 introduces a measured regression that makes normal interaction unacceptable.

## Configurability

New feel parameters must be data-driven where practical.

Examples:

- fracture stress threshold;
- fracture radius/patch scale;
- chunk depth;
- particle amount;
- particle lifetime;
- recoil amount;
- sound variation ranges;
- dust multiplier.

Do not hardcode final balance.

## Automated tests

All P0/P1/P2/P3 tests must remain green.

Add P4 tests for at least:

- deterministic fracture result for fixed input/seed;
- Clay reaction differs from Sandstone;
- discrete Chisel impacts do not bridge continuously;
- chunk removal respects layer boundaries;
- fracture cannot tunnel below bone ceiling;
- first hidden contact still protected;
- direct exposed-bone Chisel damage remains bounded to one event/impact;
- Brush/Blower remain bone-safe;
- Blower changes no structural height;
- particles/events only emitted from valid interactions;
- reset clears fracture/dust/transient gameplay state exactly;
- zoom/picking regressions remain green;
- 240 FPS cap / 60 Hz physics unchanged.

Avoid brittle tests against purely cosmetic particle positions unless deterministic behavior is specifically required.

## Human acceptance test

Antoine should play without staring at F1 first.

### A — Material identity

Can he tell from response/feel that:

- Soil is loose;
- Clay is cohesive;
- Sandstone is brittle/hard?

The distinction should not depend only on color.

### B — Chisel

Does Chisel now feel like striking/breaking material rather than erasing pixels?

Expected perception:

> impact → reaction → crack/chip/chunk

### C — Tool loop

Does the natural loop become clearer?

> Brush bulk soil → Chisel hard matrix → Blower residue → precision around discovery

### D — Bone discovery

Is Bone detected easier to notice through a combination of:

- material response;
- sound;
- small visual cue;
- lighting/contrast?

No final DA required.

### E — Condition fairness

After learning the reactions, can Antoine expose a meaningful amount of fossil without condition inevitably collapsing?

If not, report exactly which material/tool interaction still forces damage. Do **not** automatically patch it before review.

### F — Satisfaction

Play 3–5 minutes and answer:

> “Am I enjoying the act of excavating more than in P3, even though the art is still placeholder?”

That is the primary P4 gate.

## Scope exclusions

P4 must NOT implement:

- final art direction / production textures;
- final table/room composition;
- final UI skin;
- specimen classification progression;
- objectives;
- collectible fragment system;
- Preparation Complete;
- Keep Cleaning;
- museum;
- progression/economy;
- procedural block generation;
- tool unlock tree;
- additional specimens;
- save system;
- Steam features;
- hands/arms;
- full music system;
- final tuning.

Those remain P5/P6/P7 or post-V0.1.

## Documentation

Create:

- `docs/dev/P4_MATERIAL_REACTION_DECISION.md`
- `docs/dev/P4_REPORT.md`

Report:

- material reaction model;
- fracture architecture;
- particle/debris architecture;
- tool visual proxies;
- audio approach;
- Bone Condition findings;
- performance;
- tests;
- limitations;
- exact human checklist.

## Git

Work on:

`prototype/p4-game-feel`

At completion:

- push branch;
- open PR to main;
- keep PR unmerged;
- stop.

## Final gate

P5 is forbidden until Antoine personally validates P4 and explicitly authorizes the merge / next phase.
