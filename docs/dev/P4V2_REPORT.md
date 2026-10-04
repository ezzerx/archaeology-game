# P4 — Passe de clôture

2026-10-04 · `prototype/p4v2-debris-physics` · [PR #7](https://github.com/ezzerx/archaeology-game/pull/7) **DRAFT, aucun merge ni P5**. Baseline d'entrée `874edc40c2da398c1693f0cd9dd4b23e7a38ad02`. Code livré : `c775186c12d60e2a2313b2e905c161da6e8310d7`.

Le retour humain valide désormais P4 Final Feel, P4-V1, les Matrix crumbs 4,5 mm avec physique et les chunks Chisel transitoires. **Cette clôture reste à retester humainement.** [Brief](P4V2_BRIEF.md) ; [restauration précédente archivée](P4V2_LOOK_REPORT.md).

## Débris visibles et budgets indépendants

| État | Budget final | Présentation/comportement |
|---|---:|---|
| Soil grains | **128** | Flocons bruns irréguliers 1,80–2,20 mm, épaisseur 14 %, hop ≤0,45 mm durant 0,18 s, puis persistants ; Brush local, Blower directionnel 2D jusqu'au bord |
| Matrix crumbs | **256** Clay + Sandstone | Look P4-V1 exact : 4,5 mm max, épaisseur 32 %, profondeur 75 %, mêmes mesh/couleurs/contraste et taille selon quantité ; physique terrain |
| Fine Dust | Aucun slot | Carte R8 et shader diffuse inchangés |

Le budget local est `(bucket_x, bucket_y, matériau)` : deux places par zone 24×24 et par matériau, au lieu d'un quota partagé. Quantité retenue 8 %, capacité 0,02. Comptage O(1), y compris les grains en vol ; refus sans éviction, surplus renvoyé à Fine Dust. 256 enregistrements physiques préalloués et un MultiMesh fixe de 384 instances. Pas de RigidBody ni de reconstruction de mesh.

Les grains Soil n'ont plus une taille presque nulle lorsque la quantité retenue est faible. Leur variation déterministe ne consomme pas le RNG des éclats/audio. Le tableau F1 sépare Soil, Matrix, Clay/Stone, mouvement/sommeil et film ; R réinitialise tout.

### Mesures de production

Fixture Brush : outil baseline, 300 ticks à 60 Hz, chemin de 800 texels avec une légère courbe, 5 secondes, surface initiale Soil.

- **1 945 créations, soit 389/s ; 128 grains présents à 5 s**. Il s'agit de créations cumulées, y compris des grains nettoyés/recréés sous le Brush, pas de 389 nouveaux grains persistants par seconde.
- **977 444 tentatives de dépôt par pixel refusées au cap**, 421 328 par quota local. Ce ne sont pas autant de grains manquants : plusieurs pixels alimentent une même source 8×8. Le cap reste 128 et ne retire aucun slot Matrix.
- Fine Dust présente, aucun Soil dans TerrainDebris ; des miettes Clay peuvent apparaître quand le Brush atteint réellement la couche suivante.
- Le Blower transporte les grains avant leur sortie, puis le compteur Soil revient à zéro. Le test remplit aussi Soil 128 puis Clay 128 + Stone 128 dans les mêmes zones sans conflit.

Fixture Matrix : cinq points hors fossile, quatre vrais impacts Chisel par point, démarrage à la limite supérieure du matériau, sans Blower ni avance physique pendant la mesure de rendement.

| Mesure | Clay | Sandstone |
|---|---:|---:|
| Crumbs créées/présentes | **45** | **38** |
| Profondeur normalisée retirée, somme des cellules | 1 328,0022 | 305,1998 |
| Volume retiré équivalent, mm³ | 159 151,14 | 36 575,91 |
| Quantité visuelle retenue normalisée | 0,593645 | 0,223300 |
| Crumbs par unité retirée | 0,033885 | 0,124509 |
| Dépôts refusés, toutes causes | 7 054 | 1 582 |
| Refus au cap Matrix | 0 | 0 |

Le rendement Sandstone par volume retiré est supérieur à celui de Clay dans ce protocole. Les budgets séparés suppriment surtout le blocage auparavant possible par Soil : aucun multiplicateur Sandstone ni troisième slot local ajouté sans besoin mesuré. Le jugement « assez de miettes » reste humain.

## Blower : pop unique et poussée horizontale

| Paramètre | Avant | Maintenant |
|---|---:|---:|
| Poussée horizontale | `crumb_blower_impulse=5` m/s² | `crumb_blower_acceleration=12` m/s² |
| Vertical | lift répété 1,8 m/s², limite 0,22 m/s | `crumb_blower_pop=0,055` m/s au sol seulement |
| Vitesse horizontale max | 0,80 m/s | `crumb_blower_speed_limit=1,60` m/s |
| Traînée contact après passage | Clay14 / Stone9 s⁻¹ | 0,8 s⁻¹ pendant 0,4 s, puis friction habituelle |

Un fragment déjà en vol conserve sa vitesse verticale soumise à la gravité ; le jet ne la recharge pas. Le délai récemment soufflé évite de relancer le pop à chaque contact sous un jet tenu. Petit kick de naissance 0,035/ 0,025 m/s, gravité 0,65, contact orienté, glissement, sommeil sans expiration et nettoyage au XYZ courant conservés.

Fixture ouverte et plate : **80 miettes endormies**, 40 Clay/40 Stone, départ à 52,9–61 cm du bord de sortie, jet correctement balayé pendant **1 s**. **80 affectées, 80 éjectées, zéro restante** ; distance horizontale moyenne **56,95 cm**, max **61,00 cm** ; hauteur maximale au-dessus du support orienté **2,35 mm**. Quantité initiale 1,6 = quantité éjectée 1,6 ; sortie unique, slots libérés. Cela démontre ce cas sans obstacle, pas une garantie pour n'importe quel geste ou cavité.

## Bone Surface Dirt Film

`BoneSurfaceFilm` reçoit `FossilState.bone_cell_exposed`. Texture **RGBA8 256×160, 160 KiB**, séparée de Fine Dust : R = quantité du groupe 4×4 ; G/B = masque 16 bits des cellules fines sales. Le CPU conserve aussi les cellules déjà vues. Pas de nouvelle texture dynamique pleine résolution.

Film initial **0,85**. Soft Brush `bone_film_clear=1,0/s` avant falloff : ~0,85 s au centre, une seconde dans la petite zone testée. Autres outils : zéro. Film nettoyé avant l'excavation du tick, donc une révélation nouvelle n'est pas immédiatement effacée. Les événements incluent `bone_film_cleared` et maintiennent l'audio Brush même sur film seul ; aucune nouvelle famille sonore ni émission Matrix.

Une cellule fine déjà propre conserve son bit éteint même si sa voisine se révèle. Une cellule nouvelle dans un groupe encore partiellement sale partage la quantité restante du groupe, sans recharger les voisines ; un groupe entièrement propre crée une nouvelle cohorte de film à 0,85. C'est la limite spatiale assumée du stockage compact. Reset réarme exposition/film.

Shader : patches beige/brun fins sur l'ivoire existant, rugosité accrue, spéculaire atténué. L'identité Bone reste visible. **Exposure ≠ Cleanliness ≠ Condition** ; aucun film dans les décisions de plafonds, protection ou dégâts.

## Precision Pick — baseline humaine finale P4

Addendum humain positif : **radius 11,0 / power 0,44 / falloff 1,75**, remplace 7/ 0,24/ 1,50. Cadence **6 Hz**, `bone_damage=0`, efficacités **0,30/ 1,00/ 1,50** inchangées. **P4 human-validated baseline — final fine tuning still deferred to P7.**

Chisel = matrice en masse/fracture/chunks ; Pick = finition structurelle rapide et précise autour de Bone ; Brush = film adhérent et mess ; Blower = débris/Dust libres. Le Pick reste limité à son disque de **373 cellules**, rayon moitié de Chisel donc quart de sa surface, sans plaques de fracture ni gros chunks. Il ne nettoie pas le film. Retrait central observé par impact : **0,146667 Clay / 0,0825 Sandstone**. Le banc six Pick contre cinq Chisel retire 49,0874 contre 218,9618 unités, soit **4,46×** pour Chisel. L'ancienne assertion « >10× » encodait la baseline abandonnée ; elle est remplacée par le footprint exact, les nouvelles valeurs humaines et la supériorité mesurée de Chisel en volume.

## Vérification et performance

- **1 825 contrôles fonctionnels**, zéro échec au passage final avec Pick humain (historique +41 clôture, +2 assertions Pick). Rejeux V1/V2 et neuf empreintes géologiques conservés.
- **13 contrôles GPU clôture**, plus **28 Final Feel +38 interfaces/contraste +32 présence Matrix +8 physique** : zéro échec. Soil distingue **373 pixels à 1× /1 101 à 3×** de la même scène Dust seule. Le film intact après Blower et ses transitions Brush ont une présence mesurée à caméra/terrain identiques.
- **36 scénarios GPU / 122 assertions**, tous verts : Matrix 128/192/256, Soil 128 plein, sommeil/mouvement/Blower/cavité/Brush ; Soil 128/192 avec Matrix 256 en mouvement, Brush film sur grande zone exposée, à 1×/3×. Godot 4.7.2 Compatibility, RTX 5080, Ryzen7 9800X3D, 1920×1080, cap 240/physique 60 Hz. Chaque cas chronométré 3 s ; setup et captures exclus. Cas mouvement/cavité relancent les mêmes enregistrements chaque seconde pour maintenir la charge. Les positions groupées constituent un stress de jet/cleanup ; les sondes de relief sont aussi comparées exactement au sampler canonique sur 500 points/fixture.
- **199,83–240,03 FPS**, minimum sur 1 s **180,35 FPS**, pire **P95 frame 14,896 ms** ; **frame isolée max 21,099 ms** sur Brush Soil +256 Matrix à 3×. Pas de baisse soutenue sous 60 ; le pic isolé reste explicitement hors 16,67 ms.
- Noyau physique : P95 max **7 335 µs**, max **8 286 µs**, ≤2 560 sondes/tick dans ces scénarios ; MultiMesh P95 max 312 µs, max 1 509 µs. Le cache terrain est borné aux sommets interrogés et vidé chaque tick, sans influencer la géologie ni le prochain creusement.
- Film : **142 uploads** dans chacun des cas Brush ; soumission+préparation image P95 **31 µs à 1× /62 µs à 3×**, max 41/124 µs ; frame P95 **7,685 /9,228 ms** avec les deux budgets remplis. Cela mesure la soumission CPU, pas un chronométrage GPU isolé.
- Comparaison Soil : 128 →192 passe aussi le budget ; P95 Brush 1×13,684 →14,024 ms, 3×14,896 →14,355 ms. Écart variable non causal sur cette machine non isolée. **128 retenu pour une présence légère**, avec déjà 128 grains visibles après 5 s, plutôt que pour une prétendue supériorité de FPS.
- Premier passage archivé : **4/36 cas hors budget** (Brush Soil 128/192 +Matrix 256), P95 jusqu'à 27,855 ms, minimum 1 s 31,61 FPS. Refus Soil accélérés, marquage dirty par série de pixels et cache de sommets par tick corrigent cette charge. Le test compare les quantités/overflow/dirty keys exacts avec le chemin non groupé et les hauteurs au relief de référence. Tous les chiffres ci-dessus sont du passage final ; les échecs initiaux ne sont pas masqués.
- Mesures locales, éditeur/jeu utilisateur laissés ouverts ; pas une garantie pour toutes les machines. Les anciens 60 benchmarks complets ne sont pas rejoués : toute la régression fonctionnelle, les visuels affectés, les 36 cas de clôture et les 6 cas Pick le sont.

Six cas Pick humain (Bone/Clay/Stone, 1×/3×) : **239.86–239.87 FPS**, P95 frame max **4.573 ms**, frame max **7.466 ms**, 36 impacts par 6 s, zéro chunk/marque de fracture/dégât. [Preuve Pick](evidence/p4-closure-pick-human-benchmark.json).

Preuves : [fonctionnel](evidence/p4-closure-tests.json), [visuel](evidence/p4-closure-visual.json), [performance finale](evidence/p4-closure-benchmark.json), [premier passage avant optimisation](evidence/p4-closure-benchmark-before-optimization.json). Commande reproductible complète : `tests/check_p4v2.ps1 -GodotBin <Godot4.7.2> -Graphical` ; banc Pick ciblé : `--script res://tests/run_p4_benchmark.gd -- --pick-only`.

## Captures reproductibles

Séquence Bone à 3× : [sale](evidence/p4-closure-bone-3x-dirty.png) → [après Blower](evidence/p4-closure-bone-3x-blown.png) → [Brush partiel, 0,4 s](evidence/p4-closure-bone-3x-brushed.png) → [propre](evidence/p4-closure-bone-3x-clean.png). Même terrain et caméra, nouvelle découverte centrale, aucun changement de Condition.

À 1× : [sale](evidence/p4-closure-bone-1x-dirty.png), [Blower](evidence/p4-closure-bone-1x-blown.png), [Brush partiel](evidence/p4-closure-bone-1x-brushed.png), [propre](evidence/p4-closure-bone-1x-clean.png).

Soil après 5 s : [grains + Dust 1×](evidence/p4-closure-soil-1x-grains-dust.png), [3×](evidence/p4-closure-soil-3x-grains-dust.png), [vol sous Blower](evidence/p4-closure-soil-3x-blowing.png), [après nettoyage](evidence/p4-closure-soil-3x-blown.png). [F1 séparé](evidence/p4-closure-debug.png).

## Retest humain — cible OUI partout

Reset avant chaque séquence ; tester 1× et zoom de travail.

1. **Soil** : Brush une grande zone 5–10 s. « Est-ce que je vois maintenant à la fois de la poussière ET des petits grains de terre ? » Puis Blower : « Est-ce que les grains disparaissent/s'envolent clairement ? »
2. **Indépendance** : atteindre Clay/Sandstone sans nettoyer Soil. « Les Matrix crumbs continuent-elles à apparaître normalement ? » Vérifier les deux compteurs F1.
3. **Sandstone / cap** : « Est-ce qu'il y a assez de petites miettes visibles à nettoyer ? La scène gagne-t-elle en saleté sans devenir illisible ? »
4. **Blower Matrix** : balayage dirigé vers un bord. « Partent-elles réellement au loin/hors du bloc, plutôt que de léviter puis retomber à côté ? » Le compteur doit baisser.
5. **Découverte Bone** : « Ressemble-t-il immédiatement à un fossile sale, tout en restant clairement identifiable comme Bone ? »
6. **Blower Bone** : « Est-il encore visiblement sale après le Blower ? »
7. **Brush Bone** : « Nettoyer progressivement l'os est-il satisfaisant, avec un avant/après clair et l'audio continu ? »
8. **Boucle et nouveau Pick 11/ 0,44/ 1,75** : découverte → Brush Film → Pick matrice attachée → Bone propre. « Cette séquence paraît-elle naturelle et satisfaisante ? »
9. **10–15 min** : Chisel/debris/Blower agréables, Brush/Pick utiles, verticalité préservée, aucun blocage FPS.

**STOP. PR #7 reste DRAFT ; P4 DONE, merge et P5 attendent une nouvelle autorisation humaine.** Le `project.godot` local préexistant est préservé hors commits.
