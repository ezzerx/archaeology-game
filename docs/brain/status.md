# Statut canonique

- Date : **2026-10-01**.
- Projet : **ArchaeologyGame**, working title modifiable.
- Phase : **préproduction — P1 implémenté et vérifié techniquement, validation humaine attendue**.
- Dépôt privé : [ezzerx/archaeology-game](https://github.com/ezzerx/archaeology-game).
- Branche canonique : `main`.
- Branche de travail P1 : `prototype/p1-materials` (pas de merge).
- Livraison P1 : branche poussée, [PR #2](https://github.com/ezzerx/archaeology-game/pull/2) ouverte en brouillon vers `main`, non mergée.
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

## P1 — Livré pour validation humaine

- Hauteur normalisée 1→0, excavation bornée à 102 mm, vraie grille 3D déplacée, côtés adaptés et base fixe.
- Loose Soil / Compact Clay / Sandstone, résistances 1 / 3 / 8, frontières statiques ondulées ; outil debug générique uniquement.
- Picking CPU sur les triangles réellement affichés, après correction du relief, y compris pentes/bords/coins et bloc transformé.
- R exact, contrôles P0 conservés, F1 enrichi et F2 hauteur/couches/normales.
- Godot 4.7.2 local : import et scène headless PASS ; **45 tests P0 + 52 tests P1, 0 échec**.
- Rendu 1080p réel, vérification de 864 pixels GPU et texture CPU/GPU identique octet pour octet.
- Ryzen 7 9800X3D / RTX 5080 : environ 59,8 FPS en geste normal et 59,6 FPS en mouvements rapides au plafond 60 ; édition CPU ≈2,13 / 5,37 ms.

Preuves, limites, commandes et checklist : **[P1_REPORT](../dev/P1_REPORT.md)**. Choix technique : [P1_RELIEF_DECISION](../dev/P1_RELIEF_DECISION.md).

## Limites connues

- Le stress synthétique coin-à-coin à chaque tick dépasse 60 FPS : édition ≈29,84 ms, rattrapages pouvant bloquer une frame ≈256 ms.
- Un upload RF complet par tick modifié ; grille dense ; aucune garantie de performance sur d'autres GPU ou au rayon maximal.
- Collider physique toujours boîte : seul le picking fournit le relief exact. Pas de tunnels/surplombs.
- Greybox uniquement, ombres encore imparfaites ; game feel et précision perçue à valider humainement.

## Prochaine action — gate humaine

Antoine ouvre la branche P1 dans Godot 4.7.2 et suit la checklist du rapport : sensation de creusement, contact dans les cavités, différences de résistance, traits/coins/reset et fluidité. Corriger P1 en cas de défaut ressenti. La validation automatisée n'est pas un verdict humain.

**Aucun système P2+ commencé. Ne pas merger ni commencer P2 avant validation humaine de P1.**

## Références

- [PROTOTYPE_V0_1_SPEC](../PROTOTYPE_V0_1_SPEC.md) — source produit canonique.
- [ART_DIRECTION](../ART_DIRECTION.md) — DA 2.5D stylisée tabletop.
- [VISUAL_REFERENCES](../VISUAL_REFERENCES.md) — références visuelles canoniques.
- [P0_REPORT](../dev/P0_REPORT.md) — fondation technique validée.
- [P1_REPORT](../dev/P1_REPORT.md) — implémentation techniquement vérifiée, gate humaine ouverte.

Séquence : P0 ✅ → **P1 Matière : test humain attendu** → P2 Outils → P3 Fossile → P4 Game feel → P5 UI/progression → P6 Art pass → P7 Tuning.

La question finale V0.1 demeure :

> « Est-ce que j'ai envie de continuer à gratter alors que je sais déjà ce qu'il y a dessous ? »
