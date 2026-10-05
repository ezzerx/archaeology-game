# P5 Human Correction Brief — Clarity, Optional Mastery & Physical Fragment Recovery

> **Current target: Human test4 /85→95 + coverage guard + qualitative Condition at the end of this document.** It supersedes prior P5 sections. Current delivery: [P5_COVERAGE_CARE_REPORT](P5_COVERAGE_CARE_REPORT.md).

**Status:** authorized corrective pass after first human end-to-end test  
**Date:** 2026-10-05  
**Branch:** `prototype/p5-loop-progression`  
**PR:** #8 remains DRAFT  
**Scope:** fix P5 comprehension and recovery UX only. Do not start P6 and do not retune the P4 excavation baseline.

## Human-test verdict

P5 is **not human-validated yet**.

The first complete session proved that the systems are technically functional, but the session currently communicates its goals poorly enough that the key P5 behavioral test ("do I voluntarily keep cleaning after completion?") is contaminated by UI ambiguity.

Observed human feedback:

- objectives and dossier compete for authority: it is unclear whether the actual mission is the left-side request or reaching 100% on the right-side dossier;
- the UI overlays too much of the working surface;
- completed objective sub-progress remains visually white and looks unfinished;
- component `Prepared` state is too weak as a reward for high-quality cleaning;
- a visually complete specimen can still show 98–99%, creating a desire to continue without any clear payoff;
- the two recoverable fragments feel arbitrary, are hard to discover naturally, and their current UI tray makes the recovery interaction feel detached from the tabletop;
- the first Keep Cleaning behavior therefore cannot be counted as a clean product signal.

## Product correction goals

1. Make **required work vs optional refinement** unmistakable.
2. Reward high-quality preparation without making 100% mandatory.
3. Move functional UI out of the central excavation canvas where possible.
4. Make fragment recovery a physical tabletop interaction and ensure fragments are encountered naturally.
5. Retest Keep Cleaning only after these clarity fixes.

## 1. UI hierarchy / layout

Keep P5 greybox styling; do **not** perform P6 art.

Use the existing non-play grey margins / desk-side space before overlaying the fossil:

- move the specimen dossier to the right-side non-play / grey area where practical;
- keep the request panel compact on the left-side non-play / grey area;
- preserve the excavation surface as visually unobstructed as possible;
- toolbar can remain along the bottom for P5.

The P6 paper/notebook treatment is deferred, but the P5 layout should already prove the spatial hierarchy.

## 2. Required mission vs optional preparation

Rename / frame the left panel as the **museum request / required work**.

It is the sole authority for "may I finish/archive this job?".

When all three required objectives are complete, show persistent, unambiguous state:

> **Museum request complete ✓**  
> Specimen may be archived. Further preparation is optional.

The right dossier is **specimen / preparation quality information**, not another mission checklist.

Do not imply that 100% Exposure or 100% Cleanliness is required to archive.

## 3. Objective completion readability

Current issue: an objective can be checked while its child lines remain white and look unfinished.

For a completed objective:

- its child progress should also clearly read as satisfied (green/check styling or collapsed completed summary);
- do not leave raw white threshold lines that visually contradict the green objective check;
- retain exact values only if they help rather than compete with status.

Example after completion:

> ✓ Prepare the skull  
> 99% exposed · 98% clean

Both the check and the values should visually read as complete.

## 4. Optional high-quality component reward

Keep the existing `Prepared` threshold as the baseline functional state. Add a clearly optional **high-quality preparation milestone** for each anatomical component.

Prototype threshold:

- component Exposure >= 95%
- component Cleanliness >= 95%

This milestone must **not** affect required objectives or archive availability.

When first reached:

- show one brief, subtle local/UI sparkle / shine cue;
- show a one-time compact notification;
- add a persistent **star / quality mark** beside that component in the dossier.

Do not call this "perfect" if exact 100% is not required.

Working wording can be:
- `★ Fine preparation`
- `★ Fully prepared`
- equivalent concise museum-appropriate term.

Preserve Exposure / Cleanliness / Condition as separate concepts. This star is about preparation completeness only; it must not rewrite Condition.

Optional stretch: when all four main components earn the quality mark, show one non-blocking whole-specimen quality acknowledgement. Do not gate archive or progression on it.

## 5. 98–99% / visual-completion problem

Do not make exact 100% a required or primary mastery target if remaining cells are not visually actionable.

For P5 correction:

- use the >=95 / >=95 optional quality milestone as the meaningful player-facing success;
- keep exact percentages for debugging / dossier detail;
- investigate whether remaining 1–2% comes from visually inaccessible / insignificant cells, but do not perform a large geometry rewrite in this pass.

P6 will improve Bone Film / matrix readability; a future excavation-polish phase can address any true unreachable-cell issue.

