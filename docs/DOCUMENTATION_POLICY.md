# Documentation Policy — ArchaeologyGame

**Purpose:** prevent stale phase state and historical implementation detail from misleading agents.

## One source of current status

`docs/brain/status.md` is the **only authoritative document for current phase, active branch/PR, gate, and next authorized action**.

No other document should duplicate a current "allowed / forbidden" phase status.

If another document disagrees with `status.md`, treat that other statement as stale unless Antoine explicitly says otherwise.

## Read order for agents

1. `docs/brain/status.md` — current state and next action.
2. `docs/ORCHESTRATION_HANDOFF.md` — stable product mental model.
3. Active phase brief/report named by `status.md`.
4. `docs/brain/decisions.md` — durable chronological decisions.
5. Durable product docs: CONCEPT / GAMEPLAY_LOOP / ART_DIRECTION / MUSEUM_SYSTEM / FUTURE_SYSTEMS / ROADMAP.
6. Archived/historical reports only when investigating provenance or regressions.

Newest explicit instruction from Antoine always wins.

## Roles

### status.md
Short and current. No long history. Must contain:
- validated phases;
- active branch / PR;
- current gate;
- next authorized action;
- accepted watchpoints/blockers;
- pointers to active brief/report.

### AGENTS.md
Short routing + durable invariants only.
Do not store tuning trivia, benchmark values, fixture coordinates or phase micro-implementation details.

### README.md
Human onboarding and project overview.
Link to `status.md` for current state; do not duplicate the gate.

### ROADMAP.md
Phase purposes and planned sequence.
May show broad completed/active phases, but `status.md` decides the exact current action.

### ORCHESTRATION_HANDOFF.md
Stable mental model, source precedence, workflow and important product principles.
Point to `status.md` for live state instead of caching it.

### GAMEPLAY_LOOP.md
Game-design loop only. No active PR/phase authorization language.

### decisions.md
Durable decisions and why they were made. Historical entries may remain, but later entries supersede earlier ones.

### dev reports
Evidence for a specific implementation/spike. They do not authorize future work unless the current status/brief says so.

## Historical material

Superseded experiment reports should live under `docs/dev/archive/` when practical.
Keep thin redirect stubs at old paths when moving a frequently linked document so historical links do not break.

## Update rule

When a durable decision changes the project:
1. update `status.md`;
2. update `decisions.md` if the decision is durable;
3. update the active brief/report if its scope changes;
4. update durable product docs only if their subject changed;
5. do **not** copy the new status sentence into README / AGENTS / GAMEPLAY_LOOP.
