# Musée — notes de Technical Art

## Direction
La nouvelle référence transmise par Antoine inspire un cabinet d'histoire
naturelle chaleureux : pierre crème à vrais renfoncements, noyer mouluré,
vitrine garnie, livres et objets scientifiques, végétaux, tapis et laiton.
L'architecture et les petits objets de cette passe sont principalement originaux, paramétrés
et cuits hors ligne. Deux textures finales ont été générées avec imagegen
et inspectées avant intégration. Les deux bons présentoirs existants restent utilisés.
Les blocs du joueur et les données de préparation ne sont jamais reconstruits
par le décor.

## Budgets de production

| Catégorie | Budget après revue visuelle | Réalisation de la cuisson finale |
| --- | --- | --- |
| Décor complet hors présentoirs et préparations | 280 000 triangles / 45 lots de matière | 234 086 triangles / 39 lots opaques, plus 1 vitrage |
| Architecture | 35 000 triangles / 10 lots | 25 386 / 9 |
| Mobilier et textile | 35 000 triangles / 13 lots | 32 692 / 11 |
| Objets de collection et végétaux | 190 000 triangles / 16 lots | 168 656 / 15 |
| Jardin | 9 000 triangles / 4 lots | 7 352 / 4 |
| Textures runtime finales | Atlas gravé 1254 × 1254, tapis tissé 1774 × 887 | PNG originaux générés via imagegen, BC7, mipmaps activées |
| Transparence | 1 couche de vitrage maximum par pixel | 2 portes dans un seul batch, alpha 0,045 |
| Particules, physique, scripts par image | 0 | 0 |

Les maillages sont regroupés par matériau, sans fusion des données des pièces
exposées. Toutes les géométries passent par `ImporterMesh.generate_lods` ; les
petites surfaces planes restent à leur budget minimal, les lots courbes et
les cordons ont jusqu'à 8 LOD. Les tableaux de texture source restent à leur
résolution d'origine. Le jardin emploie de vraies feuilles opaques à deux faces,
aucune carte alpha superposée. Il ne projette pas d'ombre dans la fenêtre.

Aucune lumière n'est créée dans les modules de décor : tout le rig appartient
au module `gallery_lighting.gd` du Godot Shader Developer. Les matériaux communs
conservent les conventions de `gallery_surface.gdshader` (noyer, pierre, laiton,
papier/tissu), avec axe de grain horizontal pour les traverses et étagères.

## Construction et réutilisation
- Deux alcôves au centre x ±2,65 m, façade z −2,00 m, fond z −2,65 m ; arches
  avec intrados et retours solides. Les fronts de mur laissent de vraies ouvertures.
- Fenêtre arquée à x −4,75 m, ouverture également percée dans le fond de la salle.
- Vitrine originale : dos, étagères, montants, couronnement et portes séparés,
  livres debout/couchés, minéraux et petites coquilles décoratives indépendantes.
- Lierre, laurier et fougère originaux : feuilles courbes à normales lissées,
  bord roulé et nervure en relief sur les grandes feuilles ; formes distinctes
  entre les deux urnes. Les feuilles distantes du jardin sont simplifiées.
- Coquilles décoratives à spires logarithmiques jointives, côtes en volume
  et bouche creuse ; cristaux inclinés en grappes irrégulières.
- Une petite réplique du crâne réutilise la sculpture existante
  `assets/p6a32/b17_tripo_skull.glb`, réduite hors ligne ; elle ne charge aucun
  snapshot de joueur et ne modifie jamais le maillage source.
- Urnes cannelées, cadres botaniques, armillaire
  et loupe. Aucun de ces éléments ne possède d'identité de collection joueur.
- Banc à coussin et pieds tournés, tapis original à palmettes, entrelacs et
  petites rosettes avec usure et trame imprimées, dessiné pour l'ensemble des
  deux présentoirs, cordons tressés et bornes en laiton.
