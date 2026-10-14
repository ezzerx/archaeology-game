extends "res://scripts/p6a34/asset_inspection.gd"
func _source_scene() -> PackedScene:
	return preload("res://assets/p6a35/b17_production_patch.glb")
func _bone_shader() -> Shader:
	return preload("res://shaders/p6a35_aesthetic_bone.gdshader")

func setup(pilot: Node3D) -> void:
	super.setup(pilot)
	# Every inspected piece is intentionally out of matrix, so its full source
	# geometry can cast self-shadows in this isolated World3D.
	var key: DirectionalLight3D = viewport.find_children("*","DirectionalLight3D",true,false)[0]
	key.shadow_enabled = true
	key.directional_shadow_max_distance = 1.0
	key.shadow_bias = .02
	key.shadow_normal_bias = .2
