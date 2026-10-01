# Décisions initiales

Source : décisions confirmées par Antoine au 2026-09-30 et au 2026-10-01. Ces décisions cadrent la préproduction ; elles ne constituent pas encore des résultats de playtest du game feel final.

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
| Godot 4.7.2 stable Standard pour le prototype | Version P0 vérifiée en headless et localement |
| Brain canonique dans le dépôt | Reprendre depuis un autre PC sans dépendre de la mémoire globale |

## Spécification de référence

La référence détaillée pour l'implémentation du prototype est :

[PROTOTYPE_V0_1_SPEC.md](../PROTOTYPE_V0_1_SPEC.md)

En cas de conflit entre une ancienne note de brainstorming et cette spec, **la spec v0.1 la plus récente prévaut pour le prototype**.

## Décisions techniques P0 — 2026-10-01

| Décision | Raison / limite |
|---|---|
| Godot 4.7.2 stable Standard, GDScript, Compatibility | Stable vérifiée officiellement, exécutée en headless puis validée localement |
| Image RF 1024×640, mask scalaire temporaire | Écriture CPU locale et inspection simple ; P0 ne lui donne volontairement aucune sémantique matière/profondeur |
| Footprint balayé entre positions à 60 Hz | Couvrir le trait sans gaps, avec falloff configurable et déterminisme pour les mêmes entrées |
| Collision plane avec rejet des côtés | Mapping précis validé en P0 ; P1 doit réévaluer le picking avec relief |
| Paramètres du DebugExcavator en Resource | Tuning accessible sans anticiper les outils finaux |
| Gate humaine avant P1 | Antoine a testé le rendu et l'interaction localement avant merge |

### Verdict P0

**Validé par Antoine le 2026-10-01.**

PR #1 mergée vers `main`, merge commit :
`244aba3652a03aac908b1aabe1651c3b9edb1315`.

P1 est autorisé.

## Points encore ouverts pour P1+

- méthode technique finale du relief / height map ;
- stratégie de picking / raycast sur surface creusée ;
- stratégie d'upload GPU lorsque plusieurs maps existeront ;
- valeurs finales de résistance, rayon, cadence et dégâts ;
- assets et samples audio de production ;
- tuning du seuil de révélation des composants ;
- comportement final du musée au-delà du concept canonique ;
- éventuelle génération procédurale, économie ou progression longue après validation du cœur.

Ne pas transformer ces points en nouvelles features hors jalon sans décision explicite.
