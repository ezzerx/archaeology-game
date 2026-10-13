# P6A3 Tool Art — canonical ImageGen references

Human status: **approved by Antoine for P6A3 3D generation**.

These references define the visual family for the four current Archeo preparation tools before Tripo generation.

## Visual language

Shared art direction:
- warm walnut / dark wood;
- aged brass accents;
- worn / patinated steel where appropriate;
- professional natural-history preparation-lab character;
- handcrafted, warm and premium rather than modern plastic / debug-tool aesthetics;
- readable silhouettes under the near-top-down Archeo gameplay camera.

The family board establishes coherence. The four individual images are the **authoritative single-image Tripo inputs** for the first P6A3 tool-art generation pass.

## Files

| Role | Repo mirror | Original ChatGPT PNG | Original dimensions | Original PNG SHA256 |
| --- | --- | --- | ---: | --- |
| Family board | `00-tool-family-board.jpg` | `outils_d_archéologie_artisanaux_assortis.png` | 1448×1086 | `4a8a08694afb239e74810e1345969cfdd6fbb7ca6303df7b8ed56caa5aa5a8b9` |
| Brush | `01-brush-3d-reference.jpg` | `brosse_archéologique_en_noyer_et_laiton_vieilli.png` | 1254×1254 | `d9ff8732b1bed777bb0eca7a9d4c2a8c440e56e838f755e9eee204a563e6d5ce` |
| Chisel | `02-chisel-3d-reference.jpg` | `ciseau_archéologique_vintage_gravé.png` | 1254×1254 | `8f616fcf083061bb0ed8c0283789a43b4615ad2f54f01133dbd36cd6a22b8a38` |
| Precision Pick | `03-precision-pick-3d-reference.jpg` | `outil_de_précision_en_bois_et_laiton.png` | 1254×1254 | `aeff75262d4049941b5eb1cca79702583b66d1334b5d32b6b9cb2465b52bab83` |
| Air Blower | `04-air-blower-3d-reference.jpg` | `soufflet_archéologique_antique_en_laiton.png` | 1254×1254 | `d2df1193b60cc53b1eb756ef8a59b1b60a0f0aa426467ce4c5bbe59051b49b5e` |

The repo files are high-quality JPEG mirrors used for durable agent access. The original ChatGPT outputs were PNGs; their SHA256 values above preserve provenance.

## Production pipeline selected for P6A3

Preferred production path:

> **ImageGen approved reference → Tripo → Blender 5.2.2 cleanup / optimization / bake → Godot 4.7.2**

Tripo is the primary agent-facing 3D generator because its official Codex plugin is already authenticated and is the lowest-friction path for Astra. Meshy remains an optional fallback / second opinion, not the default pipeline.

Generation rules:
- use image-to-3D, not text-to-3D;
- the approved image is the source of truth;
- do not redesign the object in Tripo;
- save a high-quality/source generation when useful;
- derive a game-ready mesh with controlled topology / Smart Mesh / Blender cleanup;
- do not ship raw multi-million-face source meshes to Godot;
- retain source/high asset separately from the optimized runtime asset;
- judge the final result inside the real Archeo lighting/camera, not only in the Tripo viewer.

No tool gameplay semantics are changed by these references.
