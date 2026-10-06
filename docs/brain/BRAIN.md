# Brain canonique — ArchaeologyGame

Ce dossier porte les décisions et le statut propres au projet.

## À lire à la reprise

1. [status.md](status.md) — **source unique du statut courant**
2. [ORCHESTRATION_HANDOFF](../ORCHESTRATION_HANDOFF.md) — mental model stable
3. brief/report de la phase active indiqué par `status.md`
4. [decisions.md](decisions.md) — décisions durables et historique
5. [DOCUMENTATION_POLICY](../DOCUMENTATION_POLICY.md)

Ne jamais déduire la phase active depuis un ancien rapport, le README ou une branche historique.

## Sources canoniques par sujet

| Besoin | Document |
|---|---|
| Vision et périmètre | [CONCEPT](../CONCEPT.md) |
| Boucle, matières, outils, gestes | [GAMEPLAY_LOOP](../GAMEPLAY_LOOP.md) |
| Atmosphère et rendu | [ART_DIRECTION](../ART_DIRECTION.md) |
| Expérience V0.1 | [MVP_V0_1](../MVP_V0_1.md) |
| Collection et musée | [MUSEUM_SYSTEM](../MUSEUM_SYSTEM.md) |
| Architecture / hypothèses techniques | [TECH_NOTES](../TECH_NOTES.md) |
| Jalons conditionnels | [ROADMAP](../ROADMAP.md) |
| Systèmes futurs | [FUTURE_SYSTEMS](../FUTURE_SYSTEMS.md) |

## Principes durables

- Gameplay excavation d'abord, contenu/meta ensuite.
- Tabletop quasi top-down, sans avatar contrôlable.
- **Exposure ≠ Cleanliness ≠ Condition.**
- Godot 4.7.2 reste canonique tant qu'aucun blocker concret ne justifie un changement.
- Les validations automatisées ne remplacent jamais le test humain.
- Les rapports historiques prouvent ce qui a été testé ; ils n'autorisent pas la phase suivante.
- La variabilité future doit être **effort-aware, not depth-only**.
- P6 doit prouver une pipeline visuelle crédible avant scaling.

Pour le statut exact, les watchpoints actifs et la prochaine action autorisée : **toujours lire `status.md`**.
