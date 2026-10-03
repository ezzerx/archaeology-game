# Décision P4 — Réactions de matière et finition

2026-10-03. [Brief initial](P4_BRIEF.md) complété par deux passes correctives autorisées après tests humains. Cette deuxième passe autorise Precision Pick, quatrième outil auparavant hors périmètre. PR #5 en brouillon ; aucun merge ni P5.

## Socle humain conservé

Chisel, fracture Clay/Sandstone, profondeur, lisibilité, condition moins punitive, zoom/pan et sons osseux sont validés. Brush audio suffisant pour P4. Préserver partition angulaire seedée, stress sparse, seuils, profondeurs, footprints, cadence, recul et dommages. Les ressources des trois outils existants, matériaux et ReactionProfile sont inchangées.

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
- capacité **0,02** par miette, taille maximale **1,6 × 0,352 × 1,2 mm** ;
- durée de base des éclats **1,5 s**, variation visuelle ±15 %.

Le dictionnaire d’occupation est mis à jour uniquement lors de création, nettoyage et reset. Au plus **43×27×2 = 2 322 miettes persistantes** à 1024×640. Un bin plein ne grossit plus ; une zone pleine n’acquiert plus de miette. `deposit_removed` retourne le retrait non retenu au noyau appelant ; celui-ci l’ajoute à Fine Dust au pixel excavé, **en plus** du dépôt historique. Pas de disparition silencieuse de l’excédent avant la saturation visuelle de la poussière.

Les trois matières partagent le même plafond local. Le nettoyage libère les places, R vide les compteurs. Les zones voisines disposent de leur propre budget ; aucune analyse globale de densité ni scan idle. Le choix favorise une poussière dominante et quelques grains lisibles sans inventer de timer pour le Blower.

`LooseDebrisView` emploie un MultiMesh à slots compacts et capacité croissante, met à jour les seules cases sales et se cale sur le relief réel. La rotation/position est déterministe. Une forme de grain aplati remplace le cube. Les paquets soufflés occupent les slots suivants ; F2 masque la présentation pour conserver l’oracle.

## Nettoyage et souffle

Brush retire les miettes détachées, y compris le grès, sans pouvoir retirer le grès structurel. Son efficacité Clay historique 0,06 et son nettoyage partiel de poussière restent inchangés. Aucune conversion automatique d’une matrice attachée en saleté nettoyable près de l’os.

Blower garde son nettoyage fort, orienté par le déplacement du geste ; immobile, il conserve la dernière direction (diagonale par défaut). La poussière disparaît localement avec de petites émissions d’air/poussière dirigées. Les miettes nettoyées glissent visiblement vers la frontière au-dessus du relief ; vitesse issue du rayon et du taux existants. Zéro retrait de hauteur, zéro dégât.

Les fractions proches et orientées pareil s’agrègent en paquets à moins de 16 texels de leur source. Seuls les paquets en mouvement avancent à 60 Hz ; ils s’effacent à la frontière, pas à une échéance arbitraire. Hook conservé :

`ExcavationBlock.debris_ejected(world_position, direction, amount, material_type)`

Position interpolée à la frontière, direction monde normalisée, quantité visuelle et ID de matière. L’événement concerne les miettes, pas encore la poussière diffuse ; aucune table salissable.

## Precision Pick — outil de finition structurelle P4

Ressource `config/precision_pick.tres`, ID `precision_pick`, mode **SCRAPE** ajouté après CONTINUOUS/IMPACT pour préserver leurs valeurs. Slot **4 / KP4**, bouton et proxy fin, nouvelle petite texture audio procédurale.

Choix : **LMB maintenu + mouvement**. Le déplacement limite le travail effectif à `min(delta, distance / reference_speed)` ; immobile, rien n’est retiré. Le noyau balaie une capsule minuscule couvrant aussi les mouvements rapides. Chaque texel est traité au plus une fois par tick, sans stress ni détachement de plaques.

Paramètres initiaux, **prototypes et non tuning final** :

- rayon 3 texels ; puissance 0,16 travail/s ; falloff 1,5 ;
- efficacité Soil 0,30 / Clay 0,60 / Sandstone 0,45 ;
- vitesse de référence 100 texels/s ;
- profondeur maximale 0,004 par texel/passage ;
- poussière 1,25 ; nettoyage 0 ; dégât 0.

La résistance de chaque matériau reste appliquée. Deux options locales de `WorkingSurface.apply_segment` bornent uniquement ce mode : arrêt à l’interface du matériau initial et profondeur maximale par passage. Le plafond osseux existant reste l’ultime limite, sans marge supplémentaire. La géométrie, l’exposition, le dépôt et l’événement agrégé restent dans le chemin commun de production.

Le Pick enlève lentement de **vrais restes attachés** autour des côtes/crâne. Le Brush nettoie ce qui est déjà détaché ; le Blower termine la poussière. Pick beaucoup moins efficace pour le volume que Chisel. Aucun near-bone Brush, auto-stop Chisel ou Forceps.

**Sécurité Bone provisoire P4** : Pick ne déclenche aucun dégât ; ses nouveaux contacts peuvent jouer le son de découverte, jamais le hit direct. Cette sécurité rend la finition testable sans verrouiller son équilibrage futur. Les règles Chisel restent premier contact sûr puis −3 points par centre déjà exposé, une pénalité maximum par impact.

## Audio et caméra préservés

Sept familles validées × quatre WAV protégées par empreintes SHA-256 prises sur `c25b44f` avant ajout du Pick. Sa huitième famille est **ajoutée à la fin**, les seeds historiques dépendant des indices. Brush conserve ses deux boucles continues de deux secondes, raccord, modulation mouvement/travail, attaque 80 ms et relâchement 160 ms. Huit voix ponctuelles, deux voix Brush. Nouvel audio Pick court et discret ; aucun asset externe.

`bone_revealed` = découverte ; `direct_bone_hit` = erreur, prioritaire si un même impact révèle aussi du voisinage. Notification Bone detected une fois par reset.

Caméra inchangée : orthographique 84°, zoom 1–3× au curseur, RMB drag borné, aucune rotation. Home rétablit zoom/pan, R rétablit aussi le spécimen. Changement d’outil, focus et resize annulent le geste ; un nouveau clic est requis. Debug Shift/Ctrl/Alt+molette et F6/F7 conservés. Cap 240 FPS, physique 60 Hz.

## Validation et limites

[Rapport P4](P4_REPORT.md) : tests, mesures, captures et checklist humaine. 642 checks et oracle GPU passent. Deux minutes simulées distinctes de Chisel (Clay/Sandstone) contrôlent l’accumulation, un bloc entièrement chargé contrôle le repos, le Pick est mesuré autour des os.

Les quantités agrégées sont visuelles et saturées, pas une masse physique ; pas de collisions fines entre grains ni validation subjective automatisée. Le test humain doit surtout juger la fréquence agréable du Blower, le débit/contrôle du Pick et l’envie de finir les os. DA P6 et tuning P7 non commencés.
