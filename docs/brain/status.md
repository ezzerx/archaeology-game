# Statut canonique

**Date:** 2026-10-08
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

**P6A2 est suffisamment validé humainement pour avancer.**

Baseline actuelle à conserver :
- Soil fragmentée : première version jugée positivement en jeu ; apporte désormais du charme, sans être considérée finale ;
- Clay v02 : bonne baseline actuelle ;
- task light locale : amélioration majeure confirmée ;
- Sandstone : acceptable pour maintenant, assez sombre mais non prioritaire ;
- UI / présentation playtest / fullscreen : suffisamment propres pour ne plus bloquer le travail sensoriel suivant.

Points différés, explicitement hors de P6A3 :
- jacket et emprise intérieure moins rectangulaire ;
- Clay surface breakup grammar ;
- retuning final Sandstone ;
- nouveau tool gameplay pour accélérer la fouille ;
- P6B.

## P6A3 — livraison Tool Feel & Sensory, revue humaine attendue

La passe autorisée par Antoine le 2026-10-08 via Playwright/Tripo Studio est
implémentée : quatre outils depuis les images approuvées, lampe existante adaptée,
masters conservés, retopo/nettoyage Blender, motions, VFX et trois Foley tests.
Le Chisel à double lame signalé par Antoine est corrigé dans le runtime Blender.
Les modèles bruts restent des preuves source, pas les versions à retester.

Scène : `scenes/p6a3_tool_feel.tscn`, héritée du Hero P6A2 accepté.
Lancement : `.\Launch-P6A3-Tool-Feel.ps1` ; F12 compare avant/après sans reset.
Package autonome : `builds/ArchaeologyGame-P6A3-Playtest-Windows.zip` (hors Git).
Rapport de livraison, vidéo, preuves et limites :
`docs/dev/P6A3_TOOL_FEEL_SENSORY_REPORT.md`.

Gameplay P4/P5, Soil/Clay/Sandstone, géométrie B, picking, Bone/Condition/Film,
jacket/emprise et task light conservés. Physique 60 Hz / cap rendu 240 FPS.
Tests et mesures passent ; ils ne valident pas le ressenti humain.

**Hotfix playtest clarifié le 8 octobre : outils suivant la souris, angle constant
indépendant du terrain, animations courtes et ancien audio P4/P5/P6A2 conservés.**
L'ancrage en bas à droite était une mauvaise interprétation, corrigée.
Référence Chisel reçue : Radius 26 / Power 0.84 / Falloff 2.25, autorisés uniquement
dans le playtest P6A3 ; presets partagés P4/P5 conservés. Rapport actif :
`docs/dev/P6A3_PLAYTEST_HOTFIX_REPORT.md`.

**Prochaine action : verdict humain sur le ZIP playtest corrigé.
STOP après commit/push ; aucun autre chantier.**
PR #9 reste DRAFT. Aucun merge, P6B, P7, nouvelle génération ni travail
jacket/emprise automatique. Les outils et Foley restent des candidats de revue.
Tripo Studio/API ont des soldes distincts ; accès/génération ne vaut pas validation
artistique. Pour reprendre le workflow, suivre le rapport, pas les anciens
blocages techniques du preflight.

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
