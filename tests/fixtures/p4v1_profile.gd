## Frozen P4-V1 profile at 122e9b1cf6dfacad721f9af240ef30592de8491c.
## Only class_name removed. Before/after oracle; never used by the playable scene.
extends RefCounted
## Authored B-17 data in normalized UV. Evaluated only while building static maps.
## No seed, cell noise, runtime geology or per-bone height decisions.

const MIN_SOIL_THICKNESS := 0.10
const MIN_CLAY_THICKNESS := 0.08
const MIN_STONE_THICKNESS := 0.08
const MIN_BONE_CEILING := 0.08
const BONE_SOIL_GAP := 0.06

static func layer_limits(uv: Vector2) -> Vector2:
	# A broad diagonal slope, with a gentle bend across the whole block.
	var slope := 0.65 * uv.x + 0.35 * uv.y + 0.05 * sin(PI * (uv.x - uv.y))
	var soil_depth := 0.16 + 0.27 * smoothstep(0.28, 0.68, slope)
	# Independent upper-central clay lens, hundreds of texels wide, never a thin seam.
	var lens := (uv - Vector2(0.53, 0.30)) / Vector2(0.17, 0.27)
	var clay_depth := 0.11 + 0.26 * exp(-lens.length_squared())
	var soil_bottom := 1.0 - clampf(soil_depth, MIN_SOIL_THICKNESS,
		1.0 - MIN_CLAY_THICKNESS - MIN_STONE_THICKNESS)
	var clay_bottom := soil_bottom - clampf(clay_depth, MIN_CLAY_THICKNESS,
		soil_bottom - MIN_STONE_THICKNESS)
	return Vector2(soil_bottom, clay_bottom)

static func burial_offset(uv: Vector2) -> float:
	# One gently warped burial plane shared by every candidate at this XY.
	# Smooth shoulders prevent the tail/toes from falling towards the floor.
	var tilt := smoothstep(0.28, 0.68, 0.70 * uv.x + 0.30 * uv.y)
	return 0.095 - 0.18 * tilt + 0.008 * sin(TAU * uv.x) * sin(PI * uv.y)

static func buried_ceiling(authored_ceiling: float, uv: Vector2) -> float:
	var upper := layer_limits(uv).x - BONE_SOIL_GAP
	return clampf(authored_ceiling + burial_offset(uv), MIN_BONE_CEILING, upper)
