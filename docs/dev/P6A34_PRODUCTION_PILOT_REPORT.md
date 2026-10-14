# P6A3.4 — Essai de production 3D soigné

Livraison locale du 2026-10-14, après GO explicite d’Antoine. Candidat à revue
humaine ; aucun choix de pipeline pour le catalogue complet n’est canonisé.

## Jouer et examiner

- Godot 4.7.2 stable : `Launch-P6A34-Production-Pilot.ps1`.
- Scène : `scenes/p6a34_production_pilot.tscn` ; démarrage normalement recouvert.
- **F5** : inspection hors matrice du même GLB, propre. Ensemble / crâne / côtes,
  glisser pour tourner et molette pour rapprocher. F5 ou Échap revient à la
  préparation. C’est un outil de revue de l’asset, pas un écran de collection final.
- **F6** : mesh / relief du même champ dérivé et du même état de fouille, sans
  reset ni tuning. Ce témoin utilise la nouvelle emprise ; l’ancien B-17 exact
  reste accessible dans le lanceur P6A3.3.
- **F7** : préparation tactile P6A3.3 / témoin historique ; profils validés conservés.
- **H** : panneau de revue. « Zone pilote dégagée, os sales · réinitialise »
  crée une coupe contrôlée et expose réellement les cellules correspondantes,
  avec Film à nettoyer. Ce bouton annonce son reset. La coupe plane est une
  fixture de comparaison, pas une session enregistrée ni un résultat de fouille.

## Asset livré et provenance

Fabrication locale paramétrique dans Blender 5.2.2 LTS : un crâne avec arcade,
ouverture antérieure, strut de joue, mandibule et petites dents, plus trois
paires de côtes séparées. Sections aplaties et évasements contrôlés, volumes
fermés avec dessous, normales lissées et triangulation figée avant export.
Le matériau Bone accepté fournit la matière ivoire dans Godot, en fouille et
inspection. Aucun nouvel appel ImageGen/Tripo, aucun crédit externe consommé.
Le GLB Tripo précédent reste intact comme preuve historique.

- Générateur : `tools/p6a34/build_production_patch.py`.
- Master : `art/source/p6a34/b17-production-patch.blend`.
- Asset : `assets/p6a34/b17_production_patch.glb`, 26 562 triangles, sept pièces.
- Manifeste : `assets/p6a34/production-manifest.json` (budgets, volumes, SHA-256).
- Données de projection : `assets/p6a34/mesh_patch_data.res`.
- Reproduction : `tools/p6a34/Build-Production-Pilot.ps1 [-Graphical]` avec les
  versions indiquées. Le helper active `--python-exit-code 1` pour ne pas
  confondre une exception de génération Blender avec un export réussi.
  Reconstruction de bout en bout vérifiée ici : même SHA-256 pour le GLB.

## Liaison modèle / fouille

La projection verticale du modèle triangulé fournit son emprise et ses plafonds
Bone. Elle remplace le Skull et les trois premières paires de côtes uniquement
dans une sous-classe de champ, injectée par le bloc de cette scène. Le point
d’extension du bloc garde `FossilField` historique par défaut.

11 008 cellules sont couvertes par le modèle source. 10 883 deviennent la surface
Bone du pilote ; 125 restent occupées par des vertèbres historiques situées plus
haut, avec leurs ID et hauteur inchangés. Il s’agit d’une occlusion par une autre
pièce, pas d’un secours par l’ancien crâne ou les anciennes côtes. Aucun fallback
historique ne subsiste sur les pièces effectivement remplacées ; les anciennes
zones Skull hors de la nouvelle silhouette redeviennent de la matrice.

Exposure, Film, Condition, protections par composant, règles Archive et profils
Brush/dégâts validés sont réutilisés. Les données géométriques des pièces testées
changent : leurs trajectoires et temps de révélation ne sont donc pas supposés
identiques à ceux de l’ancien champ. Toutes les cellules anatomiques hors pilote
conservent exactement leurs ID et plafonds ; géologie et presets restent inchangés.

Le mesh observe l’exposition réelle et le Film natif. Le relief Bone est supprimé
sur son emprise gagnante. Les ombres du mesh en fouille sont désactivées pour
éviter de révéler sa silhouette sous matrice intacte. Aucune collision mesh ajoutée.
Le matériau reçoit la même carte de dégâts localisés que la préparation P6A3.3.

## Vérification finale

