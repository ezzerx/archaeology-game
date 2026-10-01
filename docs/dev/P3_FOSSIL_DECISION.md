# Décision P3 — Fossile dans le heightfield

Date : **2026-10-01**. Périmètre : **P3 uniquement**, Godot **4.7.2 stable Standard**.

La passe corrective suit [P3_DESIGN_FIXES](P3_DESIGN_FIXES.md), prioritaire sur le brief initial pour le zoom et la finition autour des os.

## Choix

Conserver la surface P1/P2 et y intégrer un **champ fossile statique 1024×640**. Aucun mesh d'os superposé, moteur de destruction, collider osseux ou système physique supplémentaire. `ReliefSurface` conserve sa topologie et son picking DDA.

`FossilField` rasterise une seule composition B-17, dessinée dans le code avec des capsules et des chaînes de points. Les coordonnées sont fixes : crâne avec orbite ouverte et mâchoire, vertèbres et queue courbe, cage thoracique partielle, bassin et membre postérieur replié avec trois doigts. Aucun hasard, modèle téléchargé ou asset externe. Les quatre composants sont **Skull, Spine / Vertebrae, Ribs, Hind Limb**. La classification reste hors scope.

Chaque cellule possède un ID (`0` = absence d'os) et un sommet osseux normalisé. Le sommet est légèrement bombé par section, entre **0,236786 et 0,355** ; il reste toujours sous la surface intacte à `1`. Les chevauchements appartiennent à l'os le plus haut. Le champ compte **32 290 cellules**, soit 7 756 / 7 243 / 10 771 / 6 520 par composant.

## Retrait, marge de précision et rendu

Dans la boucle locale de `WorkingSurface`, après intégration du travail dans les couches :

```text
next_height = max(material_removal_result, bone_ceiling)
exposed = bone_occupied && stored_float32_height <= bone_ceiling + 1/65536
```

Les outils appliquent en plus le workflow de précision :

- **Chisel, cellule cachée** : arrêt à `bone_ceiling + margin`, avec `margin = 0.002 / (thickness - base_height)`. Le réglage `ExcavationBlock.precision_margin_mm` vaut **2,0 mm**. Un impact énorme ou répété ne franchit pas cette marge. Si le Brush l'a déjà partiellement retirée, le Chisel conserve la hauteur courante sans la remonter.
- **Soft Brush, cellule osseuse dans la marge** : retrait lent de **1,0 mm/s au centre**, modulé par le falloff, indépendamment de Clay/Sandstone. La Resource expose `precision_speed_mm_s`. L'os impose toujours le plafond exact ; aucune perte de condition.
- **Hors marge ou hors fossile** : intégration P2 inchangée. Le Brush garde Soil **1**, Clay **0,06** (très faible efficacité existante), Sandstone **0**. Il n'obtient aucun bonus général sur les matières dures.
- **Chisel, cellule exposée** : hauteur strictement inchangée. Le centre de l'impact peut encore causer −3 points de condition.

La proximité est déduite des hauteurs, plafonds et de la marge ; **aucune map supplémentaire, aucun upload supplémentaire**. L'epsilon RF existant tolère l'arrondi au bord de la marge. Le noyau géométrique `apply_segment` reste utilisable sans règle d'outil pour les fixtures P0/P1/P3 ; les entrées joueur passent par `apply_continuous` / `apply_impact` et leurs règles de précision.

Le surplus de travail est abandonné ; même une puissance/durée énorme ne traverse pas l'os. Les cellules voisines sans os peuvent atteindre le fond `0`. L'os devient donc un volume qui ressort réellement du creux. Le résidu est calculé sur le retrait effectif après clamp. L'epsilon **1/65536 ≈ 0,00001526** est représentable exactement en float32 ; le CPU teste la hauteur après arrondi RF, comme le GPU. Au-dessus du plus haut os, les lectures du champ sont évitées.

Une texture **RGF statique** contient hauteur et ID ; l'occupation est dérivée de l'ID. Upload unique à l'initialisation. Le shader compare les **texels exacts** de hauteur RF et de fossile pour utiliser le même critère discret que les compteurs CPU. La géométrie reste interpolée comme en P1. Matériau ivoire chaud `(0,94 ; 0,87 ; 0,72)`, roughness `0,43`, specular `0,38`, sans émission osseuse. Le voile résidu reste gris et léger sur l'os (40 % au maximum, contre 80 % sur la matrice).

Coût supplémentaire persistant, hors en-têtes/pilote : texture GPU **5 Mio** statique ; CPU **8,75 Mio** (Image RGF 5 Mio, plafonds float32 2,5 Mio, IDs et flags d'exposition 0,625 Mio chacun). **Aucune nouvelle texture dynamique.** Les opérations interactives ne vérifient que le footprint ; seuls initialisation/reset et oracles de test parcourent le champ complet.

## Contact, condition et événements

`FossilState` est indépendant des outils, de l'interface et du résidu. Le centre d'un impact est résolu avec la même convention texel que le picking. `apply_impact` vérifie son exposition **avant** de retirer la matrice. Centre caché = aucun dégât, même si d'autres cellules du footprint sont déjà visibles. Centre exposé + Chisel = **−3 points maximum par impact**, configurés dans sa Resource. Brush/Blower ont zéro dommage. Condition bornée à `[0,100]`, sans destruction ou fin de partie.

Les cellules sont enregistrées après synchronisation de l'Image RF. Les observateurs voient les compteurs et la hauteur de l'opération terminée :

- `bone_first_contact(cell, component)` : une fois par spécimen/reset ;
- `bone_cell_exposed(cell, component)` : une fois par nouvelle cellule ;
- `bone_component_exposure_changed(component, exposed, total)` : au plus une fois par composant et opération ;
- `bone_condition_changed(condition, damage)` : seulement si la condition change ;
- `specimen_reset` : remise à zéro de la notification debug.

L'exposition est le nombre de cellules exposées divisé par la surface occupée, globalement ou par composant. Elle est structurelle, indépendante de la quantification/nettoyage du résidu. Une cellule représente **0,00310 %** du spécimen. La notification debug « Bone detected / Delicate material underneath » reste huit secondes ; F1 conserve le dernier événement.

Atteindre la marge au Chisel n'expose rien et n'émet pas `bone_first_contact`. Une indication textuelle contextuelle « Delicate material nearby — switch to Soft Brush » apparaît seulement sous le curseur dans cette marge cachée, puis « Precision cleaning — Soft Brush » avec le Brush. Ce texte dérivé évite tout événement répétitif ou nouvel état de découverte. L'exposition structurelle et `Bone detected` arrivent pendant la finition. Aucun son/VFX ajouté.

## Zoom de précision

`PrecisionZoom` reste une `Camera3D` orthographique à **84°**, sans rotation ni déplacement libre. Molette : **1× à 3×**, maximum et pas configurables ; interpolation exponentielle indépendante de la fréquence d'affichage. Le point 3D réellement touché par le rayon est mémorisé au début du zoom. À chaque frame, une translation dans le plan caméra maintient ce point sur le même rayon écran : cela fonctionne sur le relief, pas seulement sur un plan horizontal fictif. Hors du bloc, le zoom utilise le centre de la vue.

Le picking DDA n'est pas remplacé. Le curseur est reprojeté pendant l'interpolation. Une commande de zoom annule le geste en cours ; aucun segment ne relie des coordonnées avant/après déplacement de caméra. La perte de focus fige l'interpolation et annule le geste. Le resize contrôle également la taille native de la fenêtre, car le viewport logique reste fixe en mode stretch et son signal peut ne pas se déclencher.

`Home` / `Origine` rétablit la vue initiale sans toucher au terrain. `R` restaure terrain, état fossile et vue 1×. Les réglages développeur utilisent **F6/F7** pour rayon −/+, **Shift+F6/F7** pour puissance et **Ctrl+F6/F7** pour falloff ; aucun modificateur de molette ne modifie les outils.

API de projection : [documentation officielle Camera3D](https://docs.godotengine.org/en/stable/classes/class_camera3d.html). L'ancrage emploie `project_ray_origin`, `project_ray_normal` et le hit exact existant.

## Plafond runtime

Réglage officiel **`application/run/max_fps=240`** dans `project.godot`, lu par `Engine.max_fps`. **`physics/common/physics_ticks_per_second=60`** reste inchangé. Aucun limiteur artisanal dans `_process`. VSync conserve son réglage existant et peut imposer une fréquence inférieure. Les scripts de benchmark peuvent modifier `Engine.max_fps` dans leur processus ; cela n'écrit pas le projet.

Références officielles vérifiées, puis propriétés observées dans le binaire local : [ProjectSettings / max_fps](https://docs.godotengine.org/en/stable/classes/class_projectsettings.html#class-projectsettings-property-application-run-max-fps), [Engine / max_fps](https://docs.godotengine.org/en/stable/classes/class_engine.html#class-engine-property-max-fps). Le cap ne promet pas 240 images réelles si le rendu ou VSync limite davantage. Aucun chantier d'optimisation de la grille n'est engagé.

## Limites assumées

- Une hauteur par colonne : pas de sous-face, tunnel, surplomb ni dégagement sous un os. Un os reste une colonne non excavable ; la transition visuelle vers la matrice s'interpole sur environ un texel.
- Les normales proviennent toujours des triangles ; palette, ombres et contours restent greybox. Pas de texture finale ni de reconstruction anatomique scientifique.
- Un unique fossile et quatre IDs fixes ; pas de pipeline de production ou de génération procédurale.
- Les flags suivent des hauteurs qui ne font que descendre entre deux resets. Toute future opération de remblai demanderait une décision distincte.
- Coûts P1 conservés : ~1,31 M triangles, upload RF complet quand dirty, collider enveloppe uniquement.

Mesures, résultats et checklist humaine : [P3_REPORT](P3_REPORT.md). **P4/P5 exclus ; merge soumis à validation explicite d'Antoine.**
