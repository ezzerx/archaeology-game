# Prototype v0.1 — Fossil Preparation Core

> Current live phase/gate: `docs/brain/status.md`.
> This document defines the V0.1 product target, not the live implementation status.

## Core question

> **Est-ce que j’ai envie de continuer à gratter alors que je sais déjà ce qu’il y a dessous ?**

A positive answer validates the core tactile loop, not the complete commercial game.

## Canonical presentation

> **2.5D stylisée — tabletop — caméra orthographique presque verticale**

No controllable avatar. No open world.

The player is a specimen preparator/restorer working behind the scenes of a natural-history museum.

## V0.1 core loop

> **receive one specimen block → reveal / excavate → clean Bone → reach museum standard → Archive or Keep Cleaning → reset another block**

Current normal tool grammar:
- **Soft Brush** — thin Soil/surface dirt, Bone Surface Film, brushable mess;
- **Chisel** — bulk Clay/Sandstone excavation and fracture;
- **Air Blower** — loose mess evacuation;
- **Precision Pick** — precise attached matrix near Bone.

Historical Forceps/fragments work is dormant and is **not** part of the active V0.1 player loop.

## Core materials

- thin loose Soil / surface overburden;
- Compact Clay;
- Sandstone / compact matrix;
- Bone.

P6A1.5 human review prefers thin irregular Soil overburden rather than the former multi-centimeter Soil layer.

The next foundation question is the natural topography of the Clay/Sandstone matrix itself; see the live status.

## Bone concepts

Keep separate:

> **Exposure ≠ Cleanliness ≠ Condition**

- Exposure = how much Bone structure is revealed.
- Cleanliness = how much adhered Bone Surface Film is removed.
- Condition = preservation/damage state.

## Current completion model

The V0.1 prototype currently uses:
- a museum preparation standard;
- optional further cleaning;
- optional Fine Preparation mastery;
- qualitative Condition feedback;
- Archive / Keep Cleaning.

Exact thresholds are prototype/tuning values and live in the implementation docs, not here.

## Must prove before V0.1 is considered ready

- excavation is satisfying with all four tools;
- materials are immediately readable;
- Bone reveal creates desire to continue;
- the session goal and stopping point are understood without explanation;
- the art direction is reproducible in-engine and survives real excavation;
- performance remains acceptable on representative desktop hardware.

## Out of V0.1 core scope

Do not require for the first serious external playtest:
- full museum meta progression;
- crate intake/opening;
- multiple fossil families;
- equipment economy/progression;
- procedural/seeded block generation;
- final extraction vs in-matrix vs mounted-skeleton model;
- full save/meta economy;
- Steam launch integration;
- large content catalog.

These are post-core systems once the excavation and visual pipeline are proven.

## External validation target

Initial target remains:
- at least **4/5 testers** rate excavation satisfaction **4/5 or higher**;
- at least **3/5 testers** voluntarily continue cleaning after the game has clearly told them the required work is complete.

## Phase sequence

P0 Interaction ✅  
P1 Material / Relief ✅  
P2 Tools ✅  
P3 Fossil ✅  
P4 Game Feel ✅  
P5 Complete Session ✅  
P6 Art Pass / visual pipeline ▶  
P7 Final tuning

Exact active substep is always in `docs/brain/status.md`.

## References

- [Status](brain/status.md)
- [Roadmap](ROADMAP.md)
- [Gameplay Loop](GAMEPLAY_LOOP.md)
- [Art Direction](ART_DIRECTION.md)
- [Future Systems](FUTURE_SYSTEMS.md)
- [Orchestration Handoff](ORCHESTRATION_HANDOFF.md)
