# ArchaeologyGame

**Working title modifiable.**

**Statut : préproduction — P0/P1/P2/P3 validés et mergés ; P4 FINAL FEEL prête pour retest humain.**
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

**Bone audio** : petit tik uniquement à la première découverte du spécimen par reset ; gros clack uniquement sur hit Chisel direct avec perte réelle de condition. Les révélations supplémentaires gardent le son Clay/Sandstone travaillé. Condition, exposition et timbres historiques inchangés.

**[4] Precision Pick** : clic ou maintien immobile, six micro-impacts/s, rayon 3 texels, puissance 0,24, retrait rapide et précis sans grosses plaques. Zéro dégât provisoire P4, plafond osseux intact. Réglages Brush/Chisel/Blower/Pick, fracture et caméra préservés.

**1 395 checks fonctionnels, 90 contrôles graphiques et l’oracle GPU passent. 28 scénarios : 97–240 FPS**, P95 maximal 19,249 ms sur RTX 5080 / 1080p. Casse dense et Blower proches de 240 FPS ; la pose Brush à l’ancien angle coûte davantage sur Soil. Le plaisir de casser ET nettoyer attend le retest humain.

Ouvrir `project.godot` dans Godot 4.7.2, lancer **F5**, masquer F1 pour jouer. Tester 10–15 minutes selon les [sept points P4](docs/dev/P4_REPORT.md#retest-humain--exactement-sept-points). **STOP. PR #5 en brouillon, non mergée ; P4-V et P5 interdits.**

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
