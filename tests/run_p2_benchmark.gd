extends SceneTree
## Actual Compatibility renderer, 1080p, production input/controller/surface APIs.
## Timing excludes fixture setup, reset and GPU readbacks. -- --inspect keeps open.

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

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func on_frame() -> void:
	var now := Time.get_ticks_usec()
	if measuring and previous_frame > 0:
		frame_times.append((now - previous_frame) / 1000.0)
	previous_frame = now

func stats(values: Array[float]) -> Dictionary:
	if values.is_empty(): return {}
	var sorted := values.duplicate()
	sorted.sort()
	var sum := 0.0
	for value in values: sum += value
	return {"mean": sum / values.size(), "p95": sorted[int((sorted.size() - 1) * 0.95)], "max": sorted[-1]}

func move_to(uv: Vector2) -> void:
	var local := Vector3((uv.x - 0.5) * block.surface_size.x,
		block.relief.height_at(uv), (uv.y - 0.5) * block.surface_size.y)
	var event := InputEventMouseMotion.new()
	event.position = camera.unproject_position(block.to_global(local))
	root.push_input(event, true)

func press_at(uv: Vector2) -> void:
	move_to(uv)
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = controller._screen
	root.push_input(press, true)

func select(index: int) -> void:
	var key := InputEventKey.new()
	key.physical_keycode = [KEY_1, KEY_2, KEY_3][index]
	key.pressed = true
	root.push_input(key, true)

func prepare_clay() -> void:
	var brush := controller.tools[0].duplicate() as ToolDefinition
	brush.radius = 65
	for y in range(160, 501, 50):
		for repeat in range(3):
			block.working_map.apply_continuous(Vector2(220, y), Vector2(800, y), brush, 0.6)

func prepare_residue() -> void:
	prepare_clay()
	var chisel := controller.tools[1].duplicate() as ToolDefinition
	chisel.radius = 38
	for y in range(190, 471, 40):
		for x in range(250, 791, 40):
			for repeat in range(5):
				block.working_map.apply_impact(Vector2(x, y), chisel)

func screenshot(name: String) -> Image:
	await RenderingServer.frame_post_draw
	var picture := root.get_texture().get_image()
	picture.save_png("res://work/test-logs/" + name + ".png")
	return picture

func phase(label: String, ticks: int, tool_index: int, kind: String) -> void:
	controller.reset_surface()
	controller._focused = true
	controller._pointer_inside = true
	select(tool_index)
	if tool_index == 1: prepare_clay()
	if tool_index == 2: prepare_residue()
	block.flush_texture()
	if tool_index == 2:
		block.show_cursor({"inside": false}, 60)
		await screenshot("p2-residue-before")
	for warmup in range(60): await physics_frame
	press_at(Vector2(0.5, 0.5))
	var edit: Array[float] = []
	var active_edit: Array[float] = []
	var residue_edit: Array[float] = []
	var upload: Array[float] = []
	var residue_upload: Array[float] = []
	var pick: Array[float] = []
	var changed: Array[float] = []
	var height_before := block.working_map.image.get_data() if tool_index == 2 else PackedByteArray()
	var height_uploads := block.upload_count
	var residue_uploads := block.residue_upload_count
	frame_times.clear()
	previous_frame = 0
	measuring = true
	var started := Time.get_ticks_usec()
	for tick in range(ticks):
		await physics_frame
		# Benchmark inputs stay deterministic if the OS focus moves during a run.
		# Focus cancellation itself is tested separately, without this override.
		controller._focused = true
		controller._pointer_inside = true
		var t := tick / 60.0
		var uv := Vector2(0.5, 0.5)
		match kind:
			"normal", "moving", "blower", "switching":
				uv = Vector2(0.5 + 0.22 * sin(t * 1.2), 0.5 + 0.18 * cos(t * 1.5))
			"rapid":
				uv = Vector2(0.5 + 0.43 * sin(t * 24.0), 0.5 + 0.40 * cos(t * 19.0))
			"combined":
				uv = Vector2(0.5 + 0.07 * sin(t * 1.5), 0.5 + 0.055 * cos(t * 1.5))
		if kind == "combined" and tick in [180, 360]:
			select(1 if tick == 180 else 2)
			press_at(uv)
		if kind == "switching" and tick % 20 == 0:
			select((tick / 20) as int % 3)
			press_at(uv)
		move_to(uv)
		controller._physics_process(1.0 / 60.0)
		edit.append(controller.last_edit_usec / 1000.0)
		if controller.changed_texels > 0 or controller.changed_residue_cells > 0:
			active_edit.append(controller.last_edit_usec / 1000.0)
		residue_edit.append(controller.last_residue_edit_usec / 1000.0)
		upload.append(block.last_upload_usec / 1000.0)
		residue_upload.append(block.last_residue_upload_usec / 1000.0)
		pick.append(controller.last_pick_usec / 1000.0)
		changed.append(float(controller.changed_texels))
	measuring = false
	var seconds := (Time.get_ticks_usec() - started) / 1000000.0
	controller.cancel_stroke()
	report[label] = {"ticks": ticks, "elapsed_seconds": seconds,
		"render_fps": frame_times.size() / seconds, "frame_ms": stats(frame_times),
		"cpu_edit_ms": stats(edit), "cpu_active_edit_ms": stats(active_edit),
		"cpu_residue_edit_ms": stats(residue_edit), "height_upload_submit_ms": stats(upload),
		"residue_upload_submit_ms": stats(residue_upload), "cpu_pick_ms": stats(pick),
		"changed_texels": stats(changed), "height_uploads": block.upload_count - height_uploads,
		"residue_uploads": block.residue_upload_count - residue_uploads, "impacts": controller.total_impacts}
	check(report[label].render_fps >= 58.0 and report[label].frame_ms.p95 < 20.0,
		"60 FPS regression in " + label)
	if tool_index == 2:
		report[label]["height_byte_exact"] = height_before == block.working_map.image.get_data()
		check(report[label].height_byte_exact and report[label].height_uploads == 0, "blower modified/uploaded height")
	print("P2 BENCH ", label, ": ", JSON.stringify(report[label]))
	block.show_cursor({"inside": false}, controller.config.radius)
	await screenshot("p2-" + label)

