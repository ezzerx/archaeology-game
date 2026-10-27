# Statut canonique

**Date :** 2026-10-27

## Dernière livraison retenue pour intégration
Antoine autorise explicitement la fusion de la PR
[#55](https://github.com/ezzerx/archaeology-game/pull/55) dans main le 27 octobre,
et demande la synchronisation de la copie locale de main.
Cette instruction remplace la restriction de fusion de la passe précédente.
Périmètre : finition de l’atelier et du musée, matières et éclairage, sons et
musique, optimisation du souffleur sans changement des règles de fouille.
Rapport : `docs/dev/MUSEUM_SENSORY_POLISH_REPORT.md` ; première passe :
`docs/dev/ATELIER_SENSORY_POLISH_REPORT.md`.
Lanceurs : `Launch-Museum-Polish.cmd` et `Launch-Atelier-Polish.cmd`.
Les contrôles et limites sont documentés dans le rapport ; l’autorisation de
fusion ne transforme pas les contrôles automatiques en mesures humaines.

## Références validées
P0–P5, préparations #33, ammonite #35, compacte #37, concrétions #39,
parcours marin #41 et fluidité #43 ; galerie #51 et conservation du vrai bloc
#28/#53. B–17/M–08, trois familles, outils et règles à préserver.
C reste la référence compacte ; 5–7 minutes pour la petite ammonite est une
cible, sans nouvelle durée humaine mesurée.
Le dernier bloc terminé est exposé tel quel ; meilleurs résultats, photos et
distinctions restent séparés. Archives figées, sans simulation au musée.
Les profils Game Designer / Level Designer ont été ajoutés et leur PR #57
validée le 20 octobre. Guide : `docs/agents/README.md`.

## Gate et prochaine action
Achever la fusion autorisée de #55 et vérifier la synchronisation locale.
Aucune nouvelle phase de développement n’est autorisée par cette opération.
La direction V1 fait l’objet d’une discussion : carnet de préparations et
hypothèse du Mur. Aucun des deux concepts n’est ici validé pour implémentation.
La PR #54 (arrivages) reste indépendante et n’est pas fusionnée par cette demande.

## Points de vigilance
Atelier Compatibility / musée Forward+ ; relève de processus conservée.
Plafond 240 FPS / physique 60 Hz ; pointes restantes sous souffle dense.
Grille visible à très gros zoom et limites visuelles/sonores dans le rapport.
Préserver les fichiers joueur, les archives et leurs dépendances de rendu.
Les modifications indépendantes des checkouts locaux doivent être conservées
lors de leur synchronisation. Aucun nettoyage destructif des anciennes branches.
