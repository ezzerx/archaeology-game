extends SceneTree
## P3 follow-up: fixed orthographic zoom, exact picking and robust input.

var checks := 0
var failures := 0
var evidence := {}

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + message)

func wheel(position: Vector2, steps: float, shift := false, ctrl := false, alt := false) -> void:
	var event := InputEventMouseButton.new()
	event.position = position
	event.button_index = MOUSE_BUTTON_WHEEL_UP if steps > 0 else MOUSE_BUTTON_WHEEL_DOWN
	event.factor = absf(steps)
	event.pressed = true
	event.shift_pressed = shift
	event.ctrl_pressed = ctrl
	event.alt_pressed = alt
	root.push_input(event, true)

func key(code: Key, shift := false, ctrl := false) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	event.shift_pressed = shift
	event.ctrl_pressed = ctrl
	root.push_input(event, true)

func test_zoom() -> void:
	root.size = Vector2i(1920, 1080)
	var main := load("res://scenes/prototype_main.tscn").instantiate() as Node3D
	root.add_child(main)
	var block: ExcavationBlock = main.get_node("ExcavationBlock")
	var controller: ToolController = main.get_node("ToolController")
	var camera: PrecisionZoom = main.get_node("Camera3D")
	controller.set_physics_process(false)
	camera.set_process(false)
	await process_frame
	var basis := camera.global_basis
	var home := camera.global_position
	# Existing P1/P3 geometry fixture: slopes, protruding bones and adjacent floor.
	block.working_map.apply_segment(Vector2(265, 215), Vector2(310, 235), 90, 100, 1.5, 1)
	block.flush_texture()
	var terrain := block.working_map.image.get_data()
	var worst_anchor := 0.0
	var worst_ray := 0.0
	var rays := 0
	var bone_hits := 0
	var floor_hits := 0
	var slope_hits := 0
	for window_size in [Vector2i(1920, 1080), Vector2i(1280, 800), Vector2i(800, 1200), Vector2i(2560, 1080)]:
		root.size = window_size
		await process_frame
		controller._focused = true
		controller._pointer_inside = true
		camera._focused = true
		for uv in [Vector2(0.5, 0.5), Vector2(0.02, 0.03), Vector2(0.98, 0.97), Vector2(0.28, 0.305)]:
			for factor in [1.0, 1.5, 2.0, 3.0]:
				camera.reset_view()
				var local := Vector3((uv.x - 0.5) * block.surface_size.x, block.relief.height_at(uv), (uv.y - 0.5) * block.surface_size.y)
				var screen := camera.unproject_position(block.to_global(local))
				if not root.get_visible_rect().has_point(screen): continue
				var anchor := block.pick(screen, camera)
				check(anchor.inside, "zoom starts on a valid first hit")
				if not anchor.inside: continue
				camera.request_zoom(log(factor) / log(camera.wheel_step), screen)
				for i in range(150):
					camera._process(1.0 / 120.0)
					worst_anchor = maxf(worst_anchor, camera.unproject_position(anchor.world).distance_to(screen))
				check(absf(camera.zoom_factor - factor) < 0.0001, "requested zoom converges at resized viewport")
				for dy in range(-60, 61, 15):
					for dx in range(-60, 61, 15):
						var probe := screen + Vector2(dx, dy)
						var hit := block.pick(probe, camera)
						if not hit.inside: continue
						var projected := camera.unproject_position(hit.world)
						var again := block.pick(projected, camera)
						if not again.inside:
							worst_ray = INF
						else:
							worst_ray = maxf(worst_ray, hit.world.distance_to(again.world))
						rays += 1
						if hit.bone_exposed: bone_hits += 1
						elif hit.height < 0.0001: floor_hits += 1
						elif hit.height < 0.999: slope_hits += 1
	check(worst_anchor < 0.002, "cursor anchor stable throughout interpolation, including slopes/bone")
	check(worst_ray < 0.00001 and rays > 1500 and bone_hits > 10 and floor_hits > 10 and slope_hits > 10,
		"zoom roundtrips cover centre, block edges, slopes, bones and cavity floor")
	check(camera.global_basis.is_equal_approx(basis) and camera.projection == Camera3D.PROJECTION_ORTHOGONAL,
		"orientation 84 degrees and orthographic projection unchanged at every zoom")
	print("P3 ZOOM: %d rays, bone %d / floor %d / slopes %d; anchor %.6f px, ray %.8f m" % [
		rays, bone_hits, floor_hits, slope_hits, worst_anchor, worst_ray])
	evidence["zoom"] = {"rays": rays, "bone_hits": bone_hits, "floor_hits": floor_hits,
		"slope_hits": slope_hits, "anchor_max_pixels": worst_anchor, "roundtrip_max_m": worst_ray,
		"zoom_levels": [1, 1.5, 2, 3], "native_window_sizes": ["1920x1080", "1280x800", "800x1200", "2560x1080"],
		"logical_viewport": str(root.get_visible_rect().size)}
	var settled_changes := [0]
	camera.view_changed.connect(func(): settled_changes[0] += 1)
	for i in range(60): camera._process(1.0 / 60.0)
	check(settled_changes[0] == 0, "settled zoom stops redundant projection and picking updates")
	root.size = Vector2i(1920, 1080)
	await process_frame
	camera.reset_view()
	camera._focused = true
	controller._focused = true
	controller._pointer_inside = true
	var screen := camera.unproject_position(Vector3(0, block.thickness, 0))
	var original := Vector3(controller.config.radius, controller.config.power, controller.config.falloff)
	controller._held = true
	wheel(screen, 1)
	check(camera.target_zoom > 1 and camera.zoom_factor == 1 and not controller._held, "wheel starts smooth zoom and cancels held excavation")
	camera._process(1.0 / 60.0)
	check(camera.zoom_factor > 1 and camera.zoom_factor < camera.target_zoom, "zoom interpolates rather than snapping")
	check(Vector3(controller.config.radius, controller.config.power, controller.config.falloff) == original,
		"plain wheel never changes tool tuning")
	var zoom_before_tuning := camera.target_zoom
	for modifiers in [Vector3i(1, 0, 0), Vector3i(0, 1, 0), Vector3i(0, 0, 1)]:
		controller._held = true
		wheel(screen, 1, modifiers.x != 0, modifiers.y != 0, modifiers.z != 0)
		var expected := original + Vector3(modifiers.z * 2.0, modifiers.x * 0.1, modifiers.y * 0.25)
		check(Vector3(controller.config.radius, controller.config.power, controller.config.falloff).is_equal_approx(expected),
			"modified wheel changes only its assigned tool parameter: " + str(modifiers))
		check(camera.target_zoom == zoom_before_tuning and not controller._held,
			"modified wheel does not zoom and cancels the stroke")
		wheel(screen, -1, modifiers.x != 0, modifiers.y != 0, modifiers.z != 0)
		check(Vector3(controller.config.radius, controller.config.power, controller.config.falloff).is_equal_approx(original),
			"wheel-down reverses wheel-up tuning")
	wheel(screen, 2, true, true, true)
	check(is_equal_approx(controller.config.power, original.y + 0.2)
		and controller.config.radius == original.x and controller.config.falloff == original.z,
		"combined modifiers prioritize Shift and honor wheel factor")
	wheel(screen, -2, true)
	wheel(screen, 1, false, true, true)
	check(controller.config.falloff == original.z + 0.25 and controller.config.radius == original.x,
		"Ctrl takes priority over Alt")
	wheel(screen, -1, false, true)
	var defaults: ToolDefinition = load("res://config/soft_brush.tres")
	check(Vector3(defaults.radius, defaults.power, defaults.falloff) == original,
		"debug tuning never mutates default tool resources")
	wheel(screen, 100)
	check(camera.target_zoom == camera.max_zoom, "zoom-in limit is 3x")
	wheel(screen, -100)
	check(camera.target_zoom == 1, "zoom-out limit is 1x")
	key(KEY_F7)
	check(controller.config.radius == original.x + 2, "developer F7 controls radius")
	key(KEY_F6)
	key(KEY_F7, true)
	check(is_equal_approx(controller.config.power, original.y + 0.1), "developer Shift+F7 controls power")
	key(KEY_F6, true)
	key(KEY_F7, false, true)
	check(controller.config.falloff == original.z + 0.25, "developer Ctrl+F7 controls falloff")
	key(KEY_F6, false, true)
	camera.request_zoom(4, screen)
	camera._process(0.05)
	controller._held = true
	controller._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
	camera._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
	var frozen := camera.size
	camera._process(1)
	wheel(screen, 1)
	wheel(screen, 1, true)
	wheel(screen, 1, false, true)
	wheel(screen, 1, false, false, true)
	check(Vector3(controller.config.radius, controller.config.power, controller.config.falloff).is_equal_approx(original),
		"focus loss ignores all modified wheel tuning")
	check(camera.size == frozen and not controller._held, "focus loss freezes zoom and cancels excavation")
	camera._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_IN)
	controller._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_IN)
	camera._process(1)
	check(camera.size == frozen and not controller._held, "focus return never resumes pending zoom/stroke")
	key(KEY_HOME)
	check(camera.zoom_factor == 1 and camera.global_position.is_equal_approx(home), "Home restores exact overview without resetting terrain")
	check(block.working_map.image.get_data() == terrain, "zoom, developer shortcuts and focus never excavate by themselves")
	camera.request_zoom(4, screen)
	camera._process(0.05)
	controller._held = true
	root.size = Vector2i(1280, 720)
	await process_frame
	await process_frame
	# Automatic processing is disabled in this deterministic fixture.
	camera._process(1.0 / 60.0)
	controller._physics_process(1.0 / 60.0)
	check(not controller._held and is_equal_approx(camera.target_zoom, camera.zoom_factor), "resize cancels old gesture and pending zoom anchor")
	key(KEY_R)
	main._process(0.1)
	check(camera.zoom_factor == 1 and block.working_map.fossil.exposed_cells == 0
		and block.working_map.fossil.condition == 100,
		"R restores pristine specimen and overview")
	check(Engine.max_fps == 240 and Engine.physics_ticks_per_second == 60, "runtime 240 FPS / physics 60 Hz unchanged")
	main.queue_free()
	await process_frame

func run() -> void:
	await test_zoom()
	evidence["checks"] = checks
	evidence["failures"] = failures
	evidence["godot"] = Engine.get_version_info().string
	evidence["runtime_cap"] = Engine.max_fps
	evidence["physics_hz"] = Engine.physics_ticks_per_second
	DirAccess.make_dir_recursive_absolute("res://work/test-logs")
	var file := FileAccess.open("res://work/test-logs/p3-zoom-tests.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(evidence, "\t"))
	file.close()
	print("P3 ZOOM TESTS: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
