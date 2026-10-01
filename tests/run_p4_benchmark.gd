extends "res://tests/run_p2_benchmark.gd"
## Production input + FX at 1x/3x, 1080p, 240 cap / 60 physics.

func prepare_fixture(kind: String) -> void:
	if kind in ["clay", "stone", "blower"]:
		# Controlled material slab, outside fossil. Setup excluded from timings.
		for y in range(70, 221):
			for x in range(620, 821):
				var index := y * block.map_resolution.x + x
				block.working_map._heights[index] = 0.55 if kind == "clay" else 0.22
				if kind == "blower": block.working_map.residue.deposit_removed(x, y, 0.65)
		block.working_map.image.set_data(1024, 640, false, Image.FORMAT_RF, block.working_map._heights.to_byte_array())
		block.working_map.dirty = true
		if kind == "blower": block.working_map.residue.apply_segment(Vector2(620, 140), Vector2(820, 140), 90, 1, 0)
	elif kind == "bone":
		var p := SurfaceMapping.uv_to_map(Vector2(0.28, 0.305), block.map_resolution)
		block.working_map.apply_segment(p, p, 65, 1.15, 1.5, 1)
	block.flush_texture()
	main.feedback.reset()

func scenario(kind: String, zoom: float) -> void:
	controller.reset_surface()
	(camera as PrecisionZoom).reset_view()
	controller._focused = true
	controller._pointer_inside = true
	select(0 if kind == "soil" else (2 if kind == "blower" else 1))
	prepare_fixture(kind)
	var center := Vector2(0.70, 0.22) if kind != "bone" else Vector2(0.28, 0.305)
	move_to(center)
	if zoom > 1:
		(camera as PrecisionZoom)._focused = true
		(camera as PrecisionZoom).request_zoom(log(zoom) / log((camera as PrecisionZoom).wheel_step), controller._screen)
	for i in range(90): await physics_frame
	var initial_height := block.working_map.image.get_data()
	var uploads := block.upload_count
	var fracture_uploads := block.fracture_upload_count
	var edits: Array[float] = []
	var active: Array[float] = []
	var picks: Array[float] = []
	var upload_times: Array[float] = []
	var changed := 0
	var marked := 0
	var detached := 0
	frame_times.clear()
	previous_frame = 0
	measuring = true
	var started := Time.get_ticks_usec()
	press_at(center)
	for tick in range(360):
		await physics_frame
		controller._focused = true
		controller._pointer_inside = true
		controller._held = true
		var p := Vector2(655 + (tick / 40 as int % 5) * 29, 115 + (tick / 200 as int) * 32)
		var uv := (p + Vector2.ONE * 0.5) / Vector2(block.map_resolution)
		if kind in ["soil", "blower"]: uv = center + Vector2(0.065 * sin(tick / 80.0), 0.07 * cos(tick / 67.0))
		if kind == "bone": uv = center + Vector2(0.012 * sin(tick / 100.0), 0.006 * cos(tick / 90.0))
		move_to(uv)
		controller._physics_process(1.0 / 60.0)
		edits.append(controller.last_edit_usec / 1000.0)
		if controller.impacts_this_tick > 0 or kind in ["soil", "blower"]: active.append(controller.last_edit_usec / 1000.0)
		picks.append(controller.last_pick_usec / 1000.0)
		upload_times.append((block.last_upload_usec + block.last_residue_upload_usec + block.last_fracture_upload_usec) / 1000.0)
		changed += controller.changed_texels
		if controller.impacts_this_tick > 0:
			marked += block.working_map.fracture.last_marks
			detached += block.working_map.fracture.last_chunks.size()
	measuring = false
	var seconds := (Time.get_ticks_usec() - started) / 1e6
	controller.cancel_stroke()
	var label := "%s_%dx" % [kind, int(zoom)]
	report[label] = {"render_fps": frame_times.size() / seconds, "frame_ms": stats(frame_times),
		"cpu_edit_ms": stats(edits), "cpu_active_edit_ms": stats(active), "cpu_pick_ms": stats(picks),
		"upload_submit_ms": stats(upload_times), "changed_texels": changed, "marks": marked, "chunks": detached,
		"particles_emitted": Array(main.feedback.emitted), "audio_events": main.feedback.audio.played,
		"impacts": controller.total_impacts, "height_uploads": block.upload_count - uploads,
		"fracture_uploads": block.fracture_upload_count - fracture_uploads,
		"exposed_cells": block.working_map.fossil.exposed_cells, "condition": block.working_map.fossil.condition,
		"zoom": (camera as PrecisionZoom).zoom_factor}
	check(report[label].render_fps >= 58 and report[label].frame_ms.p95 < 20, "60 FPS budget: " + label)
	check(report[label].render_fps < 242, "cap respected: " + label)
	check(main.feedback.audio.played > 0, "audio event routing active: " + label)
	if kind in ["clay", "stone"]: check(marked > 0 and detached > 0, "actual marks AND chunks measured: " + label)
	if kind == "blower": check(initial_height == block.working_map.image.get_data() and block.upload_count == uploads, "Blower structural state exact: " + label)
	print("P4 BENCH ", label, " ", JSON.stringify(report[label]))
	await screenshot("p4-" + label)

