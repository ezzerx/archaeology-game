class_name MaterialFracture
extends RefCounted
## Sparse stress, deterministic angular partition; no simulation at idle.
## The small RG8 atlas contains stress only (R Clay, G Sandstone).

var profile: ReactionProfile
var image: Image
var dirty := true
var stress: Dictionary = {}
var last_chunks: Array[Dictionary] = []
var last_marks := 0
var last_work := 0.0

func _init(resolution: Vector2i, settings: ReactionProfile) -> void:
	profile = settings
	var stride := minf(profile.patch_size(1), profile.patch_size(2))
	image = Image.create(ceili((resolution.x + resolution.y * 0.25 + 8) / stride) + 3,
		ceili((resolution.y + 8) / stride) + 3, false, Image.FORMAT_RG8)
	reset()

func reset() -> void:
	stress.clear()
	last_chunks.clear()
	last_marks = 0
	last_work = 0.0
	image.fill(Color(0, 0, 0, 1))
	dirty = true

static func triangle(value: float) -> float:
	return absf(fposmod(value, 2.0) - 1.0)

func partition(point: Vector2, layer: int) -> Vector2i:
	# Continuous piecewise-linear warping makes interlocking angular plates,
	# with no unassigned holes. The shader uses exactly this same partition.
	var offset := float(posmod(profile.seed, 97)) / 97.0
	var warped := Vector2(point.x + 0.25 * point.y + 3.0 * triangle(point.y / 7.0 + offset),
		point.y + 2.0 * triangle(point.x / 11.0 + offset))
	return Vector2i((warped / profile.patch_size(layer)).floor()) + Vector2i.ONE

func _record_stress(key: Vector3i, value: float) -> void:
	if value == 0.0:
		stress.erase(key)
	else:
		stress[key] = value
	var color := image.get_pixel(key.x, key.y)
	color[key.z - 1] = clampf(value / profile.threshold(key.z), 0.0, 1.0)
	image.set_pixel(key.x, key.y, color)
	dirty = true

func apply(surface: WorkingSurface, point: Vector2, tool: ToolDefinition) -> int:
	last_chunks.clear()
	last_marks = 0
	last_work = 0.0
	if tool.power <= 0 or tool.effectiveness == Vector3.ZERO:
		return 0
	var low := Vector2i((point - Vector2.ONE * tool.radius).floor()).max(Vector2i.ZERO)
	var high := Vector2i((point + Vector2.ONE * tool.radius).ceil()).min(surface.size - Vector2i.ONE)
	var groups: Dictionary = {}
	var changed := 0
	var newly_exposed := PackedInt32Array()
	for y in range(low.y, high.y + 1):
		for x in range(low.x, high.x + 1):
			var p := Vector2(x, y)
			var ratio := p.distance_to(point) / tool.radius
			if ratio >= 1.0:
				continue
			var index := y * surface.size.x + x
			var old := surface._heights[index]
			var ceiling := surface.fossil.field.ceilings[index] if surface.fossil != null else 0.0
			if old <= ceiling:
				continue
			var limits := Vector2(surface.strata.packed_limits[index * 2], surface.strata.packed_limits[index * 2 + 1])
			var layer := Stratigraphy.index_at(old, limits)
			if tool.effectiveness[layer] <= 0:
				continue
			var work := tool.power * WorkingSurface.weight(ratio, tool.falloff) * tool.effectiveness[layer] / surface.strata.materials[layer].resistance
			var bottom := limits.x if layer == 0 else (limits.y if layer == 1 else 0.0)
			bottom = maxf(bottom, ceiling)
			if layer == 0:
				# Loose soil stays granular; no stress and no cross-layer spill.
				changed += _remove(surface, index, maxf(bottom, old - work), 0, tool, newly_exposed)
				continue
			var tile := partition(p, layer)
			var key := Vector3i(tile.x, tile.y, layer)
			if not groups.has(key):
				groups[key] = {"indices": PackedInt32Array(), "work": 0.0, "point": Vector2.ZERO}
			var group: Dictionary = groups[key]
			group.indices.append(index)
			group.work = maxf(group.work, work)
			group.point += p
	for key: Vector3i in groups:
		var group: Dictionary = groups[key]
		var accumulated: float = stress.get(key, 0.0) + group.work
		last_work += group.work
		if accumulated < profile.threshold(key.z):
			_record_stress(key, accumulated)
			last_marks += 1
			continue
		_record_stress(key, 0.0)
		var chunk_cells := 0
		var volume := 0.0
		for index: int in group.indices:
			var old := surface._heights[index]
			var bottom := surface.strata.packed_limits[index * 2 + 1] if key.z == 1 else 0.0
			if surface.fossil != null:
				bottom = maxf(bottom, surface.fossil.field.ceilings[index])
			var next := maxf(bottom, old - profile.chunk_depth(key.z))
			chunk_cells += _remove(surface, index, next, key.z, tool, newly_exposed)
			volume += old - surface._heights[index]
		if chunk_cells > 0:
			last_chunks.append({"layer": key.z, "point": group.point / group.indices.size(),
				"cells": chunk_cells, "volume": volume})
			changed += chunk_cells
	if changed > 0:
		surface.image.set_data(surface.size.x, surface.size.y, false, Image.FORMAT_RF, surface._heights.to_byte_array())
		surface.dirty = true
	if not newly_exposed.is_empty():
		surface.fossil.expose_cells(newly_exposed)
	return changed

func _remove(surface: WorkingSurface, index: int, next: float, layer: int,
		tool: ToolDefinition, exposed: PackedInt32Array) -> int:
	var old := surface._heights[index]
	if next >= old:
		return 0
	surface._heights[index] = next
	var removed := old - surface._heights[index]
	if removed <= 0:
		return 0
	surface.last_removed[layer] += removed
	@warning_ignore("integer_division")
	surface.residue.deposit_removed(index % surface.size.x, index / surface.size.x, removed * tool.residue_generation)
	if surface.fossil != null and surface.fossil.field.ceilings[index] > 0.0 \
			and surface._heights[index] <= surface.fossil.field.ceilings[index] + FossilField.EXPOSURE_EPSILON \
			and surface.fossil.exposed[index] == 0:
		exposed.append(index)
	return 1
