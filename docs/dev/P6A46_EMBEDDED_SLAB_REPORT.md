# P6A4.6 — Roche enchâssée et volume de rupture

## Brief autorisé

Antoine autorise l’essai proposé après P6A45 pour juger si ce système mérite
une place définitive dans le jeu. Transition grès/argile morcelée, influence de
surface sur l’argile, rupture périphérique progressive, volume enfoui irrégulier
et empreinte correspondante. Conserver le levier préféré, les outils et B-17.
L’essai ne vaut pas validation définitive ou autorisation de généralisation.

## Candidat jouable

Scène `scenes/p6a46_embedded_slab.tscn`, entrée `Launch-Game.ps1`.
La plaque conserve son emplacement et les joints de travail de P6A45.
Pick (4) : dégager/travailler les joints, puis maintenir sur une prise libérée
et faire un petit glissé vers le bas. Le levier, ses annulations, sa distance
et la dépose assistée de .58 s restent conservés. R recommence le spécimen.
Les scènes historiques P6A43/P6A44/P6A45 restent accessibles.

## Transition entre roche et argile

La couverture réelle est morcelée par des variations locales et trois petites
fenêtres d’érosion : des affleurements séparés appartiennent au même lit de grès.
Les limites de matière et les hauteurs sont modifiées ensemble ; la quantité
initiale de Soil reste celle de la référence. La silhouette enfouie conserve
10 860 cellules, plus grande que le seul affleurement principal visible.

L’argile porte ses propres plis, jusqu’à .65 mm avant atténuation par l’épaisseur
de couverture, et bornés pour ne jamais inverser Clay/Stone. Ces plis sont réels
dans la surface CPU/GPU. Une coloration discrète accompagne cette déformation
sur la seule surface Clay encore présente ; elle disparaît quand cette surface
est excavée. Le vrai joint Stone n’est toujours pas imprimé à travers Clay.
Toutes ces formes viennent de la géologie façonnée, indépendamment des os.

## Rupture périphérique liée au travail

Au départ, aucune fracture ne trace tout le contour. Chaque nouveau contact Pick
valide étend localement une rupture autour de la zone travaillée. Les zones se
rejoignent progressivement ; l’état mobile rend la séparation périphérique lisible.
L’érosion native peut aussi rendre la plaque mobile, sans lancement automatique.

La rupture est une petite excavation réelle, jusqu’à ~1.2 mm, de largeur et de
profondeur variables. Les hauteurs ne sont jamais remontées et la matière déjà
excavée n’est pas recréée. Un atlas accompagne les lèvres restantes, y compris sur
Clay/Soil ; il s’efface visuellement quand la surface correspondante a disparu.
Le dessous du nouveau creux n’hérite donc pas d’un contour peint en plein fond.

Ce travail reste une conséquence du vrai impact natif : cadence et nombre de
coups sont inchangés. Le retrait des trois matières est enregistré séparément ;
les événements de rupture ne consomment aucun deuxième coup ni contact Bone.
L’acteur met en cache la géométrie du bord, réinitialise les données d’état au reset
et n’actualise pas l’atlas au repos. L’annulation du levier conserve le travail
déjà effectué sur les joints et l’argile.

## Volume enfoui et empreinte commune

La profondeur constante est remplacée par quinze repères de rupture façonnés,
triangulés en facettes irrégulières. L’épaisseur sous le toit du grès varie de
**6 à 35 mm** : bosses, creux et décrochements, sans motif périodique de stries.
Les plafonds de protection Bone gardent au moins la couverture prévue par la
référence ; aucune extraction ne traverse un os ou ne l’expose automatiquement.

Une seule donnée de rupture définit à la fois les hauteurs finales de la matrice
et le dessous du morceau. Les normales inférieures suivent désormais cette forme.
Sur le parcours témoin, 2 649 sommets intérieurs sont comparés au fond réellement
rendu : accord à moins d’un micromètre, y compris après les impacts natifs.
La pièce conserve ses trous, ses couches et les marques de surface sur la matière
restante, avec projection et réception d’ombres. Sa topologie P6A44 reste en cache.

