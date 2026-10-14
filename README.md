# ArchaeologyGame

**Working title.**

Cozy, tactile fossil-preparation game set behind the scenes of a natural-history museum.

The player works directly on specimen blocks from a fixed near-top-down tabletop view: reveal matrix layers, expose and clean Bone, preserve the specimen, then archive the preparation for the museum.

## Current state

**Do not use this README as the phase gate.**

Live project status, active branch/PR and next authorized action:
- [docs/brain/status.md](docs/brain/status.md)

Stable product handoff:
- [docs/ORCHESTRATION_HANDOFF.md](docs/ORCHESTRATION_HANDOFF.md)

Documentation rules:
- [docs/DOCUMENTATION_POLICY.md](docs/DOCUMENTATION_POLICY.md)

## Engine

- Godot **4.7.2 stable**
- GDScript
- desktop prototype
- current renderer baseline: Compatibility/OpenGL unless an active visual spike proves a concrete reason to change

## Run the game

Open `project.godot` in Godot **4.7.2 stable** and press F6 (Run Project),
or run `./Launch-Game.ps1` on Windows. Pass `-GodotBin` if the engine is installed
elsewhere. The default entry point uses the modeled B-17 and starts fully buried.

In game: left click works, 1–4 selects tools, wheel zooms, right drag pans,
Home returns to overview and R restarts. F5 inspects the source model outside
the matrix; Escape closes inspection. F6 compares mesh/relief and F7 compares
preparation feedback. These in-game keys differ from Godot editor shortcuts.

The versioned GLB and baked field are sufficient to play; Blender is only needed
to rebuild the model. Historical scenes and dedicated comparison launchers remain
available. See the [B-17 report](docs/dev/P6A37_SKELETON_REPORT.md) for source,
verification and known limits; use the Brain status for the current gate.

## Validated core

- fixed tabletop / near-top-down excavation
- deterministic B-17 fossil block
- Soft Brush
- Chisel
- Air Blower
- Precision Pick
- progressive Bone Exposure
- Bone Surface Film / Cleanliness
- Bone Condition
- fracture / debris feedback
- zoom / pan / reset
- complete preparation-session loop with Archive / optional further cleaning

## Product north star

> **Est-ce que j’ai envie de continuer à gratter alors que je sais déjà ce qu’il y a dessous ?**

## Canonical docs

- [Concept](docs/CONCEPT.md)
- [Gameplay Loop](docs/GAMEPLAY_LOOP.md)
- [Art Direction](docs/ART_DIRECTION.md)
- [V0.1 Target](docs/MVP_V0_1.md)
- [Museum System](docs/MUSEUM_SYSTEM.md)
- [Future Systems](docs/FUTURE_SYSTEMS.md)
- [Roadmap](docs/ROADMAP.md)
- [Visual References](docs/VISUAL_REFERENCES.md)
- [Future Release / Studio Notes](docs/FUTURE_RELEASE_BUSINESS.md)

Historical phase evidence lives under `docs/dev/` and must not be used to infer the current phase.

## Playable geometry comparison

Run `./Launch-Natural-Matrix-Lab.ps1` or open
`scenes/p6a16_natural_matrix_lab.tscn` in Godot and press F6.
F8 compares the two substrates with the same thin Soil; F9 removes Soil for inspection.
The [geometry report](docs/dev/P6A16_SURFACE_GRAMMAR_REPORT.md) contains the fixtures,
measurements and human retest procedure. The normal project launch uses the entry point documented above.
