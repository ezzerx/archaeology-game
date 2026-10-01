# Statut canonique

- Date : **2026-10-01**.
- Projet : **ArchaeologyGame**, working title modifiable.
- Phase : **Concept / pre-production — prototype v0.1 spécifié**.
- Dépôt : [ezzerx/archaeology-game](https://github.com/ezzerx/archaeology-game), privé.
- Dossier local initial : `C:\Users\antoi\Documents\Codex\Projects\ArchaeologyGame`.

## État actuel

Le concept général, la boucle de gameplay, le musée et la direction artistique sont documentés.

La **spécification complète du Gameplay Prototype V0.1 est désormais canonique** :

[PROTOTYPE_V0_1_SPEC](../PROTOTYPE_V0_1_SPEC.md)

La direction visuelle du prototype est désormais fixée à :

> **2.5D stylisée — tabletop — caméra orthographique presque verticale**

Le pixel art n'est plus la cible du prototype.

Les concept arts validés du 2026-10-01 servent de mood references : fouille tabletop chaude et tactile, outil visible au-dessus du bloc, matériaux avec profondeur, UI papier / bois / laiton, dossier scientifique et futur musée scrollable avec Missing Fossil Parts.

## Développement

Aucun code de gameplay n'est encore considéré comme validé.

La séquence de développement prévue est :

1. P0 — Interaction brute
2. P1 — Matière
3. P2 — Outils
4. P3 — Fossile
5. P4 — Game feel
6. P5 — UI et progression
7. P6 — Art pass
8. P7 — Tuning

Le premier jalon réellement significatif est **P0 → P3**, où il devient possible de creuser, changer d'outil et tomber sur un os.

## Prochaine action

Démarrer le prototype à partir de [PROTOTYPE_V0_1_SPEC](../PROTOTYPE_V0_1_SPEC.md).

Avant le code :

- vérifier la version stable de Godot à utiliser ;
- préparer une branche de prototype ;
- conserver les systèmes découplés ;
- rendre tous les paramètres de game feel configurables ;
- ne pas développer le musée ou une méta-progression avant validation du cœur.

## Validation attendue

Question centrale :

> « Est-ce que j’ai envie de continuer à gratter alors que je sais déjà ce qu’il y a dessous ? »

Feu vert interne proposé :

- 4 joueurs sur 5 évaluent la satisfaction de la fouille à 4/5 ou plus ;
- 3 joueurs sur 5 continuent volontairement après Preparation Complete.

Si le cœur échoue, reprendre matière, audio, VFX, outils et rythme avant toute extension de scope.
