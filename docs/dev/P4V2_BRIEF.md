# P4-V2 — Terrain-Aware Debris Physics Spike

**Status:** authorized human experiment after P4-V1 validation  
**Date:** 2026-10-04  
**Base:** `main@ce014d0c2dd311ed2fbac0f37e0001be707a74a7`  
**Branch:** `prototype/p4v2-debris-physics`  
**Scope:** bounded, lightweight debris physics for game-feel validation only.

## Why this spike exists

P4 Final Feel and P4-V1 verticality are now validated.

The remaining hypothesis is sensory:

> Does debris that actually reacts to the relief — falling into cavities, bouncing/sliding, and being pushed out by the Air Blower — make excavation meaningfully more satisfying?

This is an experiment, not a commitment to a full physics simulation.

If human testing does not clearly improve the loop, keep the simpler P4-V1 system and move on.

## Product goal

Create a lightweight terrain-aware debris layer where hard-material fragments can:

- leave the Chisel impact with velocity;
- fall under gravity;
- sample the current excavation heightfield beneath them;
- collide with / bounce on the excavated relief;
- slide or roll downhill in a simplified way;
- fall into cavities instead of bouncing on their original impact height;
- receive a visible Air Blower impulse;
- leave the block / get ejected when pushed beyond the work surface.

Target loop:

```text
Chisel
→ chunk breaks free
→ chunk falls / bounces into cavity
→ a few pieces remain visibly in the work area
→ Air Blower
→ pieces jump / slide / leave the block
→ clean cavity
```

The goal is not realism for its own sake.

The goal is:

> Chisel feels heavier, verticality reads better, Blower becomes more physically satisfying.

## Critical scope rule

Do **not** replace the current structural simulation.

The authoritative gameplay remains:
- RF heightfield;
- material maps;
- Bone ceilings;
- existing fracture logic;
- existing Fine Dust / persistent mess logic.

Debris physics is a bounded secondary simulation / feedback layer.

No debris object may:
- change structural height;
- damage Bone;
- alter fossil exposure;
- affect material resistance;
- become required for objective completion.

## No RigidBody swarm

Do not spawn one Godot physics body per fragment.

Avoid:
- hundreds of RigidBody3D;
- physics-engine collision meshes rebuilt from the heightfield;
- dynamic concave colliders;
- full per-fragment node hierarchies.

Prefer a custom lightweight simulation using existing arrays / MultiMesh pools.

## V2A first: bounded dynamic hard fragments

Start with Clay / Sandstone chunks only.

Do not immediately rewrite Soil grains, Fine Dust, and all persistent LooseDebris.

Each active dynamic fragment should have roughly:

```text
position_local_xyz
velocity_xyz
rotation
angular_velocity
size
material
age
state = AIRBORNE / CONTACT / SLEEPING
```

A compact Dictionary/struct-like representation is acceptable for the spike if bounded.

Use a hard global cap.

Suggested first cap:
- 32–48 active terrain-aware hard fragments total.

Never allow unbounded accumulation.

## Heightfield collision

At each physics update for an active fragment:

1. integrate gravity;
2. integrate local X/Z movement;
3. sample the real current relief height at the fragment X/Z;
4. compare the fragment bottom against terrain height;
5. resolve penetration upward;
6. update vertical velocity with restitution;
7. update lateral velocity with friction;
8. optionally derive a cheap local downhill direction from nearby height samples.

No expensive triangle collision is required for every fragment.

The existing heightfield is the collision oracle.

## Terrain sampling

Use the same local-space / UV mapping as the block.

At fragment local X/Z:
- convert to normalized UV;
- reject outside block bounds;
- sample current `ReliefSurface.height_at(uv)`.

If slope information is useful, estimate it from a tiny fixed number of nearby height samples.

Do not scan large regions.

Suggested:
- centre height;
- +/- X sample;
- +/- Z sample.

That is enough for a cheap slope gradient.

## Collision feel — prototype targets

Gravity should look plausible relative to the small tabletop scale.

Do not blindly use 9.81 m/s² if it looks too violent at the current visual scale.

Data-drive:
- gravity;
- restitution;
- friction;
- slide threshold;
- sleep threshold;
- blower impulse;
- lifetime / sleep fade.

Initial feel target:
- first impact visible;
- maybe one small secondary bounce;
- then settle/slide;
- no pinball behavior.

Clay:
- lower bounce / more damping.

Sandstone:
- slightly sharper bounce / less damping.

Exact tuning is provisional.

