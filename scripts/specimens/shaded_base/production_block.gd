extends ExcavationBlock
func _create_fossil_field() -> FossilField:
	return preload("res://scripts/specimens/shaded_base/mesh_fossil_field.gd").new(map_resolution)
