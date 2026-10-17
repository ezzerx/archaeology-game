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
Antoine apprécie les meubles mais demande de refaire le sol, les murs et le fond.
Les cinq nouveaux exports déposés dans furniture sont intégrés : niches,
fenêtre, fougère, livres et minéral. Il autorise à avancer avec ces modèles et
à envisager une régénération seulement si le rendu reste problématique.
Le fond troué de la niche est remplacé dans l'assemblage Godot ; source GLB intacte.
Dalles, enduit, boiseries, raccords architecturaux et lumière repris.
Rapport actif : docs/dev/ISSUE51_MUSEUM_ENVIRONMENT.md, avec captures et limites.
85 contrôles natifs et 298 chargements de ressources réussis ; attendre le
verdict visuel humain avant nouvelle passe ou fusion. Aucun gameplay modifié.

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
Vue extérieure simplifiée, raccords de matières et ombres encore à peaufiner
selon le verdict humain. Sources détaillées non optimisées pour une grande salle.
Retouche de l'inscription inventée au dos de B–17 et comparaison atelier/musée
à taille strictement identique restent à traiter.
Sauvegarde 3D réelle et boucle arrivage/atelier/galerie à définir ensuite.
Plafond 240 FPS / physique 60 Hz ; baisses au souffle dense suivies dans #50.
Arrivages #27 : ancien rendu rejeté, vision détaillée encore à approfondir.
UI #46, décor #47, sons avec Claude #48, musique #49.
Lanceur : Launch-Exhibition-Study.cmd.
Worktree : C:/Users/antoi/.codex/worktrees/preparation-demos/ArchaeologyGame.
