# Brain canonique — ArchaeologyGame

Le contexte du projet voyage avec ce dépôt. Le Brain personnel conserve uniquement son routage ; ce Brain local prévaut pour le concept, les décisions et le statut.

## À lire à la reprise

**P6A-1 — Material Lab, 2026-10-06 :** P5 clos et mergé ; PR #9 DRAFT sur `prototype/p6a-visual-spike`. [Brief](../dev/P6A_BRIEF.md), [rapport courant](../dev/P6A_REPORT.md). Scène séparée de comparaison P5/A/B/C, mêmes données B-17 et gameplay gelé. **Arrêt pour revue humaine après le laboratoire.** Aucune suite éclairage/jacket/assets/UI/hero slice/P6B ni canonisation automatique.

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

P5 est suffisamment validé humainement pour avancer. Ses limites acceptées (baisse du ratio Clean lors de nouvelles révélations, complétude perceptuelle imparfaite) restent différées. Les anciens brief/rapports et fragments ne rouvrent pas le gameplay. La revue courante porte seulement sur le Material Lab.

Les baselines outils, Matrix4,5 mm/physique, film, plafonds, protections, caméra et audio P4 restent verrouillées. Soil sans mess persistant, Pick11/0,44/1,75, micro-restes bornés et évacuation Blower avec FX0,35 s sont conservés : [clôture P4](../dev/P4V2_REPORT.md). **Exposure ≠ Cleanliness ≠ Condition.** Géologie V1.1 et cleanup V1.2 : [P4V_REPORT](../dev/P4V_REPORT.md). Règle : **Verticality / generation must be effort-aware, not depth-only.** Les derniers20 % du polish excavation attendent une phase future explicitement autorisée.
