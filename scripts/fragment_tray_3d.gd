class_name FragmentTray3D
extends Node3D
## A fixed tray on the desk. Drops hit its inner floor, never a UI rectangle.
const INNER := Vector2(0.142, 0.152)
const FLOOR_Y := 0.025
var camera: Camera3D
var state: FragmentState
var count_label: Label3D
var hint_label: Label3D
var rim_material: StandardMaterial3D

func box(dimensions: Vector3, at: Vector3, material: Material) -> void:
	var mesh := MeshInstance3D.new()
	var shape := BoxMesh.new()
	shape.size = dimensions
	mesh.mesh = shape
	mesh.material_override = material
	mesh.position = at
	add_child(mesh)

func label(text: String, at: Vector3, font_size: int) -> Label3D:
	var result := Label3D.new()
	result.text = text
	result.font_size = font_size
	result.pixel_size = 0.00036
	result.outline_size = 3
	result.rotation_degrees.x = -90
	result.position = at
	add_child(result)
	return result

func setup(fragments: FragmentState, view: Camera3D) -> void:
	camera = view
	state = fragments
	position = Vector3(-0.651, 0, 0.19)
	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color(0.24, 0.29, 0.29)
	floor_material.roughness = 0.95
	rim_material = StandardMaterial3D.new()
	rim_material.albedo_color = Color(0.62, 0.66, 0.64)
	rim_material.roughness = 0.8
	box(Vector3(0.166, 0.019, 0.176), Vector3(0, FLOOR_Y - 0.0095, 0), floor_material)
	for sign_value in [-1, 1]:
		box(Vector3(0.012, 0.025, 0.176), Vector3(sign_value * 0.077, FLOOR_Y + 0.006, 0), rim_material)
		box(Vector3(0.166, 0.025, 0.012), Vector3(0, FLOOR_Y + 0.006, sign_value * 0.082), rim_material)
	box(Vector3(0.004, 0.006, INNER.y), Vector3(0, FLOOR_Y + 0.003, 0), rim_material)
	count_label = label("FRAGMENTS 0 / 2", Vector3(0, 0.015, -0.112), 30)
	hint_label = label("[5] FORCEPS", Vector3(0, 0.015, 0.114), 27)
	state.changed.connect(refresh)
	refresh()

func slot_world(id: int) -> Vector3:
	return to_global(Vector3(-0.036 if id == 0 else 0.036, FLOOR_Y + 0.004, 0))

func accepts_drop(screen: Vector2) -> bool:
	if not visible or camera == null: return false
	var ray := camera.project_ray_normal(screen)
	if absf(ray.y) < 0.00001: return false
	var origin := camera.project_ray_origin(screen)
	var t := (global_position.y + FLOOR_Y - origin.y) / ray.y
	if t < 0: return false
	var point := to_local(origin + ray * t)
	return absf(point.x) < INNER.x * 0.5 and absf(point.z) < INNER.y * 0.5

func get_global_rect() -> Rect2:
	var rect := Rect2(camera.unproject_position(to_global(Vector3(-0.083, FLOOR_Y, -0.088))), Vector2.ZERO)
	for x in [-0.083, 0.083]:
		for z in [-0.088, 0.088]: rect = rect.expand(camera.unproject_position(to_global(Vector3(x, FLOOR_Y, z))))
	return rect

func in_view() -> bool:
	return Rect2(Vector2.ZERO, camera.get_viewport().get_visible_rect().size).encloses(get_global_rect())

func refresh() -> void:
	count_label.text = "FRAGMENTS %d / 2" % state.recovered_count()
	hint_label.text = "RELEASE IN TRAY" if state.grabbed >= 0 else "[5] FORCEPS"
	rim_material.albedo_color = Color(0.62, 0.86, 0.71) if state.grabbed >= 0 else Color(0.62, 0.66, 0.64)
