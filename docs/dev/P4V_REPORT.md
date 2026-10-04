# P4-V1.1 — Effort-aware Verticality

2026-10-04. Branche `prototype/p4v-verticality`, [PR #6](https://github.com/ezzerx/archaeology-game/pull/6) **brouillon, non mergée**. Source de vérité : [P4V_BRIEF](P4V_BRIEF.md), section V1.1. **Antoine valide le principe de verticalité V1** ; cette correction réduit les colonnes Sandstone trop longues. Le ressenti de V1.1 attend un nouveau test humain.

## V1.1 — correction et formule

Référence BEFORE : **`122e9b1cf6dfacad721f9af240ef30592de8491c`**. Seule la formule d'épaisseur Clay change ; l'interface Clay/Sandstone descend largement pour remplacer une partie de la matière la plus coûteuse. Le helper reste une fonction pure de l'UV normalisé, évaluée à la construction des cartes statiques.

Code et tests AFTER : **`997132ba6297c065903f0b0cdaba05f416bf7166`**. Le commit de documentation suivant conserve ce code et ajoute les preuves de cette exécution complète.

Pour `S(a,b,x) = smoothstep(a,b,x)` :

```text
nappe = S(0, 0.20, u) × (1 − S(0.80, 1, u)) × (1 − 0.55v)
lentille_haute = ((u−0.53)/0.20)² + ((v−0.20)/0.22)²
pli_bas = ((u−0.42)/0.25)² + ((v−0.67)/0.28)²
épaisseur_Clay = 0.11 + 0.19 × nappe
                + 0.12 × exp(−lentille_haute) + 0.04 × exp(−pli_bas)
clay_bottom = soil_bottom − clamp(épaisseur_Clay, 0.08, soil_bottom−0.08)
```

Les transitions s'étalent sur des centaines de texels : nappe avec épaules douces, gradient et deux lobes larges. **Aucune donnée Bone n'entre dans cette formule**, aucun clamp à une distance du fossile ni correction par cellule. Les cellules osseuses servent uniquement à valider le budget sur la population entière. Le champ Soil, le champ d'enfouissement et leurs garde-fous restent exacts.

## V1.1 — mesures BEFORE / AFTER

**32 290 cellules Bone**, cartes production float32 à 1024×640, profondeur physique 102 mm. Le BEFORE a été exporté avant modification, puis reproduit avec un profil V1 figé dans `tests/fixtures/p4v1_profile.gd`. Médiane : moyenne des deux valeurs centrales ; P90/P95 : rang supérieur `ceil(n×p)−1`, sans interpolation. [Distributions complètes et trois résolutions](evidence/p4v11-effort-tests.json).

| Mesure | Min | Médiane | P90 | P95 | Max |
|---|---:|---:|---:|---:|---:|
| Sandstone BEFORE, mm | 1,462 | 23,279 | 29,706 | 31,476 | 36,941 |
| Sandstone AFTER, mm | **2,139** | **11,588** | **16,147** | **17,124** | **21,494** |
| Hard work index BEFORE | 113,692 | 174,183 | 201,954 | 207,472 | 231,881 |
| Hard work index AFTER | **98,983** | **147,283** | **170,325** | **175,699** | **199,648** |

Le P95 Sandstone baisse de **45,6 %**, son maximum de **41,8 %**. **90,11 %** des cellules ont 5–18 mm de Sandstone, contre 32,96 % auparavant. L'effort baisse de **15,4 % à la médiane**, **15,3 % au P95** et **13,9 % au maximum**. Les valeurs restent variées ; aucune mise à niveau de toutes les colonnes.

L'oracle lit les ressources réelles : **Clay 3/1 =3 ; Sandstone 8/1,5 =5,333…**, soit 1,78 fois le coût par mm de Clay. Il additionne seulement les épaisseurs **au-dessus de Bone**, depuis le bloc intact. Si Bone est dans Clay : `Clay_mm = max(0, soil_bottom−max(clay_bottom,bone_ceiling))×102` ; le Sandstone vaut zéro. **Ce n'est pas une prédiction de durée** : Soil, puissance, cadence, fracture, geste et nettoyage ne sont pas intégrés. F1 affiche cet indice local ; aucun changement de calcul de retrait.

| Géométrie | BEFORE | AFTER |
|---|---:|---:|
| Bone min / max depuis le top | 55,348 / 85,337 mm | **55,348 / 85,337 mm, identique** |
| Amplitude Bone | 29,989 mm | **29,989 mm, identique** |
| Soil min / max, bloc entier | 16,320 / 43,860 mm | **identique** |
| Clay min / max, bloc entier | 11,220 / 37,740 mm | **11,225 / 40,980 mm** |
| Clay médiane, bloc entier | 11,622 mm | **25,119 mm** |

Le canal Soil et la carte Bone sont identiques à V1 sur les trois résolutions. SHA-256 Bone : `1f1b9622b3aecb19cefb3b6a3266469c5ac170cf7579a695219fdee57ad8d73e` ; IDs : `9f36172b7b6924c288c089dd6736709f1bcec831adb8743b623bb3e759afca21`. Totaux toujours **7 756 Skull / 7 243 Spine / 10 771 Ribs / 6 520 Hind Limb**.

### A / B / C, mm sauf effort

| Zone | Soil avant = après | Clay avant → après | Stone avant → après | Bone avant = après | Effort avant → après |
|---|---:|---:|---:|---:|---:|
| A Skull `(250,230)` | 16,32 | 12,73 → **28,43** | 27,59 → **11,89** | **56,64** | 185,35 → **148,70** |
| B Spine `(510,307)` | 31,64 | 27,61 → **30,17** | 7,44 → **4,89** | **66,69** | 122,52 → **116,56** |
| C Hind Limb `(646,441)` | 43,19 | 13,53 → **25,30** | 22,04 → **10,27** | **78,75** | 158,13 → **130,67** |

A/C entrent dans la plage indicative 10–18 mm. B reste la passe Stone courte ; ses 4,89 mm ne sont pas forcés à 7 mm, car le budget global et la douceur du champ priment. Les chemins Soil, Clay, Sandstone et Bone restent distincts.

## V1.1 — vérification et performance

Commande complète exécutée avec succès, sans erreur de script/import/shader : `tests/check_p4v.ps1 -GodotBin <Godot 4.7.2 console> -Graphical`. **1 654 contrôles fonctionnels uniques** : 1 517 P0–P4 +90 V1 (dont trois contrôles du nouvel affichage F1) +47 effort V1.1. Les 90 contrôles V1 sont rejoués dans un processus distinct : **neuf empreintes identiques**. **90 contrôles visuels P4 +60 scénarios de performance**, zéro échec. [Journal complet](evidence/p4v11-validation.txt) · [Invariants V1](evidence/p4v11-tests.json) · [Distributions V1.1](evidence/p4v11-effort-tests.json).

Les budgets sont vérifiés à 1024×640, 512×320 et 256×160 : P95 Stone ≤18 mm, max ≤22 mm, au moins 80 % des cellules dans 5–18 mm ; effort P95 ≤180 et max ≤205, tous deux réduits d'au moins 10 % par rapport à V1. Minimums, interfaces, champs lisses, plafonds Bone exacts et amplitudes restent contrôlés. Les 72 tests de contact reconfirment **tik/100 → DING/97 → tik/97 → DING/94**, reset et outils sûrs compris. [Preuve de protection](evidence/p4v11-component-contact.json).

**CPU/GPU/picking** : 250 065 pixels dans l'oracle V1.1 (194 955 autour de Bone +55 110 sur la coupe macro). Cette coupe contient 24 565 Soil /26 286 Clay /4 259 Sandstone ; maximum couleur 0,010883, aucune alternative raster. Autour de Bone : maximum hauteur corrigé 0,004685, mêmes deux cas d'occlusion à 1× que V1, erreur brute 0,386497 avant vérification spatiale. Seuils historiques conservés : hauteur 0,01, couleur 0,02, localisation ±0,01 texel ; aucun pixel omis. Textures uploadées exactes. Oracle natif rasant : **1,650 µm / seuil 5 µm** ; 387 rayons de pan : **0,194 µm**. [GPU et benchmarks V1.1](evidence/p4v11-benchmark.json) · [Régression GPU P3](evidence/p4v11-p3-gpu.json).

Machine et protocole conservés : **Godot 4.7.2, RTX 5080 / Ryzen 7 9800X3D**, Compatibility, 1920×1080, cap 240 FPS / physique 60 Hz. Série verticale : A/C ×1×/3× ×Brush/Chisel Clay/Chisel Stone/Pick/Blower, rendu/FX actifs, audio généré mais bus muet, préparation exclue. Brush 12 s, autres 6 s ; exactement 27 impacts Chisel /36 Pick pour les maintiens de six secondes. F1 masqué pendant les mesures.

| Série | Scénarios | FPS moyens (plage) | Pire P95 frame | Plus longue frame |
|---|---:|---:|---:|---:|
| Verticalité A/C | 20 | **221,35–239,87** | **13,251 ms** | **17,484 ms** |
| Régression Brush, dont gestes de 30 s | 12 | 215,74–228,74 | 13,754 ms | 19,055 ms |
| Régression P4 | 28 | 218,23–239,97 | 13,461 ms | 17,877 ms |

Verticalité : minimum sur une seconde **212,28 FPS**, minimum instantané **57,20 FPS**. Le débit soutenu et le P95 passent ; quelques frames isolées dépassent 16,67 ms. Picking : pire P95 **0,146 ms**, maximum **0,323 ms**. Construction statique mesurée : **303,38 ms couches +44,49 ms fossile**, une fois au chargement ; aucun coût de profil par tick. Proxies toujours ≤12 sondes/48 lectures et zéro reconstruction de mesh. [Brush](evidence/p4v11-brush-regression.json) · [P4](evidence/p4v11-p4-benchmark.json) · [Synthèse chiffrée](evidence/p4v11-performance-summary.json).

Captures inspectées : [F1, effort A =148,7](evidence/p4v11-debug-shallow.png), [coupe macro F2](evidence/p4v11-macro-layers.png), [Chisel Stone A à 3×](evidence/p4v11-A_chisel_stone_3x.png), [Chisel Stone C à 3×](evidence/p4v11-C_chisel_stone_3x.png). Les grandes découpes rectangulaires sont les préparations de benchmark ; elles ne représentent pas un geste humain. F1 reste au-dessus de la barre d'outils à 1080p.

Les deux anciennes assertions de contraste des fixtures V1 sont actualisées : B n'exige plus une Clay 10 mm plus épaisse que A/C, ce qui contredirait la redistribution demandée. Le contraste Stone reste vérifié et les nouveaux budgets portent sur **toutes** les cellules Bone. Les seuils CPU/GPU/picking, minimums de couches, douceur, accord entre résolutions, fracture et protection restent inchangés.

Les ressources `ToolDefinition`, résistances et réactions, la fracture, les shaders, le picking, le contrôleur, les proxies et les sons n'ont aucune modification dans V1.1. Calcul statique uniquement ; la métrique F1 effectue une lecture locale O(1), sans carte ni simulation supplémentaire. `project.godot` conserve exactement la modification locale antérieure et reste exclu des commits.

## V1.1 — test humain demandé

Lancer avec Godot 4.7.2 (**F5**), **R** pour reset, puis jouer librement autour du squelette avec les réglages P4. F1 permet de repérer A/B/C et de lire l'indice ; le masquer pour juger le ressenti.

1. « Est-ce que certaines zones Sandstone ressemblent encore à un mur trop long ? » → **NON**.
2. « Est-ce que je sens toujours clairement des profondeurs différentes ? » → **OUI**.
3. « Est-ce que les zones profondes me demandent plus de travail sans devenir fastidieuses ? » → **OUI**.
4. « Est-ce que Sandstone reste clairement la matière dure ? » → **OUI**.
5. « Après le Skull, est-ce que la profondeur du reste reste imprévisible ? » → **OUI**.

Règle future confirmée : **“Verticality / generation must be effort-aware, not depth-only.”** Toute future seed devra respecter des budgets de travail pondérés par matériau en plus des invariants géométriques. Les seuils ci-dessus sont des budgets prototype P4-V, pas le tuning final P7. Aucun générateur n'est ajouté.

**STOP pour Antoine. PR #6 reste DRAFT ; aucun merge, P4-V2, procgen ou P5.**

## Historique V1 — preuves avant la correction V1.1

Les sections suivantes décrivent la livraison V1 de référence, ses formules et ses anciennes mesures. Le principe a depuis été validé humainement ; **la formule Clay, les valeurs et la checklist courantes sont celles de V1.1 ci-dessus**. Base P4 : `7ae0fec3c004d207c99f4713111a240f8d5f2e9a`.

Implémentation et tests : `e18cf1262e12738ba09a52761395e01a27a96970` ; isolation du harnais graphique : `c8dc92c2c6f7c2da8a865ffa3a08146184812b5a`. Le commit de documentation conserve ce code et ajoute le présent rapport, les preuves et le contexte de reprise.

### Implémentation et profil

`BlockVerticalityProfile` contient deux fonctions pures de l’UV normalisé : limites Soil/Clay et offset d’enfouissement. Un seul bloc B-17 écrit à la main, sans seed, bruit cellulaire, variante ou générateur.

Pour `u,v ∈ [0,1]`, `S(a,b,x) = smoothstep(a,b,x)` :

```text
pente = 0.65u + 0.35v + 0.05 sin(π(u−v))
épaisseur Soil = 0.16 + 0.27 S(0.28, 0.68, pente)
lentille = ((u−0.53)/0.17)² + ((v−0.30)/0.27)²
épaisseur Clay = 0.11 + 0.26 exp(−lentille)
soil_bottom = 1 − épaisseur Soil
clay_bottom = soil_bottom − épaisseur Clay

inclinaison = S(0.28, 0.68, 0.70u + 0.30v)
offset Bone = 0.095 − 0.18 inclinaison + 0.008 sin(2πu) sin(πv)
Bone ceiling = ancien plafond P4 + offset Bone
```

La pente diagonale du Soil atteint deux plateaux doux. La lentille Clay est indépendante : épaisse au centre supérieur, fine autour du crâne et du membre. L’enfouissement a des extrémités adoucies afin que queue/orteils ne plongent pas vers le floor. Pas de relief aléatoire par os.

Garde-fous normalisés : Soil ≥0,10 ; Clay ≥0,08 ; Sandstone jusqu’au floor ≥0,08 ; plafond Bone ≥0,08 et ≤`soil_bottom−0,06`. Les clamps osseux sont **inactifs sur le B-17 livré**, vérifiés sur toutes ses cellules à trois résolutions. La séparation minimale Bone/Soil mesurée est **31,33 mm**. Un Bone peut localement toucher la Clay : le diagnostic Sandstone est alors borné à zéro, et « Matrix below Soil » indique l’ensemble de la matrice dure restante.

Les overlaps sont résolus avec les plafonds P4 originaux, puis le même offset XY est appliqué au gagnant. C’est équivalent à translater tous les candidats avant comparaison ; un éventuel clamp ne peut pas changer leur propriété. Aucun changement d’authoring 2D.

`Stratigraphy` construit l’image RGF et `packed_limits` au démarrage ; `FossilField` construit ses plafonds/IDs et son image RGF. Reset réutilise ces cartes. Aucun champ vertical recalculé par frame ou par tick d’outil ; aucune nouvelle map dynamique, aucun mesh reconstruit en jeu. F1 effectue seulement des lectures locales et convertit avec la profondeur physique réelle du bloc, **102 mm**.

### Mesures à 1024×640

| Mesure | P4 | P4-V1 |
|---|---:|---:|
| Soil, épaisseur | petites ondulations autour de 30,6 mm | **16,32–43,86 mm** |
| Clay, épaisseur | interfaces proches de 0,70 / 0,36 | **11,22–37,74 mm** |
| Bone, profondeur depuis le top intact | **65,790–77,848 mm** | **55,348–85,337 mm** |
| Amplitude globale Bone | **12,058 mm** | **29,989 mm** |

Soil normalisé : **0,160–0,430** ; Clay : **0,110–0,370** ; plafonds Bone : **0,16336–0,45737**. Les valeurs sont des plages de prototype, sans tuning P7 implicite.

| Composant | Cellules P4 | Cellules V1 |
|---|---:|---:|
| Skull | 7 756 | 7 756 |
| Spine / Vertebrae | 7 243 | 7 243 |
| Ribs | 10 771 | 10 771 |
| Hind Limb | 6 520 | 6 520 |
| Union | **32 290** | **32 290** |

Comparaison intégrale à l’oracle figé `tests/fixtures/p4_fossil_field.gd`, extrait du commit P4 ci-dessus : **IDs et silhouette identiques octet par octet**, même pour les overlaps. SHA-256 de la carte IDs : `9f36172b7b6924c288c089dd6736709f1bcec831adb8743b623bb3e759afca21`.

### Zones humaines réelles

Coordonnées de cellule / centre du curseur, dans la map canonique. UV = `(cell + 0,5) / (1024,640)`. F1 donne ces coordonnées ; le masquer ensuite pour juger la sensation.

| Zone | Cellule | Os | Soil | Clay | Sandstone jusqu’à Bone | Bone depuis top |
|---|---|---|---:|---:|---:|---:|
| A, shallow | **(250,230)** | Skull | 16,3 mm | 12,7 mm | 27,6 mm | **56,6 mm** |
| B, medium | **(510,307)** | Spine | 31,6 mm | 27,6 mm | 7,4 mm | **66,7 mm** |
| C, deep | **(646,441)** | Hind Limb | 43,2 mm | 13,5 mm | 22,0 mm | **78,8 mm** |

B/C ont été légèrement déplacées par rapport aux suggestions pour viser des cellules réellement osseuses. La Clay centrale n’est pas une simple copie plus profonde de A ; la passe Sandstone y est beaucoup plus courte. Les premiers os n’indiquent donc plus une profondeur unique.

### Vérification

Résultats finaux : **1 604 contrôles fonctionnels uniques** (1 517 P0–P4 +87 V1), **90 contrôles visuels P4**, **60 scénarios de performance** (12 Brush +28 P4 +20 V1), **zéro échec dans les phases finales**. Les 87 contrôles V1 sont exécutés une seconde fois dans un nouveau processus ; les **neuf empreintes sont identiques**. Les phases déjà vertes n’ont pas été répétées après le correctif du seul harnais graphique. [Journal consolidé](evidence/p4v-validation.txt) · [Mesures et invariants V1](evidence/p4v-tests.json) · [Protection par composant](evidence/p4v-component-contact.json).

- Trois résolutions : 1024×640, 512×320, 256×160 ; nouvelles instances et resets exacts. Deux processus séparés comparent neuf empreintes.
- Ordre et minimums contrôlés sur chaque cellule ; amplitudes minimales significatives ; champs lisses, première/seconde différences bornées ; même offset additif sous tous les os.
- 361 UV par comparaison de résolution, tolérance **0,00008 normalisé**, soit 0,00816 mm. Offset osseux également comparé à UV commun dans les trois vrais os.
- Tous les composants sont exposables intégralement par le chemin d’édition de production, sans cellule sous le floor ni os dans Soil.
- Six cas de fracture avec les paramètres Chisel verrouillés : Clay fine/épaisse, Sandstone shallow/deep, cavité traversant Soil/Clay puis Clay/Sandstone inclinés. Chaque cellule reste au-dessus de l’interface de sa matière initiale et de Bone.
- Régression Bone : **tik/100 → DING/97 → tik/97 → DING/94** ; autres côtes/vertèbres, reveal caché, reset et outils sûrs également vérifiés.
- F1 : matière courante, Soil/Clay en mm, Bone depuis top, Sandstone et matrice dure jusqu’à Bone, tiret sans fossile. F2 et les quatre vues existantes conservés.
- Les ressources outils/réactions, la fracture, les 28 WAV historiques, Dust, budgets de débris, protections, caméra et contrôleur sont préservés.

### Accord CPU/GPU et picking

Une précision de géométrie latente est devenue visible sur les rayons rasants. `PlaneMesh` construit X/Z par additions float32 successives ([source Godot 4.7](https://github.com/godotengine/godot/blob/4.7-stable/scene/resources/3d/primitive_meshes.cpp#L1354)), alors que le picking reconstruit la grille depuis UV. Une dérive de l’ordre du micromètre peut sélectionner une autre paroi sur un rayon presque tangent.

Correctif ciblé : dans le vertex shader, X/Z de la surface sont reconstruits par `(UV−0,5) × surface_size`, comme la grille CPU. Uniforme transmis par `ExcavationBlock`, y compris pour une taille de bloc différente. Topologie, height RF, parcours DDA et nombre de triangles restent inchangés ; aucune reconstruction de mesh ni nouvelle simulation.

Le contrôle indépendant a aussi révélé une amplification de l’arrondi des produits vectoriels float32 sur ces rayons : jusqu’à 9,52 µm dans le diagnostic, au-dessus du budget historique de 5 µm. L’intersection conserve Möller–Trumbore et ses tolérances, mais calcule ses intermédiaires en scalaires float64 avant de retourner un `Vector3`. Aucun changement de logique de ciblage, de caméra ou de matière ; ce correctif numérique est inclus dans les mesures de performance finales.

Un oracle indépendant utilise la topologie/les UV natifs, le déplacement du shader et une intersection plan/barycentriques en float64. Dix rayons rasants à 1×/3× donnent un maximum de **1,650 µm**, sous le seuil historique de **5 µm** ; la dérive native X/Z mesurée sur ces cellules était de 1,414 µm. Le helper de triangle float32 ajoutait lui-même de l’erreur dans ces cas, d’où l’oracle scalaire. Les **387 rayons de pan** donnent un maximum de **0,194 µm**.

Le contrôle GPU lit réellement les pixels : 194 955 pixels autour des os à 1×/2×/3×, plus une coupe macro comportant les trois matières. Cartes de couches, RF, fossile et résidu vérifiées après upload. Les seuils historiques restent **0,01 pour la hauteur, 0,02 par canal couleur, ±0,01 texel pour la localisation d’une frontière**.

À une silhouette d’occlusion, cette dernière tolérance doit porter sur le rayon projeté : un déplacement subpixel peut échanger os et fond. Le test exige alors **un même rayon à ≤0,01 texel par axe** expliquant simultanément hauteur et couleur. Aucun pixel omis ; maxima bruts et cas concernés conservés dans le JSON. Cette vérification des frontières projetées est ajoutée à l’oracle P3 ; elle ne masque pas un désaccord étendu sur une couche.

Résultat final : **250 065 pixels** vérifiés. Coupe macro : 24 565 Soil /12 794 Clay /17 751 Sandstone, erreur couleur maximale 0,0108824, aucune alternative raster nécessaire. Autour de Bone :

| Zoom réel | Erreur hauteur maximale | Erreur couleur maximale | Alternatives d’occlusion |
|---|---:|---:|---:|
| 1× | 0,0047183 | 0,0108824 | 2 |
| 2× | 0,0047048 | 0,0108824 | 0 |
| 3× | 0,0046843 | 0,0015687 | 0 |

Les deux pixels d’occlusion à 1× ont une erreur de hauteur **brute** maximale de 0,386497 avant la vérification spatiale ; les déplacements explicatifs sont `(0,01; −0,005)` et `(−0,01; −0,01)` texel. Les alternatives historiques de frontière de composant concernent respectivement 12/1/2 pixels. Toutes les textures contrôlées sont identiques octet par octet après upload. [Données GPU complètes](evidence/p4v-benchmark.json).

### Performance

V1 : **227,73–239,87 FPS moyens** ; minimum sur une seconde **210,54 FPS** ; pire P95 **12,757 ms** ; frame maximale **18,728 ms**, soit **53,40 FPS instantanés**. Budget soutenu et P95 validés ; ce résultat ne garantit pas que chaque frame isolée dépasse 60 FPS. [Vingt scénarios et coûts détaillés](evidence/p4v-benchmark.json).

| Zone / outil | Zoom | Min FPS (1 s) | Min FPS instantané | P95 (ms) | Max frame (ms) |
|---|---:|---:|---:|---:|---:|
| A / Brush | 1× | 228,82 | 63,23 | 12,435 | 15,816 |
| A / Brush | 3× | 229,05 | 64,59 | 12,499 | 15,482 |
| A / Chisel Clay | 1× | 238,87 | 97,92 | 4,294 | 10,212 |
| A / Chisel Clay | 3× | 238,90 | 98,43 | 4,299 | 10,159 |
| A / Chisel Sandstone | 1× | 239,07 | 102,98 | 4,294 | 9,711 |
| A / Chisel Sandstone | 3× | 239,02 | 99,10 | 4,297 | 10,091 |
| A / Pick | 1× | 239,81 | 159,97 | 4,305 | 6,251 |
| A / Pick | 3× | 239,81 | 188,93 | 4,313 | 5,293 |
| A / Blower | 1× | 239,90 | 147,51 | 4,822 | 6,779 |
| A / Blower | 3× | 239,90 | 188,68 | 4,829 | 5,300 |
| C / Brush | 1× | 218,76 | 59,77 | 12,757 | 16,730 |
| C / Brush | 3× | 210,54 | 53,40 | 12,697 | 18,728 |
| C / Chisel Clay | 1× | 238,66 | 93,64 | 4,337 | 10,679 |
| C / Chisel Clay | 3× | 239,97 | 95,17 | 4,371 | 10,508 |
| C / Chisel Sandstone | 1× | 239,17 | 99,37 | 4,310 | 10,063 |
| C / Chisel Sandstone | 3× | 239,12 | 102,09 | 4,337 | 9,795 |
| C / Pick | 1× | 240,01 | 166,92 | 4,315 | 5,991 |
| C / Pick | 3× | 239,79 | 184,77 | 4,345 | 5,412 |
| C / Blower | 1× | 239,91 | 134,43 | 4,839 | 7,439 |
| C / Blower | 3× | 239,89 | 177,56 | 4,879 | 5,632 |

Machine : **RTX 5080 / Ryzen 7 9800X3D**, Godot **4.7.2**, Compatibility, 1920×1080, **cap 240 FPS / physique 60 Hz**. Vingt scénarios V1 : A/C × 1×/3× × Brush, Chisel Clay, Chisel Sandstone, Pick, Blower. Brush : 12 s par scénario ; autres : 6 s. Préparation/reset/captures exclus ; rendu, son et FX actifs, bus audio muet. Le Chisel frappe des zones préparées puis les excave réellement ; ce benchmark ne mesure pas le temps humain pour révéler tout le bloc.

Le harnais impose un maintien synthétique à pas fixe. Il conserve l’horloge entre deux ticks afin qu’une notification Windows de perte de focus ne crée pas une frappe supplémentaire en réarmant ce maintien ; le contrôleur du jeu est inchangé. Les six secondes doivent toujours produire exactement **27 Chisel / 36 Pick**. Le zoom réel est vérifié pour chaque scénario V1 et capture GPU, avec reprise bornée d’une transition interrompue au démarrage de la fenêtre.

FPS minimal présenté sur fenêtres d’une seconde, et FPS instantané minimal calculé séparément à partir de la frame maximale. Les tests imposent ≥60 FPS et P95 <16,67 ms, et vérifient un travail effectif, des chunks pour le Chisel, un nettoyage sans modification structurelle pour Blower.

La régression Brush historique ajoute **12 scénarios**, dont des passages mobiles de 30 s, à 1×/3× avec/sans proxies : **215,79–236,79 FPS moyens**, P95 maximal **13,506 ms**, frame maximale **18,142 ms** (55,12 FPS instantanés). Les états finaux avec/sans proxies sont identiques. Des frames isolées peuvent donc dépasser 16,67 ms, même quand le débit soutenu est largement supérieur à 60 FPS ; aucun retuning outil pour masquer ces pointes.

Les 28 autres scénarios P4 passent à **216,89–240,00 FPS moyens**, P95 maximal **13,483 ms**, frame maximale **16,871 ms**. [Régression Brush](evidence/p4v-brush-regression.json) · [Benchmark P4](evidence/p4v-p4-benchmark.json). Le coût total du picking V1, correctif float64 inclus, reste à **0,143 ms au pire P95**, maximum **0,327 ms** ; le surcoût arithmétique seul n’est pas isolé par un A/B.

La dernière construction statique mesurée représente **238,16 ms pour les couches +41,70 ms pour le fossile**, une fois au chargement sur cette machine. Pas de coût de profil au reset ou en interaction. F1 masqué pendant les benchmarks. Proxies toujours ≤12 sondes/48 lectures, P95 de placement ≤49 µs dans la sonde dédiée et aucun changement de mesh en jeu.

Captures inspectées : [F1 en zone A](evidence/p4v-debug-shallow.png), [coupe macro F2](evidence/p4v-macro-layers.png), [Chisel Sandstone A à 3×](evidence/p4v-A_chisel_stone_3x.png), [Chisel Sandstone C à 3×](evidence/p4v-C_chisel_stone_3x.png). Les grandes découpes rectangulaires des deux derniers exemples sont des préparations de benchmark, exclues du temps mesuré.

### Limites

- Un bloc écrit à la main, aucune conclusion sur la qualité d’un futur générateur.
- La variation et la cohérence géologique restent à juger humainement ; les seuils ne valident pas le plaisir.
- Relief heightfield, silhouettes et rendu P4 greybox conservés. Très fortes parois synthétiques et bords d’occlusion restent des cas de précision raster, explicitement mesurés.
- Pas de gravité terrain, collision, rebond physique, sliding ni impulsion physique Blower. **P4-V2 attend une validation et une autorisation séparées.**
- `project.godot` contient toujours la modification locale antérieure (suppression de la valeur physique explicite, défaut moteur toujours 60 Hz). Fichier conservé à l’octet près et exclu des commits.

### Checklist humaine exacte — A à F

Lancer la scène avec Godot 4.7.2 (**F5**). **R** pour un bloc intact. Conserver les réglages P4 ; utiliser F1 seulement pour repérer les coordonnées, puis le masquer. Garder la même session entre A/B/C afin de comparer les zones.

1. **A — SHALLOW, Skull (250,230).** Excaver avec Brush → Chisel → Pick/Blower. Noter la profondeur ressentie du Soil, de la Clay, du Sandstone et l’arrivée de Bone.
2. **B — MEDIUM, Spine (510,307).** Excaver. « Est-ce que j’ai l’impression de répéter exactement la Zone A ? » Cible : **NON**.
3. **C — DEEP, Hind Limb (646,441).** Excaver. « Est-ce que la différence de profondeur est évidente ? » Cible : **OUI**.
4. **D — PREDICTABILITY.** Après avoir trouvé le Skull, essayer de prédire les profondeurs restantes. « Le premier Bone découvert me permet-il encore de deviner facilement la profondeur du reste du squelette ? » Cible : **NON**.
5. **E — COHERENCE.** « Est-ce que ça ressemble à une géologie cohérente ou juste à du random/noise ? » Cible : **COHÉRENTE**.
6. **F — FINAL FEEL REGRESSION.** Jouer **10 minutes** normalement : Chisel toujours fun, Blower toujours fun, Pick utile, Brush fluide, Bone rules inchangées. Sur des centres déjà exposés : Skull → Skull → Ribs → Ribs doit donner **tik/100 → DING/97 → tik/97 → DING/94** après reset/révélation.

**STOP après livraison. Attendre le verdict d’Antoine. Aucun merge, P4-V2 ou P5.**

Reproduction :

```powershell
& tests/check_p4v.ps1 -GodotBin 'C:\Users\antoi\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' -Graphical
```