Godot 4.7.2 stable officiel ; graphique Compatibility sur RTX 5080.

| Suite | Contrôles | Échecs |
| --- | ---: | ---: |
| Régression P5 | 128 | 0 |
| Préparation tactile P6A3.3 | 40 | 0 |
| Pilote P6A3.4 fonctionnel | 26 | 0 |
| Pilote P6A3.4 graphique / budget | 21 | 0 |
| Total | 215 | 0 |

- Toutes les 11 008 cellules projetées sont contrôlées indépendamment depuis
  les tableaux de sommets/indices du mesh réellement rendu. Zéro cellule sans
  géométrie ; écart maximal du plafond environ 0,405 µm.
- 183 vrais rayons caméra/outils comparés au mesh : écart maximal environ
  0,248 mm sur les points intérieurs testés, inférieur à la grille native.
- Premier contact protégé, impacts suivants localisés, vrai Brush retirant le
  Film, complétion, archive/distinction et reset passent sur le nouveau champ.
- F5/F6/F7 sont exercés par événements clavier ; un vrai clic d’inspection ne
  démarre pas de stroke. F7 reconstruit l’UI sans perdre le blocage de l’inspection.
- Matrice intacte : pixels identiques mesh on/off. Révélation partielle, détails
  crâne/côtes, dégâts, picking conservé lors du comparatif, vues hors matrice.
- Les sept pièces partagent une seule surface de rendu en fouille, sans changer
  leurs triangles. Mesure à 1× : 73 → 75 draw calls, +26 562 primitives exactes.
  Textures résidentes observées : 177 520 462 octets dans les deux états.
  Médiane sur 20 intervalles : 4,165 ms off/on, au cap 240 FPS. Échantillon court,
  autres applications possibles : ce n’est pas une preuve de performance de
  session complète. Physique 60 Hz et cap 240 conservés.

JSON et captures finales : `docs/dev/evidence/p6a34/`. Les préparations de capture
sont des fixtures explicites ; aucune n’est présentée comme une session humaine.
Le registre de distinctions QA est isolé sous `work/test-logs/p6a34/`.

Le helper `Mesh.get_faces()` a fourni ici une représentation arrondie à 0,1 mm,
provoquant de faux écarts sur les bords fins. L’oracle utilise les tableaux de
rendu exacts, avec projection barycentrique indépendante de Blender. La précision
et la triangulation sont figées dans ce pipeline. La première version à sept
surfaces dépassait le budget local de draw calls ; le batch conserve les pièces
source tout en ramenant le surcoût mesuré à deux appels.

## Limites et verdict attendu

L’anatomie reste volontairement simplifiée et aplatie pour la préparation en
vue de côté/tabletop. Ce n’est pas encore un crâne anatomique complet à exposer
à 360° ni un squelette monté. Les côtes sont des pièces volumétriques isolées ;
aucune articulation/extraction/monture de collection n’est implémentée.

Le masque de révélation et le picking restent sur une grille à hauteur unique.
À 3×, l’aliasing des bords de matrice et de révélation peut rester visible. La
coupe plane de revue n’est pas une proposition de terrain final. Les timings de
fouille sur cette nouvelle anatomie n’ont pas de validation humaine.

À juger : style et qualité du crâne/côtes dans le bloc, intérêt réel du volume
par rapport au relief, propreté des révélations/bords et cohérence des outils,
puis valeur visuelle des mêmes pièces hors matrice. Garder le Brush sur os et les
dégâts localisés validés. Aucun GO catalogue, merge, musée/meta, Sound/Light ou
P6B/P7 automatique ; le prochain choix dépend du verdict humain sur ce candidat.


## Retour humain du 2026-10-14

Antoine trouve le candidat assez similaire au rendu généré en code et accueille
positivement cette proximité de style. Il relève une différence importante :
le nouveau modèle manque d’ombres. Ce constat correspond à la désactivation
explicite du shadow casting du mesh en fouille, documentée ci-dessus ; la solution
reste à travailler sans révéler de silhouette sous la matrice intacte.

Les deux captures de comparaison fournies sont conservées sous
`evidence/p6a34/home-comparison-1.png` et `home-comparison-2.png`.
Ce retour ne constitue pas une approbation de l’art final, de l’inspection à 360°
ou du catalogue complet. La question sur la suite esthétique appelle une
clarification du rôle du pilote : faisabilité intégrée et premier candidat visuel,
puis recommandation d’une passe de qualité sur les mêmes pièces avant extension.
