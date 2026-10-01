# P2 — Tool System

**Status:** authorized after human validation of P1  
**Date:** 2026-10-01  
**Engine:** Godot 4.7.2 stable Standard, GDScript  
**Gate:** P3 must not start before human validation of P2

## Goal

Replace the generic P1 excavator with the three actual prototype tools and prove that they create **different player decisions** on the same material system.

P2 is not primarily an art/audio milestone. It validates tool semantics, switching, cadence, footprints and material compatibility.

The player should naturally understand:

- **Soft Brush** → continuous, broad, safe, ideal for Loose Soil;
- **Chisel** → discrete impacts, concentrated, suited to Compact Clay and Sandstone;
- **Air Blower** → does not excavate structural material; clears loose surface residue.

P2 must not introduce fossils, bone damage, objectives or the final game-feel layer.

## North-star question for P2

> Without looking at numbers, do the three tools feel functionally different enough that I naturally want to change tools when the surface changes?

## Tool architecture

Create a clean tool abstraction without building a general item/inventory framework.

A lightweight configurable `ToolDefinition` or equivalent should contain only properties needed by P2, e.g.:

- id
- display_name
- interaction_mode
- radius
- power
- falloff
- cadence where relevant
- per-material effectiveness
- residue interaction

Do not add final audio, particle, bone-damage or progression fields yet.

The controller should own selection/input routing. Tools should request surface operations rather than directly mutating unrelated systems.

## Material compatibility

Current P1 material resistance remains part of the calculation.

P2 adds tool effectiveness on top of material resistance.

Target behavior, not mandatory exact numbers:

### Soft Brush

- interaction: continuous stroke
- footprint: broad, soft falloff
- Loose Soil: high effectiveness
- Compact Clay: very low effectiveness
- Sandstone: effectively zero
- structural behavior: smooth removal, not impact-based

The player should quickly learn that brushing clay is possible only at a frustratingly low rate or essentially useless.

### Chisel

- interaction: discrete repeated impacts while LMB is held
- cadence target: about **4–5 impacts/second**
- footprint: smaller and more concentrated than brush
- Loose Soil: not the sensible choice
- Compact Clay: high effectiveness
- Sandstone: useful / moderate-to-high effectiveness
- impact locations follow current cursor position; do not smear into a continuous brush stroke

The chisel must feel mechanically different even before sound and particles exist.

### Air Blower

- interaction: continuous
- structural excavation: **zero or effectively zero**
- primary role: remove loose residue
- footprint: can be broader than brush

It must never become a second brush.

## Minimal residue state

P4 owns final dust/game-feel.

However, the Air Blower needs a real gameplay target in P2.

Therefore P2 may introduce a **minimal debug-only residue state**.

Requirements:

- scalar field or similarly lightweight representation;
- deterministic;
- visually readable in debug/greybox form;
- excavation can generate some residue;
- Soft Brush may clear some residue slowly/moderately;
- Air Blower clears residue strongly;
- Chisel may generate more residue than brush;
- residue must not change geological layer boundaries or replace structural depth;
- no particle simulation;
- no drifting dust;
- no audio;
- no physical debris;
- no production texture.

Prefer a compact format and measure the upload/runtime cost if a second dynamic texture is necessary.

If a cheaper approach can make the Blower testable without a second full-resolution runtime texture, prefer it and document the choice.

## Tool switching

Support:

- keyboard `1` → Soft Brush
- keyboard `2` → Chisel
- keyboard `3` → Air Blower
- minimal clickable debug toolbar is allowed and encouraged if cheap

Switching must be immediate.

The selected tool must be obvious.

No inventory screen.

## Interaction details

### Brush stroke

Preserve P0/P1 continuous stroke quality.

No large gaps during realistic fast mouse movement.

Stationary brushing may continue to act.

### Chisel impacts

Impacts are discrete.

Holding LMB schedules impacts at cadence.

Each impact is applied once.

Moving quickly between impacts should not automatically connect them with a continuous excavated capsule.

The impact position should use the current precise relief pick.

### Blower

Continuous or high-frequency application is acceptable.

It must affect residue only.

It must not lower the height map in normal use.

## Placeholder visual representation

P2 does **not** do the P4 physical-tool art pass.

Acceptable:

- simple tool name / iconless slot;
- footprint ring changes by selected tool;
- a small primitive/debug marker if useful;
- chisel pulse/flash in debug to show impact timing.

Do not build final 3D brush/chisel/blower models, hand animations, VFX or camera feedback.

## Surface APIs

Avoid letting each tool duplicate the P1 hot loop.

Prefer explicit operations such as:

- apply_continuous_excavation(...)
- apply_impact(...)
- apply_residue_clear(...)

or another small set of well-defined surface requests.

Keep P1 relief/picking separate from tool policy.

P1 tests must remain valid.

## Parameters

All tool parameters must be data-driven.

Starting values are tuning seeds, not canon.

