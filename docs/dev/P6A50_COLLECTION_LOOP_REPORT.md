# P6A5.0 — Deux découvertes et première collection

**Date de livraison :** 2026-10-16

## Résultat livré

Le dépôt propose deux caisses, M–08 et B–17. M–08 contient une ammonite originale
modélisée, dans un bloc naturel plus compact. Les indices de provenance sont
fictifs ; le nom du fossile apparaît avec la découverte. La collection conserve
une photographie de la préparation réelle, ses métriques et la distinction
intégrale. Cliquer sur la photographie ouvre une vue détaillée. Après archivage,
le deuxième emplacement donne une destination concrète à la préparation suivante.

Le but du test humain est l'envie de recommencer après une découverte satisfaisante.
Le GO d'Antoine autorise ce prototype et sa revue interne ; il ne valide pas encore
le rendu de M–08 ou la boucle complète.

## Choix de game design

- M–08 privilégie un tour extérieur lisible, des côtes, des tours intérieurs et
  un ombilic étroit. Quatre régions anatomiques alimentent le système existant ;
  aucune classification de vertébré n'est réutilisée pour la coquille.
- Le bloc occupe une empreinte plus petite et sa couverture géologique est
  abaissée uniformément de 10,2 mm, indépendamment de l'anatomie. Les paramètres
  Chisel, Pick, Brush et souffleur restent ceux validés. L'intégralité du fossile
  est enfouie au départ.
- La poche friable validée est configurée pour cette couverture plus mince. Son
  volume est généré avant admission ; un candidat dangereux est rejeté entier,
  sans découper sa forme autour du fossile. Après un archivage, un nouvel essai
  passe au cas suivant parmi les cinq graines existantes. R rejoue le même cas.
  L'aide de découverte de poche n'est donnée qu'une fois dans le lancement.
- L'archivage conserve les seuils existants : préparation complète avec garde de
  couverture ; finition facultative à 95 %, distinction intégrale avec la règle
  d'affichage validée (99 % réels et garde de couverture → 100 affiché).
- Rejouer conserve la pièce au meilleur état ; à état égal, la finition départage.
  Une distinction obtenue reste acquise, même si la photo d'une pièce antérieure
  mieux préservée reste exposée. Les anciennes distinctions B–17 sont reconnues
  sans inventer une photographie ou une préparation archivée.
- La collection se consulte sans perdre la fouille en cours. Changer de caisse
  avant archivage demande un choix explicite. Un échec d'enregistrement conserve
  le travail, propose de réessayer et empêche le passage destructif à la suivante.

## Modèle et liaison réelle

Source modifiable : `art/source/p6a50/m08-ammonite.blend`.
Générateur : `tools/p6a50/build_ammonite.py`, Blender 5.2.2 LTS.
Runtime : `assets/p6a50/m08_ammonite.glb` et `mesh_patch_data.res`.
71 036 triangles, 21 389 cellules de fossile, zéro fallback natif. Le modèle est
une construction volumétrique originale avec côtes et ouverture en retrait,
AO géométrique à courte portée et matière ivoire chaude partagée avec B–17.
C'est une ammonite stylisée, pas une espèce reconstruite scientifiquement.

Le raster indépendant des triangles importés retrouve toutes les cellules, avec
un écart maximal de toit de 0,00000000519 m. Le mesh complet ne projette pas
l'ombre des parties cachées : seuls les toits déjà exposés contribuent au caster.
L'image du bloc intact est strictement identique avec et sans le modèle.
Les adaptations partagées sont limitées aux métadonnées, fabriques de champ,
empreinte, mesh et affichage ; les valeurs par défaut B–17 sont conservées.

## Revue et corrections avant livraison

La première revue native montrait un grand tour trop plat : la croissance de la
spire, sa section et les côtes ont été retravaillées. Les photos de collection
étaient initialement mal cadrées lors du changement de résolution ; la projection
est maintenant convertie vers les pixels réellement rendus et la prise de vue
est centrée sur la pièce. Le cadre de fenêtre choisi est conservé entre caisses.
Les étiquettes des caisses, la lecture de la galerie et la vue détaillée ont été
vérifiées sur captures natives. La vue détaillée montre la vraie matrice, les
salissures restantes et les dégâts, pas un modèle propre substitué après coup.

