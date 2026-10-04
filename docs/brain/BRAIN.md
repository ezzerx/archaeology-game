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

Le premier spike P4-V2 a reçu SIMPLIFY, puis les micro-débris ont été rejetés. **Antoine valide maintenant le look Matrix 4,5 mm restauré et sa physique, ainsi que les chunks Chisel transitoires.** La dernière clôture retire les particules Soil (**dust-only**), conserve le cap Matrix 256 et augmente les quotas locaux à Clay3/Stone4. Le Blower garde son pop unique et conserve l’élan 2 s jusqu’à la vraie sortie ; le film Bone, validé en gameplay, devient brun terreux plus sombre. Seul Brush le nettoie. **Exposure ≠ Cleanliness ≠ Condition.** [Rapport de clôture et checklist](../dev/P4V2_REPORT.md). **PR #7 DRAFT, STOP pour retest humain final ; aucun merge ni P5.** La géologie V1.1 et le cleanup V1.2 restent exacts : [P4V_REPORT](../dev/P4V_REPORT.md). Règle : **Verticality / generation must be effort-aware, not depth-only.** Watchpoint Dust/arêtes différé P6/P7. [Relief/picking](../dev/P1_RELIEF_DECISION.md), [os](../dev/P3_FOSSIL_DECISION.md).
