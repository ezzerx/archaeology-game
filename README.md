# ArchaeologyGame

**Working title modifiable.**

**Statut : préproduction — P0/P1/P2 validés et mergés ; P3 Fossile autorisé.**  
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

P3 doit cacher Specimen B-17 dans la matrice, le révéler progressivement, empêcher de creuser à travers les os, gérer un premier contact protégé et une condition de spécimen.

Brief : [P3_BRIEF](docs/dev/P3_BRIEF.md).

## Runtime

Les runs interactifs normaux doivent désormais être plafonnés à **240 FPS**. Les benchmarks peuvent override ce cap.

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
