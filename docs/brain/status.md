# Statut canonique

**Date :** 2026-10-19

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

## Mission validée / prochaine étape
#28 / PR #53 fusionnée dans main le 17 octobre (04a8406), après validation
humaine des vrais blocs exposés et des correctifs couleur, poussière et contours.
Rapports : docs/dev/ISSUE28_PREPARED_EXHIBITS_REPORT.md et
ISSUE28_EXHIBIT_DETAIL_FIX.md.

[#27](https://github.com/ezzerx/archaeology-game/issues/27) devient la mission
courante. Antoine valide le 19 octobre les visuels pour la version test :
comptoir chaleureux, trois caisses, sélection/focus, loquet puis couvercle,
bloc entièrement couvert avant préparation. Branche codex/27-arrivals créée
sur main 04a8406 ; PR [#54](https://github.com/ezzerx/archaeology-game/pull/54)
en brouillon. Brief : docs/dev/ISSUE27_ARRIVALS_BRIEF.md.
Planche et pack : docs/visual-references/arrivals/README.md.

V1 de test exportée depuis le runtime 35b921e : sources Tripo conservées,
masters Blender et copies runtime rangés dans assets/arrivals/. Réception,
loquet/couvercle, vrais blocs couverts et retour atelier/musée implémentés.
115 contrôles automatisés passent. ZIP Windows x64 et paquet contrôlés sous
Linux ; l’exécution Windows, les transitions et la fluidité restent à tester.
Captures commentées en OpenGL logiciel ; le premier rendu Forward+ n’a pas
abouti sur le cloud, donc son éclairage doit être jugé sur le PC cible.
Rapport : docs/dev/ISSUE27_ARRIVALS_V1_REPORT.md.
Preuves : docs/dev/evidence/issue27/.

Gate : essai humain de la V1 et corrections éventuelles sur la même PR #54,
encore en brouillon. Attendre la validation explicite d’Antoine avant merge.
Aucune nouvelle mission ni modification des règles de préparation.

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
La nouvelle planche du 19 octobre remplace les anciens visuels rejetés.
Leur archive reste conservée ; leur code n'est pas repris automatiquement.

## Points de suivi
Dernière mesure galerie avant les corrections : environ 165 FPS en 1080p ;
à réévaluer après le retrait des copies de rendu en double. Cible : 240 FPS.
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