## 6. Fragment discovery

The two P5 fragments remain a **Forceps mechanic test**, not final collection design.

They must no longer feel like arbitrary hidden collectibles in unrelated satellite areas.

Correction:

- author/reposition them so normal preparation of B-17 is likely to expose them naturally while pursuing the main specimen;
- do not reveal them through intact matrix;
- on first meaningful visible exposure, emit a subtle one-time `Loose fragment detected` cue / highlight so the player understands this is a recoverable object;
- preserve READY rules (exposure + local clearance);
- preserve exactly two independent fragments and do not alter main anatomical totals.

The player should discover them through excavation, not by reading coordinates in a brief.

## 7. Physical tabletop fragment tray

Replace the lower-left UI-only drop target with a simple **physical / world-space greybox tray** placed beside the working block on the desk.

P5 does not need final tray art.

Requirements:

- clearly visible and reachable in the normal camera framing;
- does not cover the fossil;
- Forceps drag remains direct;
- release over physical tray = recovered;
- release elsewhere = safe return;
- recovered fragments appear physically in the tray;
- UI may still show `Fragments 0/2 → 2/2`, but the physical tray is the interaction target.

This is necessary to validate whether fragment recovery belongs to the tactile tabletop fantasy.

## 8. Completion / Keep Cleaning retest

Do not count the first human session as a successful Keep Cleaning KPI because the player was unsure whether 100% was required.

After this correction:

1. play from reset without developer coordinates;
2. verify all three mission objectives are understood;
3. verify fragments are naturally discovered and recovered into the physical tray;
4. reach `Museum request complete`;
5. observe whether the player wants to continue for optional quality stars / visual satisfaction;
6. if Keep Cleaning is chosen, record whether the motivation is pleasure / optional mastery rather than mission confusion;
7. archive and verify conclusion is clear.

## Out of scope

Do not add:

- final P6 notebook/paper art;
- museum gallery;
- crate intake/opening;
- full specimen extraction model;
- Soil redesign;
- new fossil content;
- equipment progression;
- new P4 tuning;
- exact-100% requirement;
- new currency/rewards.

## Archive closure — explicit product direction, 2026-10-05

The corrective pass also replaces the administrative archive report with a short, positive museum-job closure: a centered greybox confirmation, specimen identity, required work fulfilled, optional preparation quality, fragments and Condition, followed by one Prepare Another Block CTA. A subtle confirmation sound / brief stamp-like entrance is permitted. No dense statistics or final-art treatment; detailed completion/archive metrics remain in F1. User wording: “short, clean, emotionally positive closure.”

Implementation and corrected retest: [P5_CORRECTION_REPORT](P5_CORRECTION_REPORT.md).

## Gate

P5 remains DRAFT / unmerged until Antoine retests this corrected flow.

Success means:

- required work is immediately distinguishable from optional mastery;
- UI no longer materially obscures the fossil;
- fragment recovery is understandable and tactile;
- high-quality preparation has a satisfying lightweight payoff;
- Keep Cleaning behavior can finally be interpreted cleanly.


## Human test 2 — simplify P5 to the core session — 2026-10-05

The second human review shows that the previous correction still over-specifies the session. P5 is now simplified aggressively.

### New P5 product target

P5 must prove only this:

> **Can a player understand, complete and end one fossil-preparation session without explanation?**

The player-facing goal becomes one compact task:

> **Prepare the specimen**
> - Reveal at least 90% of the skeleton
> - Clean at least 90% of the revealed Bone

No other requirement gates completion.

### Remove from P5 player flow

- Remove the two recoverable fragments from the P5 goal.
- Remove Forceps [5] from the normal P5 tool flow.
- Remove the fragment tray / fragment counter from the P5 UI.
- Remove component-by-component stars / fine-preparation goals from the normal UI.
- Remove the detailed component state list from the normal UI.
- Do not present Condition as another goal; keep it in debug / final summary if useful.
- Classification may still progress internally and/or appear as a lightweight one-line discovery update, but must not compete with the preparation goal.

The fragment/Forceps work is retained only as historical experiment code/documentation unless removal is technically cheaper/cleaner. It is **not part of the P5 validation gate** and should not appear to the player in the corrected P5 test.

### Minimal UI target

Persistent player-facing information should be approximately:

> **PREPARE SPECIMEN B-17**
> Reveal skeleton   56 / 90%
> Clean fossil       3 / 90%

Plus the four established excavation tools.

When both thresholds are met:

> **✓ Specimen prepared**
> Ready to archive.
> Further cleaning is optional.

Offer:
- Archive Specimen
- Keep Cleaning

Exact 100% is never required.

### P5 completion gate

P5 is human-valid when a fresh player can, without reading a brief or using debug information:

