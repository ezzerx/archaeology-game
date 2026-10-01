extends SceneTree
## P3 product corrections: physical safety envelope, safe finishing, camera/input.

var checks := 0
var failures := 0
var definitions: Array[MaterialDefinition] = [preload("res://config/loose_soil.tres"),
	preload("res://config/compact_clay.tres"), preload("res://config/sandstone.tres")]
var brush: ToolDefinition = preload("res://config/soft_brush.tres")
var chisel: ToolDefinition = preload("res://config/chisel.tres")
var contacts := 0
var damage_events := 0
var evidence := {}

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + message)

func contact(_cell: Vector2i, _component: int) -> void:
	contacts += 1

func damage(_condition: float, _amount: float) -> void:
	damage_events += 1

func highest_cell(field: FossilField) -> Vector2i:
	var index := 0
	for i in range(field.ceilings.size()):
		if field.ceilings[i] > field.ceilings[index]: index = i
	return Vector2i(index % field.size.x, index / field.size.x)

func seed_cell(surface: WorkingSurface, cell: Vector2i, height: float) -> void:
	# Isolated material fixture, not a player action. Both RF representations agree.
	surface._heights[cell.y * surface.size.x + cell.x] = height
	surface.image.set_pixelv(cell, Color(height, 0, 0, 1))

func test_precision_materials() -> void:
	var field := FossilField.new(Vector2i(128, 80))
	var cell := highest_cell(field)
	var index := cell.y * field.size.x + cell.x
	var ceiling := field.ceilings[index]
	var point := Vector2(cell)
	var impact := chisel.duplicate() as ToolDefinition
	impact.radius = 1
	impact.power = 5
	var finish := brush.duplicate() as ToolDefinition
	finish.radius = 1
	for clay_bottom in [0.1, 0.6]:
		var strata := Stratigraphy.new(field.size, definitions)
		strata.boundaries.fill(Color(0.8, clay_bottom, 0, 1))
		strata.packed_limits = strata.boundaries.get_data().to_float32_array()
		var material_name := "Clay" if clay_bottom == 0.1 else "Sandstone"
		for depth_m in [0.102, 0.2]:
			var surface := WorkingSurface.new(field.size, strata, field, depth_m)
			contacts = 0
			damage_events = 0
			surface.fossil.bone_first_contact.connect(contact)
			surface.fossil.bone_condition_changed.connect(damage)
			for i in range(5): surface.apply_impact(point, impact)
			var clearance_mm: float = (surface.value_at(cell) - ceiling) * depth_m * 1000
			check(absf(clearance_mm - 2.0) < 0.0001, material_name + ": real 2 mm margin at depth " + str(depth_m))
			check(surface.is_precision_cell(index) and contacts == 0 and surface.fossil.exposed_cells == 0,
				material_name + ": proximity is not structural exposure or first contact")
			var bytes_at_margin := surface.image.get_data()
			for i in range(50): surface.apply_impact(point, impact)
			surface.apply_segment(point, point, 1, 1e30, 1, 1e5, impact.effectiveness, 0, true)
			check(surface.image.get_data() == bytes_at_margin and surface.fossil.condition == 100 and damage_events == 0,
				material_name + ": repeated/enormous impacts cannot cross the safety margin")
			for i in range(60): surface.apply_continuous(point, point, finish, 1.0 / 60.0)
			var remainder_mm: float = (surface.value_at(cell) - ceiling) * depth_m * 1000
			check(absf(remainder_mm - 1.0) < 0.002 and contacts == 0,
				material_name + ": precision rate is a controlled 1 mm/s without premature contact")
			var partly_brushed := surface.image.get_data()
			surface.apply_impact(point, impact)
			check(surface.image.get_data() == partly_brushed and surface.fossil.condition == 100,
				material_name + ": Chisel neither removes nor raises partly brushed cover")
			for i in range(90): surface.apply_continuous(point, point, finish, 1.0 / 60.0)
			check(surface.value_at(cell) == ceiling and surface.fossil.exposed_cells == 1
				and surface.fossil.condition == 100 and contacts == 1,
				material_name + ": Brush reaches exact ceiling, one contact, 100 condition")
			surface.apply_continuous(point, point, finish, 1e5)
			check(surface.value_at(cell) == ceiling and contacts == 1 and damage_events == 0,
				material_name + ": even long Brush use cannot penetrate or damage bone")
			surface.apply_impact(point, impact)
			check(surface.fossil.condition == 97 and damage_events == 1 and surface.value_at(cell) == ceiling,
				material_name + ": intentional exposed-bone impact gives one -3 event, no height change")
			surface.reset()
			check(not surface.is_precision_cell(index) and surface.fossil.exposed_cells == 0
				and surface.fossil.condition == 100 and not surface.fossil.first_contact,
				material_name + ": reset clears all derived precision/discovery state")
		# A non-bone cell in hard material matches the fossil-free P2 kernel exactly.
		var outside := Vector2i(2, 2)
		var with_bone := WorkingSurface.new(field.size, strata, field)
		var control := WorkingSurface.new(field.size, strata)
		seed_cell(with_bone, outside, 0.45)
		seed_cell(control, outside, 0.45)
		with_bone.apply_continuous(Vector2(outside), Vector2(outside), finish, 1)
		control.apply_continuous(Vector2(outside), Vector2(outside), finish, 1)
		check(with_bone.value_at(outside) == control.value_at(outside), material_name + ": away from bone, exact P2 response")
		var removed := 0.45 - with_bone.value_at(outside)
		check(absf(removed - (0.016 if clay_bottom == 0.1 else 0.0)) < 0.000001,
			material_name + ": unchanged Clay 0.06 effectiveness / Sandstone zero")
		seed_cell(with_bone, cell, ceiling + with_bone.precision_margin + 0.03)
		seed_cell(control, cell, with_bone.value_at(cell))
		with_bone.apply_continuous(point, point, finish, 0.01)
		control.apply_continuous(point, point, finish, 0.01)
		check(with_bone.value_at(cell) == control.value_at(cell), material_name + ": no bonus above margin even with bone underneath")
		with_bone.apply_segment(Vector2(outside), Vector2(outside), 1, 1e20, 1, 1, Vector3.ONE, 0, true)
		check(with_bone.value_at(outside) == 0, material_name + ": surrounding matrix still reaches the floor")
	var tuned := WorkingSurface.new(field.size, null, field, 0.102, 2.5)
	for i in range(2): tuned.apply_impact(point, impact)
	check(absf((tuned.value_at(cell) - ceiling) * 102.0 - 2.5) < 0.0001, "margin is configurable in real millimetres")

