# P6A4.1 — Bords bruts du bloc

GO Antoine du 2026-10-14 après revue P6A40 : conserver la silhouette appréciée,
retravailler arête et flancs trop propres avec cassures, pans et grain lisible.
Base 1547364, domaine/squelette/outils conservés ; pas de merge automatique.

## Candidat

Une bande extérieure étroite reçoit des coupes anguleuses de largeur/profondeur
variable, interrompues par des portions préservées. Ces hauteurs initiales sont
réelles et partagées avec le picking. Aucun plafond ou cellule Bone modifié.
Les flancs ont plusieurs plans inclinés et des cassures sur leur hauteur.

Le peigne du bord provenait aussi du filtrage entre matrice et vide à hauteur zéro.
Un guard de rendu étend les texels voisins hors domaine pour échantillonner le
bord comme une limite, sans y ajouter de matière logique ni zone jouable. Le
picker lit exactement cette même image de relief. Les os et masques voient les
mêmes hauteurs dans toutes les cellules du domaine.

## Flancs et matière

Quatre pans sur la hauteur, limites verticales variables le long du contour,
saillies jusqu’à 18 mm sous le domaine supérieur inchangé. Normales des pans
façonnés et grain modéré issu des matériaux existants rendent la roche des
flancs plus lisible. Aucune lumière, texture externe, outil ou matière nouvelle.
Les normales des petits segments de grille ne produisent plus une alternance
uniforme X/Z de reflets. Le domaine supérieur reste celui de P6A40.

## Vérification finale

**411 contrôles, zéro échec** : candidat headless 110, graphique natif 30,
régression P1 52, P5 128, miettes P4V2 91. Godot 4.7.2 / Compatibility / RTX 5080.
14 captures et JSON dans `docs/dev/evidence/p6a41/`.

- 36 310 cellules de la bande extérieure initiale sont coupées. **Zéro cellule
  modifiée dans le cœur et sous les os**, par comparaison à un P6A40 frais.
  Champ B-17, 25 404 plafonds, source 83 431 triangles et contacts Bone conservés.
- 3 297 texels de guard hors domaine, avec matière logique toujours à zéro et
  source d’échantillonnage dans le domaine. Même image interpolée CPU/GPU.
  66 rayons près du bord : erreur maximale .000127 texel, environ .14 µm ; aucune
  sélection manquée. Aucun rebuild de cette image lors des dix flushes à l’arrêt.
- 26 368 triangles de flancs contre 6 592 précédemment ; sommets inclinés et
  saillies vérifiés dans les données réelles. Le témoin de paroi verticale est
  comparé à préparation et hauteurs de coupe identiques, à zoom 3 et angle de
  caméra normal ; il ne prétend pas rejouer exactement l’ancienne version.
- Matrice intacte pixel-identique avec source Bone retirée ; régions réellement
  enterrées de mâchoire, vertèbre, côte et patte protégées après révélation partielle.
  Indices du caster des seules cellules dégagées conservés et contrôlés.
- Correction orange conservée : 328 fausses cellules Clay reproduites, 2 531
  pixels corrigés et 328 contacts au grès cohérents, sans modifier la préparation.
  Ombres visibles, équilibre latéral et absence de lampe devant le bloc conservés.
- Pick natif : révélation complète, nettoyage, Condition 100 et distinction
  possibles ; limites, resets, sorties des miettes et presets hérités vérifiés.

Les tests ont détecté une vraie désynchronisation du picker après une édition
non encore uploadée. Le candidat flushe désormais l’image sale avant un nouveau
pick, y compris entre impacts d’un tick retardé. Les contacts directs des quatre
composantes et le picking de la bande passent ensuite. Le noyau rectangulaire
historique garde son image canonique via le point d’extension par défaut.

Le premier oracle de hauteur initiale réappliquait le profil géologique à un
terrain déjà profilé ; il a été corrigé pour construire un état P6A40 frais.
Les types du harnais et le cadrage des gros plans ont aussi été corrigés avant
les preuves finales. Les captures de bords utilisent le pan disponible en jeu,
sans changer l’inclinaison de caméra.

## Limites

Une première passe façonnée, à valider artistiquement en fouille réelle. Le
contour supérieur suit encore la grille millimétrique, et certains escaliers
restent visibles à fort zoom ; l’effet de peigne du filtrage/éclairage est atténué.
Les coupes initiales se limitent à la bande extérieure, les flancs suivent ensuite
le retrait réel de matière. Pas de simulation volumétrique de rupture latérale.
240 FPS cap / 60 Hz physique conservés, sans nouvelle mesure soutenue isolée.


## Livraison de revue

Source `a8c1bba`, branche `codex/p6a41-rough-edges`,
[PR #15 DRAFT](https://github.com/ezzerx/archaeology-game/pull/15) directement sur main.
La PR #14 est remplacée et fermée sans merge ; ses sources et scène P6A40 restent
conservées. `Launch-Game.ps1` a ouvert « B-17 · Bords bruts » avec Godot 4.7.2 /
Compatibility, fenêtre répondante et stderr vide. Les préparations des autres
fenêtres sont préservées. Aucune validation humaine ou fusion déduite de ce lancement.


## Retour humain — 2026-10-14

Antoine : « C’est déjà sympa pour le moment !! On peut faire quoi maintenant ».
La passe de bords bruts est appréciée comme base de travail suffisante à ce stade.
Ce retour ne constitue pas une exigence de finition artistique finale. La suite
reste à choisir ; le détail des contrôles ci-dessus reste inchangé.
