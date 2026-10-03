# Décision P4 — Réactions de matière et finition

2026-10-03. [Brief initial](P4_BRIEF.md) complété par trois passes correctives autorisées après tests humains. La deuxième a introduit Precision Pick ; la troisième autorise son réglage et corrige uniquement contact visuel, poussière, souffle et lecture des miettes. PR #5 en brouillon ; aucun merge ni P5.

## Socle humain conservé

Chisel, fracture Clay/Sandstone, profondeur, lisibilité, condition moins punitive, zoom/pan et sons osseux sont validés. Brush audio suffisant pour P4. Partition angulaire seedée, stress sparse, seuils, profondeurs, footprints, cadence et dommages conservés. Les ressources des trois outils existants, matériaux, ReactionProfile et audio sont inchangées. Seule l’animation visuelle du recul est adaptée pour maintenir la pointe au contact.

Le heightfield RF reste l’autorité géométrique ; picking DDA sur ses triangles. Un impact ne dépasse pas sa couche initiale ni le bone ceiling. Atlas de stress RG8 : 242×133, 64 372 octets. Le noyau continu historique conserve ses valeurs par défaut ; les limites de grattage sont opt-in, réservées au Pick.

## Trois catégories de débris

| Catégorie | État / autorité | Vie et rendu |
|---|---|---|
| Transient Chunks | Feedback seul, consommateur des fractures ; aucune quantité structurelle détenue | Gros éclats Clay/Stone de 3–6 mm, envol/rebond visuels, expiration 1,275–1,725 s, pools fixes de 48 par famille |
| Loose Debris | Saleté secondaire sparse, distincte des matériaux attachés et du picking | Petites miettes persistantes par bin 8×8 et matière, position irrégulière stable, grains aplatis MultiMesh |
| Fine Dust | Accumulation float CPU, texture R8 256×160, aucun déplacement géométrique | Trace persistante dominante, grains/taches/rugosité du shader ; pas de décroissance au repos |

Quatre familles transitoires historiques conservées (Soil, Clay, Stone, Air), **192 particules maximum au total**, sans rigid body ni collider. Leur expiration ne peut jamais effacer la vraie saleté.

### Budget local des miettes

`config/debris_profile.tres` règle seulement la rétention et la présentation :

- zone de **3×3 bins = 24×24 texels** ;
- **2 miettes maximum**, compteur partagé entre Soil/Clay/Stone ;
- fraction retenue **8 % maximum** du retrait ; moyenne par 64 texels du bin ;
- capacité **0,02** par miette, taille maximale **1,4 × 0,196 × 1,05 mm** ;
- durée de base des éclats **1,5 s**, variation visuelle ±15 %.

Le dictionnaire d’occupation est mis à jour uniquement lors de création, nettoyage et reset. Au plus **43×27×2 = 2 322 miettes persistantes** à 1024×640. Un bin plein ne grossit plus ; une zone pleine n’acquiert plus de miette. `deposit_removed` retourne le retrait non retenu au noyau appelant ; celui-ci l’ajoute à Fine Dust au pixel excavé, **en plus** du dépôt historique. Pas de disparition silencieuse de l’excédent avant la saturation visuelle de la poussière.

Les trois matières partagent le même plafond local. Le nettoyage libère les places, R vide les compteurs. Les zones voisines disposent de leur propre budget ; aucune analyse globale de densité ni scan idle. Le choix favorise une poussière dominante et quelques grains lisibles sans inventer de timer pour le Blower.

`LooseDebrisView` emploie un MultiMesh à slots compacts et capacité croissante, met à jour les seules cases sales et se cale sur le relief réel. La rotation/position est déterministe. Une écaille asymétrique à six côtés et faces orientées vers l’extérieur remplace le grain arrondi de la deuxième passe. Les paquets soufflés occupent les slots suivants ; F2 masque la présentation pour conserver l’oracle.

La matière attachée reste dans le heightfield ; les miettes et FX n’entrent jamais dans le picking. F1 précise la surface réellement touchée (STRUCTURAL/BONE), le nombre de miettes voisines à 2 texels et les FX à moins de 4 mm. Ce sont des compteurs de voisinage, pas de nouveaux colliders. Un relief orange persistant après expiration des éclats reste de la Clay structurelle : le Pick travaille cette hauteur, le Brush/Blower nettoient les miettes qui la recouvrent.

