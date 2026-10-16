# Issue 26 — Version active et prototypes retirés

Date : 16 octobre 2026. Référence : `99cf5d1` (main après consolidation #24).
Demande : nettoyer les anciens prototypes sans modifier le gameplay validé.
Le statut et la PR courante sont dans `docs/brain/status.md`.

## Résultat

197 fichiers déplacés avec conservation des UID : le code de collection,
préparation, spécimens, atelier, blocs et poches est nommé par responsabilité.
Les points d'entrée deviennent `scenes/collection.tscn` et
`scenes/specimen_preparation.tscn`. La composition héritée est regroupée sous
`scenes/preparation/base/`. Les nœuds, héritages et propriétés sont inchangés.

77 fichiers retirés : essais trois blocs et plaques P6A42–46 (scènes, scripts,
shaders propres et tests propres), et douze lanceurs de comparaison obsolètes.
Leurs rapports et captures restent présents. L'ensemble original est récupérable
au tag distant vérifié `archive/pre-issue26-runtime`.

La racine propose `Launch-Game.ps1` et l'alias de compatibilité
`Launch-P6A50-Collection.ps1`. Le README présente la collection et les deux
spécimens, les commandes actuelles et la limite de sauvegarde en cours de fouille.
`docs/RUNTIME_LAYOUT.md` explique l'organisation et les sources des assets.

## Preuve de conservation et dépendances

`tools/maintenance/runtime-layout.json` liste chaque déplacement/retrait et sa
référence Git. L'audit compare 727 fichiers conservés avec cette référence :
seule la substitution mécanique des chemins est autorisée dans le code,
les shaders, scènes, outils et réglages. Les autres octets et UID sont conservés.
Les 181 fichiers d'assets/sources contrôlés restent inchangés ; aucun retuning,
remodelage, changement de seuil, de physique, de schéma de sauvegarde ou de nom
d'application. Le dossier des sauvegardes utilisateur reste donc le même.

Le graphe combine chemins littéraux, types GDScript globaux et dépendances Godot,
y compris le script sérialisé des champs binaires. Il distingue 188 dépendances
actives et 182 entrées de régression seulement (ensemble conservateur, incluant
les sorties de tests), ainsi que les sources et outils d'assets et les retraits.
Un préfixe dynamique connu du préparateur de textures P6A2 est signalé séparément.
Les fabriques de modèles sont exercées par les tests natifs M–08 et B–17.

Le chemin `scripts/p6a34/mesh_patch_data.gd` reste stable car sérialisé dans les
`.res`. Les bases de rendu partagées, tests de régression, assets intermédiaires,
notices et outils de reconstruction restent conservés. Ne pas confondre leur
ancien nom de phase avec du code supprimable : cette passe n'aplatit pas toute
la hiérarchie et ne réécrit pas le moteur de fouille.

## Vérification effectuée

| Vérification | Résultat |
| --- | --- |
| P1 (mapping / contacts) | 52 contrôles, 0 échec |
| P5 (progression / couverture) | 128, 0 |
| P4V2 (débris) | 91, 0 |
| Poche B–17, logique / natif | 197 + 71, 0 |
| M–08, géométrie / interactions | 26, 0 |
| Persistance collection | 24, 0 |
| Parcours natif collection | 32, 0 |
| Nouveau processus / collection sauvegardée | 1, 0 |
| Total gameplay et persistance | **622, 0** |
| Chargement ressources + scripts instanciables | **252, 0** |
| Import sans cache, ressources et logique M–08 | **252 + 26, 0** |
| Comparaison normalisée du code et des assets | **727 fichiers, 0 différence hors chemins** |

Import éditeur final sans erreur ni avertissement sous Godot 4.7.2 stable.
Le test sans cache copie aussi les matériaux, sans `.godot`, puis effectue un
nouvel import et un chargement des champs binaires. Cela évite de masquer une
référence cassée avec des UID déjà résolus localement.

Le parcours natif utilise les vrais outils sur M–08, garde la protection du
premier contact, les dégâts localisés, la Brush rapide et la couverture cachée.
L'archivage, l'échec/réessai, les photos, le retour à la fouille, les deux entrées,
la taille de fenêtre, le nouvel exemplaire et le redémarrage sont vérifiés.
Les captures du fossile enfoui avec/sans modèle sont identiques au sein du test.
Le second archivage B–17 utilise la fixture de préparation existante : ce n'est
pas un playtest humain complet. Les captures M–08, collection et poche B–17 ont
été relues visuellement. Aucun benchmark ou jugement humain n'est déduit des tests.

Tous les tests de sauvegarde utilisent des chemins sous `work/`. Les fichiers de
collection de l'utilisateur ne sont pas migrés ni modifiés. Les premiers essais
d'isolation ont révélé des omissions dans le montage du test (répertoire de
sauvegarde puis dossier des matériaux) ; ils ont été corrigés et les contrôles
concernés relancés. Aucun correctif de gameplay n'a été nécessaire.

Preuves : `docs/dev/evidence/issue26/summary.json`, `dependency-audit.json`, résultats
JSON ciblés et trois captures. Les preuves historiques restent à leur emplacement.

## Reproduction

Depuis la racine, employer Godot 4.7.2 stable et créer les répertoires de sortie :
`work/issue26/pocket`, `work/issue26/logic` et `work/issue26/native`.

- Import : `--headless --editor --path . --import`.
- Ressources : `--headless --path . --script tests/run_runtime_resources.gd`.
- Audit : `python tools/maintenance/audit_runtime.py` (référence Git disponible).
- Suites : `--headless --path . --script tests/run_p1_tests.gd`, puis
  `tests/run_p5_tests.gd`, `tests/run_p4v2_tests.gd` et `tests/run_p6a50_store.gd`.
- Poche : `--headless --path . --script tests/run_p6a49_pocket_finish.gd -- tests
  --qa --distinction-store=res://work/issue26/pocket/distinction.json`.
  Pour le parcours natif : retirer `--headless` et remplacer `tests` par `visual`.
- Collection : `--headless --path . --script tests/run_p6a50_collection.gd -- tests
  --qa --collection-store=res://work/issue26/logic/records.json
  --distinction-store=res://work/issue26/logic/distinction.json`.
  Pour le parcours natif : retirer `--headless`, remplacer `tests` par `visual`
  et utiliser les chemins sous `work/issue26/native/`.
- Rechargement : lancer `tests/run_p6a50_reload.gd` sans headless, avec `-- --qa`,
  `--collection-store=` égal au `collection_path` de `work/test-logs/p6a50/visual.json`
  et un `--distinction-store=` isolé sous `work/issue26/native/`.

## Essai demandé à Antoine

Lancer `Launch-Game.ps1`, ouvrir les deux caisses, retrouver les mêmes sensations
sur les outils et la poche, consulter la collection puis reprendre la fouille.
Il ne doit y avoir aucun changement visible ou de rythme. Les écrans provisoires
restent volontairement ceux validés pour la consolidation ; leur refonte relève
des issues 27/28. La PR attend la validation humaine avant fusion.
