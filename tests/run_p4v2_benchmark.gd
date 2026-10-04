extends "res://tests/run_p4_benchmark.gd"
## Dedicated 1080p render benchmark: real tools + controlled cap/contact stress.
## Fixtures and readbacks excluded; fixed 60 Hz simulation, uncoupled from render.
const CENTER := Vector2(700, 140)
var sim_times: Array[float] = []
var jet_times: Array[float] = []
var multi_times: Array[float] = []
var samples_frame: Array[float] = []
var max_samples_tick := 0
var max_active := 0
var max_sleeping := 0
var bench_checks := 0

func settle_zoom(zoom: float) -> void:
	for attempt in range(3):
		camera._focused = true
		camera.request_zoom(log(zoom / camera.target_zoom) / log(camera.wheel_step), controller._screen)
		for i in range(90): await physics_frame
		if absf(camera.zoom_factor - zoom) < 0.001: break

func screenshot(name: String) -> Image:
	await process_frame
	await process_frame
	return await super.screenshot(name)

func check(ok: bool, message: String) -> void:
	bench_checks += 1
	super.check(ok, message)

func on_frame() -> void:
	super.on_frame()
	if measuring:
		multi_times.append(main.feedback.terrain_view.last_update_usec)
		samples_frame.append(main.feedback.terrain_samples_last_frame)

func minimum_1s_fps() -> float:
	var elapsed := 0.0
	var count := 0
	var minimum := INF
	for time in frame_times:
		elapsed += time
		count += 1
		if elapsed >= 1000:
			minimum = minf(minimum, count * 1000.0 / elapsed)
			elapsed = 0.0
			count = 0
	return minimum

func prepare_v2(kind: String) -> void:
	var s := block.working_map
	var exposed := PackedInt32Array()
	for y in range(40, 261):
		for x in range(580, 1024 if kind == "blower" else 881):
			var height := 0.60 if kind == "flat_clay" else 0.22
			if kind in ["deep_cavity", "cavity_edge", "blower"]:
				height = 0.72 if x < 705 else 0.06
			var index := y * s.size.x + x
			var ceiling := s.fossil.field.ceilings[index]
			s._heights[index] = maxf(height, ceiling)
			if ceiling > 0 and s._heights[index] <= ceiling + FossilField.EXPOSURE_EPSILON: exposed.append(index)
	s.image.set_data(s.size.x, s.size.y, false, Image.FORMAT_RF, s._heights.to_byte_array())
	s.dirty = true
	s.fossil.expose_cells(exposed)
	block.flush_texture()
	main.feedback.reset()

func top_up(kind: String, enabled: bool) -> void:
	var fx: MaterialFeedback = main.feedback
	if enabled:
		# Preallocated 48 fragments exercise contact sampling together. Resetting
		# is never used during the measurement; normal sleep/recycle remains active.
		for i in range(48 - fx.terrain_debris.active_count):
			var p := Vector2(725 + (i % 8) * 4, 113 + (i / 8 as int) * 8)
			if kind == "max_fragments": p.x -= 25
			if kind == "blower": p.x += 240 # A clean cavity opening onto the block edge.
			var uv := (p + Vector2.ONE * 0.5) / Vector2(block.map_resolution)
			var at := Vector3((uv.x - 0.5) * block.surface_size.x,
				block.relief.height_at(uv) + (0.085 if kind == "deep_cavity" else 0.012),
				(uv.y - 0.5) * block.surface_size.y)
			fx.terrain_debris.spawn(at, Vector3.ZERO, Vector3(0.005, 0.0035, 0.005), 1 + i % 2, i * 0.27)
	else:
		# Equivalent sources/widths through the actual old motion path.
		for i in range(3): fx._emit(2, Vector2(975 if kind == "blower" else 735, 140 + i * 8), 16)

