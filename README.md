# ArchaeologyGame

**Working title modifiable.** ArchaeologyGame est un nom temporaire de projet.

**Statut : préproduction — P0 et P1 validés/mergés ; P2 Outils autorisé.**  
Plateforme visée : Steam. Moteur prototype : **Godot 4.7.2 stable**, GDScript, rendu 3D Compatibility.

## État du prototype

### P0 — Interaction brute ✅

Mapping souris précis, working map, strokes continus, debug et tests.

PR #1 merge : `244aba3652a03aac908b1aabe1651c3b9edb1315`.

### P1 — Matière / relief ✅

Validé techniquement et par Antoine.

- relief 3D excavable borné ;
- Loose Soil / Compact Clay / Sandstone ;
- résistances distinctes ;
- picking exact sur le relief ;
- 45 checks P0 + 52 checks P1 ;
- validation GPU/CPU ;
- ~60 FPS local en usage normal/rapide.

PR #2 merge : `960642c3fc6972bdb257c96abd43b90c148e632d`.

Rapports :

- [P1_REPORT](docs/dev/P1_REPORT.md)
- [P1_RELIEF_DECISION](docs/dev/P1_RELIEF_DECISION.md)

### P2 — Outils ▶ prochaine étape

P2 doit introduire :

- **Soft Brush**
- **Chisel**
- **Air Blower**

avec des modes d'interaction réellement différents et une compatibilité matière lisible.

P2 ne doit pas commencer le fossile. P3 reste soumis à validation humaine.

## Vision

Jeu cosy et satisfaisant d’archéologie centré sur la fouille et la préparation de fossiles.

**Fouille → découverte → identification → fragments → collection → musée → nouvelle fouille.**

Critère final :

> Est-ce que j’ai envie de continuer à gratter alors que je sais déjà ce qu’il y a dessous ?

## Direction visuelle

> **2.5D stylisée — tabletop — caméra orthographique presque verticale**

Le pixel art n’est pas la cible de la V0.1.

## Documentation canonique

| Fichier | Usage |
|---|---|
| [CONCEPT](docs/CONCEPT.md) | Vision |
| [GAMEPLAY_LOOP](docs/GAMEPLAY_LOOP.md) | Boucle |
| [ART_DIRECTION](docs/ART_DIRECTION.md) | DA |
| [VISUAL_REFERENCES](docs/VISUAL_REFERENCES.md) | Références |
| [PROTOTYPE_V0_1_SPEC](docs/PROTOTYPE_V0_1_SPEC.md) | Spec V0.1 |
| [P0_REPORT](docs/dev/P0_REPORT.md) | P0 |
| [P1_REPORT](docs/dev/P1_REPORT.md) | P1 |
| [P1_RELIEF_DECISION](docs/dev/P1_RELIEF_DECISION.md) | Relief/picking |
| [P2_BRIEF](docs/dev/P2_BRIEF.md) | Scope P2 |
| [Brain](docs/brain/BRAIN.md) | Statut et décisions |

Pour reprendre : lire `AGENTS.md`, `docs/PROTOTYPE_V0_1_SPEC.md`, `docs/brain/status.md`, puis le brief du jalon actif.
