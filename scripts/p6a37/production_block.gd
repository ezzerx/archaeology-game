extends "res://scripts/p6a36/production_block.gd"
func _create_fossil_field() -> FossilField:
	return preload("res://scripts/p6a37/mesh_fossil_field.gd").new(map_resolution)
func _contact_source_scene() -> PackedScene:
	return preload("res://assets/p6a37/b17_skeleton.glb")
