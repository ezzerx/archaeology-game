# P6A2 Hero Patch — sources et provenance

Prototype de lookdev du 7 octobre 2026, créé par Codex pour ArchaeologyGame.
Sélection technique pour revue, **aucune validation artistique humaine implicite**.
La gate courante reste dans `docs/brain/status.md`.

## Jacket Blender

- Source : `meshes/b17_jacket.blend`, Blender **5.2.2 LTS**.
- Auteur : construction scriptée originale `tools/p6a2/build_hero_assets.py` ;
  aucune base externe, scan, mesh IA ou copie d’anatomie.
- Références visuelles : pack canonique 01/03/00, pour le langage plâtre,
  sans extraction de pixels/meshes.
- Une unité = 1 m. Blender Z-up/+Y avant → Godot Y-up/−Z avant.
  Origine au centre du bloc, plan inférieur proche de Y=0.009 m dans Godot.
  Échelles/rotations appliquées ; translations des quatre tabs conservées.
- 256 points × 6 anneaux, rebord d’épaisseur variable, encoches, bevel 1.8 mm,
  72 petites écailles et quatre renforts toile. Normales sortantes ; UV smart-project.
- Export GLB Y-up, modifiers/normales/UV/matériaux, sans animation/caméra/lumière.
  Slots `jacket_plaster` / `jacket_canvas` remplacés **localement** par les
  ShaderMaterials Godot `materials/p6a2/`. Les UV sont exportés mais ce premier
  traitement statique utilise les coordonnées locales.
- Runtime : `assets/p6a2/static/b17_jacket.glb`, racine importée à échelle 1.
  11 790 triangles, cinq meshes, aucune collision, script ou autorité de fouille.
  Contour extérieur statique autour du cœur de 1.1 × 0.7 m, jamais un substitut.

```powershell
# Exporter une source .blend éditée ; ne régénère pas le modèle.
.\tools\p6a2\Export-Hero.ps1
# Reconstruire explicitement source + GLB + quatre cartes de données.
.\tools\p6a2\Export-Hero.ps1 -Regenerate
```

Le helper accepte `BLENDER_BIN` / `-BlenderBin`, sinon utilise la convention
`%LOCALAPPDATA%\Programs\ArchaeologyGameTools\blender-5.2.2-windows-x64`.
`-Regenerate` écrase volontairement ces sources : ne pas l’utiliser pour
exporter une sculpture manuelle ultérieure. Le `.blend` n’est pas promis
octet-déterministe ; le GLB réexporté depuis le fichier rouvert l’est dans
la version vérifiée. Les binaires Blender/caches restent hors Git.

## Cartes de données des matières

Quatre PNG RGBA8 **1024 × 640**, générés par ce même script avec le NumPy
embarqué de Blender ; graines 62720–62723. Empreintes dans
`meshes/asset_manifest.json`. Source exécutable originale, pas de licence tierce.

| Canal | Rôle |
|---|---|
| R | Valeur large, dabs/granules/flecks propres à chaque matière |
| G | Microvariation de normale dérivée, bornée, sans déplacement |
| B | Variation de roughness |
| A | Inclusions supplémentaires ; données, pas transparence |

Chaque carte couvre **une fois 1.1 × 0.7 m** ; pas de répétition/tile. Marques
Soil granulaires, Clay étirées, Sandstone angulaires, Bone rares et douces.
Le shader fixe la couleur séparément ; aucune lumière, ombre, profondeur de
fouille ou forme de fossile n’est cuite dans ces cartes. Godot : import lossless,
mipmaps, sans traitement alpha, sampler linéaire sans `source_color`, repeat off.
Budget alloué théorique RGBA8+mips : 13.33 MiB pour les quatre cartes.

## Source peinte existante

`assets/p6a/material-atlas.png` est réutilisé sans modification. Provenance et
prompt d’origine : `assets/p6a/README.md` / `generation-prompt.txt`.
ImageGen du 6 octobre 2026, 1254² RGB, quatre quadrants. Ce n’est ni un scan
PBR ni un asset final approuvé. SHA256 dans les preuves du rapport Hero.

Le Hero échantillonne une seule fois chaque quadrant avec inset, en données de
valeur uniquement, puis module sa palette et son bump. Aucune reprise des
pixels des concepts canoniques ; aucun nouveau service ou ImageGen local.
Budget conservateur de l’atlas avec mips : ~8 MiB RGBA8. Bone Film continue
d’utiliser exclusivement le masque/pattern dynamique natif.

Pas de nouveaux originaux raster sélectionnés : `art/source/p6a2/images/`
n’est donc pas rempli artificiellement. Une future source fournie par Antoine
suivra les conventions du preflight (original, rôle/échelle/canaux, provenance,
prompt, SHA, sélection humaine, traitement documenté), puis textures dérivées
dans `assets/p6a2/textures/<material>/`.
