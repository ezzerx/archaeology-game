# Décisions initiales

Source : décisions confirmées par Antoine au 2026-09-30 et au 2026-10-01. Ces décisions cadrent la préproduction ; elles ne constituent pas encore des résultats de playtest.

| Décision | Raison / conséquence |
|---|---|
| Canoniser avant de développer | Conserver une référence claire et portable |
| ArchaeologyGame comme working title neutre | Permettre l’initialisation sans figer le nom commercial |
| Dépôt GitHub privé par défaut | Conserver la conception dans le compte d’Antoine |
| Tabletop fixe, sans personnage ni monde ouvert | Concentrer l’expérience sur les gestes de fouille et la découverte |
| Game feel prioritaire | Tester résistance, réactions, son et rythme avant le volume de contenu |
| Musée horizontal et squelettes réellement incomplets | Rendre l’acquisition de fragments tangible et motivante |
| Prototype v0.1 focalisé | Un écran, un bloc, un fossile, trois outils ; aucune production étendue |
| **DA v0.1 : 2.5D stylisée, tabletop, orthographique presque verticale** | Prioriser profondeur, cavités, ombres, poussière et révélation libre des os |
| Pixel art abandonné comme cible du prototype | Éviter que la grille et les contours intentionnels limitent la fouille |
| Références de philosophie visuelle | Assemble with Care, A Little to the Left, Potion Craft, Strange Horticulture — inspiration uniquement, aucune copie |
| Specimen B-17 pour la v0.1 | Petit théropode fictif / indéterminé, adapté à une révélation progressive |
| Outils v0.1 | Soft Brush, Chisel, Air Blower |
| Matières cœur v0.1 | Loose Soil, Compact Clay, Sandstone ; Hard Rock secondaire |
| Poussière = état gameplay | Casser → poussière → souffler → révéler |
| Premier contact os protégé | Le premier contact agressif signale l'os sans pénaliser le joueur |
| Bone Condition testée sans Game Over | Permettre une tension légère sans frustration forte |
| Deux fragments récupérables automatiquement | Faire évoluer physiquement la table et tester la collection |
| Keep Cleaning après complétion | Mesurer si le geste reste attirant une fois l'objectif déjà atteint |
| Godot envisagé, version stable à vérifier | Conserver une stack simple et adaptée à la 2.5D / shaders / maps |
| Brain canonique dans le dépôt | Reprendre depuis un autre PC sans dépendre de la mémoire globale |

## Spécification de référence

La référence détaillée pour l'implémentation du prototype est :

[PROTOTYPE_V0_1_SPEC.md](../PROTOTYPE_V0_1_SPEC.md)

En cas de conflit entre une ancienne note de brainstorming et cette spec, **la spec v0.1 la plus récente prévaut pour le prototype**.

## Points encore ouverts

Restent à tester ou décider :

- valeurs finales de résistance, rayon, cadence et dégâts ;
- méthode technique finale du relief / height map dans Godot ;
- version stable exacte de Godot ;
- assets et samples audio de production ;
- tuning du seuil de révélation des composants ;
- comportement final du musée au-delà du concept canonique ;
- éventuelle génération procédurale, économie ou progression longue après validation du cœur.

Ne pas transformer ces points en nouvelles features de v0.1 sans décision explicite.
