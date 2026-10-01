class_name ImpactClock
extends RefCounted
## Immediate first impact, then n / cadence. Half-open intervals [start, end)
## avoid a duplicate at exact boundaries and preserve phase at 60 Hz / 4.5 Hz.

var elapsed := 0.0
var emitted := 0

func reset() -> void:
	elapsed = 0.0
	emitted = 0

func advance(delta: float, cadence: float) -> int:
	if delta <= 0.0 or cadence <= 0.0:
		return 0
	elapsed += delta
	var scheduled := ceili((elapsed - 0.000000001) * cadence)
	var due := maxi(0, scheduled - emitted)
	emitted += due
	return due

func time_to_next(cadence: float) -> float:
	return maxf(0.0, emitted / cadence - elapsed)
