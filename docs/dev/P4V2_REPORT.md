# P4 — Micro-passe finale : finir et nettoyer sans ambiguïté

2026-10-05 · `prototype/p4v2-debris-physics` · [PR #7](https://github.com/ezzerx/archaeology-game/pull/7) **DRAFT, aucun merge ni P5**. Baseline d'entrée : `1aadaa3f35d2d73963dccc2a14a6055840644046`.

Le cœur P4, le look/physique Matrix, le spectacle Chisel, le Bone Film sombre et le Pick **11 / 0,44 / 1,75** sont validés humainement. Cette micro-passe traite uniquement trois irritants : poussière Soil persistante, minuscules restes structurels ambigus et cap Matrix retenu par des miettes soufflées encore dans le bloc. **Le nouveau retest humain reste à faire.** [Brief courant](P4V2_BRIEF.md), [passe dust-only archivée](P4V2_DUST_ONLY_REPORT.md).

## Soil : aucun mess persistant

**Soil persistent dust deferred to P6/P7 redesign.** Le dépôt `SurfaceResidue` est ignoré pour Soil, dans les chemins de retrait continu et de fracture. Les grains et leur pool étaient déjà supprimés. Retrait structurel, audio, relief, couleur et paramètres du Brush sont conservés ; aucun shader n'a été modifié pour masquer la poussière.

- Brush natif pendant **20 s** sur trois bandes de Soil : **0 grain, 0 Matrix créée, 0 nouvelle Dust Soil** ; une plage de Dust hard préexistante éloignée reste byte-exacte.
- Captures à 1×/3× : zéro différence Dust par rapport à la référence sans résidu.
- Les chemins Clay/Sandstone déposent toujours leur Fine Dust. Cette Dust et le Bone Film ne consomment jamais le cap Matrix.
- Chaque benchmark Soil de 20 s effectue **zéro upload de résidu**. Le coût CPU du balayage de nettoyage du résidu existe toujours : aucune promesse de CPU nul.

## Micro-restes hard : conversion locale au Brush

`MicroRemnant` examine uniquement le voisinage de la cellule touchée. Critères cumulatifs :

| Critère | Valeur |
|---|---|
| Matériau | Clay ou Sandstone exposée |
| Épaisseur restante | ≤ **1,5 mm** au-dessus de son interface inférieure ou du plafond Bone |
| Emprise | composante **8-connectée, ≤4 cellules** de la heightmap |
| Inspection | entièrement reconnue dans une fenêtre **5×5** autour du candidat |
| Attachement | aucun prolongement ni voisin supporté plus épais, diagonales comprises |
| Geste | poids de Brush ≥0,25 ; **64 inspections maximum par action** |

Sur le bloc 1,1×0,7 m /1024×640, quatre cellules représentent environ4,7 mm² de footprint. Les critères sont conservateurs : un voisin hors carte ou un prolongement hors fenêtre invalide l'îlot. Ce n'est ni une segmentation globale ni un flood-fill du terrain.

Le Brush convertit **tout le petit îlot admis** en quantité de Matrix crumb, puis abaisse ses cellules exactement à l'interface/plafond Bone. La miette reçoit le comportement physique existant ; un passage Brush suivant la nettoie. Cette conversion n'utilise pas la rétention de8 % des impacts Chisel. Aucun stress de fracture, gros chunk, dégât Bone ou protection consommée. Si le budget local/global ou la capacité de la miette empêche l'admission, **la structure reste intacte** ; libérer une place permet la conversion suivante.

Pour appliquer « Brush ne fait rien sur un vrai morceau attaché », l'efficacité native Clay du Brush passe de **0,06 à0** ; Stone était déjà à0. C'est la seule correction d'efficacité : rayon40, puissance0,70, falloff1,25, nettoyage du film et du mess sont conservés. Pick/Chisel gardent les vrais morceaux structurels.

Tests côte à côte sur les deux matériaux : îlot1,2 mm détaché, morceau3×3 de6 mm intact. Rejets répétés : îlot2,1 mm, cinq cellules, nappe mince50×25, rattachement diagonal épais. Îlot2×2 à1,5 mm admis. Au Skull réel : plafond exact, Condition100, film nouvellement révélé encore présent. Stress : **2 632 cellules converties**, maximum25 inspections/action et12 miettes simultanées.

## Blower : évacuation de gameplay puis vol visuel

**Matrix crumbs can be removed by cleanup commitment, not only literal block-edge crossing.** Le jet teste la position actuelle de chaque miette, y compris sur Soil. Il accumule `poids × durée` seulement si le poids est≥0,25 ; à **0,075 seconde pondérée**, le nettoyage est engagé. Un passage centré demande environ cinq ticks à60 Hz ; une influence au seuil demande environ0,3 s. La dose est oubliée après0,15 s sans influence suffisante. Un effleurement d'une frame ou des contacts au bord du rayon ne suffisent pas.

À l'engagement, dans cet ordre :

1. Retirer la quantité et ses slots logique, local et physique.
2. Émettre une notification unique d'évacuation au point courant.
3. Montrer un FX **EJECTING pendant0,35 s**, même mesh/couleur/taille, vitesse horizontale0,65 m/s dans le jet et lift initial0,08 m/s. Gravité visuelle0,65 ; rétrécissement sur les derniers40 % de vie.

Le vol est un retour visuel sans collision terrain ; il n'est plus propriétaire de mess. Aucun besoin de traverser tout le bloc. Le budget est réutilisable pendant ce vol. Le hook `physical_ejected` peut donc désormais signaler une évacuation au centre ; l'expiration du FX n'émet aucun deuxième événement. Les sorties naturelles au bord restent possibles et libèrent toujours leurs slots.

**Matrix256 + FX256** : le MultiMesh réserve512 instances fixes, avec le mesh statique existant. Si les FX saturent, seul le plus ancien FX est remplacé ; aucune miette logique n'est supprimée par cette limite. Pas de nouveaux nodes/colliders ni de reconstruction de mesh. F1 sépare `Matrix crumbs`, Moving/Sleeping et `Ejecting FX (outside cap)`.

Le noyau gravité/collision/pente/sleep au spawn reste inchangé. Le jet utilise maintenant la règle de nettoyage ci-dessus plutôt que l'ancienne poussée `TerrainDebris.blow` ; cette dernière subsiste comme primitive diagnostique dans les tests historiques. F3 OFF conserve la même sémantique d'évacuation.

| Preuve | Résultat |
|---|---|
| Cap plein déplacé sur Soil, souffle local | **256 logique →0**, physique0, **256 FX visibles** |
| Quatre nouveaux impacts Chisel avant expiration | **13 nouvelles miettes** admises,256 anciens FX encore présents |
| Après0,5 s | aucun FX résiduel, aucun double événement |
| Micro-reste bloqué par cap plein | structure conservée ; après nettoyage, conversion possible pendant l'ancien FX |
| 64 miettes rendues sur Soil | 64→0 ; contribution du vol **858 /7 798 pixels** à1×/3× |

## Acquis préservés

- Fréquence **Clay3 / Sandstone4 par zone24×24**, cap global256, rétention Chisel8 %, capacité0,02, taille maximale4,5 mm, proportions, mesh et couleurs inchangés. Pas de nouvel essai de densité.
- Chunks Chisel3–6 mm et leur courte durée conservés.
- **Bone Film entièrement inchangé** : code, ressource et shader de production identiques à l'entrée. Teinte sombre validée, Brush seul, Exposure/Condition/protections indépendantes. Les comparaisons GPU retrouvent les mêmes comptes de pixels de film que la passe précédente.
- Pick **11 /0,44 /1,75**, cadence6 Hz, `bone_damage=0`, efficacités0,30/1,00/1,50. Aucun stress de fracture ni gros chunks. **P4 human-validated baseline — final fine tuning still deferred to P7.**
- Verticalité, plafonds Bone, géologie, caméra, proxies, sons et règles de contact Bone préservés. `project.godot` était modifié avant cette passe : fichier conservé hors commit.

## Performance et validation

Godot4.7.2 Compatibility, RTX5080, Ryzen7 9800X3D,1920×1080, cap240 FPS, physique60 Hz. Rendu et FX réels ; setup/captures exclus du chronométrage. Soil dure20 s, les autres scénarios6 s. Aucun autre benchmark lancé en parallèle.

| Scénario 1× /3× | FPS moyens | P95 frame ms | Max frame ms | CPU débris P95 µs | Résidu edit P95 µs |
|---|---:|---:|---:|---:|---:|
| Brush Soil20 s | 145,05 /144,85 | 10,899 /10,927 | **103,965** /12,804 | 59 /64 | 49 /48 |
| 256 sleeping | 144,91 /144,74 | 7,903 /7,923 | 8,413 /8,833 | 1 022 /1 074 | 0 /0 |
| Blower local256→0 | 144,76 /144,76 | 7,105 /7,112 | 8,958 /9,090 | 220 /216 | 90 /85 |
| Brush micro-restes | 144,75 /144,75 | 8,120 /8,003 | 8,776 /8,938 | 134 /118 | 49 /48 |
| Brush Bone Film | 144,70 /144,70 | 11,506 /11,255 | 12,560 /12,469 | 44 /41 | 47 /42 |

`CPU débris` chronomètre tout `LooseDebris.advance`, y compris les FX. Le nettoyage Blower est mesuré séparément : **maximum1 421 /1 412 µs** ; le P95 de2 µs sur6 s est peu représentatif du pic d'évacuation, puisque le cap est libéré très tôt. Brush micro : edit P95990 /887 µs. Film :189 uploads dans chaque cas, soumission CPU P9552 /48 µs (maximum131 /178). Tous les cas ci-dessus : **0 upload de SurfaceResidue**, car seuls Soil/film/micro-restes/nettoyage sans Dust préexistante sont exercés ; les tests hard séparés vérifient sa génération normale.

**Anomalie conservée :** la première série tourne autour de145 FPS malgré le cap240, et Soil1× contient une frame isolée de103,965 ms. Une répétition ciblée des deux gestes Soil, sans modification de production, donne **239,95 /239,94 FPS**, P95 **8,172 /8,086 ms**, maxima **11,108 /11,786 ms**, minimum sur1 s **239,13 /239,04 FPS**, toujours zéro upload de résidu. Le pic ne se reproduit pas. Cause de la différence entre sessions non établie ; ni gain chiffré ni absence absolue de hitch ne sont revendiqués. Les deux JSON sont conservés, sans remplacer la série défavorable.

Le contrôle historique via le contrôleur réel ajoute quatre cas Blower128, à1×/3×, F3 ON/OFF : **128→0 partout**,239,86 FPS, P95 maximal4,439 ms, maximum5,633 ms ; quantités évacuées exactes et aucune modification structurelle. [JSON](evidence/p4-micro-controller-blower-benchmark.json).

Contrôles : **1 895 assertions fonctionnelles uniques** (chaîne P0→P4-V2, puis quatre protections de cap ajoutées), plus rejeux V1/V2 identiques entre processus ; **93 contrôles GPU ciblés** et **76 assertions de performance** sur dix scénarios +deux répétitions Soil +quatre contrôles Blower historiques. Zéro échec au dernier passage de chaque suite. La suite graphique historique `run_p4v_visual_cleanup_visual.gd` a été interrompue après plusieurs minutes sans progression des captures : ses38 assertions ne sont pas comptées comme vérifiées. Géologie/picking/shaders de production inchangés et régressions fonctionnelles vertes. Les longues anciennes matrices de benchmarks P4/P4-V1/P4-V2 ne sont pas toutes relancées ; les résultats archivés ne sont pas présentés comme des mesures de cette micro-passe.

[Tests ciblés](evidence/p4-micro-tests.json) · [GPU](evidence/p4-micro-visual.json) · [Benchmark complet](evidence/p4-micro-benchmark.json) · [Répétition Soil](evidence/p4-micro-soil-repeat.json) · [Index de vérification](evidence/p4-micro-verification.json).

Captures : [Soil1×](evidence/p4-micro-soil-1x-clean.png), [micro-restes avant](evidence/p4-micro-remnants-3x-before.png) → [détachés](evidence/p4-micro-remnants-3x-detached.png), [Matrix sur Soil](evidence/p4-micro-eject-3x-before.png) → [vol](evidence/p4-micro-eject-3x-flight.png) → [nettoyé](evidence/p4-micro-eject-3x-expired.png), [F1](evidence/p4-micro-debug.png).

## Retest humain final — STOP après livraison

1. Reset, **Brush Soil10–20 s** : reste-t-il agréable et fluide sans poussière persistante ? **OUI**.
2. Finir un Bone avec Chisel/Pick : les derniers petits restes ressemblant à de la saleté partent-ils naturellement au Brush ? **OUI**.
3. Sur un vrai morceau Clay/Sandstone attaché, Brush ne doit rien faire : le besoin de Pick est-il clair ? **OUI**.
4. Accumuler Matrix puis souffler localement, aussi sur Soil : voit-on les miettes partir **et** le compteur baisser franchement ? **OUI**.
5. Reprendre immédiatement Chisel : de nouvelles crumbs apparaissent-elles normalement ? **OUI**.
6. Jouer10 minutes : **Chisel → Pick → Brush film/micro-restes → Blower mess**. Reste-t-il un moment où il faut deviner l'outil attendu ? **NON**.

Le Bone Film sombre doit rester identique et satisfaisant pendant toute la boucle. La sélection des micro-restes est conservatrice et la conversion peut attendre une place Matrix : si cela gêne humainement, relever le geste et le point précis, sans lancer un redesign dans cette passe. **PR #7 reste DRAFT ; aucun merge ni P5.**
