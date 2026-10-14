# P6A4.4 — Intégration naturelle de la plaque

## Brief autorisé

Antoine autorise l’intégration naturelle proposée : contour moins découpé,
fissures liées au relief, enfouissement partiel. Garder le principe encourageant
P6A43, le feeling des outils, B-17, le rendu chaud et les protections des os.
Une seule plaque façonnée ; ni autre comportement ni génération aléatoire.

Le défaut à corriger est l’affleurement uniforme du polygone et son contour
entièrement souligné. La plaque doit être partiellement prise dans une matrice
réelle, avec une transition cohérente rendu/picking, des fissures en relief et
un morceau détaché continu portant les matières encore présentes.

## Candidat

Scène `scenes/p6a44_natural_slab.tscn`, entrée normale `Launch-Game.ps1`.
La plaque conserve son emplacement et son principe de joint, sur B-17 inchangé.
Le placement n’est pas aléatoire. Le candidat historique P6A43 reste accessible.

## Intégration dans la matrice

Le contour est façonné en 86 points usés au lieu de neuf longs segments droits.
Les joints ne soulignent plus tout le périmètre : ils forment des courbes et
branches locales qui passent sur un lit légèrement plissé. Ce relief, de faible
amplitude, et les sillons jusqu’à .55 mm sont réellement dans les hauteurs CPU/GPU,
pas seulement peints. Toutes ces formes viennent des UV, sans lecture des os.

Sur les 10 860 cellules de plaque, 4 571 sont recouvertes d’argile et 6 289
restent affleurantes ; 715 portent le sillon du lit de grès. L’argile forme des
langues inégales au nord, à l’est et au sud-ouest, jusqu’à ~3 mm de couverture
plus le remplissage local de fissure. Elle remplit les joints enterrés plutôt
que d’imprimer leur contour sur sa propre surface. La quantité locale de Soil
fragmenté acceptée est conservée et suit la nouvelle matrice.

Les modifications de hauteur/interface restent dans le rectangle local de la
plaque et sa transition courte : 19 558 cellules géologiques modifiées. Les coins
naturels, bords bruts, lumière centrée, source/plafonds B-17 et correctif orange
sont conservés. Aucun mouvement des os ni découpe de matrice d’après Bone.

## Geste et pièce détachée

Les réglages des quatre outils ne changent pas. Trois attaques espacées sur du
grès déjà visible peuvent toujours libérer la plaque, sans ordre imposé. Un joint
sous Clay ou Soil ne donne pas de crédit : un premier Pick retire le mince Clay,
puis le contact suivant peut ouvrir le joint réellement exposé. Brush reste
réservée à la terre meuble et au nettoyage accepté.

Le plafond utilisé par la plaque est désormais l’interface Stone, pour distinguer
le grès de sa couverture. Les limites de retrait, la protection des os et la voie
Chisel par érosion restent celles du principe P6A43. Le parcours automatique de
joint réussit en trois impacts après brossage local, dans trois ordres ; le trajet
Chisel témoin en demande 40. Ce dernier nombre est un parcours de test non optimal,
pas une durée humaine ou une promesse d’équilibrage identique.

Le morceau emporte les trois matières réellement restantes : Soil, Clay et Stone
sont comptés séparément. Des sommes scalaires évitent l’accumulation d’erreur
float32 détectée dans les métadonnées de volume. Le retrait physique des hauteurs
était déjà exact. Le changement de comptage est aussi vérifié sur P6A43.

Le mesh détaché partage ses sommets et reprend le relief filtré réel sur une grille
de deux texels, avec normales inclinées, trous existants et faces de tranche.
11 436 triangles sur le parcours témoin. La topologie est mise en cache une fois ;
les attributs sont préparés au reset et seuls les sommets modifiés par le travail
natif sont réévalués lors du détachement. Les projections des textures et la patine
sont celles du terrain accepté, y compris les couches visibles sur les tranches.
Le fragment conserve les joints visibles et masque ceux encore sous Clay/Soil.

