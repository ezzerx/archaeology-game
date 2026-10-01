# Décisions initiales

Source : décisions confirmées par Antoine au 2026-09-30 et au 2026-10-01.

## Décisions produit

| Décision | Conséquence |
|---|---|
| Tabletop fixe, sans avatar | La fouille est le centre du jeu |
| DA 2.5D stylisée, orthographique presque verticale | Relief, lumière et profondeur prioritaires |
| Pixel art non retenu pour V0.1 | Liberté de creusement et contours |
| Trois outils | Soft Brush, Chisel, Air Blower |
| Matières cœur | Loose Soil, Compact Clay, Sandstone |
| Specimen B-17 | Petit théropode fictif / indéterminé |
| Premier contact os protégé | La découverte ne punit pas instantanément |
| Bone Condition sans Game Over | Tension légère |
| Musée scrollable, non navigable | Méta-progression future |
| Godot 4.7.2 stable Standard | Stack prototype |

## Gates validées

### P0
Validé par Antoine. Merge :
`244aba3652a03aac908b1aabe1651c3b9edb1315`.

### P1
Validé par Antoine. Merge :
`960642c3fc6972bdb257c96abd43b90c148e632d`.

Décisions techniques principales :

- height RF 1024×640 ;
- grille GPU dense ;
- picking DDA sur la même topologie que le rendu ;
- stratigraphie statique irrégulière ;
- Hard Rock omis.

### P2
Validé par Antoine : les outils fonctionnent comme voulu pour le prototype.

Merge :
`9b8423fedfb4723ba8b0113a23e564ba474c8bd2`.

Décisions P2 :

- ToolDefinition minimal ;
- Brush continu ;
- Chisel impacts discrets à 4,5 Hz ;
- Blower sans excavation structurelle ;
- résidu debug léger 256×160 R8 ;
- aucun système fossile ou polish final en P2.

## Décision FPS — 2026-10-01

Pendant P2, Godot utilisait la RTX 5080 à 100% lorsque le rendu était non plafonné.

Décision d'Antoine :

- **runtime interactif normal plafonné à 240 FPS à partir de P3** ;
- benchmarks autorisés à override le plafond ;
- ne pas lancer de chantier d'optimisation GPU supplémentaire tant que le comportement à 240 FPS n'est pas retesté ;
- si nécessaire, réduire encore le cap après test humain.

## Scope P3

P3 est autorisé.

Il doit couvrir :

- fossile caché ;
- exposition progressive ;
- bone ceiling ;
- Bone detected ;
- protection premier contact ;
- condition 100→0 ;
- dégâts Chisel uniquement sur os déjà exposé ;
- Brush/Blower sûrs ;
- exposition globale/composants.

P3 ne doit pas couvrir classification, fragments, objectifs, final audio/VFX ou musée.

Référence : [P3_BRIEF](../dev/P3_BRIEF.md).

## Choix techniques P3 implémentés — validation humaine en attente

- Un champ statique aligné à la hauteur P1 porte plafond et ID de composant ; l'occupation dérive de l'ID. Même géométrie/picking, aucune texture dynamique supplémentaire.
- Quatre composants fixes de B-17 : Skull, Spine / Vertebrae, Ribs, Hind Limb. Pas de génération aléatoire ou d'asset externe.
- Exposition structurelle par cellule, epsilon binaire `1/65536` et comparaison sur les float32 réellement stockés pour accorder CPU et GPU.
- Dégât décidé sur le centre **avant** l'impact : révélation protégée puis −3 points par impact direct sur os déjà exposé. Résidu et condition indépendants.
- Événements émis après synchronisation ; compteur de composant regroupé par opération. Premier contact réarmé seulement par reset.
- Cap Godot `application/run/max_fps=240`, physique 60 Hz. Aucun changement de densité du mesh. Lectures osseuses évitées tant que le retrait reste au-dessus du plus haut plafond.

Décision complète : [P3_FOSSIL_DECISION](../dev/P3_FOSSIL_DECISION.md). Résultats et limites mesurés : [P3_REPORT](../dev/P3_REPORT.md). **Aucune validation humaine P3 ou autorisation P4 n'est inférée des tests automatiques.**
