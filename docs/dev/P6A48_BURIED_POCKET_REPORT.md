# P6A4.8 — Poche découverte à mi-profondeur

## Brief autorisé

GO explicite d’Antoine le 2026-10-15 pour la poche à mi-profondeur, après son
retour positif conditionné à une bonne intégration. Garder le soufflage court,
les outils acceptés et le squelette B-17 ; découvrir la matière dans l’épaisseur
du bloc pendant la fouille. Quelques implantations contrôlées servent à comparer
la découverte avant une éventuelle généralisation.

## Contrat de l’essai

- Départ visuellement identique au bloc naturel : aucune tache ou silhouette
  ne signale la poche cachée. Elle existe dans une vraie tranche de matière.
- Toit incliné et épaisseur variable ; ouverture graduelle par le travail natif.
  Les grains deviennent un indice lisible seulement près de la vraie surface.
- Souffler immédiatement après découverte doit donner un résultat franc local.
  Une couverture épaisse restante demande encore du Chisel : pas de tunnel,
  retrait magique d’argile ou effondrement complet sans action.
- Une poche et trois implantations déterministes d’essai. R conserve le même
  essai ; changer d’essai recommence explicitement la préparation.
- Reprendre Pick/Brush après l’évacuation, préserver les os enterrés et éviter
  que le fond dessine l’anatomie encore couverte.
- Conserver le candidat P6A47 pour comparaison, sans nouveau son, outil,
  génération de tous les blocs ou architecture de strates généralisée.

## Revue humaine recherchée

La surprise fonctionne-t-elle pendant la fouille normale ? L’apparition des
grains invite-t-elle au souffleur, le creux progresse-t-il dans l’épaisseur et
la transition reprend-elle naturellement vers le travail du fossile ?

## Livraison et preuves

Scène : `scenes/p6a48_buried_pocket.tscn`. Entrée : `Launch-Game.ps1`.
Fouiller normalement au Chisel (2). Quand les grains apparaissent, passer au
Blower (3), puis reprendre le Pick (4) et la Brush (1) selon la matière visible.
H ouvre le panneau ; son premier bouton « Autre essai · recommencer » cycle trois
implantations. Ce bouton recommence entièrement la préparation. R conserve
l’implantation choisie et restaure exactement le même bloc.

### Volume et découverte

La géologie, les hauteurs et la Soil initiales sont identiques à la référence
P6A41. Aucune surface façonnée n’est ajoutée pour annoncer la poche : le toit
granulaire se situe **15.3 à 26.5 mm** sous la couverture initiale selon l’essai.
Il s’incline et ondule ; l’épaisseur friable varie de **1.2 à 18.8 mm**. Les trois
volumes sont indépendants de l’anatomie et suivent des implantations façonnées.
Ils recoupent respectivement 2 275, 1 221 et 1 388 cellules Bone du trajet.

Le Chisel traverse d’abord la couverture avec son comportement natif. Il est
arrêté par le toit des grains lorsque celui-ci est réellement atteint. Le
parcours de découverte au centre atteint les premiers grains en deux impacts
natifs dans les trois essais ; ce nombre n’est pas imposé au joueur et dépend
du contact et du travail préalable.

La grammaire visuelle et les grains soufflés P6A47 sont repris à la vraie hauteur
excavée. Une demi-seconde de souffle sur une ouverture fait reculer le front
localement, sans faire disparaître tout le volume sous la couverture restante.
Le joueur peut retrouver sa continuation en avançant normalement dans la fouille.

### Rythme mesuré et couverture restante

Un parcours contrôlé de dégagement connecté utilise 21 à 23 impacts natifs sur
la bande, puis trois balayages de 0.65 s. Ces balayages évacuent **99.6 à 99.99 %
des grains initialement accessibles** sur ce parcours. À ce stade, 73 à 81.8 %
du volume total a été retiré : la partie encore cachée sous une couverture épaisse
attend la suite de la fouille. La quantité totale n’est donc pas une jauge de
soufflage à terminer avant de reprendre le Chisel.

