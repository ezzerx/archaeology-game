# ArchaeologyGame

**Working title modifiable.**

**Statut : préproduction — P0/P1/P2 validés et mergés ; corrections gameplay P3 testées, retest humain requis ; PR #4 non mergée.**
Moteur : **Godot 4.7.2 stable**, GDScript, 3D Compatibility.

## Progression

- P0 Interaction brute ✅
- P1 Matière / relief ✅
- P2 Outils ✅
- **P3 Fossile : zoom et finition sûre à retester**
- P4 Game feel
- P5 UI / progression
- P6 Art pass (spike visuel puis application)
- P7 Tuning ; détails dans la [roadmap](docs/ROADMAP.md)

### P2 — Outils

Trois outils fonctionnels :

- Soft Brush
- Chisel
- Air Blower

194 checks P0/P1/P2 passent. PR #3 merge :
`9b8423fedfb4723ba8b0113a23e564ba474c8bd2`.

Rapport : [P2_REPORT](docs/dev/P2_REPORT.md).

### P3 — Fossile

Objectif : créer le premier vrai moment de découverte.

P3 cache Specimen B-17 dans la matrice et bloque l'excavation sur les os. Le Chisel laisse une marge de **2 mm** sur os caché ; le Brush termine localement à **1 mm/s**, même à travers Clay/Sandstone. Un impact Chisel centré sur un os déjà exposé retire 3 points de condition. Brush/Blower restent sûrs. Molette : **zoom orthographique 1–3× au curseur** ; Home : vue d'ensemble ; R : reset.

**500 checks fonctionnels passent.** Le scénario de douze zones expose **1 698 cellules à 100 % de condition**. Exposition globale/quatre composants, F1 et reset exact. Rapport et checklist F5 : [P3_REPORT](docs/dev/P3_REPORT.md). Architecture : [P3_FOSSIL_DECISION](docs/dev/P3_FOSSIL_DECISION.md). Scope correctif prioritaire : [P3_DESIGN_FIXES](docs/dev/P3_DESIGN_FIXES.md), complétant [P3_BRIEF](docs/dev/P3_BRIEF.md).

Antoine a validé le fonctionnement initial et le confort GPU. La revue produit a ensuite imposé le zoom et la finition sûre avant merge. Ces corrections sont livrées ; leur naturel attend un nouveau retest humain. Les réglages développeur sont déplacés vers F6/F7 (rayon), Shift+F6/F7 (puissance), Ctrl+F6/F7 (falloff).

Travailler sur `prototype/p3-fossil`. **Pas de merge ni P4/P5 sans nouvelle autorisation explicite d'Antoine.**

## Runtime

Les runs interactifs normaux sont plafonnés à **240 FPS** (`application/run/max_fps`), physique **60 Hz**. VSync peut limiter plus bas. Les benchmarks peuvent explicitement override ce cap.

## Vision

Jeu cosy/satisfaisant d'archéologie centré sur la fouille de fossiles.

> Est-ce que j’ai envie de continuer à gratter alors que je sais déjà ce qu’il y a dessous ?

## Direction visuelle

> **2.5D stylisée — tabletop — orthographique presque verticale**

## Docs

- [PROTOTYPE_V0_1_SPEC](docs/PROTOTYPE_V0_1_SPEC.md)
- [ART_DIRECTION](docs/ART_DIRECTION.md)
- [VISUAL_REFERENCES](docs/VISUAL_REFERENCES.md)
- [P1_REPORT](docs/dev/P1_REPORT.md)
- [P2_REPORT](docs/dev/P2_REPORT.md)
- [P3_BRIEF](docs/dev/P3_BRIEF.md)
- [Brain](docs/brain/BRAIN.md)
