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

Statut : **réglages recommandés ; modèle non encore reçu ni évalué**.
Antoine prévoit de lancer lui-même cette génération dans Studio.
Les libellés ci-dessous proviennent de sa capture du 17 octobre 2026.

Entrée : [01-presentoir-b17.png](01-presentoir-b17.png), une seule image.
Il s'agit du meuble vide ; le vrai bloc et les cartels seront ajoutés dans Godot.

| Réglage | Valeur recommandée |
|---|---|
| Mode | Modèle HD |
| AI Modèle | H3.1 – Qualité Optimale |
| Qualité de maillage Ultra | Désactivée |
| Complétion IA et amélioration 3D | Désactivée |
| Texture | Activée |
| Qualité de la texture | 4K |
| Supprimer l'éclairage | Activé |
| PBR | Activé |
| Topologie | Triangle |
| Nombre de polygones | 10 000 |
| Générer par parties | Désactivé |
| Texture 8K | Désactivée |
| Générer des multi-vues | Ne pas lancer pour ce pilote |

Par rapport à la capture : désactiver **Ultra** et remplacer **2 000 000**
par **10 000** dans le champ numérique. Les autres valeurs visibles correspondent
à la recommandation. Une seule génération suffit pour la première inspection.
Le coût à retenir est celui affiché dans Studio, sans extrapolation du tarif API.

### Raisons et contrôle du résultat

- 10 000 triangles constituent un budget de départ pour ce meuble statique aux
  formes simples. Vérifier le cadre, les angles arrondis et les petites pièces
  en laiton ; ce budget ne garantit pas la qualité du maillage obtenu.
- Le mode Ultra ne paraît pas nécessaire pour ce premier présentoir. Réserver
  les décisions de densité supplémentaire à un défaut visible sur le modèle.
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

Le [plan API du guide](README.md#option-api--plan-du-pilote-préparé-non-exécuté)
est une autre voie : ses paramètres `smart_low_poly` et `face_limit` ne sont pas
la preuve que Studio utilise exactement le même traitement.
