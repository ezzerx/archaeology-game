# P6A3.7 — Squelette B-17 modelé

Candidat livré localement le 2026-10-14 après le GO d’Antoine pour étendre le
modelage du crâne validé aux côtes et au reste du squelette, même style et
interactions conservés. Ce rapport décrit le B-17 partiel existant, sans ajouter
les parties anatomiques absentes ou produire un catalogue d’autres spécimens.

## Voir le candidat

`Launch-P6A37-Modeled-Skeleton.ps1`, Godot 4.7.2 stable. Démarrage recouvert.
L’option `-InspectSkeleton` ouvre l’ensemble hors matrice, sans altérer la fouille.

- **F5** : inspection du vrai GLB utilisé en jeu. Ensemble, crâne, côtes,
  vertèbres/queue, bassin/patte ; glisser pour tourner et molette pour rapprocher.
  F5 ou Échap revient à la préparation conservée.
- **Matière : ivoire / étude de forme** : évaluer les volumes sans texture.
- **Modèle / Référence P6A3.6** : comparer crâne et côtes avec angle/échelle
  conservés. Le précédent GLB ne contenait pas de vertèbres ou de patte : cette
  comparaison est désactivée pour ces régions plutôt que d’afficher un faux témoin.
- **F6** : nouveau mesh / relief du même nouveau champ, sans reset.
- **F7** : comparatif tactile historique, sans modifier la préparation.
- **H** : « Squelette dégagé, os sales · réinitialise » est une coupe de revue
  contrôlée qui met en scène les plafonds réels ; elle n’est pas du gameplay enregistré.
  Le bouton d’ombres compare les mêmes os réellement exposés.
- **H** : « Squelette préparé au Pick · réinitialise » emploie uniquement le Pick
  natif inchangé. La série finale exécute 4716 impacts,
  environ 5.7 s dans ce test, et expose 100 %
  des quatre régions, Condition 100. Brush pour nettoyer la vraie pellicule.
  Le bouton crâne seul reste disponible. Ces fixtures annoncent le reset.

## Travail artistique

Le crâne P6A3.6 accepté est chargé depuis son master et conservé exactement.
Les tableaux importés Godot de positions, normales, UV, occlusion et indices
sont byte-identiques ; ses cellules et plafonds sont aussi inchangés.

Les autres pièces sont des volumes Blender originaux, modelés par sections
anatomiques, volumes soustractifs, remeshing et sculpture légère assistée par script.
Le master conserve 50 cages de travail éditables, absentes du GLB runtime.
Aucune génération 3D distante, scan ou géométrie de musée utilisée.

- Douze côtes individuelles : section aplatie, courbure variable, tête et
  tubercule différenciés, col, sillon costal discret et pointe effilée.
- Vingt vertèbres : corps resserrés au centre, arc et facettes, crêtes et processus,
  orientation suivant la courbe de la chaîne et proportions affinées vers la queue.
- Bassin : lame iliaque, ouverture acétabulaire traversante, crête et branches
  ouvertes du pubis/ischium.
- Patte : fémur courbé, tête décalée, trochanter et condyles ; crête tibiale,
  fibula indépendante, phalanges arrondies séparées par des articulations et trois griffes.

