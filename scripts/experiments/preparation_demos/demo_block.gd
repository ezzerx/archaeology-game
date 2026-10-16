extends "res://scripts/collection/specimen_block.gd"
@export var demo_kind:=0
func _create_working_surface(stratigraphy:Stratigraphy) -> WorkingSurface:
 var value=preload("res://scripts/experiments/preparation_demos/demo_surface.gd").new(map_resolution,stratigraphy,_create_fossil_field(),reactions)
 value.demo_kind=demo_kind
 return value
