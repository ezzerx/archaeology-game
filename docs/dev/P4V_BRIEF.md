# P4-V1.2 — Visual Cleanup

**Status:** base verticale V1.1 jugée meilleure ; micro-passe visuelle V1.2, puis test humain

**Date:** 2026-10-04  
**Base:** `main@7ae0fec3c004d207c99f4713111a240f8d5f2e9a`  
**Branch:** `prototype/p4v-verticality`  
**Scope:** interfaces et lisibilité des blocs uniquement ; distribution V1.1 conservée. Aucune physique de débris.

## Passe courante V1.2 — prioritaire

Référence : `36bd665b2fdf3362875c55803dc184dad84056b3`. Le retour humain est positif sur la base verticale : conserver cette direction sans nouvelle passe de géologie. Deux objectifs : supprimer la grille/les stries Clay parasites sur Sandstone ; améliorer la séparation et la profondeur perçues des blocs, éclats et miettes.

Diagnostiquer d'abord la présence réelle de Clay et le sampling des interfaces. Une couche fine doit rester propre ; rendu, matériau du curseur et CPU doivent rester cohérents. Contraste local ou clarification légère des faces autorisés, sans changer la logique des morceaux. Préserver outils, résistances, fracture, Bone, audio, caméra et cap 240 FPS / physique 60 Hz. Tous les tests existants restent verts ; ajouter des vérifications ciblées CPU/GPU, couches fines, lisibilité et une sanity de performance.

Commit/push sur la même branche, **PR #6 reste DRAFT, aucun merge**, puis STOP. Antoine vérifie les interfaces (grille orange encore visible ? **NON**), les blocs/profondeur au Chisel (plus lisibles ? **OUI**), puis 5–10 minutes libres (base toujours aussi agréable ? **OUI**). Checklist exacte et preuves dans [P4V_REPORT](P4V_REPORT.md). Aucun P4-V2, procgen, P5 ou retuning.

## Distribution V1.1 — conservée, contexte de la correction précédente

Référence avant correction : `122e9b1cf6dfacad721f9af240ef30592de8491c`. Antoine valide l'intérêt de la variation de profondeur, mais certaines colonnes Sandstone sont trop longues à traverser. Modifier **uniquement la distribution des couches** : descendre l'interface Clay/Sandstone avec un champ large et lisse en UV. Aucun masque Bone, clamp sur la silhouette ou correctif par cellule. Les cellules Bone servent à mesurer et valider le résultat.

Conserver les plafonds Bone autant que possible, environ **55–85 mm / 30 mm d'amplitude**, les variations Soil/Clay et les chemins distincts A/B/C. Les ressources outils, résistances, efficacités, cadences, fracture, audio, protections et contrôles P4 restent verrouillés. Pas de procgen, P4-V2 ou P5.

Budgets prototype sur **toutes les 32 290 cellules Bone**, pas seulement les fixtures : Sandstone typique **5–18 mm**, **P95 ≤18–20 mm**, maximum **≤22 mm**. Zéro Sandstone est acceptable si Bone arrive naturellement dans Clay. A Skull `(250,230)` et C Hind Limb `(646,441)` visent environ 10–18 mm ; B Spine `(510,307)` conserve un chemin plus court. La distribution globale prime sur l'ajustement exact de ces trois points.

Ajouter un oracle debug/test depuis le top intact :

```text
hard_work_index = Clay_au-dessus_de_Bone_mm × (3 / 1.0)
                + Sandstone_au-dessus_de_Bone_mm × (8 / 1.5)
```

Lire les poids dans les ressources production. Si Bone est dans Clay, exclure la Clay sous son plafond. Cet indice exclut Soil, puissance/cadence, fracture et gestes : **comparaison relative, aucune prédiction de temps réel**. F1 suffit, sans nouvelle interface joueur.

Mesurer avant/après min, médiane, P90, P95 et max de Sandstone et de l'effort, conserver les profondeurs Bone et les profils A/B/C. Tester également trois résolutions, interfaces, amplitudes Soil/Clay/Bone, IDs/silhouette/totaux exacts, CPU/GPU/picking et la séquence **tik/100 → DING/97 → tik/97 → DING/94**. Les anciennes attentes de contraste A/B/C doivent refléter la redistribution ; conserver les seuils numériques des oracles géométriques et matériaux.

Règle confirmée pour la suite : **“Verticality / generation must be effort-aware, not depth-only.”** Une future seed devra respecter des budgets de travail pondérés par la matière, en plus des invariants géométriques. Aucun générateur n'est implémenté maintenant.

