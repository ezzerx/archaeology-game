class_name ForcepsView
extends Node3D
## Two static fragment meshes and a simple tweezer proxy. No physics or rebuilds.
var block: ExcavationBlock
var controller: ToolController
var camera: Camera3D
var proxy: Node3D
var pieces: Array[MeshInstance3D] = []
var drag_height := 0.0
var _dragged := -1

func setup(target: ExcavationBlock, input: ToolController, view: Camera3D) -> void:
	block = target
	controller = input
	camera = view
	proxy = Node3D.new()
	add_child(proxy)
	var metal := StandardMaterial3D.new()
	metal.albedo_color = Color(0.62, 0.68, 0.70)
	metal.roughness = 0.5
	for side in [-1, 1]:
		var arm := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.002, 0.060, 0.002)
		arm.mesh = mesh
		arm.material_override = metal
		arm.position = Vector3(side * 0.004, 0.034, 0)
		arm.rotation.z = side * -0.10
		proxy.add_child(arm)
	var bone := StandardMaterial3D.new()
	bone.albedo_color = Color(0.94, 0.87, 0.72)
	bone.roughness = 0.43
	var field := block.working_map.fragments.field
	for id in range(field.COUNT):
		var piece := MeshInstance3D.new()
		piece.mesh = _fragment_mesh(field, id)
		piece.material_override = bone.duplicate()
		piece.hide()
		add_child(piece)
		pieces.append(piece)
	block.working_map.fragments.changed.connect(_sync)
	_sync()

func _fragment_mesh(field: RecoverableFragmentField, id: int) -> ArrayMesh:
	var outline := field.outline(id)
	var ends: Vector4 = field.ENDS[id]
	var center := Vector2(ends.x + ends.z, ends.y + ends.w) * 0.5
	var builder := SurfaceTool.new()
	builder.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(outline.size()):
		var a := (outline[i] - center) / FossilField.AUTHOR_SIZE * block.surface_size
		var b := (outline[(i + 1) % outline.size()] - center) / FossilField.AUTHOR_SIZE * block.surface_size
		# Top dome, base and rim preserve the authored silhouette at every zoom.
		for vertex in [Vector3(0, 0.003, 0), Vector3(b.x, 0, b.y), Vector3(a.x, 0, a.y),
			Vector3(0, -0.002, 0), Vector3(a.x, -0.002, a.y), Vector3(b.x, -0.002, b.y),
			Vector3(a.x, 0, a.y), Vector3(b.x, 0, b.y), Vector3(b.x, -0.002, b.y),
			Vector3(a.x, 0, a.y), Vector3(b.x, -0.002, b.y), Vector3(a.x, -0.002, a.y)]:
			builder.add_vertex(vertex)
	builder.generate_normals()
	return builder.commit()

func _sync() -> void:
	var state := block.working_map.fragments
	var present := Vector2.ONE
	for id in range(state.field.COUNT):
		if state.recovered[id] or state.grabbed == id: present[id] = 0.0
		pieces[id].visible = state.grabbed == id or state.recovered[id]
		if state.recovered[id]: pieces[id].global_position = controller.fragment_tray.slot_world(id)
	block.material.set_shader_parameter("fragment_visible", present)
	if state.grabbed >= 0 and _dragged != state.grabbed:
		var uv := (state.field.centers[state.grabbed] + Vector2.ONE * 0.5) / Vector2(block.map_resolution)
		# Carry above the block's rim as well as its cavity; never disappear into
		# unexcavated matrix while travelling from a deep find toward the tray.
		drag_height = block.to_global(Vector3(0, maxf(block.thickness + 0.012, block.relief.height_at(uv) + 0.018), 0)).y
		var film := block.working_map.bone_film.value_at(uv)
		(pieces[state.grabbed].material_override as StandardMaterial3D).albedo_color = Color(0.94, 0.87, 0.72).lerp(Color(0.56, 0.48, 0.35), film * 0.5)
	_dragged = state.grabbed

func _process(_delta: float) -> void:
	if controller == null: return
	proxy.visible = controller.selected_index == 4 and (controller.hit.inside or _dragged >= 0) and (controller.session == null or controller.session.can_use_tools())
	if not proxy.visible: return
	var at: Vector3 = controller.hit.get("world", Vector3.ZERO)
	if _dragged >= 0:
		var origin := camera.project_ray_origin(controller._screen)
		var ray := camera.project_ray_normal(controller._screen)
		at = origin + ray * ((drag_height - origin.y) / ray.y)
		pieces[_dragged].global_position = at
	proxy.global_position = at
	proxy.global_basis = ToolProxyPose.fixed_basis(0)
