class_name P5Fixture
extends RefCounted
## Test-only setup. Production has no reveal/complete shortcut.

static func commit(surface: WorkingSurface) -> void:
	surface.image.set_data(surface.size.x, surface.size.y, false, Image.FORMAT_RF, surface._heights.to_byte_array())
	surface.dirty = true

static func reveal(surface: WorkingSurface, percentages: Array) -> void:
	var targets: Array[int] = []
	for id in range(1, 5): targets.append(ceili(surface.fossil.field.component_totals[id] * percentages[id - 1] / 100.0))
	reveal_counts(surface, targets)

static func reveal_counts(surface: WorkingSurface, targets: Array[int]) -> void:
	var counts := [0, 0, 0, 0, 0]
	var indices := PackedInt32Array()
	for index in range(surface.fossil.field.component_ids.size()):
		var id := surface.fossil.field.component_ids[index]
		if id == 0: continue
		counts[id] += 1
		if counts[id] > targets[id - 1]: continue
		surface._heights[index] = surface.fossil.field.ceilings[index]
		indices.append(index)
	commit(surface)
	surface.fossil.expose_cells(indices)

static func clean(surface: WorkingSurface) -> void:
	var brush: ToolDefinition = load("res://config/soft_brush.tres")
	for y in range(0, surface.size.y + 1, 20):
		surface.bone_film.clean(Vector2(0, y), Vector2(surface.size.x, y), brush, 2.0)

static func ready_fragment(surface: WorkingSurface, id: int) -> void:
	var field := surface.fragments.field
	for index in field.cells[id]: surface._heights[index] = field.ceilings[index]
	for index in field.collars[id]: surface._heights[index] = field.clearance_heights[id] - 0.005
	commit(surface)
	surface.update_fragments(field.bounds[id])

static func recover(surface: WorkingSurface, id: int) -> void:
	ready_fragment(surface, id)
	surface.fragments.grab(id)
	surface.fragments.release(true)

# Main-skeleton masks only, deliberately independent of the production guard.
static func foot_hidden(surface: WorkingSurface) -> PackedInt32Array:
	var result := PackedInt32Array()
	for i in range(surface.fossil.field.component_ids.size()):
		if surface.fossil.field.component_ids[i] == 4 and i / surface.size.x >= 503: result.append(i)
	return result

static func scattered_hidden(surface: WorkingSurface, count: int) -> PackedInt32Array:
	var result := PackedInt32Array()
	for i in range(surface.fossil.field.component_ids.size()):
		if surface.fossil.field.component_ids[i] == 0: continue
		@warning_ignore("integer_division")
		if i % surface.size.x % 16 < 7 and (i / surface.size.x) % 16 < 7:
			result.append(i)
			if result.size() == count: break
	assert(result.size() == count)
	return result

static func reveal_except(surface: WorkingSurface, hidden: PackedInt32Array) -> void:
	var mask := PackedByteArray()
	mask.resize(surface.fossil.exposed.size())
	for i in hidden: mask[i] = 1
	var indices := PackedInt32Array()
	for i in range(mask.size()):
		if surface.fossil.field.component_ids[i] == 0 or mask[i] != 0: continue
		surface._heights[i] = surface.fossil.field.ceilings[i]
		indices.append(i)
	commit(surface)
	surface.fossil.expose_cells(indices)

static func distributed(surface: WorkingSurface, percent: float) -> void:
	reveal_except(surface, scattered_hidden(surface, maxi(1, floori(surface.fossil.field.total_cells * (100 - percent) / 100.0))))

static func connected_foot(surface: WorkingSurface, count: int) -> PackedInt32Array:
	var remaining := {}
	for i in foot_hidden(surface): remaining[i] = true
	var queue := PackedInt32Array([remaining.keys()[0]])
	remaining.erase(queue[0])
	var head := 0
	while queue.size() < count:
		var i := queue[head]
		head += 1
		for dy in range(-1, 2):
			for dx in range(-1, 2):
				var next := i + dy * surface.size.x + dx
				if remaining.has(next):
					remaining.erase(next)
					queue.append(next)
					if queue.size() == count: return queue
	return queue
