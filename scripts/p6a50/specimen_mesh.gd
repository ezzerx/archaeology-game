extends "res://scripts/p6a37/production_mesh_view.gd"
var specimen_id:String
func _init(id:="B17") -> void:specimen_id=id
func _source_scene() -> PackedScene:
 return load(preload("res://scripts/p6a50/catalog.gd").entry(specimen_id).model)
