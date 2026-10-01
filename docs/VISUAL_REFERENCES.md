# Visual References — ArchaeologyGame V0.1

**Status: canonical visual reference manifest**  
**Decision date:** 2026-10-01

This document fixes the visual reference set for the gameplay prototype.

The four approved concept images are intentionally treated as **directional references**, not production assets. Their role is to preserve composition, atmosphere, interaction language, material treatment and museum presentation while the underlying game systems are developed.

## Canonical reference board

A 2×2 contact sheet has been generated from the four approved concepts.

**Intended repository path:**

`docs/visual-references/archaeologygame-v0.1-visual-reference-board.jpg`

**SHA-256 of the exact approved board:**

`58d223c25022c1badc59cd822a7df144672646be6dcd645b8a80788c34881fa1`

The exact approved binary is versioned on `prototype/p0-foundation` at the path above. Its SHA-256 was verified on 2026-10-01 against this manifest. It is documentation only, excluded from Godot imports by `docs/.gdignore` and never loaded by the prototype.

## 01 — Excavation main

Role: **primary overall gameplay composition reference**.

Preserve:

- warm tabletop natural-history atmosphere;
- central excavation block as the dominant object;
- orthographic / nearly vertical camera;
- visible material zones and genuine-looking depth;
- lamp, notebook, specimen labels, trays and restrained scientific clutter;
- bottom tool bar;
- objective and specimen panels;
- wood / parchment / brass / bottle-green visual language.

Do not treat any generated text, exact fossil anatomy, icon or UI wording as final production content.

## 02 — Active excavation / Bone detected

Role: **primary game-feel and moment-to-moment interaction reference**.

Preserve:

- visible physical tool above the block rather than a simple mouse cursor;
- fine dust kicked up by brushing;
- cavities and exposed stratified material;
- clear transition from soil / clay / sandstone / hard rock toward bone;
- warm directional lamp light;
- restrained `Bone detected!` feedback;
- sense that the player should instinctively become more careful when bone appears.

This is the most important image for P4 game-feel work.

## 03 — Late-stage excavation / Identification

Role: **progression and scientific-discovery reference**.

Preserve:

- mostly exposed skeleton while some matrix remains;
- specimen dossier evolving from uncertainty toward classification;
- recovered fragments visibly accumulating around the workspace;
- comparison notebook / scientific notes;
- same tabletop composition and visual language as the early excavation;
- fine tool selected near the end of preparation.

This image illustrates the transition from physical excavation to scientific understanding.

## 04 — Museum carousel

Role: **future museum meta-progression reference**.

Preserve:

- museum as a horizontally scrollable interface, not a navigable 3D level;
- selected central exhibit with neighboring exhibits partially visible;
- incomplete skeleton represented physically and with ghosted missing sections;
- prominent **Missing Fossil Parts** list and counters;
- category tabs and collection stats;
- warm natural-history museum atmosphere;
- wood / brass / parchment continuity with the excavation workspace.

The museum is **not part of V0.1 implementation**. This image exists to protect the long-term product direction while the excavation core is validated.

## Priority order

When visual references conflict, use this priority:

1. gameplay readability and tactile excavation feel;
2. Reference 02 — Active excavation;
3. Reference 01 — Excavation main;
4. Reference 03 — Late-stage identification;
5. Reference 04 — Museum carousel.

The detailed implementation target remains [PROTOTYPE_V0_1_SPEC.md](PROTOTYPE_V0_1_SPEC.md). The visual language is defined in [ART_DIRECTION.md](ART_DIRECTION.md).

## Agent rule

An agent working on ArchaeologyGame must **not infer that the screenshots are literal UI specifications**.

They are references for:

- visual hierarchy;
- atmosphere;
- material readability;
- lighting;
- tabletop composition;
- interaction feel;
- museum presentation.

Gameplay rules, scope and architecture are governed by the written canonical specs.