L’ivoire chaud, la texture et le shader du crâne accepté restent communs à tout
le modèle. L’occlusion courte portée provient des surfaces ; aucune fissure
uniforme décorative ajoutée. Les vrais dégâts localisés restent l’autorité d’usure.
Interprétation stylisée originale, pas une restitution scientifique exacte d’espèce.
Repère institutionnel de silhouette générale :
[Smithsonian](https://naturalhistory.si.edu/explore/dinosaurs-fossils/nations-t-rex).
Les nombres et la disposition viennent du B-17 du projet, pas d’un inventaire muséal.

## Sources et intégration

- Master : `art/source/p6a37/b17-modeled-skeleton.blend`.
- Fabrication : `tools/p6a37/build_skeleton.py`, Blender 5.2.2 LTS.
- Reconstruction et contrôles : `tools/p6a37/Build-Modeled-Skeleton.ps1 -Graphical`.
- GLB : `assets/p6a37/b17_skeleton.glb`, **49 pièces, 83,431 triangles**,
  2,544,456 octets ; plafond 100 000.
- SHA-256 : `942bfde8c127b3ed4055884295817e48fefd233d360debd7d90614cc6df2f346`.
- `production-manifest.json` et `mesh_patch_data.res` dans le même dossier.

Les volumes de travail sont fermés, avec contrôle manifold à la fabrication.
L’exporteur élimine trois triangles dégénérés : le manifeste distingue les
83 434 triangles source des 83 431 triangles réellement exportés/importés.
Leur absence ne laisse aucune cellule manquante à la projection contrôlée.
Import sans compression des positions ni LOD automatique.

Le champ entier provient des triangles finalisés : **25 404 cellules**,
crâne 6 252, vertèbres 5 160, côtes 8 986, bassin/patte 5 006. Les recouvrements
entre nouvelles pièces se résolvent par leur vraie surface supérieure.
Aucun Bone historique de secours : terrain natif masqué seulement sur les
cellules réellement exposées, rendu source groupé en une surface.
Les quatre IDs canoniques sont conservés, donc protections du premier contact,
Condition, nettoyage, objectifs et archive gardent les mêmes règles.

Le picker du crâne accepté est partagé sans changement de logique ; seules ses
factories source/champ sont surchargées. Matrice couverte : contact natif.
Bone exposé : affinement sur les vrais triangles avec garde de distance de 5 mm.
Aucun collider, changement de preset, rayon, gain Brush ou cadence.

Le mesh complet ne projette pas d’ombres. Le caster contient seulement les
plafonds de cellules réellement exposées. Le patron d’indices est désormais
précalculé et les suites de cellules exposées sont copiées en bloc ; cela évite
six écritures GDScript par cellule à chaque reconstruction. Les indices soumis
sont contrôlés explicitement, y compris lors d’une révélation partielle des
quatre régions. Reset synchrone et aucune reconstruction au repos.
Les pilotes précédents conservent leurs sources par défaut.

## Vérifications et captures

**461 contrôles, zéro échec** : P5 128, P6A3.3 40, P6A3.4 26,
P6A3.5 38, P6A3.6 50 + 43 graphiques, P6A3.7 85 + 51 graphiques.
Preuves : `docs/dev/evidence/p6a37/`, JSON et 38 captures natives Godot.
Les registres QA sont isolés dans work/, sans écrire dans la collection personnelle.

- 25 404 cellules couvertes par les tableaux de rendu importés, aucun manque ;
  erreur maximale de plafond **0.0066 µm**, tolérance 1 µm inchangée.
- 370 contacts caméra vérifiés, écart maximal observé nul sur cet échantillon ;
  contacts couverts/exposés testés séparément sur chaque région.
- Toute la matrice intacte pixel-identique mesh/relief et ombres on/off.
  Ombres partielles : aucun indice enterré soumis ; reset immédiat.
  Comparaison propre des ombres : 69,531 pixels assombris au-delà
  de 0,025 en luminance, zéro éclairci au-delà.
- Sur chaque composante : premier Chisel protégé, impact suivant localisé,
  courts allers-retours Brush nettoyant la vraie pellicule. La préparation
  complète garde Condition 100 ; 100/100, distinction et archive passent.
- F5/F6/F7 et les sélections anatomiques ne modifient pas la préparation.

Captures de référence : `modeled-source-0-three-quarter.png` (GLB propre),
`modeled-source-2-three-quarter.png` (côtes), `modeled-source-4-three-quarter.png`
(patte), `prepared-overview.png` (coupe mise en scène), `native-skeleton-dirty.png`,
`native-skeleton-clean.png` et `native-detail-*.png` (vrais impacts Pick, puis Film nettoyé).
Ces images sont des rendus du jeu, pas des concepts.

## Coût et limites

Compatibility / RTX 5080, vue entière contrôlée : 83 → 86 draw calls ;
2 671 966 → 2 806 205 primitives, soit **+134 239** : 83 431 visibles et
50 808 triangles de caster. Textures résidentes 177 957 368 octets dans les deux
états. Reconstruction maximale du caster observée **6.449 ms**
après optimisation, contre 8,667 ms dans une première série. Ces observations
ne garantissent pas un coût maximal en session réelle.

Cap 240 FPS / physique 60 Hz conservés. Le dernier échantillon mural d’environ
une seconde donne **185.0 FPS** ; trois autres fenêtres de playtest
P6A3.4/3.5/3.6 étaient toujours actives et ont été préservées. Le test n’est donc
pas isolé et ne valide pas 240 FPS soutenus. Les intervalles de signaux graphiques
sont irréguliers ; ne pas transformer leurs médianes en promesse de fluidité.

La grille de révélation reste visible à fort zoom, notamment sur les petites
pointes. Les formes et les surfaces diffèrent de la fixture historique : même
règle d’outil ne signifie pas durée de fouille identique. Les préparations
automatiques ne valident pas la durée ni le ressenti d’une session humaine.
La reconstruction Blender ne garantit pas une empreinte binaire identique à
chaque export ; le GLB/master/champ versionnés sont la référence de cette livraison.

À juger humainement : cohérence des nouvelles pièces avec le crâne accepté,
lecture des articulations et pointes, intérêt de la précision sur côtes/patte,
et confort pendant la vraie fouille. Le statut canonique conserve la gate.


## Retour humain — 2026-10-14

Antoine : « Ok je valide ça me plait, on pourrait faire les futurs squelettes /
reliques de la collection comme ça ! ».

Le squelette B-17 modelé et cette méthode artistique sont acceptés comme référence
pour les futurs assets à excaver. Conserver les vrais volumes et détails utiles à
la précision, le style chaleureux et les interactions validées. Pour les reliques,
adapter la matière à l’objet, sans imposer la matière osseuse à toute la collection.

Ce verdict artistique ne mesure pas une durée de session ou les performances
isolées. La demande suivante porte sur une recommandation de prochaine étape,
pas sur un démarrage automatique du Sound Design, du musée ou du catalogue.
