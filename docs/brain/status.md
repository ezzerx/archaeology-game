# Statut canonique

- Date : **2026-10-03**.
- Projet : **ArchaeologyGame**, working title modifiable.
- Phase : **préproduction — simplification finale P4 livrée, retest humain attendu ; P5 interdit**.
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

## P4 — Simplification finale après test humain ▶

Le core est validé humainement : Chisel très fun, marks → cracks → chunks, Clay/Sandstone, profondeur, condition plus juste, sons découverte/hit direct, Brush audio acceptable, zoom/pan/picking et envie de continuer. Aucun merge n’est autorisé.

**Livré : matière attachée / saleté**, sans classification Loose Debris à apprendre. Soil → Brush ; matrice dure → Chisel ; détails attachés → Pick ; mess → Brush/Blower. Bone garde au moins 76,08 % de son ivoire dans le mélange poussiéreux et une roughness/specular distincte. Dust liée au substrat local, souffle depuis les sources nettoyées conservé. Proxies à angle fixe et pointe ancrée ; corps dégagé verticalement. Éclats 1,2–2,4 mm, trois maximum par impact par défaut, éjectés hors du centre, 0,51–0,69 s.

**Pick seul retuné** sur décision explicite : IMPACT, clic ou maintien immobile, 6 Hz, rayon 3, puissance 0,24, efficacités Soil/Clay/Stone 0,30/1,00/1,50. Retrait direct local sans grosses plaques, arrêt de couche et plafond osseux ; zéro dégât provisoire P4. Un clic central : 8,16 mm Clay / 4,59 mm grès si la couche le permet ; volume environ 18 fois inférieur au Chisel dans le test d’une seconde. Réglages historiques, fracture, audio et caméra inchangés.

**1 376 checks fonctionnels + 62 contrôles graphiques passent**, 28 WAV historiques exacts, oracle GPU de 194 955 pixels conservé. **24 scénarios 1×/3× : 169,27–240,01 FPS**, P95 maximal 13,365 ms, frame maximale 20,944 ms sur RTX 5080 / 1080p. Cap 240 FPS / physique 60 Hz. Code vérifié : `f62fccfb3f6d1572e42f8ad3a3ec98b9691a3e14` ; documentation/preuves dans les commits suivants.

Prochaine action : **exactement huit points du [P4_REPORT](../dev/P4_REPORT.md#retest-humain--exactement-huit-points)** : Chisel ; Bone + dust ; outil fixe sur pente/cavité/os ; éclats non obstructifs ; Pick rapide/précis/safe ; nettoyage évident ; boucle Brush → Chisel → Pick → Blower ; jeu libre 10–15 minutes. Le dégagement du corps peut atteindre 36,32 mm dans la cavité synthétique extrême ; contact et lecture restent à juger en jeu. **STOP. PR #5 BROUILLON, NON MERGÉE ; P5 interdit.**

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
