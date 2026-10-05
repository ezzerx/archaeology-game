extends SceneTree
## Run after a headless editor import; no testing addon required.

var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + description)

func test_mapping() -> void:
	var dimensions := Vector2(1.1, 0.7)
	var resolution := Vector2i(1024, 640)
	check(SurfaceMapping.local_to_uv(Vector3.ZERO, dimensions) == Vector2(0.5, 0.5), "centre UV")
	check(SurfaceMapping.local_to_uv(Vector3(-0.55, 0, -0.35), dimensions).is_equal_approx(Vector2.ZERO), "top left UV")
	check(SurfaceMapping.local_to_uv(Vector3(0.55, 0, 0.35), dimensions).is_equal_approx(Vector2.ONE), "bottom right UV")
	check(SurfaceMapping.contains_uv(Vector2.ONE), "inclusive UV edge")
	check(not SurfaceMapping.contains_uv(Vector2(-0.001, 0.5)), "negative UV rejected")
	check(not SurfaceMapping.contains_uv(Vector2(0.5, 1.001)), "outside UV rejected")
	check(not SurfaceMapping.contains_uv(Vector2(NAN, 0)), "NaN UV rejected")
	check(SurfaceMapping.uv_to_cell(Vector2.ONE, resolution) == resolution - Vector2i.ONE, "last texel, no overflow")
	check(SurfaceMapping.uv_to_map(Vector2.ZERO, resolution) == Vector2(-0.5, -0.5), "texture edge convention")
	check(SurfaceMapping.uv_to_map(Vector2(0.5 / 1024, 0.5 / 640), resolution).is_equal_approx(Vector2.ZERO), "first texel centre")

