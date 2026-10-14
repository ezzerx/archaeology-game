extends SceneTree
func _initialize() -> void:
	var data := preload("res://scripts/p6a34/mesh_patch_data.gd").new()
	data.ceilings = FileAccess.get_file_as_bytes("res://work/p6a36/roof.rf").to_float32_array()
	data.components = FileAccess.get_file_as_bytes("res://work/p6a36/components.bytes")
	data.old_rib_selection = FileAccess.get_file_as_bytes("res://work/p6a36/old-rib-selection.bytes")
	assert(data.components.size() == 1024*640 and data.ceilings.size() == data.components.size())
	# Retain the already validated rib bake bit-for-bit. The source rib meshes
	# are reused exactly; only the skull has a newly authored projection.
	var previous: Resource = load("res://assets/p6a35/mesh_patch_data.res")
	for i in range(data.components.size()):
		if data.components[i] == 3:
			data.components[i] = 0
			data.ceilings[i] = 0.0
		if previous.components[i] == 3:
			data.components[i] = 3
			data.ceilings[i] = previous.ceilings[i]
	var result := ResourceSaver.save(data,"res://assets/p6a36/mesh_patch_data.res",ResourceSaver.FLAG_COMPRESS)
	var manifest_path := "res://assets/p6a36/production-manifest.json"
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	var count := 0
	for component in data.components:
		if component != 0: count += 1
	manifest["runtime_baked_cells"] = count
	manifest["runtime_rib_bake"] = "P6A35 retained exactly"
	FileAccess.open(manifest_path,FileAccess.WRITE).store_string(JSON.stringify(manifest,"\t")+"\n")
	print("P6A36 FIELD PACK ",error_string(result))
	quit(0 if result == OK else 1)
