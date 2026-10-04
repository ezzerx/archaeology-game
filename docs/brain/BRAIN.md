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

Pour reprendre, lire [dev/P4_FINAL_FEEL_TARGET.md](../dev/P4_FINAL_FEEL_TARGET.md), source de vérité de la composition A/B et du dernier lock, puis [dev/P4_REPORT.md](../dev/P4_REPORT.md) et [dev/P4_MATERIAL_REACTION_DECISION.md](../dev/P4_MATERIAL_REACTION_DECISION.md). **P4 FINAL FEEL** compose spectacle Chisel A, nettoyage visible Blower B, mécaniques Soil/Pick et angle ancien fixe. Baselines humaines persistées : Brush 40/0.70/1.25, Chisel 22/0.64/2.25, Blower 60/0/1, Pick 7/0.24/1.50 ; tuning final P7. Premier Chisel sur un centre Bone **déjà exposé avant le coup** : petit tik, zéro dégât ; toute révélation, même centrale, reste matériau et ne consomme pas la protection. Hit direct suivant : DING/−3. Quantité persistante bornée, fracture, dégâts ultérieurs, ivoire poussiéreux et caméra préservés. Lock préparé pour fermeture ; les tests automatiques ne valident pas le plaisir. P0/P1/P2/P3 sont validés et mergés ; **PR #5 reste brouillon : aucun merge P4, P4-V ou P5 sans autorisation explicite**. Relief et os : [dev/P1_RELIEF_DECISION.md](../dev/P1_RELIEF_DECISION.md), [dev/P3_FOSSIL_DECISION.md](../dev/P3_FOSSIL_DECISION.md).
