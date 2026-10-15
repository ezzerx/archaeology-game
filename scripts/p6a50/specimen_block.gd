extends "res://scripts/p6a49/final_block.gd"
@export var specimen_id:="B17"
func _create_fossil_field() -> FossilField:
 return preload("res://scripts/p6a50/specimen_field.gd").new(map_resolution,specimen_id)
func _contact_source_scene() -> PackedScene:
 return load(preload("res://scripts/p6a50/catalog.gd").entry(specimen_id).model)
func _create_footprint() -> RefCounted:
 if specimen_id=="B17":return super._create_footprint()
 var shape=preload("res://scripts/p6a40/footprint.gd")
 var points:Array=[]
 for point:Vector2 in shape.POINTS:points.append((point-Vector2(.5,.5))*Vector2(.53,.78)+Vector2(.52,.52))
 return shape.new(map_resolution,points)
