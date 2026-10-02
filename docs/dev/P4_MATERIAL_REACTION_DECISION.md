# Décision P4 — Réactions de matière et nettoyage

2026-10-02. Source : [P4_BRIEF](P4_BRIEF.md), complété par la passe corrective explicitement demandée après le premier test humain. P4 uniquement ; ni merge ni P5.

## Fracture conservée

Le test humain a confirmé le plaisir du Chisel et la fracture Clay/Sandstone : Antoine a continué environ 15 minutes alors qu'il devait arrêter. La partition angulaire seedée, le stress sparse, les seuils, les profondeurs, le footprint et les plafonds osseux restent identiques. Marks → cracks → chunks, sans retour à un effacement circulaire.

Le heightfield RF reste l'autorité géométrique et le picking DDA utilise toujours ses triangles. Un impact reste dans la couche initialement touchée. Atlas de stress RG8 : 242×133, 64 372 octets. Le noyau historique `apply_segment` reste disponible ; aucun changement des ressources de tuning des outils/matériaux/réactions.

## Deux états persistants de saleté

**Fine Dust** conserve `SurfaceResidue` : accumulation float CPU, carte R8 256×160, dépôt lié au retrait réel. Aucune décroissance temporelle. Les taux historiques de nettoyage restent inchangés : Brush partiel, Blower fort. Le shader remplace le voile orange par une distribution stable de grains et de petites accumulations, avec variation de couleur et de rugosité. Le dépôt recouvre partiellement fissures et os ; aucun déplacement géométrique.

**Loose Debris** est un état secondaire `LooseDebris`, distinct des trois matériaux structurels. Dictionnaire sparse de cases 8×8 texels par matière source ; chaque case accumule une quantité visuelle normalisée de matière réellement retirée, plafonnée à 1. Ce nombre n'est pas une masse physique. À 1024×640, au plus 30 720 cases matière peuvent être occupées. Aucun rigid body, collider ou modification du bone ceiling. Positions irrégulières déterministes ; reset exact.

Les miettes restent jusqu'au nettoyage. Brush enlève les miettes détachées, y compris de grès, sans acquérir la capacité de creuser le grès. L'efficacité Clay historique de 0,06 reste inchangée. Une matrice encore attachée reste structurelle : aucune conversion automatique d'un reste dur en matière sûre à proximité des os et aucune marge de 2 mm.

`LooseDebrisView` emploie un MultiMesh à capacité croissante, avec slots compacts et mises à jour des seules cases sales. La hauteur de pose vient du relief réel et se rafraîchit quand le substrat est excavé. Au repos, aucune simulation ni traversée des cases persistantes. F2 masque les effets et la saleté de présentation pour conserver l'oracle GPU.

## Souffle et éjection

Blower nettoie la Fine Dust et met en mouvement les miettes compatibles. La direction suit le déplacement du geste ; immobile, il conserve la dernière direction, avec une direction diagonale initiale. La vitesse de transport dérive du rayon et du taux de nettoyage existants ; aucune ressource de tuning n'est modifiée.

Les fractions nettoyées proches et orientées pareil sont regroupées en paquets visuels tant qu'ils restent à moins de 16 texels du point de départ. Leur quantité s'additionne exactement. Cette approximation évite un nouveau petit objet à chaque tick. Seuls les paquets en mouvement sont avancés à 60 Hz ; ils glissent au-dessus du relief sans collision gameplay et disparaissent à la frontière, pas au bout d'une durée arbitraire.

`ExcavationBlock.debris_ejected(world_position, direction, amount, material_type)` signale alors leur sortie. Position interpolée à la frontière du bloc, direction monde normalisée, quantité visuelle et ID de matière. Le futur atelier peut consommer cet événement ; aucune table salissable n'est implémentée. L'événement concerne les miettes, pas encore la poussière fine diffuse.

## Audio et sémantique osseuse

Brush utilise deux textures WAV bouclées de deux secondes, à raccord continu, croisées selon la matière. Une seule mise en route du couple par reset ; modulation de volume/pitch, attaque 80 ms, relâchement 160 ms, absence de travail → silence. Le mouvement fournit l'essentiel de l'intensité ; le retrait/nettoyage réel la module légèrement. Une brosse immobile reste presque silencieuse. Plus de grains Brush redéclenchés toutes les 95 ms.

Sept familles de sons procéduraux × quatre variantes, sans asset externe. Deux voix continues s'ajoutent aux huit voix ponctuelles. Les sons du Chisel restent inchangés.

- `bone_revealed` : de nouvelles cellules osseuses apparaissent ; tik aigu, bref et doux, sans supposer un dommage.
- `direct_bone_hit` : impact dont le centre était déjà exposé et dont l'outil peut infliger un dégât ; clack plus grave/résonant. Ce son prend priorité si le même impact révèle aussi des cellules voisines.

Premier contact protégé et au maximum une pénalité par impact, comme en P3. Brush/Blower ne produisent aucun faux contact direct. La notification specimen-level Bone detected reste une fois par reset.

## Caméra

RMB maintenu + drag déplace directement la caméra dans son plan. Orthographique, angle fixe de 84°, pas de rotation. La projection du bloc doit garder une bande visible de 15 % de la plus petite dimension bloc/viewport sur chaque axe ; les limites restent compatibles avec le cadrage à 3×. Quatre projections de coins suffisent pour borner un changement de vue.

Le zoom 1–3× reste ancré au point réellement touché après pan. Un pan annule le stroke et capture les événements souris, y compris au-dessus de l'UI ; LMB pendant le pan n'arme aucun outil. Relâchement, perte de focus, sortie de fenêtre et resize terminent le geste. Home restaure exactement transformée et zoom initiaux ; R restaure aussi le spécimen. Les modificateurs de molette et F6/F7 restent inchangés.

Résultats, limites et retest : [P4_REPORT](P4_REPORT.md).
