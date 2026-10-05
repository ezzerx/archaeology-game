# P5 — Complete Session Loop / UI & Progression

> **Historique — supersédé pour le parcours actif.** La dernière décision85/95 du [brief humain](P5_HUMAN_CORRECTION_BRIEF.md) et [P5_SIMPLIFICATION_REPORT](P5_SIMPLIFICATION_REPORT.md) font autorité : carte unique, quatre outils, étoile globale facultative ; aucun fragment/dossier droit. Les chiffres et captures ci-dessous décrivent cette ancienne livraison.

**Status:** authorized after human closure of P4  
**Date:** 2026-10-05  
**Base:** `main@b2a32c8ae97c8fec2c8a583c405ac9274ef566af`  
**Branch:** `prototype/p5-loop-progression`  
**Scope:** one complete museum-preparation session, functional UI, classification progression, manual fragment recovery and completion/archive flow.

## Product objective

P4 proved that excavation/preparation is satisfying enough to build a complete session around it.

P5 must answer:

> Does one full specimen-preparation session make sense from start to finish, with clear goals, progression, recovery, completion and a diegetic museum handoff?

P5 is **not** the full museum metagame and **not** the final art/UI pass.

The player should understand:
- what they are working on;
- what has been discovered;
- what remains to do;
- when preparation is complete;
- why they may keep cleaning;
- how the prepared specimen leaves the workshop and enters museum records.

## Narrative baseline

Current canon:

> The player works as a specimen preparator/restorer in the back rooms of a natural-history museum.

The museum assigns specimen B-17 to the preparation lab.

P5 should lightly reinforce that framing without building a full museum scene.

Suggested functional framing:
- header / dossier: **Museum Preparation Lab — Specimen B-17**
- completion action: **Archive Specimen**
- archive confirmation: **Museum records updated**
- prototype continuation: **Prepare Another Block**

The actual façade/menu and full gallery belong later, especially P6.

## P5 source precedence

This brief overrides older prototype text where it conflicts.

Specifically:

1. `PROTOTYPE_V0_1_SPEC.md §21` currently says fragment recovery is automatic.  
   **P5 replaces this with manual Forceps recovery.**

2. `PROTOTYPE_V0_1_SPEC.md §23` currently offers `Restart Specimen`.  
   **P5 replaces the primary diegetic end flow with Archive Specimen → Prepare Another Block.**

3. Precision Pick [4], Bone Film, verticality and all P4 baselines are now canonical even where older spec sections still describe only three tools.

## P4 baseline — do not retune

Keep exactly:

### Soft Brush
- radius 40
- power 0.70
- falloff 1.25

### Chisel
- radius 22
- power 0.64
- falloff 2.25
- cadence 4.5 Hz

### Air Blower
- radius 60
- power 0
- falloff 1.0
- residue_clear 2.5

### Precision Pick
- radius 11
- power 0.44
- falloff 1.75
- cadence 6 Hz
- Bone damage 0

Preserve:
- Chisel fracture spectacle;
- effort-aware verticality;
- Matrix crumbs / Blower cleanup;
- Bone Surface Film;
- per-component protected Bone contact;
- Bone Condition;
- camera / pan / zoom / picking;
- current performance constraints.

P5 must not become a disguised P4 tuning pass.

---

# 1. Session progression model

Create one event-driven P5 session/progression state.

Working name:
- `PreparationSession`
- `SpecimenProgress`
- equivalent.

It should **observe** authoritative P4 systems rather than duplicate them.

Authoritative sources remain:
- `FossilState` for exposure/component data;
- `BoneSurfaceFilm` for cleanliness;
- Bone Condition state;
- recoverable-fragment state;
- tool / working surface state.

P5 state derives:
- classification stage;
- objective completion;
- fragment recovery;
- completion availability;
- archive state;
- post-completion behavior metrics.

Avoid full-map scans every frame.

Update only on relevant events:
- Bone exposure changed;
- Bone Film changed;
- fragment readiness/recovery changed;
- Bone Condition changed;
- reset;
- completion/archive actions.

