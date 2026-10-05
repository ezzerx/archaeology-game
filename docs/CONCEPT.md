# Concept

Canonisé le 2026-09-30 — **Concept / pre-production**.

## Promesse

Transformer un bloc opaque en découverte tangible par des gestes de fouille et de nettoyage satisfaisants. Le plaisir vient autant du travail de la matière que de l’objet révélé et de la collection qui grandit.

*PowerWash Simulator* est une référence pour la satisfaction de transformation progressive, pas un modèle à reproduire dans son univers ou ses systèmes. Le nom de travail ArchaeologyGame reste modifiable. Le terme « archéologie » décrit le concept général ; le premier cœur de contenu porte sur les fossiles et leur préparation.

## Cadre narratif actuel

La base narrative canonique actuelle est celle d'un **atelier de préparation au sein d'un musée d'histoire naturelle**.

Le joueur est employé / préparateur du musée. Il reçoit des blocs, fragments et spécimens qui doivent être dégagés, nettoyés, préparés et documentés avant de rejoindre les réserves, la collection ou une exposition.

Boucle diégétique cible :

> **spécimen confié par le musée → atelier de préparation → excavation / nettoyage / identification → archivage → collection / exposition mise à jour**

Le joueur ne contrôle toujours aucun avatar. Le musée sert de lieu, d'employeur et de destination du travail, pas de monde ouvert.

Mise en scène de travail retenue tant qu'une meilleure idée n'émerge pas :

- menu principal / accueil pouvant montrer **la façade du musée** ;
- lancement d'une session = passage implicite « à l'intérieur », dans **l'atelier de préparation** ;
- la galerie / collection représente le résultat visible du travail accompli.

Cette direction est une **baseline narrative actuelle**, pas un scénario définitif. Elle peut évoluer si une proposition plus forte apparaît sans casser le cœur du jeu.

## Périmètre confirmé

- Jeu cosy destiné à Steam, sans monde ouvert ni personnage contrôlable.
- Fouille en vue strictement du dessus : un bloc est posé sur une table, le joueur agit directement sur sa surface.
- Plusieurs matériaux superposés possèdent résistance, profondeur, réactions et outils adaptés.
- Les os se révèlent progressivement ; l’identité du spécimen peut être cachée au départ.
- Les fragments récupérés enrichissent une collection et complètent les expositions du musée ; le musée est aussi le cadre narratif qui confie les spécimens au joueur.
- Le musée est une interface de galerie horizontale, sans déplacement d’avatar.
- La réussite dépend prioritairement du game feel, de l’atmosphère et du rythme de découverte.
- Le premier prototype reste limité à un seul écran de fouille.

## Expérience recherchée

Le joueur brosse une surface. Quelques grains s’envolent et une minuscule courbe blanche apparaît. Il insiste : la courbe devient un élément osseux. Un son et un retour visuel discrets reconnaissent cette nouvelle découverte. Il souhaite poursuivre pour voir la forme se dessiner, même lorsqu’il connaît déjà le résultat.

Les retours doivent permettre de sentir la transition entre terre, roche et os. Un outil plus agressif offre de la vitesse ; un outil délicat donne du contrôle. La tension éventuelle autour de la conservation du fossile doit rester compatible avec une expérience cosy.

## Hypothèses et choix ouverts

| Sujet | Orientation actuelle | Validation attendue |
|---|---|---|
| Direction artistique | **2.5D stylisée, tabletop, caméra orthographique presque verticale** | P6A valide la production finale sans changer cette base |
| Fragilité / condition | **Bone Condition globale + protection du premier hit direct par composant** ; Pick/Brush/Blower sûrs | Tuning final du risque en P7 |
| Identification | Unknown → Vertebrate remains → Possible Theropod → Likely small theropod | P5 teste le rythme et la lisibilité du dossier |
| Progression | Musée/collection comme méta-progression ; P5 teste d'abord une session de préparation complète | Relier ensuite plusieurs spécimens/fouilles |
| Statistiques du musée | Collection Progress, Exhibit Prestige, Visitor Rating | Garder uniquement les indicateurs utiles |
| Catalogue | Dinosaures et autres collections possibles | Choisir après validation du cœur jouable |
| Moteur | **Godot 4.7.2 stable Standard, GDScript, Compatibility** | Reconsidérer uniquement face à une limitation concrète |

Le contenu culturel ancien, l’économie, les doublons de fragments, les déblocages et les contraintes scientifiques précises ne sont pas encore définis. Aucun planning commercial ni volume final de contenu n’est engagé.

## Règle de priorité

Si le geste de nettoyage n’est pas satisfaisant, améliorer la matière et ses retours avant d’ajouter des systèmes ou de nouveaux fossiles. La référence de validation reste [MVP_V0_1](MVP_V0_1.md).
