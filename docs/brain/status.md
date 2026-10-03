# Statut canonique

- Date : **2026-10-04**.
- Projet : **ArchaeologyGame**, working title modifiable.
- Phase : **préproduction — P4 FINAL FEEL livrée, retest humain attendu ; P4-V et P5 interdits**.
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

## P4 — FINAL FEEL, composition A/B livrée ▶

Source de vérité : [P4_FINAL_FEEL_TARGET](../dev/P4_FINAL_FEEL_TARGET.md). Préférences confirmées par Antoine : Chisel spectacle A (`42ec46d`), Blower nettoyage B (`c25b44f`), Soil/Pick récents E (`f527139`), ancien angle fixe. **Cette composition attend son propre retest humain.**

Livré : éclats Chisel **3–6 mm, 1–5 par plaque cassée**, projection depuis le dessus estimé du morceau retiré, expiration **0,51–0,69 s**, pools toujours bornés. Les gros morceaux restent transitoires. Blower retrouve des miettes dures visibles (**jusqu’à 4,5 mm**) transportées dans le jet puis éjectées ; dust soulevée et hook `debris_ejected` conservés. **Quantités persistantes inchangées** : deux miettes par zone 24×24, rétention 8 %, capacité 0,02. Après 60 s simulées : 29/27 miettes Clay/grès, puis zéro après souffle.

**Nouvelle règle audio verrouillée** : petit Bone tik uniquement à la première détection du spécimen par reset ; gros clack uniquement sur hit Chisel direct avec perte réelle de condition ; autres reveals = son de matière travaillée, dominant en cas de mélange. Exposure et règle de condition inchangées ; 28 WAV historiques exacts. Fracture, outils historiques, Soil, poussière contextuelle et ivoire Bone préservés.

**Pick inchangé** : clic/maintien immobile, six micro-impacts/s, rayon 3, puissance 0,24, efficacités 0,30/1,00/1,50 ; petit footprint, interface et plafond osseux, zéro dégât provisoire P4. **Angle ancien `(0.5, 0, -0.62)`** pour tous les outils, pointe ancrée, manche rigide dégagé verticalement ; aucune orientation selon les micronormales. Cavité synthétique extrême : connecteur allongé, jusqu’à 84,90 mm de dégagement hors recul, à juger en jeu.

**1 395 checks fonctionnels + 90 contrôles graphiques passent**, oracle GPU de 194 955 pixels conservé. **28 scénarios 1×/3× : 96,56–239,97 FPS**, P95 maximal 19,249 ms, frame maximale 29,850 ms sur RTX 5080 / 1080p. Casse dense/Blower proches de 240 ; le coût du dégagement Brush à l’angle ancien réduit Soil à 97–107 FPS. Cap 240 FPS / physique 60 Hz. Code vérifié : `8394ee9eed8b5dd2b15fb901b5a7c6c7d77ee484` ; preuves et limites dans le rapport.

Prochaine action : **exactement sept points du [P4_REPORT](../dev/P4_REPORT.md#retest-humain--exactement-sept-points)** : Chisel comparé à A ; lisibilité après une minute ; Blower comparé à B ; Bone audio ; Pick ; angle stable ; 10–15 min « casser ET nettoyer sont-ils tous les deux satisfaisants ? ». **STOP. PR #5 BROUILLON, NON MERGÉE. P4-V Verticality / Debris Physics et P5 bloqués jusqu’à validation humaine et nouvelle autorisation explicite.**
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