## Contact des proxies

L’ancien ancrage `hit.world` avec rotation fixe pouvait enfoncer le manche dans une pente. Une normale seule ne résout pas la paroi opposée d’une cavité concave. `ToolProxyPose` utilise donc un repère continu issu de la normale, redresse progressivement l’outil en profondeur et conserve une inclinaison minimale pour voir la pointe depuis la caméra.

La pointe réelle du mesh et le pivot restent au hit ; les extrémités sont effilées vers ce contact. Le recul du Chisel étire uniquement le proxy depuis ce pivot. Aucun déplacement du curseur, rayon, caméra, collider ou heightfield.

Une protection purement visuelle remet les sommets du côté positif du plan de contact et au-dessus du relief. Elle vérifie aussi centres, milieux d’arêtes et sous-centres des faces, puis relève les sommets partagés des seules faces en conflit. La pointe est protégée ; marge locale de 0,1 mm, avec réserve de 0,9 mm uniquement sur une face en conflit. Le mesh peut se déformer localement dans une cavité extrême : c’est un proxy de présence, pas un outil physique.

Topologie fixe : au plus 2 592 sommets rendus pour le Brush. Sommets uniques et échantillons du relief local réutilisés ; exclusion des faces au-dessus du relief local maximal ; aucun balayage global. Pose inchangée + aucun upload height = résultat conservé exactement. Lire les tableaux de sommets du renderer : `Mesh.get_faces()` quantifie son maillage dérivé et fausse les contrôles submillimétriques.

## Rendu Fine Dust

La carte R8 et l’accumulation float restent inchangées. Le shader compose des amas de l’ordre du centimètre, des taches intermédiaires et des speckles plus fins, avec déformation de leurs contours. L’accumulation étend la couverture ; teinte beige/grise, rugosité et baisse du spéculaire rendent le dépôt distinct de la Clay orange. Aucun nouveau node de saleté et aucune expiration au repos.

## Nettoyage et souffle

Brush retire les miettes détachées, y compris le grès, sans pouvoir retirer le grès structurel. Son efficacité Clay historique 0,06 et son nettoyage partiel de poussière restent inchangés. Aucune conversion automatique d’une matrice attachée en saleté nettoyable près de l’os.

Blower garde son nettoyage fort, orienté par le déplacement du geste ; immobile, il conserve la dernière direction (diagonale par défaut). Les miettes nettoyées glissent visiblement vers la frontière au-dessus du relief ; vitesse issue du rayon et du taux existants. Zéro retrait de hauteur, zéro dégât.

Pour Fine Dust, `SurfaceResidue` produit au plus **16 packets temporaires `{point, amount}` par action**. Les quantités réellement retirées sont regroupées dans une grille locale 4×4 ; le point représentatif est une cellule effectivement nettoyée, jamais un centroïde dans un trou propre. La somme des quantités correspond à `last_cleared`. L’événement copie ces packets ; ils sont remplacés à l’action suivante/reset et ne sont jamais rejoués au repos.

`MaterialFeedback` transforme ces sources en bouffées douces dans le pool AirDust existant (**48 maximum**, toujours 192 FX au total). Départ sur le relief de la source, vitesse horizontale 0,13–0,19 m/s dans le jet, soulèvement 0,018–0,035 m/s, dispersion latérale, expansion, ralentissement et extinction après 0,55–0,9 s. Surface visuelle liée à la quantité retirée, taille et opacité plafonnées ; les émissions excédentaires sont omises si le pool est plein. Aucune masse gameplay dans les FX, aucune poussière rigide, aucun changement des taux de nettoyage. La texture radiale est procédurale ; le billboard conserve explicitement l’échelle des instances.

Les fractions proches et orientées pareil s’agrègent en paquets à moins de 16 texels de leur source. Seuls les paquets en mouvement avancent à 60 Hz ; ils s’effacent à la frontière, pas à une échéance arbitraire. Hook conservé :

`ExcavationBlock.debris_ejected(world_position, direction, amount, material_type)`

Position interpolée à la frontière, direction monde normalisée, quantité visuelle et ID de matière. L’événement concerne les miettes, pas encore la poussière diffuse ; aucune table salissable.

## Precision Pick — outil de finition structurelle P4

