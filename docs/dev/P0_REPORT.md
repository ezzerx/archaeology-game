# Rapport P0 — Interaction brute

Date : **2026-10-01**. Branche : `prototype/p0-foundation`. Base canonique : `main` au commit `74b5e88dea181d7b8683a7cbb8a290928e88edf5`.

**P0 implémenté ; validation humaine attendue. P1 n'est pas commencé.** Ce jalon vérifie une interaction et une représentation de données. Il ne valide ni le creusement, ni les matériaux, ni le game feel de V0.1.

## Préflight et moteur retenu

- Les neuf documents demandés ont été lus dans l'ordre, puis `docs/brain/BRAIN.md`.
- **Godot 4.7.2 stable Standard**, version exécutée : `4.7.2.stable.official.ed1daf0bf`.
- Vérification officielle au 2026-10-01 : [archive Godot](https://godotengine.org/download/archive/) et [4.7.2 stable](https://godotengine.org/download/archive/4.7.2-stable/), publiée le 18 août 2026. L'archive distingue cette stable de la branche 4.8 en développement.
- GDScript, primitives natives, renderer **Compatibility / OpenGL 3**, sans addon ni dépendance du projet. Suffisant pour cette scène simple ; le renderer ne préjuge pas du rendu de P1/P6.
- Les anciennes pistes 2D de `TECH_NOTES.md` ne s'appliquent pas : la spec canonique impose ici la scène 3D tabletop orthographique.
- Planche visuelle copiée sans transformation dans `docs/visual-references/archaeologygame-v0.1-visual-reference-board.jpg` ; SHA-256 vérifié : `58d223c25022c1badc59cd822a7df144672646be6dcd645b8a80788c34881fa1`.
- `docs/.gdignore` exclut la documentation des imports Godot. La planche n'est jamais utilisée comme texture de jeu.

## Architecture livrée

| Élément | Responsabilité |
|---|---|
| `project.godot` | Scène de démarrage, viewport 1920×1080, fenêtre initiale 1280×720, proportions conservées, physique 60 Hz |
| `scenes/prototype_main.tscn` | Primitives de table/bloc, lumière neutre, Camera3D, contrôleur, panneau debug |
| `scripts/prototype_main.gd` | Caméra, R/F1 et texte debug actualisé à 10 Hz |
| `scripts/excavation_block.gd` | Géométrie, collider, raycast indépendant de l'outil, texture et curseur shader |
| `scripts/surface_mapping.gd` | Conversions locales → UV → coordonnées continues / cellule |
| `scripts/working_surface.gd` | Image CPU, footprint balayé, falloff, saturation et reset |
| `scripts/tool_controller.gd` | Entrées, état du trait, application à 60 Hz, interruptions de focus/bounds |
| `scripts/debug_excavator.gd` + `config/debug_excavator.tres` | Resource de paramètres temporaires : rayon, force, falloff |
| `shaders/surface_debug.gdshader` | Niveaux de gris et cercle indiquant le rayon réellement appliqué |
| `tests/run_tests.gd` | Vérifications sans addon, incluant la scène et ses vraies collisions |
| `tests/check_p0.sh` | Import, tests et lancement avec timeout et contrôle des erreurs moteur |

La hiérarchie contient `PrototypeMain`, `TableEnvironment`, `ExcavationBlock/SurfaceMesh`, `ToolController` et `Debug`. Aucun FXController, DiscoverySystem ou modèle de matériau vide n'est créé.

## Caméra et composition

Caméra orthographique fixe, **84° par rapport au sol**, taille orthographique 0,85. Angle exposé entre 82° et 86° dans l'inspecteur. Bloc 1,1 × 0,7, épaisseur placeholder 0,12. À 16:9, sa face supérieure occupe environ 60 % de l'image. Aucun déplacement ni rotation joueur.

Le viewport conserve le ratio 16:9 avec bandes si nécessaire. La résolution de rendu de référence reste 1920×1080. Les entrées Godot fournissent déjà les coordonnées du viewport après mise à l'échelle ; aucune division manuelle par la taille de fenêtre n'est ajoutée.

## Mapping souris

1. Mémoriser la position viewport des événements souris ; resynchroniser lors d'un redimensionnement ou retour de focus.
2. Dans le tick physique, appeler `Camera3D.project_ray_origin` et `project_ray_normal`. L'origine dépend de la souris même en orthographique.
3. Intersecter le collider du bloc via `PhysicsDirectSpaceState3D.intersect_ray`, masque 1. La table n'a pas de collider interactif.
4. Convertir le point monde avec `ExcavationBlock.to_local` et rejeter les faces latérales selon leur normale.
5. `u = local.x / largeur + 0.5`, `v = local.z / longueur + 0.5`. Tester les bounds avant toute écriture.
6. Coordonnées continues de map : `uv * résolution - 0.5` (entiers = centres des texels). Cellule : `floor(uv * résolution)`, bornée au dernier texel pour UV=1.

Les UV sont comparés aux UV réels du PlaneMesh dans les tests pour détecter une inversion du rendu. Les translations, rotation et échelle du bloc sont aussi testées. Les faces latérales ne sont jamais rabattues sur un texel du bord.

Le panneau affiche écran, monde, local, UV, map, cellule, in/out-of-bounds, valeur sous curseur, FPS, paramètres et coût CPU de l'édition. Le curseur shader utilise exactement les mêmes UV/résolution/rayon que la map.

## Working map et stroke

**Image CPU `FORMAT_RF`, 1024×640**, un float32 par texel, soit 2,5 Mio. État initial uniforme **1**, valeur minimale **0**. C'est un mask de debug sans signification de profondeur ou de résistance.

LMB maintenu applique un **balayage continu de disque entre deux positions** (capsule). La distance de chaque texel au segment détermine le footprint. Cette interpolation géométrique couvre le segment complet sans trous entre des tampons espacés et sans double application des zones où les tampons se recouvriraient.

Pour `t = distance / rayon`, le poids est `(1 - smoothstep(0, 1, t)) ^ falloff`. La valeur diminue de `strength * delta * poids`, avec saturation à zéro. Un curseur immobile continue donc à modifier la map. La force est exprimée en unités par seconde sur la surface balayée ; ce n'est pas un modèle physique de temps de contact par grain.

Les paramètres sont bornés : rayon 1–128 texels, force 0,05–5/s, falloff 0,25–8. Le rayon est exprimé dans la map, et le cercle rendu suit cette convention ; les proportions physiques et texels diffèrent légèrement (1,1/0,7 contre 1024/640).

Sortie du bloc, relâchement, sortie de fenêtre, perte de focus et changement de paramètres cassent la continuité du trait. Réentrer sur la surface avec LMB encore maintenu commence un nouveau footprint sans relier les deux points à travers le bloc. Après perte de focus/sortie de fenêtre, un nouveau clic est nécessaire. **R restaure exactement les octets initiaux**, et exige un nouveau clic si LMB était maintenu.

Le déterminisme vérifié porte sur les mêmes positions ordonnées, paramètres et deltas sur ce moteur. Ce n'est pas une garantie d'identité binaire entre architectures CPU, ni entre des chemins échantillonnés différemment.

## Performance et limites de la mesure

- Écriture limitée à la boîte englobante du footprint, intersectée ligne par ligne avec la bande du segment. Aucun parcours complet de map au repos ; seul le reset remplit toute l'image.
- `ImageTexture` créée une fois puis `update` uniquement si la map a changé. Cette API transfère **l'image entière**, pas seulement la région modifiée ; au maximum environ 150 Mio/s à 60 mises à jour/s, hors coûts du pilote.
- Le curseur est un calcul de shader, sans reconstruction de mesh. Aucun changement de géométrie ni de collision à chaque coup.
- Mesure CPU headless, build officiel debug, map/rayon par défaut, 60 petits segments de 3 texels : **environ 2,4–2,9 ms par tick**.
- Cas de stress, traversée d'une diagonale presque entière en un seul tick : **environ 40–46 ms** après réduction du parcours (environ 110 ms avant). Ce déplacement extrême peut causer un à-coup. Le rayon 128 augmente aussi le coût ; il sert au tuning, ce n'est pas une enveloppe de performance validée.
- Ces chiffres n'incluent **ni l'upload GPU, ni le rendu, ni la latence réelle souris-écran**. Ils ne constituent pas une certification 1080p/60 FPS. Le défaut semble compatible côté CPU, à confirmer sur le PC de test.

## Tests exécutés

Depuis la racine du dépôt, sous Linux, avec l'exécutable officiel 4.7.2 :

```sh
godot --version
godot --headless --path . --editor --import
godot --headless --path . --script res://tests/run_tests.gd
godot --headless --path . --quit-after 120
bash tests/check_p0.sh /chemin/absolu/vers/godot
git diff --check
sha256sum docs/visual-references/archaeologygame-v0.1-visual-reference-board.jpg
```

Résultat de la suite : **45 checks, 0 failures**, exit 0. Import et scène principale : exit 0, aucune erreur de script relevée. Le script shell vérifie aussi les logs, car certains échecs d'import Godot peuvent retourner 0.

Couverture : conversions/bounds/NaN, centres et bords de texels, falloff/rayon/symétrie/saturation, paramètres bornés, déterminisme, reset exact, bords sans wrap, balayages rapides horizontal/diagonal, comparaison de la capsule avec la géométrie native dans les deux sens et à l'arrêt, force stationnaire basée sur le temps, UV du vrai PlaneMesh, 25 raycasts sur la face supérieure, rejet des côtés/hors viewport, transformation du bloc, LMB via événements du viewport, R avec clic maintenu, interruption/reprise hors bloc, relâchement, F1 et perte de focus.

Les événements automatisés ne remplacent pas une souris physique. Les logs locaux des trois commandes sont dans `work/test-logs/` (ignorés par Git).

## Limitation de validation graphique

Le binaire Godot fonctionne en headless dans Work. Une tentative d'affichage virtuel Xvfb a échoué lors de la création des sockets du serveur (`Cannot establish any listening sockets`). **Aucun rendu graphique ni screenshot n'est présenté comme validé.** La compilation GPU du shader, son affichage, le cadrage visuel, le comportement de la souris physique après redimensionnement et le 1080p/60 restent à confirmer localement. Le headless a validé les fichiers GDScript, la scène, la caméra mathématique, les collisions et les interactions par événements du viewport.

## À vérifier localement avant d'accepter P0

1. Importer le projet avec Godot 4.7.2 Standard et lancer **F5**. Vérifier table/bloc, proportions et panneau lisible.
2. Passer sur le centre, les quatre coins et les bords ; comparer curseur, valeurs et région qui s'assombrit.
3. Maintenir LMB sans bouger, puis tracer lentement et rapidement, en ligne droite et en diagonale. Vérifier continuité et réactivité.
4. Sortir du bloc puis rentrer en maintenant LMB : aucun pont entre les deux traits. Les côtés/table ne doivent pas peindre.
5. Tester molette, Maj+molette, Ctrl+molette ; comparer rayon visible, force et profil du bord.
6. Appuyer sur R pendant un trait, conserver LMB enfoncé : la surface reste initiale jusqu'au prochain clic. Refaire un trait après reset.
7. Tester F1, redimensionnement 1280×720 / 1920×1080 / fenêtre non 16:9, puis Alt+Tab et relâchement hors fenêtre.
8. Observer les FPS, l'absence de saccades au réglage par défaut et la concordance entre souris et modification. Signaler toute inversion, dérive, latence ou erreur de console.

## Dette technique et risques avant P1

- La surface et sa collision restent planes. P1 devra décider comment le raycast suit les futurs creux : aucune collision de heightfield n'est prétendue livrée.
- Le mask RF n'encode ni matériau, ni profondeur, ni os, ni poussière. Sa sémantique devra être définie avant d'ajouter ces données.
- Le balayage entre ticks est une droite. Un mouvement courbe plus rapide que l'échantillonnage peut être raccourci ; la quantité appliquée sur une trajectoire mobile n'est pas indépendante de tout rééchantillonnage.
- Transfert intégral de texture et coût GDScript des grands footprints à mesurer avant l'empilement de maps. Aucun plugin ni système GPU complexe ajouté pour anticiper cette question.
- La référence visuelle est conservée pour la suite ; ce greybox ne valide aucune DA.

**Aucune feature P1+ livrée** : ni matière, outil final, fossile, FX/audio, objectifs, musée, économie, sauvegarde ou progression. Aucune décision produit de la spec n'a été élargie.

Suggestion future uniquement : après validation humaine de P0, mesurer le relief et son mapping sur un seul bloc avant toute extension des systèmes. **Ne pas commencer P1 sans cette validation.**
