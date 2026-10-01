extends SceneTree
## Real renderer at 1920x1080, deterministic input through the production controller.
## -- --inspect keeps the carved scene open after measurement; no production shortcuts.

var main: Node3D
var block: ExcavationBlock
var controller: ToolController
var camera: Camera3D
var frame_times: Array[float] = []
var previous_frame := 0
var measuring := false
var failures := 0
var report := {}

func _initialize() -> void:
	call_deferred("run")

func on_frame() -> void:
	var now := Time.get_ticks_usec()
	if measuring and previous_frame > 0:
		frame_times.append((now - previous_frame) / 1000.0)
	previous_frame = now

func stats(values: Array[float]) -> Dictionary:
	if values.is_empty():
		return {}
	var ordered := values.duplicate()
	ordered.sort()
	var total := 0.0
	for value in values:
		total += value
	return {"mean": total / values.size(), "p95": ordered[int((ordered.size() - 1) * 0.95)], "max": ordered[-1]}

func move_to(uv: Vector2) -> void:
	var local := Vector3((uv.x - 0.5) * block.surface_size.x, block.thickness, (uv.y - 0.5) * block.surface_size.y)
	var motion := InputEventMouseMotion.new()
	motion.position = camera.unproject_position(block.to_global(local))
	root.push_input(motion, true)

func press_at(uv: Vector2) -> void:
	move_to(uv)
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = controller._screen
	root.push_input(press, true)

func phase(label: String, ticks: int, kind: String) -> void:
	controller.reset_surface()
	controller._focused = true
	controller._pointer_inside = true
	# Exclude reset/readback stalls and let the engine drain any prior catch-up.
	for warmup in range(60):
		await physics_frame
	press_at(Vector2(0.5, 0.5))
	var edit: Array[float] = []
	var upload: Array[float] = []
	var pick: Array[float] = []
	var changed: Array[float] = []
	frame_times.clear()
	previous_frame = 0
	measuring = true
	var started := Time.get_ticks_usec()
	for tick in range(ticks):
		await physics_frame
		controller._focused = true
		controller._pointer_inside = true
		match kind:
			"normal":
				var t := tick / 60.0
				move_to(Vector2(0.5 + 0.22 * sin(t * 1.2), 0.5 + 0.18 * cos(t * 1.5)))
			"rapid":
				# Large deliberate movements: ~200 map texels per 60 Hz tick.
				var t := tick / 60.0
				move_to(Vector2(0.5 + 0.43 * sin(t * 24.0), 0.5 + 0.40 * cos(t * 19.0)))
			"extreme":
				move_to(Vector2(0.03, 0.03) if tick % 2 == 0 else Vector2(0.97, 0.97))
			"idle":
				controller.cancel_stroke()
		controller._physics_process(1.0 / 60.0)
		edit.append(controller.last_edit_usec / 1000.0)
		upload.append(block.last_upload_usec / 1000.0)
		pick.append(controller.last_pick_usec / 1000.0)
		changed.append(float(controller.changed_texels))
	measuring = false
	var seconds := (Time.get_ticks_usec() - started) / 1000000.0
	controller.cancel_stroke()
	report[label] = {"ticks": ticks, "elapsed_seconds": seconds,
		"render_fps": frame_times.size() / seconds, "frame_ms": stats(frame_times),
		"cpu_edit_ms": stats(edit), "upload_submit_ms": stats(upload),
		"cpu_pick_ms": stats(pick), "changed_texels": stats(changed)}
	print("P1 BENCH ", label, ": ", JSON.stringify(report[label]))