func test_surface() -> void:
	var surface := WorkingSurface.new(Vector2i(128, 80))
	var initial := surface.image.get_data()
	var centre := Vector2(64, 40)
	surface.dirty = false
	check(surface.apply_segment(centre, centre, 10, 0, 1, 0.1) == 0 and not surface.dirty, "zero strength is a no-op")
	check(surface.apply_segment(centre, centre, 10, 1, 1, 0) == 0, "zero delta is a no-op")
	surface.apply_segment(centre, centre, 10, 1, 1, 0.5)
	check(is_equal_approx(surface.value_at(Vector2i(64, 40)), 0.5), "stationary footprint strength")
	check(surface.value_at(Vector2i(74, 40)) == 1.0, "radius boundary untouched")
	check(surface.value_at(Vector2i(64, 40)) < surface.value_at(Vector2i(69, 40)), "falloff towards edge")
	check(surface.value_at(Vector2i(69, 40)) < surface.value_at(Vector2i(73, 40)), "smooth radial falloff")
	check(surface.value_at(Vector2i(69, 40)) == surface.value_at(Vector2i(59, 40)), "footprint symmetry")
	check(WorkingSurface.weight(0.5, 2) < WorkingSurface.weight(0.5, 1), "falloff tuning changes profile")
	check(WorkingSurface.weight(0, 2) == 1.0 and WorkingSurface.weight(1, 2) == 0.0, "falloff endpoints")
	var once := surface.image.get_data()
	surface.reset()
	check(initial == surface.image.get_data(), "byte-exact reset")
	surface.apply_segment(centre, centre, 10, 1, 1, 0.5)
	check(once == surface.image.get_data(), "byte-exact repeatability")
	var config := DebugExcavator.new()
	config.radius = -5
	config.strength = 200
	config.falloff = 0
	check(config.radius == 1.0 and config.strength == 5.0 and config.falloff == 0.25, "resource parameter bounds")
	surface.apply_segment(centre, centre, 10, 5, 1, 100)
	check(surface.value_at(Vector2i(64, 40)) == 0.0, "saturation clamps to zero")
	surface.reset()
	surface.apply_segment(Vector2(-0.5, -0.5), Vector2(-0.5, -0.5), 10, 1, 1, 1)
	check(surface.value_at(Vector2i.ZERO) < 1.0, "corner footprint clips to map")
	check(surface.value_at(Vector2i(127, 79)) == 1.0, "no wrapping at edges")
	check(surface.apply_segment(Vector2(-200, -200), Vector2(-190, -190), 10, 1, 1, 1) == 0, "outside footprint is a no-op")
	surface.reset()
	surface.apply_segment(Vector2(5, 40), Vector2(122, 40), 5, 1, 1, 0.1)
	var continuous := true
	for x in range(5, 123):
		continuous = continuous and surface.value_at(Vector2i(x, 40)) < 1.0
	check(continuous, "fast horizontal sweep has no gaps")
	surface.reset()
	surface.apply_segment(Vector2(5, 5), Vector2(120, 74), 4, 1, 1, 0.1)
	continuous = true
	for i in range(116):
		var point := Vector2(5, 5).lerp(Vector2(120, 74), i / 115.0)
		continuous = continuous and surface.value_at(Vector2i(point.round())) < 1.0
	check(continuous, "fast diagonal sweep has no gaps")
	# Independent native geometry oracle for the row-clipping optimisation.
	var capsule_matches := true
	for end in [Vector2(27, 19), Vector2(27, 2), Vector2(5, 2), Vector2(5, 19)]:
		var probe := WorkingSurface.new(Vector2i(32, 24))
		var start := Vector2(5, 19)
		probe.apply_segment(start, end, 5, 1, 1, 0.2)
		for y in range(24):
			for x in range(32):
				var point := Vector2(x, y)
				var closest := Geometry2D.get_closest_point_to_segment(point, start, end)
				var expected := 1.0 - 0.2 * WorkingSurface.weight(point.distance_to(closest) / 5.0, 1)
				capsule_matches = capsule_matches and absf(probe.value_at(Vector2i(x, y)) - expected) < 0.00001
	check(capsule_matches, "swept capsule matches native geometry in both directions and at rest")
	var split := WorkingSurface.new(Vector2i(128, 80))
	surface.reset()
	surface.apply_segment(centre, centre, 10, 1, 1.5, 1.0)
	for i in range(60):
		split.apply_segment(centre, centre, 10, 1, 1.5, 1.0 / 60.0)
	check(absf(surface.value_at(Vector2i(67, 40)) - split.value_at(Vector2i(67, 40))) < 0.00001, "stationary strength is elapsed-time based")
	var full := WorkingSurface.new()
	var begin := Time.get_ticks_usec()
	for i in range(60):
		full.apply_segment(Vector2(400 + i * 3, 300), Vector2(403 + i * 3, 300), 40, 0.8, 1.5, 1.0 / 60.0)
	print("BENCH: default 1024x640/r40, mean edit %.3f ms (CPU only)" % ((Time.get_ticks_usec() - begin) / 60000.0))

	begin = Time.get_ticks_usec()
	full.apply_segment(Vector2(20, 20), Vector2(1004, 620), 40, 0.8, 1.5, 1.0 / 60.0)
	print("BENCH: full diagonal %.3f ms (CPU only)" % ((Time.get_ticks_usec() - begin) / 1000.0))

