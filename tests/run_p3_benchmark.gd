extends "res://tests/run_p2_benchmark.gd"
## P2 helpers reused; P3 runs at the unmodified project cap (240).
## Explicit optional -- --uncapped measures headroom, never changes project.godot.

var first_contacts := 0

func on_first_contact(_cell: Vector2i, _component: int) -> void:
	first_contacts += 1

func target_uv() -> Vector2:
	return Vector2(0.28, 0.305) # Skull crown, upper arc, all dimensions normalized.

func prepare_bone(residue := false) -> void:
	var point := SurfaceMapping.uv_to_map(target_uv(), block.map_resolution)
	block.working_map.apply_segment(point, point, 90, 40, 1.5, 1, Vector3.ONE, 8.0 if residue else 0.0)
	if residue:
		block.working_map.residue.apply_segment(point, point, 90, 1.5, 0)
	block.flush_texture()

func p3_phase(label: String, tool_index: int, kind: String, ticks := 360) -> void:
	controller.reset_surface()
	controller._focused = true
	controller._pointer_inside = true
	select(tool_index)
	if kind in ["bone", "brush", "blower"]:
		prepare_bone(kind in ["brush", "blower"])
	elif kind == "reveal":
		# Prepare a thin sandstone cover, keeping the benchmark's reveal incremental.
		var p := SurfaceMapping.uv_to_map(target_uv(), block.map_resolution)
		block.working_map.apply_segment(p, p, 65, 1.15, 1.5, 1)
	block.flush_texture()
	block.show_cursor({"inside": false}, 40)
	if kind == "blower": await screenshot("p3-residue-before")
	for i in range(60): await physics_frame
	var initial_exposure := block.working_map.fossil.exposed_cells
	var initial_condition := block.working_map.fossil.condition
	var heights_before := block.working_map.image.get_data()
	var static_before := block.fossil_texture.get_image().get_data()
	var height_uploads := block.upload_count
	var residue_uploads := block.residue_upload_count
	var edit: Array[float] = []
	var active: Array[float] = []
	var pick: Array[float] = []
	var height_submit: Array[float] = []
	var residue_submit: Array[float] = []
	frame_times.clear()
	previous_frame = 0
	measuring = true
	var started := Time.get_ticks_usec()
	press_at(Vector2(0.5, 0.14) if kind == "matrix" else target_uv())
	for tick_index in range(ticks):
		await physics_frame
		controller._focused = true
		controller._pointer_inside = true
		var uv := target_uv()
		if kind == "matrix": uv = Vector2(0.5 + 0.14 * sin(tick_index / 60.0), 0.14)
		if kind == "reveal": uv += Vector2(0.012 * sin(tick_index / 100.0), 0.006 * cos(tick_index / 90.0))
		move_to(uv)
		controller._physics_process(1.0 / 60.0)
		edit.append(controller.last_edit_usec / 1000.0)
		if controller.impacts_this_tick > 0 or tool_index != 1: active.append(controller.last_edit_usec / 1000.0)
		pick.append(controller.last_pick_usec / 1000.0)
		height_submit.append(block.last_upload_usec / 1000.0)
		residue_submit.append(block.last_residue_upload_usec / 1000.0)
	measuring = false
	var seconds := (Time.get_ticks_usec() - started) / 1e6
	controller.cancel_stroke()
	var fossil := block.working_map.fossil
	report[label] = {"ticks": ticks, "elapsed_seconds": seconds, "render_fps": frame_times.size() / seconds,
		"frame_ms": stats(frame_times), "cpu_edit_ms": stats(edit), "cpu_active_edit_ms": stats(active),
		"cpu_pick_ms": stats(pick), "height_submit_ms": stats(height_submit), "residue_submit_ms": stats(residue_submit),
		"height_uploads": block.upload_count - height_uploads, "residue_uploads": block.residue_upload_count - residue_uploads,
		"impacts": controller.total_impacts, "exposed_before": initial_exposure, "exposed_after": fossil.exposed_cells,
		"condition_before": initial_condition, "condition_after": fossil.condition, "runtime_cap": Engine.max_fps}
	check(report[label].render_fps >= 58 and report[label].frame_ms.p95 < 20, "60 FPS interaction budget: " + label)
	if Engine.max_fps > 0: check(report[label].render_fps <= 241, "runtime cap respected: " + label)
	check(block.fossil_texture.get_image().get_data() == static_before, "fossil texture remains immutable")
	if kind == "matrix": check(fossil.exposed_cells == 0, "matrix phase actually stays away from fossil")
	if kind == "reveal": check(fossil.exposed_cells > initial_exposure, "bone boundary phase actually exposes new cells")
	if kind == "bone": check(fossil.condition == maxf(0, initial_condition - controller.total_impacts * 3), "repeated direct hits pay one damage penalty each")
	if kind in ["brush", "blower"]: check(fossil.condition == initial_condition, "safe tools preserve condition")
	if kind == "blower":
		check(heights_before == block.working_map.image.get_data() and block.upload_count == height_uploads, "Blower over bone has zero structural uploads")
		check(fossil.exposed_cells == initial_exposure, "Blower over bone preserves exposure")
	print("P3 BENCH ", label, ": ", JSON.stringify(report[label]))
	block.show_cursor({"inside": false}, 40)
	await screenshot("p3-" + label)