La livraison V1.1 et ses mesures restent dans [P4V_REPORT](P4V_REPORT.md). Son protocole à cinq questions est historique ; le prochain test est celui de V1.2 ci-dessus. **PR #6 reste DRAFT, aucun merge**.

## Brief initial V1 — contexte conservé

Les invariants ci-dessous restent applicables ; budgets Sandstone et composition Clay sont ceux de V1.1, le prochain protocole humain est celui de V1.2 ci-dessus.

## Why this spike exists

P4 Final Feel is good enough to freeze for now: breaking, cleanup, precision work, tool baselines, Bone audio and per-component protection are all human-validated.

A new core risk remains:

> the player can still learn a mostly fixed vertical script — Soil, then Clay, then Sandstone, then Bone at roughly the same depth.

That is too predictable for repeated excavation.

The full procedural-generation system remains future work. What moves earlier is only the **verticality foundation** because layer thickness and fossil burial depth directly change the excavation gameplay.

## Product goal

Create one deterministic B-17 block where excavation depth genuinely varies across the block.

The player should encounter:
- noticeably different Soil thicknesses;
- noticeably different Clay thicknesses;
- Sandstone beginning at different depths;
- different amounts of hard matrix above nearby fossil regions;
- different Bone burial depths across the same skeleton.

The player should need to **read the material and the cavity**, not memorize a fixed depth/timer.

## Explicit non-goals

Do **not** implement:
- random seeds;
- procedural block generation;
- multiple generated variants;
- site progression;
- new materials;
- debris gravity / terrain collision;
- sliding/bouncing chunks;
- physics bodies for debris;
- P5 UI/progression;
- P6 art;
- final tuning.

Those are separate later decisions.

## V1 design rule

This is **authored deterministic macro-stratigraphy**, not noise.

The block must remain identical every reset and every run.

Broad geological shapes are preferred:
- long slopes;
- broad folds;
- one or two lenses/pockets;
- gradual rises/falls.

Avoid:
- high-frequency noise;
- checkerboard thickness;
- arbitrary per-cell randomness;
- interfaces so chaotic that material reading becomes impossible.

## Current system to replace/extend

Current `Stratigraphy` uses gentle sin/cos variation around:
- Soil bottom ≈ 0.70
- Clay bottom ≈ 0.36

This is only micro-variation.

P4-V1 must introduce **macro variation** while preserving:
- normalized height semantics;
- `packed_limits`;
- CPU/GPU agreement;
- existing layer sampling;
- material resistance logic;
- fracture logic;
- RF authority.

## Target ranges

Physical excavatable depth remains ~102 mm.

Use these as design bands, not hard final tuning:

### Soil

Visible thickness across the block should vary roughly from:
- shallow: ~15–20 mm
- deep: ~40–45 mm

Equivalent normalized bottom roughly:
- high bottom ~0.80–0.85
- low bottom ~0.55–0.60

### Clay

Clay thickness should vary clearly, roughly:
- thin: ~10–15 mm
- thick: ~35–40 mm

Enforce a minimum readable thickness where Clay exists.

### Sandstone

Sandstone thickness above Bone should vary meaningfully.

Some Bone regions should be reached after a relatively short Sandstone pass.
Other Bone regions should remain under substantially more Sandstone.

The exact numbers are secondary to the human result:
- nearby regions should not all reach Bone after the same amount of Chisel work.

## Layer ordering invariants

Always enforce:

`1.0 > soil_bottom > clay_bottom > 0.0`

And keep safe minimum gaps so interfaces never cross due to formulas.

Suggested minimum normalized layer gap:
- Soil thickness >= ~0.10
- Clay thickness >= ~0.08

Exact constants may be adjusted if tests show better values.

## Fossil burial verticality

Layer variation alone is not sufficient.

B-17 Bone ceilings currently have only modest authored depth variation.

Add a deterministic **broad burial offset field** to Bone ceiling height so different parts of the skeleton sit at meaningfully different depths.

Requirements:
- broad, smooth variation;
- same value for overlapping authored Bone at the same XY so component ownership/counts do not change unexpectedly;
- no random noise;
- no per-run seed;
- preserve fossil 2D silhouette/component map;
- keep every Bone ceiling inside valid excavatable range;
- preserve Bone ceiling authority and exposure logic.

Good mental model:

> B-17 lies on a gently tilted / warped burial plane.

Not:
> each bone has a random Z.

A broad tilt plus one gentle low-frequency warp is sufficient for V1.

Target human effect:
- Skull may be relatively shallow;
- another region such as Ribs/Hind Limb can require noticeably deeper excavation;
- the player cannot infer the whole skeleton depth from the first Bone discovery.

Do not make the skeleton visually absurdly twisted.

## Coupling to materials

Do not overengineer a geological solver.

