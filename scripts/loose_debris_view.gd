class_name LooseDebrisView
extends MultiMeshInstance3D
## Incremental instancing: update only dirty bins; airborne crumbs occupy tail slots.
var block: ExcavationBlock
var state: LooseDebris
var keys: Array[Vector3i] = []
var slots: Dictionary = {}
var colors := [Color(0.32, 0.24, 0.15), Color(0.49, 0.34, 0.22), Color(0.67, 0.61, 0.47)]

func setup(target: ExcavationBlock) -> void:
	block = target
	state = block.working_map.loose_debris
	multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_colors = true
	var chip := BoxMesh.new()
	chip.size = Vector3.ONE
	multimesh.mesh = chip
	multimesh.instance_count = 256
	multimesh.visible_instance_count = 0
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.roughness = 1.0
	material_override = material
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func draw_item(slot: int, point: Vector2, amount: float, layer: int, lift := 0.0) -> void:
	var uv := (point + Vector2.ONE * 0.5) / Vector2(block.map_resolution)
	var pos := block.to_global(Vector3((uv.x - 0.5) * block.surface_size.x,
		block.relief.height_at(uv) + 0.0005 + lift, (uv.y - 0.5) * block.surface_size.y))
	var width := (0.0022 if layer == 0 else 0.0045) * clampf(sqrt(amount / 0.04), 0.12, 1.5)
	var basis := Basis(Vector3.UP, point.x * 1.7 + point.y * 2.3).scaled(Vector3(width, width * 0.32, width * 0.75))
	multimesh.set_instance_transform(slot, Transform3D(basis, pos))
	multimesh.set_instance_color(slot, colors[layer])

func _process(_delta: float) -> void:
	if state == null: return
	visible = block.debug_view == 0
	# Capacity grows geometrically; unchanged bins retain their GPU transforms.
	var required := keys.size() + state.dirty_cells.size() + state.flying.size()
	if required > multimesh.instance_count:
		multimesh.instance_count = maxi(required, multimesh.instance_count * 2)
		for key in state.cells: state.dirty_cells[key] = true
	for key: Vector3i in state.dirty_cells:
		if state.cells.has(key):
			if not slots.has(key):
				slots[key] = keys.size()
				keys.append(key)
			draw_item(slots[key], state.point_for(key), state.cells[key], key.z)
		elif slots.has(key):
			var slot: int = slots[key]
			var last: Vector3i = keys.back()
			keys[slot] = last
			slots[last] = slot
			keys.pop_back()
			slots.erase(key)
			if slot < keys.size() and state.cells.has(last):
				draw_item(slot, state.point_for(last), state.cells[last], last.z)
	state.dirty_cells.clear()
	for i in range(state.flying.size()):
		var item: Dictionary = state.flying[i]
		draw_item(keys.size() + i, item.point, item.amount, item.layer,
			0.004 + absf(sin(item.travel * 0.09)) * 0.003)
	multimesh.visible_instance_count = keys.size() + state.flying.size()
