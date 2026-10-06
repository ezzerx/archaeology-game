extends SceneTree
## Review JPEGs; raw full-resolution GPU PNGs remain under ignored work/.
func _initialize() -> void:
	var source := "res://work/test-logs/p6a16-structured/"
	var target := "res://docs/dev/evidence/p6a16-structured/"
	DirAccess.make_dir_recursive_absolute(target)
	var shapes := []
	for form in NaturalMatrixProfile.FORMS:
		var shape: Dictionary = form.duplicate()
		shape.outline = []
		for v: Vector2 in form.outline: shape.outline.append([v.x,v.y])
		shapes.append(shape)
	FileAccess.open(target+"parameters.json",FileAccess.WRITE).store_string(JSON.stringify({
		"revision":"structured correction", "footprint_mm":[1100,700],
		"top_bias_mm":NaturalMatrixProfile.TOP_BIAS_MM, "ordered_forms":shapes},"\t"))
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
