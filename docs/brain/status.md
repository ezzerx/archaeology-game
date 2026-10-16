# Statut canonique

**Date :** 2026-10-16
**Projet :** ArchaeologyGame
Source unique de la phase, de la branche, de la gate et de la prochaine action.

## Phases et référence

P0–P5 validées et fusionnées. P6A Visual Direction / Production Spike active.
P6B et P7 non démarrées. Godot 4.7.2 stable reste canonique.
P6A49 (poche friable) validée par Antoine ; M–08 reçoit un retour positif.
Outils, Brush, dégâts localisés, squelette, lumière chaude, bloc brut et
non-révélation des fossiles enfouis restent protégés. Sound Design différé.

## Référence et PR de consolidation

- Référence de reprise : `main` contenant la [PR #24](https://github.com/ezzerx/archaeology-game/pull/24).
- [Issue #25](https://github.com/ezzerx/archaeology-game/issues/25) : consolidation et workflow par issues.
- Branche de livraison historique : `codex/p6a50-collection-loop`, à retirer après fusion vérifiée.
- Source jouable `ebd1b72` ; documentation de livraison `09593a3`.
- Rapport produit : `docs/dev/P6A50_COLLECTION_LOOP_REPORT.md`.

## Retour humain et gate

**Antoine valide explicitement la consolidation le 16 octobre 2026**, avec
les écrans de caisses et de collection conservés comme provisoires. Cette
validation autorise la fusion de #24 et le nettoyage des branches associées.
L'ammonite plaît ; la présentation des deux écrans doit être reprise dans
ses issues dédiées. Ne pas présenter cet accord comme une validation de leur art.

Méthode : plan découpé en issues, une issue à la fois, PR, validation humaine,
merge, nettoyage, puis départ depuis main à jour.
Règles durables : `docs/DEVELOPMENT_WORKFLOW.md`.
Plan ordonné et inventaire : `docs/dev/GITHUB_TRANSITION_PLAN.md`.

**Prochaine mission proposée :** #26, isoler le code actif et retirer les
expériences inutiles. Elle n'est pas démarrée ; attendre sa sélection avant
implémentation. #27 puis #28 portent la reprise artistique des arrivages et de
la collection. Desserte/registre restent des propositions à choisir avant
réalisation. Aucun changement de gameplay dans la clôture de #25.

## État du nettoyage et limites

Neuf branches distantes et dix branches locales déjà contenues dans main ont
été supprimées après contrôle d'ascendance. Suppression automatique de la branche
source après merge activée sur GitHub. Les branches P6A39–50 doivent être
retirées après vérification de leur inclusion dans main. La branche divergente
P6A38 est préservée par le tag distant vérifié
`archive/p6a38-orientable-lamp-2026-10-16` (tête `14acef4`) avant retrait.
L’état effectif des branches est vérifiable dans Git ; ces références historiques
ne constituent pas de nouvelles branches de travail.
Le checkout principal modifié et les worktrees utilisateur sont conservés.

Les 622 contrôles ciblés de P6A50 restent les preuves de la livraison précédente ;
ils ne valent pas validation humaine. Collection persistante ; fouille non
archivée seulement en mémoire durant le lancement. Musée complet, économie,
montage/extraction et génération globale hors périmètre.

Historique déplacé sans perte dans
`docs/dev/archive/STATUS_BEFORE_ISSUE_WORKFLOW_2026_10_16.md`.