func validate_gpu() -> void:
	check(block.texture.get_image().get_data() == block.working_map.image.get_data(), "height GPU/CPU byte equality")
	check(block.residue_texture.get_image().get_data() == block.working_map.residue.image.get_data(), "R8 residue GPU/CPU byte equality")
	block.show_cursor({"inside": false}, 40)
	main.get_node("Debug/Panel").hide()
	block.set_debug_view(1)
	var height_picture := await screenshot("p2-height")
	var worst := 0.0
	var samples := 0
	for y in range(280, 780, 19):
		for x in range(700, 1240, 17):
			var pixel := Vector2i(x, y)
			var hit := block.pick(Vector2(pixel) + Vector2(0.5, 0.5), camera)
			if not hit.inside: continue
			var displayed := (height_picture.get_pixelv(pixel).r - 0.25) / 0.75
			worst = maxf(worst, absf(displayed - hit.height))
			samples += 1
	check(worst < 0.01 and samples >= 500, "P2 rendered height disagrees with precise CPU picking")
	report["gpu_height_max_error"] = worst
	report["gpu_height_samples"] = samples
	report["gpu_height_byte_exact"] = block.texture.get_image().get_data() == block.working_map.image.get_data()
	report["gpu_residue_byte_exact"] = block.residue_texture.get_image().get_data() == block.working_map.residue.image.get_data()
	block.set_debug_view(0)
	main.get_node("Debug/Panel").show()

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://work/test-logs")
	if DisplayServer.get_name() == "headless":
		push_error("This benchmark requires the actual graphical renderer.")
		quit(1)
		return
	root.size = Vector2i(1920, 1080)
	root.content_scale_size = Vector2i(1920, 1080)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 60
	process_frame.connect(on_frame)
	main = load("res://scenes/prototype_main.tscn").instantiate()
	root.add_child(main)
	block = main.get_node("ExcavationBlock")
	controller = main.get_node("ToolController")
	camera = main.get_node("Camera3D")
	controller.set_physics_process(false)
	for i in range(120): await physics_frame
	await phase("brush_normal", 360, 0, "normal")
	await phase("brush_rapid", 360, 0, "rapid")
	await phase("chisel_stationary", 360, 1, "stationary")
	await phase("chisel_moving", 360, 1, "moving")
	await phase("blower_residue", 360, 2, "blower")
	await phase("brush_chisel_blower", 540, 0, "combined")
	await phase("rapid_switching", 360, 0, "switching")
	await validate_gpu()
	report["gpu"] = RenderingServer.get_video_adapter_name()
	report["cpu"] = OS.get_processor_name()
	report["godot"] = Engine.get_version_info().string
	report["viewport"] = str(root.get_texture().get_size())
	report["height_payload_bytes"] = block.working_map.image.get_data_size()
	report["residue_payload_bytes"] = block.working_map.residue.image.get_data_size()
	report["failures"] = failures
	var file := FileAccess.open("res://work/test-logs/p2-benchmark.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print("P2 GRAPHICAL CHECKS: ", failures, " failures")
	controller.set_physics_process(true)
	if not "--inspect" in OS.get_cmdline_user_args():
		quit(0 if failures == 0 else 1)
