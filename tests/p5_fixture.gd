class_name P5Fixture
extends RefCounted
## Test-only setup. Production has no reveal/complete shortcut.

static func commit(surface: WorkingSurface) -> void:
	surface.image.set_data(surface.size.x, surface.size.y, false, Image.FORMAT_RF, surface._heights.to_byte_array())
	surface.dirty = true

static func reveal(surface: WorkingSurface, percentages: Array) -> void:
	var counts := [0, 0, 0, 0, 0]
	var indices := PackedInt32Array()
	for index in range(surface.fossil.field.component_ids.size()):
		var id := surface.fossil.field.component_ids[index]
		if id == 0: continue
		counts[id] += 1
		if counts[id] > ceili(surface.fossil.field.component_totals[id] * percentages[id - 1] / 100.0): continue
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
