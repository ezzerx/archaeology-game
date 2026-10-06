# ArchaeologyGame — Agent Instructions

## Start here

Read in this order:

1. `docs/brain/status.md` — **single source of current phase, active PR, gate and next authorized action**.
2. `docs/ORCHESTRATION_HANDOFF.md` — stable product mental model.
3. The active phase brief/report named by `status.md`.
4. `docs/brain/decisions.md` when decision history matters.
5. `docs/DOCUMENTATION_POLICY.md`.

Do not infer project state from README text, old reports, branch names or historical sections.

If documents conflict:
> newest explicit Antoine instruction > status.md > active brief/report > decisions.md > durable product docs > archive/history.

## Durable product invariants

- Godot 4.7.2 stable remains the canonical engine unless a concrete blocker justifies a change.
- Fixed tabletop / near-top-down presentation; no controllable avatar or open world.
- Excavation feel and material/tool readability take priority over feature volume.
- Exposure, Cleanliness and Condition are distinct concepts.
- P4/P5 gameplay is considered frozen during visual work unless an explicitly authorized spike says otherwise.
- Runtime target:240 FPS cap /60 Hz physics on the reference PC; performance evidence never replaces human validation.
- The museum is the narrative employer and future collection/meta destination.
- Current art target: warm stylized2.5D natural-history preparation lab; gameplay readability wins over screenshot beauty.

## Workflow

- During a phase: implement/test on the active branch.
- Between phases: require explicit human review before merge or next gate.
- Automated tests do not imply human/product validation.
- Do not start a later phase because a report mentions it; only `status.md` / active brief can authorize it.
- Preserve deterministic fixtures and regression tests when changing visuals.

## Documentation

Follow `docs/DOCUMENTATION_POLICY.md`.

Keep this file short.
Do not add:
- tuning trivia;
- benchmark numbers;
- fixture coordinates;
- micro-thresholds;
- historical implementation narratives.

Those belong in active briefs/reports or archive documents.
