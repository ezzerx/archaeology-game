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

Pour reprendre, lire [dev/P4V_BRIEF.md](../dev/P4V_BRIEF.md), puis [dev/P4V_REPORT.md](../dev/P4V_REPORT.md) et [status.md](status.md). **P4 Final Feel est validé humainement et mergé** au commit `7ae0fec3c004d207c99f4713111a240f8d5f2e9a`. Ses baselines outils, spectacle, nettoyage, audio, protection par composant et caméra restent verrouillés : [P4_FINAL_FEEL_TARGET](../dev/P4_FINAL_FEEL_TARGET.md).

**P4-V1** introduit seulement une macro-stratigraphie et un enfouissement B-17 déterministes, précalculés dans les cartes statiques. Le profil ne change ni la silhouette ni les composants. PR #6 sur `prototype/p4v-verticality`, toujours brouillon. Les tests techniques ne valident pas l'intérêt humain : **STOP pour test Antoine ; aucun merge, P4-V2 debris physics, procgen ou P5 automatique**. Relief/picking : [P1_RELIEF_DECISION](../dev/P1_RELIEF_DECISION.md) ; os : [P3_FOSSIL_DECISION](../dev/P3_FOSSIL_DECISION.md).