## Cavity behavior — the core V2 test

This is mandatory.

If a chunk breaks near the edge of a cavity and there is lower relief beside/below it:

it must be able to:

```text
leave impact point
↓
fall toward lower terrain
↓
land deeper in the cavity
```

It must NOT behave like P4 where the original impact height is a permanent invisible floor.

Create deterministic test fixtures proving:
- flat landing;
- shallow slope;
- deep cavity;
- ledge with void/lower floor;
- edge of block.

## Air Blower interaction

The Blower must affect active terrain-aware hard fragments.

When Blower works near a fragment:

apply an impulse based on:
- distance / tool radius;
- tool falloff;
- current jet direction;
- optional small upward lift.

Conceptually:

```text
velocity += jet_direction * blower_impulse * weight
velocity.y += lift_impulse * weight
```

Do not alter the locked Air Blower ToolDefinition.

Physics-specific impulse values belong in the debris physics profile.

Human target:

> A piece sitting in a cavity visibly jumps / slides away when blown.

If a fragment leaves block bounds:
- emit/use the existing `debris_ejected` semantics where appropriate;
- remove/recycle the fragment.

## Relation to existing P4 transient chunks

Current Chisel hard-material transient chunks are visual particles with simple original-height bounce.

V2 should replace that motion path for the chosen hard-fragment subset.

Preserve:
- approximate P4-A spectacle;
- number of break-off cues;
- material color;
- face contrast;
- Chisel audio;
- fracture marks/cracks.

Do not accidentally double-spawn both old and new versions of every hard chunk.

If some particles remain purely decorative, document exactly which family is terrain-aware.

## Relation to existing persistent mess

Do not rewrite the full `LooseDebris` model in the first implementation.

Persistent mess remains:
- Fine Dust;
- bounded crumbs;
- Brush/Blower cleanup.

The terrain-aware fragment system is initially a **game-feel experiment**.

Important human question:

> Is terrain-aware motion already fun enough as transient/short-lived feedback?

Only if human testing says yes should we consider promoting some settled dynamic chunks into persistent cleanup state.

Do not preemptively couple them.

## Lifetime / sleeping

A fragment should not vanish while obviously mid-air.

Suggested flow:

```text
AIRBORNE
→ collision(s)
→ SLEEPING after velocity remains below threshold
→ short hold
→ fade/recycle
```

Suggested total lifetime target:
- roughly 1.5–3.5 seconds,
- but driven by state, not only a fixed timer.

If Blower hits a sleeping fragment during its hold:
- wake it;
- apply impulse;
- extend/restart its short lifetime if needed.

This lets the player observe and blow pieces without creating permanent clutter.

## Debug A/B toggle

Add a debug-only A/B mechanism if it can be done cleanly.

Preferred:
- F3 toggles `Debris Physics: ON/OFF` for newly spawned chunks;
- F1 displays state;
- R resets.

OFF should approximate the validated P4-V1/P4 transient behavior closely enough for immediate human comparison.

Do not make production UI.

If F3 conflicts with an existing control, choose another unused debug key and document it.

## Determinism

The structural result must remain deterministic.

Debris visuals may use the existing seeded RNG, but:
- reset must reseed predictably;
- automated physics fixtures must be reproducible.

No gameplay logic may depend on fragment landing position.

## Performance

This spike must remain bounded.

Target architecture:
- one manager;
- arrays;
- one or a few MultiMesh pools;
- fixed maximum active fragments;
- small constant number of terrain samples per active fragment.

Do not:
- create/remove Nodes per impact;
- rebuild meshes each frame;
- scan the full RF map;
- create dynamic collision shapes.

Performance target:
- >=60 FPS minimum human interaction;
- aim to remain near the existing 240 FPS cap on the reference PC;
- P95 <16.67 ms in the dedicated scenarios.

Measure:
- active fragment count;
- terrain samples/frame;
- physics simulation usec;
- MultiMesh update usec;
- frame P95/max.

## P4/P4-V1 invariants

Do not retune or change:

### Soft Brush
- radius 40
- power 0.70
- falloff 1.25

### Chisel
- radius 22
- power 0.64
- falloff 2.25
- cadence 4.5 Hz

### Air Blower
- radius 60
- power 0
- falloff 1.0
- residue_clear 2.5

### Precision Pick
- radius 7
- power 0.24
- falloff 1.5
- cadence 6 Hz