---

# 2. Three distinct Bone concepts

P4 established:

> **Exposure ≠ Cleanliness ≠ Condition**

P5 must preserve this separation in both code and UI.

### Exposure
How much Bone structure is revealed.

### Cleanliness
How much adhered Bone Surface Film has been removed from exposed Bone.

### Condition
Damage state from direct damaging contacts.

Do not collapse them into one percentage.

Functional dossier may show:
- Skeleton exposed: XX %
- Bone cleanliness: XX %
- Condition: XX %

Exact labels may be refined, but the three meanings must remain distinct.

---

# 3. Component preparation states

Use the four existing anatomical components:

- Skull
- Spine / Vertebrae
- Ribs
- Hind Limb

Expose simple progression states to the dossier.

Suggested provisional states:

### Hidden
Exposure < 10 %

### Detected
Exposure >= 10 %

### Exposed
Exposure >= 50 %

### Prepared
Exposure >= 80 %
AND cleanliness of currently exposed cells >= 80 %

These thresholds are **P5 prototype values**, not final P7 tuning.

Keep them data-driven or centralized.

Do not add per-bone/per-rib subprogression.

---

# 4. Classification progression

B-17 begins:

> **Classification: Unknown**

Classification should evolve automatically from real discovery state.

Prototype stages:

### Stage 0 — Unknown
Start.

### Stage 1 — Vertebrate remains
Trigger after meaningful Bone discovery.

Suggested:
- overall exposure >= 5 %
OR
- first component reaches Detected.

### Stage 2 — Possible Theropod
Trigger when the body plan provides enough evidence.

Suggested:
- Spine exposure >= 15 %
AND
- Hind Limb exposure >= 10 %

### Stage 3 — Likely small theropod
Trigger once skull morphology becomes sufficiently visible.

Suggested:
- Skull exposure >= 35 %
AND
- Stage 2 already reached.

These exact percentages remain prototype thresholds.

Requirements:
- progression only moves forward;
- reset returns to Unknown;
- no species-level identification in V0.1;
- no player quiz/minigame yet.

Provide a subtle one-time dossier/update feedback when classification changes.

No large modal that interrupts excavation.

---

# 5. Objectives

P5 objectives should remain simple and completable in any order.

Use:

### Objective A — Prepare the skull

This replaces the older purely exposure-only wording.

Prototype completion condition:

- Skull exposure >= 60 %
AND
- Skull cleanliness >= 50 %

Reason:
- requires the player to engage with Bone Film / Brush;
- does not require perfect polishing;
- leaves meaningful optional work for Keep Cleaning.

### Objective B — Reveal 60 % of the skeleton

- overall fossil exposure >= 60 %

### Objective C — Recover both fragments

- recoverable fragments 2 / 2

All thresholds are centralized prototype values.

Do not make 100 % cleaning/exposure mandatory for completion.

The session must intentionally finish before the specimen is perfectly cleaned so **Keep Cleaning** remains meaningful.

---

# 6. Recoverable fragments — manual Forceps

P5 introduces a fifth tool/interaction:

> **Forceps [5]**

This is **not** an excavation tool.

Role:

> manually recover two small independent fossil fragments after they are sufficiently exposed and cleared.

This replaces the old automatic recovery rule.

## Fragment authoring

Add exactly two deterministic recoverable fragments to B-17.

They must:
- be independent from the main four component totals;
- not change Skull/Spine/Ribs/Hind Limb counts;
- not consume per-component Bone protection;
- remain deterministic on reset;
- have Bone-like rendering and ceiling protection;
- be physically/visually distinct enough for recovery.

Prefer a dedicated:
- `RecoverableFragmentField`
- `FragmentState`
- equivalent

rather than overloading the four main anatomical component IDs.

Integrate their ceilings into structural excavation so Clay/Sandstone cannot be excavated through them.

## Fragment readiness

A fragment becomes `READY` when:

- >= 90 % of its own surface is exposed;
- surrounding matrix clearance passes a deterministic local clearance test.

The surrounding-clearance test should be simple and bounded.

