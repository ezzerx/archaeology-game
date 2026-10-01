# Statut canonique

- Date : **2026-10-01**.
- Projet : **ArchaeologyGame**, working title modifiable.
- Phase : **préproduction — P2 validé et mergé ; P3 Fossile autorisé**.
- Dépôt privé : [ezzerx/archaeology-game](https://github.com/ezzerx/archaeology-game).
- Branche canonique : `main`.
- Merge P0 : `244aba3652a03aac908b1aabe1651c3b9edb1315`.
- Merge P1 : `960642c3fc6972bdb257c96abd43b90c148e632d`.
- Merge P2 : `9b8423fedfb4723ba8b0113a23e564ba474c8bd2`.
- Dossier local initial : `C:\Users\antoi\Documents\Codex\Projects\ArchaeologyGame`.

## P0 — Validé ✅

Fondation interaction validée : mapping souris, surface, strokes, reset/debug.

## P1 — Validé ✅

Relief excavable 3D, stratigraphie, résistances et picking précis sur le relief.

## P2 — Validé ✅

Antoine confirme le 2026-10-01 que les trois outils fonctionnent comme voulu pour le prototype.

Livré et validé :

- Soft Brush continu ;
- Chisel discret à 4,5 Hz ;
- Air Blower sans retrait structurel ;
- ToolDefinition data-driven ;
- résidu debug R8 256×160 ;
- changement 1/2/3 et toolbar ;
- reset/input robustes ;
- **194 checks P0/P1/P2, 0 échec** ;
- ~60 FPS sur les benchmarks graphiques 1080p plafonnés à 60.

PR #3 mergée vers `main` le 2026-10-01 au commit `9b8423fedfb4723ba8b0113a23e564ba474c8bd2`.

Rapport : [P2_REPORT.md](../dev/P2_REPORT.md).

## Décision runtime FPS

Lors du test humain P2, le runtime Godot non plafonné a poussé la RTX 5080 à 100% GPU.

Décision explicite d'Antoine :

> **Capper les runs interactifs normaux à 240 FPS à partir de P3.**

Les scripts de benchmark peuvent temporairement désactiver/modifier ce plafond pour mesurer la marge.

Aucune autre optimisation GPU n'est demandée pour l'instant. Si 240 FPS laisse encore une charge jugée excessive, le plafond sera abaissé dans une décision ultérieure.

## Watchpoints techniques

- grille relief dense (~1,31 M triangles) ;
- upload height RF complet à chaque tick dirty ;
- residue R8 séparé mais léger ;
- stress synthétique extrême hors budget ;
- collider physique enveloppe uniquement ;
- valeurs d'efficacité/résistance encore de prototype.

Aucun de ces points ne bloque P3.

## Prochaine étape autorisée — P3 Fossile

P3 doit introduire :

- Specimen B-17 caché dans le bloc ;
- révélation progressive du fossile ;
- plafond osseux empêchant de creuser à travers l'os ;
- `Bone detected` au premier contact ;
- premier contact protégé ;
- condition du spécimen ;
- dégâts Chisel sur os déjà exposé ;
- Brush/Blower sûrs ;
- pourcentage d'exposition global et par composant.

Le brief canonique est :

[P3_BRIEF.md](../dev/P3_BRIEF.md)

**P4 n'est pas autorisé avant validation humaine de P3.**

## Séquence

P0 ✅ → P1 ✅ → P2 ✅ → **P3 Fossile** → P4 Game feel → P5 UI/progression → P6 Art pass → P7 Tuning.
