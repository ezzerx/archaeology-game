# P1 — Décision relief / picking

Date : 2026-10-01. Périmètre : P1 uniquement, avant validation humaine.

## Choix

Conserver la carte RF CPU 1024×640 de P0 comme **hauteur normalisée** et déplacer les sommets d'un `PlaneMesh` natif dans un shader spatial. La grille comprend 1024×640 quads (un pas par texel). Le picking CPU parcourt uniquement les cellules traversées par le rayon, puis intersecte les deux triangles qui sont réellement affichés. Même interpolation bilinéaire de la carte aux sommets, mêmes UV et même diagonale que le mesh natif.

Un spike local sous Godot 4.7.2 a inspecté les tableaux d'un `PlaneMesh` subdivisé : diagonale entre les coins (+X, −Z) et (−X, +Z). Les tests conserveront un oracle utilisant les vrais tableaux du mesh, indépendant du parcours accéléré.

La base reste un volume non excavable ; quatre jupes subdivisées suivent les hauteurs périphériques. Le collider de P0 reste une enveloppe technique, **jamais le hit final**. Le picking utilise une intersection analytique avec cette enveloppe, rejette les côtés solides et renvoie le premier triangle visible. Le cercle de contact est dessiné directement sur la surface ; après une édition le hit est recalculé.

## Alternatives

| Approche | Avantages | Motif du choix / rejet |
|---|---|---|
| Grille déplacée GPU + picking sur les mêmes triangles | Pas de reconstruction mesh/collision pendant les gestes, une map dirty, précision contrôlable | **Retenue**, validée techniquement en rendu local ; gate humaine encore ouverte |
| Mesh CPU par régions + collision actualisée | Géométrie physique native accessible | Plus de code de buffers/chunks ; reconstruire une collision dense à chaque geste est inutile pour une table sans objets physiques |
| Grille grossière + recherche itérative dans une height map dense | Géométrie moins coûteuse | Un hit bilinéaire peut différer du triangle visible, surtout aux petites empreintes et sur une paroi raide |
| Heightfield CPU dense réactualisé intégralement | Facile à expliquer | Trafic de positions/normales et édition CPU plus coûteux que la seule hauteur RF |
| Voxels / CSG | Surplombs possibles | Hors besoin : une hauteur par colonne suffit, sans moteur de destruction généraliste |

## Données et coût attendu

- Hauteur 1 = dessus intact ; 0 = fond excavable. Hauteur locale = base + hauteur normalisée × épaisseur excavable.
- Une carte de frontières RG statique, déterministe, décrit les deux interfaces ondulées. Le matériau courant est dérivé de la hauteur ; aucune material map mutable supplémentaire.
- L'édition utilise un `PackedFloat32Array`, puis synchronise l'Image RF de staging avant picking/upload. Les écritures de gameplay passent exclusivement par `WorkingSurface`, pas directement par l'Image exposée en lecture.
- Seule la hauteur est éditée localement. Un upload RF complet est effectué au plus une fois par tick modifié (2,5 Mio) : simplicité de l'API `ImageTexture.update`, à mesurer avant d'introduire un découpage en textures.
- 1 310 720 triangles de surface ; pas de coût CPU de reconstruction pendant la fouille. C'est le compromis principal à mesurer sur le PC local.

## Limites / impact sur P2

Un heightfield ne représente ni tunnels ni surplombs. Les côtés ferment le volume mais ne sont pas excavables par clic latéral. Le collider enveloppe n'est pas adapté à de futurs débris physiques : ceux-ci exigeraient une décision distincte. Les outils P2 pourront utiliser le hit monde/local/normal et l'édition locale existante ; aucune règle, animation ou compatibilité de ces outils n'est ajoutée ici. Le coût mesuré des mouvements extrêmes est signalé séparément de l'usage normal ci-dessous.

## Confirmation locale

Godot 4.7.2 / Compatibility / RTX 5080 / Ryzen 7 9800X3D, 1920×1080 : édition normale ≈2,13 ms, grands mouvements rapides ≈5,37 ms ; sessions plafonnées ≈59,8 et 59,6 FPS. Le stress synthétique coin-à-coin à chaque tick reste hors budget (≈29,84 ms d'édition et rattrapages physiques). Détails et limites : [P1_REPORT](P1_REPORT.md).

Le helper générique `Geometry3D.ray_intersects_triangle` emploie une tolérance absolue inadaptée aux triangles millimétriques : le picking utilise Möller–Trumbore avec tolérance relative. Un oracle natif redimensionné, indépendant du DDA, vérifie 180 rayons (erreur maximale ≈0,00000020 m). La lecture de 864 pixels GPU en vue hauteur confirme la cohérence affichage/picking à la précision du framebuffer 8 bits. La base ne possède pas de face supérieure doublant le fond, afin d'éviter le z-fighting à profondeur maximale.

## Références techniques

API officielles consultées le 2026-10-01 : [PlaneMesh](https://docs.godotengine.org/en/stable/classes/class_planemesh.html), [ArrayMesh et AABB personnalisée](https://docs.godotengine.org/en/stable/classes/class_arraymesh.html), [shader spatial](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/spatial_shader.html). Les propriétés et la topologie utilisées ont également été vérifiées avec le binaire local.
