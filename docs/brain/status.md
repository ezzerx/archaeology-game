# Statut canonique

**Date :** 2026-10-17

## Références validées
P0–P5, préparations #33, ammonite #35, terre compacte #37, concrétions #39,
parcours marin #41 et fluidité #43 retenus après essai humain.
B–17/M–08, trois familles, outils, matières et art à préserver.
C reste la référence de rythme compacte ; 5–7 minutes reste la cible de la
petite ammonite, sans nouvelle durée humaine mesurée.

Galerie #51 : base visuelle et correctif de netteté validés par Antoine.
PR #52 fusionnée sur main 085b6a8 ; issue fermée, branche distante et locale
nettoyées. La qualité artistique pourra encore être améliorée.
Rapport : docs/dev/ISSUE51_GALLERY_CLARITY.md.
La copie historique locale de main comporte des changements indépendants
préservés ; cette mission repart du main distant fusionné dans preparation-demos.

## Mission active
[#28](https://github.com/ezzerx/archaeology-game/issues/28) : conserver et exposer
le vrai bloc préparé, puis le retrouver identique après relance.
Branche codex/28-prepared-exhibits créée depuis main 085b6a8.
Brief actif : docs/dev/ISSUE28_PREPARED_EXHIBITS.md.
Rapport : docs/dev/ISSUE28_PREPARED_EXHIBITS_REPORT.md.
PR [#53](https://github.com/ezzerx/archaeology-game/pull/53) ouverte pour essai.
Gate : implémentation et vérifications terminées ; attendre la revue humaine.
Aucune fusion de cette nouvelle mission sans revue d’Antoine.

Le dernier bloc terminé de chaque espèce devient la pièce exposée, avec matière,
nettoyage et dégâts réels ; aucune substitution silencieuse par un meilleur
résultat ancien. Préserver photos, meilleurs scores et distinctions historiques.
Les trois préparations restent identiques ; les places encore vides ne dévoilent
pas les espèces. L’archivage 3D est figé, sans simulation de fouille au musée.

## Parcours / limites techniques
Vision : docs/design/FIRST_EXHIBITION_PLAN.md.
Direction artistique : docs/design/MUSEUM_ART_DIRECTION_STUDY.md.
Atelier en Compatibility, galerie en Forward+ ; relève de processus pour cette
passe, avec chargement et changement de fenêtre. Le renderer commun et la
transition continue demandent une comparaison dédiée des trois préparations.
Nouveaux lanceurs : Launch-Prepare-For-Museum.cmd, Launch-Museum.cmd.
Les lanceurs d’essais précédents restent disponibles.

Ordre confirmé : netteté validée → vrais blocs exposés #28 → caisses #27.
Les caisses rejetées ne constituent pas une référence ; définir leur vision
avant développement. Pas de nouvelle passe caisses dans #28.

## Points de suivi
Galerie avec deux vrais blocs : environ 165 FPS en 1080p, sous la cible 240 FPS.
Archives de 7–10 Mo par tentative ; transition de fenêtre de 7–8 s.
Préparation préservée. Mesures et limites détaillées dans le rapport #28.
Plafond 240 FPS / physique 60 Hz ; souffle dense suivi dans #50.
UI #46, décor #47, sons avec Claude #48, musique #49.
Retouche de l’inscription inventée au dos de B–17 à traiter.
Sources Tripo : assets/museum/source/tripo-studio/ ; dépôt utilisateur :
C:/Users/antoi/Documents/ArchaeologyGame-Assets/Tripo/museum/.
Toujours fournir les réglages adaptés avant chaque génération ; travailler
sur copie pour optimiser, conserver les originaux.
Worktree : C:/Users/antoi/.codex/worktrees/preparation-demos/ArchaeologyGame.