Examples:
- annulus/ring around authored fragment has sufficient cells below a clearance height;
- no substantial hard-matrix bridge remains attached around the fragment.

Do not require perfect cleanliness.

## Forceps behavior

Tool slot:

> `[5] Forceps`

When selected:
- does not alter Soil/Clay/Sandstone;
- does not clean Bone Film;
- does not affect Bone Condition.

Hover states:
- not a fragment → no recovery target;
- fragment not ready → subtle `Clear more matrix`;
- fragment ready → subtle highlight / `Ready to recover`.

Interaction target:

### minimal tactile recovery

1. LMB on a READY fragment grabs it;
2. fragment lifts slightly above the block;
3. player drags it toward the fragment tray;
4. release over tray → recovered;
5. release elsewhere → snaps safely back / remains READY.

No rigid-body simulation required.

The interaction should feel deliberate but remain easy.

Main skeleton Bone must never be draggable with Forceps.

## Fragment tray

Functional placeholder tray on the tabletop/UI.

Recovered fragment:
- leaves the excavation block;
- appears in tray slot;
- updates `Fragments 1/2`, then `2/2`.

No production art required.

---

# 7. Functional P5 UI

P5 UI is functional/greybox.

Do not attempt final P6 paper/wood/brass styling.

Required information:

### Objectives panel
- Prepare the skull
- Reveal 60 % of skeleton
- Recover both fragments

Checkbox / progress state.

### Specimen dossier
At minimum:
- Specimen B-17
- current classification
- overall exposure %
- overall Bone cleanliness %
- Bone Condition %
- component states/progress
- fragments 0/2, 1/2, 2/2

Component detail can be compact.

Example:

```text
B-17
Likely small theropod

Exposure      53 %
Cleanliness   61 %
Condition     97 %

Skull         Prepared
Spine         Exposed
Ribs          Detected
Hind Limb     Hidden

Fragments     1 / 2
```

### Toolbar
Keep:
- [1] Soft Brush
- [2] Chisel
- [3] Air Blower
- [4] Precision Pick

Add:
- [5] Forceps

### Fragment tray
Two functional slots.

### Minimal notifications
Examples:
- Bone detected
- Classification updated
- Fragment ready
- Fragment recovered — 1/2
- Objective completed

Avoid notification spam.

---

# 8. Completion gate

When all three objectives are complete:

set:

`preparation_complete = true`

Trigger the completion presentation **once**.

Do not automatically end the session.

Suggested lightweight presentation:
- tool audio ducks slightly;
- subtle lamp/intensity change if easy;
- functional completion card.

Card:

> **Preparation Complete**
>
> Classification: Likely small theropod
> Skeleton exposed: XX %
> Bone cleanliness: XX %
> Fragments recovered: 2/2
> Condition: XX %

Actions:

### Keep Cleaning
Primary behavioral-test action.

- dismiss card;
- restore normal interaction;
- all tools remain available;
- no state reset;
- completion stays achieved.

### Archive Specimen
Diegetic end-session action.

- finalize current stats;
- stop excavation input;
- show archive confirmation.

Do NOT use `Restart Specimen` as the primary completion action.

---

# 9. Keep Cleaning behavior

This is a critical P5 product test.

After `Keep Cleaning`:

- player can expose more Bone;
- clean more Bone Film;
- remove more Matrix;
- improve final archived stats;
- Bone Condition can still worsen if careless;
- Forceps already recovered fragments stay recovered.

Provide a small persistent `Archive Specimen` action after the completion card is dismissed.

The player must not be trapped in endless cleanup.

Archive can be selected at any later time.

---

# 10. Post-completion telemetry/debug

No analytics backend required.

Track session-local values:

- time from completion → archive;
- exposure at completion;
- exposure at archive;
- cleanliness at completion;
- cleanliness at archive;
- Condition at completion;
- Condition at archive;
- additional tool actions after completion.

F1/debug can expose these.

This helps evaluate the North Star:

> Does the player continue cleaning after being told they are done?

No network telemetry.

---

# 11. Archive flow

