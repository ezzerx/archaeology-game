# Statut canonique

- Date : **2026-10-05**.
- Projet : **ArchaeologyGame**, working title modifiable.
- Phase : **préproduction — P4 validé et mergé ; P5 simplifié85/95 livré pour retest après les derniers retours, toujours non validé humainement ; PR #8 DRAFT, aucun merge ni P6 autorisé**.
- Dépôt privé : [ezzerx/archaeology-game](https://github.com/ezzerx/archaeology-game).
- Branche canonique : `main`. P4 Final Feel mergé via [PR #5](https://github.com/ezzerx/archaeology-game/pull/5) au commit `7ae0fec3c004d207c99f4713111a240f8d5f2e9a`. P4-V1 verticality mergé via [PR #6](https://github.com/ezzerx/archaeology-game/pull/6) au commit `756cd4338285e52b7d751bc0f0e1694b7792c882`. Clôture P4 / V2 mergée via [PR #7](https://github.com/ezzerx/archaeology-game/pull/7) au commit `bae4ee64268dd6270afb9f0011c316c45c57d251`. P5 actif : `prototype/p5-loop-progression`, PR #8 en brouillon.
- Merge P0 : `244aba3652a03aac908b1aabe1651c3b9edb1315`.
- Merge P1 : `960642c3fc6972bdb257c96abd43b90c148e632d`.
- Merge P2 : `9b8423fedfb4723ba8b0113a23e564ba474c8bd2`.
- Merge P3 : `10a12379ab1db629380ac9697e5597aeb16a373b`.
- Dossier local initial : `C:\Users\antoi\Documents\Codex\Projects\ArchaeologyGame`.

**Reprise courante :** [P5_SIMPLIFICATION_REPORT](../dev/P5_SIMPLIFICATION_REPORT.md), dernière section85/95 du brief humain ; lancer/jouer puis six questions, sans briefing technique.

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
| Pick | 11 | 0.44 | 1.75 |

**P4 human-validated baseline — tuning final deferred to P7.** Blower conserve `residue_clear = 2.5`. Cadences Chisel 4.5 Hz / Pick 6 Hz, efficacités, génération de résidus, dégâts, résistances et seuils de fracture inchangés. Valeurs disponibles au lancement/reset sans retouche debug préalable ; fonctionnement des réglages en session préservé.

Livré : éclats Chisel **3–6 mm, 1–5 par plaque cassée**, projection depuis le dessus estimé du morceau retiré, expiration **0,51–0,69 s**, pools toujours bornés. Les gros morceaux restent transitoires. Blower conserve des miettes dures visibles (**jusqu’à 4,5 mm**) transportées dans le jet puis éjectées ; dust soulevée et hook `debris_ejected` conservés. **Budgets persistants inchangés** : deux miettes par zone 24×24, rétention 8 %, capacité 0,02.

**Protection Bone par composant** : `direct_contact_consumed` est un `PackedByteArray` indexé par NONE (inutilisé), **Skull / Spine / Ribs / Hind Limb**. Maximum **quatre contacts protégés par reset**. Toutes les côtes partagent RIBS, toute la colonne partage SPINE ; aucune protection par cellule, os individuel ou zone. Snapshot `was_exposed_before_impact` conservé : révélation, même centrale, = matière / zéro dégât / aucun flag consommé. Premier Chisel sur un centre déjà visible de ce composant : petit tik, zéro dégât, flag consommé ; suivants sur ce composant : DING/−3. **Bone Condition reste globale** : Skull → Skull → Ribs → Ribs = **100 → 97 → 97 → 94**. Reset réarme les quatre ; Pick/Brush/Blower ne consomment rien. F1 affiche READY/USED dans les lignes existantes. **Baseline P4 réévaluable en P7.** Découverte/UI, exposition et 28 WAV inchangés.

**Mécanique Pick inchangée**, rayon humain verrouillé à 11 : clic/maintien immobile, six micro-impacts/s, puissance 0,44, falloff 1,75, efficacités 0,30/ 1,00/ 1,50 ; footprint local, interface et plafond osseux, zéro dégât provisoire P4. **Proxies conservés** : angle fixe `(0.5, 0, -0.62)`, Tip exact, Body statique déplacé verticalement, douze sondes maximum. Aucune reconstruction de mesh en jeu. Priorité fluidité ; rares petites intersections acceptées, aucun suivi des normales.

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

## P4 — Micro-passe finale, livraison historique avant clôture

Le retest et le STOP ci-dessous décrivent la livraison historique ; la clôture humaine du 2026-10-05, consignée ensuite, les remplace.

Le cœur P4 est apprécié ; gameplay et teinte du Bone Film sont validés. Cette passe ne traite que trois irritants : micro-restes hard ambigus, Matrix camouflée conservant le cap, Dust Soil persistante sans valeur suffisante.

- **Soil : aucun mess persistant.** Ni grains ni nouveau dépôt SurfaceResidue Soil. Retrait/audio/couleur/relief préservés ; **Soil persistent dust deferred to P6/P7 redesign**. Hard Dust reste active.
- **Micro-restes** : ≤1,5 mm, composante8-connectée ≤4 cellules entièrement reconnue dans5×5, sans voisin épais/prolongement. Maximum64 inspections/action. Brush convertit l’îlot en une miette puis le nettoie ; plafond Bone respecté, aucun dégât ou spectacle Chisel. Efficacité Clay générale du Brush0,06→0 pour appliquer la règle produit ; radius/power/falloff restent40/0,70/1,25.
- **Blower** : poids≥0,25, dose≥0,075 seconde pondérée, oubli après0,15 s sans influence. EJECTING libère immédiatement les slots logique/local/physique. Vol visuel0,35 s, petit lift, puis disparition ; aucun besoin d’atteindre le vrai bord. FX plafonnés séparément à256.
- **Cap/reprise** :256 miettes posées sur Soil→souffle local→0 logique +256 FX ;4 impacts Chisel recréent13 miettes avant expiration des FX. Fréquence Clay3/Stone4, cap256 et look conservés.
- **Bone Film et Pick inchangés** : film sombre, Brush seul, Exposure/Condition/protections indépendantes ; Pick11/0,44/1,75,6 Hz, dégâts0, aucune fracture/gros chunk Chisel.

**Vérification de cette micro-passe** :1 895 assertions fonctionnelles uniques ; performances ciblées à1×/3×, zéro upload de résidu sur les gestes Soil20 s. Une répétition Soil atteint239,9 FPS ; la première série avait un pic isolé104 ms non reproduit, conservé dans le rapport. Retest humain requis.

[Rapport courant, preuves/perf](../dev/P4V2_REPORT.md) · [Brief](../dev/P4V2_BRIEF.md) · [Passe dust-only désormais historique](../dev/P4V2_DUST_ONLY_REPORT.md). `project.godot` préexistant préservé hors commits.

**Prochaine action : retest humain final** Soil10–20 s, Brush sur micro-restes, Pick sur vrais morceaux attachés, compteur qui baisse avec vol visible sous Blower, reprise Chisel, puis boucle10 min sans deviner l’outil attendu. **STOP, PR #7 DRAFT ; aucun merge ni P5.**

## P4 — Clôture humaine finale ✅

Validation humaine confirmée le **2026-10-05**. La base de gameplay d'excavation/préparation est considérée suffisante pour avancer.

Boucle retenue :
- **Brush** pour Soil et nettoyage / Bone Film ;
- **Chisel** pour excavation bulk Clay/Sandstone et spectacle de fracture ;
- **Precision Pick** pour finition structurelle précise autour des os ;
- **Blower** pour évacuer Fine Dust et Matrix crumbs ;
- **Bone Film** pour transformer la découverte en vraie étape de préparation ;
- **verticalité effort-aware** pour éviter un script de profondeur trop prédictible.

Derniers choix de clôture :
- Soil : pas de grains ni dust persistante pour l'instant ; feedback à revisiter plus tard ;
- Matrix crumbs Clay/Sandstone : persistantes, bornées, physique légère et évacuation par engagement du Blower ;
- micro-restes hard très fins : peuvent se détacher en mess brushable selon la règle locale bornée ;
- Pick baseline : **11 / 0,44 / 1,75**, 6 Hz, Bone safe ;
- Exposure, Cleanliness et Condition restent séparés.

### 20 % volontairement différés

Non-blockers connus, à revisiter avec davantage de contexte :
- Soil encore trop provisoire pour une version finale ;
- débris/mess satisfaisants mais probablement perfectibles ;
- ambiguïté visuelle ponctuelle **Pick vs Brush** sur les micro-restes ;
- **Bone dirt vs Sandstone** encore trop proches visuellement sur certains cas ;
- Dust pouvant réduire la lecture des arêtes avant Blower.

Première stratégie P6 pour la lisibilité : **tester uniquement la couleur** du Bone Film avant de changer pattern/densité/forme, car les taches actuelles plaisent.

Ces sujets ne rouvrent pas P4 maintenant. S'ils restent importants après P5/P6, ils recevront une **phase dédiée de polish gameplay/excavation avec un nouveau nom (TBD), pas “P4.2”**.

## P5 — Livraison initiale Complete Session Loop / UI & Progression (historique)

Source de vérité : [P5_BRIEF](../dev/P5_BRIEF.md).

Livré sur `prototype/p5-loop-progression`, [PR #8 DRAFT](https://github.com/ezzerx/archaeology-game/pull/8). [Rapport, preuves, limites et checklist humaine](../dev/P5_REPORT.md).

- `PreparationSession` observe les compteurs et signaux existants ; états, classification, objectifs et UI actualisés sur événement. Aucun scan du squelette par frame. **Exposure / Cleanliness / Condition restent trois autorités distinctes.** Cleanliness dérive du film des seules cellules anatomiques exposées.
- Composants : Hidden <10 % ; Detected ≥10 % ; Exposed ≥50 % ; Prepared ≥80 % exposé **et** ≥80 % propre. Classification monotone Unknown → Vertebrate (global ≥5 % ou composant ≥10 %) → Possible Theropod (Spine ≥15 % et Hind Limb ≥10 %) → Likely small theropod (Skull ≥35 %, étape précédente acquise).
- Trois objectifs acquis dans n'importe quel ordre : Skull ≥60 % exposé et ≥50 % propre ; squelette ≥60 % exposé ; fragments2/2. Completion unique, sans exiger100 %.
- Deux fragments indépendants, déterministes, plafonds Bone et film ; totaux anatomiques **32 290 / 7 756 / 7 243 / 10 771 / 6 520** inchangés. READY exige ≥90 % exposé et une couronne locale entièrement dégagée. **Forceps [5]** saisit, soulève et transporte au tray ; relâchement ailleurs, changement d'outil ou perte de focus rendent le fragment. Aucun retrait/film/dégât par Forceps.
- UI fonctionnelle : objectifs, dossier, cinq outils, deux slots, notifications bornées. Snapshot figé à `Preparation Complete` ; **Keep Cleaning** conserve le bloc et ses outils ; **Archive Specimen** prend les valeurs actuelles, stoppe les outils et affiche `Museum records updated.`. **Prepare Another Block** et R réarment exactement le même B-17.
- Métriques locales F1 : temps depuis completion, Keep Cleaning choisi, valeurs à completion/archive et actions supplémentaires. Le temps inclut la carte ; une action est un impact ou un tick continu appliqué, pas un clic humain. Aucune télémétrie ni sauvegarde musée.
- Validation : **1 895 contrôles historiques +184 P5**, tous verts ; **47 contrôles graphiques P5 +63 historiques ciblés**, oracle GPU194 955 pixels et interfaces256 725 pixels, zéro échec. Performance : **20 scénarios ×6 s à1×/3×**, 239,71–239,88 FPS, minimum1 s238,95, pire frame11,221 ms ; drag final répété à239,87 FPS. Cap240 / physique60 conservés.

Le feel P4 et les quatre ressources outils restent verrouillés. Modification locale préexistante de `project.godot` préservée hors commits. P5 remplace explicitement l'auto-recovery et `Restart Specimen` des anciennes spécifications.

**Prochaine action : une session humaine complète en huit étapes, surtout Keep Cleaning.** Le fonctionnement technique est vérifié ; compréhension, agrément du transfert Forceps et envie de poursuivre restent à valider. **STOP après livraison : PR #8 DRAFT, aucun merge ni P6.**

## P5 — Correction humaine1 (historique, supersédée)

Le premier test a révélé une confusion entre mission requise et qualité100 %, des panneaux obstructifs, une récupération peu naturelle et une archive trop administrative. **Son Keep Cleaning n'est pas un signal produit exploitable.** [Brief correctif](../dev/P5_HUMAN_CORRECTION_BRIEF.md) et [rapport courant](../dev/P5_CORRECTION_REPORT.md) prévalent sur la livraison initiale ci-dessus.

- Museum Request seul obligatoire ; sous-objectifs terminés également verts/résumés ; état persistant Request complete / Ready to archive / Further work optional. Archive accessible dans ce panneau. Dossier explicitement informatif/optionnel ; panneaux224 px dans les marges à vue d'ensemble.
- Étoiles par composant à **95 % exposé ET95 % propre**, persistantes, éclat doré et notice uniques. Prepared80/80 conservé ; aucune autorité sur Condition, mission ou archive. Zéro étoile n'empêche rien ;100 % n'est pas requis.
- Fragments rapprochés de la mâchoire/bassin, notice unique à10 % réellement exposé. READY90 %+couronne inchangé ; exactement deux, totaux anatomiques exacts. Plateau3D fixe sur le bureau ; dépôt sur son fond intérieur réel, meshes visibles dans les compartiments. Home restaure le plateau si le zoom l'a sorti du cadre, sans recadrage automatique.
- Archive courte : confirmation visuelle/sonore discrète, identité, demande accomplie, fragments/Condition finale, qualité optionnelle et remerciement. Un seul bouton Prepare Another Block ; valeurs détaillées conservées en F1, snapshots toujours séparés.
- **2 117 checks fonctionnels** (1 895 historiques +184 P5 +38 correctifs), **79 graphiques**, **22 scénarios de performance /70 checks**, zéro échec.239,70–239,88 FPS, minimum1 s239,01, pire frame11,426 ms. Cap240/physique60 ; ressources et géologie P4 inchangées. `project.godot` préexistant toujours hors commits.

**Prochaine action : retest sans coordonnées ni consigne de continuer.** Distinguer plaisir/maîtrise optionnelle de confusion ; tester aussi confort du plateau depuis le zoom et satisfaction de l'archive. P5 reste non validé humainement. **STOP, PR #8 DRAFT ; aucun merge/P6.**

## Watchpoints techniques courants

- grille relief dense (~1,31 M triangles) ;
- upload RF complet quand dirty ;
- stress synthétique extrême hors budget ;
- collider physique enveloppe ;
- Compatibility renderer conservé pour l'instant ;
- Godot reste le moteur canonique tant qu'aucun mur concret ne justifie un switch.

## Séquence

P0 ✅ → P1 ✅ → P2 ✅ → P3 ✅ → P4/P4-V1/P4-V2 ✅ → **P5 corrigé, retest humain attendu** → P6 Art Pass (non autorisé) → P7 Tuning → V0.1.

## Precision Pick — addendum humain confirmé, 2026-10-04

Nouveau test humain positif : **11 / 0,44 / 1,75** remplace **7 / 0,24 / 1,50** dans la ressource native. Cadence6 Hz, dégâts Bone 0, efficacités0,30/ 1,00/ 1,50 inchangées. Finition structurelle rapide après Chisel ; faible capacité de déblaiement due au petit footprint, pas à un impact local péniblement faible. Aucun stress de fracture ni gros chunks Chisel. Brush prépare le film adhérent, Blower chasse le mess libre. **P4 human-validated baseline — final fine tuning still deferred to P7.** Les anciennes entrées de décision conservent leur valeur historique, pas une baseline concurrente.


## P5 — second human review (historical90/90, superseded)

Second review on 2026-10-05: the corrected UI still contains too much information and obscures the basic purpose of the session. P5 remains **not human-validated**.

New validation target: one simple player-facing goal — **reveal >=90% skeleton and clean >=90% Bone** — then clearly offer Archive or optional further cleaning. Fragments/Forceps/tray and component-quality stars are removed from the P5 validation flow. Detailed classification/components/Condition move out of the primary UI.

P5 is intentionally greybox; P6 will make the interface beautiful/diegetic. The only P5 UI requirement is immediate comprehension.

PR #8 remains DRAFT. Next action: implement this simplification, rerun regression/performance checks, then one clean human retest with no brief/debug guidance. No P6 before that gate.


### P5 latest target — compact HUD / 85→95

Latest human direction supersedes the prior 90/90-only mockup: required completion is now **85% Exposure +85% Cleanliness**, followed by one optional global **Fine Preparation ★** at **95% +95%**. Exact100% is personal only.

Player-facing HUD should be reduced to a single compact top-left/left-margin preparation card plus the bottom four-tool toolbar. Remove the permanent right dossier, component list, Forceps/fragments/tray and component stars from the P5 validation flow.

**Livraison85/95 réalisée** : code `19b8ec49395e18378af4996788c90807c31af13d`, [rapport courant](../dev/P5_SIMPLIFICATION_REPORT.md). Une carte224px à gauche, deux barres ; completion à85/85 sans modal ni interruption, étoile globale persistante à95/95 avec éclat/son uniques. Seule Archive bloque les outils ; sa carte affiche deux lignes positives, l'étoile si acquise et Prepare Another Block. Classification transitoire, Condition/métriques F1. Fragments/Forceps/plateau non instanciés normalement ; expérience conservée pour tests seulement.

**Vérifié** :2 017 contrôles fonctionnels (1 895 historiques +83 actifs +39 expérience),59 graphiques,22 scénarios/90 contrôles de performance, oracle GPU194 955 pixels ; zéro échec.239,68–239,87 FPS, minimum1s238,99, pire frame11,035ms. Les quatre outils et autorités P4 sont inchangés. `project.godot` préexistant hors commits.

**Prochaine action : lancer et jouer librement, puis répondre aux six questions du rapport courant.** Aucun brief ni coordonnées. P5 reste non validé ; PR #8 DRAFT, STOP sans merge/P6.


### P5 implementation target locked after human review

Next corrective build is now defined: 85/85 global Exposure/Cleanliness plus an invisible major-section coverage guard for archive readiness; optional global Fine Preparation at95/95; qualitative Condition tiers (Excellent/Good/Fair/Damaged) as care feedback, not a completion requirement.

HUD remains one compact preparation card plus the four-tool toolbar. No right dossier, fragments, Forceps, tray, component stars or detailed component checklist in the P5 validation flow.

PR #8 remains DRAFT. Next action: implement this target, rerun regressions/performance, then perform one clean human retest without brief/debug guidance. No P6 until explicit validation.
