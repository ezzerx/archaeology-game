# Statut canonique

- Date : **2026-10-04**.
- Projet : **ArchaeologyGame**, working title modifiable.
- Phase : **préproduction — micro-fix P4 FINAL FEEL par composant livré, prêt pour décision de fermeture ; P4-V et P5 non autorisés**.
- Dépôt privé : [ezzerx/archaeology-game](https://github.com/ezzerx/archaeology-game).
- Branche canonique : `main`. Livraison en revue : `prototype/p4-game-feel`, [PR #5](https://github.com/ezzerx/archaeology-game/pull/5) en brouillon, non mergée (implémentation initiale `42ec46d`, puis correctifs documentés dans le rapport).
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

## P4 — FINAL FEEL, micro-fix par composant ▶

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

Le test humain initial a ensuite conduit à la passe corrective ci-dessus. Si un nouveau test relève encore un dommage jugé inévitable, documenter le geste précis avant toute protection supplémentaire. **Ne pas merger cette livraison ni commencer P5.**

Architecture et limites : [P4_MATERIAL_REACTION_DECISION](../dev/P4_MATERIAL_REACTION_DECISION.md).

Brief canonique :

[P4_BRIEF.md](../dev/P4_BRIEF.md)

**P5 reste interdit avant validation humaine de P4.**

## Watchpoints techniques

- grille relief dense (~1,31 M triangles) ;
- upload RF complet quand dirty ;
- stress synthétique extrême hors budget ;
- collider physique enveloppe ;
- Compatibility renderer conservé pour l'instant ;
- Godot reste le moteur canonique tant qu'aucun mur concret ne justifie un switch.

## Séquence

P0 ✅ → P1 ✅ → P2 ✅ → P3 ✅ → **P4 Game Feel** → P5 UI/progression → P6 Art Pass → P7 Tuning → V0.1.