Suggested qualitative defaults:

### Soft Brush
- radius: around 35–45 texels
- power: tuned for visibly fast Loose Soil
- falloff: soft
- effectiveness:
  - Soil 1.0
  - Clay ~0.03–0.10
  - Sandstone 0

### Chisel
- radius: around 8–16 texels
- cadence: ~4.5 Hz
- impact power: enough to make Clay clearly preferable to Brush
- effectiveness:
  - Soil low / wasteful
  - Clay high
  - Sandstone useful

### Air Blower
- radius: around 45–70 texels
- structural effectiveness: 0
- residue clear strength: high

Exact tuning is part of P2 iteration and human test.

## Debug UI

F1 should additionally show:

- selected tool;
- interaction mode;
- effective radius;
- current material;
- material resistance;
- tool effectiveness on current material;
- effective structural removal rate;
- current residue value under cursor if residue exists;
- chisel cadence / time to next impact;
- CPU edit timing;
- residue update timing/upload if applicable;
- FPS.

A minimal bottom toolbar should show:

`[1] Soft Brush   [2] Chisel   [3] Air Blower`

Selected state must be visible.

This is debug UI, not final UI.

## Reset

`R` must restore:

- pristine height;
- pristine residue state;
- deterministic stratigraphy.

Selected tool may remain selected.

Reset during held input must not immediately reapply until a fresh intended interaction, preserving P0 behavior.

## Performance

Retain the P1 target:

- 1080p;
- 60 FPS in realistic interaction;
- no visible input lag.

Benchmark each tool separately.

Especially measure:

- continuous Brush stroke;
- Chisel held stationary and moved;
- Blower clearing a broad residue field;
- rapid tool switching;
- combined typical sequence.

Do not optimize the synthetic corner-to-corner P1 stress case unless P2 makes normal interaction regress.

## Automated tests

Keep all P0/P1 tests.

Add P2 coverage for at least:

- tool selection 1/2/3;
- invalid selection handling;
- data-driven parameter bounds;
- per-material effectiveness;
- Brush affects Soil much more than Clay and not Sandstone;
- Chisel cadence deterministic;
- Chisel does not create continuous bridging between impacts;
- Chisel effectiveness on Clay/Sandstone;
- Air Blower does not alter structural height;
- residue generation deterministic;
- residue clearing strength;
- reset restores height and residue;
- focus/window exit cancels held interaction correctly;
- tool switching during held input cannot produce accidental cross-tool stroke;
- performance benchmark hooks remain functional.

## Scope exclusions

P2 must NOT implement:

- fossil geometry;
- bone detection;
- bone condition;
- protected first bone contact;
- fragment recovery;
- objectives;
- classification;
- final dust particles;
- final debris;
- final audio;
- final tool models / hands;
- camera shake;
- final UI;
- museum;
- save system;
- economy;
- Steam integration;
- procedural blocks.

## Human acceptance test

Antoine must test P2 locally.

### A — Tool identity

Without reading debug numbers:

1. Brush Loose Soil.
2. Try Brush on Clay.
3. Switch to Chisel on Clay.
4. Reach Sandstone and compare.
5. Use Blower where residue is present.

He should naturally understand why each tool exists.

### B — Brush

- draw slow and fast curves;
- hold stationary;
- work near layer boundaries;
- verify smooth continuous response.

### C — Chisel

- hold stationary;
- move slowly;
- move quickly;
- confirm discrete impacts rather than a painted line;
- judge whether cadence feels controllable.

### D — Blower

- confirm structural height does not move;
- residue should visibly clear;
- confirm it does not feel like a duplicate Brush.

### E — Switching

Repeatedly switch 1→2→3 during navigation and after release.

No stuck input, bridging, surprise excavation or residue action.

### F — Performance

Normal use should remain smooth at 60 FPS on the local PC.

## Acceptance criteria

P2 is complete only if:

- [ ] all P0 and P1 tests still pass;
- [ ] 1/2/3 select the correct tools;
- [ ] Brush is a continuous stroke;
- [ ] Brush is clearly best on Loose Soil;
- [ ] Brush is near-useless on Clay and useless on Sandstone;
- [ ] Chisel works as discrete impacts;
- [ ] Chisel is clearly the correct tool for Clay;
- [ ] Chisel can work Sandstone;
- [ ] Air Blower changes no structural depth;
- [ ] Air Blower has a real residue-clearing role;
- [ ] residue implementation remains debug-only / non-polished;
- [ ] reset restores all mutable P2 state;
- [ ] no input regressions;
- [ ] realistic use holds 60 FPS locally;
- [ ] automated tests pass;
- [ ] `docs/dev/P2_REPORT.md` exists;
- [ ] no P3+ system exists;
- [ ] branch is pushed and PR opened toward `main`;
- [ ] PR remains unmerged.

## Final gate

P3 is forbidden until Antoine has tested P2 and explicitly authorized the merge / next phase.