Selecting `Archive Specimen`:

1. capture final session snapshot;
2. stop tool interaction;
3. show:

> **Specimen Archived**
>
> Museum records updated.

Functional summary:
- classification;
- final exposure;
- final cleanliness;
- fragments;
- final Condition.

Then show:

### Prepare Another Block

For P5 prototype:
- reload/reset the same deterministic B-17 fixture;
- document that this is a placeholder for future specimen/site selection.

Do not build:
- full museum gallery;
- site selection screen;
- persistent museum save;
- economy;
- rewards.

A lightweight in-memory archive record is acceptable if useful for tests.

---

# 12. Museum narrative touch only

P5 should reinforce the museum story, but remain cheap.

Allowed:
- `Museum Preparation Lab` label;
- archive wording;
- museum-record confirmation;
- specimen dossier tone.

Not allowed:
- exterior museum scene;
- navigable museum;
- horizontal gallery implementation;
- visitor simulation;
- prestige economy;
- equipment progression.

Those belong later.

---

# 13. Completion snapshot vs archive snapshot

Important behavior:

The first `Preparation Complete` card shows stats at the moment objectives are completed.

If the player selects `Keep Cleaning`:
- current stats continue evolving.

When they later `Archive Specimen`:
- archive summary uses the **latest** stats.

Thus Keep Cleaning has visible consequences.

---

# 14. Reset semantics

`R` remains a developer reset during P5.

Reset must restore:
- B-17 structural state;
- Bone exposure;
- Bone Film;
- Bone Condition;
- component protections;
- Matrix crumbs;
- classification = Unknown;
- objective states;
- fragment positions/readiness/recovery;
- Forceps state;
- completion/archive state;
- post-completion metrics.

Exact deterministic reset.

---

# 15. Performance architecture

P5 progression/UI must be event-driven.

Do not:
- scan 32k Bone cells every frame;
- recompute component cleanliness every rendered frame;
- rebuild Control trees per tick;
- poll every state from `_process` unnecessarily.

Use:
- signals;
- cached counters;
- UI refresh only when values change.

Target:
- no material degradation from P4;
- 240 FPS cap preserved;
- >=60 FPS strict.

---

# 16. Automated tests

All P0–P4 tests remain green.

Add tests for:

## Classification
- reset = Unknown;
- Stage 1 trigger;
- Stage 2 requirements;
- Stage 3 requirements;
- monotonic progression;
- no duplicate notification spam.

## Component states
- Hidden / Detected / Exposed / Prepared thresholds;
- cleanliness matters only for Prepared;
- Condition does not alter exposure/cleanliness state.

## Objectives
- Skull preparation condition exact;
- overall 60 % condition exact;
- fragments 2/2 condition exact;
- any order;
- completion only when all three true;
- completion fires once.

## Fragment authoring
- exactly two fragments;
- deterministic masks/ceilings;
- main component totals unchanged;
- main fossil IDs unchanged;
- fragments remain reachable;
- Bone ceilings respected.

## Fragment readiness
- <90 % exposure → not ready;
- >=90 % but matrix bridge present → not ready;
- exposure + clearance → ready.

## Forceps
- cannot excavate;
- cannot clean film;
- cannot damage Bone;
- cannot grab main skeleton;
- cannot recover not-ready fragment;
- can grab ready fragment;
- release outside tray returns safely;
- release over tray recovers;
- recovered fragment cannot recover twice;
- reset restores both.

## Completion / Keep Cleaning
- card fires once;
- Keep Cleaning preserves state;
- further exposure/cleaning changes current stats;
- Archive action remains available.

## Archive
- archive snapshot uses latest values;
- input disabled after archive;
- Prepare Another Block resets exact state.

## Telemetry
- completion timestamp/state recorded;
- post-completion deltas correct;
- reset clears metrics.

---

# 17. Graphical / interaction tests

Add targeted graphical tests for:

- objectives panel states;
- dossier classification progression;
- Forceps ready highlight;
- dragging fragment;
- fragment tray 0/2 → 1/2 → 2/2;
- Preparation Complete card;
- Keep Cleaning returning to excavation;
- Archive summary.

