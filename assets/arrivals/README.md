# Assets des arrivages (#27)

Ce dossier suit la séparation sources/modèles du mobilier dans `assets/museum/`.
Les accessoires du musée sont référencés directement, sans copie ici.

- `source/tripo-studio/<objet>/original.glb` : export d'Antoine intact.
- `source/tripo-studio/<objet>/provenance.json` : nom reçu, SHA-256 et métriques.
- `source/tripo-studio/<objet>/fitted.blend` : master ajusté en mètres, avant réduction.
- `source/.gdignore` : sources et masters exclus des imports et de l'export du jeu.
- `models/<objet>.glb` : copie réduite pour Godot, textures embarquées et imports associés.
- `models/budgets.json` : résultats mesurés de la préparation Blender.
- `covered_blocks/block_<0|1|2>.scn` : snapshots figés des vrais blocs initiaux,
  sans simulation ; produits par `tools/arrivals/bake_covered_blocks.gd`.

Les géométries des loquets, charnières, calages, étiquettes et de l'architecture
restent dans `scripts/arrivals/`. Les scènes sont dans `scenes/arrivals/`.
Les concepts et fiches Studio restent dans `docs/visual-references/arrivals/`.
Les captures et mesures de validation vont dans `docs/dev/evidence/issue27/`.
Les exports Windows et fichiers intermédiaires vont dans `builds/` et `work/`,
ignorés par Git. Ne pas placer de ZIP de jeu ou d'essais Blender dans `models/`.

Préparation reproductible : Blender en arrière-plan avec
`--python tools/arrivals/prepare_assets.py`, puis import Godot 4.7.2 et génération
des blocs couverts. Inspecter les modèles en vue d'ensemble et au focus avant de
changer les ratios de réduction. Les réglages Studio conseillés ne prouvent pas
les options réellement utilisées pour les GLB reçus.
