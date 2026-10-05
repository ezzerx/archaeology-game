# P5 Human Correction Brief — Clarity, Optional Mastery & Physical Fragment Recovery

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
