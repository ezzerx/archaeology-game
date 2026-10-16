# Statut canonique

**Date :** 2026-10-16
**Projet :** ArchaeologyGame
Source unique de la phase, de la branche, de la gate et de la prochaine action.

## Base conservée

Main `7feaa4e` conserve le gameplay validé et les deux spécimens : B–17 et
M–08 (ammonite). PR #29 fusionnée, nettoyage #26 terminé. Godot 4.7.2 stable.
P0–P5 validées ; le socle visuel P6A et les ajouts acceptés restent la référence.
Outils, Brush, dégâts localisés, poche friable, bloc brut, lumière chaude et
non-révélation des fossiles enfouis protégés. Sound Design différé.

## Décision humaine / essais retirés

Antoine rejette le concept de caisses présenté dans #30 : niveau visuel insuffisant.
La PR #30 est fermée sans fusion ; sa branche locale/distante a été supprimée.
L’essai reste récupérable au tag `archive/issue27-arrivals-rejected-2026-10-16`.
Aucun code de ces caisses n’a été ajouté à main. L’écran de choix et la galerie
provisoires de main restent des accès fonctionnels, sans validation artistique.

Les issues #27 (arrivages) et #28 (collection visuelle) sont différées. Ne pas
reprendre automatiquement les caisses physiques, une desserte ou un registre.

## Travail actif / gate

- Issue [#31 — Vision et prochaines missions](https://github.com/ezzerx/archaeology-game/issues/31).
- Branche documentaire `codex/31-product-vision`, créée depuis main `7feaa4e`.
- [PR documentaire #32](https://github.com/ezzerx/archaeology-game/pull/32), en brouillon ; aucun changement de gameplay.
- Support : `docs/design/NEXT_STEPS_VISION.md`.

Prochaine action autorisée : brainstorm avec Antoine sur l’état du jeu, sa
promesse, les priorités et la vision de chaque mission. Les pistes du document
sont des propositions non approuvées. Aucun développement, nouvelle passe d’art,
merge ou passage de phase ne découle de ce brainstorm sans accord explicite.

## Méthode et limites

Pour chaque mission, définir et valider d’abord l’expérience en jeu, le parcours
concret, le traitement visuel/gestuel, les exclusions et le test de réussite.
Découper ensuite en issues exécutables ; une issue → PR → validation → merge →
nettoyage. Voir `docs/DEVELOPMENT_WORKFLOW.md`.
Collection archivée persistante ; fouille en cours uniquement en mémoire.
Les modifications utilisateur dans le checkout principal et le worktree main
restent préservées. Le code jouable de cette branche est identique à main ; 252 ressources chargées sans échec.
