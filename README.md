# ArchaeologyGame

**Working title modifiable.**

**Statut : préproduction — P0/P1/P2/P3 validés et mergés ; micro-fix P4 FINAL FEEL par composant prêt pour décision de fermeture.**
Moteur : **Godot 4.7.2 stable**, GDScript, 3D Compatibility.

## Progression

- P0 Interaction brute ✅
- P1 Matière / relief ✅
- P2 Outils ✅
- P3 Fossile / zoom ✅
- **P4 Game Feel ▶**
- P5 UI / progression
- P6 Art pass
- P7 Tuning

### P3 — Fossile

P3 introduit :

- Specimen B-17 caché ;
- exposition progressive ;
- bone ceiling ;
- premier contact protégé ;
- Bone Condition technique ;
- zoom orthographique 1×–3× ancré au curseur ;
- debug rapide souris ;
- cap runtime 240 FPS.

**439 checks passent.**

PR #4 merge :
`10a12379ab1db629380ac9697e5597aeb16a373b`.

Rapports :

- [P3_REPORT](docs/dev/P3_REPORT.md)
- [P3_FOSSIL_DECISION](docs/dev/P3_FOSSIL_DECISION.md)
- [P3_DESIGN_FIXES](docs/dev/P3_DESIGN_FIXES.md)

### P4 — Game Feel

P4 ajoute les réactions de matière :

- Soil granulaire ;
- Clay qui chip/peel ;
- Sandstone qui fissure et casse en chunks ;
- Chisel avec vraie sensation d'impact ;
- particules / débris placeholder ;
- outils visibles simples ;
- sons distincts ;
- meilleure lisibilité Bone contact.

La composition [FINAL FEEL](docs/dev/P4_FINAL_FEEL_TARGET.md) reprend le spectacle Chisel de P4-A (éclats transitoires 3–6 mm) et le nettoyage visible de P4-B (miettes projetées hors du bloc), avec la quantité persistante récente toujours plafonnée. Soil, Pick et ivoire Bone sous la poussière sont préservés. Les outils retrouvent l’ancien angle fixe, pointe exacte et corps dégagé. Grammaire joueur : **matière attachée / saleté**.

**Bone audio** : une protection indépendante pour **Skull / Spine / Ribs / Hind Limb**, quatre maximum par reset, avec **une Bone Condition globale**. Toute révélation, même centrale, garde le son matériau et ne consomme aucun flag. Premier Chisel sur un centre du composant **déjà exposé avant l’impact** : petit tik, zéro dégât ; suivants sur ce composant : DING/−3. Skull → Skull → Ribs → Ribs donne **100 → 97 → 97 → 94**. Toutes les côtes partagent RIBS, toute la colonne SPINE. Reset réarme les quatre ; Pick/Brush/Blower ne consomment jamais. F1 affiche READY/USED. Baseline P4 réévaluable en P7 ; exposition et timbres historiques inchangés.

**Baselines humaines persistées**, rayon / puissance / falloff : Brush **40 / 0.70 / 1.25**, Chisel **22 / 0.64 / 2.25**, Blower **60 / 0 / 1.00**, Pick **7 / 0.24 / 1.50**. **P4 human-validated baseline — tuning final deferred to P7.** Blower conserve son nettoyage 2.5 ; cadences, efficacités, génération de résidu, dégâts et fracture inchangés.

**[4] Precision Pick** : clic ou maintien immobile, six micro-impacts/s, rayon 7 texels, puissance 0,24, retrait rapide et précis sans grosses plaques. Zéro dégât provisoire P4, plafond osseux intact.

**Bugfix Brush conservé** : Tip/Body statiques, douze sondes terrain maximum, aucune reconstruction de mesh pendant le jeu. Avec la baseline du lock, geste de 30 s à 1×/3× : **235–236 FPS**, proxy P95 **31 µs**. Diagnostic, tests et limites dans le [rapport P4](docs/dev/P4_REPORT.md).

Ouvrir `project.godot` dans Godot 4.7.2, lancer **F5**, masquer F1 pour jouer ; aucun réglage debug préalable nécessaire. [Trois vérifications avant fermeture P4](docs/dev/P4_REPORT.md#retest-humain--exactement-trois-points) : Brush 30–60 s, contacts protégés par composant, sanity Chisel/Blower/Pick. **P4 Final Feel ready for human closure / P4-V authorization.** STOP ; PR #5 en brouillon, non mergée, aucune ouverture automatique de P4-V/P5.

Brief :

[P4_BRIEF](docs/dev/P4_BRIEF.md)

[Rapport et mesures P4](docs/dev/P4_REPORT.md) · [Architecture P4](docs/dev/P4_MATERIAL_REACTION_DECISION.md)

## Runtime

Runs normaux : **240 FPS max**, physique **60 Hz**.

## Vision

> Est-ce que j’ai envie de continuer à gratter alors que je sais déjà ce qu’il y a dessous ?

Le premier signal P3 est positif : une fois l'os perçu, Antoine a envie de continuer à le révéler.

## Direction visuelle

> **2.5D stylisée — tabletop — orthographique presque verticale**

P4 ajoute seulement les visuels nécessaires au game feel. Le vrai Art Pass reste P6.

## Docs

- [PROTOTYPE_V0_1_SPEC](docs/PROTOTYPE_V0_1_SPEC.md)
- [ROADMAP](docs/ROADMAP.md)
- [ART_DIRECTION](docs/ART_DIRECTION.md)
- [FUTURE_SYSTEMS](docs/FUTURE_SYSTEMS.md)
- [P4_BRIEF](docs/dev/P4_BRIEF.md)
- [Brain](docs/brain/BRAIN.md)
