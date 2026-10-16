extends "res://scripts/specimens/shaded_base/production_mesh_view.gd"
func _source_scene() -> PackedScene:
	return preload("res://assets/p6a36/b17_production_patch.glb")

func _bone_shader() -> Shader:
	return preload("res://shaders/p6a36_hero_bone.gdshader")
