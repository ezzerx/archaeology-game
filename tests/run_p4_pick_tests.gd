extends "res://tests/run_p4_dirt_tests.gd"
## Precision Pick is a structural finishing tool, with provisional P4 bone safety.
var pick: ToolDefinition = preload("res://config/precision_pick.tres")

func sync(surface: WorkingSurface) -> void:
	surface.image.set_data(surface.size.x, surface.size.y, false, Image.FORMAT_RF, surface._heights.to_byte_array())

func test_scrape() -> void:
	check(pick.id == &"precision_pick" and pick.interaction_mode == ToolDefinition.InteractionMode.SCRAPE
		and pick.radius < chisel.radius / 3 and pick.bone_damage == 0 and pick.residue_clear == 0,
		"data-driven Pick has a small structural footprint, provisional zero damage and no cleanup bonus")
	for height in [0.9, 0.6, 0.25]:
		var surface := dirty_fixture(height)
		var before := surface.image.get_data()
		var before_values := before.to_float32_array()
		surface.apply_continuous(point, point, pick, 10)
		check(surface.image.get_data() == before and surface.last_action.is_empty(), "held stationary Pick never drills any material")
		var changed := surface.apply_continuous(point - Vector2.RIGHT * 2, point, pick, 1.0 / 60.0)
		check(changed > 0 and surface.value_at(cell) < height, "moving Pick slowly removes structural material: %.2f" % height)
		var precise := true
		for y in range(surface.size.y):
			for x in range(surface.size.x):
				var distance := Vector2(x, y).distance_to(Vector2(clampf(x, point.x - 2, point.x), point.y))
				if distance >= pick.radius: precise = precise and surface._heights[y * surface.size.x + x] == before_values[y * surface.size.x + x]
		check(precise and changed < 50, "Pick work stays in a narrow capsule without broad collateral fracture")
		check(surface.fracture.stress.is_empty() and surface.last_action.chunks.is_empty()
			and surface.last_action.marks == 0, "Pick never triggers Chisel plate stress or chunks")
	var bulk := fixture(0.6)
	var fine := fixture(0.6)
	for i in range(60):
		fine.apply_continuous(point - Vector2.RIGHT, point + Vector2.RIGHT, pick, 1.0 / 60.0)
		if i % 14 == 0: bulk.apply_impact(point, chisel)
	var fine_removed := 0.0
	var bulk_removed := 0.0
	for i in range(fine._heights.size()):
		fine_removed += 0.6 - fine._heights[i]
		bulk_removed += 0.6 - bulk._heights[i]
	check(fine_removed > 0 and bulk_removed > fine_removed * 10, "default Pick is much slower at bulk removal than Chisel")
	var strong := pick.duplicate() as ToolDefinition
	strong.power = 5
	strong.scrape_reference_speed = 1
	for boundary in [0, 1]:
		var layer := dirty_fixture(0.6)
		for i in range(layer._heights.size()): layer._heights[i] = layer.strata.packed_limits[i * 2 + boundary] + 0.0005
		sync(layer)
		layer.apply_continuous(point - Vector2.RIGHT * 2, point, strong, 10)
		var bounded := true
		for i in range(layer._heights.size()): bounded = bounded and layer._heights[i] >= layer.strata.packed_limits[i * 2 + boundary]
		check(bounded and layer.value_at(cell) == layer.strata.packed_limits[(cell.y * layer.size.x + cell.x) * 2 + boundary],
			"a delayed/strong Pick pass stops exactly at its initial material interface")
	var delayed := fixture(0.6)
	delayed.apply_continuous(point - Vector2.RIGHT * 2, point, strong, 10)
	check(0.6 - delayed.value_at(cell) <= pick.scrape_max_depth + 0.000001, "one delayed Pick pass has a bounded depth")

