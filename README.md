# ArchaeologyGame

**Working title modifiable.** ArchaeologyGame est un nom temporaire de projet, pas un titre commercial validé.

**Statut : préproduction — P0 validé et mergé ; P1 implémenté, validation humaine attendue.** Plateforme visée : Steam. Moteur du prototype : **Godot 4.7.2 stable**, GDScript, rendu 3D Compatibility.

## État du prototype

### P0 — Interaction brute ✅

Validé automatiquement puis testé localement par Antoine le 2026-10-01.

Fondations disponibles :

- caméra orthographique fixe à 84° ;
- bloc greybox ;
- mapping souris → raycast → local → UV → map ;
- working map CPU 1024×640 ;
- stroke continu avec rayon / force / falloff configurables ;
- reset `R` ;
- debug `F1` ;
- tests automatisés.

PR #1 mergée vers `main` : `244aba3652a03aac908b1aabe1651c3b9edb1315`.

Rapport : [P0_REPORT](docs/dev/P0_REPORT.md).

### P1 — Matière ▶ à tester

Sur `prototype/p1-materials`, la surface est maintenant un volume creusable :

- relief 3D borné à 102 mm ;
- creux visibles ;
- mapping précis malgré le relief ;
- Loose Soil ;
- Compact Clay ;
- Sandstone ;
- résistances distinctes avec outil debug générique.

**97 contrôles automatisés passent**, plus la vérification graphique CPU/GPU. En 1080p local, les gestes normaux et rapides tiennent environ 60 FPS ; le stress artificiel coin-à-coin à chaque tick dépasse le budget.

**Clic maintenu** : creuser · **R** : reset · **F1** : données · **F2** : vues · **Molette** : rayon · **Shift+molette** : puissance · **Ctrl+molette** : falloff.

Lire le [rapport P1 et sa checklist humaine](docs/dev/P1_REPORT.md) avant validation. P2 (outils finaux) reste interdit avant le test d'Antoine.

## Vision

Un jeu cosy et satisfaisant d’archéologie, centré sur la fouille et la préparation de fossiles. La satisfaction répétée de *PowerWash Simulator* inspire la boucle : travailler une surface, observer une transformation tangible, puis avoir envie de continuer.

Le joueur travaille en **vue tabletop presque verticale**, sur un bloc de terre et de roche posé sur une table. Il retire progressivement les couches pour découvrir des os, identifier un spécimen et récupérer des fragments qui complètent son musée. Aucun monde ouvert ni personnage contrôlable.

**Fouille / nettoyage → découverte → identification / classification → récupération de fragments → collection → musée → nouvelle fouille.**

## Piliers

1. **Le game feel d’abord.**
2. **Une matière crédible à travailler.**
3. **Une découverte progressive.**
4. **Une collection physique visible.**
5. **Un périmètre maîtrisé.**

Le critère de validation final reste :

> Est-ce que j’ai envie de continuer à gratter alors que je sais déjà ce qu’il y a dessous ?

## Direction visuelle canonique

> **2.5D stylisée — tabletop — caméra orthographique presque verticale**

Illustration chaleureuse devenue interactive : table en bois, lampe chaude, carnet scientifique, matériaux avec relief, os ivoire, UI papier/bois/laiton et atmosphère de musée d’histoire naturelle.

Le pixel art n’est plus la cible de la V0.1.

## Documentation canonique

| Fichier | Usage |
|---|---|
| [CONCEPT](docs/CONCEPT.md) | Promesse et périmètre |
| [GAMEPLAY_LOOP](docs/GAMEPLAY_LOOP.md) | Fouille, matériaux, outils, révélation |
| [ART_DIRECTION](docs/ART_DIRECTION.md) | Direction 2.5D tabletop |
| [VISUAL_REFERENCES](docs/VISUAL_REFERENCES.md) | Références visuelles canoniques |
| [MVP_V0_1](docs/MVP_V0_1.md) | Résumé du prototype |
| [PROTOTYPE_V0_1_SPEC](docs/PROTOTYPE_V0_1_SPEC.md) | **Spécification détaillée canonique V0.1** |
| [P0_REPORT](docs/dev/P0_REPORT.md) | Fondation technique P0 validée |
| [P1_REPORT](docs/dev/P1_REPORT.md) | Résultats P1, performance, limites et test humain |
| [P1_RELIEF_DECISION](docs/dev/P1_RELIEF_DECISION.md) | Choix du relief et du picking |
| [MUSEUM_SYSTEM](docs/MUSEUM_SYSTEM.md) | Galerie et progression future |
| [TECH_NOTES](docs/TECH_NOTES.md) | Notes techniques |
| [ROADMAP](docs/ROADMAP.md) | Jalons |
| [Brain](docs/brain/BRAIN.md) | Routage et décisions |

Pour reprendre le développement : lire [AGENTS.md](AGENTS.md), [PROTOTYPE_V0_1_SPEC.md](docs/PROTOTYPE_V0_1_SPEC.md), [docs/brain/status.md](docs/brain/status.md), puis le rapport du dernier jalon.