func validate_bone_pixels() -> void:
	# A large test cavity, created only through the production edit operation.
	controller.reset_surface()
	block.working_map.apply_segment(Vector2(295, 365), Vector2(745, 365), 220, 1000, 1.5, 1)
	block.flush_texture()
	main.get_node("Debug/Panel").hide()
	main.get_node("Debug/BonePanel").hide()
	main.get_node("Debug/BoneNotice").hide()
	block.show_cursor({"inside": false}, 40)
	await screenshot("p3-emergence")
	block.set_debug_view(1)
	var height_picture := await screenshot("p3-height")
	block.set_debug_view(2)
	var material_picture := await screenshot("p3-material")
	var bone_color: Color = block.material.get_shader_parameter("bone_color")
	var color_error := 0.0
	var height_error := 0.0
	var bone_samples := 0
	var matrix_samples := 0
	for y in range(270, 885, 3):
		for x in range(480, 1430, 3):
			var pixel := Vector2i(x, y)
			var hit := block.pick(Vector2(pixel) + Vector2.ONE * 0.5, camera)
			if not hit.inside: continue
			height_error = maxf(height_error, absf((height_picture.get_pixelv(pixel).r - 0.25) / 0.75 - hit.height))
			# Compare the CPU texel criterion against the GPU's flat layer rendering.
			var expected: Color = bone_color if hit.bone_exposed else hit.material.debug_color
			var actual := material_picture.get_pixelv(pixel)
			var error := maxf(absf(actual.r - expected.r), maxf(absf(actual.g - expected.g), absf(actual.b - expected.b)))
			color_error = maxf(color_error, error)
			if hit.bone_exposed: bone_samples += 1
			else: matrix_samples += 1
	check(bone_samples > 2000 and matrix_samples > 10000, "GPU oracle samples both bone and adjacent cavity")
	check(height_error < 0.01, "rendered height equals CPU first-hit relief including bone boundaries")
	check(color_error < 0.02, "rendered bone material equals structural exposure / component cells")
	check(block.fossil_texture.get_image().get_data() == block.working_map.fossil.field.image.get_data(), "static RGF GPU/CPU byte equality")
	check(block.texture.get_image().get_data() == block.working_map.image.get_data(), "height GPU/CPU byte equality")
	check(block.residue_texture.get_image().get_data() == block.working_map.residue.image.get_data(), "residue GPU/CPU byte equality")
	report["gpu_oracle"] = {"bone_pixels": bone_samples, "matrix_pixels": matrix_samples,
		"height_max_error": height_error, "bone_material_max_error": color_error, "textures_byte_exact":
		block.fossil_texture.get_image().get_data() == block.working_map.fossil.field.image.get_data()}
	print("P3 GPU ORACLE: ", JSON.stringify(report.gpu_oracle))
	block.set_debug_view(0)
	main.get_node("Debug/Panel").show()
	main.get_node("Debug/BonePanel").show()
	# Debug F1 legibility and every component's final counters.
	main._process(0.1)
	await screenshot("p3-debug")

