# Statut canonique

- Date : **2026-10-01**.
- Projet : **ArchaeologyGame**, working title modifiable.
- Phase : **préproduction — P0 implémenté, revue humaine attendue**.
- Dépôt privé : [ezzerx/archaeology-game](https://github.com/ezzerx/archaeology-game).
- Branche : `prototype/p0-foundation`, issue de `main` au commit `74b5e88dea181d7b8683a7cbb8a290928e88edf5`.
- Dossier local initial : `C:\Users\antoi\Documents\Codex\Projects\ArchaeologyGame`.

## État livré sur la branche P0

Godot **4.7.2 stable**, GDScript, renderer Compatibility. Scène 3D greybox, caméra orthographique fixe à 84°, bloc, raycast/local/UV/map, mask CPU 1024×640, DebugExcavator à footprint balayé, curseur et panneau debug, R/F1, tuning temporaire rayon/force/falloff.

La planche des quatre références est versionnée avec son SHA-256 canonique vérifié. Elle n'est pas un asset de jeu.

**Validation automatisée : 45 checks passés**, import et démarrage headless sans erreur. Rendu graphique, souris physique et 1080p/60 à vérifier localement : l'affichage virtuel Work a échoué à ouvrir ses sockets. Aucun playtest humain ni résultat de game feel n'est revendiqué.

Le livrable détaillé, les commandes et la checklist sont dans [P0_REPORT.md](../dev/P0_REPORT.md).

## Prochaine action autorisée

1. Revoir la PR P0 vers `main` sans merge automatique.
2. Ouvrir `project.godot` dans Godot 4.7.2 et suivre la checklist locale du rapport.
3. Corriger les éventuels défauts de P0, puis obtenir la validation d'Antoine avant de planifier la suite.

**P1 n'est pas commencé.** Aucun matériau, outil final, fossile, FX/audio, objectif, musée, sauvegarde ou progression n'a été ajouté.

## Références et suite conditionnelle

[PROTOTYPE_V0_1_SPEC](../PROTOTYPE_V0_1_SPEC.md) reste la source canonique. DA : **2.5D stylisée — tabletop — orthographique presque verticale**, sans pixel art pour le prototype.

Séquence : P0 Interaction brute → P1 Matière → P2 Outils → P3 Fossile → P4 Game feel → P5 UI/progression → P6 Art pass → P7 Tuning. Les jalons ultérieurs ne sont pas autorisés par la livraison de P0.

La question de validation V0.1 demeure : « Est-ce que j'ai envie de continuer à gratter alors que je sais déjà ce qu'il y a dessous ? » Les objectifs proposés (4 joueurs sur 5 à 4/5 de satisfaction, 3 sur 5 continuant après la fin) ne sont pas encore testables dans ce greybox P0.
