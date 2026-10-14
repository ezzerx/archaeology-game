extends Node3D
var block: ExcavationBlock
var model: Node3D
var material: ShaderMaterial
var meshes: Array[MeshInstance3D] = []
var enabled := true
var coverage: ImageTexture
var source_piece_count := 0

func setup(target: ExcavationBlock) -> void:
	block = target
	var source: Node3D = _source_scene().instantiate()
	add_child(source)
	var batch := SurfaceTool.new()
	batch.begin(Mesh.PRIMITIVE_TRIANGLES)
	# One surface for the common material; the source GLB keeps seven editable
	# pieces and the inspection view still uses those exact individual pieces.
	for mesh: MeshInstance3D in source.find_children("*","MeshInstance3D",true,false):
		var transform: Transform3D = global_transform.affine_inverse()*mesh.global_transform
		for surface in range(mesh.mesh.get_surface_count()): batch.append_from(mesh.mesh,surface,transform)
		source_piece_count += 1
	source.free()
	model = Node3D.new()
	add_child(model)
	var instance := MeshInstance3D.new()
	instance.name = "ProductionBoneBatch"
	instance.mesh = batch.commit()
	model.add_child(instance)
	material = ShaderMaterial.new()
	material.shader = _bone_shader()
	var field: FossilField = block.working_map.fossil.field
	var bytes: PackedByteArray = field.replacement.duplicate()
	for i in range(bytes.size()): bytes[i] *= 255
	coverage = ImageTexture.create_from_image(Image.create_from_data(field.size.x,field.size.y,false,Image.FORMAT_L8,bytes))
	for mesh: MeshInstance3D in model.find_children("*","MeshInstance3D",true,false):
		mesh.material_override = material
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		meshes.append(mesh)
	material.set_shader_parameter("working_map",block.texture)
	material.set_shader_parameter("fossil_map",block.fossil_texture)
	material.set_shader_parameter("bone_film_map",block.bone_film_texture)
	material.set_shader_parameter("residue_map",block.residue_texture)
	material.set_shader_parameter("production_coverage",coverage)
	material.set_shader_parameter("hero_bone",preload("res://assets/p6a2/textures/bone/p6a2_bone_albedo_v02.png"))

func sync_state() -> void:
	material.set_shader_parameter("shown",enabled and block.debug_view == 0)

func _process(_delta: float) -> void:
	visible = enabled and block.debug_view == 0
	sync_state()
	if visible:
		for key in ["cursor_uv","cursor_radius","cursor_visible","cursor_color","mastery_cursor_scale"]:
			material.set_shader_parameter(key,block.material.get_shader_parameter(key))

func _source_scene() -> PackedScene:
	return preload("res://assets/p6a34/b17_production_patch.glb")

func _bone_shader() -> Shader:
	return preload("res://shaders/p6a34_production_bone.gdshader")
