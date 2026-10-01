# Statut canonique

- Date : **2026-10-01**.
- Projet : **ArchaeologyGame**, working title modifiable.
- Phase : **préproduction — P0 validé humainement, P1 autorisé**.
- Dépôt privé : [ezzerx/archaeology-game](https://github.com/ezzerx/archaeology-game).
- Branche canonique : `main`.
- Merge P0 : `244aba3652a03aac908b1aabe1651c3b9edb1315`.
- Dossier local initial : `C:\Users\antoi\Documents\Codex\Projects\ArchaeologyGame`.

## P0 — Validé

P0 a été implémenté sur `prototype/p0-foundation`, revu techniquement, puis testé localement par Antoine dans Godot 4.7.2 Standard.

Éléments validés :

- scène 3D greybox ;
- caméra orthographique fixe à 84° ;
- mapping souris → raycast → local → UV → map ;
- précision centre, bords et coins ;
- strokes lents et rapides, y compris diagonaux ;
- absence de pont lors d'une sortie/réentrée du bloc ;
- reset `R` ;
- debug `F1` ;
- tuning molette / Shift+molette / Ctrl+molette ;
- comportement réel sous redimensionnement / usage local ;
- réactivité jugée correcte par Antoine.

Validation automatisée P0 : **45 checks, 0 failures**.

PR #1 a été validée puis mergée vers `main` le 2026-10-01.

Rapport : [P0_REPORT.md](../dev/P0_REPORT.md).

## Limites connues héritées de P0

- surface et collision encore planes ;
- working map RF temporaire, sans sémantique de profondeur ou matériau ;
- upload de texture complet à chaque modification ;
- stress case d'un stroke diagonal extrême plus coûteux que l'usage naturel ;
- aucun matériau, fossile, FX/audio final, objectif ou musée n'est encore implémenté.

Ces points ne remettent pas en cause P0 ; ils cadrent P1.

## Prochaine étape autorisée — P1 Matière

P1 peut maintenant commencer **en local avec Codex + Godot 4.7.2**.

Objectifs canoniques P1 :

1. donner une vraie sémantique de profondeur à la surface ;
2. produire un relief / creux visuellement convaincant ;
3. conserver un mapping souris précis malgré le relief ;
4. introduire les trois matières cœur :
   - Loose Soil ;
   - Compact Clay ;
   - Sandstone ;
5. ajouter Hard Rock uniquement comme petite zone secondaire si cela reste dans le scope ;
6. rendre les résistances et réactions de retrait perceptiblement différentes avec un outil debug générique ;
7. préserver 60 FPS et une architecture compatible avec P2.

**P2 ne doit pas commencer avant validation humaine de P1.**

## Références

- [PROTOTYPE_V0_1_SPEC](../PROTOTYPE_V0_1_SPEC.md) — source produit canonique.
- [ART_DIRECTION](../ART_DIRECTION.md) — DA 2.5D stylisée tabletop.
- [VISUAL_REFERENCES](../VISUAL_REFERENCES.md) — références visuelles canoniques.
- [P0_REPORT](../dev/P0_REPORT.md) — fondation technique validée.

Séquence : P0 ✅ → **P1 Matière** → P2 Outils → P3 Fossile → P4 Game feel → P5 UI/progression → P6 Art pass → P7 Tuning.

La question finale V0.1 demeure :

> « Est-ce que j'ai envie de continuer à gratter alors que je sais déjà ce qu'il y a dessous ? »
