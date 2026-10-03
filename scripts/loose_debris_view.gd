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
	multimesh.mesh = crumb_mesh()
	multimesh.instance_count = 256
	multimesh.visible_instance_count = 0
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.roughness = 1.0
	material_override = material
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

static func crumb_mesh() -> ArrayMesh:
	# An asymmetric thin flake, visually distinct from attached fracture plates.
	var outline := [Vector2(-0.50, -0.15), Vector2(-0.24, -0.45), Vector2(0.24, -0.39),
		Vector2(0.45, 0.07), Vector2(0.19, 0.48), Vector2(-0.34, 0.32)]
	var mesh := SurfaceTool.new()
	mesh.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(outline.size()):
		var a := Vector3(outline[i].x, 0, outline[i].y)
		var b := Vector3(outline[(i + 1) % outline.size()].x, 0, outline[(i + 1) % outline.size()].y)
		for vertex in [Vector3(-0.06, 0.5, 0.03), a, b, Vector3(0, -0.5, 0), b, a]: mesh.add_vertex(vertex)
	mesh.generate_normals()
	return mesh.commit()

func draw_item(slot: int, point: Vector2, amount: float, layer: int, lift := 0.0) -> void:
	var uv := (point + Vector2.ONE * 0.5) / Vector2(block.map_resolution)
	var pos := block.to_global(Vector3((uv.x - 0.5) * block.surface_size.x,
		block.relief.height_at(uv) + 0.00018 + lift, (uv.y - 0.5) * block.surface_size.y))
	var width := state.profile.crumb_width * clampf(sqrt(amount / state.profile.crumb_capacity), 0.08, 1.0)
	var basis := Basis(Vector3.UP, point.x * 1.7 + point.y * 2.3).scaled(Vector3(width, width * 0.14, width * 0.75))
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