Le souffleur ne coupe pas l’argile épaisse. Seule une croûte proche et déchaussée
peut s’effriter dans son jet, comme dans l’essai accepté. Le Chisel reste utilisable
sur les grains ; après évacuation, les contacts sur le substrat reprennent les
règles normales et le risque Bone déjà validé. Aucun outil, cadence, Condition,
nettoyage ou règle de collection n’est retuné.

### Préservation de la référence

Trois hooks étroits P6A47 permettent le choix d’acteur, de toit/fond et de domaine
de contact. Leur comportement par défaut reproduit le candidat de surface.
La suite P6A47 est rejouée avec 136 contrôles sans échec. La couverture Bone du
fond reste une borne commune conservatrice, sans relief calqué sur les os cachés.
Aucun nouveau modèle, son ou shader de matériau n’est généré. La lumière P6A45,
les ombres réservées aux os exposés et le contour orange corrigé sont conservés.

### Preuves

**629 contrôles, zéro échec** : candidat 163, rendu natif 59, référence P6A47 136,
P1 52, P5 128, miettes P4V2 91. Les contrôles vérifient notamment :

- mêmes hauteurs/interfaces au départ, y compris en changeant d’implantation ;
- volume enfoui, toit incliné, absence de découpe selon l’anatomie ;
- vrai circuit souris pour le souffle, arrêt au relâchement et vrai clic du bouton
  d’essai, accessible dans le panneau et sans coup d’outil parasite ;
- R identique, outils inchangés, comptabilité du volume et absence de calcul au repos ;
- préparation complète, picking, champs Bone et outils de référence préservés.

Sous rendu natif Godot 4.7.2 / Compatibility / RTX 5080 : modèle présent/absent
pixel-identique sous couverture intacte et après ouverture locale dans les trois
implantations ; poche activée/désactivée pixel-identique sur le bloc intact et les
zones voisines encore couvertes. Les ombres exposées et l’équilibre lumineux
restent contrôlés. Vingt-neuf captures générées ; cinq étapes conservées avec les
JSON et régressions dans `docs/dev/evidence/p6a48/`.

Source B-17 inchangée : SHA256
`942bfde8c127b3ed4055884295817e48fefd233d360debd7d90614cc6df2f346`.
Cap 240 / physique 60 Hz conservés ; aucun débit soutenu de 240 FPS n’est déduit
du harnais. Les contrôles ne valident ni le plaisir humain ni l’art final.

### Reproduire

Godot 4.7.2 stable, `--path . --script tests/run_p6a48_buried_pocket.gd` :

- logique : `--headless` et arguments utilisateur
  `-- tests --distinction-store=res://work/test-logs/p6a48/distinction-tests.json` ;
- rendu natif : sans headless, arguments utilisateur
  `-- visual --distinction-store=res://work/test-logs/p6a48/distinction-visual.json`.

La référence utilise `tests/run_p6a47_friable_pocket.gd` avec son propre fichier
QA de distinction. Régressions : `run_p1_tests`, `run_p5_tests`, `run_p4v2_tests`.

### Limites et suite à évaluer humainement

Une poche par essai, avec trois implantations prédéfinies, sans génération globale
ni répartition aléatoire de toutes les rencontres. Le volume progresse dans la
hauteur excavable actuelle ; pas de tunnel ni surplomb persistant sous une
couverture épaisse. Les parties encore couvertes attendent une ouverture réelle.

Le test humain doit surtout juger la surprise pendant une fouille normale,
la lisibilité des premiers grains, l’intérêt du changement d’outil et la reprise
vers le squelette. Le GO d’essai ne vaut pas généralisation ni merge.



## Livraison locale et GitHub

Source du candidat : `61e9297`, branche `codex/p6a48-buried-pocket`.
[PR #22 DRAFT](https://github.com/ezzerx/archaeology-game/pull/22), basée sur main ;
#21 remplacée sans fusion. Dossier local :
`C:\Users\antoi\.codex\worktrees\p6a32-fossil-mesh\ArchaeologyGame`.
`Launch-Game.ps1` ouvre « ArchaeologyGame — B-17 · Poche enfouie » sous Godot 4.7.2.
La livraison reste un essai à évaluer humainement en fouillant normalement.