Un hook `_plate_floor_at` dans l’acteur P6A43 permet ce volume propre au candidat.
Son comportement par défaut reproduit exactement l’ancien calcul ; P6A45 est
retesté comme témoin de régression. Aucun réglage des quatre outils, source B-17,
champ Bone ou interaction de collection n’est modifié.

## Vérification et preuves

**729 contrôles, zéro échec** : candidat 218, natif 38, référence P6A45 202,
P1 52, P5 128 et miettes P4V2 91. Dix-sept captures natives générées, dont neuf
étapes/comparaisons conservées dans le dépôt. Sur le parcours témoin, la rupture
passe par 665 / 1 278 / 1 343 cellules aux trois impacts, sans libération automatique.
4 016 cellules de plaque restent couvertes et 6 844 sont affleurantes au départ.
Le commit de retrait mesure ~18.5–18.9 ms dans ce harnais headless non isolé.


Commandes : Godot 4.7.2 stable, script `tests/run_p6a46_embedded_slab.gd`, modes
`tests` (headless) et `visual` (renderer natif Compatibility / RTX 5080).
Les sorties complètes sont sous `work/test-logs/p6a46/`. Les JSON et captures
retenus sont dans `docs/dev/evidence/p6a46/`.

Les contrôles couvrent :
- outils, source, contacts, Brush courte, dégâts locaux et session hérités ;
- géologie locale, quantité de Soil, épaisseur variable et interfaces non inversées ;
- progression de rupture, retrait réel limité, un seul impact natif et zéro upload
  de fracture au repos ;
- vraie entrée souris, levier immobile/inversé, annulations, réussite unique et reset ;
- géométrie continue, faces/normales, volume retiré, empreinte/underside commune
  et pose du morceau restant hors domaine de fouille ;
- comparaison source Bone visible/absente sur matrice intacte, pendant le levier
  et après retrait ; aucun pixel ou caster caché anticipé ;
- visibilité des plis Clay indépendants de l’atlas Stone et de la première rupture
  périphérique ; comparatifs natifs de lumière et ombres exposées préservés.

Les comparatifs de plaque sont à fenêtre, caméra et échelle conservées. Une étude
native retourne temporairement le vrai morceau pour inspecter son dessous ; elle
appartient seulement au harnais, sans nouveau mode ou commande dans le jeu.

## Limites et revue humaine

Une seule roche façonnée ; ni génération aléatoire ni solveur volumétrique général.
Le volume respecte la représentation de fouille actuelle : profondeur variable,
sans surplombs latéraux arbitraires. Le mesh détaché reste sur une grille de deux
texels et le bord du creux suit la résolution native. Le levier demeure une
prévisualisation attachée réversible, suivie d’un commit et d’une dépose assistée.

Le coût ponctuel du retrait reste mesuré dans le harnais, sans nouvelle preuve
soutenue isolée de 240 FPS. Cap 240 / physique 60 Hz conservés. La lumière P6A45
reste inchangée et le Sound Design est différé.

Le verdict humain doit porter sur la cohérence plaque/argile, la lecture du moment
où elle se libère, l’effet de masse et de profondeur, et l’envie de rencontrer
ce type de situation sur d’autres blocs. Les contrôles ne décident pas de retenir
ce système définitivement, de le généraliser ou de fusionner la branche.


## Livraison native

`Launch-Game.ps1` ouvre « ArchaeologyGame — B-17 · Roche enchâssée » avec Godot
4.7.2 / Compatibility ; fenêtre répondante et stderr vide au lancement.
L’ouverture de cette version ne vaut pas verdict artistique ou décision finale
sur le système. Les anciennes scènes et branches restent conservées.
