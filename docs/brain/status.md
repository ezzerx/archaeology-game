# Statut canonique

**Date:** 2026-10-07
**Projet:** ArchaeologyGame (working title)  
**Source unique du statut courant:** ce fichier. Voir aussi `docs/DOCUMENTATION_POLICY.md`.

## Phases

- P0 Interaction ✅
- P1 Material / Relief ✅
- P2 Tools ✅
- P3 Fossil ✅
- P4 Game Feel / Verticality / Debris / Bone preparation ✅
- P5 Complete preparation session ✅ human-validated and merged
- **P6A Visual Direction / Production Spike ▶ active**
- P6B V0.1 Art Pass — not started
- P7 Tuning — not started

## Active branch / PR

Active branch: `prototype/p6a-visual-spike`  
PR: **#9 — P6A Visual Direction / Production Spike** (DRAFT)

P6A-1 Material Lab is complete and human-reviewed.

P6A1.5 Soil Foundation Spike is also human-reviewed.

## P6A1.5 human verdict

Antoine prefers the thin-overburden candidate.

Accepted direction:
- Soil = thin, partial, irregular surface dirt / overburden;
- Soil follows the substrate instead of creating a flat independent top plane;
- Brush removes the superficial dirt quickly;
- Clay/Sandstone is the real structural work surface;
- exact spike thickness/coverage values remain tunable, not final production constants.

Contact patina direction:
- original Clay/Sandstone color remains visible;
- contact history appears as irregular dirty deposits/stains;
- no uniform dark band / full-material recolor.

Visual quality of the spike is **not** approved as final art; only the Soil semantics and patina language are accepted.

Report on active branch:
`docs/dev/P6A15_SOIL_REPORT.md`

## Current gate / next authorized action

**P6A1 est suffisamment validé humainement pour avancer vers P6A2.**

- Le B actuel P6A1.6 (macro + méso, `natural_matrix_profile.gd`, livraison `26f3552`) est accepté comme fondation de travail P6A2 pour maintenant, pas comme géométrie finale parfaite.
- **Clay surface breakup grammar** est une amélioration ciblée future : rapprocher la surface Clay intacte du langage minéral cassé visible après excavation. Différée, non bloquante, à ne pas implémenter maintenant.
- Soil mince et patine par dépôts P6A1.5 restent acceptés ; gameplay P4/P5 gelé.
- Les rapports/candidats P6A1.6 restent des preuves historiques, sans réécriture de leurs verdicts contemporains.

**P6A2 Hero Lookdev PREFLIGHT terminé — READY.** Six références inspectées ; Blender 5.2.2 LTS portable vérifié ; export GLB reproductible et import/rendu Godot 4.7.2 validés (31 contrôles). Aucun fichier gameplay retuné. Rapport actif : `docs/dev/P6A2_PREFLIGHT_REPORT.md`.

## P6A2 status

**Dernier verdict humain après test de la correction `d535c31` : progrès partiellement validés, Soil prioritaire.**

- Clay peut rester en l’état pour maintenant.
- La lampe locale est une amélioration majeure à conserver.
- Sandstone est acceptable pour maintenant, encore un peu sombre mais non prioritaire.
- **Soil est le problème visuel principal** : trop proche d’un camouflage sombre sur Clay. Le conserver comme matériau de gameplay, mais viser une terre superficielle, meuble, granulaire et naturelle, avec moins de grandes taches sombres.
- L’intégration jacket/bloc reste à améliorer après Soil. Une emprise intérieure moins rectangulaire est une piste à examiner ultérieurement, pas une modification autorisée du cœur dynamique maintenant.
- Pour un playtest entre amis : confort plein écran/grand écran, présentation des objectifs et de fin de session, lampe visible et décor d’établi limité.
- Simulation conservée à **60 Hz** ; direction Clay et éclairage local préservés.

La chaîne technique, l’isolation et la performance restent validées. Sources ImageGen v02 intégrées, ancien atlas Material Lab débranché du Hero. Scène : `scenes/p6a2_hero_patch.tscn`, fondation géométrique B inchangée. Preuves de la livraison : `docs/dev/P6A2_TARGETED_CORRECTION_REPORT.md` ; les rapports précédents restent historiques.

