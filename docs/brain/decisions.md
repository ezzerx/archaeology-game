# Décisions initiales

Source : décisions confirmées par Antoine au 2026-09-30 et au 2026-10-01.

## Décisions produit

| Décision | Conséquence |
|---|---|
| Tabletop fixe, sans avatar | La fouille est le centre du jeu |
| DA 2.5D stylisée, orthographique presque verticale | Relief, lumière et profondeur prioritaires |
| Pixel art non retenu pour V0.1 | Liberté de creusement et contours |
| Trois outils | Soft Brush, Chisel, Air Blower |
| Matières cœur | Loose Soil, Compact Clay, Sandstone |
| Specimen B-17 | Petit théropode fictif / indéterminé |
| Premier contact os protégé | La découverte ne punit pas instantanément |
| Bone Condition sans Game Over | Tension légère |
| Musée scrollable, non navigable | Méta-progression future |
| Godot 4.7.2 stable Standard | Stack prototype |

## Gates validées

### P0
Validé par Antoine. Merge :
`244aba3652a03aac908b1aabe1651c3b9edb1315`.

### P1
Validé par Antoine. Merge :
`960642c3fc6972bdb257c96abd43b90c148e632d`.

Décisions techniques principales :

- height RF 1024×640 ;
- grille GPU dense ;
- picking DDA sur la même topologie que le rendu ;
- stratigraphie statique irrégulière ;
- Hard Rock omis.

### P2
Validé par Antoine : les outils fonctionnent comme voulu pour le prototype.

Merge :
`9b8423fedfb4723ba8b0113a23e564ba474c8bd2`.

Décisions P2 :

- ToolDefinition minimal ;
- Brush continu ;
- Chisel impacts discrets à 4,5 Hz ;
- Blower sans excavation structurelle ;
- résidu debug léger 256×160 R8 ;
- aucun système fossile ou polish final en P2.

## Décision FPS — 2026-10-01

Pendant P2, Godot utilisait la RTX 5080 à 100% lorsque le rendu était non plafonné.

Décision d'Antoine :

- **runtime interactif normal plafonné à 240 FPS à partir de P3** ;
- benchmarks autorisés à override le plafond ;
- ne pas lancer de chantier d'optimisation GPU supplémentaire tant que le comportement à 240 FPS n'est pas retesté ;
- si nécessaire, réduire encore le cap après test humain.

## Scope P3

P3 est autorisé.

Il doit couvrir :

- fossile caché ;
- exposition progressive ;
- bone ceiling ;
- Bone detected ;
- protection premier contact ;
- condition 100→0 ;
- dégâts Chisel uniquement sur os déjà exposé ;
- Brush/Blower sûrs ;
- exposition globale/composants.

P3 ne doit pas couvrir classification, fragments, objectifs, final audio/VFX ou musée.

Référence : [P3_BRIEF](../dev/P3_BRIEF.md).


## Future product pillars confirmed — 2026-10-01

These directions are now confirmed as intended future features, but their detailed design is deliberately deferred until the core excavation loop and visual pipeline are validated.

### Variable excavation blocks

The finished game must not repeat identical layer depths and stratigraphy across every block.

Future blocks should use controlled, seed-based / authored variability so the player reads the material rather than memorizing fixed depths.

Confirmed future variation may include:

- variable layer thicknesses;
- irregular interfaces;
- local pockets / lenses;
- variable fossil depth / position / orientation where compatible;
- difficulty bands.

Implementation is deferred until after the V0.1 core gate.

### Equipment progression

Long-term progression should include tool unlocks / specialization in addition to fossil collection.

Prefer functional choices (precision, width, stiffness, power/risk, nozzle control, preservation tools) over simple percentage upgrades.

Detailed progression economy / tree / currency remains open for a dedicated brainstorm.

### Expertise / site progression

Long-term progression should also unlock more demanding excavation sites / matrices.

Possible framing includes museum prestige, expertise, reputation, funding or another diegetic system.

Detailed design is deferred.

Reference: [FUTURE_SYSTEMS.md](../FUTURE_SYSTEMS.md).

## Visual-production timing clarified — 2026-10-01

Canonical roadmap numbering remains:

**P0 → P1 → P2 → P3 → P4 → P5 → P6 Art Pass → P7 Tuning**

There is **no separate ART0 phase**.

Decision:

- advance gameplay with placeholder/greybox visuals using a Pareto 80/20 approach;
- P4 adds only the sensory visuals/audio needed to validate game feel;
- P5 completes the gameplay loop and functional UI without requiring final DA;
- P6 is the dedicated DA milestone once visual production has greater leverage than adding another gameplay system;
- inside P6, first run a **P6A Visual Direction / Production Spike**, then a **P6B V0.1 Art Pass**;
- P7 tunes the completed, art-passed slice.

DA remains a core product risk and must not be treated as optional polish, but expensive production art is intentionally deferred until the gameplay foundation is mature.

Reference: [ROADMAP.md](../ROADMAP.md) and [ART_DIRECTION.md](../ART_DIRECTION.md).


## Engine policy — Godot remains canonical — 2026-10-01

Decision by Antoine:

> Continue development on Godot. Do not perform a speculative Unity port or parallel implementation.

Rationale:

- Godot currently satisfies the technical needs of ArchaeologyGame;
- the existing P0–P3 architecture is progressing quickly and has not hit an engine-specific blocker;
- switching now would impose a certain rewrite cost for hypothetical benefits;
- Unity's larger ecosystem / artist tooling is acknowledged, but is not sufficient reason by itself to migrate.

A Unity switch should be reconsidered only if a **concrete, material engine limitation** appears, for example:

- a required visual/VFX result is significantly harder or impractical in Godot;
- the art/content pipeline is materially less efficient than a Unity equivalent;
- performance cannot meet target hardware after reasonable Godot optimization;
- console/platform requirements make Unity materially more practical;
- a critical production tool or middleware cannot be integrated reasonably in Godot.

The comparison standard is not “Unity has more features”, but:

> **Would Unity materially reduce risk, effort, or quality limitations for a problem we are actually facing?**

Until such a case exists, Godot 4.7.2 remains the canonical engine for the prototype and subsequent development.
