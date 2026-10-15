extends "res://scripts/p6a41/rough_block.gd"
func _create_working_surface(strata:Stratigraphy) -> WorkingSurface:
 return preload("res://scripts/p6a49/final_surface.gd").new(map_resolution,strata,_create_fossil_field(),reactions)
