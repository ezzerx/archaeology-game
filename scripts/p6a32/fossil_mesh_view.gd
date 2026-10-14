extends Node3D
## Pure presentation consumer of the authoritative native field/height/Film.
var block: ExcavationBlock
var model: Node3D
var material: ShaderMaterial
var enabled := true
var meshes: Array[MeshInstance3D] = []

func setup(target: ExcavationBlock, source: PackedScene) -> void:
	block=target
	model=source.instantiate()
	add_child(model)
	material=ShaderMaterial.new()
	material.shader=preload("res://shaders/p6a32/fossil_mesh.gdshader")
	for mesh:MeshInstance3D in model.find_children("*","MeshInstance3D",true,false):
		var source_material := mesh.get_active_material(0) as StandardMaterial3D
		if source_material != null:
			material.set_shader_parameter("source_albedo",source_material.albedo_texture)
			material.set_shader_parameter("source_normal",source_material.normal_texture)
			material.set_shader_parameter("use_source_albedo",source_material.albedo_texture != null)
			material.set_shader_parameter("use_source_normal",source_material.normal_enabled and source_material.normal_texture != null)
		mesh.material_override=material
		# A fragment exposure mask does not constrain a cached shadow map reliably.
		# Keep shadows off until a revealed-only caster is proven.
		mesh.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		meshes.append(mesh)
	material.set_shader_parameter("working_map",block.texture)
	material.set_shader_parameter("fossil_map",block.fossil_texture)
	material.set_shader_parameter("bone_film_map",block.bone_film_texture)
	material.set_shader_parameter("residue_map",block.residue_texture)
	material.set_shader_parameter("component_filter",FossilField.Component.SKULL)
	material.set_shader_parameter("hero_bone",preload("res://assets/p6a2/textures/bone/p6a2_bone_albedo_v02.png"))
	block.working_map.fossil.bone_condition_changed.connect(_on_condition)
	block.working_map.surface_reset.connect(sync_state)
	sync_state()

func _on_condition(_value: float,_damage: float) -> void: sync_state()
func sync_state() -> void:
	material.set_shader_parameter("b17_condition",block.working_map.fossil.condition)
	material.set_shader_parameter("shown",enabled and block.debug_view==0)
func _process(_delta:float) -> void:
	visible=enabled and block.debug_view==0
	if visible:
		for key in ["cursor_uv","cursor_radius","cursor_visible","cursor_color","mastery_cursor_scale"]:
			material.set_shader_parameter(key,block.material.get_shader_parameter(key))