func v2_scenario(kind: String, zoom: float, enabled: bool) -> void:
	controller.reset_surface()
	camera.reset_view()
	main.feedback.debris_physics_enabled = enabled
	prepare_v2(kind)
	controller._focused = true
	controller._pointer_inside = true
	select(2 if kind == "blower" else 1)
	var center := Vector2(980, 140) if kind == "blower" else CENTER
	move_to((center + Vector2.ONE * 0.5) / Vector2(block.map_resolution))
	if zoom == 3: await settle_zoom(zoom)
	for i in range(60): await physics_frame
	var height_before := block.working_map.image.get_data()
	if kind in ["deep_cavity", "max_fragments", "blower"]: top_up(kind, enabled)
	if kind == "blower":
		# Start with real sleeping chunks, not a flying-only shortcut.
		for i in range(90): main.feedback._physics_process(1.0 / 60)
	var initial_sleeping: int = main.feedback.terrain_debris.sleeping_count
	main.feedback._process(0) # Drain setup samples before per-render-frame metrics.
	# on_frame runs before the next view update: do not record that setup frame.
	main.feedback.terrain_samples_last_frame = 0
	frame_times.clear()
	sim_times.clear()
	jet_times.clear()
	multi_times.clear()
	samples_frame.clear()
	max_samples_tick = 0
	max_active = 0
	max_sleeping = initial_sleeping
	previous_frame = 0
	var chunks := 0
	var edits := 0
	var started := Time.get_ticks_usec()
	measuring = true
	press_at((center + Vector2.ONE * 0.5) / Vector2(block.map_resolution))
	for tick in range(360):
		var elapsed := controller.impact_clock.elapsed
		var impacts := controller.impact_clock.emitted
		await physics_frame
		controller.impact_clock.elapsed = elapsed
		controller.impact_clock.emitted = impacts
		controller._focused = true
		controller._pointer_inside = true
		controller._held = kind in ["flat_clay", "flat_stone", "cavity_edge", "blower"]
		var point := center
		if kind.begins_with("flat_"): point.x += (tick / 120 as int - 1) * 25
		if kind == "cavity_edge": point = Vector2(703, 104 + (tick / 120 as int) * 27)
		if kind == "blower": point += Vector2(18 * sin(tick / 45.0), 25 * cos(tick / 37.0))
		move_to((point + Vector2.ONE * 0.5) / Vector2(block.map_resolution))
		controller._physics_process(1.0 / 60)
		if kind in ["max_fragments", "deep_cavity", "blower"] and tick % 60 == 0: top_up(kind, enabled)
		main.feedback._physics_process(1.0 / 60)
		var sim: TerrainDebris = main.feedback.terrain_debris
		sim_times.append(sim.last_step_usec)
		if kind == "blower": jet_times.append(sim.last_blower_usec)
		max_samples_tick = maxi(max_samples_tick, sim.last_samples)
		max_active = maxi(max_active, sim.active_count)
		max_sleeping = maxi(max_sleeping, sim.sleeping_count)
		edits += controller.changed_texels
		if controller.impacts_this_tick > 0: chunks += block.working_map.last_action.get("chunks", []).size()
	measuring = false
	var seconds := (Time.get_ticks_usec() - started) / 1e6
	controller.cancel_stroke()
	var sim: TerrainDebris = main.feedback.terrain_debris
	var label := "%s_%s_%dx" % [kind, "on" if enabled else "off", int(zoom)]
	var data := {"fps": frame_times.size() / seconds, "min_1s_fps": minimum_1s_fps(), "frame_ms": stats(frame_times),
		"simulation_us": stats(sim_times), "blower_us": stats(jet_times), "multimesh_us": stats(multi_times),
		"samples_frame": stats(samples_frame), "max_samples_tick": max_samples_tick,
		"max_active": max_active, "max_sleeping": max_sleeping, "initial_sleeping": initial_sleeping,
		"spawned": sim.emitted_count, "skipped": sim.skipped_count, "recycled": sim.recycled_count,
		"ejected": sim.ejected_count, "chunks": chunks, "edited_cells": edits, "impacts": controller.total_impacts,
		"seconds": seconds, "physics_on": enabled, "zoom": camera.zoom_factor}
	check(data.fps >= 60 and data.min_1s_fps >= 60 and data.frame_ms.p95 < 16.67, "dedicated performance budget: " + label)
	check(absf(camera.zoom_factor - zoom) < 0.001 and data.fps <= 241, "zoom and 240 FPS cap: " + label)
	check(max_active <= 48 and max_samples_tick <= 48 * 11, "bounded simulation: " + label)
	if kind in ["flat_clay", "flat_stone", "cavity_edge"]:
		check(chunks > 0 and edits > 0 and controller.total_impacts == 27, "27 real Chisel impacts fracture matrix: " + label)
	else:
		check(height_before == block.working_map.image.get_data(), "feedback never edits geometry: " + label)
	if enabled:
		check(max_active > 0, "physics exercised: " + label)
		if kind in ["max_fragments", "deep_cavity", "blower"]: check(max_active == 48, "full cap exercised: " + label)
		if kind == "blower": check(initial_sleeping == 48 and data.ejected > 0, "Blower starts sleeping and ejects real chunks: " + label)
	report[label] = data
	print("P4V2 BENCH ", label, " ", JSON.stringify(data))
	await screenshot("p4v2-" + label)

