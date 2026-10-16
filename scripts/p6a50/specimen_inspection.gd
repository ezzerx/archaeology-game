extends "res://scripts/p6a35/asset_inspection.gd"
func _source_scene() -> PackedScene:
 return load(preload("res://scripts/p6a50/catalog.gd").entry(owner_pilot.specimen_id).model)
func _bone_shader() -> Shader:return preload("res://shaders/p6a36_hero_bone.gdshader")
func setup(pilot:Node3D) -> void:
 super.setup(pilot)
 var row=root_control.get_child(1).get_child(2)
 row.get_child(1).hide();row.get_child(2).hide()
