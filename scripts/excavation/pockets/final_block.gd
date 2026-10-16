extends "res://scripts/excavation/block/rough/rough_block.gd"
func _create_working_surface(strata:Stratigraphy) -> WorkingSurface:
 return preload("res://scripts/excavation/pockets/final_surface.gd").new(map_resolution,strata,_create_fossil_field(),reactions)
