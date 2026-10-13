# P6A3 — tool and lamp source assets

See `docs/dev/P6A3_TOOL_FEEL_SENSORY_REPORT.md` for review, evidence and budgets.
These are review candidates, not automatically human-approved production art.

- `tripo/*_high.glb`: immutable Studio masters, never loaded by the game.
- `tripo/*_low.glb`: immutable Smart Mesh P1.0 Triangle exports, original 2K PBR.
- `tripo/provenance.json`: approved source paths, projects, costs, hashes and license reference.
- `blender/*.blend`: packed editable cleaned runtime source, metre scale, 1K PBR.
- `blender/*.json`: actual mesh counts, dimensions and texture dimensions.
- Runtime: `assets/p6a3/models/*.glb` (no colliders, no imported lights).

Reproduce a cleaned asset from its local retopo source:

```powershell
$blender = Join-Path $env:LOCALAPPDATA 'Programs/ArchaeologyGameTools/blender-5.2.2-windows-x64/blender.exe'
& $blender --background --factory-startup --python-exit-code 1 --python tools/p6a3/build_runtime_assets.py -- chisel
```

Other names: `brush`, `pick`, `blower`, `lamp`. This only runs local Blender;
it does not contact Tripo or spend credits. Diagnostic views go to ignored `work/p6a3-art/`.
All transforms are applied. Blender Z-up exports as Godot Y-up; tool origins are
their working tips. Lamp placement is in the isolated P6A3 scene assembly.

**Chisel warning:** the raw Tripo source has two splayed blades, identified by
Antoine. The script/cleaned `.blend` and runtime have one repaired blade.
Do not re-import the raw low directly as a runtime replacement.

The lamp's lower arm is extended after reducing shade/base scale to fit the
fixed camera and existing light; this stretches the dark arm UVs. The original
lamp master remains unchanged. The Blower high is the official compressed
viewer GLB, successfully imported by Blender 5.2.2 at 1,987,658 triangles.