func test_scene() -> void:
	root.size = Vector2i(1920, 1080)
	var main := load("res://scenes/prototype_main.tscn").instantiate() as Node3D
	root.add_child(main)
	var block: ExcavationBlock = main.get_node("ExcavationBlock")
	var camera: Camera3D = main.get_node("Camera3D")
	var controller: ToolController = main.get_node("ToolController")
	await physics_frame
	await physics_frame
	check(camera.projection == Camera3D.PROJECTION_ORTHOGONAL, "orthographic camera")
	check(is_equal_approx(rad_to_deg(-camera.rotation.x), 84.0), "84 degree elevation")
	# Check real PlaneMesh UVs: this catches mirrored debug textures.
	var arrays := block.surface.mesh.surface_get_arrays(0)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
	var uv_matches := true
	for i in range(vertices.size()):
		uv_matches = uv_matches and SurfaceMapping.local_to_uv(vertices[i], block.surface_size).is_equal_approx(uvs[i])
	check(uv_matches, "mapping agrees with actual PlaneMesh UVs")
	# Round-trip through the real camera and physics collider across the full top.
	var mapped := true
	for u in [0.001, 0.1, 0.5, 0.9, 0.999]:
		for v in [0.001, 0.1, 0.5, 0.9, 0.999]:
			var local := Vector3((u - 0.5) * 1.1, block.thickness, (v - 0.5) * 0.7)
			var screen := camera.unproject_position(block.to_global(local))
			var hit := block.pick(screen, camera)
			mapped = mapped and hit.inside and (hit.uv as Vector2).distance_to(Vector2(u, v)) < 0.0001
	check(mapped, "25-point camera/raycast/local/UV round-trip")
	var side := block.to_global(Vector3(0, 0.04, 0.35))
	check(not block.pick(camera.unproject_position(side), camera).inside, "side face rejected")
	check(not block.pick(Vector2(-1, -1), camera).inside, "outside viewport rejected")
	var initial := block.working_map.image.get_data()
	# Exercise the real controller with viewport input, not a replacement paint path.
	Input.warp_mouse(camera.unproject_position(Vector3(0, block.thickness, 0)))
	var motion := InputEventMouseMotion.new()
	motion.position = camera.unproject_position(Vector3(0, block.thickness, 0))
	root.push_input(motion)
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = motion.position
	root.push_input(press)
	for i in range(5):
		await physics_frame
	check(block.working_map.image.get_data() != initial, "held LMB edits through controller")
	var key := InputEventKey.new()
	key.physical_keycode = KEY_R
	key.pressed = true
	root.push_input(key)
	await physics_frame
	await physics_frame
	check(block.working_map.image.get_data() == initial, "R resets while LMB held without repaint")
	var left := camera.unproject_position(Vector3(-0.3, block.thickness, 0))
	var right := camera.unproject_position(Vector3(0.3, block.thickness, 0))
	motion = InputEventMouseMotion.new()
	motion.position = left
	root.push_input(motion, true)
	press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = left
	root.push_input(press, true)
	await physics_frame
	await physics_frame
	motion = InputEventMouseMotion.new()
	motion.position = Vector2(10, 900)
	root.push_input(motion, true)
	await physics_frame
	await physics_frame
	motion = InputEventMouseMotion.new()
	motion.position = right
	root.push_input(motion, true)
	await physics_frame
	await physics_frame
	check(block.working_map.value_at(Vector2i(512, 320)) == 1.0, "leaving/re-entering surface never bridges")
	check(block.working_map.value_at(Vector2i(791, 320)) < 1.0, "held LMB resumes with fresh footprint on re-entry")
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = right
	root.push_input(release, true)
	var released := block.working_map.image.get_data()
	await physics_frame
	await physics_frame
	check(block.working_map.image.get_data() == released, "release stops edits")
	var panel: PanelContainer = main.get_node("Debug/Panel")
	key = InputEventKey.new()
	key.physical_keycode = KEY_F1
	key.pressed = true
	root.push_input(key)
	await process_frame
	check(panel.visible, "F1 shows debug from the P5 player view")
	root.push_input(key.duplicate())
	await process_frame
	check(not panel.visible, "F1 returns to the P5 player view")
	controller._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
	await physics_frame
	await physics_frame
	check(not controller.hit.inside, "focus loss disables cursor and edit")
	controller._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_IN)
	var saved := block.transform
	block.position = Vector3(0.03, 0.02, 0)
	block.rotation.y = 0.15
	block.scale = Vector3(0.9, 1.1, 0.9)
	await physics_frame
	await physics_frame
	var target := block.to_global(Vector3(0.11, block.thickness, -0.14))
	var transformed := block.pick(camera.unproject_position(target), camera)
	check(transformed.inside and (transformed.uv as Vector2).distance_to(Vector2(0.6, 0.3)) < 0.0001, "world/local mapping survives block transform")
	block.transform = saved
	main.queue_free()
	await process_frame

func run() -> void:
	test_mapping()
	test_surface()
	await test_scene()
	print("P0 TESTS: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