It is acceptable in V1 if different Bone regions are surrounded by different hard-matrix thicknesses.

The key requirement is:
- no Bone starts above the intact top;
- no Bone goes below the excavation floor;
- all Bone remains reachable;
- no authored component becomes impossible to expose.

If Bone locally sits closer to a Clay/Sandstone interface, that is acceptable and may be useful gameplay.

## Determinism / future compatibility

Keep this block deterministic.

Prefer pure authored functions of normalized UV so results are:
- resolution-independent;
- reproducible;
- easy to test.

Do not introduce the future generator yet.

If helpful, isolate the verticality formulas behind a small helper/profile API so a future seeded generator can replace the authored fields later, but do not build the generator now.

## Debug requirements

Add enough debug visibility to validate verticality without guessing.

F1 should expose at cursor, where applicable:
- Soil thickness in mm;
- Clay thickness in mm;
- Sandstone depth from Clay boundary to current/known Bone ceiling if Bone exists at that XY;
- Bone depth from intact top in mm;
- current material.

Use existing debug UI; no production UI.

F2/material/height debug views must remain correct.

Optional: one additional debug visualization for macro interfaces only if it materially helps and does not complicate controls.

## Human validation fixture

The block must contain at least three intentionally different excavation zones:

### Zone A — shallow path
A place where Soil/Clay are relatively thin and Bone or deep Sandstone is reached earlier.

### Zone B — medium path
A middle-of-the-road region.

### Zone C — deep path
A place where one or more layers are clearly thicker and Bone is substantially deeper.

These zones should be deterministic and documented by map coordinates for tests.

Do not add visible player markers in normal gameplay.

## Acceptance questions

Human test should answer:

1. Can I feel that layer thickness changes across the block?
2. After finding Bone in one area, can I still be surprised by how deep another area is?
3. Do I look at the material/cavity instead of mentally counting seconds?
4. Does the extra depth variation make Chisel/Brush/Pick choices more interesting?
5. Does the block still feel coherent rather than noisy/random?
6. Does the P4 Final Feel remain intact?

North-star subquestion:

> “If I already found the skull, do I still have uncertainty about what depth the rest of the specimen is at?”

Target answer: **yes**.

## Regression requirements

All P0–P4 tests must remain green.

Specifically preserve:
- P4 tool baselines;
- Chisel A spectacle;
- Blower B cleanup feel;
- Soil feel;
- Precision Pick;
- Bone per-component protection;
- Bone Condition;
- zoom/pan/picking;
- fixed tool proxies;
- audio semantics;
- 240 FPS cap / 60 Hz physics.

## New tests

Add deterministic checks for:

### Stratigraphy
- boundaries identical across reset/run;
- same normalized UV gives same result at different map resolutions within tolerance;
- layer ordering never crosses;
- minimum thickness invariants hold;
- target macro range is actually present;
- zones A/B/C produce distinct thickness profiles.

### Fossil burial
- component cell counts unchanged from P4 unless an explicitly documented reason exists;
- component IDs unchanged at same XY;
- Bone ceiling stays within legal bounds;
- burial depth range is meaningfully larger than P4 baseline;
- Bone depth varies smoothly, not cell-noise;
- all components remain exposable.

### CPU/GPU
- shader material classification still agrees with CPU;
- displaced surface/picking remains exact;
- layer-boundary texture remains authoritative.

### Performance
- no new per-frame full-map work;
- verticality is precomputed/static for the block;
- normal interaction remains comfortably >=60 FPS;
- benchmark Brush/Chisel/Pick/Blower at shallow and deep zones.

## Performance architecture rule

Verticality must be **data**, not a runtime simulation.

Compute the authored boundaries / burial field:
- at block construction/reset as appropriate;
- not every frame;
- not every tool tick beyond existing lookups.

Do not add a dynamic geology solver.

## Deliverables

Update/create:
- `docs/dev/P4V_REPORT.md`
- `docs/brain/status.md`
- `docs/brain/decisions.md`
- `docs/FUTURE_SYSTEMS.md` clarification:
  - deterministic macro-verticality foundation moved into P4-V;
  - procedural/seeded block variability remains future work.

Document:
- formulas/profile used;
- normalized and mm ranges;
- A/B/C fixture coordinates;
- Bone burial range before/after;
- tests;
- performance;
- known limits.

## Git / stop condition

Stay on:
`prototype/p4v-verticality`

Use the new P4-V draft PR.

Do not merge.

When V1 verticality is implemented and automated checks pass:

**STOP for human test.**

Do **not** start debris gravity/physics yet.

The next possible step, only after human approval, is:

**P4-V2 — terrain-aware debris gravity / bounce / blower impulse.**
