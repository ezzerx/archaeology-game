# Organisation de la version jouable

## Entrée et composants

Lancer `Launch-Game.ps1` (Godot 4.7.2). `project.godot` ouvre
`scenes/collection.tscn`, qui instancie `scenes/specimen_preparation.tscn` pour
M–08 ou B–17. Le lanceur P6A50 reste compatible avec les raccourcis existants.

| Dossier | Responsabilité |
| --- | --- |
| `scripts/collection/arrivals/` | Caisses physiques dans un monde 3D séparé, sélection et actions d’arrivage |
| `scripts/collection/` | Catalogue, arrivages, photos, sauvegarde, variantes M–08/B–17 |
| `scripts/excavation/pockets/` | Poche friable validée, recette et rendu ; bases sous `base/` et `buried_base/` |
| `scripts/excavation/block/` | Empreinte naturelle, débris, bords bruts |
| `scripts/preparation/` | Interaction, lisibilité, Brush, dégâts localisés, distinction |
| `scripts/specimens/` | Champ et rendu du squelette, bases du rendu modélisé |
| `scripts/workshop/` | Atelier, éclairage, affichage et matériaux |
| `scripts/tools/feedback/` | Poses et feedback des outils |
| `scripts/*.gd`, `config/` | Simulation commune, règles et réglages conservés |
| `scenes/preparation/base/` | Composition héritée partagée avec les régressions |

Le graphe conserve les mêmes classes, héritages, noms de nœuds et propriétés.
Par exemple, le bloc d'un spécimen hérite du bloc à poches, puis du bloc brut,
puis du bloc naturel. Les bases de rendu anciennes restent nécessaires aux
fabriques et comparaisons. Leur présence n'est pas une nouvelle fonctionnalité.
Cette organisation nomme les responsabilités sans réécrire le gameplay.

## Assets et sources

- B–17 : `assets/p6a37/`, `art/source/p6a37/`, `tools/p6a37/Build-Modeled-Skeleton.ps1`.
- M–08 : `assets/p6a50/`, `art/source/p6a50/`, `tools/p6a50/Build-Ammonite.ps1`.
- Caisses d’arrivages : `assets/arrivals/`, `art/source/arrivals/`, `tools/arrivals/build_crates.py` ; matières finales dans le décor Godot.
- Les sources, notices et assets intermédiaires sont conservés avec leur provenance.
- `scripts/p6a34/mesh_patch_data.gd` est volontairement stable : son chemin est
  sérialisé dans les champs binaires `.res`. Ne pas le déplacer sans migration
  des ressources et validation depuis un import vierge.
- Ne pas renommer `application/config/name` pour nettoyer son suffixe historique :
  il détermine le dossier des sauvegardes existantes.

## Régressions et expériences retirées

Les tests conservés gardent leurs noms de phase pour retrouver les preuves
historiques. Certaines scènes de laboratoire restent exclusivement nécessaires
aux régressions. Les rapports et captures d'origine ne sont pas réécrits.

Les essais P6A42 (trois blocs) et P6A43–46 (plaques de grès) n'ont aucune dépendance
entrante depuis la version retenue. Leurs scènes, scripts, shaders spécifiques et
tests dédiés sont retirés ensemble. Les anciens lanceurs de comparaison sont
retirés de la racine. Les rapports et preuves restent disponibles dans `docs/dev/`.

Référence complète avant retrait : tag Git distant `archive/pre-issue26-runtime`,
commit `99cf5d1c38c2e893efb0df2d20edf744f6b3a14f`. Examiner cette référence dans un
checkout séparé pour rejouer une ancienne expérience, sans restaurer ses fichiers
sur une branche de mission. La liste exacte des déplacements et retraits est
`tools/maintenance/runtime-layout.json`.

## Vérifications reproductibles

Depuis la racine, avec le moteur canonique :

1. Godot `--headless --editor --path . --import`.
2. Godot `--headless --path . --script tests/run_runtime_resources.gd`.
3. Python `tools/maintenance/audit_runtime.py`.
4. Suites P1, P5, P4V2, P6A49 et P6A50 selon le rapport de l'issue 26.

L'audit est un contrôle de migration figé sur sa référence Git : il compare les
fichiers conservés après seule substitution des chemins, les assets et UID octet
pour octet, puis construit un graphe conservateur des ressources, types globaux
et dépendances binaires fournies par Godot. Ses catégories sont actif,
régression seulement, sources d'assets et retiré. Les préfixes de chemins
construits dynamiquement sont signalés séparément. Les parcours natifs restent
nécessaires pour vérifier les fabriques dynamiques, les sauvegardes et l'affichage.
Ne pas utiliser ce comparateur figé comme interdiction de futurs changements
fonctionnels autorisés dans d'autres issues.
