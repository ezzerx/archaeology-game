extends SceneTree
## Runtime derivatives of the selected JPEG mirrors. No invented resolution,
## no generated height/normal/gameplay data, no changes to selected sources.
func _initialize() -> void:
	var manifest := []
	for material in ["clay","sandstone","soil","bone","plaster"]:
		var source: String="res://art/source/p6a2/images/p6a2_"+material+"_albedo_source_v02.jpg"
		var picture:=Image.load_from_file(source)
		assert(picture!=null and picture.get_size()==Vector2i(1254,1254))
		var folder: String="res://assets/p6a2/textures/"+material+"/"
		DirAccess.make_dir_recursive_absolute(folder)
		var target: String=folder+"p6a2_"+material+"_albedo_v02.png"
		picture.convert(Image.FORMAT_RGB8)
		picture.resize(1024,1024,Image.INTERPOLATE_LANCZOS)
		assert(picture.save_png(target)==OK)
		manifest.append({"source":source,"source_sha256":FileAccess.get_sha256(source),
			"source_dimensions":[1254,1254],"runtime":target,"runtime_sha256":FileAccess.get_sha256(target),
			"runtime_dimensions":[1024,1024],"scale_m":.24,"processing":"RGB8 Lanczos downsample only; color correction in local shader"})
	FileAccess.open("res://art/source/p6a2/images/runtime_manifest.json",FileAccess.WRITE).store_string(JSON.stringify(manifest,"\t")+"\n")
	print("P6A2: five selected JPEG mirrors -> five 1024 RGB PNG runtime derivatives")
	quit()
