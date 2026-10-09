extends SceneTree
## Re-encode real GPU captures for Git; never retouch or synthesize evidence.
func _initialize() -> void:
	var source := "res://work/test-logs/p6a2-hero/"
	var target := "res://docs/dev/evidence/p6a2-hero/"
	var correction := "--correction" in OS.get_cmdline_user_args()
	if correction:
		source="res://work/test-logs/p6a2-correction/"
		target="res://docs/dev/evidence/p6a2-correction/"
	DirAccess.make_dir_recursive_absolute(target)
	for mode in ["tests","visual","benchmark"]:
		var result: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(source+mode+".json"))
		if result.is_empty() or not result.get("failures",["missing"]).is_empty():
			push_error("Missing/failing evidence: "+mode);quit(1);return
		if mode=="benchmark":
			for i in range(0,result.benchmark.size(),2):
				var before: Dictionary=result.benchmark[i]
				var hero: Dictionary=result.benchmark[i+1]
				if before.initial!=hero.initial or before.final!=hero.final or before.camera!=hero.camera or before.camera_size!=hero.camera_size:
					push_error("Benchmark state/pose mismatch at "+str(i));quit(1);return
		DirAccess.copy_absolute(source+mode+".json",target+mode+".json")
	var names: Array[String]=[]
	for state in ["reset","part-brushed","excavated","dirty-bone","cleaner-bone"]:
		names.append("baseline-"+state)
		names.append("hero-"+state)
		names.append("hero-"+state+"-3x")
	names.append_array(["hero-stone-interface-3x","hero-jacket-integration-3x"])
	if correction:
		var visual: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(source+"visual.json"))
		names.clear()
		for capture_name: String in visual.captures: names.append(capture_name.trim_suffix(".png"))
	for label in names:
		var picture:=Image.load_from_file(source+label+".png")
		if picture==null or picture.save_jpg(target+label+".jpg",.93)!=OK:
			push_error("Missing capture: "+label);quit(1);return
	print("P6A2: exported ",names.size()," unretouched review JPEGs + three result files")
	quit()
