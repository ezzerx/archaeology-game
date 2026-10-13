# Marketing M1 — First Public Hook Ready

**Defined:** 2026-10-09. **Status:** candidate milestone, NOT YET PASSED.
**Authority:** `docs/brain/status.md` for active gates.
**Purpose:** prove that the existing enjoyable excavation loop is also instantly
**visually communicable and appealing** to an unfamiliar person.

> A new viewer watches 15–30 seconds of real Godot gameplay (without narrated
> explanation) and understands the fossil-preparation fantasy, sees satisfying
> interaction and wants to discover more.

This is a **marketing-readiness** check, not a claim of Steam demo/release readiness,
viral traction or product–market fit.

## Why M1 now

- P5 complete loop has been human validated.
- P6A2 introduced credible Clay/Soil and warm task lighting.
- P6A3 introduced authored tools/particles, with hotfix restoring preferred tool
  pose and prior audio.
- Friend playtest (n=3) found the loop enjoyable and one player pursued 99%,
  showing a potential optional-mastery motivation.
- Remaining obvious first-impression risks are a 2.5D-looking fossil/reveal,
  unreworked Foley, some Bone readability/frustrating 99% progress behavior and
  the recognizable framed rectangular block in wider shots.

Therefore a public hook clip is much closer than a robust public playable demo;
we should not wait to finish every long-term system before *testing* interest.

## Acceptance gates

These must be met for **the actual chosen footage**, not theoretically in a
different build.

| ID | Gate | Check |
| --- | --- | --- |
| M1-G1 | **Instantly understandable fantasy** | In first ~2–3 sec, a viewer sees a fossil-bearing prep block and knows what kind of action is taking place; no voice-over or dev intro needed |
| M1-G2 | **Satisfying visible tool/material contact** | at least one compelling Brush/Chisel/Pick interaction with clear, truthful motion, material response and readable debris |
| M1-G3 | **Compelling discovery payoff** | a progressive fossil reveal looks convincingly 3D/tactile and rewards the action; a B-17 mesh lookdev is promising but must prove actual masked exposure |
| M1-G4 | **Coherent captured look** | framing/materials/lighting/tool art/UI do not look like a debug demo; no obvious tool clipping, broken mesh, intrusive placeholder or scene seam dominates the selected shot |
| M1-G5 | **Sound in shot** | satisfying, recognizable contact + material sound without misleading metallic rattles, fatigue or terrible repetition; complete sound library/music not mandatory |
| M1-G6 | **Truthful gameplay & reliable capture** | authentic Godot recording, no fake mechanics, stable input/camera/60Hz physics/240FPS cap policy; 1080p high-quality 60fps original feasible; vertical 9:16 crop legible |
| M1-G7 | **No visible mastery/readability contradiction** | dirty Bone visibly dirty where significant film remains; progress presented truthfully; viewers don't encounter a conspicuous 99%-stall if a 100%-cleanup payoff is shown |
| M1-G8 | **Cold-viewer qualitative check** | ideally 5–10 unfamiliar viewers in relevant target audience, with no instructions, can describe what they saw, see appeal or name the blockers; save verbatim comments |
| M1-G9 | **Explicit human approval** | Antoine approves one or more truthful public clips and chooses whether/where to publish; no default automatic publication |

G1–G7 are qualitative product gates, not synthetic pass/fail unit tests.
G8 is limited-sample research, not a statistically representative conversion
forecast. Do not declare market validation from views alone.

## Suggested route to M1

1. **P6A3.1 — Mastery / Bone readability**: achievable 100%, reduced visual
   Chisel cursor only, dirty/clean Bone and Condition feedback, dust cleaning.
2. **B-17 Fossil Mesh Lookdev**: prove actual 3D anatomy integrates with real
   excavation. Human review decides whether the result is a necessary M1 asset.
3. **Minimum clip-ready sound**: a few strong and correctly mixed Foley cues
   for captured interactions. A dedicated sound/music pass can continue beyond M1.
4. **Shot-specific presentation polish**: revisit jacket/contact/outer frame
   only if it distracts from the selected camera shot. Avoid requiring a full
   new excavation footprint prematurely.
5. **Capture candidate hooks**: 2–3 different 15–30s sequences in portrait,
   based on actual gameplay, with the first ~2 sec and clear final reveal.
6. **Cold preview** and iterate, then explicit M1 human gate.

This is a candidate route. No new engineering job is authorized by this file.

## What M1 explicitly does not need

- Multiple fossil species, full procedural blocks/material columns, a completed
  museum or crate/intake flow.
- Full soundtrack and full per-tool-per-material Foley set.
- Adjustable lamp gameplay.
- Complete jacket/geometry rework outside the chosen marketing framing.
- All P6B art or P7 balance.
- Full consumer-ready public demo.

## Beyond M1

**M2 — Steam Wishlist / Public Demo Readiness** is separate: accurate store
assets, a stable and sufficiently representative experience, appropriate QA,
source/licensing and AI-asset documentation, localization/accessibility/controls
as needed, and a workable wishlist entry point before major traffic campaigns.

Self-publishing is the current baseline; the choice of PR agency/publisher can
be reconsidered if audience data or production requirements justify it. Do not
buy publicity or cede publishing rights on the assumption that a short clip
must go viral.

## Communication test examples

- Brush away the loose Soil → reveal the first piece of Bone.
- Chisel removes a satisfying wedge of Clay → a previously hidden detail appears.
- Progress toward a beautifully prepared Bone → satisfying cleanup at full
  quality, only if that quality genuinely exists in-game.

Avoid simulated reveals or off-engine promo composites misrepresented as
playable footage. The campaign's job is to communicate what the game already
does well.
