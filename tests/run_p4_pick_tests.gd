extends "res://tests/run_p4_dirt_tests.gd"
## Precision Pick is a structural finishing tool, with provisional P4 bone safety.
var pick: ToolDefinition = preload("res://config/precision_pick.tres")

func sync(surface: WorkingSurface) -> void:
	surface.image.set_data(surface.size.x, surface.size.y, false, Image.FORMAT_RF, surface._heights.to_byte_array())

func test_micro_impacts() -> void:
	# Final human decision supersedes SCRAPE/movement and 0.004 per-pass limits.
	check(pick.id == &"precision_pick" and pick.interaction_mode == ToolDefinition.InteractionMode.IMPACT
		and is_equal_approx(pick.radius, 11) and is_equal_approx(pick.power, 0.44) and is_equal_approx(pick.falloff, 1.75)
		and pick.radius <= chisel.radius * 0.5 and pick.bone_damage == 0 and pick.residue_clear == 0,
		"human Pick 11/0.44/1.75: at most quarter Chisel disk area, zero damage, no loose-cleanup bonus")
	check(pick.cadence == 6 and pick.effectiveness == Vector3(0.3, 1.0, 1.5), "human Pick retains 6 Hz and original effectiveness")
	for height in [0.9, 0.6, 0.25]:
		var surface := dirty_fixture(height)
		var before := surface.image.get_data()
		var before_values := before.to_float32_array()
		var changed := surface.apply_impact(point, pick)
		check(changed > 0 and surface.value_at(cell) < height - 0.02, "one stationary Pick impact visibly removes material: %.2f" % height)
		var precise := true
		var footprint_cells := 0
		for y in range(surface.size.y):
			for x in range(surface.size.x):
				var distance := Vector2(x, y).distance_to(point)
				if distance < pick.radius: footprint_cells += 1
				if distance >= pick.radius: precise = precise and surface._heights[y * surface.size.x + x] == before_values[y * surface.size.x + x]
		check(precise and changed <= footprint_cells and footprint_cells == 373,
			"human radius-11 footprint is exactly a 373-cell disk: no sweep bridge or broad fracture")
		check(surface.fracture.stress.is_empty() and surface.last_action.chunks.is_empty()
			and surface.last_action.marks == 0, "Pick never triggers Chisel plate stress or chunks")
	var bulk := fixture(0.6)
	var fine := fixture(0.6)
	var initial := fine._heights.duplicate()
	for i in range(6): fine.apply_impact(point, pick)
	for i in range(5): bulk.apply_impact(point, chisel)
	var fine_removed := 0.0
	var bulk_removed := 0.0
	for i in range(fine._heights.size()):
		fine_removed += initial[i] - fine._heights[i]
		bulk_removed += initial[i] - bulk._heights[i]
	# The old >10 ratio encoded the superseded weak/small Pick. The new contract
	# is stronger local finishing, bounded to <=1/4 the disk area, without fracture.
	check(fine_removed > 0 and bulk_removed > fine_removed, "one second: Chisel still wins bulk removal over the human-validated fast Pick")
	check(0.6 - fine.value_at(cell) > 0.25, "six stationary micro-impacts quickly clear a substantial attached Clay cap")
	print("P4 PICK BULK: Pick=", fine_removed, "; Chisel=", bulk_removed, "; ratio=", bulk_removed / fine_removed)
	var strong := pick.duplicate() as ToolDefinition
	strong.power = 5
	for boundary in [0, 1]:
		var layer := dirty_fixture(0.6)
		for i in range(layer._heights.size()): layer._heights[i] = layer.strata.packed_limits[i * 2 + boundary] + 0.0005
		sync(layer)
		layer.apply_impact(point, strong)
		var bounded := true
		for i in range(layer._heights.size()): bounded = bounded and layer._heights[i] >= layer.strata.packed_limits[i * 2 + boundary]
		check(bounded and layer.value_at(cell) == layer.strata.packed_limits[(cell.y * layer.size.x + cell.x) * 2 + boundary],
			"even a debug-strength Pick impact stops exactly at its initial material interface")

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
		surface.apply_impact(target, pick)
		check(surface._heights[index] == field.ceilings[index] and surface.fossil.exposed[index] != 0,
			"Pick finishes an attached remnant exactly down to skull/rib bone ceiling")
		check(surface.last_action.bone_revealed and not surface.last_action.direct_bone_hit, "Pick reveal event remains distinct from damaging bone hit")
		for i in range(30): surface.apply_impact(target, pick)
		check(surface.fossil.condition == 100 and not surface.last_action.get("direct_bone_hit", false),
			"repeated Pick impacts over visible bone cause no damage in this P4 prototype")
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
	surface.apply_impact(Vector2(702, 140), control.config)
	check(fx.audio.last_family == &"precision_pick" and fx.emitted[1] == 0 and fx.emitted[2] == 0,
		"real Pick action routes its quiet sound without emitting hard fracture chunks")
	# Exercise the production controller clock, holding still in screen space.
	control._screen = main.camera.unproject_position(fx.point_world(Vector2(702, 140)))
	control._focused = true
	control._pointer_inside = true
	control._held = true
	control.impact_clock.reset()
	var impacts := control.total_impacts
	for tick in range(60): control._physics_process(1.0 / 60.0)
	check(control.total_impacts - impacts == 6, "stationary held Pick produces six real impacts in one second")
	control.cancel_stroke()
	for tap in range(3):
		control._held = true
		control._physics_process(1.0 / 60.0)
		control.cancel_stroke()
	check(control.total_impacts - impacts == 9, "three fresh short clicks each produce an immediate micro-impact")
	main.queue_free()
	await process_frame

func run() -> void:
	test_micro_impacts()
	test_bone_finish()
	await test_input_and_sound()
	print("P4 PICK TESTS: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
