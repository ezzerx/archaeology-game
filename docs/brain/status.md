# Statut canonique

**Date :** 2026-10-16
**Projet :** ArchaeologyGame
Source unique de la phase, de la branche, de la gate et de la prochaine action.

## Référence et invariants

P0–P5 validées et fusionnées. P6A active ; P6B et P7 non démarrées.
Base main `7feaa4e` : PR #29 fusionnée avec autorisation explicite d’Antoine,
issue #26 clôturée et branche de nettoyage supprimée.
M–08/B–17, poche friable, Brush, dégâts localisés, lumière chaude, bloc brut et
non-révélation des fossiles enfouis protégés. Godot 4.7.2 ; Sound Design différé.

## Issue active / branche / PR

- [#27 — Arrivages dans l’atelier](https://github.com/ezzerx/archaeology-game/issues/27).
- Branche `codex/27-workshop-arrivals`, créée depuis main `7feaa4e`.
- [PR #30](https://github.com/ezzerx/archaeology-game/pull/30), prête pour revue humaine ; code candidat `1bfbdc5`.
- Rapport : `docs/dev/ISSUE27_WORKSHOP_ARRIVALS_REPORT.md`.
- Nouveau worktree isolé : `27-workshop-arrivals/ArchaeologyGame`.

## Gate / prochaine action

Antoine a autorisé le passage au ticket suivant après #29. Il accepte la
composition à deux caisses sur l’établi « pour le moment », en demandant de
retravailler le rendu visuel. Cet accord valide la disposition, pas l’art final.

La candidate remplace les cartes d’arrivages par des caisses 3D fermées et reliées
au parcours existant. Matériaux et volumes affinés après inspection native.
119 contrôles de parcours/persistance/invariants et 255 ressources passent.
Prochaine action : essai de la candidate et revue de la PR par Antoine, puis
corrections éventuelles. Aucun merge ni démarrage de #28 avant validation explicite.

## Suite et limites

#28 reprend la collection, dont l’interface provisoire reste conservée ici.
Pas de musée explorable, économie, nouveau fossile ou nouvelle mécanique de fouille.
La collection est persistante ; la fouille non archivée reste uniquement en mémoire.

Workflow : `docs/DEVELOPMENT_WORKFLOW.md` (une issue → PR → validation → merge →
nettoyage ; prochaine branche depuis main). Les modifications utilisateur du
checkout principal et de l’ancien worktree `p6a32-fossil-mesh` restent préservées.