Also preserve:
- effort-aware P4-V1 geology;
- Bone depth/IDs/totals;
- layer-interface fix;
- per-component Bone protection;
- Bone Condition;
- audio semantics;
- Brush performance fix;
- zoom/pan/picking;
- dust state;
- persistent debris budgets.

## Dust ↔ edge readability watchpoint

Human P4-V1 validation noted:

> block edges / dark depth cues are easier to read after Blower cleanup.

Do not solve this in V2 unless the physics implementation directly worsens it.

Keep it documented as later P6/P7 visual polish.

## Automated tests

Add focused tests for:

### Gravity
- airborne fragment falls;
- Y velocity responds to gravity;
- no invisible original-impact floor.

### Flat collision
- fragment does not tunnel below terrain;
- collision resolves above surface;
- bounce/damping bounded.

### Cavity
- fragment started near a ledge can end at a lower terrain height;
- final/settled Y reflects the cavity floor, not spawn height.

### Slope
- fragment can acquire downhill lateral movement or continue downhill after impact;
- no uphill energy creation.

### Edge
- fragment leaving block bounds is recycled/ejected exactly once.

### Blower
- nearby fragment receives directional velocity;
- farther fragment receives weaker/no impulse;
- no structural height edit;
- no Bone damage;
- sleeping fragment can wake.

### Bounds
- active fragment count never exceeds configured cap;
- no dynamic Node count growth;
- reset clears all fragments;
- deterministic fixture replay.

### Regression
- all P0–P4/P4-V1 checks green;
- Skull → Skull → Ribs → Ribs remains tik/100 → DING/97 → tik/97 → DING/94;
- tool resources byte/field values unchanged;
- structural RF result with debris physics ON vs OFF is identical for the same input sequence.

## Performance fixtures

Benchmark at least:

1. Flat Clay repeated Chisel impacts.
2. Flat Sandstone repeated Chisel impacts.
3. Deep cavity with maximum active fragments.
4. Chisel near cavity edge.
5. Blower hitting many active/sleeping fragments.
6. Physics ON vs OFF A/B.
7. 1× and 3× for the heavy cases.

Report:
- average FPS;
- 1-second minimum;
- P95;
- max frame;
- max active fragments;
- max physics simulation usec.

## Human test

The human test must be about feel, not realism.

### A — Chisel weight

Break Clay/Sandstone on relatively flat terrain.

Question:

> “Est-ce que voir les morceaux tomber/rebondir rend le Chisel plus satisfaisant ?”

### B — Cavity

Create a clear cavity / ledge and break material at its edge.

Question:

> “Est-ce que je vois naturellement les morceaux tomber plus bas dans le trou ?”

This is the main V2 success condition.

### C — Blower

Let several fragments settle briefly, then use Air Blower.

Question:

> “Est-ce que le Blower donne maintenant vraiment l’impression de chasser des morceaux physiques hors de la fouille ?”

### D — A/B

Use debug physics OFF, reset, perform similar Chisel/Blower sequence.

Then physics ON, reset, repeat.

Question:

> “La version ON est-elle clairement plus fun, ou seulement plus complexe ?”

This is the decision question.

### E — Clutter

Question:

> “Les morceaux physiques gênent-ils la lecture du Bone ou du point de travail ?”

Target:
- no meaningful obstruction.

### F — 10 minutes

Play freely.

Target:
- P4 Final Feel preserved;
- no urge to constantly manage debris;
- no performance annoyance.

## Decision gate

After human test, choose one:

### KEEP
If terrain-aware debris clearly improves Chisel + Blower:
- keep bounded V2 architecture;
- document accepted parameters;
- merge.

### SIMPLIFY
If only one part helps:
- e.g. keep gravity/cavity fall but remove sliding;
- or keep Blower impulse only.

### DROP
If effect is subtle / distracting / too expensive:
- revert V2 branch;
- P4-V1 remains canonical;
- move to P5.

A failed spike is a valid outcome.

## Deliverables

Create:
- `docs/dev/P4V2_REPORT.md`

Update:
- `docs/brain/status.md`
- `docs/brain/decisions.md`

Document:
- architecture;
- fragment cap;
- terrain samples;
- gravity/restitution/friction values;
- blower impulse;
- lifecycle;
- ON/OFF A/B mechanism;
- tests;
- perf;
- human checklist;
- known limitations.

## Git / stop condition

Stay on:
`prototype/p4v2-debris-physics`

Use the P4-V2 draft PR.

Do not merge.

When implementation + automated validation are complete:

**STOP for human A/B test.**

Do not start P5 in the same delivery.
