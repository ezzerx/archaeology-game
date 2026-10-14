extends SceneTree
func _initialize() -> void:
	var data := preload("res://scripts/p6a34/mesh_patch_data.gd").new()
	data.ceilings = FileAccess.get_file_as_bytes("res://work/p6a35/roof.rf").to_float32_array()
	data.components = FileAccess.get_file_as_bytes("res://work/p6a35/components.bytes")
	data.old_rib_selection = FileAccess.get_file_as_bytes("res://work/p6a35/old-rib-selection.bytes")
	assert(data.components.size() == 1024*640 and data.ceilings.size() == data.components.size())
	var result := ResourceSaver.save(data,"res://assets/p6a35/mesh_patch_data.res",ResourceSaver.FLAG_COMPRESS)
	print("P6A35 FIELD PACK ",error_string(result))
	quit(0 if result == OK else 1)
