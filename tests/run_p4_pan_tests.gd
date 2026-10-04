extends SceneTree
## P4 corrective pass: camera/input integration, including real DDA relief hits.

var checks := 0
var failures := 0
var rays := 0
var worst_ray := 0.0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + message)

func button(at: Vector2, code: MouseButton, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.position = at
	event.button_index = code
	event.pressed = pressed
	root.push_input(event, true)

func drag(at: Vector2) -> void:
	var event := InputEventMouseMotion.new()
	event.position = at
	event.button_mask = MOUSE_BUTTON_MASK_RIGHT
	root.push_input(event, true)

func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	root.push_input(event, true)

func run() -> void:
	root.size = Vector2i(1920, 1080)
	var main := load("res://scenes/prototype_main.tscn").instantiate() as Node3D
	root.add_child(main)
	var block: ExcavationBlock = main.get_node("ExcavationBlock")
	var controller: ToolController = main.get_node("ToolController")
	var camera: PrecisionZoom = main.get_node("Camera3D")
	controller.set_physics_process(false)
	camera.set_process(false)
	await process_frame
	var home := camera.global_transform
	# Slopes, exposed cranium and adjacent deep floor, with untouched edges.
	block.working_map.apply_segment(Vector2(265, 215), Vector2(310, 235), 90, 100, 1.5, 1)
	block.flush_texture()
	var terrain := block.working_map.image.get_data()
	var condition := block.working_map.fossil.condition
	for uv in [Vector2(0.5, 0.5), Vector2(0.03, 0.03), Vector2(0.97, 0.97),
			Vector2(0.28, 0.305), Vector2(0.34, 0.36)]:
		camera.reset_view()
		controller._focused = true
		controller._pointer_inside = true
		camera._focused = true
		var local := Vector3((uv.x - 0.5) * block.surface_size.x,
			block.relief.height_at(uv), (uv.y - 0.5) * block.surface_size.y)
		var screen := camera.unproject_position(block.to_global(local))
		camera.request_zoom(30, screen)
		for i in range(150): camera._process(1.0 / 60.0)
		var anchor := block.pick(screen, camera)
		check(anchor.inside, "pan starts on block centre/edge/bone/cavity")
		if not anchor.inside: continue
		controller._held = true
		button(screen, MOUSE_BUTTON_RIGHT, true)
		check(camera.panning and not controller._held, "RMB captures pan and cancels pending excavation")
		var moved := screen + Vector2(80, 45)
		drag(moved)
		check(camera.unproject_position(anchor.world).distance_to(moved) < 0.002,
			"3x drag follows the pointer directly without slipping")
		button(moved, MOUSE_BUTTON_LEFT, true)
		controller._physics_process(1.0 / 60.0)
		check(not controller._held, "LMB pressed during pan cannot excavate")
		button(moved, MOUSE_BUTTON_RIGHT, false)
		check(not camera.panning and not controller._held, "RMB release requires fresh LMB for excavation")
		camera.request_zoom(-2, moved)
		for i in range(150): camera._process(1.0 / 60.0)
		check(camera.unproject_position(anchor.world).distance_to(moved) < 0.003,
			"zoom after pan preserves the real relief anchor")
		for y in range(-60, 61, 15):
			for x in range(-60, 61, 15):
				var hit := block.pick(moved + Vector2(x, y), camera)
				if not hit.inside: continue
				var again := block.pick(camera.unproject_position(hit.world), camera)
				worst_ray = maxf(worst_ray, hit.world.distance_to(again.world)) if again.inside else INF
				rays += 1
	check(rays > 200 and worst_ray < 0.00001, "DDA picking stays exact after pan plus zoom")
	for motion in [Vector2(50000, 50000), Vector2(-50000, -50000),
			Vector2(50000, -50000), Vector2(-50000, 50000)]:
		var center := root.get_visible_rect().size * 0.5
		button(center, MOUSE_BUTTON_RIGHT, true)
		drag(center + motion)
		button(center + motion, MOUSE_BUTTON_RIGHT, false)
		var visible_hits := 0
		for y in range(30, 1080, 60):
			for x in range(30, 1920, 60):
				if block.pick(Vector2(x, y), camera).inside: visible_hits += 1
		check(visible_hits > 2, "extreme diagonal pan keeps a useful portion of block visible")
	check(camera.global_basis.is_equal_approx(home.basis)
		and camera.projection == Camera3D.PROJECTION_ORTHOGONAL, "pan never rotates or changes projection")
	var screen := root.get_visible_rect().size * 0.5
	button(screen, MOUSE_BUTTON_RIGHT, true)
	camera._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
	controller._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
	var frozen := camera.global_transform
	drag(screen + Vector2(120, 80))
	check(not camera.panning and camera.global_transform == frozen, "focus loss ends pan without later drift")
	camera._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_IN)
	controller._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_IN)
	drag(screen + Vector2(160, 90))
	check(not camera.panning and camera.global_transform == frozen, "focus return cannot resume stale RMB drag")
	button(screen, MOUSE_BUTTON_RIGHT, true)
	root.size = Vector2i(1280, 800)
	await process_frame
	camera._process(1.0 / 60.0)
	check(not camera.panning, "native resize ends captured pan")
	button(screen, MOUSE_BUTTON_RIGHT, true)
	camera._notification(Node.NOTIFICATION_WM_MOUSE_EXIT)
	check(not camera.panning, "leaving window cancels pan even without receiving release")
	key(KEY_HOME)
	check(camera.global_transform.is_equal_approx(home) and camera.zoom_factor == 1,
		"Home restores exact initial transform and zoom")
	check(block.working_map.image.get_data() == terrain and block.working_map.fossil.condition == condition,
		"all pan/input/zoom paths leave terrain and condition untouched")
	button(screen, MOUSE_BUTTON_RIGHT, true)
	drag(screen + Vector2(80, 45))
	key(KEY_R)
	check(not camera.panning and camera.global_transform.is_equal_approx(home)
		and block.working_map.fossil.exposed_cells == 0, "R resets specimen, pan and zoom")
	main.queue_free()
	await process_frame
	var evidence := {"checks": checks, "failures": failures, "rays": rays, "roundtrip_max_m": worst_ray}
	var file := FileAccess.open("res://work/test-logs/p4-pan-tests.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(evidence, "\t"))
	file.close()
	print("P4 PAN TESTS: %d checks, %d failures; %d rays, max error %.8f m" % [checks, failures, rays, worst_ray])
	quit(0 if failures == 0 else 1)
