"""Reconcile the recorded full GPU run and the focused input-isolation replay.

Never edits a measured value. Keep both source runs and the superseded failure.
Run after: -- benchmark, then -- benchmark brush_soil.
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
source = ROOT / 'work/test-logs/p6a'
target = ROOT / 'docs/dev/evidence/p6a'
target.mkdir(parents=True, exist_ok=True)
full = json.loads((source / 'benchmark.json').read_text(encoding='utf-8-sig'))
replay = json.loads((source / 'benchmark-brush_soil.json').read_text(encoding='utf-8-sig'))
assert not replay['failures'], replay['failures']
assert full['hardware'] == replay['hardware']
assert len(full['benchmark']) == 56 and len(replay['benchmark']) == 8
rows = []
for row in full['benchmark']:
    key = row['kind'], row['zoom'], row['candidate']
    replacement = next((r for r in replay['benchmark']
                        if (r['kind'], r['zoom'], r['candidate']) == key), None)
    rows.append({**(replacement or row), 'source_run':
                 'benchmark-brush_soil.json' if replacement else 'benchmark-full.json'})
assert len({(r['kind'], r['zoom'], r['candidate']) for r in rows}) == 56
checks = 0
for row in rows:
    baseline = next(b for b in rows if b['candidate'] == 0 and
                    (b['kind'], b['zoom']) == (row['kind'], row['zoom']))
    assert row['frame_ms']['p95'] < 1000 / 60, row
    assert row['initial_state'] == baseline['initial_state'], row
    assert row['final_state'] == baseline['final_state'], row
    assert (row['camera_transform'], row['camera_size']) == (
        baseline['camera_transform'], baseline['camera_size']), row
    checks += 4
for name, data in [('benchmark-full.json', full), ('benchmark-brush_soil.json', replay)]:
    (target / name).write_text(json.dumps(data, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
result = {'hardware': full['hardware'], 'benchmark': rows, 'checks': checks, 'failures': [],
          'source_runs': [{'file': 'benchmark-full.json', 'failures': full['failures'],
                           'superseded_workload': 'brush_soil'},
                          {'file': 'benchmark-brush_soil.json', 'failures': replay['failures']}],
          'note': 'Brush Soil replay isolates the scripted gesture from native focus cancellation. '
                  'Other workloads retained verbatim. All 56 final map/progress states and camera poses match P5.'}
(target / 'benchmark.json').write_text(json.dumps(result, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
print(f'P6A reconciled evidence: {checks} checks, 0 failures, 56 scenarios; source runs preserved.')
