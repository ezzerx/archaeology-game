# Statut canonique

- Date : **2026-10-04**.
- Projet : **ArchaeologyGame**, working title modifiable.
- Phase : **préproduction — P4/P4-V1 validés et mergés ; première P4-V2 SIMPLIFY ; look P4-V1 des miettes restauré après rejet des micro-débris, nouvel A/B humain attendu ; P5 bloqué**.
- Dépôt privé : [ezzerx/archaeology-game](https://github.com/ezzerx/archaeology-game).
- Branche canonique : `main`. P4 Final Feel mergé via [PR #5](https://github.com/ezzerx/archaeology-game/pull/5) au commit `7ae0fec3c004d207c99f4713111a240f8d5f2e9a`. P4-V1 verticality mergé via [PR #6](https://github.com/ezzerx/archaeology-game/pull/6) au commit `756cd4338285e52b7d751bc0f0e1694b7792c882`. Spike actif : `prototype/p4v2-debris-physics`, PR #7 en brouillon.
- Merge P0 : `244aba3652a03aac908b1aabe1651c3b9edb1315`.
- Merge P1 : `960642c3fc6972bdb257c96abd43b90c148e632d`.
- Merge P2 : `9b8423fedfb4723ba8b0113a23e564ba474c8bd2`.
- Merge P3 : `10a12379ab1db629380ac9697e5597aeb16a373b`.
- Dossier local initial : `C:\Users\antoi\Documents\Codex\Projects\ArchaeologyGame`.

## P0 — Validé ✅

Interaction brute, mapping souris, surface editable et debug.

## P1 — Validé ✅

Relief excavable 3D, stratigraphie, résistances et picking exact.

## P2 — Validé ✅

Soft Brush, Chisel, Air Blower, résidu debug et changements d'outils.

## P3 — Validé et mergé ✅

Validation finale humaine le **2026-10-02**.

Livré :

- Specimen B-17 caché et déterministe ;
- quatre composants osseux ;
- bone ceiling infranchissable ;
- exposition progressive ;
- premier contact protégé ;
- `Bone detected` ;
- Bone Condition technique ;
- Brush/Blower sûrs ;
- zoom orthographique **1×–3×** ancré au curseur ;
- Home = vue initiale ;
- debug : Shift+molette puissance, Ctrl+molette falloff, Alt+molette rayon ;
- cap normal **240 FPS**, physique **60 Hz** ;
- **439 checks**, zéro échec après la passe finale.

PR #4 mergée vers `main` au commit :

`10a12379ab1db629380ac9697e5597aeb16a373b`

Rapports :

- [P3_REPORT](../dev/P3_REPORT.md)
- [P3_FOSSIL_DECISION](../dev/P3_FOSSIL_DECISION.md)
- [P3_DESIGN_FIXES](../dev/P3_DESIGN_FIXES.md)

### Retours humains P3 à conserver

- Une fois l'os perçu, **l'envie de continuer à révéler est présente**.
- La lisibilité Bone / Clay reste faible en greybox : sujet P4/P6.
- Le zoom de précision est validé.
- L'équilibrage Bone Condition n'est **pas final**.
- Le Chisel actuel reste encore trop proche d'un effacement local de heightfield : P4 doit introduire une vraie réaction de matière avant de décider d'une mécanique de protection supplémentaire.
- Les valeurs de vitesse/puissance actuelles peuvent sembler lentes ; ne pas faire le tuning final avant P7, sauf nécessité de test.

## P4 — FINAL FEEL ✅

Source de vérité : [P4_FINAL_FEEL_TARGET](../dev/P4_FINAL_FEEL_TARGET.md). Micro-fix autorisé : **une protection indépendante par composant anatomique**, toujours sur cellule déjà exposée **avant** l’impact. Les baselines humaines déjà persistées, Chisel A (`42ec46d`), Blower B (`c25b44f`), mécaniques Soil/Pick et correctif FPS restent inchangés.

| Outil | Rayon | Puissance | Falloff |
|---|---:|---:|---:|
| Brush | 40 | 0.70 | 1.25 |
| Chisel | 22 | 0.64 | 2.25 |
| Blower | 60 | 0 | 1.00 |
| Pick | 7 | 0.24 | 1.50 |

**P4 human-validated baseline — tuning final deferred to P7.** Blower conserve `residue_clear = 2.5`. Cadences Chisel 4.5 Hz / Pick 6 Hz, efficacités, génération de résidus, dégâts, résistances et seuils de fracture inchangés. Valeurs disponibles au lancement/reset sans retouche debug préalable ; fonctionnement des réglages en session préservé.

Livré : éclats Chisel **3–6 mm, 1–5 par plaque cassée**, projection depuis le dessus estimé du morceau retiré, expiration **0,51–0,69 s**, pools toujours bornés. Les gros morceaux restent transitoires. Blower conserve des miettes dures visibles (**jusqu’à 4,5 mm**) transportées dans le jet puis éjectées ; dust soulevée et hook `debris_ejected` conservés. **Budgets persistants inchangés** : deux miettes par zone 24×24, rétention 8 %, capacité 0,02.

**Protection Bone par composant** : `direct_contact_consumed` est un `PackedByteArray` indexé par NONE (inutilisé), **Skull / Spine / Ribs / Hind Limb**. Maximum **quatre contacts protégés par reset**. Toutes les côtes partagent RIBS, toute la colonne partage SPINE ; aucune protection par cellule, os individuel ou zone. Snapshot `was_exposed_before_impact` conservé : révélation, même centrale, = matière / zéro dégât / aucun flag consommé. Premier Chisel sur un centre déjà visible de ce composant : petit tik, zéro dégât, flag consommé ; suivants sur ce composant : DING/−3. **Bone Condition reste globale** : Skull → Skull → Ribs → Ribs = **100 → 97 → 97 → 94**. Reset réarme les quatre ; Pick/Brush/Blower ne consomment rien. F1 affiche READY/USED dans les lignes existantes. **Baseline P4 réévaluable en P7.** Découverte/UI, exposition et 28 WAV inchangés.

**Mécanique Pick inchangée**, rayon verrouillé à 7 : clic/maintien immobile, six micro-impacts/s, puissance 0,24, efficacités 0,30/1,00/1,50 ; footprint local, interface et plafond osseux, zéro dégât provisoire P4. **Proxies conservés** : angle fixe `(0.5, 0, -0.62)`, Tip exact, Body statique déplacé verticalement, douze sondes maximum. Aucune reconstruction de mesh en jeu. Priorité fluidité ; rares petites intersections acceptées, aucun suivi des normales.

**Brush avec baselines du lock** : geste de 30 s, **235,24 FPS à 1×**, **236,17 à 3×**, P95 frame **12,264/12,202 ms**, proxy P95 **31 µs**. Coût de pose CPU borné à douze sondes/48 lectures, meshes immuables. L’ancien surcoût proxy reste corrigé ; aucune chute <10 FPS reproduite dans ces mesures. Cap 240 FPS / physique 60 Hz conservés.

Code du micro-fix : **`0c549f58d6c2c27e21251a854c2e18a39d389ee2`**. **1 517 checks fonctionnels + 90 graphiques verts**, dont 72 nouveaux couvrant les quatre composants, autre côte/vertèbre, reset et outils sûrs. Oracle GPU 194 955 pixels ; sanity de quatre cas Clay/Stone à 1×/3× : **239,86–239,87 FPS**, P95 maximal 4,325 ms. Les benchmarks longs du lock précédent ne sont pas relancés ; preuves historiques conservées. [P4_REPORT](../dev/P4_REPORT.md). **Clôture humaine et merge PR #5 confirmés ensuite par Antoine**, au commit `7ae0fec3c004d207c99f4713111a240f8d5f2e9a` ; les travaux P4-V autorisés sont décrits ci-dessous.
### Livraison initiale conservée comme historique

P4 vise à faire passer le prototype de :

> système d'excavation techniquement correct

à :

> matière qui réagit et geste qui commence à être satisfaisant.

Priorités :

- Soil granulaire ;
- Clay cohésive / plaques / chips ;
- Sandstone cassant / cracks / chunks ;
- Chisel qui frappe et casse plutôt qu'il n'efface des pixels ;
- particules / débris placeholder ;
- présence physique simple des outils ;
- audio différencié par matériau ;
- meilleure lisibilité du contact osseux ;
- réévaluation de Bone Condition **après** ces nouvelles réactions de matière.

Aucune mécanique de marge de sécurité osseuse n'est pré-autorisée.

Livraison du 2026-10-02 : stress local déterministe, fissures avant retrait, plaques Clay / petits fragments Sandstone, trois proxies, quatre familles de débris bornées et six familles audio procédurales. Le heightfield, les plafonds osseux et les commandes P3 restent l'autorité.

Vérifications : **495 checks fonctionnels** (439 historiques + 56 P4), dix scénarios graphiques 1×/3× à environ 240 FPS, P95 maximal 8,842 ms. Cap 240 FPS / physique 60 Hz. Oracle GPU P3 : 194 955 pixels, seuils historiques conservés.

Condition : sonde attentive de 1 004 impacts → 4 105 cellules osseuses, **49,87 % du crâne**, condition **100 %**. Elle reconnaît parfaitement les centres visibles ; ce n'est pas un test humain. Maintenir le Chisel sur un centre exposé inflige toujours −3 par impact. Aucun mécanisme de protection ajouté.

Le test humain initial a ensuite conduit à la passe corrective ci-dessus, puis à la clôture humaine P4 du 2026-10-04. Si un nouveau test relève un dommage jugé inévitable, documenter le geste précis avant toute protection supplémentaire.

Architecture et limites : [P4_MATERIAL_REACTION_DECISION](../dev/P4_MATERIAL_REACTION_DECISION.md).

Brief canonique :

[P4_BRIEF.md](../dev/P4_BRIEF.md)

**La validation P4 ne lance pas P5. P4-V1 a ensuite été validé ; seul le spike secondaire V2 ci-dessous est autorisé.**

## P4-V1.1 — Effort-aware Verticality : base conservée

Source de vérité : [P4V_BRIEF](../dev/P4V_BRIEF.md). Architecture, mesures, preuves et checklist : [P4V_REPORT](../dev/P4V_REPORT.md).

**Antoine valide le principe V1** mais juge certaines colonnes Sandstone trop longues. Référence avant correction : `122e9b1cf6dfacad721f9af240ef30592de8491c`. V1.1 redistribue Clay/Sandstone par une nappe avec gradient et deux lobes larges en UV, sans masque Bone. Soil et plafonds Bone restent exacts. Un seul B-17 déterministe ; cartes précalculées au chargement, inchangées au reset ; aucune procgen ni simulation verticale en jeu.

| Mesure | Valeur V1.1 |
|---|---:|
| Soil | 16,32–43,86 mm |
| Clay | 11,22–40,98 mm, médiane 25,12 mm sur le bloc |
| Bone depuis top | 55,35–85,34 mm, amplitude 29,99 mm ; exact V1 |
| Sandstone au-dessus de Bone | médiane 23,28 →11,59 ; P95 31,48 →17,12 ; max 36,94 →21,49 mm |
| Effort relatif Clay/Stone | médiane 174,18 →147,28 ; P95 207,47 →175,70 ; max 231,88 →199,65 |
| Cellules Bone | 32 290, silhouette/IDs/totaux P4 exacts |
| A / B / C | Skull (250,230), Spine (510,307), Hind Limb (646,441) |

Les ressources P4 Final Feel sont inchangées. Bone Condition globale et protection par composant préservées : **Skull → Skull → Ribs → Ribs = tik/100 → DING/97 → tik/97 → DING/94**. F1 donne épaisseurs/profondeurs et **hard work index = Clay au-dessus de Bone ×3 + Stone ×5,333…** ; cet indice n'est pas une durée. Précision V1 conservée : grille X/Z depuis UV, picking en scalaires float64 ; aucun changement de shader, parcours, tolérance ou mesh dans V1.1.

Code/tests V1.1 : **`997132ba6297c065903f0b0cdaba05f416bf7166`**. Validation complète historique : **1 654 contrôles fonctionnels +90 visuels**, neuf empreintes identiques entre processus, **60 scénarios de performance**, zéro échec. Série A/C : 221,35–239,87 FPS moyens, minimum sur une seconde 212,28 FPS, P95 maximal 13,251 ms ; frame isolée maximale 17,484 ms. Oracle rasant 1,650 µm, pan 0,194 µm, 250 065 pixels GPU et mêmes tolérances numériques que V1. **Antoine juge ensuite la base verticale meilleure et demande de conserver cette direction.**

Règle confirmée : **Verticality / generation must be effort-aware, not depth-only.** Les futures seeds devront respecter des budgets de travail par matériau, en plus des invariants géométriques. Le contrôle porte sur toute la population Bone, pas seulement A/B/C.

## P4-V1.2 — Visual Cleanup ✅

Référence : `36bd665b2fdf3362875c55803dc184dad84056b3`. La grille orange venait d'une comparaison entre hauteur triangulée et interface bilinéaire, même à zéro Clay restante. Le shader interpole maintenant le delta aux sommets ; le curseur suit les mêmes triangles, avec `1e-6` de tolérance d'arrondi (0,102 µm). Cartes V1.1 et travail par cellule exacts. Sur cinq cas /256 725 pixels : zéro couleur parasite et zéro désaccord curseur ; une vraie pellicule de 0,051 mm reste visible.

Parois dures légèrement assombries, dessus plats conservés ; contraste de faces statique sur les meshes d'éclats/miettes. Séparation mesurée accrue sur huit fixtures, sans changer leur mouvement, forme, nombre ou durée. Les protections Bone, ressources outils, résistances, fracture, audio et caméra restent préservées. Détails et validation dans [P4V_REPORT](../dev/P4V_REPORT.md#v12--vérification-et-performance).

Code/tests : **`bef81c8e6d51bd16f56c1e2f35f911543a0320bf`**. Validation finale : **1 691 contrôles fonctionnels +128 visuels**, neuf empreintes identiques entre processus, **60 scénarios de performance**, zéro échec. Verticalité **222,40–239,87 FPS**, pire P95 **13,237 ms**, minimum sur une seconde **210,74 FPS** ; performance soutenue quasi inchangée, frames isolées jusqu'à 18,527 ms. Les paramètres et les règles du jeu restent conservés ; seul le harnais Brush stabilise la continuité de son geste synthétique face aux notifications natives.

Validation humaine : **NON/OUI/OUI** obtenus — grille orange absente, blocs/profondeur mieux lisibles, base toujours agréable. P4-V1 est validé et mergé via PR #6. Watchpoint différé : la poussière réduit encore la lisibilité des arêtes/blocs avant Blower ; après nettoyage, les bords noirs et la profondeur se lisent mieux. À reprendre en polish visuel/P6-P7, pas comme blocker gameplay. **P4-V2 debris physics peut être ouvert séparément ; P5 reste bloqué tant que ce spike n'est pas cadré/validé.**

## P4-V2 — Look P4-V1 restauré, physique conservée ▶

**Retour humain confirmé : micro-débris de `8f703ae` rejetés**, trop petits/discrets. Nouvelle cible : **MÊMES DÉBRIS QU’AVANT, AVEC UN PEU DE PHYSIQUE**. Le premier malentendu reste corrigé : la physique vise les miettes persistantes, pas les gros éclats transitoires.

Restauration directe de la baseline `ce014d0` : **4,5 mm maximum** Clay/Sandstone au lieu de 2,2 ; mêmes mesh, couleurs, contraste, proportions 32 %/75 %, taille selon quantité. Soil 1,4 mm, deux miettes/24×24, rétention 8 %, capacité 0,02 exacts. Cap V2 128 conservé, surplus Dust, aucune éviction. Le spectacle Chisel, outils, relief/géologie, Bone, Dust, audio et proxies ne changent pas.

Moteur physique et paramètres inchangés : petit kick 0,035/0,025 m/s, gravité 0,65, contact/settle/sleep sans expiration, Blower qui réveille/transporte, Brush progressif, position XYZ autoritaire, sortie unique avec quantité réelle. F3 OFF/ON garde la même taille P4-V1 ; R reset sans changer de mode. F1 expose les coûts et comptes.

**1 782 contrôles fonctionnels**, **32 visuels de présence**, **28 Final Feel +38 contraste/interfaces +8 GPU physiques** verts. En captures figées, présence pixel ×**3,67–4,10** face à 2,2 mm, mêmes 20 miettes/quantités ON/OFF sur chaque fixture. Seuils visuels P4-V1 rétablis et fixture de contraste simplifiée d'origine rétablie. Chute vérifiée **67,64 mm** ; persistance 30 s au cap et 100 s sur plat.

Correction/tests **`a58fe1a`**. **36 scénarios V2 /202 assertions verts** : 239,78–239,87 FPS, minimum une seconde 238,70 ; pire P95 6,556 ms (précédemment 6,342), max frame 12,202 ms. Noyau ON P95 max 1 016 µs, max 4 248 µs ; 1 280 sondes/tick, 128 miettes max. Blower éjecte le cap avec quantité exacte, Brush le nettoie. Mesures locales non isolées ; 60 anciens benchmarks complets non rejoués, cas affectés et visuels reprofilés.

Sources : [brief](../dev/P4V2_BRIEF.md), [rapport courant et preuves](../dev/P4V2_REPORT.md). Le [rapport 2,2 mm](../dev/P4V2_CRUMBS_MICRO_REPORT.md) est historique/rejeté ; ses mesures ne décrivent pas la restauration actuelle. Modification locale préexistante `project.godot` préservée hors commits.

**STOP pour les quatre questions humaines visibilité / identité / physique / Blower. PR #7 DRAFT ; aucun merge ni P5.** La technique ne vaut pas validation du ressenti. Watchpoint Dust/arêtes toujours différé P6/P7.

## Watchpoints techniques

- grille relief dense (~1,31 M triangles) ;
- upload RF complet quand dirty ;
- stress synthétique extrême hors budget ;
- collider physique enveloppe ;
- Compatibility renderer conservé pour l'instant ;
- Godot reste le moteur canonique tant qu'aucun mur concret ne justifie un switch.

## Séquence

P0 ✅ → P1 ✅ → P2 ✅ → P3 ✅ → P4 ✅ → P4-V1 ✅ → **P4-V2 : SIMPLIFY initial, nouvel A/B sur petites miettes persistantes** → P5 UI/progression → P6 Art Pass → P7 Tuning → V0.1.