Do not attempt visual-polish assertions beyond layout/readability.

---

# 18. Performance tests

Benchmark with P5 UI visible:

- Brush Soil;
- Chisel Clay;
- Chisel Sandstone;
- Precision Pick near Bone;
- Blower with crumbs;
- Forceps drag;
- completion card transition;
- Keep Cleaning;
- dossier updates during exposure.

Measure:
- average FPS;
- 1-second minimum;
- P95 frame;
- max frame;
- P5 progression/UI CPU if practical.

No new sustained regression below 60 FPS.

---

# 19. Human test — full P5 session

Prepare one end-to-end test.

### A — Start

Player sees:
- B-17 dossier;
- Unknown classification;
- three objectives;
- empty 0/2 fragment tray.

Question:
> “Est-ce que je comprends immédiatement ce que je prépare et ce qu’on attend de moi ?”

### B — Discovery progression

Play normally.

Verify:
- Bone detected;
- classification changes naturally;
- dossier does not distract from excavation.

Question:
> “Les nouvelles informations arrivent-elles au bon moment sans casser le flow ?”

### C — Bone preparation

Reveal/clean skull.

Question:
> “Est-ce que ‘Prepare the skull’ correspond naturellement à ce que je fais déjà avec Brush/Pick ?”

### D — Fragment recovery

Find a fragment.

Clear it until READY.

Use Forceps → drag → tray.

Question:
> “Est-ce que récupérer manuellement le fragment est plus satisfaisant qu’une récupération automatique ?”

Target:
YES.

### E — Completion

Reach all objectives.

Preparation Complete appears.

Question:
> “Est-ce que le jeu me dit clairement que le travail demandé est fini ?”

### F — KEEP CLEANING — key test

Select Keep Cleaning.

Continue freely.

Measure:
- extra time;
- exposure delta;
- cleanliness delta.

Question:
> “Est-ce que j’ai envie de continuer alors que le musée considère déjà le travail suffisant ?”

This is the primary behavioral KPI.

### G — Archive

When ready, Archive Specimen.

Question:
> “Est-ce que l’archivage donne une conclusion naturelle à la session ?”

### H — Another block

Prepare Another Block.

For prototype it reloads B-17.

Question:
> “Est-ce que je comprends naturellement que, dans le vrai jeu, un autre travail/spécimen viendrait ensuite ?”

---

# 20. Out of scope

Do NOT implement in P5:

- full museum gallery;
- exterior museum/main menu art;
- real museum collection persistence;
- multiple specimens;
- procedural generation;
- site selection;
- equipment progression;
- expertise/reputation;
- economy/currency;
- geodes/minerals;
- final UI art;
- P6 contact patina;
- Bone dirt color redesign;
- Soil redesign;
- debris redesign;
- new excavation tool besides Forceps;
- final tool tuning.

Known P4 last-20-% issues remain deferred.

---

# 21. Documentation

Create:
- `docs/dev/P5_REPORT.md`

Update:
- `docs/PROTOTYPE_V0_1_SPEC.md` with a P5 addendum for:
  - Forceps manual recovery;
  - Bone cleanliness;
  - Archive flow;
  - fourth/fifth tools now canonical.
- `docs/GAMEPLAY_LOOP.md`
- `docs/brain/status.md`
- `docs/brain/decisions.md`

Document clearly:
- threshold table;
- classification rules;
- objective rules;
- fragment readiness;
- Forceps interaction;
- completion/archive behavior;
- telemetry;
- performance;
- human-test outcome.

---

# 22. Git / stop condition

Stay on:
`prototype/p5-loop-progression`

Use the P5 draft PR.

Commits should be atomic.

Do not merge until human validation.

When:
- complete loop implemented;
- automated tests green;
- performance checked;
- human checklist ready;

**STOP for Antoine’s end-to-end test.**

Do not start P6.

The next decision after P5 human validation is:
- merge P5;
- then open P6A Visual Direction / Production Spike.
