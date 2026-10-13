extends SceneTree
## Archive true Godot captures (JPEG encoding only), numerical tests and timings.
func _initialize() -> void:
	var source:="res://work/test-logs/p6a3/"
	var target:="res://docs/dev/evidence/p6a3-sensory/"
	DirAccess.make_dir_recursive_absolute(target)
	for mode in ["tests","visual","benchmark","movie"]:
		var result:Dictionary=JSON.parse_string(FileAccess.get_file_as_string(source+mode+".json"))
		assert(result.get("failures",["missing"]).is_empty(),"Invalid evidence: "+mode)
		var log_text:=FileAccess.get_file_as_string("res://work/p6a3-"+mode+".log")
		assert(not log_text.contains("ERROR"),"Runtime error: "+mode)
		DirAccess.copy_absolute(source+mode+".json",target+mode+".json")
		if mode=="visual":
			for name:String in result.captures:
				var picture:=Image.load_from_file(source+name)
				assert(picture!=null)
				assert(picture.save_jpg(target+name.trim_suffix(".png")+".jpg",.93)==OK)
	DirAccess.copy_absolute("res://work/test-logs/p5h-tests.json",target+"p5-regression.json")
	for asset in ["brush","chisel","pick","blower","lamp"]:
		for view in ["front","back","side","top"]:
			var name:String=asset+"-"+view
			var picture:=Image.load_from_file("res://work/p6a3-art/"+name+".png")
			assert(picture!=null)
			assert(picture.save_jpg(target+name+".jpg",.93)==OK)
	print("P6A3 evidence: real render captures and numerical records exported")
	quit()
