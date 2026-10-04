extends "res://tests/run_p2_benchmark.gd"
## Paired deterministic Brush inputs. Same surface/FX with only proxy+fit off.
## -- --baseline saves the pre-fix profile without imposing post-fix budgets.
var cpu: Dictionary = {}
var endpoints: Dictionary = {}

func record(key: String, value: float) -> void:
	if not cpu.has(key): cpu[key] = [] as Array[float]
	cpu[key].append(value)

func on_frame() -> void:
	super.on_frame()
	if measuring:
		record("proxy_usec", main.feedback.last_proxy_usec)
		record("particles_usec", main.feedback.last_particles_usec)
		record("debris_view_usec", main.feedback.loose_view.last_update_usec)

func brush_case(kind: String, zoom: float, enabled: bool) -> void:
	controller.reset_surface()
	(camera as PrecisionZoom).reset_view()
	main.feedback.proxies_enabled = enabled
	controller._focused = true
	controller._pointer_inside = true
	controller.select_tool(0)
	var center := Vector2(0.70, 0.22)
	if kind == "dug":
		var p := SurfaceMapping.uv_to_map(center, block.map_resolution)
		block.working_map.apply_segment(p, p, 65, 2, 1.5, 1)
		block.flush_texture()
	move_to(center)
	if zoom > 1:
		(camera as PrecisionZoom)._focused = true
		(camera as PrecisionZoom).request_zoom(log(zoom) / log((camera as PrecisionZoom).wheel_step), controller._screen)
	for i in range(60): await physics_frame
	press_at(center)
	# Same work is replayed even when render throughput differs.
	var ticks := 1800 if kind == "moving_soil" else 360
	cpu.clear()
	frame_times.clear()
	previous_frame = 0
	measuring = true
	var started := Time.get_ticks_usec()
	var changed := 0
	var cancelled_sweeps := 0
	for tick in range(ticks):
		# Preserve the fixed synthetic sweep across native focus/mouse-exit
		# notifications, just as the impact harness preserves its held clock.
		var previous_valid := controller._previous_valid
		await physics_frame
		if previous_valid and not controller._previous_valid: cancelled_sweeps += 1
		controller._previous_valid = previous_valid
		controller._focused = true
		controller._pointer_inside = true
		controller._held = true
		var uv := center
		if kind != "stationary": uv += Vector2(0.065 * sin(tick / 80.0), 0.07 * cos(tick / 67.0))
		move_to(uv)
		main.feedback.last_action_usec = 0
		controller._physics_process(1.0 / 60.0)
		record("edit_usec", controller.last_edit_usec)
		record("surface_edit_usec", block.working_map.last_edit_usec)
		record("height_upload_usec", block.last_upload_usec)
		record("residue_upload_usec", block.last_residue_upload_usec)
		record("upload_usec", block.last_upload_usec + block.last_residue_upload_usec + block.last_fracture_upload_usec)
		record("action_feedback_usec", main.feedback.last_action_usec)
		record("pick_usec", controller.last_pick_usec)
		changed += controller.changed_texels
	measuring = false
	var seconds := (Time.get_ticks_usec() - started) / 1e6
	controller.cancel_stroke()
	var label := "%s_%dx_%s" % [kind, int(zoom), "on" if enabled else "off"]
	var data := {"render_fps": frame_times.size() / seconds, "frame_ms": stats(frame_times), "ticks": ticks,
		"elapsed_seconds": seconds, "changed_texels": changed, "native_sweep_resets_ignored": cancelled_sweeps}
	for key in cpu: data[key] = stats(cpu[key])
	var endpoint := {"height": hash(block.working_map.image.get_data()), "residue": hash(block.working_map.residue.image.get_data()),
		"exposure": block.working_map.fossil.exposed_cells, "condition": block.working_map.fossil.condition,
		"debris": hash(block.working_map.loose_debris.cells)}
	data["endpoint"] = endpoint
	if enabled:
		endpoints[label] = endpoint
	else:
		check(endpoint == endpoints[label.trim_suffix("off") + "on"], "proxy A/B leaves exact gameplay state: " + label)
	report[label] = data
	print("BRUSH BENCH ", label, " ", JSON.stringify(data))

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://work/test-logs")
	if DisplayServer.get_name() == "headless":
		push_error("Brush A/B benchmark requires graphical rendering")
		quit(1)
		return
	check(Engine.max_fps == 240 and Engine.physics_ticks_per_second == 60, "runtime 240 FPS / 60 Hz unchanged")
	root.size = Vector2i(1920, 1080)
	root.content_scale_size = Vector2i(1920, 1080)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	AudioServer.set_bus_mute(0, true)
	process_frame.connect(on_frame)
	main = load("res://scenes/prototype_main.tscn").instantiate()
	root.add_child(main)
	block = main.block
	controller = main.controller
	camera = main.camera
	controller.set_physics_process(false)
	main.get_node("Debug/Panel").hide()
	main.get_node("Debug/BonePanel").hide()
	for i in range(90): await physics_frame
	for zoom in [1.0, 3.0]:
		for kind in ["stationary", "moving_soil", "dug"]:
			for enabled in [true, false]: await brush_case(kind, zoom, enabled)
	var baseline := "--baseline" in OS.get_cmdline_user_args()
	if not baseline:
		for zoom in [1, 3]:
			for kind in ["stationary", "moving_soil", "dug"]:
				var on: Dictionary = report["%s_%dx_on" % [kind, zoom]]
				var off: Dictionary = report["%s_%dx_off" % [kind, zoom]]
				# Ratios plus measured CPU cost, not CI/headless absolute FPS alone.
				check(on.render_fps >= off.render_fps * 0.8, "proxy throughput within 20% of disabled")
				check(on.proxy_usec.p95 < maxf(250, on.edit_usec.p95 * 0.05), "bounded proxy CPU contribution")
				check(on.render_fps >= 60, "local graphical 60 FPS minimum")
	report["gpu"] = RenderingServer.get_video_adapter_name()
	report["cpu"] = OS.get_processor_name()
	report["engine"] = Engine.get_version_info().string
	report["viewport"] = str(root.size)
	report["runtime_cap"] = Engine.max_fps
	report["physics_hz"] = Engine.physics_ticks_per_second
	report["failures"] = failures
	FileAccess.open("res://work/test-logs/p4-brush-%s.json" % ("before" if baseline else "after"), FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("P4 BRUSH A/B: %d failures" % failures)
	controller.reset_surface()
	main.queue_free()
	await create_timer(0.4).timeout
	quit(0 if failures == 0 else 1)
