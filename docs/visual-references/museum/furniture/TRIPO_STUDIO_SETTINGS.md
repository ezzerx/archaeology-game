# Tripo Studio — fiches de génération

## Consigne durable

Antoine demande le 17 octobre 2026 de mémoriser les réglages et de fournir une
fiche explicite **avant chaque génération**, adaptée à l'objet concerné.
Indiquer l'image d'entrée, le modèle, toutes les options de géométrie et de
texture, le budget de polygones, le format de sortie et les changements par
rapport à la génération précédente. Ne pas supposer que Studio a conservé les
bons paramètres. Distinguer recommandation, paramètres réellement utilisés et
résultat validé dans Godot.

## Pilote 01 — Présentoir B–17

Statut : **réglages recommandés ; export reçu, rendu encore à évaluer**.
Antoine a fourni `museum_b17_stand_pilot.glb`. Le fichier contient 84 656 triangles,
un matériau et trois images embarquées. Les réglages exacts utilisés dans Studio
ne sont pas tous déductibles du GLB ; ils restent non confirmés.
Source et provenance : [archive du dépôt](../../../../assets/museum/source/README.md).
Les libellés ci-dessous proviennent de sa capture du 17 octobre 2026.

Entrée : [01-presentoir-b17.png](01-presentoir-b17.png), une seule image.
Il s'agit du meuble vide ; le vrai bloc et les cartels seront ajoutés dans Godot.

| Réglage | Valeur recommandée |
|---|---|
| Mode | Modèle HD |
| AI Modèle | H3.1 – Qualité Optimale |
| Qualité de maillage Ultra | Activée |
| Complétion IA et amélioration 3D | Désactivée |
| Texture | Activée |
| Qualité de la texture | 4K |
| Supprimer l'éclairage | Activé |
| PBR | Activé |
| Topologie | Triangle |
| Nombre de polygones | 100 000 |
| Générer par parties | Désactivé |
| Texture 8K | Désactivée |
| Générer des multi-vues | Ne pas lancer pour ce pilote |

Par rapport à la capture : conserver **Ultra activé** et remplacer **2 000 000**
par **100 000** dans le champ numérique. Les autres valeurs visibles correspondent
à la recommandation. Cette recommandation remplace celle de 10 000 polygones et
Ultra désactivé, qui anticipait trop tôt l'optimisation pour le jeu.
Une seule génération suffit pour la première inspection.
Le coût à retenir est celui affiché dans Studio, sans extrapolation du tarif API.

### Raisons et contrôle du résultat

- Priorité de ce pilote : juger une source détaillée, puis optimiser sur une copie
  après comparaison dans Godot. Le budget de génération ne vaut pas budget final
  pour chaque meuble présent dans la scène.
- Recommandation : 100 000 triangles avec Ultra activé pour laisser de la marge
  aux arrondis, moulures et petites pièces. C'est une proposition de travail,
  pas un seuil de qualité mesuré ; le nombre réellement obtenu reste à vérifier.
- Tripo distingue la qualité géométrique Ultra de la limite de polygones :
  [fiche H3.1](https://developers.tripo3d.ai/en/models/v3-1). Augmenter la densité
  ne garantit ni une meilleure silhouette ni une meilleure texture. Le grain
  du bois et la patine dépendent aussi des matériaux ; inspecter le résultat.
- Conserver le GLB source avant toute réduction. Choisir ensuite un budget pour
  le jeu par comparaison à l'échelle d'écran réelle, sans dégradation visible.
- Conserver une source 4K pour inspecter bois et laiton de près ; la résolution
  réellement utilisée dans le jeu sera décidée après comparaison dans Godot.
- Activer PBR et la suppression de l'éclairage pour obtenir des matériaux qui
  réagissent à la lumière du moteur. Vérifier malgré tout que la texture ne
  contient pas d'ombres gênantes. Voir [la documentation Tripo sur les textures](https://www.tripo3d.ai/features/ai-texturing).
- Pas de parties ni de multivues générées à cette étape : un seul meuble statique
  suffit pour juger la silhouette, les matières et l'intégration au bloc.

Exporter en **GLB avec textures**, nom conseillé : `museum_b17_stand_pilot.glb`.
Conserver l'original. Examiner face, côtés et dos, puis comparer dans Godot à
l'échelle du vrai B–17 avant de produire la suite.

### Suite

Les fiches ammonite, vitrine et applique seront précisées avant leurs générations,
en tenant compte du résultat du pilote. Ne pas appliquer automatiquement le
budget du présentoir à tous les futurs assets.

Le [plan API du guide](README.md#option-api--simulation-antérieure-non-exécutée)
est une simulation antérieure à cette révision : ne pas l'exécuter tel quel pour
ce pilote détaillé. Ses paramètres `smart_low_poly` et `face_limit` ne sont pas
la preuve que Studio utilise exactement le même traitement.

## Retour du pilote dans Godot
Le fichier fourni a été importé avec ses 84 656 triangles et ses textures PBR.
Les détails du meuble paraissent suffisants pour cet essai après adaptation du
plateau et correction de teinte ; aucune validation humaine du rendu n'en découle.
Une inscription inventée au dos reste à retoucher. Voir le
[rapport du pilote](../../../dev/ISSUE51_B17_TRIPO_PILOT.md).
