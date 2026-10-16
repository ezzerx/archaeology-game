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

## Branche et PR

- Branche : `codex/p6a50-collection-loop`.
- [PR #24 DRAFT](https://github.com/ezzerx/archaeology-game/pull/24) vers main :
  consolidation exceptionnelle de la chaîne de prototypes, sous [issue #25](https://github.com/ezzerx/archaeology-game/issues/25).
- Source jouable `ebd1b72` ; documentation de livraison `09593a3`.
- Main conserve la référence précédente. Aucun merge de #24 effectué.
- Rapport produit : `docs/dev/P6A50_COLLECTION_LOOP_REPORT.md`.

## Retour humain et gate

Antoine apprécie l'ammonite. Il juge les écrans des caisses et de la collection
trop proches d'un jeu navigateur. Leur art doit être repris ; ce retour ne valide
ni leur présentation ni l'ensemble de la boucle de progression.

Nouvelle méthode demandée : plan découpé en issues, une issue à la fois, PR,
validation humaine, merge, nettoyage des branches, puis départ depuis main à jour.
Règles durables : `docs/DEVELOPMENT_WORKFLOW.md`.
Plan ordonné et inventaire : `docs/dev/GITHUB_TRANSITION_PLAN.md`.

**Action autorisée :** organiser GitHub, documenter le retour et préparer la
consolidation #25. La fusion de #24 nécessite l'accord explicite d'Antoine sur
cette base avec écrans provisoires. Ne pas ouvrir une nouvelle branche empilée.
Après consolidation : #26 isole le code actif ; #27 puis #28 portent la reprise
artistique des arrivages et de la collection. Les propositions desserte/registre
restent à choisir avant leur réalisation ; aucune refonte graphique commencée.

## État du nettoyage et limites

Neuf branches distantes et dix branches locales déjà contenues dans main ont
été supprimées après contrôle d'ascendance. Suppression automatique de la branche
source après merge activée sur GitHub. Les branches P6A39–49 attendent la fusion
de la consolidation ; P6A38 diverge et doit être archivée avant retrait.
Le checkout principal modifié et les worktrees utilisateur sont conservés.

Les 622 contrôles ciblés de P6A50 restent les preuves de la livraison précédente ;
ils ne valent pas validation humaine. Collection persistante ; fouille non
archivée seulement en mémoire durant le lancement. Musée complet, économie,
montage/extraction et génération globale hors périmètre.

Historique déplacé sans perte dans
`docs/dev/archive/STATUS_BEFORE_ISSUE_WORKFLOW_2026_10_16.md`.
