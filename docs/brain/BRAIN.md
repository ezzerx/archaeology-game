# Brain canonique — ArchaeologyGame

Le contexte du projet voyage avec ce dépôt. Le Brain personnel conserve uniquement son routage ; ce Brain local prévaut pour le concept, les décisions et le statut.

## À lire à la reprise

**P5 courant — coverage + Condition, 2026-10-05 :** archive = Exposure≥85 % ET Cleanliness≥85 % ET chacun des quatre composants majeurs révélé à≥65 %. Garde cachée sauf « Major section still covered » quand elle bloque85/85. Carte unique : Museum standard85 %, Reveal/Clean, Condition qualitative (Excellent≥95 / Good≥85 / Fair≥70 / Damaged<70), sans troisième barre. L'étoile globale95/95 reste facultative et indépendante de Condition. Les quatre outils et P4 sont inchangés. [Rapport courant](../dev/P5_COVERAGE_CARE_REPORT.md). **P5 non validé humainement, PR #8 DRAFT ; aucun merge/P6.**

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

P5 doit prouver qu'une session est comprise, terminée et archivée sans explication. Les tests humains antérieurs n'ont pas validé cette compréhension ; l'envie de poursuivre ne se mesure qu'après une fin clairement comprise. Les anciens brief/rapports P5 et les fragments décrivent des expériences supersédées. Le retest courant comporte seulement neuf questions et laisse jouer librement.

Les baselines outils, Matrix4,5 mm/physique, film, plafonds, protections, caméra et audio P4 restent verrouillées. Soil sans mess persistant, Pick11/0,44/1,75, micro-restes bornés et évacuation Blower avec FX0,35 s sont conservés : [clôture P4](../dev/P4V2_REPORT.md). **Exposure ≠ Cleanliness ≠ Condition.** Géologie V1.1 et cleanup V1.2 : [P4V_REPORT](../dev/P4V_REPORT.md). Règle : **Verticality / generation must be effort-aware, not depth-only.** Les derniers20 % du polish excavation attendent une phase future explicitement autorisée.
