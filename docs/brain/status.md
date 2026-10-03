# Statut canonique

- Date : **2026-10-03**.
- Projet : **ArchaeologyGame**, working title modifiable.
- Phase : **préproduction — troisième passe corrective P4 livrée, nouveau test humain attendu ; P5 interdit**.
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

## P4 — Troisième passe corrective après test humain ▶

Les tests humains sont **très positifs** : environ 15 minutes supplémentaires, Chisel très fun, fracture Clay/Sandstone, profondeur, lisibilité Bone/matrice, condition moins punitive et zoom/pan validés. Les sons découverte osseuse/hit direct sont jugés parfaits ; le Brush audio suffit pour P4. Ce retour n’autorise aucun merge.

Troisième passe livrée : pointe réelle des proxies au hit, repère issu de la normale et protection visuelle locale contre les pentes/cavités ; Fine Dust en amas persistants lisibles à 1×/3× ; bouffées du Blower issues des cellules effectivement nettoyées, soulevées puis entraînées dans le jet. Loose Debris en écailles **≤1,4 × 0,196 mm**, toujours deux par zone 24×24 texels ; F1 distingue surface attachée et débris/FX proches. Les gros éclats restent transitoires. Aucun nouveau système de saleté.

**Seul le Pick est retuné**, avec autorisation explicite : puissance 0,22, efficacités Clay 0,75 / Sandstone 1,00, référence 40 texels/s ; rayon 3 et retrait maximal 0,004 inchangés. Le grès reste deux fois plus lent que la Clay au centre ; geste de 0,4 s à 30 texels/s : 1,68 / 0,84 mm de retrait. LMB + mouvement, aucun forage immobile, interfaces/plafond osseux respectés, zéro dégât provisoire P4. Aucun auto-stop Chisel ni bonus Brush. Fracture, sons, caméra et paramètres des trois outils historiques préservés.

**1 093 checks fonctionnels + 16 contrôles graphiques passent**, 28 WAV historiques identiques à l’octet, oracle GPU de 194 955 pixels. **22 scénarios : 122,91–239,98 FPS**, P95 maximal **14,039 ms**, frame maximale **17,927 ms**, RTX 5080 / 1080p. Les poses ont un coût supplémentaire au Brush continu, tout en tenant le budget ≥60 FPS. Cap 240 FPS / physique 60 Hz. Bloc saturé au repos : 2 322 miettes, zéro édition/upload height. Deux sessions de 60 secondes simulées gardent 29/27 miettes, puis zéro après souffle.

Prochaine action : **retest humain 10–15 minutes**, sept points de [P4_REPORT](../dev/P4_REPORT.md#retest-humain--10-à-15-minutes) : clipping, poussière au dézoom, souffle « ça souffle ou ça efface ? », Pick Clay, Pick Sandstone, distinction attaché/détaché, boucle complète. Les proxies peuvent se déformer localement dans les cavités extrêmes ; rendu et transitions restent à juger en jeu. **STOP. PR #5 reste en brouillon, non mergée ; P5 interdit.**

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
