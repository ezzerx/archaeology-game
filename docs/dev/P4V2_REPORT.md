# P4 — Dernière clôture : Soil dust-only, Matrix et préparation Bone

2026-10-04 · `prototype/p4v2-debris-physics` · [PR #7](https://github.com/ezzerx/archaeology-game/pull/7) **DRAFT, aucun merge ni P5**. Baseline d’entrée : `491934e1dae46c6c980a325e2d73f4aaee58cac6`.

Les retours humains valident le look Matrix 4,5 mm, sa physique légère, le spectacle Chisel, le gameplay Bone Film et le Pick **11 / 0,44 / 1,75**. Cette dernière passe simplifie Soil et corrige la présence/évacuation Matrix ainsi que la teinte du film. **Le retest humain de cette passe reste à faire.** [Brief courant](P4V2_BRIEF.md), [première clôture archivée](P4V2_FIRST_CLOSURE_REPORT.md).

## Soil : suppression complète des grains

**Soil particles removed for now; Soil uses dust-only feedback.** La décision remplace l’essai des grains visibles : plus de génération persistante, de cap Soil, de hop, de pool GPU Soil ni d’émission transitoire Soil. Le chemin structurel Soil ne passe plus par l’admission des miettes à chaque pixel ; toute la quantité non structurelle concernée retourne à Fine Dust. La carte R8, sa présentation et son nettoyage Brush/Blower restent les mêmes.

Le MultiMesh persistant passe de **384 à 256 instances réservées** ; le pool transitoire Soil de 48 instances disparaît aussi. Aucun nouveau nœud, collider ou mesh dynamique. Les tableaux communs gardent les IDs matériaux historiques ; leur index0 est inutilisé pour les débris, sans compteur Soil affiché.

Fixture réelle de 5 s de Brush : **0 grain créé, 0 visible, 0 tentative Soil au cap**, Fine Dust présente. Quand le Brush atteint la Clay, des miettes Clay apparaissent normalement. Soil Dust ne réserve aucune place Matrix.

## Matrix : fréquence accrue, même look et physique

| Paramètre | Avant | Maintenant |
|---|---:|---:|
| Places Clay par zone 24×24 | 2 | **3** |
| Places Sandstone par zone 24×24 | 2 | **4** |
| Cap global Clay + Sandstone | 256 | 256 |
| Rétention / capacité par miette | 8 % / 0,02 | inchangées |
| Taille maximale | 4,5 mm | inchangée |

Mesh irrégulier, couleurs, contraste, proportions32 %/75 %, taille selon quantité, kick initial0,035 m/s latéral +0,025 vertical, gravité0,65, contact avec relief, settle/sleep sans expiration restent conservés. Les chunks Chisel gardent leur spectacle3–6 mm et leur courte durée ; aucun retuning outil ni géologique.

Mesure A/B avec le **même retrait structurel byte-exact**, cinq points hors fossile, quatre impacts Chisel par point et matériau, aucun cap atteint :

| Mesure | Clay | Sandstone |
|---|---:|---:|
| Crumbs avant → après | **45→66 (+46,7 %)** | **38→65 (+71,1 %)** |
| Profondeur normalisée retirée, somme | 1 328,0022 | 305,1998 |
| Volume équivalent retiré, mm³ | 159 151,14 | 36 575,91 |
| Crumbs / unité retirée avant → après | 0,033885→**0,049699** | 0,124509→**0,212975** |
| Refus au cap | **0** | **0** |
| Refus locaux, tentatives de dépôt par pixel | 4 591 | 329 |

Les refus sont des tentatives par pixel, pas autant de miettes manquantes. Ce protocole mesure le rendement, pas une promesse de nombre constant pour chaque geste. La quantité suffisante à l’écran reste un verdict humain.

## Blower : élan jusqu’au vrai bord et budget libéré

Le code retirait déjà le state à la frontière ; le problème était l’élan trop court une fois la miette sortie du rayon du jet. La traînée récemment soufflée passe de **0,8 à 0,2 s⁻¹**, sa durée de **0,4 à 2 s**. Pop unique au sol0,055 m/s, accélération horizontale12 m/s², vitesse max1,6 m/s inchangés. Gravité active, aucun lift répété, aucune suppression arbitraire au centre ni disparition au bout d’un timer : le timer rétablit seulement la friction normale.

- **Régression ciblée, court balayage central de0,5 s puis plus de jet** : ancien profil **0/20 sorties,20 restantes** ; nouveau **20/20 sorties,0 restante** après3 s de transport.
- Balayage ouvert historique de1 s : **80/80 sorties**, déplacement moyen56,95 cm, soulèvement max2,35 mm, quantité conservée jusqu’au bord.
- **Relief de production, cap plein réparti sur ses sources** : balayage natif de15 s +3 s de transport, **256→0**. Chaque événement est au bord réel, unique ; compteurs logique/physique cohérents. De nouvelles frappes Chisel génèrent immédiatement des miettes ; un remplissage supplémentaire réutilise les256 slots.
- Les benchmarks GPU Blower à1×/3× passent aussi de256 à0. Le budget n’est jamais libéré avant le franchissement réel, sauf nettoyage explicite Brush.

Une miette seulement effleurée ou un geste mal orienté peut encore se poser dans le bloc : cette passe n’ajoute ni attraction automatique vers un bord ni physique de collision volumétrique complète. Le modèle de relief reste le heightfield validé.

## Bone Film : brun plus sombre, identité Bone conservée

La seule modification de film en production est son multiplicateur de teinte : **(0,66;0,56;0,40)→(0,32;0,25;0,19)**, appliqué à l’ivoire dans les patches existants. Couverture, masque, rugosité, spéculaire et quantité initiale0,85 inchangés. Des zones ivoire restent visibles entre les taches terreuses ; l’inspection des captures montre une séparation avec le Sandstone jaune environnant.

A/B GPU à caméra/terrain/film identiques : **53 694 / 277 940 pixels plus sombres** à1×/3×, aucun éclaircissement significatif. Le nettoyage progressif change6 141 /55 373 pixels ; le nettoyage complet61 443 /320 025. Ces mesures prouvent le changement et le contraste Brush, pas la préférence visuelle humaine.

Brush seul enlève le film, en environ1 s au centre. Blower laisse le film byte-exact, Pick/Chisel ne le nettoient pas. Audio Brush sur film seul, zéro émission Matrix par ce nettoyage, Exposure/Condition/protections inchangées. **Exposure ≠ Cleanliness ≠ Condition.**

Séquence3× : [sale](evidence/p4-final-bone-3x-dirty.png) → [Blower](evidence/p4-final-bone-3x-blown.png) → [Brush partiel](evidence/p4-final-bone-3x-brushed.png) → [propre](evidence/p4-final-bone-3x-clean.png). [Ancienne teinte au même état](evidence/p4-final-bone-3x-old-tint-reference.png). Soil : [Dust seule1×](evidence/p4-final-soil-1x-dust-only.png), [3×](evidence/p4-final-soil-3x-dust-only.png). [F1 Matrix uniquement](evidence/p4-final-closure-debug.png).

## Performance et vérifications

Godot4.7.2 Compatibility, RTX5080, Ryzen7 9800X3D,1920×1080, cap240 FPS, physique60 Hz. **16 scénarios de6 s,58 assertions,0 échec**, setup et captures exclus du chronométrage ; travail réel à60 Hz, rendu/FX actifs. Les gestes Chisel utilisent la cadence4,5 Hz. La fixture Soil descend assez pour atteindre ponctuellement Clay : les60 miettes finales sont de la Clay, pas du Soil.

| Geste | FPS moyens | P95 frame ms | Max frame ms | Matrix début→fin / cap |
|---|---:|---:|---:|---:|
| Brush Soil 1× | 239.68 | 9.868 | 11.411 | 0→60 / 256 |
| Brush Soil 3× | 239.68 | 9.874 | 11.804 | 0→60 / 256 |
| Chisel Clay 1× | 239.85 | 4.659 | 10.511 | 0→87 / 256 |
| Chisel Clay 3× | 239.85 | 4.660 | 10.415 | 0→87 / 256 |
| Chisel Sandstone 1× | 239.85 | 4.698 | 9.585 | 0→100 / 256 |
| Chisel Sandstone 3× | 239.85 | 4.688 | 9.739 | 0→100 / 256 |
| Blower, Matrix plein 1× | 239.89 | 4.332 | 9.066 | 256→0 / 256 |
| Blower, Matrix plein 3× | 239.89 | 4.360 | 9.012 | 256→0 / 256 |
| Brush film Bone 1× | 239.82 | 6.214 | 7.360 | 0→0 / 256 |
| Brush film Bone 3× | 239.82 | 6.228 | 6.740 | 0→0 / 256 |

Stress supplémentaires à256 miettes : sommeil, mouvement et cavité à1×/3×, tous verts ; P95 maximal8,277 ms. Ensemble16 cas : **239,68–239,89 FPS**, minimum sur1 s **238,63 FPS**, P95 max **9,874 ms**, frame max **11,804 ms**. Upload CPU film P95 :30/29 µs à 1×/3×. Pas de chronomètre GPU isolé.

Le gain structurel est la suppression de128 instances persistantes réservées,48 transitoires, de l’admission Soil et de son animation. Les anciens chiffres de stress Soil+Matrix n’utilisent pas exactement le même protocole : **aucun pourcentage de gain FPS A/B n’est revendiqué**. Mesures locales courtes, pas une garantie sur toutes machines ou sur une session longue.

Régressions : **1 831 contrôles fonctionnels uniques**, dont47 de clôture ; relectures V1/V2 dans des processus distincts identiques. Suite complète exécutée avant l’ajout du dernier test A/B Blower, puis clôture47 relancée verte. Tests natifs Pick40, protection par composant72, Condition100/97/97/94, verticalité/cartes exactes, film et masses conservées. Les anciens oracles de grains Soil et de quota2/2 sont remplacés par les nouveaux contrats explicites ; les oracles géométriques et outils ne sont pas relâchés.

GPU : **119 contrôles verts** — 13 de clôture, 28 Final Feel, 38 interfaces V1.2, 32 présence Matrix ON/OFF et 8 séquence physique. Les autres benchmarks historiques longs ne sont pas relancés. Le test technique ne valide pas le plaisir.

Preuves : [index de vérification](evidence/p4-final-verification.json), [fonctionnel](evidence/p4-final-closure-tests.json), [benchmark16 cas](evidence/p4-final-closure-benchmark.json), [comparaisons GPU](evidence/p4-final-closure-visual.json). `project.godot` préexistant conservé hors commits.

## Retest humain — cible OUI partout

Reset, puis tester1× et le zoom de travail :

1. **Soil** : Brush5–10 s. « Le Soil reste-t-il lisible uniquement avec la poussière, sans petites particules ? Le Brush évite-t-il les grosses baisses de FPS ? »
2. **Clay/Sandstone** : excavation réelle. « Y a-t-il maintenant assez de petites miettes visibles à nettoyer ? »
3. **Blower** : accumuler, balayer vers le bord, regarder F1, puis creuser à nouveau. « Sont-elles vraiment éjectées hors du bloc, le compteur redescend-il et de nouvelles miettes apparaissent-elles ? »
4. **Dirty Bone** : révéler puis souffler. « L’os sale se distingue-t-il clairement de la Sandstone tout en restant identifiable ? »
5. **Préparation** : découverte→Brush film→Pick restes attachés→Bone propre. « Cette boucle est-elle naturelle et satisfaisante ? »

Pick natif **11 /0,44 /1,75**,6 Hz, dégâts0, efficacités inchangées. **P4 human-validated baseline — final fine tuning still deferred to P7.** Aucun gros chunk ni fracture Chisel pour Pick.

**STOP. PR #7 reste DRAFT. Aucun merge ni P5 sans nouvelle autorisation.**