func initial_and_first_reveal() -> void:
	controller.reset_surface()
	main.get_node("Debug/Panel").hide()
	main.get_node("Debug/BonePanel").hide()
	block.show_cursor({"inside": false}, 40)
	await screenshot("p3-initial")
	select(1)
	var point := SurfaceMapping.uv_to_map(target_uv(), block.map_resolution)
	var impacts := 0
	while block.working_map.fossil.exposed_cells == 0 and impacts < 80:
		block.working_map.apply_impact(point, controller.config)
		impacts += 1
	block.flush_texture()
	check(block.working_map.fossil.condition == 100 and first_contacts == 1, "natural first reveal is protected with one notification")
	check(block.working_map.fossil.exposure_percent() > 0 and block.working_map.fossil.exposure_percent() < 1, "natural first contact exposes under one percent")
	await screenshot("p3-first-contact")
	report["first_contact"] = {"default_chisel_impacts": impacts, "condition": block.working_map.fossil.condition,
		"exposed_cells": block.working_map.fossil.exposed_cells, "exposure_percent": block.working_map.fossil.exposure_percent()}

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://work/test-logs")
	if DisplayServer.get_name() == "headless":
		push_error("P3 benchmark requires the graphical renderer")
		quit(1)
		return
	check(Engine.max_fps == 240, "project boots at 240 FPS before any benchmark override")
	check(Engine.physics_ticks_per_second == 60, "project boots at 60 Hz physics")
	root.size = Vector2i(1920, 1080)
	root.content_scale_size = Vector2i(1920, 1080)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	if "--uncapped" in OS.get_cmdline_user_args(): Engine.max_fps = 0
	process_frame.connect(on_frame)
	main = load("res://scenes/prototype_main.tscn").instantiate()
	root.add_child(main)
	block = main.get_node("ExcavationBlock")
	controller = main.get_node("ToolController")
	camera = main.get_node("Camera3D")
	controller.set_physics_process(false)
	block.working_map.fossil.bone_first_contact.connect(on_first_contact)
	for i in range(120): await physics_frame
	await initial_and_first_reveal()
	await p3_phase("matrix_excavation", 0, "matrix")
	await p3_phase("bone_boundary_reveal", 1, "reveal")
	await p3_phase("chisel_exposed_bone", 1, "bone")
	await p3_phase("brush_bone", 0, "brush")
	await p3_phase("blower_bone_residue", 2, "blower")
	await validate_bone_pixels()
	report["gpu"] = RenderingServer.get_video_adapter_name()
	report["cpu"] = OS.get_processor_name()
	report["godot"] = Engine.get_version_info().string
	report["viewport"] = str(root.get_texture().get_size())
	report["static_fossil_payload_bytes"] = block.working_map.fossil.field.image.get_data_size()
	report["physics_hz"] = Engine.physics_ticks_per_second
	report["failures"] = failures
	var file := FileAccess.open("res://work/test-logs/p3-benchmark.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print("P3 GRAPHICAL CHECKS: ", failures, " failures")
	# --inspect is interactive: restore the project cap and pristine specimen.
	Engine.max_fps = ProjectSettings.get_setting("application/run/max_fps")
	controller.reset_surface()
	controller.set_physics_process(true)
	if not "--inspect" in OS.get_cmdline_user_args(): quit(0 if failures == 0 else 1)
