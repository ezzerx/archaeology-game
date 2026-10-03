# ArchaeologyGame

**Working title modifiable.**

**Statut : préproduction — P0/P1/P2/P3 validés et mergés ; simplification finale P4 prête pour retest humain.**
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

Les tests humains confirment le plaisir du Chisel/fracture, les sons osseux et la caméra. La passe finale simplifie la lecture : **matière attachée / saleté**. Soil → Brush ; matrice dure → Chisel ; détails → Precision Pick ; mess → Brush/Blower. Bone reste ivoire même poussiéreux ; dépôts teintés selon la matière locale ; souffle conservé. Proxies à angle fixe et corps dégagé, éclats petits et éjectés hors du centre.

**[4] Precision Pick** : clic ou maintien immobile, six micro-impacts/s, rayon 3 texels, puissance 0,24, retrait rapide et précis sans grosses plaques. Zéro dégât provisoire P4, plafond osseux intact. Réglages Brush/Chisel/Blower, fracture, audio et caméra préservés.

**1 376 checks fonctionnels, 62 contrôles graphiques et l’oracle GPU passent. 24 scénarios : 169–240 FPS**, P95 maximal 13,365 ms sur RTX 5080 / 1080p. Les retours de plaisir, l’identité des os sales et la silhouette des outils attendent le retest humain.

Ouvrir `project.godot` dans Godot 4.7.2, lancer **F5**, masquer F1 pour jouer. Tester 10–15 minutes selon la [checklist P4](docs/dev/P4_REPORT.md#retest-humain--exactement-huit-points). **PR #5 en brouillon, non mergée ; P5 interdit.**

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
