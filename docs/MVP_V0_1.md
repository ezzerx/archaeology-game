# Prototype v0.1 — Fossil Cleaning Prototype

**Statut : prototype développé par gates ; P4 validé, P5 livré sur PR #8 pour test humain.**  
La spécification détaillée et canonique se trouve dans [PROTOTYPE_V0_1_SPEC.md](PROTOTYPE_V0_1_SPEC.md), mais les briefs de phase plus récents prévalent lorsqu'ils la remplacent.

## Overrides canoniques actuels

- quatre outils d'excavation/préparation sont désormais validés : Brush, Chisel, Blower, Precision Pick ; **Forceps [5]** est ajouté par P5 pour la récupération manuelle ;
- les fragments ne sont plus récupérés automatiquement en P5 : ils deviennent READY puis sont déplacés au plateau avec Forceps ;
- la fin de session actuelle est **Preparation Complete → Keep Cleaning / Archive Specimen → Prepare Another Block**, pas Restart Specimen ;
- **Exposure ≠ Cleanliness ≠ Condition** ; le Bone Surface Film est nettoyé au Brush ;
- Soil n'a actuellement aucun mess persistant ; sa refonte est différée ;
- le cadre narratif actuel est le laboratoire de préparation d'un musée d'histoire naturelle.

Pour la reprise actuelle, lire [ORCHESTRATION_HANDOFF](ORCHESTRATION_HANDOFF.md), [P5_BRIEF](dev/P5_BRIEF.md) et [P5_REPORT](dev/P5_REPORT.md).

## Question à résoudre

> Est-ce que j’ai envie de continuer à gratter alors que je sais déjà ce qu’il y a dessous ?

Une réponse positive valide le cœur de sensation, pas la viabilité commerciale ni le jeu complet.

## Direction visuelle retenue

Pour le prototype, la direction canonique est désormais :

> **2.5D stylisée — tabletop — caméra orthographique presque verticale**

Le pixel art n'est plus la cible du prototype. La fouille doit permettre profondeur, cavités, ombres locales, fissures, poussière et révélation progressive des os. Voir [ART_DIRECTION.md](ART_DIRECTION.md).

## Périmètre obligatoire

| Élément | Résultat attendu |
|---|---|
| Un écran | Tabletop fixe, sans personnage ni déplacement |
| Un bloc | Surface multicouche travaillable directement |
| Un fossile | Specimen B-17, os révélés progressivement |
| Trois matières cœur | Loose Soil, Compact Clay, Sandstone |
| Une zone secondaire | Hard Rock facultatif pour tester la résistance |
| Trois outils | Soft Brush, Chisel, Air Blower |
| Matière destructible | Profondeur, états intermédiaires, creux et couche suivante |
| Poussière | État gameplay nettoyable, pas simple VFX |
| Game feel | Outils visibles, particules, débris, sons, lumière et réactions distinctes |
| Découverte | Premier contact os protégé, son différent, feedback Bone detected |
| Condition | Chisel pouvant endommager un os déjà exposé |
| Mystère | Unknown → Vertebrate remains → Possible Theropod → Likely small theropod |
| Fragments | Deux fragments récupérables automatiquement après dégagement |
| Progression | Trois objectifs, completion card et Keep Cleaning |

## Les trois objectifs

- Expose the skull
- Reveal 60 % of the skeleton
- Recover both fragments

Ils peuvent être réalisés dans n'importe quel ordre.

## Condition de fin

Une fois les trois objectifs atteints, afficher **Preparation Complete** avec :

- classification probable ;
- pourcentage révélé ;
- fragments récupérés ;
- condition du spécimen.

Proposer :

- **Keep Cleaning**
- **Restart Specimen**

Le comportement le plus important à observer est : **le joueur continue-t-il volontairement après la fin ?**

## Validation interne

Feu vert proposé :

- au moins **4 joueurs sur 5** donnent **4/5 ou plus** à la satisfaction de la fouille ;
- au moins **3 joueurs sur 5** continuent volontairement après **Preparation Complete**.

## Hors périmètre

Pas de :

- musée fonctionnel ;
- économie ;
- monde ouvert ;
- personnage ;
- multiples fossiles ;
- sauvegarde avancée ;
- génération procédurale ;
- Steam integration ;
- achievements ;
- gamepad ;
- histoire ;
- catalogue important d'assets.

**V0.1 = le bloc.**

## Ordre de réalisation

1. **P0 — Interaction brute** : caméra, bloc, raycast, curseur, modification d'une map.
2. **P1 — Matière** : profondeur, matériaux, résistance, creusement.
3. **P2 — Outils** : Brush, Chisel, Blower.
4. **P3 — Fossile** : exposure, detection, condition.
5. **P4 — Game feel** : particules, débris, outil physique, audio, poussière, lumière.
6. **P5 — UI et progression**.
7. **P6 — Art pass** vers la DA canonique.
8. **P7 — Tuning**, sans nouveau système.

Le développement doit respecter la règle suivante :

> Si Astra hésite entre ajouter une feature et rendre le pinceau plus agréable, améliorer le pinceau.

Tous les détails de comportement, architecture, audio, matériaux, UI, debug et critères de Done sont définis dans [PROTOTYPE_V0_1_SPEC.md](PROTOTYPE_V0_1_SPEC.md).
