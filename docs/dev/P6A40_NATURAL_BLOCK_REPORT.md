# P6A4.0 — Premier bloc naturel

GO Antoine du 2026-10-14 : premier bloc aux formes naturelles, squelette et
interactions validées conservés ; correction du contour orange si un fix est
identifié ; modèle de lampe à dégager de la surface de travail.
Base : candidat centré cf19051 / PR #13, sans code de lampe mobile.

## Périmètre

Une empreinte B-17 façonnée, indépendante des os : silhouette asymétrique,
pans cassés, épaisseur qui suit le relief existant. Masque de domaine commun au
rendu, à la matière initiale et au picking. Parois déplacées par la vraie heightmap.
Les coins retirés n’ont aucune matière à creuser. Pas de nouveau matériau ni outil.

La lampe décorative et l’ancien modèle de lampe sont hors rendu pour libérer la
vue à tous les zooms ; la source réelle chaude et centrée reste inchangée.

## Contour orange — cause reproduite et correction

Le plafond Bone participe à l’interpolation des sommets de terrain. Dans des
cellules voisines déjà creusées à l’interface du grès, cette interpolation fait
apparaître de l’argile orange qui dessine l’os. Reproduction native contrôlée au
bassin/vertèbres, avec ancien et nouveau calcul sur **le même état de fouille** :
328 cellules faussement Clay identifiées par un oracle CPU de triangles, et
2 531 pixels orange corrigés dans la région de comparaison.

Le shader utilise les hauteurs/interfaces discrètes réelles de la cellule,
uniquement au voisinage d’un os effectivement exposé, sur la matrice et non sur
l’os. Le matériau renvoyé par le pointeur suit ce même calcul ; 328 contacts
réels vérifiés, zéro mauvais matériau. Coordonnées, normales, hauteurs et
contacts Bone restent inchangés. État complet de préparation identique avant/après.
Les vrais restes Clay restent présents ; aucune matière n’est supprimée pour
cacher le contour. Le masque est vide à l’état enterré, vidé synchroniquement au
reset, mis à jour lors de nouvelles révélations et jamais uploadé à l’arrêt.

## Domaine et interactions

Empreinte dessinée sans lire la disposition des os, 48 points de silhouette ;
116 925 cellules hors bloc (17.84 % du rectangle). Les 25 404 cellules Bone et
leurs plafonds restent byte-identiques ; aucun os coupé. 3 296 segments de bord
forment les parois à hauteur du terrain réel, 6 592 triangles de paroi. L’ancien
socle rectangulaire et le jacket de revue sont masqués dans ce candidat.

Les zones retirées sont à hauteur logique zéro et exclues du shader et du picking.
Une option de domaine vide conserve exactement le picker rectangulaire historique.
Un rayon rasant ne peut pas sélectionner le dessus à travers une paroi naturelle.
Les cinq fixtures/reset conservent les vides, sans changer les kernels de travail.

Les miettes emploient le même mouvement et la même évacuation aux nouveaux bords.
Un bin de dépôt 8×8 peut chevaucher le contour : son jitter est replacé sur la
cellule solide la plus proche **du même bin**, sans changer propriétaire, matière,
quantité ou budget. Test intégré : dépôt réel dans un tel bin, déplacement physique,
évacuation au contour et libération du propriétaire logique. Pas de miettes posées
sur un coin rectangulaire invisible.

## Vérification

**401 contrôles finaux, zéro échec :** candidat headless 105 (85 hérités B-17),
graphique natif 25, régression picker P1 52, P5 128, miettes P4V2 91.
Godot 4.7.2 / Compatibility / RTX 5080. Preuves JSON et dix captures dans
`docs/dev/evidence/p6a40/`.

- Matrice intacte : viewport entier pixel-identique avec modèle retiré, caster
  absent. Révélation partielle : régions réellement enterrées de mâchoire,
  vertèbre, côte et patte pixel-identiques avec modèle retiré. Chaque cellule du
  masque de correction borde un os exposé ; aucune référence aux os cachés.
- Géométrie/source : 83 431 triangles et 25 404 plafonds conformes ; erreur maximale
  6.62e-9 m de l’oracle indépendant, 370 contacts source sans écart. Pick natif
  intégral : 4 716 impacts, 100 % révélé et nettoyé, Condition 100, distinction active.
- Coins hors bloc non sélectionnables, intérieur accessible, pas de sélection
  à travers les parois ; source centrée conservée. Ancienne et nouvelle lampe
  décorative restent invisibles à travers F8/F11/F12 ; capture zoomée de la partie
  supérieure accessible au Pick.
- Ombres des os dégagés visibles, lumière latéralement équilibrée conservée.
  Cap 240 FPS / physique 60 Hz ; aucune nouvelle validation soutenue isolée de FPS.

Le harnais initial de miette injectait un fragment sans propriétaire logique et
produisait une erreur de callback. Il a été remplacé par un vrai dépôt suivi de
son évacuation ; l’ultime exécution headless est sans erreur, pas seulement sans
assertion de test. Cette vérification a aussi motivé la gestion des bins de bord.

## Limites de l’essai

Une seule forme façonnée, pas un générateur ou un catalogue. Le relief supérieur
et la géologie acceptés sont conservés ; l’irrégularité est celle du contour et
des parois qui suivent ce relief, sans nouvelle famille de matières ou fractures.
Le bord suit la résolution millimétrique actuelle. Les captures du contour
utilisent une coupe QA annoncée ; elles ne rejouent pas exactement la session
humaine. L’amélioration artistique reste à valider en fouille réelle. Des restes
d’argile effectivement présents restent naturellement possibles près des os.


## Livraison native

`Launch-Game.ps1` ouvre le candidat naturel par défaut sur cette branche.
Fenêtre « B-17 · Bloc naturel » lancée avec Godot 4.7.2 / Compatibility,
répondante et sans erreur stderr. Les sessions précédentes sont préservées.
La référence main n’a pas été fusionnée ou remplacée automatiquement.


Source `ab6ba7a`, branche `codex/p6a40-natural-block`,
[PR #14 DRAFT](https://github.com/ezzerx/archaeology-game/pull/14) directement sur main.
Elle inclut le recentrage et remplace la PR #13, fermée sans merge. La PR #12
mobile non retenue est également fermée ; ses sources restent sur sa branche.


## Retour humain — silhouette et bords

Antoine juge la silhouette irrégulière déjà bien meilleure. Les captures zoomées
montrent toutefois des flancs droits et une arête supérieure trop nette, avec un
aspect découpé à la disqueuse ; il souhaite davantage de caractère brut.
C’est un retour positif sur la silhouette, pas une validation artistique complète
du bloc. Aucun verdict distinct reçu ici sur le contour orange ou la lampe.

Recommandation : reprendre les volumes de la bande extérieure avec des cassures
anguleuses de tailles variées, des pans inclinés et une arête irrégulièrement
ébréchée ; rendre la matière des flancs plus lisible et atténuer les petites
marches répétées du bord. Préserver domaine de fouille, squelette et interactions.
Discussion de la passe suivante, sans implémentation ou merge déclenché.
