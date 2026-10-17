extends SceneTree
func _initialize() -> void:
 var data:=preload("res://scripts/p6a34/mesh_patch_data.gd").new()
 data.ceilings=FileAccess.get_file_as_bytes("res://work/issue41/journey/roof.rf").to_float32_array()
 data.components=FileAccess.get_file_as_bytes("res://work/issue41/journey/components.bytes")
 data.old_rib_selection.resize(data.components.size());data.old_rib_selection.fill(1)
 assert(data.components.size()==1024*640 and data.ceilings.size()==data.components.size())
 var result:=ResourceSaver.save(data,"res://assets/experiments/marine_trial/field.res",ResourceSaver.FLAG_COMPRESS)
 print("MARINE FIELD ",error_string(result));quit(0 if result==OK else 1)