func comparison_captures() -> void:
	controller.reset_surface()
	(camera as PrecisionZoom).reset_view()
	controller._focused = true
	controller._pointer_inside = true
	select(1)
	prepare_fixture("clay")
	var p := Vector2(710, 140)
	move_to((p + Vector2.ONE * 0.5) / Vector2(block.map_resolution))
	(camera as PrecisionZoom)._focused = true
	(camera as PrecisionZoom).request_zoom(log(3.0) / log((camera as PrecisionZoom).wheel_step), controller._screen)
	for i in range(80): await physics_frame
	controller.refresh_view()
	block.working_map.apply_impact(p, controller.config)
	block.flush_texture()
	controller.refresh_view()
	await screenshot("p4-clay-mark")
	block.working_map.apply_impact(p, controller.config)
	block.flush_texture()
	controller.refresh_view()
	await screenshot("p4-clay-chip")
	prepare_fixture("stone")
	block.working_map.fracture.reset()
	block.working_map.apply_impact(p, controller.config)
	block.flush_texture()
	controller.refresh_view()
	await screenshot("p4-stone-mark")
	for i in range(2): block.working_map.apply_impact(p, controller.config)
	block.flush_texture()
	controller.refresh_view()
	await screenshot("p4-stone-chip")
	check(block.fracture_texture.get_image().get_data() == block.working_map.fracture.image.get_data(), "fracture atlas GPU byte equality")

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://work/test-logs")
	if DisplayServer.get_name() == "headless":
		push_error("P4 benchmark requires graphical renderer")
		quit(1)
		return
	check(Engine.max_fps == 240 and Engine.physics_ticks_per_second == 60, "normal project runtime settings")
	root.size = Vector2i(1920, 1080)
	root.content_scale_size = Vector2i(1920, 1080)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	# Exercise real mixer/voices without broadcasting repeated test audio.
	AudioServer.set_bus_mute(0, true)
	process_frame.connect(on_frame)
	main = load("res://scenes/prototype_main.tscn").instantiate()
	root.add_child(main)
	block = main.get_node("ExcavationBlock")
	controller = main.get_node("ToolController")
	camera = main.get_node("Camera3D")
	controller.set_physics_process(false)
	main.get_node("Debug/Panel").hide()
	main.get_node("Debug/BonePanel").hide()
	for i in range(90): await physics_frame
	for zoom in [1.0, 3.0]:
		for kind in ["soil", "clay", "stone", "bone", "blower"]:
			await scenario(kind, zoom)
	await comparison_captures()
	report["gpu"] = RenderingServer.get_video_adapter_name()
	report["cpu"] = OS.get_processor_name()
	report["engine"] = Engine.get_version_info().string
	report["viewport"] = str(root.size)
	report["stress_atlas_bytes"] = block.working_map.fracture.image.get_data_size()
	report["max_particles"] = block.reactions.particles_per_family * 4
	report["runtime_cap"] = Engine.max_fps
	report["physics_hz"] = Engine.physics_ticks_per_second
	report["failures"] = failures
	FileAccess.open("res://work/test-logs/p4-benchmark.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("P4 GRAPHICAL: %d failures" % failures)
	controller.reset_surface()
	main.queue_free()
	# Let the audio thread retire stopped playbacks before the process exits.
	await create_timer(0.4).timeout
	quit(0 if failures == 0 else 1)
