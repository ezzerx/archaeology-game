# Essai de galerie — #51

## Vision validée le 17 octobre 2026
Antoine accepte provisoirement une petite galerie 3D chaleureuse, sans avatar, avec vues composées, déplacement horizontal et inspection rapprochée. B–17 et M–08 restent dans leur matrice, sur des supports adaptés. Les essais doivent permettre de juger puis d'ajuster cette direction.

## Résultat de ce premier essai
Une scène native Godot représentant une alcôve d'histoire naturelle : matériaux, éclairage, présentoirs et cartels soignés, deux exemples 3D de préparation, vue d'ensemble et inspection de chaque pièce. Navigation claire et retour simple à l'ensemble.

## Périmètre
- Réutiliser les spécimens et le langage matériel validés.
- Montrer des exemples déterministes dans leur matrice, distincts des sauvegardes du joueur.
- Vérifier salle, composition, lumière, relief, échelle et angles supportés par nos fossiles.
- Préparer un lanceur indépendant et des captures natives revues avant PR.
- Garder le gameplay, les sauvegardes et le lanceur existants.

## Exclusions
Pas de génération d'une collection complète, placement libre de meubles, avatar, extraction ni squelette monté. Pas encore de sauvegarde 3D d'une vraie préparation ou raccordement arrivage/atelier/galerie ; ces étapes suivront la revue visuelle dans #28 / #45.

## Acceptation et essai
- [ ] Vue d'ensemble cohérente avec l'atelier, au-delà d'une maquette de placement.
- [ ] B–17 et ammonite lisibles dans leur matrice aux vues choisies.
- [x] Caméra et transitions entre pièces appréciées par Antoine le 17 octobre.
- [ ] Aucun effet sur les données réelles ; scène et lanceur isolés.
- [ ] Captures revues, contrôles natifs et limites consignées.
- [ ] PR soumise à Antoine avant fusion ; aucune validation artistique déduite des tests.

Lié à #45 et #28. L'essai juge l'envie d'admirer/conserver une préparation, pas encore la boucle complète.


## Précision issue de la revue humaine
La caméra et les changements de pièce sont appréciés. Le rendu du décor est
rejeté pour la production. Concevoir la scène, l'ambiance et les supports à
partir de références, puis préparer une pipeline 3D avec Tripo.
Voir [l'étude artistique proposée](../design/MUSEUM_ART_DIRECTION_STUDY.md).
L'appréciation de la navigation ne valide pas la qualité artistique.

## Direction choisie et continuité visuelle
Antoine retient le second concept stylisé, à harmoniser avec le rendu validé de
la préparation. Le concept guide la composition et l'ambiance ; les modèles,
matières, reliefs et détails du jeu guident le traitement des blocs et du décor.
Comparer une travée avec B–17/M–08 aux préparations à taille d'écran comparable,
en vue d'ensemble et en inspection. Choix de référence distinct de l'acceptation
du futur rendu natif ; aucune modification du gameplay n'est requise.

## Retour sur le pilote de mobilier
Antoine apprécie le rendu du présentoir B–17 importé mais demande de remplacer
le cartel frontal. Continuer à harmoniser le reste de la scène avec ce niveau
artistique : présentoir ammonite, vitrine, applique, puis architecture et lumière.
Les fiches de génération sont dans le guide du mobilier ; conserver les sources
et distinguer la revue de chaque élément de l'acceptation globale de la salle.

## RÃ©fÃ©rences pour remplacer le dÃ©cor de fond
Antoine apprÃ©cie les meubles Tripo mais demande de refaire le sol, les murs et
les Ã©lÃ©ments derriÃ¨re les prÃ©parations. PrÃ©parer les images utiles Ã  cette
production : niche et fenÃªtre comme modules, quelques accessoires sobres,
matiÃ¨res de calcaire et dâ€™enduit pour les surfaces aux dimensions contrÃ´lÃ©es.
Le [pack environnement](../visual-references/museum/environment/README.md)
distingue chaque entrÃ©e Tripo des rÃ©fÃ©rences de textures. Les images ne
valident pas encore le rÃ©sultat 3D ni lâ€™architecture assemblÃ©e.
