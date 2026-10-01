# Statut canonique

- Date : **2026-10-01**.
- Projet : **ArchaeologyGame**, working title modifiable.
- Phase : **préproduction — P3 Fossile validé fonctionnellement par Antoine ; passe design à cadrer ; non mergé**.
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

## P3 — Fonctionnement validé humainement ; passe design à cadrer

Livré dans le périmètre autorisé :

- Specimen B-17 fixe, initialement caché, **32 290 cellules** et quatre composants ;
- champ fossile RGF statique, clamp au sommet osseux et relief émergent ;
- `Bone detected` une fois par reset, premier contact de chaque cellule protégé ;
- condition 100→0, Chisel **−3 points par impact direct sur centre déjà exposé** ;
- Brush/Blower sûrs, résidu indépendant ;
- exposition globale/composants, signaux découplés et reset exact ;
- cap officiel **240 FPS**, physique **60 Hz** ;
- **279 checks P0/P1/P2/P3, zéro échec**, validation graphique locale et captures GPU.

Reprise et checklist : [P3_REPORT](../dev/P3_REPORT.md). Architecture/limites : [P3_FOSSIL_DECISION](../dev/P3_FOSSIL_DECISION.md). Scope : [P3_BRIEF](../dev/P3_BRIEF.md).

Retour humain d'Antoine le 2026-10-01 : « Ok tout fonctionne et le GPU ne surchauffe plus. » Le fonctionnement P3 et le confort GPU sont donc validés par son retour. Cette confirmation reste qualitative et ne remplace pas les mesures automatisées conservées dans le rapport.

Prochaine action : Antoine souhaite discuter de quelques modifications design avec l'orchestrateur, puis définir une nouvelle passe. Les modifications précises ne sont pas encore fournies. La grille dense est conservée ; seul le coût des lectures osseuses inutiles a été réduit pour respecter le benchmark CPU existant.

**STOP à P3. PR #4 conservée en brouillon. Aucun merge ni P4/P5 sans nouvelle autorisation explicite d'Antoine.**

## Séquence

P0 ✅ → P1 ✅ → P2 ✅ → **P3 Fossile** → P4 Game feel → ART0 Direction visuelle et pipeline → P5 Boucle complète → V0.1.

La [roadmap](../ROADMAP.md) fixe les gates suivants. Les [systèmes futurs confirmés](../FUTURE_SYSTEMS.md) restent différés après V0.1 ; leur documentation n'autorise aucune implémentation dans P3.



## P3 design review — clarified 2026-10-01

Human feedback:

- discovery hook succeeds: once bone is perceived, Antoine wants to continue revealing it;
- Bone/Clay readability is weak in greybox and is deferred mainly to P4/P6;
- precision excavation needs camera zoom;
- current Bone Condition is hard to preserve because the Chisel interaction is still a simplified point-by-point prototype.

Scope decision:

- **do not add a P3 precision-margin / near-bone Brush workaround**;
- P4 is already intended to change material reaction toward cracks, chunks, debris and stronger tool physicality, so the fair way to avoid bone damage must be reassessed there;
- P3 only needs to prove detection, clamping, protected first contact, condition damage semantics, exposure, picking and reset;
- a 100%-condition excavation is **not yet a P3 acceptance criterion**.

Required P3 follow-up before merge:

- add smooth fixed-orientation orthographic zoom for precision;
- reserve normal mouse wheel for zoom and move debug tuning to developer-only bindings;
- keep current bone damage semantics as technical proof;
- document Bone Condition avoidance as a P4 design target;
- retest zoom/picking and existing P3 functionality.

Design rule now canonized:

> Do not add an earlier-phase workaround for a problem that a later planned phase is explicitly expected to reshape, unless it blocks validation of the current phase.

Reference: [P3_DESIGN_FIXES.md](../dev/P3_DESIGN_FIXES.md).

P4 remains blocked until the P3 zoom retest passes.
