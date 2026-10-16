# Statut canonique

**Date :** 2026-10-16
**Projet :** ArchaeologyGame
Source unique de la phase, de la branche, de la gate et de la prochaine action.

## Référence et invariants

P0–P5 validées et fusionnées. P6A active ; P6B et P7 non démarrées.
Base validée : main `99cf5d1`, consolidation #24 fusionnée, issue #25 clôturée.
Antoine accepte cette base M–08/B–17 avec les écrans de caisses/collection provisoires.
Poche friable P6A49 validée ; art de l'ammonite apprécié. Outils, Brush, dégâts
localisés, lumière chaude, bloc brut et non-révélation des fossiles enfouis protégés.
Godot 4.7.2 stable ; Sound Design toujours différé.

## Issue active / branche / PR

- [#26 — Isoler la version active](https://github.com/ezzerx/archaeology-game/issues/26).
- Branche `codex/26-clean-active-runtime`, créée depuis main `99cf5d1`.
- [PR #29](https://github.com/ezzerx/archaeology-game/pull/29), prête pour validation humaine.
- Source candidate `707a630` ; aucun merge autorisé implicitement.
- Rapport : `docs/dev/ISSUE26_RUNTIME_CLEANUP_REPORT.md`.
- Organisation et reconstruction : `docs/RUNTIME_LAYOUT.md`.

## Gate / prochaine action

Antoine autorise explicitement #26 : nettoyer les prototypes sans toucher au
jeu validé, vérifier le fonctionnement et préparer la PR. Candidate implémentée :
197 déplacements par responsabilité, 77 retraits de fichiers d'expériences et de
lanceurs, même code conservé après substitution des chemins. Sources/assets,
fixtures utiles et règles inchangées ; archives récupérables par tag Git.

622 contrôles gameplay/persistance et 252 chargements de ressources passent.
Import vierge et comparaison de 727 fichiers conservés passent également.
Ces preuves ne remplacent pas le verdict humain : prochaine action, revue de la
PR et essai M–08/B–17 par Antoine, puis corrections éventuelles dans cette issue.
Pas de fusion avant sa validation. Ne pas démarrer #27/#28 dans cette branche.

## Suite et limites

#27 reprend les arrivages ; #28 reprend la collection. Desserte et registre restent
à choisir avant réalisation. Musée complet, économie, montage et génération globale
hors périmètre. Collection persistante ; fouille non archivée seulement en mémoire.

Workflow : `docs/DEVELOPMENT_WORKFLOW.md` (une issue → PR → validation → merge →
nettoyage, prochaine branche depuis main). Les anciennes branches ont été nettoyées ;
le checkout principal modifié et les autres worktrees utilisateur restent préservés.
Archives Git : `archive/pre-issue26-runtime` pour cette migration,
`archive/p6a38-orientable-lamp-2026-10-16` pour la lampe abandonnée.
