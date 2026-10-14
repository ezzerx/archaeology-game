extends "res://scripts/p6a35/asset_inspection.gd"
var previous_model: Node3D
var previous_meshes: Array[MeshInstance3D] = []
var using_previous := false
var current_part := 0
var shape_study := false
var reference_button: Button
var shape_button: Button

func _source_scene() -> PackedScene:
	return preload("res://assets/p6a36/b17_production_patch.glb")
func _bone_shader() -> Shader:
	return preload("res://shaders/p6a36_hero_bone.gdshader")

func setup(pilot: Node3D) -> void:
	super.setup(pilot)
	# Raking review light, shared by current and previous source models.
	var lights := viewport.find_children("*","DirectionalLight3D",true,false)
	lights[0].rotation_degrees = Vector3(-40,-35,0)
	lights[0].light_energy = 1.0
	lights[1].light_energy = .28
	var review_environment: WorldEnvironment = viewport.find_children("*","WorldEnvironment",true,false)[0]
	review_environment.environment.ambient_light_energy = .45
	previous_model = _previous_source_scene().instantiate()
	pivot.add_child(previous_model)
	var material: ShaderMaterial = meshes[0].material_override.duplicate()
	for mesh: MeshInstance3D in previous_model.find_children("*","MeshInstance3D",true,false):
		previous_meshes.append(mesh)
		mesh.material_override = material
	previous_model.hide()
	var row: HBoxContainer = root_control.get_child(1).get_child(2)
	reference_button = Button.new()
	reference_button.text = "Modèle : nouveau crâne"
	reference_button.focus_mode = Control.FOCUS_NONE
	reference_button.custom_minimum_size = Vector2(210,44)
	row.add_child(reference_button)
	reference_button.pressed.connect(toggle_reference)
	shape_button = Button.new()
	shape_button.text = "Matière : ivoire"
	shape_button.focus_mode = Control.FOCUS_NONE
	shape_button.custom_minimum_size = Vector2(170,44)
	row.add_child(shape_button)
	shape_button.pressed.connect(toggle_shape_study)

func select_part(which: int) -> void:
	current_part = which
	if previous_model == null or not using_previous:
		super.select_part(which)
	else:
		var current_model: Node3D = model
		var current_meshes: Array[MeshInstance3D] = meshes
		model = previous_model
		meshes = previous_meshes
		super.select_part(which)
		model = current_model
		meshes = current_meshes

func toggle_reference() -> void:
	var rotation_before := pivot.rotation
	var size_before := camera.size
	using_previous = not using_previous
	model.visible = not using_previous
	previous_model.visible = using_previous
	select_part(current_part)
	# Center each asset for the selected view while preserving review scale/angle.
	pivot.rotation = rotation_before
	camera.size = size_before
	reference_button.text = "Modèle : pilote précédent" if using_previous else "Modèle : nouveau crâne"

func toggle_shape_study() -> void:
	shape_study = not shape_study
	for mesh in meshes+previous_meshes:
		mesh.material_override.set_shader_parameter("shape_study",shape_study)
	shape_button.text = "Matière : étude de forme" if shape_study else "Matière : ivoire"

func _previous_source_scene() -> PackedScene:
	return preload("res://assets/p6a35/b17_production_patch.glb")
