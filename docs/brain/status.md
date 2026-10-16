# Statut canonique

**Date :** 2026-10-16

## Référence
P0–P5 validées. P6A active. Main intègre les essais validés par la fusion de #34 (c297d42).
L'accès habituel à B–17/M–08, les interactions validées et la collection réelle sont préservés. Caisses #30 rejetées et archivées sans fusion.
#27/#28 différées, son différé. Découverte prioritaire, collection comme continuité.

## Mission / gate
L'essai [#33](https://github.com/ezzerx/archaeology-game/issues/33) reçoit la
validation explicite d'Antoine : les trois approches apportent une variété
ludique appréciée. Les réserves concernent la finition, pas l'acceptation de
l'essai. [PR #34](https://github.com/ezzerx/archaeology-game/pull/34) fusionnée,
issue #33 fermée ; branches de #33 et du cadrage #31 supprimées. Aucune mission
de développement active. Source jouable validée : 2bf10ce.

Brief : docs/dev/ISSUE33_PREPARATION_DEMOS.md.
Rapport, verdict humain et captures : docs/dev/ISSUE33_PREPARATION_DEMOS_REPORT.md.
Vision : docs/design/NEXT_STEPS_VISION.md.
Worktree : C:/Users/antoi/.codex/worktrees/preparation-demos/ArchaeologyGame.
Lanceur : Launch-Preparation-Demos.cmd ; scène principale et collection réelle préservées.

## Prochaine action
Cadrer ensemble une mission de finition avant toute nouvelle implémentation.
Sujets : grès trop dominant / poches trop rares ; relief réel entre les tours
de M–08 ; finition des concrétions ; familles d'outils et variantes sur une même
touche. Aucun nouvel outil, ordre de missions ou développement n'est encore autorisé.
Le détail des règles de sélection des variantes reste une proposition à discuter.

## Preuves et points de suivi
518 contrôles de régression, 73 contrôles nouveaux et 267 ressources passent.
Trois parcours natifs à 100/100, condition 100 ; occultation contrôlée pixel à pixel.
Recettes fixes, deux fossiles, aucun générateur global. Le coût du souffle et le
court chargement des scènes restent des points de suivi pour la production.
#31 terminé ; #32 remplacée par #34. Le cadrage remplacé est conservé sous le
tag archive/issue31-product-vision-2026-10-16. Les dossiers jouables et les
changements utilisateur des anciens checkouts sont préservés. Le worktree des
essais suit la référence de main en HEAD détachée ; créer la prochaine branche
depuis main actualisée après validation d'une nouvelle vision.
Workflow : une issue → branche depuis main → PR → validation → merge → nettoyage.