func visual_sequence() -> void:
	controller.reset_surface()
	camera.reset_view()
	main.feedback.debris_physics_enabled = true
	prepare_v2("deep_cavity")
	controller._focused = true
	controller._pointer_inside = true
	move_to((CENTER + Vector2.ONE * 0.5) / Vector2(block.map_resolution))
	await settle_zoom(3)
	controller.hit = {"inside": false}
	block.show_cursor(controller.hit, 40)
	var fx: MaterialFeedback = main.feedback
	fx.set_process(false)
	var p := Vector2(700, 140)
	var uv := (p + Vector2.ONE * 0.5) / Vector2(block.map_resolution)
	var at := Vector3((uv.x - 0.5) * block.surface_size.x, block.relief.height_at(uv) + 0.012, (uv.y - 0.5) * block.surface_size.y)
	for i in range(8): fx.terrain_debris.spawn(at + Vector3(0, i * 0.001, (i - 4) * 0.005),
		Vector3(0.11, 0.045, 0), Vector3(0.0055, 0.00385, 0.0055), 2, i * 0.2)
	fx._process(0)
	await screenshot("p4v2-cavity-launch")
	for i in range(18): fx._physics_process(1.0 / 60)
	fx._process(0)
	await screenshot("p4v2-cavity-fall")
	for i in range(90): fx._physics_process(1.0 / 60)
	fx._process(0)
	check(fx.terrain_debris.sleeping_count == 8, "rendered cavity sequence settles all eight chunks")
	await screenshot("p4v2-cavity-sleep")
	var sim := fx.terrain_debris
	var first := sim.fragments[0]
	var floor_y := block.relief.height_at(SurfaceMapping.local_to_uv(first.position, block.surface_size))
	check(first.position.y < at.y - 0.05 and absf(first.position.y - first.support_height() - floor_y) < 0.0003,
		"rendered chunk sits on cavity floor 50+ mm below launch")
	var point := SurfaceMapping.local_to_uv(first.position, block.surface_size) * Vector2(block.map_resolution) - Vector2.ONE * 0.5
	block.working_map.apply_continuous(point - Vector2.RIGHT, point, controller.tools[2], 0.12)
	for i in range(12): fx._physics_process(1.0 / 60)
	fx._process(0)
	check(first.velocity.x > 0 and first.state != TerrainDebris.State.SLEEPING, "rendered clean-cavity Blower wakes and displaces")
	await screenshot("p4v2-cavity-blower")
	fx.set_process(true)
	controller.reset_surface()
	camera.reset_view()
	for i in range(30): await physics_frame
	main.get_node("Debug/Panel").show()
	main.get_node("Debug/BonePanel").show()
	move_to((Vector2(250, 230) + Vector2.ONE * 0.5) / Vector2(block.map_resolution))
	controller._focused = true
	controller._pointer_inside = true
	controller.refresh_view()
	check(controller.hit.inside, "F1 capture includes full hovered-material/Bone diagnostics")
	main._process(0.2)
	await screenshot("p4v2-debug")
	check(main.debug_panel.get_global_rect().end.y < 960, "F1 diagnostics remain above toolbar")

func run() -> void:
	if DisplayServer.get_name() == "headless": quit(1); return
	DirAccess.make_dir_recursive_absolute("res://work/test-logs")
	root.size = Vector2i(1920, 1080)
	root.content_scale_size = root.size
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	AudioServer.set_bus_mute(0, true)
	process_frame.connect(on_frame)
	main = load("res://scenes/prototype_main.tscn").instantiate()
	root.add_child(main)
	block = main.block
	controller = main.controller
	camera = main.camera
	controller.set_physics_process(false)
	main.feedback.set_physics_process(false)
	for node in ["Debug/Panel", "Debug/BonePanel", "Debug/BoneNotice"]: main.get_node(node).hide()
	if not "--visual-only" in OS.get_cmdline_user_args():
		for zoom in [1.0, 3.0]:
			for kind in ["flat_clay", "flat_stone", "deep_cavity", "max_fragments", "cavity_edge", "blower"]:
				if "--blower-only" in OS.get_cmdline_user_args() and kind != "blower": continue
				for enabled in [false, true]: await v2_scenario(kind, zoom, enabled)
	await visual_sequence()
	report["checks"] = bench_checks
	report["failures"] = failures
	report["gpu"] = RenderingServer.get_video_adapter_name()
	report["cpu"] = OS.get_processor_name()
	report["godot"] = Engine.get_version_info().string
	report["cap"] = Engine.max_fps
	report["physics_hz"] = Engine.physics_ticks_per_second
	var output := "p4v2-visual" if "--visual-only" in OS.get_cmdline_user_args() else "p4v2-benchmark"
	if "--blower-only" in OS.get_cmdline_user_args(): output = "p4v2-blower-benchmark"
	FileAccess.open("res://work/test-logs/" + output + ".json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("P4V2 GRAPHICAL: %d checks, %d failures" % [bench_checks, failures])
	main.free()
	await process_frame
	quit(0 if failures == 0 else 1)
