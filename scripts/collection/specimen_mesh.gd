extends "res://scripts/specimens/skeleton/production_mesh_view.gd"
var specimen_id:String
func _init(id:="B17") -> void:specimen_id=id
func _source_scene() -> PackedScene:
 return load(preload("res://scripts/collection/catalog.gd").entry(specimen_id).model)
