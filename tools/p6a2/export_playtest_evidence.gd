extends SceneTree
## Real GPU images only: lossless capture -> JPEG encoding, no image retouch.
func _initialize() -> void:
	var source := "res://work/test-logs/p6a2-playtest/"
	var target := "res://docs/dev/evidence/p6a2-playtest/"
	DirAccess.make_dir_recursive_absolute(target)
	var captures: Array[String] = []
	for mode in ["tests","visual","display","benchmark","benchmark-native"]:
		var result:Dictionary=JSON.parse_string(FileAccess.get_file_as_string(source+mode+".json"))
		assert(result.get("failures",["missing"]).is_empty(),"Invalid evidence: "+mode)
		var log_text:=FileAccess.get_file_as_string(source+mode+".log")
		assert(not log_text.contains("ERROR"),"Runtime error in "+mode)
		DirAccess.copy_absolute(source+mode+".json",target+mode+".json")
		for name:String in result.captures:
			if not name in captures: captures.append(name)
	for file_name in captures:
		var picture:=Image.load_from_file(source+file_name)
		assert(picture!=null)
		assert(picture.save_jpg(target+file_name.trim_suffix(".png")+".jpg",.93)==OK)
	DirAccess.copy_absolute("res://work/test-logs/p5h-tests.json",target+"p5-regression.json")
	print("PLAYTEST EVIDENCE: ",captures.size()," real captures, 6 JSON reports")
	quit()
