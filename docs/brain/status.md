# Statut canonique

- Date : **2026-10-04**.
- Projet : **ArchaeologyGame**, working title modifiable.
- Phase : **préproduction — P4 FINAL FEEL validé humainement et mergé ; P4-V1 Verticality implémenté, validation humaine attendue ; P4-V2 debris physics et P5 bloqués**.
- Dépôt privé : [ezzerx/archaeology-game](https://github.com/ezzerx/archaeology-game).
- Branche canonique : `main`. P4 Final Feel mergé via [PR #5](https://github.com/ezzerx/archaeology-game/pull/5) au commit `7ae0fec3c004d207c99f4713111a240f8d5f2e9a`. Spike actif : `prototype/p4v-verticality`, [PR #6](https://github.com/ezzerx/archaeology-game/pull/6) en brouillon, non mergée.
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

Code du micro-fix : **`0c549f58d6c2c27e21251a854c2e18a39d389ee2`**. **1 517 checks fonctionnels + 90 graphiques verts**, dont 72 nouveaux couvrant les quatre composants, autre côte/vertèbre, reset et outils sûrs. Oracle GPU 194 955 pixels ; sanity de quatre cas Clay/Stone à 1×/3× : **239,86–239,87 FPS**, P95 maximal 4,325 ms. Les benchmarks longs du lock précédent ne sont pas relancés ; preuves historiques conservées. [P4_REPORT](../dev/P4_REPORT.md). **P4 Final Feel ready for human closure / P4-V authorization.** Prochaine action : décision humaine. **STOP. PR #5 BROUILLON, NON MERGÉE. P4-V et P5 nécessitent une nouvelle autorisation explicite.**
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

**La validation P4 ne lance pas P5 : seule la passe P4-V1 est actuellement autorisée.**

## P4-V1 — Verticality : implémenté, à tester humainement

Source de vérité : [P4V_BRIEF](../dev/P4V_BRIEF.md). Architecture, mesures, preuves et checklist : [P4V_REPORT](../dev/P4V_REPORT.md).

Un seul B-17 déterministe : Soil en pente large, lentille Clay indépendante, champ d’enfouissement commun aux os. Cartes précalculées au chargement, inchangées au reset ; aucune procgen ni simulation verticale en jeu.

| Mesure | Valeur V1 |
|---|---:|
| Soil | 16,32–43,86 mm |
| Clay | 11,22–37,74 mm |
| Bone depuis top | 55,35–85,34 mm, contre 65,79–77,85 mm en P4 |
| Cellules Bone | 32 290, silhouette/IDs/totaux P4 exacts |
| A / B / C | Skull (250,230), Spine (510,307), Hind Limb (646,441) |

Les ressources P4 Final Feel sont inchangées. Bone Condition globale et protection par composant préservées : **Skull → Skull → Ribs → Ribs = tik/100 → DING/97 → tik/97 → DING/94**. F1 donne les épaisseurs/profondeurs en mm. Précision : grille X/Z du shader alignée sur UV, intersection du picking en scalaires float64 ; parcours DDA et tolérances conservés, aucune reconstruction de mesh.

Validation : **1 604 contrôles fonctionnels +90 visuels**, neuf empreintes identiques entre processus, 60 scénarios de performance, zéro échec dans les phases finales. V1 : 227,73–239,87 FPS moyens, minimum sur une seconde 210,54, P95 maximal 12,757 ms ; frame isolée maximale 18,728 ms. Oracle rasant : 1,650 µm ; 250 065 pixels GPU vérifiés avec tolérances et cas d’occlusion documentés. Ces contrôles ne remplacent pas le test humain sur l’intérêt de la verticalité.

Prochaine action : **Antoine exécute les six points A–F du rapport**, puis décide de la suite. PR #6 reste brouillon/non mergée. **STOP : aucun merge, seed/procgen, P4-V2 debris physics ni P5 sans nouvelle autorisation.**

## Watchpoints techniques

- grille relief dense (~1,31 M triangles) ;
- upload RF complet quand dirty ;
- stress synthétique extrême hors budget ;
- collider physique enveloppe ;
- Compatibility renderer conservé pour l'instant ;
- Godot reste le moteur canonique tant qu'aucun mur concret ne justifie un switch.

## Séquence

P0 ✅ → P1 ✅ → P2 ✅ → P3 ✅ → P4 ✅ → **P4-V1 : test humain** → P4-V2 éventuel sur autorisation → P5 UI/progression → P6 Art Pass → P7 Tuning → V0.1.
