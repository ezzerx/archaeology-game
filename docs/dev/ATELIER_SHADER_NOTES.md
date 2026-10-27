# Atelier — Matières et éclairage

## Intention visuelle

Conserver la fouille validée et lui donner la présence matérielle d'un atelier
de musée : terre cuite minérale, ivoire poreux, bois ciré usé, plâtre crayeux et
toile de chanvre. Les références fournies le 19 octobre guident la chaleur,
la matière et l'éclairage ; elles ne promettent pas une reconstruction
photographique de la scène.

## Réalisation

- Argile : saturation de la texture ramenée à 0,65, en conservant le détail,
  la distinction avec le sol et la palette existante des dépôts.
- Sol, argile, grès et fossile : microrelief calculé depuis l'albedo déjà
  échantillonné, avant Film, résidu et curseur. Il modifie la normale
  d'éclairage uniquement. Échelle en mètres et pente limitée ; aucun vertex,
  plafond de fouille, masque ou état physique n'est déplacé.
- Rugosité : réponse mate propre à chaque matière, avec variation liée au
  grain existant. Le Film augmente toujours la rugosité et atténue le
  microrelief ; ses couleurs, motif, couverture et règles restent inchangés.
- Bois : noyer modéré, fibres longitudinales non périodiques, variation
  discrète par planche, joints fins et patine
  de finition. Toile : tissage filtré par la taille projetée des fils pour
  limiter le moiré au recul. Plâtre : relief de la texture existante.
- Lumière : trois sources existantes rééquilibrées. Lumière principale chaude
  oblique, lampe locale douce, remplissage neutre/frais dans les ombres.
  Le module ne crée aucune lumière ni ombre supplémentaire.
  L'ancienne lampe cachée pour préserver le champ de fouille reste cachée.
- Anticrénelage MSAA 4× du viewport pour les contours de bloc, outils et
  accessoires. Son coût GPU fait partie des mesures finales de la mission.

## Intégration

`scripts/workshop/sensory_lighting.gd` fournit `setup(preparation)`.
Il s'applique après la chaîne de `_ready()` de la préparation et après un
changement du look Hero. L'intégration se trouve dans
`scripts/collection/specimen_preparation.gd`.

Les helpers de `p6a2_materials.gdshaderinc` sont appelés depuis les points
de montage existants de `hero_patch.gd` ; le shader de l'os appelle les mêmes
helpers. Le relief visuel est calculé avant les masques du curseur, pour ne
pas transformer le marqueur d'outil en bosse.

## Renderer et coût

Cible de validation : Godot **4.7.2 stable**, **Compatibility**, RTX 5080.
Les fonctions utilisent les built-ins Godot et des dérivées disponibles dans
ce renderer. Aucun écran/depth sampler, aucune boucle dynamique, aucun calcul
GPU externe, aucune transparence nouvelle.

| Élément | Échantillons de texture ajoutés |
| --- | --- |
| Microrelief / rugosité des matières dynamiques | 0 |
| Microrelief du fossile | 0 |
| Bois et toile statiques | 0 (procéduraux) |
| Plâtre statique | 0 (3 lectures déjà présentes conservées) |

Le triplanar hérité reste à 2 lectures de couleur par face dominante, jusqu'à
6 sur une intersection. Les cartes de fouille, de cavité, de Film et de
visibilité existantes conservent leur coût. Le coût ajouté est surtout
arithmétique et doit être inclus dans la mesure d'intégration ; le nombre
d'échantillons seul ne constitue pas une mesure de performance.

Le `discard` du fossile reste indispensable au masque d'enfouissement validé ;
cette passe ne le convertit pas en transparence. La cible actuelle n'est pas
un nouveau portage mobile.

## Preuves

- `tests/run_issue35_relief.gd -- --qa --art-label=sensory-shader` :
  exécution réelle GPU, sortie 0, aucune erreur shader observée.
- Capture locale revue :
  `work/issue35/sensory-shader-art-reference-staged.png`.
  Coupe artistique explicitement préparée par la fixture ; elle prouve la
  compilation et permet de lire l'ivoire, les pores et les petites côtes,
  sans constituer une preuve de progression native ou un avant/après strict.
- Les captures avant/après des trois préparations et contrôles d'invariants
  de la mission sont centralisés dans le rapport d'intégration. Ils doivent
  être lus séparément de cette fixture de matière.
- API vérifiées dans les références officielles Godot :
  [spatial shaders](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/spatial_shader.html)
  et [shader functions](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/shader_functions.html).

## Limites

Ce travail ne remplace pas la géométrie de terrain, la silhouette validée,
les modèles de fossiles ni la mise en scène périphérique. Le plâtre statique
historique n'est pas visible dans toutes les préparations à bloc naturel.
Le jugement « beau / envie de jouer » et le plaisir des gestes restent à
valider par Antoine ; aucun contrôle automatique ne les démontre.
