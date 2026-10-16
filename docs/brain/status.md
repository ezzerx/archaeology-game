# Statut canonique

**Date :** 2026-10-16

## Référence
P0–P5 validées. P6A active. Main conserve B–17, M–08 et les interactions
validées après fusion de #29. Caisses #30 rejetées et archivées sans fusion.
#27/#28 différées, son différé. Découverte prioritaire, collection comme continuité.

## Mission / gate
L'essai [#33](https://github.com/ezzerx/archaeology-game/issues/33) reçoit la
validation explicite d'Antoine : les trois approches apportent une variété
ludique appréciée. Les réserves concernent la finition, pas l'acceptation de
l'essai. [PR #34](https://github.com/ezzerx/archaeology-game/pull/34),
branche codex/33-preparation-demos : fusion et nettoyage autorisés par ce
verdict selon le workflow installé. Source jouable validée : 2bf10ce.

Brief : docs/dev/ISSUE33_PREPARATION_DEMOS.md.
Rapport, verdict humain et captures : docs/dev/ISSUE33_PREPARATION_DEMOS_REPORT.md.
Vision : docs/design/NEXT_STEPS_VISION.md.
Worktree : C:/Users/antoi/.codex/worktrees/preparation-demos/ArchaeologyGame.
Lanceur : Launch-Preparation-Demos.cmd ; scène principale et collection réelle préservées.

## Prochaine action
Clore #34 et nettoyer ses branches après vérification de la fusion. Ensuite,
cadrer ensemble une mission de finition avant toute nouvelle implémentation.
Sujets : grès trop dominant / poches trop rares ; relief réel entre les tours
de M–08 ; finition des concrétions ; familles d'outils et variantes sur une même
touche. Aucun nouvel outil, ordre de missions ou développement n'est encore autorisé.
Le détail des règles de sélection des variantes reste une proposition à discuter.

## Preuves et points de suivi
518 contrôles de régression, 73 contrôles nouveaux et 267 ressources passent.
Trois parcours natifs à 100/100, condition 100 ; occultation contrôlée pixel à pixel.
Recettes fixes, deux fossiles, aucun générateur global. Le coût du souffle et le
court chargement des scènes restent des points de suivi pour la production.
#31 terminé ; #32 remplacée par #34. Conserver les changements utilisateur des
anciens checkouts et l'accès au lanceur des essais pendant le nettoyage.
Workflow : une issue → branche depuis main → PR → validation → merge → nettoyage.
