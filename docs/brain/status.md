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
Antoine a autorisé la passe de rendu après avoir jugé l'environnement amélioré
mais encore insuffisant. Le candidat ajoute ombres douces, SSIL/contact,
reflets, lampes visibles, matières harmonisées, fenêtre/vitrage/jardin et raccords.
Lanceur de galerie en Forward+ ; préparation et project.godot conservés.
Captures comparées au concept, plusieurs itérations et contrôles terminés :
85 contrôles par renderer et 300 ressources, zéro échec.
Rapport actif : docs/dev/ISSUE51_GALLERY_RENDERING.md, avec avant/après et mesures.
Attendre le nouveau verdict visuel d'Antoine avant fusion ou autre mission.
PR #52 reste ouverte. Aucun gameplay ni donnée joueur modifié.

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
Sauvegarde 3D réelle et boucle arrivage/atelier/galerie à définir ensuite.
Plafond 240 FPS / physique 60 Hz ; baisses au souffle dense suivies dans #50.
Arrivages #27 : ancien rendu rejeté, vision détaillée encore à approfondir.
UI #46, décor #47, sons avec Claude #48, musique #49.
Lanceur : Launch-Exhibition-Study.cmd.
Worktree : C:/Users/antoi/.codex/worktrees/preparation-demos/ArchaeologyGame.
