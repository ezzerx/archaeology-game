# Rejeu exact — diagnostic du zoom de caméra

Date de mesure : 2026-10-20, Godot 4.7.2 stable.

## Constat et cause reproduite

Le rejeu historique `run_issue43_fluidity_replay.gd` échoue à comparer quatre
hauteurs de la terre compacte avec `atelier-sensory/before-replay.json` en natif.
Les quantités de cellules modifiées restent identiques : 7 360 au burin,
28 747 au souffleur, 4 529 au Pick, 21 944 à la brosse. Les autres cartes sont
identiques ; un écart supplémentaire de ~2 × 10⁻⁷ apparaît sur le pourcentage
final de propreté. Marin et concrétions restent exacts dans ce rejeu natif.

La cause est une entrée de test dépendante du temps réel, avant la fouille :

1. `zoom_to()` attend des frames de physique, mais laisse `PrecisionZoom._process`
   interpoler la caméra avec les deltas de rendu réellement écoulés.
2. L’ancrage réajuste `global_position` à chaque frame. Ces positions et les
   calculs vectoriels de caméra sont en float32 ; le nombre et la taille des
   étapes influencent les derniers bits du résultat.
3. Le rejeu convertit chaque point de carte en écran avec `at()`, puis en point
   d’impact avec le vrai ray-pick du contrôleur. Ce trajet n’est pas exact au bit
   près lorsque la caméra finale diffère. Les amplitudes de retrait continues
   peuvent donc changer sans modifier le nombre de cellules touchées.
4. Le JSON historique conserve les résultats, mais pas la transformation finale
   de la caméra ni les coordonnées effectivement repérées. Il ne suffit pas à
   reconstituer les arrondis d’entrée de cette exécution passée.

La sonde reproduit le symptôme **avec l’ancien code seul** : mêmes cartes
initiales et mêmes gestes, zoom à 240 Hz contre 60 Hz. Aucune optimisation
n’intervient dans cette comparaison.

| Mesure compacte | Oracle, zoom 240 Hz | Même oracle, zoom 60 Hz |
|---|---:|---:|
| Étapes de zoom avant convergence | 223 | 56 |
| Position caméra Y | 3,102224349975586 | 3,102220058441162 |
| Position caméra Z | 0,32647138833999634 | 0,3264709413051605 |
| Cellules retirées aux quatre étapes | 7360 / 28747 / 4529 / 21944 | Identiques |
| Empreintes des points réellement touchés | Référence de sonde | Différentes |
| Empreintes des hauteurs aux quatre étapes | Référence de sonde | Toutes différentes |

Dès le burin, le SHA256 de l’image RF passe de
`67f1299b2c049c14e554b3d7ea72bdd4a07bb3b3c5a25d6ed6c019c6f36351c9` à
`4d13a871dca4cc1e7db3a30f178d8e07d6267dc9e4df78dafeb7a2b0757a3998`.
Ce sont les empreintes de la sonde contrôlée, **pas de nouvelles fixtures**.
La caméra exacte du vieux relevé n’ayant pas été enregistrée, on ne prétend pas
retrouver ses quatre empreintes à partir de cette sonde.

## Preuve d’équivalence indépendante

`tests/run_museum_replay_exact.gd` extrait uniquement `demo_surface.gd` du commit
immuable `99fa7fe5c5da956078327e3629ba02ebb52c07be` vers `work/`. Une sous-classe
de bloc dédiée au test instancie cette surface ou la surface actuelle, dans deux
copies successives de la même préparation. Aucun fichier de production n’est
remplacé. L’oracle et la version actuelle utilisent les dépendances communes.

Vérification Git : `demo_surface`, `demo_block`, `compact_profile`,
`WorkingSurface`, `PrecisionZoom`, `ToolController`, `ReliefSurface` et le dossier
`scripts/excavation/` n’ont pas changé entre la base `04a8406` et `99fa7fe`.
Parmi ces fichiers, seule `demo_surface` diffère actuellement de `99fa7fe`.
Sa voie `demo_kind == 0` délègue immédiatement aux parents, sans atteindre les
boucles optimisées ; l’impact du burin n’a pas été modifié non plus.

Le test fixe seulement la cadence de préparation du zoom : `_process(1/240)`
appelé manuellement jusqu’au critère de convergence existant, puis caméra figée.
Fenêtre demandée : 1280 × 720, viewport de projet 1920 × 1080. Les autres règles
sont celles du rejeu historique : vraie projection/picking, même trajet, 120 ticks
à 60 Hz par outil, trois rafraîchissements visuels entre chaque tick. Aucun point
n’est arrondi ou substitué, aucun rayon, geste ou calcul de matériau n’est changé.

Résultat headless complet : **77 contrôles, zéro échec**. Trois préparations,
14 étapes d’outils, 1 680 ticks par version. Contrôles exacts :

- état initial et transformation de caméra sérialisée ;
- coordonnées de carte réellement repérées pour les 120 entrées de chaque étape ;
- hauteurs float32 et image RF, strates, os, plafonds, caps, exposition, film,
  fractures, poussière, condition, propreté, progression et volumes ;
- quantités retirées à chaque tick et dernier événement complet ;
- ordre et contenu des événements de matériau ;
- reset exact de chaque préparation.

Les comparaisons utilisent égalité stricte ou SHA256 des octets, sans tolérance.
Les empreintes sources LF de cette exécution sont conservées dans le résultat :
ancien `0231cffe87e9c28f0e3662bc419da5af458e4399b314be0649d0e89222a383af`,
actuel `f208958820f738556c2c11ed963c1a8e5b1e125abb478f9b6e776f82065a1899`.

## Reproduction et limites

Depuis la racine du dépôt, avec Git et Godot 4.7.2 :

```powershell
godot --headless --path . --script tests/run_museum_replay_exact.gd -- --qa --distinction-store=res://work/museum-polish/replay-exact/distinctions.json
```

Ajouter `--compact-only` après `--` pour la sonde rapide (25 contrôles).
Rapport : `work/museum-polish/replay-exact/result.json` ; log complet de cette
mesure : `work/museum-polish/replay-exact-all-headless.log`.

Le test historique et ses fixtures restent intacts, avec leur résultat d’échec
historique explicitement conservé. Cette preuve différentielle vérifie la
conservation de la fouille à entrées rigoureusement identiques ; elle ne remplace
ni l’essai humain ni le test visuel natif. Les différences headless/natif du vieux
rejeu ne doivent pas être transformées en nouveaux hashes de référence sans
maîtriser d’abord caméra, viewport et points d’entrée. Aucun seuil n’a été élargi.

## Confirmation native finale

Le même test complet a ensuite été exécuté en Compatibility natif :
**77 contrôles, 0 échec**, y compris les mêmes coordonnées d’entrée, cartes,
volumes et événements dans les trois familles. La sonde de cadence reproduit
aussi les différences sur l’ancien code. Preuves conservées séparément :
`docs/dev/evidence/museum-sensory/replay-headless-exact.json` et
`replay-native-exact.json`. L’exécution native utilise la commande ci-dessus
sans `--headless`, avec `--rendering-method gl_compatibility`.
