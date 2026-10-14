# P6A3.8 — Essai de lampe orientable

Livraison du 2026-10-14 après GO d’Antoine : manipuler la lampe pour lire le relief,
conserver ambiance chaude et interactions validées, ne jamais révéler les os enterrés.
Essai isolé depuis main `ff3ffd7`. Le lancement normal de main reste le B-17 accepté.

## Jouer l’essai

`Launch-P6A38-Orientable-Lamp.ps1`, Godot 4.7.2 stable.
Scène : `scenes/p6a38_orientable_lamp.tscn`. Départ recouvert, pose de lampe identique
à la référence. Le modèle existant est réutilisé ; aucune génération ou crédit externe.

- **L** ou bouton **Lampe** : entrer dans la manipulation.
- **Glisser gauche/droite avec le bouton gauche** : déplacer la lampe autour du
  bord de la table et faire pivoter sa source vers la zone de préparation.
- **Replacer la lampe**, ou double-clic en mode lampe : pose initiale exacte.
- **L**, **Échap**, bouton **Retour outils**, ou touche **1–4** : reprendre les outils.
- Molette et glissement droit conservent zoom et pan. F5 garde l’inspection.
- H conserve les préparations de revue annoncées avec reset, dont le squelette
  préparé au Pick natif ; utiles pour comparer les creux. Elles restent des fixtures.

Le reset R du spécimen conserve la position choisie de la lampe. La remise en place
de la lampe n’efface jamais le travail. Échap quitte d’abord le mode lampe lorsqu’on
est en plein écran ; une nouvelle pression peut ensuite quitter le plein écran.

## Implémentation et invariants

Deux scripts propres à cette scène : `scripts/p6a38/lamp_pilot.gd` et
`orientable_lamp.gd`. Aucun changement de `project.godot`, des shaders, du squelette,
du champ, du caster, du picker, de ToolController, de la caméra ou des presets.

La vraie source se déplace avec l’objet de lampe, plutôt que de seulement tourner
le cône depuis une position fixe : les ombres peuvent réellement changer de direction.
Course angulaire bornée de -125° à +35° depuis la pose acceptée ; base contrainte au
pourtour de la table, hauteur de source constante. Le modèle reste rigide, sans
nouveau rig d’articulation des bras. La pose zéro restaure les deux Transform3D exacts.

SpotLight et ambiance inchangés : couleur (1, 0,94, 0,83), puissance 1,20,
portée 1,9 m, ouverture 50°, atténuations, biais d’ombres, bounce et fill acceptés.
Aucune lumière supplémentaire. Ces paramètres sont comparés avant/après manipulation.

Un mode explicite bloque les hits d’excavation et annule le geste d’outil précédent.
Il capture seulement ses propres glissements ; les boutons gardent leur relâchement.
Perte de focus, sortie de souris, redimensionnement, pan/zoom et inspection terminent
la capture. Un garde sur l’état global du bouton évite une capture persistante si
un relâchement est consommé ailleurs. Après retour aux outils, un clic frais est requis.
Les blockers restent enregistrés après reconstruction de l’UI de comparaison F7.

Le système existant reste responsable du secret : shader masqué par hauteur/exposition,
mesh complet sans ombres, caster constitué uniquement des cellules réellement dégagées.
Déplacer la lumière ne modifie ni l’exposition ni les indices de ce caster.

## Vérifications

**565 contrôles exécutés, zéro échec**, avec répétition des tests d’entrée selon
l’environnement : P5 128, B-17 85, lampe headless 121, entrées natives 123,
graphique natif 108. Les suites lampe héritent des contrôles de géométrie, outils,
nettoyage, dégâts, reset, complétion et archive de la référence acceptée.
JSON et 15 nouvelles captures dans `docs/dev/evidence/p6a38/`. Les captures héritées
de la référence sont aussi produites sous work/test-logs/p6a38 ; les preuves historiques
complètes restent dans evidence/p6a37. Registres QA isolés, option --qa pour ne pas
charger/enregistrer les préférences de fenêtre du joueur pendant les tests.

### Aucun os enterré révélé

Cinq poses contrôlées : -125°, -85°, -45°, 0°, +35°.

- Matrice intacte : **viewport entier pixel-identique** pour source affichée/retirée,
  et ombres actives/désactivées, à chaque pose. Aucun triangle de caster enterré.
  Les empreintes SHA-256 des trois états sont conservées pour chaque angle.
- Crâne révélé à 35 % : vérifier que les points de mâchoire, vertèbre, côte et patte
  choisis sont encore enterrés ; comparer leurs pixels avec la source retirée tout
  en conservant les ombres légitimes des os déjà dégagés. Régions identiques aux cinq poses.
- Les 2189 cellules du caster partiel gardent les mêmes indices à tous les angles.
  Les suites héritées contrôlent ces indices contre chaque cellule réellement exposée,
  y compris sur les quatre composantes et lors du reset synchrone.

### Interactions et rendu

Injection des vrais événements Godot clavier/souris, convertis en coordonnées natives :
drag, relâchement, boutons de mode/reset, wheel/pan, retour à un clic de Pick effectif,
F5/F7/F11 et état complet de préparation/presets. Notifications focus/sortie et signal
resize exercés explicitement ; ce sont des tests de gestion d’événements, pas un retest
humain de tous les changements de fenêtre possibles. Plein écran réellement basculé dans
la suite native, Échap consommé par la lampe puis retour fenêtré sans sauvegarde QA.

Les captures `lamp-prepared-*.png` viennent de vrais impacts Pick, avec la pellicule
nettoyée par le helper de préparation, pas d’un rendu Blender. Elles montrent le même
terrain et les mêmes os sous plusieurs orientations ; état complet inchangé.
`lamp-controls.png` montre les commandes pendant cette revue.

## Limites à juger humainement

La course est horizontale et bornée ; l’objet complet glisse/pivote sur le pourtour.
Ce premier essai ne propose ni rig de bras, ni hauteur/réglage d’intensité, ni lampe
libre hors table. L’inspection F5 garde son éclairage propre, distinct de la fouille.
À fort zoom, l’objet de lampe peut sortir du cadre ; le bouton et L restent disponibles.
La source peut éclairer différemment les bords du bloc tout en conservant ses réglages.

La manipulation réutilise la lumière existante et ne reconstruit pas le caster CPU.
Le déplacement invalide toutefois les ombres GPU. Cap 240 FPS / physique 60 Hz conservés ;
plusieurs autres fenêtres de playtest étaient actives, donc aucune nouvelle validation
isolée de fluidité ou de coût soutenu. Mesures graphiques héritées dans visual.json.

Retour utile : facilité de manipulation, aide réelle à lire les creux/restes de matrice,
confort de l’ambiance et envie d’utiliser la lampe pendant une préparation normale.
Les tests ne constituent pas cette validation. La gate vit dans le Brain du dépôt.