L’orientation initiale des triangles du nouveau mesh ne correspondait pas à ses
normales explicites, ce qui assombrissait le morceau. Le correctif porte sur leur
orientation et la fermeture cohérente des faces, selon la convention décrite dans
la [documentation ArrayMesh de Godot](https://docs.godotengine.org/en/4.6/classes/class_arraymesh.html).
**Projection et réception des ombres sont conservées.** Le fragment ne reçoit aucun
collider de picking ; il sort du champ de travail, se pose à partir de ses seuls
sommets encore rendus, puis est libéré immédiatement au reset. Animation .58 s et
feedback existant conservés, sans nouvelle passe sonore.

## Vérification finale

**608 contrôles, zéro échec** : candidat 166, graphique natif 21, référence P6A43
150, P1 52, P5 128, miettes P4V2 91. Godot 4.7.2 / Compatibility / RTX 5080.
JSON et neuf captures dans `docs/dev/evidence/p6a44/`.

- Quantité de Soil, source/contacts/plafonds B-17 et réglages des outils conservés.
  Relief local, couverture réelle et sillons contrôlés ; aucune exposition initiale.
- Clay recouvrant un vrai joint : Brush ne l’active pas, le premier Pick enlève
  Clay sans crédit anticipé, puis le suivant peut travailler le joint Stone.
- Trois permutations via le vrai controller libèrent une seule plaque. Bonus limité
  aux cellules encore présentes : aucun remplissage, exposition ou dégât Bone induit.
  Somme des trois matières égale au volume réel retiré.
- Le haut détaché suit les données filtrées du terrain et les trous des impacts ;
  faces/normales cohérentes, reset exact et aucune reconstruction/upload au repos.
  La pièce érodée se pose aussi avec sa vraie géométrie restante.
- Un premier oracle de pose utilisait `Mesh.get_faces()`, qui arrondit la géométrie ;
  il lit désormais les vrais tableaux de sommets/indices rendus pour le contrôle
  micrométrique. Les autres géométries/source Bone n’ont pas été modifiées.
- Matrice intacte identique avec/sans modèle Bone ; crâne, colonne, côte et patte
  toujours enterrés gardent les mêmes pixels après le retrait de plaque. Un joint
  sous Clay est pixel-identique avec/sans atlas de fissures, tandis que les joints
  exposés sont effectivement visibles. Pas d’indication anticipée via la texture.
- Neuf captures : état intact, joints, deux étapes de travail, levée, pose, reset,
  nouveau gros plan et témoin P6A43 à caméra/échelle conservées. Les proxies d’outils
  sont masqués seulement dans ces captures pour laisser voir le travail artistique.

## Limites et revue humaine

Une seule plaque façonnée et un geste déjà encourageant, pas un solveur de fracture
ou un assemblage aléatoire de blocs. La grille du fragment reste plus grossière que
celle de la surface ; l’intégration artistique finale attend le verdict humain.
La couverture introduit localement un mince Clay à dégager, tout en laissant les
joints de référence accessibles et les réglages des outils identiques.

Création/commit ponctuels ~19–21 ms dans le harnais, sans mesure soutenue isolée de
240 FPS. Le premier mesh continu non mis en cache approchait 30 ms ; la mise en cache
réduit ce coût, qui reste à optimiser avant une généralisation. Cap 240 / physique
60 Hz conservés. Les fenêtres et préparations antérieures restent ouvertes.

La suite dépend de la revue : est-ce que la plaque paraît appartenir au bloc, les
joints restent-ils assez lisibles et le détachement garde-t-il son intérêt ? Aucun
verdict artistique final, nouveau comportement ou merge n’est déduit des contrôles.



## Livraison de revue

Source `1766ba7`, branche `codex/p6a44-natural-slab`,
[PR #18 DRAFT](https://github.com/ezzerx/archaeology-game/pull/18) directement sur main.
#17 est remplacée sans fusion ; ses sources, scène et verdict humain restent
conservés. Aucun merge automatique. Les autres préparations ouvertes sont
préservées.

`Launch-Game.ps1` a ouvert « B-17 · Plaque naturelle » avec Godot 4.7.2 /
Compatibility, fenêtre répondante et stderr vide. Le lancement ne vaut pas
validation artistique humaine de cette intégration.
