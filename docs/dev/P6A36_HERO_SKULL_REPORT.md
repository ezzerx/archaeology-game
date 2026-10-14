# P6A3.6 — Crâne de référence artistique

Candidat livré localement le 2026-10-14 après GO d’Antoine pour du vrai travail de
modelage. L’objectif est désormais de juger une qualité artistique pour la
production ; les tests ne constituent pas ce verdict.

## Voir le candidat

`Launch-P6A36-Hero-Skull.ps1`, Godot 4.7.2 stable. Démarrage recouvert.
L’option `-InspectSkull` ouvre directement F5 sur le crâne, sans toucher à la
préparation ; fermer F5 revient au bloc recouvert.

- **F5** : inspection du modèle réellement utilisé par le jeu. Crâne / côtes /
  ensemble, glisser pour tourner, molette pour rapprocher, F5 ou Échap pour fermer.
- Dans l’inspection, **Modèle : nouveau crâne / pilote précédent** alterne les
  deux vrais GLB, avec angle et échelle conservés et chaque objet recentré.
- **Matière : ivoire / étude de forme** retire la texture pour juger les volumes.
  L’éclairage d’inspection est commun aux deux modèles comparés.
- **H** : « Crâne préparé au Pick · réinitialise » exécute 2 128 impacts du Pick
  natif, sans exposition ni hauteur forcée. Le crâne est entièrement révélé,
  sale et sans dégâts ; Brush pour le nettoyer. C’est une fixture de revue,
  pas une session humaine ou une proposition de durée normale.
- La coupe contrôlée précédente et le bouton d’ombres restent disponibles dans H.
  Ces préparations réinitialisent la session et l’annoncent.
- **F6** : mesh / relief du même champ et même préparation, sans reset. Ce témoin
  n’est pas le modèle précédent : les silhouettes/hauteurs diffèrent.
- **F7** : comparatif tactile historique existant ; profils validés conservés.

## Travail artistique livré

Le crâne a été reconstruit avec des cages anatomiques dessinées, volumes
soustractifs et déformations de surface dans Blender ; le générateur en tubes
P6A3.5 n’a pas été simplement retuné. Le modelage est assisté par script, avec
12 cages éditables conservées dans le master. Aucune génération 3D distante.

Silhouette effilée et dissymétrie mesurée ; larges plaques maxillaires, quatre
fenêtres crâniennes de tailles distinctes, rebord frontal et joue bombés.
Le volume bilatéral est creux avec palais, sinus et cavité postérieure. La
mandibule possède une fenêtre, un espace médial entre ses deux côtés et un
renflement postérieur ; elle est posée légèrement ouverte, sans rig ou animation.
Quarante couronnes différenciées, réparties sur deux rangées supérieures et deux
rangées inférieures, sont intégrées au volume. Les marges sont arrondies et la
microvariation géométrique limitée pour conserver des surfaces douces.

L’ivoire chaud et la texture acceptée sont conservés. L’occlusion courte portée
provient des vraies surfaces. Pas de fissures décoratives ajoutées : les dégâts
restent les traces localisées des vrais contacts. Les six côtes sont reprises
exactement du master P6A3.5, y compris leurs normales, UV et données d’occlusion.