func screenshot(name: String) -> Image:
	await RenderingServer.frame_post_draw
	var picture := root.get_texture().get_image()
	picture.save_png("res://work/test-logs/" + name + ".png")
	return picture

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://work/test-logs")
	FileAccess.open("res://work/.gdignore", FileAccess.WRITE).close()
	if DisplayServer.get_name() == "headless":
		push_error("Run this benchmark with the graphical renderer, not --headless.")
		quit(1)
		return
	root.size = Vector2i(1920, 1080)
	root.content_scale_size = Vector2i(1920, 1080)
	# Uncapped rendering measures headroom. Simulation remains fixed at 60 Hz.
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0 # Explicit benchmark override of P3's normal 240 cap.
	process_frame.connect(on_frame)
	main = load("res://scenes/prototype_main.tscn").instantiate()
	root.add_child(main)
	block = main.get_node("ExcavationBlock")
	controller = main.get_node("ToolController")
	camera = main.get_node("Camera3D")
	controller.set_physics_process(false)
	print("P1 GPU: ", RenderingServer.get_video_adapter_name())
	print("P1 CPU: ", OS.get_processor_name())
	for i in range(120):
		await physics_frame
	await phase("idle", 180, "idle")
	await phase("normal", 360, "normal")
	await screenshot("p1-normal")
	await phase("rapid", 180, "rapid")
	await screenshot("p1-rapid")
	await phase("extreme_diagonal", 60, "extreme")
	Engine.max_fps = 60
	await phase("normal_capped_60", 360, "normal")
	await phase("rapid_capped_60", 180, "rapid")
	await phase("stationary_deep", 480, "stationary")
	await screenshot("p1-deep")
	# Inspect several well separated cavities, including a carved edge.
	for pair in [[Vector2(0.3, 0.42), 1.2], [Vector2(0.7, 0.55), 4.0], [Vector2(0.995, 0.78), 10.0]]:
		var point := SurfaceMapping.uv_to_map(pair[0], block.map_resolution)
		block.working_map.apply_segment(point, point, 85, 1, 1.5, pair[1])
	block.flush_texture()
	block.show_cursor({"inside": false}, 40)
	main.get_node("Debug/Panel").hide()
	await screenshot("p1-cavities")
	block.set_debug_view(1)
	var height_picture := await screenshot("p1-height")
	var worst := 0.0
	var samples := 0
	# Height view emits the actual interpolated vertex height. Validate GPU pixels
	# against first-hit CPU heights, including sidewalls and layer transitions.
	for y in range(280, 780, 19):
		for x in range(700, 1240, 17):
			var pixel := Vector2i(x, y)
			var hit := block.pick(Vector2(pixel) + Vector2(0.5, 0.5), camera)
			if not hit.inside:
				continue
			# Compatibility outputs sRGB directly (OUTPUT_IS_SRGB); debug emission
			# writes the scalar without a linear-to-sRGB conversion in this renderer.
			var displayed := (height_picture.get_pixelv(pixel).r - 0.25) / 0.75
			worst = maxf(worst, absf(displayed - hit.height))
			samples += 1
	print("P1 GPU HEIGHT: ", samples, " pixels, max linear-height error ", worst)
	if worst > 0.01 or samples < 500:
		failures += 1
		push_error("GPU height pixels do not agree with CPU picking")
	var texture_matches := block.texture.get_image().get_data() == block.working_map.image.get_data()
	if not texture_matches:
		failures += 1
		push_error("Uploaded height texture differs from the CPU map")
	block.set_debug_view(0)
	main.get_node("Debug/Panel").show()
	controller.set_physics_process(true)
	report["gpu_height_max_error"] = worst
	report["gpu_height_samples"] = samples
	report["gpu_texture_byte_exact"] = texture_matches
	report["gpu"] = RenderingServer.get_video_adapter_name()
	report["cpu"] = OS.get_processor_name()
	report["godot"] = Engine.get_version_info().string
	report["viewport"] = str(root.size)
	report["failures"] = failures
	var file := FileAccess.open("res://work/test-logs/p1-benchmark.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print("P1 GRAPHICAL CHECKS: ", failures, " failures")
	Engine.max_fps = ProjectSettings.get_setting("application/run/max_fps")
	if not "--inspect" in OS.get_cmdline_user_args():
		quit(0 if failures == 0 else 1)
