extends SceneTree
## Export a compact review set from the unmodified GPU PNG readbacks.
func _initialize() -> void:
	var source := "res://work/test-logs/p6a/"
	var target := "res://docs/dev/evidence/p6a/"
	DirAccess.make_dir_recursive_absolute(target)
	var names: Array[String] = ["state09-P5-1x", "state09-A-1x", "state09-C-1x", "state09-C-3x",
		"state06-B-3x", "state07-B-3x", "state08-B-3x", "toggle-02-before", "toggle-02-after",
		"toggle-06-before", "toggle-06-after", "lab-controls"]
	for p in range(10): names.append("state%02d-B-1x" % p)
	for label in names:
		var picture := Image.load_from_file(source + label + ".png")
		if picture == null or picture.save_jpg(target + label + ".jpg", 0.91) != OK:
			push_error("Missing capture " + label)
			quit(1)
			return
	print("P6A: exported ", names.size(), " review JPEGs; original PNGs retained in work/test-logs/p6a")
	quit()