- Les GLB historiques restent intacts sur disque. La passe n'ajoute aucune dépendance runtime. Deux générations via
  l'outil imagegen intégré ont produit les textures finales ; aucun coût
  n'est exposé par cet outil, donc aucune gratuité n'est affirmée.

## Sources reproductibles
Les wrappers runtime restent dans `scripts/experiments/exhibition/` :
`gallery_room.gd`, `gallery_furniture.gd`, `gallery_environment_assets.gd`,
`gallery_garden.gd`. Ils chargent quatre scènes statiques sous
`assets/museum/polish/` ; le vitrage est un unique mesh ajouté au chargement.

Outillage hors ligne sous `scripts/experiments/exhibition/polish/`, textures
finales sous `assets/museum/polish/` :
- `museum_geometry.gd` : modélisation paramétrée et matériaux.
- `make_museum_art.py` : générateur de secours des prototypes SVG originaux,
  non utilisés par le rendu final. Il n'est pas nécessaire à la cuisson finale.
  Le prototype de tapis SVG de 7,8 Mo est retiré des assets livrés.
- `natural_history_engraved.png` : atlas décoratif de quatre gravures détaillées
  (1254 × 1254), créé avec le mode intégré du skill imagegen.
- `heritage_rug_woven.png` : laine et motif patiné (1774 × 887), même outil.
- Les fichiers `.provenance.json` adjacents conservent les prompts complets,
  la date, l'outil et la résolution native. Aucun redimensionnement ni
  retouche des sorties n'a été effectué. Les gravures sont décoratives,
  pas des références taxonomiques.
- `bake_museum.gd` : cuisson des scènes, génération LOD et contrôle du budget.

```powershell
& $Godot --headless --path . --editor --quit
& $Godot --headless --path . --script res://scripts/experiments/exhibition/polish/bake_museum.gd
```

## Atelier
La lampe visible a été retirée des deux variantes de décor selon la demande
explicite d'Antoine. Les lumières de travail restent indépendantes. Nouvelle
cuisson de chaque variante : 32 660 triangles et 13 lots, contre 42 322 et 14.

## Corrections de la revue moteur
La capture `work/museum-polish/iteration-1/01-gallery.png` a révélé un mur
qui passait devant le fond de la vitrine et une corniche qui masquait le
décor posé au-dessus. Le mur central est reculé, le fond de vitrine est en
noyer et la corniche est relevée. Le feuillage anguleux, les coquilles trop
fines et le tapis trop simple ont été remodelés après comparaison directe
avec la référence. Le budget triangles a été relevé avec l'orchestrateur
pour cette passe, puis ramené de 462 677 à 234 086 par réduction des nervures
invisibles et des feuilles du jardin. Le nombre de lots baisse à 39.
La dernière revue a fermé les raccords entre pans de façade, posé les lierres
dans de vrais pots, supprimé le bouquet flottant et ajouté des moulures sur
les trois faces visibles des socles. Le tapis et les gravures vectorielles ont
été remplacés par les deux textures finales plus organiques.
Les supports Tripo ont une rugosité de 0,54 et une modulation neutre douce
pour retrouver une finition de noyer satinée sous la lumière du musée.

## Vérification et limites
Import et cuisson Godot 4.7.2 headless réussis, sans erreur de script ou de
ressource. Les métriques ci-dessus décrivent la géométrie cuite, pas un coût GPU
mesuré. Captures moteur, revue des angles, contrôle des vrais blocs exposés et
mesures de performance sont effectués avec l'orchestrateur après assemblage.
Revue visuelle finale : `work/museum-polish/final-real/01-overview.png`
(capture moteur du 20 octobre 2026, 00:25), avec les deux textures finales
effectivement chargées. Les raccords de façade, plantes, moulures et gravures
ont été inspectés ; aucune nouvelle correction géométrique n'est identifiée.
Le jardin, le sol et la densité des étagères restent plus simples que la
référence. Les modèles restent gelés pour la revue d'Antoine.
La validation artistique reste humaine, aucune équivalence photoréaliste avec
l'image de référence n'est affirmée.
