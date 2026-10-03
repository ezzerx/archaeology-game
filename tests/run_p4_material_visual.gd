extends "res://tests/run_p4_feedback_visual.gd"
## Render production shading, then read its roughness/specular/coverage through
## a temporary diagnostic shader copy. No test uniform or mode in the game.

func sample_color(picture: Image, points: Array[Vector2]) -> Color:
	var sum := Color(0, 0, 0, 0)
	for p in points:
		var uv := (p + Vector2.ONE * 0.5) / Vector2(block.map_resolution)
		var local := Vector3((uv.x - 0.5) * block.surface_size.x, block.relief.height_at(uv), (uv.y - 0.5) * block.surface_size.y)
		sum += picture.get_pixelv(Vector2i(camera.unproject_position(block.to_global(local)).round()))
	return sum / points.size()

func rgb(color: Color) -> Array:
	return [color.r, color.g, color.b]

func separation(a: Color, b: Color) -> float:
	return Vector3(a.r - b.r, a.g - b.g, a.b - b.b).length()

func material_capture(kind: String, zoom: int) -> Dictionary:
	controller.reset_surface()
	camera.reset_view()
	var p := Vector2(286, 194) if kind == "bone" else CENTER
	if kind == "bone":
		block.working_map.apply_segment(p, p, 85, 100, 1.5, 1)
	else:
		prepare_fixture("clay" if kind == "clay" else "stone")
		if kind == "soil":
			for y in range(70, 221):
				for x in range(620, 821): block.working_map._heights[y * 1024 + x] = 0.9
			block.working_map.image.set_data(1024, 640, false, Image.FORMAT_RF, block.working_map._heights.to_byte_array())
			block.working_map.dirty = true
	block.flush_texture()
	main.feedback.reset()
	move_to((p + Vector2.ONE * 0.5) / Vector2(block.map_resolution))
	camera._focused = true
	if zoom == 3: camera.request_zoom(30, controller._screen)
	for i in range(75): await physics_frame
	controller.hit = {"inside": false}
	block.show_cursor({"inside": false}, 3)
	main.get_node("Debug/BoneNotice").hide()
	main.feedback._process(0)
	await process_frame
	var points: Array[Vector2] = []
	for y in range(int(p.y) - 30, int(p.y) + 31, 3):
		for x in range(int(p.x) - 30, int(p.x) + 31, 3):
			if kind == "bone":
				var interior := true
				for offset in [Vector2i.ZERO, Vector2i(2, 0), Vector2i(-2, 0), Vector2i(0, 2), Vector2i(0, -2)]:
					interior = interior and block.working_map.fossil.exposed[(y + offset.y) * 1024 + x + offset.x] != 0
				if not interior: continue
			points.append(Vector2(x, y))
	check(points.size() > 30, "material readback has enough interior samples: " + kind)
	var geometry := block.working_map.image.get_data()
	var clean := await screenshot("p4-final-%s-clean-%dx" % [kind, zoom])
	# Saturate all nearby dust cells: strongest possible identity test.
	for y in range(int(p.y) - 80, int(p.y) + 81):
		for x in range(int(p.x) - 80, int(p.x) + 81): block.working_map.residue.deposit_removed(x, y, 1.0)
	block.working_map.residue.apply_segment(p, p, 120, 1, 0)
	block.flush_texture()
	var dirty := await screenshot("p4-final-%s-dirty-%dx" % [kind, zoom])
	var before := sample_color(clean, points)
	var after := sample_color(dirty, points)
	if kind == "bone":
		check(separation(before, after) > 0.003 and separation(before, after) < 0.12,
			"saturated dust visibly dulls Bone while retaining its ivory identity at %dx" % zoom)
		check(after.r > after.g and after.g > after.b and after.r > before.r * 0.90,
			"dirty Bone stays warm ivory, never grey stone at %dx" % zoom)
	else:
		check(separation(before, after) > 0.025 and after.r > after.g and after.g > after.b,
			"material dust renders visible warm accumulation: %s %dx" % [kind, zoom])
	var original: Shader = block.material.shader
	var diagnostic := Shader.new()
	var code := original.code.replace("render_mode cull_disabled, diffuse_burley;", "render_mode cull_disabled, unshaded;")
	var end := code.rfind("}")
	# Emit metrics with the same calculation/texture/geometry, removing lighting
	# so that reflected specular cannot contaminate the diagnostic RGB channels.
	diagnostic.code = code.substr(0, end) + "\n ALBEDO = vec3(ROUGHNESS, SPECULAR, dust_cover); EMISSION = vec3(0.0);\n}"
	block.material.shader = diagnostic
	var metrics_image := await screenshot("p4-final-%s-metrics-%dx" % [kind, zoom])
	var metrics := sample_color(metrics_image, points)
	block.material.shader = original
	if kind == "bone":
		check(metrics.r < 0.55 and metrics.g > 0.30 and metrics.b <= 0.245,
			"GPU Bone roughness/specular/coverage stay distinct at saturated dust")
	else:
		check(metrics.r >= 0.84 and metrics.g < 0.16, "GPU matrix remains rougher and less specular than Bone: " + kind)
	var puff: Color = main.feedback.dust_color_at(points[points.size() / 2])
	check(puff.r > puff.g and puff.g > puff.b, "Blower source color follows warm material identity: " + kind)
	check(block.working_map.image.get_data() == geometry and block.working_map.fossil.condition == 100,
		"dust rendering cannot alter structure or condition: " + kind)
	var result := {"samples": points.size(), "clean_rgb": rgb(before), "dirty_rgb": rgb(after), "metrics": rgb(metrics), "puff": rgb(puff)}
	print("P4 MATERIAL ", kind, " ", zoom, "x: ", JSON.stringify(result))
	return result

func run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Material readability needs the actual graphical renderer")
		quit(1)
		return
	root.size = Vector2i(1920, 1080)
	root.content_scale_size = root.size
	AudioServer.set_bus_mute(0, true)
	main = load("res://scenes/prototype_main.tscn").instantiate()
	root.add_child(main)
	block = main.block
	controller = main.controller
	camera = main.camera
	controller.set_physics_process(false)
	main.get_node("Debug/Panel").hide()
	main.get_node("Debug/BonePanel").hide()
	for zoom in [1, 3]:
		var samples := {}
		for kind in ["soil", "clay", "stone", "bone"]:
			samples[kind] = await material_capture(kind, zoom)
		var dirt: Array = samples.soil.dirty_rgb
		var clay: Array = samples.clay.dirty_rgb
		var stone: Array = samples.stone.dirty_rgb
		var bone: Array = samples.bone.dirty_rgb
		check(Vector3(dirt[0], dirt[1], dirt[2]).distance_to(Vector3(clay[0], clay[1], clay[2])) > 0.04
			and Vector3(clay[0], clay[1], clay[2]).distance_to(Vector3(stone[0], stone[1], stone[2])) > 0.08,
			"Soil, Clay and Sandstone have distinct rendered dusty palettes")
		check(Vector3(bone[0], bone[1], bone[2]).distance_to(Vector3(stone[0], stone[1], stone[2])) > 0.06,
			"dirty Bone remains visibly separate from dirty Sandstone")
		report["materials_%dx" % zoom] = samples
	report["failures"] = failures
	report["checks"] = visual_checks
	FileAccess.open("res://work/test-logs/p4-material-visual.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("P4 MATERIAL VISUAL: %d checks, %d failures" % [visual_checks, failures])
	main.queue_free()
	await create_timer(0.4).timeout
	quit(0 if failures == 0 else 1)
