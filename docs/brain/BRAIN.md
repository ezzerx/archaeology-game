# Brain canonique — ArchaeologyGame

Le contexte du projet voyage avec ce dépôt. Le Brain personnel conserve uniquement son routage ; ce Brain local prévaut pour le concept, les décisions et le statut.

## À lire à la reprise

**Passe active : correction P5 après test humain1 non concluant.** Lire [P5_HUMAN_CORRECTION_BRIEF](../dev/P5_HUMAN_CORRECTION_BRIEF.md), [P5_CORRECTION_REPORT](../dev/P5_CORRECTION_REPORT.md) et le dernier statut. Le Keep Cleaning initial n'est pas un KPI validé. Retest libre requis ; PR #8 DRAFT, aucun merge/P6.

0. [ORCHESTRATION_HANDOFF](../ORCHESTRATION_HANDOFF.md) — mental model produit et protocole de reprise
1. [AGENTS.md](../../AGENTS.md)
2. [status.md](status.md)
3. [decisions.md](decisions.md)
4. [README](../../README.md), puis les seules fiches utiles à la demande.

## Sources canoniques

| Besoin | Document |
|---|---|
| Vision et périmètre | [CONCEPT](../CONCEPT.md) |
| Matière, outils, gestes et mystère | [GAMEPLAY_LOOP](../GAMEPLAY_LOOP.md) |
| Atmosphère et choix de rendu | [ART_DIRECTION](../ART_DIRECTION.md) |
| Expérience prioritaire | [MVP_V0_1](../MVP_V0_1.md) |
| Collection et musée | [MUSEUM_SYSTEM](../MUSEUM_SYSTEM.md) |
| Architecture / hypothèses Godot | [TECH_NOTES](../TECH_NOTES.md) |
| Jalons conditionnels | [ROADMAP](../ROADMAP.md) |

Provenance : demande de canonisation d’Antoine le 2026-09-30, complétée par la conversation ChatGPT « jeu archéologie » (`6abd6b0a-1744-83eb-80f3-f739fa4f427d`). Les anciens messages sont du contexte ; les orientations de la demande actuelle prévalent. La planche canonique est versionnée dans `docs/visual-references/` sur la branche P0 ; elle n'est pas un asset de production.

Pour reprendre, lire [P5_BRIEF](../dev/P5_BRIEF.md), [P5_REPORT](../dev/P5_REPORT.md) et [status.md](status.md). **P4 est validé humainement et mergé** ; base P5 `main@b2a32c8ae97c8fec2c8a583c405ac9274ef566af`. La première boucle complète P5 est livrée sur `prototype/p5-loop-progression`, **PR #8 DRAFT**, pour le test humain end-to-end. **Aucun merge ni P6 automatique.**

P5 observe les systèmes existants, ajoute deux fragments indépendants avec Forceps, classification/objectifs/dossier, puis **Preparation Complete → Keep Cleaning → Archive Specimen → Prepare Another Block**. Les snapshots completion et archive sont distincts. Le test comportemental central reste l’envie de continuer après l’annonce de fin ; le premier essai était ambigu et ce comportement doit être retesté après correction.

Les baselines outils, Matrix4,5 mm/physique, film, plafonds, protections, caméra et audio P4 restent verrouillées. Soil sans mess persistant, Pick11/0,44/1,75, micro-restes bornés et évacuation Blower avec FX0,35 s sont conservés : [clôture P4](../dev/P4V2_REPORT.md). **Exposure ≠ Cleanliness ≠ Condition.** Géologie V1.1 et cleanup V1.2 : [P4V_REPORT](../dev/P4V_REPORT.md). Règle : **Verticality / generation must be effort-aware, not depth-only.** Les derniers20 % du polish excavation attendent une phase future explicitement autorisée.
