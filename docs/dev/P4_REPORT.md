# Rapport P4 — FINAL FEEL, protection par composant

> Dernière décision de clôture : **Soil sans mess persistant**, grains et dépôt Dust retirés ; micro-restes hard détachables au Brush et évacuation Matrix par engagement du Blower. [Contrat courant](P4V2_BRIEF.md). Les réglages historiques de débris ci-dessous ne sont plus la baseline courante.

> Addendum humain de clôture, 2026-10-04 : Precision Pick **radius 11.0 / power 0.44 / falloff 1.75**, cadence 6 Hz, `bone_damage=0`, efficacités inchangées. **P4 human-validated baseline — final fine tuning still deferred to P7.** Les mesures plus anciennes ci-dessous décrivent leur baseline datée ; [rapport courant](P4V2_REPORT.md), [mesures Pick de la première clôture](P4V2_FIRST_CLOSURE_REPORT.md).

**2026-10-04 · `prototype/p4-game-feel` · Godot 4.7.2 / Compatibility.**

Code du micro-fix : **`0c549f58d6c2c27e21251a854c2e18a39d389ee2`**, base **`44edb75c71398d72137966f2fd029d7614552e68`**. [PR #5](https://github.com/ezzerx/archaeology-game/pull/5) **brouillon, non mergée**. Unique changement de gameplay : **une protection de premier contact direct par composant anatomique**. Les baselines humaines, le snapshot avant impact et tout le reste du Final Feel sont conservés. Source de vérité : [P4_FINAL_FEEL_TARGET](P4_FINAL_FEEL_TARGET.md).

## Micro-fix courant — protection indépendante par composant

`FossilState.direct_contact_consumed` remplace le booléen global par un **PackedByteArray de cinq cases** indexées par `FossilField.Component`. NONE reste inutilisé ; **Skull / Spine / Ribs / Hind Limb** ont chacun un flag. `is_direct_contact_protected(component)` expose l’état. `contact_at` consulte uniquement le composant de la cellule centrale, déjà exposée avant le coup, et ignore NONE. **Bone Condition reste globale**, avec les dégâts historiques de trois points.

B-17 dispose de **quatre protections maximum par reset**, jamais une par cellule, côte, vertèbre ou nouvelle zone. Toutes les côtes partagent RIBS et toute la colonne partage SPINE. Reset remet les quatre flags à READY et la condition à 100. Révélation centrale ou adjacente, Pick, Brush et Blower ne consomment aucun flag. Les sons existants suivent les mêmes événements. F1 ajoute seulement READY/USED dans les lignes de composants déjà présentes.

Résultat réel du nouveau test `run_p4_component_contact_tests.gd`, avec B-17 et les ressources de production :

| Impact sur os déjà visible | Protection | Dégât | Condition globale | Son |
|---|---|---:|---:|---|
| Skull, premier | Skull consommée | 0 | **100** | Petit tik |
| Skull, deuxième | Aucune nouvelle | 3 | **97** | Gros DING |
| Ribs, premier | Ribs consommée | 0 | **97** | Petit tik |
| Ribs, deuxième | Aucune nouvelle | 3 | **94** | Gros DING |

Une autre côte éloignée, révélée ensuite, ne redonne aucune protection : son premier hit sur centre visible descend à **91**. Spine puis Hind Limb restent indépendants : premier hit protégé pour chacun, condition inchangée à 91 ; une autre vertèbre prend ensuite trois points. Le reset et les outils sûrs sur les quatre composants laissent tous les flags disponibles. **Baseline P4, réévaluable au tuning P7 si nécessaire.**

Validation courante : **1 517 checks fonctionnels (dont 72 nouveaux) + 90 contrôles graphiques**, zéro échec, soit **1 607 contrôles comptés**. Six cas CPU de pose, oracle GPU **194 955 pixels**, 28 WAV historiques identiques et sonde de condition également verts. Sanity uniquement : **quatre cas Chisel Clay/Stone à 1×/3×**, **239,86–239,87 FPS**, P95 maximal **4,325 ms**, frame max **11,768 ms**, sur RTX 5080 / Ryzen 9800X3D en 1080p. Cap 240 FPS / physique 60 Hz inchangés. Aucun benchmark long relancé ; les mesures Brush du lock précédent restent historiques.

[Validation courante](evidence/p4-component-validation.json) · [séquence des composants/reset](evidence/p4-component-contact.json) · [sanity](evidence/p4-component-sanity.json) · [composition](evidence/p4-component-composition-visual.json) · [dust/cleanup](evidence/p4-component-feedback-visual.json) · [matières](evidence/p4-component-material-visual.json) · [GPU](evidence/p4-component-gpu.json) · [condition](evidence/p4-component-condition.json) · [coût proxy](evidence/p4-component-proxy-cost.json).

Le diff de production est limité à `fossil_state.gd` et à l’affichage dev dans `prototype_main.gd`. Ressources, retrait, fracture, spectacle, débris, audio, shaders, proxies et caméra inchangés. La modification locale préexistante de `project.godot` reste exclue. **P4 Final Feel ready for human closure / P4-V authorization.** STOP ; aucun merge ni ouverture de P4-V/P5.

## Historique du lock des ressources

Le code **`e5df77f`**, livré au HEAD **`44edb75`**, a persisté les baselines ci-dessous et corrigé l’éligibilité avant impact. Ses mesures complètes sont conservées ; sa protection alors globale est remplacée par le micro-fix ci-dessus.

## Ressources : avant / après

**P4 human-validated baseline — tuning final deferred to P7.**

| Ressource | Avant : rayon / puissance / falloff | Baseline P4 persistée |
|---|---|---|
| `soft_brush.tres` | 40 / 0.80 / 1.50 | **40 / 0.70 / 1.25** |
| `chisel.tres` | 12 / 0.24 / 2.00 | **22 / 0.64 / 2.25** |
| `air_blower.tres` | 60 / 0 / 1.00 | **60 / 0 / 1.00**, inchangé |
| `precision_pick.tres` | 7 / 0.24 / 1.50 (ancien lock) | **11 / 0.44 / 1.75** (addendum humain de clôture) |

Blower conserve `residue_clear = 2.5`. Cadences Chisel **4.5 Hz** / Pick **6 Hz**, efficacités, génération de résidu, dégâts Bone, résistances et seuils de fracture inchangés. Les tests chargent la scène réelle et vérifient les quatre triplets au lancement puis au reset, sans entrée debug. Le reset conserve son fonctionnement existant si le joueur ajuste ensuite le debug pendant sa session.

## Performance du lock avec ces baselines

Scène 1080p, Godot 4.7.2 Compatibility, RTX 5080 / Ryzen 7 9800X3D, cap 240 FPS / physique 60 Hz. Douze cas Brush, avec/sans proxy, immobile, Soil en mouvement et zone creusée, à 1×/3× ; aucune erreur. Gestes Soil de 30 s :

| Zoom | FPS, proxy actif | P95 frame | Frame max | Proxy P95 | FPS sans proxy |
|---|---:|---:|---:|---:|---:|
| 1× | **235,24** | 12,264 ms | 14,964 ms | 31 µs | 237,15 |
| 3× | **236,17** | 12,202 ms | 15,567 ms | 31 µs | 236,81 |

Le Brush reste proche du cap. Aucune chute <10 FPS dans ces mesures ; le résultat ne prétend pas reproduire toutes les conditions du signalement humain. Les empreintes finales gameplay correspondent entre proxy actif/désactivé pour chaque geste. Sonde CPU : six cas, ≤12 sondes/48 lectures, zéro modification de mesh, fit P95 ≤34 µs même avec densité du relief doublée. [Mesures Brush du lock](evidence/p4-lock-brush.json) · [coût proxy](evidence/p4-lock-proxy-cost.json).

## Historique conservé : diagnostic du bugfix Brush

Les trois sections suivantes concernent le bugfix **`59f7e21`**, avant le lock des ressources. Les nombres avant/après ci-dessous restent des preuves historiques ; les mesures courantes figurent ci-dessus.

Le signalement humain est une chute **sous 10 FPS** pendant Brush → Soil → mouvement continu. Cette chute précise n’a **pas été reproduite** dans le benchmark autonome ; le surcoût du proxy est en revanche isolé quantitativement. La référence avant correction est `70349ab`, avec seulement des compteurs temporels et un interrupteur de diagnostic pour masquer/désactiver les proxies sans couper les autres effets.

Même scène 1080p, RTX 5080 / Ryzen 7 9800X3D, réglages de jeu inchangés, cap 240 FPS / physique 60 Hz. Pour chaque zoom : Brush immobile six secondes, mouvement de 30 secondes partant de Soil intact, mouvement six secondes dans une zone déjà creusée. Chaque geste est rejoué avec et sans proxy, soit douze cas avant et douze après. Rendu, audio et effets actifs ; bus muet. Préparation, reset et captures exclus du chronométrage.

**Cause vérifiée : le solveur de dégagement du proxy reconstruisait ses meshes pendant le jeu.** Un changement de contact ou d’upload invalidait la pose ; les neuf pièces Brush déclenchaient scans rectangulaires du relief, duplication des positions, sondes de faces, normales et `clear_surfaces/add_surface_from_arrays`. En zone creusée, couper seulement le proxy faisait passer **120,32 → 236,11 FPS à 1×**, et **125,54 → 235,97 FPS à 3×**. Les uploads et effets étaient beaucoup plus petits.

Sonde CPU isolée avant fix, 120 poses en zone creusée : jusqu’à **1 498 lectures de sommets terrain par pose**, **729 notifications de modification de mesh**, P95 du fit **10 823 µs**. Doubler la densité linéaire du relief portait ces lectures à **5 495**, P95 **15 333 µs**. Le coût dépendait donc de la géométrie/du relief, malgré le cache. Cela établit la régression du proxy, sans attribuer artificiellement les <10 FPS non reproduits à un autre facteur non mesuré.

## Proxy après simplification

`ToolRoot` garde la base exacte **`Basis.from_euler(Vector3(0.5, 0, -0.62))`**. Deux enfants : **Tip**, pointe réelle au hit, et **Body**, manche/corps statiques. La silhouette existante est séparée une seule fois à quatre millimètres du contact lors de l’initialisation.

En jeu : au plus **douze sondes de hauteur** réparties sur trois sections du corps ; un simple déplacement vertical, aucun recalcul des sommets/normales, aucune reconstruction de surface, aucun scan de zone ni duplication de vertex arrays. Dégagement réutilisé si contact/height inchangés ; le recul déplace Body et ne relance pas les sondes. Zéro soulèvement au repos sur le plat ; pointe et angle inchangés même avec une normale presque horizontale.

La sonde CPU après fix relève **48 lectures de sommets maximum**, même avec densité doublée, **zéro modification de mesh**, P95 **37 µs** en zone creusée. Les tableaux de sommets/normales et ressources restent identiques sur tous les contacts. La cavité synthétique extrême demande jusqu’à **83,14 mm de déplacement, recul compris**. De rares petites intersections ou une séparation pointe/corps dans ce cas extrême sont acceptées par la priorité humaine : fluidité, angle stable, contact lisible, puis anti-clipping. Aucun retour au suivi des normales.

## Performance avant / après

Proxy actif dans les deux colonnes. Temps de frame en ms, coût proxy au P95 en µs.

| Scénario | FPS avant → après | P95 frame avant → après | Frame max avant → après | Proxy P95 avant → après |
|---|---:|---:|---:|---:|
| Immobile 1× | 146,27 → 231,69 | 13,178 → 12,502 | 25,128 → 17,486 | 5 515 → 33 |
| Immobile 3× | 156,63 → 237,75 | 12,378 → 12,058 | 20,008 → 13,908 | 5 309 → 31 |
| Soil en mouvement 30 s, 1× | 143,57 → **232,59** | 17,860 → **12,537** | 30,367 → **18,205** | 8 616 → **32** |
| Soil en mouvement 30 s, 3× | 154,03 → **235,60** | 17,027 → **12,265** | 34,910 → **17,400** | 8 432 → **32** |
| Zone creusée 1× | 120,32 → 236,76 | 19,817 → 12,162 | 34,417 → 15,668 | 9 574 → 32 |
| Zone creusée 3× | 125,54 → 237,08 | 17,562 → 12,080 | 35,789 → 14,696 | 9 132 → 32 |

Après fix, proxy actif/désactivé : **232,59 / 233,10 FPS à 1×**, **235,60 / 236,66 à 3×** sur les gestes de 30 s, moins de 0,5 % d’écart. Les six comparaisons restent à moins de 1 % ; les empreintes finales height, residue et débris, les cellules modifiées, exposure et condition correspondent avant/après et avec/sans proxy. Le Brush n’a pas été retuné.

Détail CPU du geste de 30 s à 1×, **moyenne / P95**, en µs. ToolController inclut WorkingSurface et le consommateur synchrone : ces lignes ne s’additionnent pas. Proxy/particules/débris sont mesurés par frame rendue, édition/uploads par tick physique.

| Mesure | Avant | Après |
|---|---:|---:|
| ToolController `edit_usec` | 8 188,7 / 9 185 | 7 897,1 / 8 445 |
| WorkingSurface seul | 8 161,4 / 9 152 | 7 871,7 / 8 412 |
| RF height upload | 131,7 / 156 | 123,0 / 139 |
| Residue upload | 10,0 / 20 | 7,6 / 10 |
| Total `upload_usec` | 141,7 / 172 | 130,6 / 148 |
| `proxy_usec` | 1 918,9 / 8 616 | 15,4 / 32 |
| Feedback synchrone de l’action | 22,2 / 31 | 20,8 / 28 |
| Particules | 55,1 / 80 | 53,7 / 72 |
| Rendu des débris persistants | 45,4 / 127 | 27,8 / 111 |

Les JSON contiennent aussi les maxima et toutes ces mesures à 3×. Les moyennes dépassent largement 60 FPS et tous les P95 après correction sont sous 16,67 ms ; quelques frames isolées atteignent 18,205 ms. Le test autonome ne remplace pas le retest humain de 30–60 s dans les conditions du signalement.

## Bone : prérequis avant impact conservé, protection par composant

Cause exacte restante : le bugfix précédent avait séparé découverte et protection, mais autorisait encore le **centre révélé par le coup lui-même** à consommer `first_direct_contact_consumed`. Le joueur découvrait donc un os dont la protection était déjà dépensée ; son premier clic volontaire visible produisait DING/−3. Cette règle est abandonnée.

`apply_impact` capture **`was_exposed_before_impact` avant toute mutation**. Le centre exact doit déjà être exposé dans ce snapshot et l’outil doit pouvoir faire des dégâts pour consommer la protection **de ce composant** ou infliger les dégâts ultérieurs. `FossilState.contact_at` rejette également tout centre qui n’était pas exposé avant le coup. `first_contact` reste la découverte/UI ; aucune décision depuis `bone_revealed`, les cellules nouvellement exposées ou les compteurs après mutation. Actuellement, seul Chisel est dommageable. Le tableau suivant part d’un reset et reste dans le même composant.

| Action | Protection / condition | Son |
|---|---|---|
| Révélation adjacente, même première | Protection disponible ; 100 ; aucun événement protégé | Matériau travaillé |
| **Centre caché révélé par ce coup** | **Protection toujours disponible ; 100 ; aucun événement protégé/direct** | **Matériau travaillé** |
| Premier Chisel suivant sur Bone déjà exposé avant le coup | `bone_protected_contact = true`, dégâts 0 ; 100 ; protection consommée | Petit tik |
| Deuxième Chisel au même point | Protection fausse, dégâts historiques 3 ; 97 | Gros DING |
| Reset | Les quatre protections réarmées ; 100 | État audio réinitialisé |
| Pick, Brush, Blower avant Chisel | Aucun dégât, aucune consommation | Audio propre à leur travail |

Toute révélation, centrale ou adjacente, reste sans dommage et ne consomme jamais la protection. Après consommation, une nouvelle cellule cachée reste également sûre sur l’impact qui la découvre ; seuls les centres déjà exposés prennent les dégâts ultérieurs. À condition zéro, aucun faux son de dommage. Les **28 WAV historiques restent identiques**.

Test obligatoire dans `tests/run_p4_audio_tests.gd` : reset → fracture révélant le centre caché (Stone/100/protection disponible/événement protégé faux) → clic suivant (tik/100/protection consommée) → clic suivant (DING/3 dégâts/97) → reset réarmé. Les cas adjacents et Pick/Brush/Blower passent aussi. Deux cycles de révélations adjacentes : **3 Clay et 86 Stone supplémentaires** par cycle, aucun son Bone ni consommation. Tests de surface P3/P4 et entrée souris réelle restent verts.

## Acquis Final Feel conservés

- **Chisel A `42ec46d`** : marks → cracks → chunks, éclats 3–6 mm, 1–5 par plaque cassée, départ au dessus estimé du morceau, durée 0,51–0,69 s, pools 4 × 48 ; fracture, cadence et résistances inchangées. Seuls rayon/puissance/falloff prennent les valeurs autorisées.
- **Blower B `c25b44f`** : miettes dures visibles jusqu’à 4,5 mm, vol directionnel et sortie de frontière ; hook `debris_ejected`. Zéro retrait structurel ou dommage.
- **Quantités persistantes** : deux miettes par zone 24×24, rétention 8 %, capacité 0,02 ; Soil à 1,4 mm / 14 %. Dust locale, ivoire Bone, effets de souffle inchangés.
- **Pick, baseline humaine actualisée à la clôture** : six impacts/s, **11 / 0,44 / 1,75**, efficacités 0,30/ 1,00/ 1,50 inchangées, interface/plafond Bone, zéro dégât. Nettoyage structurel local rapide, sans stress de fracture ni gros chunks. Le ratio historique 15,76 et les retraits 0,08/ 0,045 concernaient le lock précédent ; le nouveau banc donne **Chisel/Pick 4,46**, retraits centraux **0,146667 Clay / 0,0825 Stone**. Empreinte Pick 373 cellules, au plus un quart de la surface du disque Chisel ; le retrait de masse reste le rôle du Chisel.
- **Caméra/input** : zoom 1–3×, RMB pan borné, Home et R, touches/debug, picking exact ; 240 FPS / physique 60 Hz.

## Validation historique du lock et preuves

**1 445 checks fonctionnels, zéro échec** : P0 45, P1 52, P2 97, P3 88, zoom 160, P4 72, pan 43, audio 42, dirt 27, débris 18, Pick 39, feedback 25, proxies 737. Six cas CPU de pose et douze cas Brush également verts. Le test d’entrée P3 vérifie le premier contact sur Bone visible protégé, puis la pénalité habituelle au clic suivant.

**90 contrôles graphiques, zéro échec** : feedback 16, composition 28, matières 46. **28 scénarios à 235,18–240,01 FPS**, P95 maximal **12,214 ms**, frame maximale **14,478 ms**. Oracle GPU : **194 955 pixels**, height ≤0,004825, matériau corrigé ≤0,010882, maps exactes et tolérances inchangées. Les 28 WAV historiques passent la comparaison SHA-256 du test Pick.

Avec le Chisel 22/ 0.64/2.25, le test de spectacle produit 30 particules Clay / 33 Stone, visibles aux deux zooms. Après une minute simulée : **40/39 miettes Clay/Stone**, dans les mêmes budgets de deux par zone ; zéro après souffle. Blower : 43 paquets au premier souffle, 144 sorties, zéro modification structurelle ou de condition. Ces quantités résultent du nouveau footprint et ne changent pas les règles de débris.

[28 scénarios](evidence/p4-lock-benchmark.json) · [composition](evidence/p4-lock-composition-visual.json) · [dust/cleanup](evidence/p4-lock-feedback-visual.json) · [matières](evidence/p4-lock-material-visual.json) · [GPU](evidence/p4-lock-gpu.json) · [test Bone/audio](evidence/p4-lock-audio.txt).

Sonde attentive avec baselines courantes : **344 impacts → 4 976 cellules exposées, 57,77 % du crâne, condition 100, protection toujours disponible**. Dix impacts ultérieurs sur un centre visible : premier protégé à 100, neuf dommages de trois points → **73**. Cette sonde reconnaît parfaitement les centres visibles ; elle ne remplace pas un geste humain. **4 432 rayons zoom, 387 pan** ; plafonds osseux et picking conservés.

Le test de fracture conserve une charge historique explicite (12/ 0.24/2) pour vérifier les mêmes seuils marques/détachement sans les confondre avec le tuning. Les scènes réelles, audio, Pick, débris, sonde de condition et benchmarks emploient les nouvelles ressources. Le test P2 compare la génération des résidus sous saturation : une puissance supérieure ne doit pas invalider une comparaison de ratios en remplissant le dépôt.

Les régressions du proxy vérifient toujours pointe exacte, base stable, meshes statiques, zéro effet gameplay, nombre borné de sondes et coût CPU. Aucun seuil de performance ou de rendu n’est assoupli pour le lock.

[Validation du lock antérieur](evidence/p4-lock-validation.json) · [condition](evidence/p4-lock-condition.json). Historique du bugfix précédent : [Brush avant](evidence/p4-bugfix-brush-before.json) · [Brush après](evidence/p4-bugfix-brush-after.json) · [coût proxy avant](evidence/p4-bugfix-proxy-cost-before.json) · [coût proxy après](evidence/p4-bugfix-proxy-cost-after.json) · [validation ancienne](evidence/p4-bugfix-validation.json).

Les JSON `p4-bugfix-*` décrivent le code `59f7e21`, notamment son ancienne protection centrale désormais abandonnée ; ils restent des preuves historiques, pas la règle actuelle. Proxies inchangés : [Brush en cavité](evidence/p4-bugfix-deep-brush.png), [Chisel au bord](evidence/p4-bugfix-deep-edge-chisel.png), [Pick/Bone](evidence/p4-bugfix-bone-pick.png).

Reproduction complète :

```powershell
& tests/check_p4.ps1 -GodotBin 'C:\Users\antoi\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' -Graphical
```

Les preuves A/B restent sous `evidence/p4-feel-*`, le bugfix précédent sous `p4-bugfix-*`, le lock des ressources sous `p4-lock-*` et le micro-fix courant sous **`p4-component-*`**. La modification locale préexistante de `project.godot` est préservée et exclue des commits. Aucun merge, P4-V, physique des débris, verticalité ou P5.

## Retest humain — exactement trois points

Les baselines proviennent du dernier test humain. Pour la décision de fermeture : ouvrir `project.godot` dans Godot 4.7.2, **F5**, masquer **F1**, sans retoucher les paramètres debug.

1. **BRUSH PERF** — Reset, puis Brush sur Soil pendant **30–60 s** : aucune chute massive, jeu fluide, sensation Soil inchangée.
2. **BONE PROTECTION** — Révéler Skull : aucun flag consommé. Skull → Skull → Ribs → Ribs sur os déjà visible : **tik/100 → DING/97 → tik/97 → DING/94**. Une autre côte ne redonne pas de protection. Spine/Hind Limb indépendants ; reset réarme les quatre.
3. **QUICK SANITY** — Chisel + Blower + Pick pendant quelques minutes : vérifier que les autres sensations sont conservées.

**STOP après push du lock. PR #5 BROUILLON, NON MERGÉE. P4-V et P5 restent interdits sans nouvelle autorisation explicite.**
