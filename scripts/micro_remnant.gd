class_name MicroRemnant
extends RefCounted
## Bounded 5x5 / 8-connected component inspection, never a global flood fill.
## Any covered/deeper neighbour or fifth supported cell rejects the whole island.

static func bottom(surface: WorkingSurface, index: int, layer: int) -> float:
	var floor_height := surface.strata.packed_limits[index * 2 + 1] if layer == 1 else 0.0
	if surface.fossil != null: floor_height = maxf(floor_height, surface.structural_ceilings[index])
	return floor_height

static func inspect(surface: WorkingSurface, start: Vector2i, layer: int, seen: Dictionary) -> PackedInt32Array:
	var profile := surface.loose_debris.profile
	var maximum := profile.micro_depth_m / surface.excavatable_depth + Stratigraphy.SURFACE_EPSILON
	var pending: Array[Vector2i] = [start]
	var members := PackedInt32Array()
	var visited := {start: true}
	while not pending.is_empty():
		var p: Vector2i = pending.pop_back()
		var index := p.y * surface.size.x + p.x
		seen[index] = true
		var remaining := surface._heights[index] - bottom(surface, index, layer)
		if remaining > maximum or absi(p.x - start.x) > 2 or absi(p.y - start.y) > 2:
			return PackedInt32Array()
		members.append(index)
		if members.size() > profile.micro_max_cells: return PackedInt32Array()
		for dy in range(-1, 2):
			for dx in range(-1, 2):
				if dx == 0 and dy == 0: continue
				var other := p + Vector2i(dx, dy)
				# Map edges are unknown support, not an automatic detach boundary.
				if other.x < 0 or other.y < 0 or other.x >= surface.size.x or other.y >= surface.size.y:
					return PackedInt32Array()
				if visited.has(other): continue
				visited[other] = true
				var neighbour := other.y * surface.size.x + other.x
				if surface._heights[neighbour] > bottom(surface, neighbour, layer) + Stratigraphy.SURFACE_EPSILON:
					pending.append(other)
	return members
