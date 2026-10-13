extends SceneTree
func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("res://work/p6a32")
	var field := FossilField.new()
	var output := FileAccess.open("res://work/p6a32/b17-ceilings.bin",FileAccess.WRITE)
	output.store_buffer(field.ceilings.to_byte_array())
	FileAccess.open("res://work/p6a32/b17-components.bin",FileAccess.WRITE).store_buffer(field.component_ids)
	FileAccess.open("res://work/p6a32/b17-field.json",FileAccess.WRITE).store_string(JSON.stringify({"size":[field.size.x,field.size.y],"total":field.total_cells,"components":Array(field.component_totals),"surface_size":[1.1,.7],"base_height":.018,"height_range":.102},"\t"))
	print("B17 canonical field export ",field.total_cells)
	quit()