func test_careful_excavation() -> void:
	var field := FossilField.new()
	var surface := WorkingSurface.new(field.size, Stratigraphy.new(field.size, definitions), field)
	var pristine := surface.image.get_data()
	var static_map := field.image.get_data()
	contacts = 0
	damage_events = 0
	surface.fossil.bone_first_contact.connect(contact)
	surface.fossil.bone_condition_changed.connect(damage)
	# Several separate real areas, alternating DEFAULT Chisel then DEFAULT Brush.
	# No height seeding, strength override or generic editing API in this scenario.
	var points := [Vector2(280, 193), Vector2(317, 231), Vector2(240, 239),
		Vector2(192, 260), Vector2(394, 314), Vector2(439, 375), Vector2(252, 199),
		Vector2(188, 240), Vector2(259, 271), Vector2(371, 282), Vector2(451, 305), Vector2(601, 353)]
	for point in points:
		var before := surface.fossil.exposed_cells
		for i in range(80): surface.apply_impact(point, chisel)
		check(surface.fossil.exposed_cells == before and surface.fossil.condition == 100,
			"careful approach stays safe at " + str(point))
		for i in range(210): surface.apply_continuous(point, point, brush, 1.0 / 60.0)
		check(surface.fossil.exposed_cells > before and surface.fossil.condition == 100,
			"Brush adds a new bone area safely at " + str(point))
	check(surface.fossil.exposed_cells > 1000 and surface.fossil.component_exposed[FossilField.Component.SKULL] > 0
		and surface.fossil.component_exposed[FossilField.Component.RIBS] > 0 and contacts == 1 and damage_events == 0,
		"meaningful skull/rib extraction at 100%, one discovery")
	print("P3 SAFE WORKFLOW: %d cells / %.3f%%, condition %.0f, contacts %d" % [
		surface.fossil.exposed_cells, surface.fossil.exposure_percent(), surface.fossil.condition, contacts])
	evidence["safe_workflow"] = {"default_tools": true, "areas": points.size(),
		"exposed_cells": surface.fossil.exposed_cells, "exposure_percent": surface.fossil.exposure_percent(),
		"condition": surface.fossil.condition, "first_contacts": contacts, "damage_events": damage_events}
	surface.apply_impact(points[0], chisel)
	check(surface.fossil.condition == 97 and damage_events == 1, "deliberate error after safe workflow loses exactly 3")
	surface.reset()
	check(surface.image.get_data() == pristine and field.image.get_data() == static_map
		and surface.fossil.condition == 100 and surface.fossil.exposed_cells == 0
		and surface.residue._values.count(0.0) == surface.residue._values.size(), "workflow reset exact; static field unchanged")

func wheel(position: Vector2, steps: float, shift := false, ctrl := false) -> void:
	var event := InputEventMouseButton.new()
	event.position = position
	event.button_index = MOUSE_BUTTON_WHEEL_UP if steps > 0 else MOUSE_BUTTON_WHEEL_DOWN
	event.factor = absf(steps)
	event.pressed = true
	event.shift_pressed = shift
	event.ctrl_pressed = ctrl
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
	wheel(screen, 1, true)
	wheel(screen, 1, false, true)
	check(Vector3(controller.config.radius, controller.config.power, controller.config.falloff) == original,
		"wheel including modifiers never changes tool tuning")
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
		and block.working_map.fossil.condition == 100 and not main.get_node("Debug/PrecisionHint").visible,
		"R restores pristine specimen, overview and precision hint")
	check(Engine.max_fps == 240 and Engine.physics_ticks_per_second == 60, "runtime 240 FPS / physics 60 Hz unchanged")
	main.queue_free()
	await process_frame

func run() -> void:
	test_precision_materials()
	test_careful_excavation()
	await test_zoom()
	evidence["checks"] = checks
	evidence["failures"] = failures
	evidence["godot"] = Engine.get_version_info().string
	evidence["runtime_cap"] = Engine.max_fps
	evidence["physics_hz"] = Engine.physics_ticks_per_second
	DirAccess.make_dir_recursive_absolute("res://work/test-logs")
	var file := FileAccess.open("res://work/test-logs/p3-precision-tests.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(evidence, "\t"))
	file.close()
	print("P3 PRECISION TESTS: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