func test_bone_finish() -> void:
	var size := Vector2i(128, 80)
	var field := FossilField.new(size)
	var surface := WorkingSurface.new(size, Stratigraphy.new(size, definitions), field, profile)
	# Leave actual thin attached caps on skull AND ribs, plus matrix around them.
	for i in range(surface._heights.size()): surface._heights[i] = maxf(0.22, field.ceilings[i] + 0.0006)
	sync(surface)
	for component in [FossilField.Component.SKULL, FossilField.Component.RIBS]:
		var index := -1
		for i in range(field.ceilings.size()):
			if field.component_ids[i] == component and field.ceilings[i] + 0.0006 <= surface.strata.packed_limits[i * 2 + 1] \
					and (index < 0 or field.ceilings[i] > field.ceilings[index]): index = i
		var target := Vector2(index % size.x, index / size.x)
		var before := surface._heights[index]
		surface.apply_continuous(target, target, brush, 2)
		check(surface._heights[index] == before, "Brush cannot remove the attached Sandstone remnant on bone")
		for i in range(90): surface.apply_continuous(target - Vector2.RIGHT, target + Vector2.RIGHT, pick, 1.0 / 60.0)
		check(surface._heights[index] == field.ceilings[index] and surface.fossil.exposed[index] != 0,
			"Pick finishes an attached remnant exactly down to skull/rib bone ceiling")
		check(surface.fossil.condition == 100 and not surface.last_action.get("direct_bone_hit", false),
			"repeated Pick strokes over visible bone cause no damage in this P4 prototype")
	var bounded := true
	for i in range(field.ceilings.size()): bounded = bounded and surface._heights[i] >= field.ceilings[i]
	check(bounded, "Pick never tunnels below any bone ceiling")
	surface.reset()
	check(Array(surface._heights).min() == 1 and surface.fossil.condition == 100 and surface.fossil.exposed_cells == 0
		and surface.loose_debris.occupancy.is_empty() and surface.fracture.stress.is_empty(), "reset restores structure, specimen and Pick dirt")

func test_input_and_sound() -> void:
	root.size = Vector2i(1920, 1080)
	root.content_scale_size = Vector2i(1920, 1080)
	var main := load("res://scenes/prototype_main.tscn").instantiate() as Node3D
	root.add_child(main)
	main.set_process(false)
	var control: ToolController = main.get_node("ToolController")
	control.set_physics_process(false)
	var toolbar: HBoxContainer = main.get_node("Debug/Toolbar")
	await process_frame
	check(control.tools.size() == 4 and toolbar.get_child_count() == 4
		and control.tools[3].id == &"precision_pick", "four tool resources and a fourth visible button")
	for keycode in [KEY_4, KEY_1, KEY_KP_4, KEY_2, KEY_4, KEY_3]:
		control._held = true
		var key := InputEventKey.new()
		key.physical_keycode = keycode
		key.pressed = true
		control._unhandled_input(key)
		var expected := 3 if keycode in [KEY_4, KEY_KP_4] else (0 if keycode == KEY_1 else (1 if keycode == KEY_2 else 2))
		check(control.selected_index == expected and toolbar.get_child(expected).button_pressed and not control._held,
			"keyboard switch to/from Pick cancels held input and synchronizes toolbar")
	var button: Button = toolbar.get_child(3)
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	click.position = button.get_global_rect().get_center()
	control._held = true
	root.push_input(click, true)
	click = click.duplicate()
	click.pressed = false
	root.push_input(click, true)
	await process_frame
	check(control.selected_index == 3 and button.button_pressed and not control._held, "real fourth toolbar click selects Pick and requires a fresh stroke")
	control._held = true
	control._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
	control._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_IN)
	check(not control._held, "Pick held input does not resume after lost focus")
	control._held = true
	control._update_pointer_position()
	check(not control._held, "Pick held input cancels on resize")
	var fx: MaterialFeedback = main.feedback
	control.hit = {"inside": true, "world": Vector3(0, 0.12, 0)}
	fx._process(0)
	check(fx.proxies[3].visible and fx.proxies[3].get_child_count() > 0, "fourth tool has a visible narrow proxy")
	var validated: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/p4-validated-audio.json"))
	var unchanged := true
	for family in validated:
		for variant in range(4):
			var hash := HashingContext.new()
			hash.start(HashingContext.HASH_SHA256)
			hash.update(fx.audio.samples[StringName(family)][variant].data)
			unchanged = unchanged and hash.finish().hex_encode() == validated[family][variant]
	check(unchanged, "all 28 human-validated audio variants remain byte-identical to c25b44f")
	var surface: WorkingSurface = control.block.working_map
	surface.apply_continuous(Vector2(700, 140), Vector2(702, 140), control.config, 1.0 / 60.0)
	check(fx.audio.last_family == &"precision_pick" and fx.emitted[1] == 0 and fx.emitted[2] == 0,
		"real Pick action routes its quiet sound without emitting hard fracture chunks")
	main.queue_free()
	await process_frame

func run() -> void:
	test_scrape()
	test_bone_finish()
	await test_input_and_sound()
	print("P4 PICK TESTS: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
