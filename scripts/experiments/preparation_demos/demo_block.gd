extends "res://scripts/collection/specimen_block.gd"
@export var demo_kind:=0
func _create_working_surface(stratigraphy:Stratigraphy) -> WorkingSurface:
 var value=preload("res://scripts/experiments/preparation_demos/demo_surface.gd").new(map_resolution,stratigraphy,_create_fossil_field(),reactions)
 value.demo_kind=demo_kind
 return value

func _create_fossil_field() -> FossilField:
 if demo_kind==1:return preload("res://scripts/experiments/preparation_demos/marine_field.gd").new(map_resolution,"M08")
 return super._create_fossil_field()
func _contact_source_scene() -> PackedScene:
 if demo_kind==1:return preload("res://assets/experiments/marine_trial/m08_marine.glb")
 return super._contact_source_scene()
