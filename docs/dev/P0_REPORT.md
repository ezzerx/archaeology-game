# Rapport P0 — Interaction brute

Date : **2026-10-01**. Branche : `prototype/p0-foundation`. Base initiale : `main` au commit `74b5e88dea181d7b8683a7cbb8a290928e88edf5`.

**Statut final : P0 VALIDÉ ET MERGÉ.**  
PR #1 mergée vers `main` au commit `244aba3652a03aac908b1aabe1651c3b9edb1315`.

Ce jalon vérifie l'interaction brute et la représentation de données. Il ne valide pas encore le creusement, les matériaux ni le game feel final de V0.1.

## Validation finale

### Automatisée

- Godot **4.7.2 stable Standard**
- GDScript
- renderer Compatibility / OpenGL 3
- **45 checks, 0 failures**
- import headless : PASS
- scène principale headless : PASS
- aucune erreur de script détectée

### Humaine — Antoine, 2026-10-01

Test local effectué dans Godot 4.7.2 sur PC.

Validation déclarée : **« Tout est ok sur P0 dans Godot. »**

La checklist P0 a été testée sans problème remonté :

- cadrage et rendu de la scène ;
- précision souris au centre, bords et coins ;
- traits lents et rapides ;
- traits horizontaux / diagonaux ;
- continuité du stroke ;
- sortie puis réentrée du bloc sans pont parasite ;
- reset `R` ;
- debug `F1` ;
- réglages molette / Shift / Ctrl ;
- redimensionnement et comportement réel de fenêtre ;
- réactivité locale.

Aucun défaut bloquant n'a été identifié.

## Architecture livrée

| Élément | Responsabilité |
|---|---|
| `project.godot` | Scène de démarrage, viewport 1920×1080, fenêtre initiale 1280×720, proportions conservées, physique 60 Hz |
| `scenes/prototype_main.tscn` | Primitives de table/bloc, lumière neutre, Camera3D, contrôleur, panneau debug |
| `scripts/prototype_main.gd` | Caméra, R/F1 et texte debug actualisé à 10 Hz |
| `scripts/excavation_block.gd` | Géométrie, collider, raycast indépendant de l'outil, texture et curseur shader |
| `scripts/surface_mapping.gd` | Conversions locales → UV → coordonnées continues / cellule |
| `scripts/working_surface.gd` | Image CPU, footprint balayé, falloff, saturation et reset |
| `scripts/tool_controller.gd` | Entrées, état du trait, application à 60 Hz, interruptions de focus/bounds |
| `scripts/debug_excavator.gd` + `config/debug_excavator.tres` | Resource de paramètres temporaires |
| `shaders/surface_debug.gdshader` | Niveaux de gris et cercle indiquant le rayon réellement appliqué |
| `tests/run_tests.gd` | Vérifications sans addon, incluant la scène et ses vraies collisions |

## Fondations validées

### Caméra

Caméra orthographique fixe, **84° par rapport au sol**.

### Mapping souris

Pipeline validé :

`screen → ray → hit → local → UV → map → cell`

Les côtés sont rejetés ; les bords et transformations sont testés.

### Working map

Image CPU `FORMAT_RF`, **1024×640**, utilisée comme mask scalaire temporaire.

Elle reste volontairement **sans sémantique de profondeur ou de matériau** jusqu'à P1.

### Stroke

Footprint balayé en capsule entre deux positions successives avec falloff configurable.

Ce choix évite les gaps perceptibles lors de mouvements rapides.

## Performance P0

Mesures Work headless :

- usage normal : ~**2,4–2,9 ms/tick** côté édition CPU ;
- stress diagonal extrême : ~**40–46 ms** ;
- texture complète envoyée au GPU lorsqu'elle est dirty.

Le test humain local n'a remonté aucune latence ou saccade bloquante dans l'usage normal.

Ces résultats ne valident pas encore la future charge de plusieurs maps ou du relief.

## Dette technique transmise à P1

1. **Surface et collision planes.** P1 doit décider comment le picking reste correct lorsque des creux apparaissent.
2. **Working map sans sémantique.** P1 doit introduire profondeur et matériau explicitement.
3. **Upload texture complet.** À surveiller avant multiplication des maps.
4. **Stroke linéaire entre ticks.** Suffisant pour P0 ; à réévaluer seulement si le game feel réel l'exige.
5. **Greybox uniquement.** Aucun choix de P0 ne doit être confondu avec la DA finale.

## Conclusion

P0 répond à sa mission : la souris modifie précisément et continuellement une surface de données associée au bloc, avec un socle testable et configurable.

**P0 est fermé. P1 — Matière est autorisé.**