Ressource `config/precision_pick.tres`, ID `precision_pick`, mode **SCRAPE** ajouté après CONTINUOUS/IMPACT pour préserver leurs valeurs. Slot **4 / KP4**, bouton et proxy fin, nouvelle petite texture audio procédurale.

Choix : **LMB maintenu + mouvement**. Le déplacement limite le travail effectif à `min(delta, distance / reference_speed)` ; immobile, rien n’est retiré. Le noyau balaie une capsule minuscule couvrant aussi les mouvements rapides. Chaque texel est traité au plus une fois par tick, sans stress ni détachement de plaques.

Paramètres de la troisième passe, **prototypes et non tuning final** :

- rayon 3 texels ; puissance **0,22** travail/s (avant 0,16) ; falloff 1,5 ;
- efficacité Soil 0,30 / Clay **0,75** / Sandstone **1,00** (avant 0,30 / 0,60 / 0,45) ;
- vitesse de référence **40 texels/s** (avant 100), pour rendre les petits gestes de finition perceptibles ;
- profondeur maximale 0,004 par texel/passage ;
- poussière 1,25 ; nettoyage 0 ; dégât 0.

La résistance de chaque matériau reste appliquée. Deux options locales de `WorkingSurface.apply_segment` bornent uniquement ce mode : arrêt à l’interface du matériau initial et profondeur maximale par passage. Le plafond osseux existant reste l’ultime limite, sans marge supplémentaire. La géométrie, l’exposition, le dépôt et l’événement agrégé restent dans le chemin commun de production.

Débit nominal central Clay **0,055** profondeur/s ; Sandstone **0,0275**, donc deux fois plus résistant malgré son efficacité augmentée. À 30 texels/s sur 0,4 s, le test mesure **0,01650 / 0,00825** de retrait central. Le rayon, la limite par passage, l’arrêt de couche et la sécurité osseuse ne changent pas. Le Chisel reste nettement supérieur pour le volume.

Le Pick enlève lentement de **vrais restes attachés** autour des côtes/crâne. Le Brush nettoie ce qui est déjà détaché ; le Blower termine la poussière. Pick beaucoup moins efficace pour le volume que Chisel. Aucun near-bone Brush, auto-stop Chisel ou Forceps.

**Sécurité Bone provisoire P4** : Pick ne déclenche aucun dégât ; ses nouveaux contacts peuvent jouer le son de découverte, jamais le hit direct. Cette sécurité rend la finition testable sans verrouiller son équilibrage futur. Les règles Chisel restent premier contact sûr puis −3 points par centre déjà exposé, une pénalité maximum par impact.

## Audio et caméra préservés

Sept familles validées × quatre WAV protégées par empreintes SHA-256 prises sur `c25b44f` avant ajout du Pick. Sa huitième famille est **ajoutée à la fin**, les seeds historiques dépendant des indices. Brush conserve ses deux boucles continues de deux secondes, raccord, modulation mouvement/travail, attaque 80 ms et relâchement 160 ms. Huit voix ponctuelles, deux voix Brush. Nouvel audio Pick court et discret ; aucun asset externe.

`bone_revealed` = découverte ; `direct_bone_hit` = erreur, prioritaire si un même impact révèle aussi du voisinage. Notification Bone detected une fois par reset.

Caméra inchangée : orthographique 84°, zoom 1–3× au curseur, RMB drag borné, aucune rotation. Home rétablit zoom/pan, R rétablit aussi le spécimen. Changement d’outil, focus et resize annulent le geste ; un nouveau clic est requis. Debug Shift/Ctrl/Alt+molette et F6/F7 conservés. Cap 240 FPS, physique 60 Hz.

## Validation et limites

[Rapport P4](P4_REPORT.md) : tests, mesures, captures et checklist humaine. Les régressions historiques sont conservées ; les nouvelles suites contrôlent contact, intérieur des faces, sources du souffle, accumulation réellement rendue à 1×/3× et retrait Clay/Stone. Le benchmark couvre aussi le Pick dans chaque matière et le proxy Brush sur cavité/relief osseux.

Les quantités agrégées sont visuelles et saturées, pas une masse physique ; pas de collisions fines entre grains ni validation subjective automatisée. Le test humain doit surtout juger le contact des outils, la saleté au dézoom, le mouvement du souffle, le débit/contrôle du Pick et la distinction attaché/détaché. DA P6 et tuning P7 non commencés.
