# Statut canonique

- Date : **2026-10-01**.
- Projet : **ArchaeologyGame**, working title modifiable.
- Phase : **préproduction — P1 validé et mergé ; P2 Outils autorisé**.
- Dépôt privé : [ezzerx/archaeology-game](https://github.com/ezzerx/archaeology-game).
- Branche canonique : `main`.
- Merge P0 : `244aba3652a03aac908b1aabe1651c3b9edb1315`.
- Merge P1 : `960642c3fc6972bdb257c96abd43b90c148e632d`.
- Dossier local initial : `C:\Users\antoi\Documents\Codex\Projects\ArchaeologyGame`.

## P0 — Validé ✅

Fondation interaction : caméra orthographique, mapping souris précis, working map, strokes continus, reset/debug et tests.

Rapport : [P0_REPORT.md](../dev/P0_REPORT.md).

## P1 — Validé ✅

Antoine a testé localement le build P1 dans Godot 4.7.2 et a confirmé : **« j'ai testé tout fonctionne »**.

Livré et validé :

- vraie hauteur 3D excavable, bornée à 102 mm ;
- Loose Soil / Compact Clay / Sandstone ;
- résistances 1 / 3 / 8 ;
- stratigraphie fixe légèrement irrégulière ;
- picking CPU sur la même topologie triangulée que le rendu GPU ;
- curseur restant aligné au fond des cavités et sur les pentes ;
- reset exact ;
- 45 checks P0 + 52 checks P1, 0 échec ;
- vérifications GPU/CPU et benchmark graphique local.

PR #2 mergée vers `main` le 2026-10-01.

Rapports :

- [P1_REPORT.md](../dev/P1_REPORT.md)
- [P1_RELIEF_DECISION.md](../dev/P1_RELIEF_DECISION.md)

## Watchpoints techniques après P1

Ces points ne bloquent pas P2, mais doivent rester visibles :

1. **Grille très dense** : 1024×640 quads, environ 1,31 M triangles. Excellent pour la précision du prototype, mais pas encore une cible de performance production pour un parc Steam plus large.
2. **Upload height texture complet** à chaque tick dirty. Acceptable aujourd'hui avec une seule map ; éviter de multiplier naïvement les maps runtime.
3. **Stress extrême** coin-à-coin hors budget 60 FPS. L'usage réel est fluide ; ne pas optimiser prématurément, mais mesurer après ajout des outils.
4. **Collider physique = enveloppe**. Le picking est exact ; une future physique de débris nécessitera une stratégie séparée.
5. **Résistances 1/3/8 = paramètres P1**, pas tuning final du game feel.
6. **Hard Rock volontairement omis** : bon choix pour garder P1 focalisé.

## Prochaine étape autorisée — P2 Outils

P2 doit introduire les trois outils du prototype :

- Soft Brush ;
- Chisel ;
- Air Blower.

P2 doit prouver que leurs **modes d'interaction et leurs utilités sont clairement différents**, sans commencer le fossile (P3) ni le polish sensoriel complet (P4).

Pour que l'Air Blower ait une fonction réelle sans avancer P4, P2 peut introduire un **état de résidu minimal et debug-only**, distinct du futur système de poussière/VFX. Il sert uniquement à valider la logique outil ; les particules, sons et rendu satisfaisant de la poussière restent P4.

**P3 ne doit pas commencer avant validation humaine de P2.**

## Références

- [PROTOTYPE_V0_1_SPEC](../PROTOTYPE_V0_1_SPEC.md)
- [ART_DIRECTION](../ART_DIRECTION.md)
- [VISUAL_REFERENCES](../VISUAL_REFERENCES.md)
- [P2_BRIEF](../dev/P2_BRIEF.md) une fois créé

Séquence : P0 ✅ → P1 ✅ → **P2 Outils** → P3 Fossile → P4 Game feel → P5 UI/progression → P6 Art pass → P7 Tuning.

La question finale V0.1 demeure :

> « Est-ce que j'ai envie de continuer à gratter alors que je sais déjà ce qu'il y a dessous ? »
