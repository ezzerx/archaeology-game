# ArchaeologyGame

**Working title modifiable.** ArchaeologyGame est un nom temporaire de projet.

**Statut : préproduction — P0/P1 validés et mergés ; P2 validé humainement, non mergé.**
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

### P2 — Outils validé ✅, merge en attente d'autorisation

Antoine confirme le 2026-10-01 : **« Ok ça fonctionne ! »**. Validation globale du fonctionnement ; la checklist détaillée reste disponible pour les retests.

La scène jouable propose :

- **Soft Brush**
- **Chisel**
- **Air Blower**

avec trois profils configurables : Brush continu, Chisel à 4,5 impacts/s, Blower nettoyant un résidu debug sans changer la hauteur. Une toolbar cliquable et les touches `1/2/3` sélectionnent l'outil. Un changement pendant le clic annule le geste jusqu'au prochain clic.

**194 checks P0/P1/P2 passent**, ainsi que les sept phases du benchmark graphique local à environ 60 FPS / 1080p. Valeurs, limites et checklist : [P2_REPORT](docs/dev/P2_REPORT.md). **PR non mergée ; merge et P3 attendent une autorisation explicite distincte.**

Pour jouer : ouvrir `project.godot` dans Godot 4.7.2 Standard puis **F5**. LMB maintenu : utiliser ; `R` : reset ; `F1` : données ; `F2` : vues. Molette : rayon ; Shift+molette : puissance ; Ctrl+molette : falloff. Le voile gris est le résidu debug et se voit dans la vue éclairée.

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
| [P2_REPORT](docs/dev/P2_REPORT.md) | Outils, mesures et test humain |
| [Brain](docs/brain/BRAIN.md) | Statut et décisions |

Pour reprendre : lire `AGENTS.md`, `docs/PROTOTYPE_V0_1_SPEC.md`, `docs/brain/status.md`, puis le brief du jalon actif.
