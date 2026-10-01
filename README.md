# ArchaeologyGame

**Working title modifiable.**

**Statut : préproduction — P0/P1/P2 validés et mergés ; P3 Fossile à tester humainement, non mergé.**
Moteur : **Godot 4.7.2 stable**, GDScript, 3D Compatibility.

## Progression

- P0 Interaction brute ✅
- P1 Matière / relief ✅
- P2 Outils ✅
- **P3 Fossile ▶**
- P4 Game feel
- P5 UI / progression
- P6 Art pass
- P7 Tuning

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

P3 cache Specimen B-17 dans la matrice, le révèle progressivement et bloque l'excavation sur les os. Le premier contact est protégé ; les impacts Chisel suivants sur un centre déjà exposé retirent 3 points de condition. Brush/Blower restent sûrs.

**279 checks fonctionnels passent.** Exposition globale/quatre composants, F1 étendu et reset exact. Rapport et checklist F5 : [P3_REPORT](docs/dev/P3_REPORT.md). Architecture : [P3_FOSSIL_DECISION](docs/dev/P3_FOSSIL_DECISION.md). Scope : [P3_BRIEF](docs/dev/P3_BRIEF.md).

Travailler sur `prototype/p3-fossil`. **Pas de merge ni P4/P5 avant validation explicite d'Antoine.**

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
