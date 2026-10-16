# Statut canonique

**Date :** 2026-10-16

## Référence
P0–P5 validées. P6A active. Main `7feaa4e` conserve B–17, M–08 et les interactions
validées après fusion de #29. Caisses #30 rejetées et archivées sans fusion.
#27/#28 différées, son différé. Découverte prioritaire, collection comme continuité.

## Mission active / gate
[#33](https://github.com/ezzerx/archaeology-game/issues/33), branche
`codex/33-preparation-demos`, créée depuis main. Trois démos comparatives livrables,
revues et testées : compact, granulaire, encroûté.
[PR #34](https://github.com/ezzerx/archaeology-game/pull/34), prête pour validation
humaine. Source jouable `2bf10ce` ; aucune fusion autorisée implicitement.

Brief : `docs/dev/ISSUE33_PREPARATION_DEMOS.md`.
Rapport, captures et limites : `docs/dev/ISSUE33_PREPARATION_DEMOS_REPORT.md`.
Vision : `docs/design/NEXT_STEPS_VISION.md`.
Worktree actif : `C:/Users/antoi/.codex/worktrees/preparation-demos/ArchaeologyGame`.
Lanceur : `Launch-Preparation-Demos.cmd` ; scène principale et collection réelle préservées.

## Vérification / prochaine action
518 contrôles de régression, 73 contrôles nouveaux et 267 ressources passent.
Trois parcours natifs à 100/100, condition 100 ; occultation contrôlée pixel à pixel.
Captures revues et traitement du souffle optimisé. Les chiffres ne prouvent ni
la rejouabilité ni la qualité artistique finale. Évaluer les trois gestes avec
Antoine, corriger dans #33, puis attendre sa validation avant merge et nettoyage.

Recettes fixes, deux fossiles, aucun générateur global. Le coût du souffle et le
court chargement des scènes restent des points de suivi pour la production.
Le cadrage #31 est terminé ; sa PR documentaire #32 est remplacée par #34,
sans empiler son code. La branche documentaire est conservée jusqu’au nettoyage
après validation de #34.
Workflow : une issue → branche depuis main → PR → validation → merge → nettoyage.
