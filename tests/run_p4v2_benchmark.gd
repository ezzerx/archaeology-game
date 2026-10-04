extends "res://tests/run_p4_benchmark.gd"
## Persistent crumb benchmarks: real ownership, fixed ticks, real 1080p renderer.
const CENTER := Vector2(740, 140)
var sim_times: Array[float] = []
var jet_times: Array[float] = []
var multi_times: Array[float] = []
var samples_frame: Array[float] = []
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
		multi_times.append(main.feedback.loose_view.last_update_usec)
		samples_frame.append(block.working_map.loose_debris.samples_last_frame)

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
	for y in range(40, 321):
		for x in range(540, 1024):
			var height := 0.60 if kind == "chisel_clay" else 0.22
			if kind == "cavity": height = 0.72 if x < 705 else 0.06
			var index := y * s.size.x + x
			var ceiling := s.fossil.field.ceilings[index]
			s._heights[index] = maxf(height, ceiling)
			if ceiling > 0 and s._heights[index] <= ceiling + FossilField.EXPOSURE_EPSILON: exposed.append(index)
	s.image.set_data(s.size.x, s.size.y, false, Image.FORMAT_RF, s._heights.to_byte_array())
	s.dirty = true
	s.fossil.expose_cells(exposed)
	block.flush_texture()
	main.feedback.reset()

func local_at(point: Vector2) -> Vector3:
	var uv := (point + Vector2.ONE * 0.5) / Vector2(block.map_resolution)
	return Vector3((uv.x - 0.5) * block.surface_size.x, block.relief.height_at(uv), (uv.y - 0.5) * block.surface_size.y)

func seed_crumbs(count: int, kind: String) -> void:
	var dirt := block.working_map.loose_debris
	# Sources obey real local spawn budgets. Stress positions intentionally pack
	# the cap into one jet/Brush footprint after leaving their source buckets.
	for i in range(count):
		var bx := (i / 2 as int) % 8
		var by := i / 16 as int
		dirt.deposit_removed(552 + bx * 24 + i % 2 * 8, 48 + by * 24, 16, 1 + i % 2)
	var index := 0
	for key: Vector3i in dirt.cells:
		var center := Vector2(980, 140) if kind == "blower_cap" else CENTER
		var p := center + Vector2((index % 16 - 7.5) * 3.2, (index / 16 as int - 3.5) * 5.0)
		if dirt.physics_enabled:
			var f := dirt.physics.fragments[dirt.physical_slots[key]]
			f.position = local_at(p) + Vector3.UP * (0.080 if kind == "cavity" else 0.004)
			f.velocity = Vector3.ZERO
			f.angular_velocity = 0
		else: dirt._rest_points[key] = p
		dirt.dirty_cells[key] = true
		index += 1

