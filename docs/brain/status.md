# Statut canonique

- Date : **2026-10-01**.
- Projet : **ArchaeologyGame**, working title modifiable.
- Phase : **préproduction — corrections gameplay P3 implémentées et testées ; retest humain requis ; non mergé**.
- Dépôt privé : [ezzerx/archaeology-game](https://github.com/ezzerx/archaeology-game).
- Branche canonique : `main`.
- Branche de livraison P3 : `prototype/p3-fossil` ; [PR #4](https://github.com/ezzerx/archaeology-game/pull/4) en brouillon vers `main`, non mergée.
- Merge P0 : `244aba3652a03aac908b1aabe1651c3b9edb1315`.
- Merge P1 : `960642c3fc6972bdb257c96abd43b90c148e632d`.
- Merge P2 : `9b8423fedfb4723ba8b0113a23e564ba474c8bd2`.
- Dossier local initial : `C:\Users\antoi\Documents\Codex\Projects\ArchaeologyGame`.

## P0 — Validé ✅

Fondation interaction validée : mapping souris, surface, strokes, reset/debug.

## P1 — Validé ✅

Relief excavable 3D, stratigraphie, résistances et picking précis sur le relief.

## P2 — Validé ✅

Antoine confirme le 2026-10-01 que les trois outils fonctionnent comme voulu pour le prototype.

Livré et validé :

- Soft Brush continu ;
- Chisel discret à 4,5 Hz ;
- Air Blower sans retrait structurel ;
- ToolDefinition data-driven ;
- résidu debug R8 256×160 ;
- changement 1/2/3 et toolbar ;
- reset/input robustes ;
- **194 checks P0/P1/P2, 0 échec** ;
- ~60 FPS sur les benchmarks graphiques 1080p plafonnés à 60.

PR #3 mergée vers `main` le 2026-10-01 au commit `9b8423fedfb4723ba8b0113a23e564ba474c8bd2`.

Rapport : [P2_REPORT.md](../dev/P2_REPORT.md).

## Décision runtime FPS

Lors du test humain P2, le runtime Godot non plafonné a poussé la RTX 5080 à 100% GPU.

Décision explicite d'Antoine :

> **Capper les runs interactifs normaux à 240 FPS à partir de P3.**

Les scripts de benchmark peuvent temporairement désactiver/modifier ce plafond pour mesurer la marge.

Aucune autre optimisation GPU n'est demandée pour l'instant. Après son test P3 le 2026-10-01, Antoine confirme que le GPU ne surchauffe plus ; le cap reste à 240 FPS.

## Watchpoints techniques

- grille relief dense (~1,31 M triangles) ;
- upload height RF complet à chaque tick dirty ;
- residue R8 séparé mais léger ;
- stress synthétique extrême hors budget ;
- collider physique enveloppe uniquement ;
- valeurs d'efficacité/résistance encore de prototype.

Aucun de ces points ne bloque P3.

## P3 — Corrections de précision livrées ; retest humain requis

Livré dans le périmètre autorisé :

- Specimen B-17 fixe, initialement caché, **32 290 cellules** et quatre composants ;
- champ fossile RGF statique, clamp au sommet osseux et relief émergent ;
- marge **2 mm** pour le Chisel sur os caché ; finition locale sûre au Brush à **1 mm/s** ;
- zoom orthographique **1×–3×** ancré au curseur, orientation 84° fixe ; Home rétablit la vue ;
- `Bone detected` une fois par reset, premier contact de chaque cellule protégé ;
- condition 100→0, Chisel **−3 points par impact direct sur centre déjà exposé** ;
- Brush/Blower sûrs, résidu indépendant ;
- exposition globale/composants, signaux découplés et reset exact ;
- cap officiel **240 FPS**, physique **60 Hz** ;
- **500 checks P0/P1/P2/P3, zéro échec**, benchmarks graphiques P1/P2/P3 validés ;
- scénario de douze zones avec outils par défaut : **1 698 cellules / 5,259 %**, condition **100 %**, puis **97 %** après impact volontaire ;
- comparaison GPU/picking à 1×/2×/3× : **194 955 pixels**, huit cas de frontière documentés, aucun échec.

Reprise et checklist : [P3_REPORT](../dev/P3_REPORT.md). Architecture/limites : [P3_FOSSIL_DECISION](../dev/P3_FOSSIL_DECISION.md). Source de vérité corrective : [P3_DESIGN_FIXES](../dev/P3_DESIGN_FIXES.md), prioritaire sur le [brief initial](../dev/P3_BRIEF.md).

Retour humain d'Antoine le 2026-10-01 : « Ok tout fonctionne et le GPU ne surchauffe plus. » Le fonctionnement P3 et le confort GPU sont donc validés par son retour. Cette confirmation reste qualitative et ne remplace pas les mesures automatisées conservées dans le rapport.

Après cette validation initiale, la revue produit a imposé le zoom et la finition sûre décrits ci-dessous. Ces deux corrections sont désormais implémentées ; **prochaine action : retest humain du workflow Chisel → Brush à 100 % de condition**, puis essai de dégât volontaire. Les six phases P3 tournent à environ 240 FPS, dont une finition à 3×. La grille dense est conservée.

**STOP à P3. PR #4 conservée en brouillon. Aucun merge ni P4/P5 sans nouvelle autorisation explicite d'Antoine.**

## Séquence

P0 ✅ → P1 ✅ → P2 ✅ → **P3 Fossile** → P4 Game feel → P5 UI/progression → P6 Art pass (spike puis application) → P7 Tuning → V0.1.

La [roadmap](../ROADMAP.md) fixe les gates suivants. Les [systèmes futurs confirmés](../FUTURE_SYSTEMS.md) restent différés après V0.1 ; leur documentation n'autorise aucune implémentation dans P3.


## P3 design review — 2026-10-01

Human feedback after functional validation:

- discovery hook succeeds: once bone is perceived, Antoine wants to continue revealing it;
- Bone/Clay readability remains weak in greybox; defer the real solution to P4/P6;
- precision excavation requires camera zoom;
- current Chisel/Bone Condition interaction makes damage too difficult to avoid during normal careful excavation.

Decision:

- **PR #4 remains unmerged**;
- P3 receives a design-fix pass before closure;
- add smooth orthographic zoom for precision;
- add a configurable near-bone precision margin: Chisel stops before hidden bone, Soft Brush safely removes only the final thin matrix near bone, and direct Chisel impacts on already exposed bone can still damage condition;
- target outcome: a careful player can expose a meaningful fossil region while maintaining 100% condition;
- P4 remains blocked until human retest passes.

Reference: [P3_DESIGN_FIXES.md](../dev/P3_DESIGN_FIXES.md).

État de la passe : corrections implémentées au commit `79b3193`. Aucun résultat automatique ne valide le naturel du nouveau geste à la place d'Antoine. La lisibilité Bone/Clay reste un sujet P4/P6.
