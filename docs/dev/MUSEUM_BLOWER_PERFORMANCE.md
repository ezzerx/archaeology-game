# Souffleur — optimisation CPU de la passe musée

## Résultat

Le scanner de matière dans scripts/experiments/preparation_demos/demo_surface.gd
est spécialisé en deux boucles : grains et abrasion. La finalisation, les
notifications et le contenu des événements restent communs.

Sur deux répétitions courtes de 100 gestes actifs, à résolution 1024 × 640,
le traitement moyen descend de 4,73 ms à 3,64 ms face à la référence 99fa7fe,
soit environ 23 %. La borne conservative par ligne seule donne 4,08 ms :
la spécialisation apporte donc environ 11 % supplémentaires.

Ce sont des temps CPU de _work_material sur fixture contrôlée, hors rendu,
contrôleur et consommateurs visuels des signaux. Ce pourcentage n’est pas une
promesse de gain de FPS; la mesure native reste du ressort de la revue globale.

## Changements retenus

- Borne conservative du disque balayé par ligne, déjà préparée dans cette passe.
  La distance exacte au segment décide toujours du texel et du poids.
- Boucle de grains indépendante de celle de l’abrasion, évitant les branches
  de pointe abrasive à chaque texel soufflé.
- Rejet des grains fermés ou épuisés avant les lectures de plafond et de cap.
- Geste immobile : dx² + dy² donne exactement la distance du segment nul,
  sans calcul inutile de projection.

Aucun rayon, débit, seuil, cadence, résolution ou ordre de parcours ne change.
Le snapshot avant le geste reste explicite, notamment pour empêcher la cascade
dans les lèvres. Aucun cache d’éligibilité inter-geste n’est ajouté : Pick,
Chisel, reset et les couches profondes restent immédiatement pris en compte.
Les sons, les particules et les règles de préparation ne sont pas retouchés.

## Mesures courtes sans cuisson concurrente

Fenêtre CPU coordonnée avec Technical Artist avant sa cuisson.
Godot 4.7.2 stable, headless. L’ordre des trois variantes tourne à chaque geste
pour réduire le biais de chauffe/cache. Les comparaisons d’état se font hors du
chronomètre. Chaque répétition effectue 45 gestes stationnaires puis 55 gestes
courts mobiles sur la même fixture ouverte; les 100 gestes modifient la matière.

| Variante | Répétition 1 moyenne | Répétition 2 moyenne | P95 rép. 1 / rép. 2 |
|---|---:|---:|---:|
| Original 99fa7fe | 4,772 ms | 4,684 ms | 5,793 / 5,649 ms |
| Borne par ligne seule | 4,102 ms | 4,064 ms | 5,155 / 5,033 ms |
| Boucles spécialisées | 3,646 ms | 3,639 ms | 4,466 / 4,518 ms |

Sources locales : work/museum-polish/blower/candidate2-quick.json et
candidate2-quick-repeat.json. Les timings des tests longs, exécutés pendant
d’autres travaux de l’équipe, ne servent pas à cette conclusion.

## Équivalence et régressions

tests/run_museum_blower_exact.gd reconstruit l’oracle depuis le commit immuable
99fa7fe et le témoin intermédiaire dans work/, sans remplacer le script de jeu.
Les trois variantes sont instanciées séparément dans le même processus.

Le parcours complet comprend 12 cas : deux familles × couvert, ouvert,
couche profonde, lèvres, mélange et concrétions. Chaque cas reçoit 70 gestes
stationnaires, fractionnaires, horizontaux/verticaux, diagonaux longs, inversés,
aux bords et hors carte. Il compare après chaque geste :

- octets float32 des hauteurs, image RF et caps;
- exposition, composantes, premier contact, état et film;
- volumes cumulés, nombre de cellules et événement complet;
- ordre exact des signaux et des sources de grains.

Résultat : 1 680 comparaisons, zéro différence.
Les deux mesures courtes ajoutent chacune 200 comparaisons exactes.
Le script autonome reconstruisant l’oracle a aussi été vérifié : 200/200.

La suite existante tests/run_issue41_marine_materials.gd passe ses 21 contrôles
avec la géologie réelle : lèvre sans cascade, couches enterrées, arrêt sur l’os,
film, impossibilité de souffler une matrice scellée et reset.

## Reproduction

Depuis la racine du dépôt, avec Git et Godot disponibles :

~~~powershell
godot --headless --path . --script res://tests/run_museum_blower_exact.gd -- --label=exact
godot --headless --path . --script res://tests/run_museum_blower_exact.gd -- --quick --label=timing
godot --headless --path . --script res://tests/run_issue41_marine_materials.gd -- --qa --distinction-store=res://work/museum-polish/blower/distinctions.json
~~~

La comparaison complète utilise une géologie synthétique de test et le champ
osseux B17 existant; elle ne remplace pas une capture ni un parcours humain.
La suite marine complète cette preuve avec la préparation réelle. Pour les
mesures CPU, laisser finir les imports, cuissons et autres jeux/tests.

## Complément natif et rejeu intégral

RTX 5080, Compatibility, 1440 × 810, même parcours : souffle marin
141,8 → 178,7 FPS moyens ; P95 image 17,516 → 16,364 ms. Les pointes restent
présentes. Terre compacte 236,0 → 236,5 FPS, concrétions 210,4 → 219,5 FPS.
Les 20 contrôles de suivi natif passent. Preuves dans
`docs/dev/evidence/museum-sensory/blower-native-{before,after}.json`.

Le [rejeu intégral différentiel](MUSEUM_REPLAY_DIAGNOSTIC.md) ajoute
77 contrôles exacts sur les trois vraies préparations. Il explique les quatre
écarts du test historique par la caméra dépendante du temps réel, sans
modifier les références anciennes ni introduire de tolérance.
