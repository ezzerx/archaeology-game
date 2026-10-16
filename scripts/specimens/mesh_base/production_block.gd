extends ExcavationBlock
func _create_fossil_field() -> FossilField:
	return preload("res://scripts/specimens/mesh_base/mesh_fossil_field.gd").new(map_resolution)