Référence de forme : `evidence/p6a36/art-direction-concept.png`, générée avec
ImageGen. C’est un concept, **pas un rendu du jeu ni une image plaquée sur un mesh**.
Les captures `hero-*.png`, `native-pick-*.png` et les autres vues sont de vrais
rendus Godot. Le modèle constitue une interprétation stylisée originale ; aucune
anatomie scientifique exacte d’espèce n’est revendiquée. Références anatomiques
consultées : [AMNH](https://digitalcollections.amnh.org/archive/Tyrannosaurus-rex--1910-2URM1T1DH7A8.html)
et [Smithsonian](https://naturalhistory.si.edu/explore/dinosaurs-fossils/nations-t-rex).

## Source et intégration

- Master : `art/source/p6a36/b17-hero-skull.blend`, avec cages de construction
  masquées dans une collection séparée. Elles ne sont pas exportées au runtime.
- Modélisation : `tools/p6a36/build_hero_skull.py` ; reconstruction et vérification :
  `tools/p6a36/Build-Hero-Skull.ps1 -Graphical`, Blender 5.2.2 LTS.
- GLB : `assets/p6a36/b17_production_patch.glb`, sept pièces fermées,
  **37 118 triangles** (26 798 crâne + 10 320 côtes), 1 080 000 octets.
- SHA-256 livré : `064a0f1981d08fc1b1ff97c1f28c8d911607708344cb3d4dbf9e6195919aef12`.
- Manifeste et champ : `production-manifest.json`, `mesh_patch_data.res` au même endroit.
  Import sans compression de positions ni LOD automatique.

Le crâne définit son champ par projection analytique des triangles finalisés.
Les données de côtes P6A3.5 sont conservées bit pour bit ; le manifeste distingue
10 658 cellules projetées brutes et 10 660 cellules de la ressource runtime,
dont deux limites de côtes déjà présentes dans leur bake validé. Il reste
10 542 cellules gagnantes après 118 occlusions par des vertèbres conservées.
Aucun crâne ou côte historiques de secours sur les pièces remplacées.

Les ombres reprennent le caster dégagé seulement de P6A3.5 ; le modèle complet
enterré ne projette toujours aucune ombre. Le reset efface ce caster immédiatement.
Le nouveau crâne nécessite aussi un contact plus précis aux marges raides :
uniquement sur une cellule pilote réellement exposée, le picker affine son hit
contre les triangles affichés. Matrice et autres os gardent le picker historique.
L’affinement est rejeté si elle cible une cellule couverte, une autre région
ou s’écarte de plus de 5 mm du hit de terrain. Aucun collider ajouté, aucun preset,
rayon, gain Brush, règle de dégâts ou objectif modifié. F6 garde le même picking.

## Vérifications

**356 contrôles, zéro échec** : P5 128, P6A3.3 40, P6A3.4 fonctionnel 26,
P6A3.5 fonctionnel 38 et graphique 31, P6A3.6 fonctionnel 50 et graphique 43.
JSON et 28 captures Godot : `docs/dev/evidence/p6a36/`. Registres QA isolés sous work/.

- 10 660 cellules contrôlées depuis les tableaux de rendu importés : zéro manque,
  erreur de plafond maximale **0,0753 µm**, tolérance de 1 µm conservée.
- L’oracle a été amélioré pour utiliser des scalaires doubles et les positions
  importées originales : la conversion mm → m et les cross products Vector2
  amplifiaient l’erreur sur les triangles raides. La tolérance barycentrique
  historique et celle des plafonds n’ont pas été relâchées. Pilotes 34/35 retestés.
- 144 rayons caméra comparés à la géométrie : contacts alignés dans cet échantillon.
  Les tests couvrent explicitement matrice intacte, partie encore enterrée d’un
  crâne partiellement révélé, plateau réellement exposé et absence de mutation.
  Moyenne observée de 100 picks répétés : environ **58,5 µs** par appel.
- Les cinq fenêtres et la conservation exacte de chaque cellule de côte sont
  exercées. Premier contact protégé, dégâts localisés, courts allers-retours Brush,
  reset, complétion, distinction et archive passent aussi.
- Tout le viewport intact est pixel-identique mesh/relief et ombres on/off.
  Révélation partielle et indices du caster vérifiés ; comparatif d’ombres propre :
  34 455 pixels assombris de plus de 0,025 en luminance, zéro éclairci au-delà.
- F5/F6/F7, comparaison des sources, mode sans texture et états d’inspection
  conservent la préparation. Le Pick natif révèle 100 % du crâne, Condition 100.

Budget natif Compatibility / RTX 5080 à 1× : 73 → 76 draw calls ; +37 118 triangles
visibles et +21 058 triangles de caster sur cette coupe, soit +58 176 primitives.
Textures résidentes observées 177 520 462 octets dans les deux états ; 20 intervalles
médians environ 4,165 ms au cap 240 FPS. Reconstruction du caster ≤2,835 ms dans
cette série, pas de reconstruction au repos. Physique 60 Hz. Mesures courtes avec
d’autres fenêtres possibles, pas une preuve de fluidité d’une session complète.

## Limites et verdict attendu

La reconstruction de bout en bout passe, mais deux exports successifs n’ont pas
la même empreinte binaire (`rebuild-byte-check.json`) : la byte-identité du build
Blender n’est pas garantie. Le GLB, le master, le champ et les preuves de cette
livraison sont versionnés ; ils constituent la référence du retest. Ne pas
remplacer ces fichiers par un nouvel export en supposant son identité.

La révélation et les bords de terrain gardent la grille historique, perceptible
à fort zoom, particulièrement sur les dents. Les captures au Pick sont des
séquences contrôlées, pas une validation humaine de durée ou de ressenti. Les
nouvelles proportions peuvent modifier le temps de révélation. La collection
finale, ses montures et les autres spécimens ne sont pas implémentés ici.

À juger maintenant : silhouette et caractère du crâne, hiérarchie des ouvertures,
volumes à l’angle de fouille et en inspection, dentition, ivoire et cohérence avec
la terre et les côtes. Le concept illustre une intention ; juger la qualité de
production à partir du modèle Godot, sans texture puis en ivoire. La gate reste
exclusivement dans `docs/brain/status.md`.


## Retour humain — 2026-10-14

Antoine : « Ok ca rend bien ! les détails en plus avec dents etc donne plus
d’interet à être précis et c’est plus jolie ».

La direction artistique du nouveau crâne est acceptée comme référence : les
détails anatomiques, notamment la dentition, améliorent à la fois le rendu et
l’intérêt de la précision en fouille. Préserver cette richesse de formes ainsi
que l’ivoire chaud, les ombres exposées, le Brush et les dégâts localisés validés.

Ce verdict porte sur le crâne présenté ; il ne constitue ni un GO de fabrication
du catalogue complet, ni une validation de durée de session ou de toute la phase.
La prochaine extension reste à cadrer avant un nouveau GO, selon le statut canonique.
