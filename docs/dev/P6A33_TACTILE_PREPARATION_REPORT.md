# P6A3.3 — Préparation tactile, 2026-10-13

Passe locale autorisée après le retour natif d’Antoine. Branche :
`prototype/p6a32-fossil-mesh`. Candidat : `scenes/p6a33_tactile_preparation.tscn`.
Lanceur : `Launch-P6A33-Tactile-Preparation.ps1`, Godot 4.7.2 stable.
Les anciennes scènes restent disponibles. Le main_scene historique est conservé.

## Résultat

- Style des os précédents actif au lancement. F6 compare avec le crâne Tripo,
  sans réinitialiser ni modifier le vrai rayon de l’outil.
- F7 compare la nouvelle préparation au témoin P6A3. Il conserve l’état courant,
  puis sélectionne aussi le profil de nettoyage pour les gestes suivants.
  Les boutons du panneau H indiquent l’état actif ; l’aide debug est corrigée.
- Jauge Condition conservée. Les marques prennent naissance aux vrais contacts
  dommageables, avec branches de directions variables. Répéter au même endroit
  agrandit/renforce la même zone. Le premier contact protégé ne crée aucune marque.
  Les autres os ne se dégradent plus simultanément.
- Brush plus efficace en mouvement : quelques petits passages sur une trace
  donnent un résultat rapide. Maintenir immobile reste moins efficace. Une faible
  trace effectivement touchée se termine sans queue invisible ; aucun retrait
  hors du rayon réel. Le Film et ses compteurs restent les données de nettoyage.
- Poussière de retrait plus large et lisible, synchronisée au nettoyage réel ;
  aucun puff de nettoyage sur un os déjà propre. Pool existant borné conservé.
  Texture sonore Brush existante réutilisée avec un contact plus granuleux pour
  le Film ; aucune nouvelle source sonore ni musique produite.
- À 100/100 affichés avec garde de couverture satisfaite, distinction facultative
  « Préparation intégrale ». Elle reste distincte de Fine Preparation et de
  Condition, se conserve pour la session, puis est enregistrée à l’archivage dans
  `user://preparation_distinctions.json`. Reset et redémarrage conservent le registre.
  Un archivage ultérieur moins complet n’efface pas la distinction existante.
  Le registre est un support minimal pour la future collection, pas un écran musée.

## Isolation et budgets

Le profil Film est opt-in dans cette scène : mouvement ×2.4, maintien ×0.35,
falloff de nettoyage ×0.55, fin de trace sous 0.025 de Film. Les presets partagés,
Soil/Clay/Sandstone, plafonds Bone, picking, protections et quantité de dégâts
restent inchangés. Les profils historiques gardent leurs paramètres exacts.
Ces chiffres sont du tuning de candidat, pas des constantes artistiques validées.

Les marques utilisent une carte de présentation L8 1024×640 (640 Kio CPU avant
ressource GPU), mise à jour seulement sur dégâts/reset. Les zones sont bornées
localement et limitées aux cellules déjà exposées du composant touché.
Aucune destruction d’os, réparation ou seconde simulation de Condition.
Physique 60 Hz / cap rendu 240 FPS conservés. Pas de revendication de benchmark.

## Vérifications

Godot `4.7.2.stable.official.ed1daf0bf`, rendu natif Compatibility sur RTX 5080.
- P5 : 128 contrôles, zéro échec.
- P6A3.1 : 127 contrôles, zéro échec ; trajectoires historiques conservées.
- P6A3.2 : 142 contrôles, zéro échec.
- P6A3.3 : 40 contrôles fonctionnels, zéro échec : vrais événements clavier F6/F7,
  protections et impacts, localisation/reset, quatre petits allers-retours
  nettoyant une trace centrale en 0.48 s, maintien plus lent, absence de fausse
  poussière, fin de trace au bord, garde 100/100 et persistance/rechargement.
- 17 contrôles graphiques natifs, zéro échec : dégâts visibles au contact et pixels identiques
  sur une mâchoire éloignée, poussière réelle affichée, avant/après Brush et archive.
  Total : 454 contrôles passés, zéro échec.

Captures contrôlées avec fixtures de test, pas une session humaine enregistrée.
Le stockage QA est isolé sous `work/test-logs/p6a33/collection-test.json` : aucun
badge n’est attribué au joueur par les tests. Les tests graphiques convertissent
les coordonnées logiques 1920×1080 vers les pixels 1280×720 avant comparaison.
Des captures initiales inadéquates (contact caché / région mal projetée) ont été
corrigées ; seules les preuves finales sous `docs/dev/evidence/p6a33/` sont livrées.

## Retest humain

1. Recommencer une vraie session via le nouveau lanceur. Os précédents affichés.
2. Quelques petits allers-retours : juger vitesse, trace nettoyée et poussière à
   1×/3×, puis la fin du nettoyage. F7 permet le témoin, sans reset.
3. Chisel sur os visible : premier contact protégé, puis marque locale ; répéter
   et changer d’endroit. Juger forme, lisibilité et absence d’usure distante.
4. F6/F7 : vérifier les comparaisons et l’absence de changement de rayon.
5. Atteindre 100/100, archiver, puis reset/redémarrer : distinction conservée.

L’appréciation tactile et artistique reste humaine. La production de nouveaux
fossiles paramétriques, les sons dédiés, la lampe interactive et la collection
complète restent hors de cette passe.


## Retour humain ciblé — 2026-10-13

Antoine valide explicitement :
- Brush sur la saleté de l’os : « parfait » ;
- dégâts localisés : « parfait ».

Ces deux interactions et leurs réglages sont acceptés pour maintenant. Aucun
verdict sur la distinction sauvegardée ni validation globale de la phase n’est
inféré. Captures humaines conservées dans `evidence/p6a33/home-bone-baseline.png`
et `evidence/p6a33/home-bone-tripo-hybrid.png`.

Antoine observe que Tripo paraît superposé au crâne en code. Le code confirme
un remplacement partiel : le masque supprime le Bone précédent sur 4 497 cellules
sur 7 756 (environ 58 %) ; les 3 259 autres (environ 42 %) restent rendues en Bone
historique. Le mesh est adapté à la silhouette native, sans remplacement de son
champ physique. Le rendu est donc un hybride avec raccords visibles, pas un
crâne Tripo autonome comparé à un crâne entièrement remplacé. Cette limite
technique était conservée pour éviter des trous ; elle ne valide pas le résultat
artistique. Les captures seules ne démontrent pas un z-fighting généralisé.

Recommandation : garder le style précédent comme référence jouable. Un éventuel
nouveau test de modèle 3D doit distinguer adaptation complète, raccords et
qualité propre de l’asset ; aucune nouvelle production n’est lancée ici.
