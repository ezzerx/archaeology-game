# #28 — Poussière et contours au zoom

## Diagnostic
Les plages claires signalées sur B–17 sont bien les résidus laissés par la
préparation : masquer seulement `residue_map` les fait disparaître.
Leur couleur procédurale, interprétée comme linéaire au musée, les blanchissait
excessivement. La poussière doit rester présente avec sa teinte terreuse.

Les franges triangulaires sur les côtes et l’ammonite viennent du découpage de
la silhouette par la grille d’exposition. Le centre d’une cellule peut tomber
hors de l’empreinte alors qu’un petit morceau du vrai modèle dépasse dedans.
Cette géométrie était alors supprimée entièrement, même au-dessus d’une matrice
déjà creusée. Ce défaut devient particulièrement visible en inspection oblique.

Une autre anomalie a été identifiée : la capture parcourait le bloc, puis une
seconde fois sa branche enfant contenant os et ombres. Les premières archives
contiennent donc deux copies identiques de ces objets.

## Correction
`exhibit_display.gd` adapte uniquement le rendu figé lors de l’ouverture au musée :

- décodage sRGB des couleurs de poussière procédurales avant leur mélange à la
  matière ; ni suppression de poussière ni recoloration globale du bloc ;
- maintien strict du test d’exposition existant dans les cellules d’os connues ;
  à la bordure extérieure de l’empreinte, visibilité seulement si le vrai
  modèle se trouve au-dessus de la hauteur restante du terrain ;
- retrait en mémoire des copies partageant exactement maillage, transformation,
  matériaux et mode d’ombre. Les objets distincts ne sont pas fusionnés.

Le mode `inspection` qui désactiverait le masquage reste désactivé.
Les casters restent limités aux cellules réellement exposées.
La capture des nouvelles préparations ne parcourt plus deux fois les descendants.

Aucun changement des outils, de la physique, du rendu d’atelier, de la salle,
des textures de hauteur, de l’exposition, du film ou des dégâts sauvegardés.
Les archives existantes sont adaptées en mémoire, sans réécriture des fichiers.

## Vérifications
- **44 contrôles natifs Forward+, 0 échec** sur les trois familles.
  Quatre objets de rendu distincts, adaptation idempotente, cartes conservées,
  fichiers d’archive inchangés.
- Avec la matrice masquée pour rendre toute fuite visible : aucun pixel d’os
  entièrement enterré ; aucun pixel dans la moitié enterrée d’un bloc partiel,
  tandis que la moitié dégagée reste visible.
- Captures des vraies préparations du joueur et inspection au zoom maximal.
- **71 contrôles de restitution, 0 échec** : nouvelles archives sans doublon,
  image identique au bloc vivant dans Compatibility pour les trois préparations,
  cartes exactes, aucun os enterré révélé et historique conservé.
- **315 ressources et scripts**, aucun échec au chargement.

Preuves :
- [B–17, poussière avant correction](evidence/issue28/b17-dust-before.png)
- [B–17 corrigé, inspection rapprochée](evidence/issue28/b17-detail-after.png)
- [Ammonite, raccord avant](evidence/issue28/marine-edge-before.png)
- [Ammonite, raccord corrigé](evidence/issue28/marine-edge-after.png)
- [Contrôles d’affichage](evidence/issue28/display.json)
- [Restitution des nouvelles archives](evidence/issue28/exhibits-after-detail-fix.json)

La poussière, le film, les fissures et les petits restes de matière réellement
présents ne sont pas effacés pour embellir l’exposition.

Reproduction du contrôle Forward+ après création des archives QA par
`tests/run_issue28_exhibits.gd` :
```powershell
$archives = Get-Content work/issue28/archive-directory.txt
& $Godot --path . --rendering-method forward_plus --script res://tests/run_issue28_display.gd -- "--exhibit-store=$archives"
```

## Validation humaine
Le 2026-10-17, Antoine valide le rendu corrigé après essai et autorise la fusion
de la PR #53. Cette validation porte sur la restitution au musée ; les pistes
d’optimisation et les améliorations artistiques futures restent distinctes.
