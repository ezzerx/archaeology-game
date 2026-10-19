# #27 — Arrivages : première version de test

## Vision retenue le 19 octobre 2026

Antoine valide explicitement la [planche](../visual-references/arrivals/00-arrivals-approved.png)
pour la version test, après consultation sur le site privé. Cette acceptation
artistique permet la préparation des assets puis du build ; elle ne vaut pas
validation du futur rendu natif, de ses interactions ni autorisation de fusion.

Un comptoir de réception chaleureux, adjacent à l'atelier du musée, présente
trois colis distincts. Vue fixe légèrement plongeante, sans avatar. Bois patiné,
enduit crème, vert bouteille, laiton discret ; lumière naturelle diffuse et
accents chauds, matières identifiables et ombres de contact lisibles.

## Parcours du premier build

1. Examiner les trois colis sans engagement. Un clic sélectionne une caisse et
   rapproche doucement la caméra ; les autres choix restent accessibles.
2. Lire une étiquette concise : numéro de lot, provenance et matrice probable.
   Pas de nom d'espèce, silhouette, fossile visible ou récompense de rareté.
3. Manipuler le loquet, puis soulever le couvercle : deux gestes souris lisibles,
   sans échec punitif, à éprouver sur plusieurs répétitions. Quelques secondes
   d'ouverture sont une cible de conception, pas une durée déjà validée.
4. Voir le vrai bloc entièrement couvert dans son calage. Les proportions du
   bloc dessiné sont indicatives ; conserver les blocs et matériaux existants.
5. Passer à la préparation correspondante puis utiliser la conservation et la
   galerie existantes. Prévoir un retour vers les arrivages.

Les trois colis donnent accès aux trois préparations actuelles. L'association
devient connue après quelques essais : aucune promesse de génération aléatoire,
de nouvelles espèces ou de surprise renouvelée par cette seule mission.

## Production d'assets

Références et fiches : [pack Tripo](../visual-references/arrivals/README.md).
Antoine garde la génération manuelle dans son Tripo Studio ; aucun appel payant
API n'est déclenché. Préserver chaque GLB original avant optimisation.

- Pilote : corps creux et couvercle générés séparément. Ajuster proportions,
  intérieur, dessous, UV, normales, matériau et joint de fermeture dans Blender.
- Loquet et charnières : petites pièces distinctes construites localement ;
  pivots mécaniques maîtrisés. Pas d'animation d'un couvercle fusionné au corps.
- Comptoir : un asset dédié, plateau vide pour positionner librement les caisses.
- Réutilisation : fenêtre, applique, livres, fougère et éventuellement mobilier
  de fond existants dans `assets/museum/models/`, après contrôle dans la scène.
- Architecture, calages et étiquettes : éléments éditables assemblés localement.
  Aucun texte intégré aux textures générées. Étiquettes lisibles au focus.

Les trois références isolées dérivent de la planche approuvée ; leur production
en 3D et leurs proportions définitives restent à examiner. Pour les variantes,
adapter le pilote sans étirer les rivets, poignées ou l'épaisseur du bois.
Si la silhouette ne supporte pas l'adaptation, préparer une nouvelle référence
avant une génération supplémentaire.

## Intégration et lumière

Éprouver une caisse complète sous l'éclairage natif avant de multiplier les
variantes. Éclairer réellement les objets dans Godot : supprimer les ombres
peintes gênantes, éviter reflets métalliques excessifs, blancs brûlés et voile
orange. Garder de la marge autour des couvercles ouverts et des trajectoires
de caméra ; aucun accessoire ne doit intercepter la souris.

Atelier Compatibility et galerie Forward+ restent les références existantes.
Le choix de rendu de l'arrivage devra préserver les trois préparations ; cette
mission n'autorise pas leur migration globale. Mesurer le coût et la durée des
transitions, conserver la cible 240 FPS / physique 60 Hz sans les promettre.

## Vérifications du candidat

- Vue d'ensemble, focus et ouverture de chaque caisse ; couvercle et loquet
  sans intersection, bloc masqué tant que fermé et sans os révélé à l'ouverture.
- Sélection, annulation avant engagement, focus perdu, entrée répétée, retour et
  confirmation avant abandon d'une préparation : aucun double lancement.
- Les trois vrais blocs rejoignent les préparations validées et le musée conserve
  leurs traces après relance ; sauvegardes et historiques préservés.
- Captures natives aux cadrages représentatifs, plusieurs formats d'écran,
  lisibilité des étiquettes et comparaison de coût avant/après.
- Antoine examine les captures à distance puis teste les gestes et répétitions
  sur PC avant validation explicite et merge de la PR liée à #27.

## Limites de la V1

Les trois GLB ont été reçus le 19 octobre et leur intégration est autorisée par
Antoine. Sources intactes, masters Blender et copies runtime sont regroupés dans
`assets/arrivals/` ; les accessoires du musée sont réutilisés par référence.
Le rapport de réalisation et les preuves sont séparés de ce brief.
L'ancien essai #30 reste rejeté et archivé ; son code n'est pas repris.
UI globale, sons avec Claude, musique, économie, nouvelles préparations et
renderer commun restent des missions séparées.