1. immediately understand that the job is to reveal and clean the fossil;
2. reach the 90/90 preparation threshold through the normal P4 tool grammar;
3. understand clearly that the required work is finished;
4. freely choose Archive or Keep Cleaning without wondering whether hidden requirements remain;
5. archive and reach a clear end-of-session state;
6. start/reset another block successfully.

P5 does **not** need final UI art, museum meta, extraction/mounting logic, fragments, collection progression, crates, or full classification UX.

P6 owns visual identity / beautiful UI. For P5, **ugly is acceptable; confusing is not**.

The final question of whether finished fossils are displayed in matrix, fully extracted, mounted as skeleton components, or handled by a hybrid system is deferred to the Macro Game Design workshop.


## Human test 3 — compact HUD + 85/95 mastery ladder — 2026-10-05

P5 keeps the aggressive UI simplification, but restores one lightweight optional mastery hook without reintroducing component-level complexity.

### Thresholds

Required museum preparation:
- global skeleton Exposure >=85%
- global Bone Cleanliness >=85%

Optional mastery:
- global skeleton Exposure >=95%
- global Bone Cleanliness >=95%

At 85/85:
> **✓ Specimen prepared — Ready to archive**

At 95/95:
> **★ Fine Preparation**

Exact 100% remains purely personal completion and never gates anything.

### HUD placement

Use **one compact always-on progress card** anchored to the upper-left / left non-play margin when available. Do not keep a permanent right-side dossier.

The card should contain only:
- specimen name;
- Reveal skeleton progress;
- Clean fossil progress;
- current state: Preparing / Ready to archive / Fine Preparation ★.

Keep the four-tool toolbar along the bottom.

Detailed classification, component states and Condition remain hidden from the primary HUD; classification can appear as a short transient discovery notification, and Condition can remain debug/final-summary information.

At narrower resolutions where no non-play margin exists, preserve the same top-left anchor with a compact translucent overlay rather than introducing a second panel.

### Visual language for mastery

Do not show component stars. There is exactly **one global Fine Preparation star**.

When 95/95 is first reached:
- brief subtle sparkle/glint;
- short quiet positive sound;
- persistent small gold star beside the compact preparation state.

The mastery cue should be desirable but clearly optional.

### Gate

A successful P5 retest should show that:
- 85/85 communicates "job done";
- the player understands immediately that archiving is allowed;
- the 95/95 star creates optional motivation without looking like another mandatory objective;
- the work surface remains visually dominant.


## Human test 4 — final P5 target: 85/95 + coverage guard + Condition tiers — 2026-10-05

Antoine validates this as the next P5 version to implement and retest.

### Required preparation
Archive-ready requires all of:
- global Skeleton Exposure >=85%
- global Bone Cleanliness >=85%
- **coverage guard passes**: no major contiguous anatomical region remains substantially buried

The coverage guard is not a third visible progress bar. It exists to prevent cases where global 85–95% is reached while an obvious major limb/section is still missing visually.

If the global thresholds are met but the guard fails, show only a contextual line such as:
> **A major section is still covered.**

Do not show a permanent component checklist and do not reveal hidden Bone through intact matrix.

### Optional mastery
- global Exposure >=95%
- global Cleanliness >=95%
- reward: one global **★ Fine Preparation**

Fine Preparation never gates archive.
Exact 100% is personal completion only.

### Condition
Condition remains independent from Exposure/Cleanliness and does not gate archive in P5.

Player-facing Condition is qualitative:
- 95–100%: **Excellent**
- 85–94%: **Good**
- 70–84%: **Fair**
- <70%: **Damaged**

Primary HUD shows only the qualitative label (exact percentage may remain debug/final-summary data). On a tier drop, show one subtle contextual feedback so the player understands careless work has consequences.

Fine Preparation and Condition are intentionally independent:
- ★ Fine Preparation + Excellent is possible
- ★ Fine Preparation + Good is also possible

This avoids turning one early mistake into a permanently failed preparation run.

### Minimal HUD
Persistent card:
- Specimen B-17
- Museum standard: 85%
- Reveal skeleton: X%
- Clean fossil: Y%
- Condition: Excellent / Good / Fair / Damaged

Before completion, do not advertise the 95% mastery target heavily.

At archive-ready:
> **✓ Ready to archive**
> Further preparation is optional.
> ★ Fine Preparation — reach 95%

At 95/95:
> **★ Fine Preparation**

No right-side dossier, no component list, no fragments/Forceps/tray in the P5 player flow.

### P5 gate
P5 is valid when the player can:
1. understand the job immediately;
2. reveal/clean the specimen to the museum standard;
3. not be allowed to archive while a major visual section is still buried;
4. understand that 85% means "done enough";
5. optionally pursue 95% Fine Preparation;
6. understand that Condition represents care, not another fill-to-100 objective;
7. archive and reach a clear end state without explanation.
