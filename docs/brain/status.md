# Statut canonique

**Date :** 2026-10-17

## Références validées
P0–P5, préparations #33, ammonite #35, terre compacte #37, concrétions #39,
parcours marin #41 et fluidité #43 retenus après essai humain.
PR #44 fusionnée sur main 683bd11, issue #43 fermée et branche nettoyée.
B–17/M–08, trois familles de préparation, outils, matières et art à préserver.
C reste la référence de rythme compacte ; 5–7 minutes pour la petite ammonite
reste une cible, sans nouvelle durée humaine mesurée.

## Vision acceptée / mission active
Petite galerie 3D chaleureuse, sans avatar, avec préparations dans leur matrice,
vues composées et inspection rapprochée. Direction acceptée provisoirement pour
essais ; caméra et transitions appréciées, qualité artistique finale non validée.
Seconde référence stylisée choisie, avec continuité graphique avec la préparation.
Vision : docs/design/FIRST_EXHIBITION_PLAN.md ; cadrage parent #45, collection #28.
Direction artistique : docs/design/MUSEUM_ART_DIRECTION_STUDY.md.

Premier essai [#51](https://github.com/ezzerx/archaeology-game/issues/51) :
galerie avec deux exemples de préparation, indépendante des données du joueur.
Branche codex/51-exhibition-study depuis main 683bd11.
Brief : docs/dev/ISSUE51_EXHIBITION_STUDY.md.
Rapport : docs/dev/ISSUE51_EXHIBITION_STUDY_REPORT.md.
PR [#52](https://github.com/ezzerx/archaeology-game/pull/52) ouverte pour essai humain.

## Version à essayer / prochaine action
Antoine apprécie la galerie comme base, plus aboutie qu'une démo, tout en
réservant des améliorations artistiques. Il demande de corriger le flou près/loin.
Correctif de revue dans #52 : rendu à la résolution native de la fenêtre,
MSAA 4× sans TAA, filtrage des ombres ajusté pour garder leur douceur.
Rapport actif : docs/dev/ISSUE51_GALLERY_CLARITY.md (comparaisons et limites).
95 contrôles par renderer et 300 ressources passent. Le rendu 1440p natif
coûte davantage : la galerie ne tient pas encore la cible 240 FPS à cette résolution.
Le lanceur reste Launch-Exhibition-Study.cmd, en Forward+ ; préparation préservée.
PR #52 reste ouverte pour vérifier ce correctif avant fusion.

Ordre confirmé par Antoine : netteté → vrai bloc préparé exposé (#28) →
caisses avant préparation (#27), pour une boucle démo caisse/préparation/musée.
Le prochain raccordement doit conserver l'apparence du travail juste terminé :
matière restante, nettoyage et dégâts. Les exemples actuels ne sont pas encore
remplacés. Cadrer cette mission sur main après clôture de la revue #52,
conformément au workflow par issue/PR ; puis définir la passe caisses.

Originaux archivés dans assets/museum/source/tripo-studio/ ; dépôt utilisateur
stable : C:/Users/antoi/Documents/ArchaeologyGame-Assets/Tripo/museum/.
Le dossier furniture contenait un dépôt ponctuel : ses cinq GLB ont été rangés
dans ce dossier stable après vérification des copies.
Pack de références : docs/visual-references/museum/environment/README.md.
Toujours fournir les réglages adaptés avant chaque génération ; priorité à la
source, puis optimisation sur copie après comparaison.
Pas de nouvelle génération Tripo réalisée pendant cette intégration.

## Points de suivi
Exemples annoncés comme tels ; aucune acquisition ni modification de sauvegarde.
Préparations, suivi d'outils et lanceurs existants conservés.
Jardin secondaire simple et sources détaillées non optimisées pour une grande
salle. Le rendu indirect est SSIL ; pas encore d'éclairage précalculé. Une future
boucle atelier/musée dans un processus devra comparer le renderer commun.
Retouche de l'inscription inventée au dos de B–17 et comparaison atelier/musée
à taille strictement identique restent à traiter.
Sauvegarde 3D réelle à définir : le stockage actuel garde une photo et des scores,
et choisit le meilleur résultat. Distinguer cette archive de la préparation
qui vient de finir, demandée pour l’exposition ; préserver les archives existantes.
Plafond 240 FPS / physique 60 Hz ; baisses au souffle dense suivies dans #50.
Arrivages #27 : ancien rendu rejeté, vision détaillée encore à approfondir.
UI #46, décor #47, sons avec Claude #48, musique #49.
Lanceur : Launch-Exhibition-Study.cmd.
Worktree : C:/Users/antoi/.codex/worktrees/preparation-demos/ArchaeologyGame.
