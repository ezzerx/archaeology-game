# Brain canonique — ArchaeologyGame

Le contexte du projet voyage avec ce dépôt. Le Brain personnel conserve uniquement son routage ; ce Brain local prévaut pour le concept, les décisions et le statut.

## À lire à la reprise

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

Pour reprendre, lire [P4V2_BRIEF](../dev/P4V2_BRIEF.md), [P4V2_REPORT](../dev/P4V2_REPORT.md) et [status.md](status.md). **P4 Final Feel et P4-V1 sont validés humainement et mergés** ; baseline `main@ce014d0c2dd311ed2fbac0f37e0001be707a74a7`. Baselines outils, spectacle, nettoyage, audio, protection par composant et caméra verrouillées : [P4_FINAL_FEEL_TARGET](../dev/P4_FINAL_FEEL_TARGET.md).

Le spike **P4-V2** ajoute uniquement la physique secondaire de 48 éclats durs maximum, avec F3 ON/OFF et reset identique. **PR #7 DRAFT, STOP pour KEEP / SIMPLIFY / DROP humain ; aucun merge ni P5 automatique.** La géologie V1.1 et le cleanup V1.2 restent exacts : [P4V_REPORT](../dev/P4V_REPORT.md). Règle canonique : **Verticality / generation must be effort-aware, not depth-only.** Pas de nouvelle passe géologique ni seed/procgen. Watchpoint poussière/arêtes différé P6/P7. Relief/picking : [P1_RELIEF_DECISION](../dev/P1_RELIEF_DECISION.md) ; os : [P3_FOSSIL_DECISION](../dev/P3_FOSSIL_DECISION.md).
