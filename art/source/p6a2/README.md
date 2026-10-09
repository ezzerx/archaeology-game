# P6A2 Hero Patch — sources et provenance

Sources originales de lookdev pour ArchaeologyGame. Gate courante :
`docs/brain/status.md`. Première livraison : commit `a9d47b6` et rapport
`docs/dev/P6A2_HERO_LOOKDEV_REPORT.md` (preuves historiques conservées).

## Coque de correction — 7 octobre 2026

- Source : `meshes/b17_jacket.blend`, Blender **5.2.2 LTS**.
- Construction scriptée originale : `tools/p6a2/build_hero_assets.py`, graine
  627207. Aucune base externe, scan, anatomie ou données fossiles.
- Références 01/03/00 : langage de contenant plâtré, sans extraction de pixels.
- Une unité = 1 m ; Blender Z-up/+Y avant → Godot Y-up/−Z avant.
  Origine au centre du bloc ; rotations/échelles appliquées.
- Contour extérieur asymétrique de 25 points, corps à six anneaux, 23 érosions
  locales, quatre épaules amincies, hauteur variable, 38 petits éclats solides
  intégrés, deux bandes de toile extérieures. Normales recalculées avec
  cassures marquées sur les changements de plan ; UV planaires et COLOR_0.
- Trois meshes : `jacket_contact`, `jacket_shell`, `jacket_burlap`.
  **6 400 triangles** ; GLB 320 216 octets ; .blend 262 763 octets.
- Overrides locaux Godot dans `materials/p6a2/`. Plâtre/contact : nouvelle
  source plaster v02 + teintes de sommets (plâtre gris chaud / contact sale).
  Toile et établi : shaders de la première livraison, sans nouveaux props.
- Aucun sommet dans le cœur XZ de 1.1 × 0.7 m, aucune collision ; test des
  132 rayons de bord jusqu’au fond. Aucun recouvrement volontaire du cœur.
- Le contour intérieur reste rectangulaire : amélioration expérimentale,
  pas acceptation humaine d’une coque finale. Rapport de correction détaillé :
  `docs/dev/P6A2_TARGETED_CORRECTION_REPORT.md`.

```powershell
# Exporter une source éditée sans la reconstruire.
.\tools\p6a2\Export-Hero.ps1
# Reconstruire explicitement la coque scriptée et son GLB seulement.
.\tools\p6a2\Export-Hero.ps1 -Regenerate
```

Le helper utilise `BLENDER_BIN` / `-BlenderBin`, sinon
`%LOCALAPPDATA%\Programs\ArchaeologyGameTools\blender-5.2.2-windows-x64`.
`-Regenerate` écrase intentionnellement la source scriptée : ne pas l’utiliser
pour exporter une sculpture manuelle ultérieure. Export depuis le .blend
rouvert, GLB Y-up, modifiers, normales/UV/couleurs/matériaux ; sans animations,
caméra ou lumière. Empreintes/tailles : `meshes/jacket_manifest.json`.
Installation Blender et caches hors Git.

## Sources ImageGen v02 sélectionnées

Commit externe `5a3d340`, sélection orchestrateur et autorisation d’intégration
explicite d’Antoine. Cinq **miroirs JPEG 1254²**, pas les PNG originaux ni des
2048² : Clay, Sandstone, Soil, Bone, plaster. Provenance, SHA des originaux,
limites de raccord et prompts : `images/README.md`, `images/P6A2_IMAGEGEN_PROMPTS.md`.
La demande historique reste dans `docs/dev/P6A2_IMAGEGEN_SOURCE_REQUEST.md`.

Dérivés runtime : `assets/p6a2/textures/<material>/p6a2_<material>_albedo_v02.png`.
Reproduction : Godot 4.7.2 `--headless --path . --script tools/p6a2/prepare_textures.gd`.
Conversion RGB8 et réduction Lanczos 1254→1024 uniquement. Pas d’upscale,
retouche lumineuse, normal/height map ou masque inventé. SHA réels des JPEG
et des PNG dérivés dans `images/runtime_manifest.json`.

Import lossless, mipmaps, filtrage anisotrope dans les samplers `source_color`.
Projection triplanaire à échelle nominale 24 cm ; deux lectures décalées/tournées réduisent la répétition
périodique du cœur. Plâtre : projection triplanaire à 24 cm sur les côtés aussi.
Assombrissement/désaturation Stone et légère correction Bone **dans le shader
Hero seulement** ; roughness mate. Les sources ne sont jamais interprétées en
hauteur. Le relief et Bone Film proviennent uniquement du système Godot natif.

## Sources historiques retirées du Hero

L’atlas `assets/p6a/material-atlas.png` a été rejeté humainement.
**Il n’est plus référencé par le Hero.** Sa provenance reste dans
`assets/p6a/README.md` et `generation-prompt.txt`, pour l’expérience historique.

Les quatre `p6a2_*_surface_data.png` initiaux sont aussi débranchés.
`meshes/asset_manifest.json` conserve leurs empreintes historiques.
Leur générateur reste récupérable au commit `a9d47b6` ; le générateur courant
ne reconstruit que la coque. Aucun fichier historique n’est présenté comme
nouvelle source acceptée. Pas de suppression des preuves antérieures.
