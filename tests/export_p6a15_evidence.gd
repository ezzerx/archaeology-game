extends SceneTree
## Lossy review copies only. Original GPU PNGs remain in ignored work/.
func _initialize() -> void:
	var source := "res://work/test-logs/p6a15/"
	var target := "res://docs/dev/evidence/p6a15/"
	DirAccess.make_dir_recursive_absolute(target)
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(source + "visual.json"))
	for file: String in data.captures:
		if "mask" in file: continue
		var pic := Image.load_from_file(source + file)
		if pic == null or pic.save_jpg(target + file.get_basename() + ".jpg", 0.91) != OK:
			push_error("Missing capture " + file)
			quit(1)
			return
	for name in ["tests", "visual", "benchmark"]:
		var error := DirAccess.copy_absolute(source + name + ".json", target + name + ".json")
		if error != OK:
			push_error("Missing evidence " + name)
			quit(1)
			return
	print("P6A15: exported review JPEGs + tests, visual and benchmark JSON")
	quit()
