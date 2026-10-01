# Statut canonique

- Date : **2026-10-01**.
- Projet : **ArchaeologyGame**, working title modifiable.
- Phase : **préproduction — P2 Outils livré, validation humaine en attente**.
- Dépôt privé : [ezzerx/archaeology-game](https://github.com/ezzerx/archaeology-game).
- Branche canonique : `main`.
- Branche de travail P2 : `prototype/p2-tools` ; PR vers `main` non mergée.
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

## P2 — Implémenté, vérifié techniquement ; verdict humain en attente

P2 introduit les trois outils du prototype :

- Soft Brush ;
- Chisel ;
- Air Blower.

Les profils sont data-driven : Brush continu (Soil 50× Clay, Sandstone nul), Chisel discret à 4,5 Hz et Blower sans effet structurel. Toolbar debug cliquable, touches 1/2/3, changement d'outil désarmant le clic en cours, F1 étendu et F2 conservé.

Résidu debug scalaire 256×160, accumulation CPU float32 et texture R8 de 40 Kio, soit un payload 64× inférieur à la hauteur RF P1. Génération liée à la profondeur réellement retirée ; nettoyage spatial, aucune particule/audio/physique.

Vérification locale Godot 4.7.2 : **45 P0 + 52 P1 + 97 P2, zéro échec**. Sept phases graphiques à 1920×1080 : **59,76–59,89 FPS** observés ; coût CPU Brush normal 3,59 ms, rapide 9,33 ms ; Blower 0,30 ms avec zéro upload de hauteur. Hauteur et résidu relus sur GPU identiques aux données CPU ; précision du picking conservée. Ces mesures courtes ne sont pas une validation du ressenti ni de tous les matériels.

Rapport, données brutes, limites et checklist exacte : [P2_REPORT](../dev/P2_REPORT.md). **Prochaine action : Antoine teste P2 et donne son verdict ; aucun merge automatique.**

**P3 ne doit pas commencer avant validation humaine de P2.**

## Références

- [PROTOTYPE_V0_1_SPEC](../PROTOTYPE_V0_1_SPEC.md)
- [ART_DIRECTION](../ART_DIRECTION.md)
- [VISUAL_REFERENCES](../VISUAL_REFERENCES.md)
- [P2_BRIEF](../dev/P2_BRIEF.md)
- [P2_REPORT](../dev/P2_REPORT.md)

Séquence : P0 ✅ → P1 ✅ → **P2 en attente de test humain** → P3 interdit à ce stade → P4/P5/P6/P7 conditionnels.

La question finale V0.1 demeure :

> « Est-ce que j'ai envie de continuer à gratter alors que je sais déjà ce qu'il y a dessous ? »