Dans le parcours M–08 automatisé avec contacts réels : premier fossile après
2 coups de Chisel au point de sonde, puis Pick, puis 14 traversées Brush de 0,8 s.
Résultat : dégagement 100 %, nettoyage 99,529 %, état 100. Le parcours conservateur
utilise 976 impacts Pick ; il sert d'oracle fonctionnel et ne mesure pas la durée
humaine, car il connaît les coordonnées et n’optimise pas le dégrossissage.
Le plaisir et le rythme réel restent à juger au premier essai d'Antoine.

## Vérification finale — 2026-10-16

622 contrôles ciblés, zéro échec : 26 géométrie/interactions M–08, 24 persistance,
32 parcours natif (12 clics UI, échec/réessai de sauvegarde et nouvel exemplaire),
1 redémarrage dans un nouveau processus, 197 référence P6A49 logique,
71 référence P6A49 native, 52 P1, 128 P5 et 91 P4V2. Import éditeur sans erreur.
Moteur 4.7.2 stable, RTX 5080, cap 240 FPS / physique 60 Hz conservés. Ces contrôles
ne constituent ni un benchmark global ni une validation humaine du plaisir.

## Persistance et périmètre

`user://collection/records.json` et photographies PNG locales. Commit du manifeste
avec sauvegarde précédente, récupération d'un manifeste endommagé si possible,
validation des données et chemins de photos bornés au dossier de collection.
Une sauvegarde irrécupérable est préservée et signalée. Tests et captures de QA
utilisent exclusivement des dossiers isolés sous `work/test-logs/p6a50/`.
L'ancien fichier `user://preparation_distinctions.json` garde ses distinctions.

La fouille en cours reste en mémoire lors des visites de la collection ; elle
n'est pas sauvegardée pour reprendre après fermeture du jeu. La collection, elle,
est durable. Deux spécimens seulement, cinq cas de poche contrôlés : pas encore
une génération globale des collections, une économie ou un musée explorable.
Le choix extraction/montage final reste ouvert ; la photographie documente ici
la pièce préparée dans sa matrice. Le Sound Design reste différé.

## Reproduction

Lancer `Launch-Game.ps1` ou `Launch-P6A50-Collection.ps1` avec Godot 4.7.2 stable.
Choisir M–08 pour le nouvel essai ; B–17 reste disponible. C ouvre la collection,
Home recadre, molette zoome, clic droit déplace ; 1 Brush, 2 Chisel, 3 souffleur,
4 Pick. Le bouton d'archive apparaît au seuil existant. R propose de recommencer.
Alt+Entrée bascule le plein écran ; les commandes de lookdev révélant
le modèle complet sont réservées à `--qa` dans cette scène de collection.

Reconstruction de l'asset : `tools/p6a50/Build-Ammonite.ps1`.
Tests Godot :

- `--headless --path . --script tests/run_p6a50_store.gd` ;
- `--headless --path . --script tests/run_p6a50_collection.gd -- tests --qa
  --collection-store=res://work/test-logs/p6a50/logic/records.json
  --distinction-store=res://work/test-logs/p6a50/logic/distinction.json` ;
- sans `--headless`, même script avec `-- visual --qa`, autres chemins isolés ;
- `tests/run_p6a50_reload.gd` dans un nouveau processus avec `--qa` et
  `--collection-store=` pointant sur le `collection_path` de `visual.json`.

Les captures de la fouille M–08 et de son archivage proviennent des outils réels.
Le second archivage B–17 utilise son parcours Pick de revue puis la fixture de
nettoyage pour vérifier la transition ; ce n'est pas une session humaine filmée.
Les preuves finales sont dans `docs/dev/evidence/p6a50/`.

## À juger pendant l'essai

1. La découverte et la finition de M–08 ont-elles leur propre rythme face à B–17 ?
2. Retrouver sa pièce, puis voir une autre caisse, donne-t-il envie de continuer ?
3. La collection, le retour au travail et la distinction sont-ils compréhensibles ?

## Références de forme

[Collections d'ammonites du Natural History Museum](https://www.nhm.ac.uk/discover/how-to-make-a-salt-dough-ammonite-fossil.html)
et [description d'une ammonite du Smithsonian](https://naturalhistory.si.edu/visit/accessibility/audio-and-visual-description/from-these-lands-visual-description-tour).
Le mesh et ses matériaux sont originaux ; aucun scan ou asset de ces collections
n'est redistribué.
