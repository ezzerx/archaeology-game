# P6A4.2 — Trois préparations B-17

## Brief autorisé

Antoine autorise trois blocs avec B-17 pour varier la façon de fouiller, sans
simple augmentation de durée. Outils, interactions et rapidité du nettoyage
restent ceux acceptés. Direction : découverte rapide, géologie contrastée avec
banc de grès oblique, accès séparés invitant à travailler par petites touches.

Les champs sont façonnés en coordonnées du bloc, indépendants des os cachés.
Conserver exactement source, plafonds et composants B-17, domaine naturel,
bords bruts et lumière chaude centrée. Garder les trois rôles de matériaux.
Comparer l'effort structurel aux conditions précédentes, puis vérifier les
parcours natifs complets, le reset, le passage au bloc suivant et l'occultation.
Les mesures ne remplacent pas le verdict humain sur les décisions et la durée.

## Candidat

Scène `scenes/p6a42_three_blocks.tscn`, entrée normale `Launch-Game.ps1`.
Trois profils déterministes mis en cache à l’ouverture, sans génération pendant
la fouille. La géologie est construite uniquement à partir des UV et des couches
précédentes : aucun contour, poche ou hauteur de surface calculé d’après Bone.
Les plafonds, positions, composants et géométrie B-17 restent strictement égaux.

| Préparation | Structure | Hypothèse de jeu | Travail vers Bone / référence |
|---|---|---|---:|
| Découverte | Sommet abaissé de 3,57 mm, grès plus bas | Ouvrir largement puis suivre les premiers os | 76,28 % |
| Banc oblique | Sommet abaissé de 2,55 mm ; banc ondulé de grès qui affleure et se prolonge en profondeur | Choisir entre traverser le banc ou ouvrir l’argile à côté | 91,63 % |
| Îlots | Sommet abaissé de 2,55 mm ; trois lentilles séparées de grès | Alterner ouvertures et finitions locales | 94,77 % |

Les offsets du profil sont .035/.025 de la profondeur utile
102 mm, soit **3,57 / 2,55 mm réels**. La couverture Soil fragmentée acceptée
reste identique en quantité locale et inférieure à 2 mm. Le banc et les lentilles
pincent localement l’argile jusqu’au grès : toujours les trois rôles existants,
sans colonne multi-slot. Ce sont de vraies interfaces de résistance, de picking
et de rendu, et non une peinture sur un bloc identique.

L’oracle additionne le travail structurel exact jusqu’aux plafonds des 25 404
cellules Bone, avec la résistance et l’efficacité du Chisel existant. Ce n’est
ni une durée humaine, ni le coût de retirer tout le bloc. Le premier essai des
îlots dépassait la référence (~110 %) ; leurs dimensions ont été réduites pour
conserver la contrainte de durée. Pas de modification de puissance, cadence,
rayon, fracture, nettoyage ou dégâts pour atteindre ces budgets.

## Parcours de revue

Sélecteur en haut du plateau : Découverte / Banc oblique / Îlots. Changer de
bloc après avoir commencé demande une confirmation explicite ; annuler garde
la préparation entière. **R recommence le même profil**. Après archivage,
« Préparer le bloc suivant » ouvre le profil suivant, puis boucle sur le premier.
Les critères d’archivage et la distinction intégrale restent ceux acceptés.
Ce sélecteur est un outil de l’essai, pas une nouvelle interface de collection.

Le sélecteur vit dans sa propre couche : les comparaisons F6/F7 peuvent remplacer
la carte de préparation sans le détruire. Le bouton de bloc suivant est reconnecté
à la nouvelle carte. F10 conserve son vrai témoin de couverture Soil, sur la même
géologie choisie. Les presets de coupes annoncés restent accessibles dans H.

## Vérification

142 contrôles candidat, 26 contrôles graphiques natifs, régressions P1 52,
P5 128 et miettes P4V2 91 : **439 contrôles, zéro échec** après corrections.
Godot 4.7.2 stable, Compatibility, RTX 5080. JSON et six captures dans
`docs/dev/evidence/p6a42/`.

- Trois champs initiaux ordonnés, coins logiquement vides, tous les os enterrés
  avec au moins 2,58 / 3,60 / 3,60 mm de matrice restante. Aucun masque de contour
  d’os ou caster à l’état intact ; source/plafonds strictement inchangés.
- Chaque bloc est entièrement révélé par de vrais impacts Pick depuis son état
  intact, sans coupe de fixture, puis nettoyé par de vrais balayages Brush.
  Exposure 100, Cleanliness 100, Condition 100, couverture et distinction validées.
  4 683 / 4 704 / 4 699 impacts du parcours exhaustif automatique ; beaucoup sont
  volontairement redondants. Ce parcours ne mesure pas la durée d’une fouille.
- Archivage et bouton suivant testés sur les trois profils, reset déterministe
  exact, annulation et confirmation de changement, comparaison Soil réversible.
  Pas de reconstruction de hauteur au repos.
- Matrice intacte pixel-identique avec et sans source 3D sur chaque bloc. Après
  une vraie ouverture locale exposant Bone, seules les cellules réellement
  découvertes participent au caster ; trois régions encore enterrées gardent
  les mêmes pixels sans le modèle. Six captures natives à cadrage commun.
- Le premier harnais a détecté le sélecteur libéré lors du remplacement de carte ;
  sa couche et le raccord du bouton suivant ont été corrigés, puis revérifiés.
  Le lancement graphique via wrapper console s’est arrêté avant l’initialisation
  OpenGL lors d’une reprise ; le binaire natif direct a terminé les preuves avec
  stderr vide. Les fenêtres de préparation précédentes ont été préservées.

## Limites et revue humaine

Les trois géologies changent réellement les distributions de matériaux et les
budgets, mais **la différence de stratégie et de durée reste à juger en jeu**.
Si le même balayage systématique reste préférable partout, l’essai n’aura pas
encore prouvé la rejouabilité. Ne pas compenser par des outils supplémentaires
avant ce retour. B-17, position, silhouette et couverture de dirt identiques
isolent volontairement l’effet de la géologie. Ni nouvelle pièce de collection,
ni progression ou génération par seed. Pas de son nouveau.

Lumière centrée, style ivoire chaud, bords bruts, occultation et correctif orange
hérités sont conservés. Cap 240 FPS / physique 60 Hz inchangés ; pas de nouvelle
mesure soutenue isolée de performance. Les contrôles ne valent pas validation
humaine de la variété proposée.



## Livraison de revue

Source `969eda7`, branche `codex/p6a42-three-blocks`,
[PR #16 DRAFT](https://github.com/ezzerx/archaeology-game/pull/16) sur main.
La PR #15 est remplacée sans fusion ; ses scènes et sa branche sont conservées.
Main reste la référence précédente. Les fenêtres et préparations en cours n’ont
pas été fermées pour ce nouvel essai.
