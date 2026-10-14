extends ExcavationBlock
func _create_fossil_field() -> FossilField:
	return preload("res://scripts/p6a35/mesh_fossil_field.gd").new(map_resolution)
