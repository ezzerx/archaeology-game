extends SceneTree
## Review JPEGs; raw full-resolution GPU PNGs remain under ignored work/.
func _initialize() -> void:
	var source := "res://work/test-logs/p6a16-outcrops/"
	var target := "res://docs/dev/evidence/p6a16-outcrops/"
	DirAccess.make_dir_recursive_absolute(target)
	var shapes := []
	for form in NaturalMatrixProfile.FORMS:
		var shape: Dictionary = form.duplicate()
		shape.lobes = []
		shape.back = [form.back.x,form.back.y]
		for v: Vector4 in form.lobes: shape.lobes.append([v.x,v.y,v.z,v.w])
		shapes.append(shape)
	FileAccess.open(target+"parameters.json",FileAccess.WRITE).store_string(JSON.stringify({
		"revision":"organic outcrops correction", "footprint_mm":[1100,700],
		"top_bias_mm":NaturalMatrixProfile.TOP_BIAS_MM, "ordered_forms":shapes,
		"union_smoothing_mm":12, "crown_distance_mm":[0,75],
		"front_weight":"smoothstep(-width*0.6,width*0.4,elliptical_radial_distance_mm)",
		"merge_weight":"smoothstep(0.15,0.8,dot(local.normalized(),back.normalized()))",
		"boundary_warp_mm":["8*sin(y/43)+4*sin((x+y)/77)","11*sin(x/61)+3*cos(y/37)"],
		"lower_interface_offset_mm":0},"\t"))
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(source + "visual.json"))
	for file: String in data.captures:
		var pic := Image.load_from_file(source + file)
		if pic == null or pic.save_jpg(target + file.get_basename() + ".jpg", .91) != OK:
			push_error("Missing capture " + file)
			quit(1)
			return
	for name in ["tests", "visual", "benchmark"]:
		var result: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(source + name + ".json"))
		if result.get("checks", 0) == 0 or not result.get("failures", ["missing"]).is_empty():
			push_error("Unverified evidence " + name)
			quit(1)
			return
		if DirAccess.copy_absolute(source + name + ".json", target + name + ".json") != OK:
			push_error("Cannot export " + name)
			quit(1)
			return
	print("P6A16: exported comparison JPEGs and verified JSON")
	quit()