func v2_scenario(kind: String, zoom: float, enabled: bool) -> void:
	controller.reset_surface()
	camera.reset_view()
	main.feedback.crumb_physics_enabled = enabled
	prepare_v2(kind)
	controller._focused = true
	controller._pointer_inside = true
	select(2 if kind == "blower_cap" else (0 if kind == "brush_cleanup" else 1))
	var center := Vector2(980, 140) if kind == "blower_cap" else CENTER
	move_to((center + Vector2.ONE * 0.5) / Vector2(block.map_resolution))
	if zoom == 3: await settle_zoom(zoom)
	for i in range(30): await physics_frame
	var count := 0 if kind == "zero" or kind.begins_with("chisel_") else (32 if kind == "count32" else (64 if kind == "count64" else 128))
	seed_crumbs(count, kind)
	var dirt := block.working_map.loose_debris
	if kind in ["blower_cap", "brush_cleanup"]:
		for i in range(120): dirt.advance(1.0 / 60)
	var initial_sleeping := dirt.physics.sleeping_count
	var initial_amount := 0.0
	for amount in dirt.cells.values(): initial_amount += amount
	var exits: Array = []
	var capture_exit := func(at, direction, amount, material): exits.append([at, direction, amount, material])
	block.debris_ejected.connect(capture_exit)
	var initial_height := block.working_map.image.get_data()
	main.feedback.loose_view._process(0)
	dirt.samples_last_frame = 0
	# Drain setup-induced catch-up before timed physics/render intervals.
	for settle_frame in range(6): await physics_frame
	frame_times.clear()
	sim_times.clear()
	jet_times.clear()
	multi_times.clear()
	samples_frame.clear()
	previous_frame = 0
	var max_samples := 0
	var max_count := dirt.persistent_count()
	var max_moving := dirt.moving_count()
	var edits := 0
	var chunks := 0
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
		controller._held = kind.begins_with("chisel_") or kind in ["blower_cap", "brush_cleanup"]
		var point := center
		if kind.begins_with("chisel_"): point.x += (tick / 120 as int - 1) * 25
		move_to((point + Vector2.ONE * 0.5) / Vector2(block.map_resolution))
		# Fix a rightwards jet with the real production tool capsule/radius.
		if kind == "blower_cap":
			controller._previous = point - Vector2.RIGHT
			controller._previous_valid = true
		controller._physics_process(1.0 / 60)
		sim_times.append(dirt.physics.last_step_usec)
		if kind == "blower_cap": jet_times.append(dirt.physics.last_blower_usec)
		max_samples = maxi(max_samples, dirt.physics.last_samples)
		max_count = maxi(max_count, dirt.persistent_count())
		max_moving = maxi(max_moving, dirt.moving_count())
		edits += controller.changed_texels
		if controller.impacts_this_tick > 0: chunks += block.working_map.last_action.get("chunks", []).size()
	measuring = false
	var seconds := (Time.get_ticks_usec() - started) / 1e6
	controller.cancel_stroke()
	block.debris_ejected.disconnect(capture_exit)
	var exited_amount := 0.0
	for event in exits: exited_amount += event[2]
	var remaining_amount := 0.0
	for amount in dirt.cells.values(): remaining_amount += amount
	for packet in dirt.flying: remaining_amount += packet.amount
	var label := "%s_%s_%dx" % [kind, "on" if enabled else "off", int(zoom)]
	var data := {"fps": frame_times.size() / seconds, "min_1s_fps": minimum_1s_fps(), "frame_ms": stats(frame_times),
		"simulation_us": stats(sim_times), "blower_us": stats(jet_times), "multimesh_us": stats(multi_times),
		"samples_frame": stats(samples_frame), "max_samples_tick": max_samples, "max_crumbs": max_count,
		"max_moving": max_moving, "initial_sleeping": initial_sleeping, "remaining": dirt.persistent_count(),
		"ejected": exits.size(), "initial_amount": initial_amount, "exited_amount": exited_amount,
		"remaining_amount": remaining_amount, "chunks": chunks, "edited_cells": edits,
		"impacts": controller.total_impacts, "seconds": seconds, "physics_on": enabled, "zoom": camera.zoom_factor}
	check(data.fps >= 60 and data.min_1s_fps >= 60 and data.frame_ms.p95 < 16.67, "performance budget: " + label)
	check(absf(camera.zoom_factor - zoom) < 0.001 and data.fps <= 241, "zoom and 240 FPS cap: " + label)
	check(max_count <= 128 and max_samples <= 128 * 11, "bounded persistent state/sampling: " + label)
	if kind.begins_with("chisel_"):
		check(chunks > 0 and edits > 0 and controller.total_impacts == 27, "27 real P4-V1 Chisel impacts: " + label)
	else:
		check(initial_height == block.working_map.image.get_data(), "no structural change: " + label)
		check(max_count == count, "requested crumb count exercised: " + label)
	if kind == "blower_cap":
		check(exits.size() > 0 and dirt.persistent_count() == 0, "Blower expels the full persistent cap: " + label)
		check(absf(initial_amount - exited_amount - remaining_amount) < 0.00001, "ejection amount conservation: " + label)
		if enabled: check(initial_sleeping == 128 and max_moving == 128, "full cap wakes from sleep: " + label)
	if kind == "brush_cleanup": check(dirt.persistent_count() == 0, "Brush cleans the cap: " + label)
	if kind in ["count32", "count64", "cap", "cavity"]: check(dirt.persistent_count() == count, "no timed disappearance: " + label)
	report[label] = data
	# Persist each completed measurement before any later graphical readback.
	FileAccess.open("res://work/test-logs/p4v2-crumbs-benchmark-progress.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("P4V2 CRUMBS BENCH ", label, " ", JSON.stringify(data))

func step_visual(ticks: int) -> void:
	for i in range(ticks):
		block.working_map.loose_debris.advance(1.0 / 60)
		main.feedback._process(1.0 / 60)
	main.feedback.loose_view._process(0)

func visual_sequence() -> void:
	controller.reset_surface()
	camera.reset_view()
	main.feedback.crumb_physics_enabled = true
	prepare_v2("chisel_clay")
	controller._focused = true
	controller._pointer_inside = true
	select(1)
	move_to((CENTER + Vector2.ONE * 0.5) / Vector2(block.map_resolution))
	await settle_zoom(3)
	main.feedback.set_process(false)
	main.feedback.loose_view.set_process(false)
	for i in range(5):
		block.working_map.apply_impact(CENTER, controller.tools[1])
		if main.feedback.particles[1].size() > 5: break
	block.flush_texture()
	step_visual(5)
	await screenshot("p4v2-crumbs-chisel-flight")
	controller.hit = {"inside": false}
	block.show_cursor(controller.hit, 40)
	step_visual(150)
	var dirt := block.working_map.loose_debris
	check(main.feedback.particles[1].is_empty() and main.feedback.particles[2].is_empty() and dirt.cells.size() > 0,
		"rendered aftermath has persistent crumbs but no large transient cubes")
	await screenshot("p4v2-crumbs-aftermath")
	# Synthetic ledge: eight small retained crumbs cross into the lower cavity.
	controller.reset_surface()
	prepare_v2("cavity")
	controller.hit = {"inside": false}
	block.show_cursor(controller.hit, 40)
	main.get_node("Debug/BoneNotice").hide()
	seed_crumbs(8, "cap")
	var start := local_at(Vector2(699, 140)) + Vector3.UP * 0.003
	var i := 0
	for f in dirt.physics.fragments:
		if not f.active: continue
		f.position = start + Vector3(0, 0, (i - 4) * 0.006)
		f.velocity = Vector3(0.11, 0.025, 0)
		f.angular_velocity = 4
		dirt.dirty_cells[f.source] = true
		i += 1
	step_visual(1)
	await screenshot("p4v2-crumbs-cavity-launch")
	step_visual(18)
	await screenshot("p4v2-crumbs-cavity-fall")
	step_visual(110)
	check(dirt.physics.sleeping_count == 8, "eight rendered crumbs settle in cavity")
	await screenshot("p4v2-crumbs-cavity-sleep")
	var first := dirt.physics.fragments[0]
	var floor_y := block.relief.height_at(SurfaceMapping.local_to_uv(first.position, block.surface_size))
	check(first.position.y < start.y - 0.05 and absf(first.position.y - first.support_height() - floor_y) < 0.0003,
		"rendered crumb reaches cavity floor 50+ mm below source")
	# Validate real GPU transforms after complete rendered frames, not headless dummy data.
	var poses_match := true
	var small := true
	for key: Vector3i in dirt.physical_slots:
		var f := dirt.physics.fragments[dirt.physical_slots[key]]
		var pose: Transform3D = main.feedback.loose_view.multimesh.get_instance_transform(main.feedback.loose_view.slots[key])
		poses_match = poses_match and block.to_local(pose.origin).is_equal_approx(f.position)
		small = small and pose.basis.x.length() <= 0.002201 and pose.basis.y.length() <= 0.000705
	check(poses_match and small, "GPU crumb transforms match physical XYZ, width <=2.2 mm, no cuboids")
	var positions: Array[Vector3] = []
	for f in dirt.physics.fragments:
		if f.active: positions.append(f.position)
	step_visual(1800)
	var stable := dirt.physics.active_count == 8 and dirt.cells.size() == 8
	i = 0
	for f in dirt.physics.fragments:
		if not f.active: continue
		stable = stable and f.position == positions[i]
		i += 1
	check(stable, "rendered persistent crumbs stay unchanged after 30 seconds without cleanup")
	await screenshot("p4v2-crumbs-cavity-30s")
	var point := dirt.point_for(first.source)
	block.working_map.apply_continuous(point - Vector2.RIGHT, point, controller.tools[2], 0.12)
	step_visual(8)
	check(first.velocity.x > 0 and first.state != TerrainDebris.State.SLEEPING, "real clean-cavity Blower wakes and displaces crumbs")
	await screenshot("p4v2-crumbs-cavity-blower")
	# Moved-location Brush test, visible on the same GPU-backed scene.
	point = dirt.point_for(first.source)
	var shape: ToolDefinition = controller.tools[0].duplicate()
	shape.radius = 4
	dirt.clean(point, point, shape, 1)
	main.feedback.loose_view._process(0)
	await screenshot("p4v2-crumbs-cavity-brush")
	check(not first.active, "Brush removes current physical crumb and rendered slot")
	main.feedback.set_process(true)
	main.feedback.loose_view.set_process(true)
	controller.reset_surface()
	camera.reset_view()
	for frame in range(30): await physics_frame
	main.get_node("Debug/Panel").show()
	main.get_node("Debug/BonePanel").show()
	move_to((Vector2(250, 230) + Vector2.ONE * 0.5) / Vector2(block.map_resolution))
	controller._focused = true
	controller._pointer_inside = true
	controller.refresh_view()
	main._process(0.2)
	await screenshot("p4v2-crumbs-debug")
	check(main.debug_panel.get_global_rect().end.y < 960 and "Crumb Physics:" in main.debug_label.text,
		"F1 persistent crumb diagnostics fit above toolbar")

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
	for node in ["Debug/Panel", "Debug/BonePanel", "Debug/BoneNotice"]: main.get_node(node).hide()
	if not "--visual-only" in OS.get_cmdline_user_args():
		for zoom in [1.0, 3.0]:
			for kind in ["zero", "count32", "count64", "cap", "cavity", "blower_cap", "brush_cleanup", "chisel_clay", "chisel_stone"]:
				if "--blower-only" in OS.get_cmdline_user_args() and kind != "blower_cap": continue
				for enabled in [false, true]: await v2_scenario(kind, zoom, enabled)
	else: await visual_sequence()
	report["checks"] = bench_checks
	report["failures"] = failures
	report["gpu"] = RenderingServer.get_video_adapter_name()
	report["cpu"] = OS.get_processor_name()
	report["godot"] = Engine.get_version_info().string
	report["cap"] = Engine.max_fps
	report["physics_hz"] = Engine.physics_ticks_per_second
	var output := "p4v2-crumbs-visual" if "--visual-only" in OS.get_cmdline_user_args() else "p4v2-crumbs-benchmark"
	if "--blower-only" in OS.get_cmdline_user_args(): output = "p4v2-crumbs-blower-benchmark"
	FileAccess.open("res://work/test-logs/" + output + ".json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("P4V2 CRUMBS GRAPHICAL: %d checks, %d failures" % [bench_checks, failures])
	main.queue_free()
	await create_timer(0.4).timeout
	quit(0 if failures == 0 else 1)