**P6A2 Soil & Playtest Presentation livré pour revue humaine après GO explicite.** Rapport actif : `docs/dev/P6A2_PLAYTEST_PRESENTATION_REPORT.md` ; brief : `docs/dev/P6A2_PLAYTEST_PRESENTATION_BRIEF.md`. Vrais dépôts Soil fragmentés, frange mince et patine séparée ; Clay v02 et lumière conservées. Restyle papier/musée de la fiche, outils et archive ; plein écran natif, lampe visible + deux accessoires ; ZIP Windows autonome testé. Aucun retuning P4/P5. Les métriques de fragmentation et tests techniques ne valident pas le plaisir de brosser ni la direction artistique.

**Prochaine action : HUMAN VISUAL VERDICT d’Antoine**, d’abord « cette terre meuble apporte-t-elle une vraie couche de matière plaisante à nettoyer ? », puis UI/affichage et ambiance. Même scène et lanceur Hero ; F10 compare les deux Soil avec reset, H expose la patine ON/OFF. Export local : `builds/ArchaeologyGame-P6A2-Playtest-Windows.zip`, reproductible via `tools/p6a2/Export-Playtest.ps1`. Limites : Soil moins abondant ; patine encore présente ; jacket/emprise rectangulaires inchangés ; 4K/autres PC non testés. STOP après livraison, aucune suite automatique. Jacket/emprise intérieure, P6A1.6/Clay surface breakup grammar, P6B et merge restent hors mission. Cap 240 FPS / physique 60 Hz. PR #9 reste DRAFT.

Références canoniques locales : `docs/visual-references/p6a2/`, matérialisées par `370ba6355a4a03d48e6faa5ae6aa60988aa2cb88`. Rôles : `docs/visual-references/P6A2_VISUAL_TARGETS.md`.

## P5 closure baseline

Current prototype session:
- four tools: Brush / Chisel / Blower / Precision Pick;
- museum standard: global Exposure >=85% + Cleanliness >=85% + hidden-cluster guard;
- optional Fine Preparation at95/95;
- Condition shown qualitatively: Excellent / Good / Fair / Damaged;
- Archive or optional further cleaning;
- dormant fragment/Forceps experiment is not part of normal play.

Accepted P5 watchpoints, not blockers:
- Cleanliness may decrease when newly exposed dirty Bone enlarges the exposed-Bone denominator;
- hidden-cluster coverage is not a perfect human visual-completeness oracle;
- final in-matrix vs extracted vs mounted/hybrid specimen destination remains a Macro Game Design question.

## Gameplay freeze during P6A

Unless a specifically authorized spike says otherwise:
- do not retune the P4 tool baselines;
- do not redesign P5 progression;
- do not reopen fragment/Forceps work;
- do not start museum/intake/meta implementation.

P6A is currently about proving the geometry + visual-production foundation before art scaling.

## Key pointers

- Stable mental model: `docs/ORCHESTRATION_HANDOFF.md`
- Documentation rules: `docs/DOCUMENTATION_POLICY.md`
- Durable decisions: `docs/brain/decisions.md`
- Roadmap: `docs/ROADMAP.md`
- Gameplay loop: `docs/GAMEPLAY_LOOP.md`
- Visual direction: `docs/ART_DIRECTION.md`
- Future systems / Soil hypothesis: `docs/FUTURE_SYSTEMS.md`
- Active P6A implementation and reports live on PR #9 / `prototype/p6a-visual-spike`.

## Source precedence

1. Antoine's newest explicit instruction.
2. This status file for current phase/gate.
3. Active phase brief/report.
4. `docs/brain/decisions.md`.
5. Durable product docs.
6. Archived/historical reports.


## New orchestration chat expectation

Lire le dernier verdict humain et le rapport actif avant toute reprise. Distinguer les éléments déjà acceptés du candidat Soil/présentation à retester ; le rapport de livraison conserve les preuves techniques et le preflight les conventions d’outils. Ne pas déduire un GO P6B ou une correction jacket des tests.
