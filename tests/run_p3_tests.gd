extends SceneTree
## P3 invariants plus independent full-map accounting and real scene input/picking.

var checks := 0
var failures := 0
var definitions: Array[MaterialDefinition] = [preload("res://config/loose_soil.tres"),
	preload("res://config/compact_clay.tres"), preload("res://config/sandstone.tres")]
var brush: ToolDefinition = preload("res://config/soft_brush.tres")
var chisel: ToolDefinition = preload("res://config/chisel.tres")
var blower: ToolDefinition = preload("res://config/air_blower.tres")
var field: FossilField
var observed: WorkingSurface
var first_events := 0
var cell_events := 0
var component_events := 0
var damage_events := 0
var event_cells := {}
var committed_events := true

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + message)

func sample_cell(component: int) -> Vector2i:
	var best := -1
	for index in range(field.component_ids.size()):
		if field.component_ids[index] == component and (best < 0 or field.ceilings[index] > field.ceilings[best]):
			best = index
	return Vector2i(best % field.size.x, best / field.size.x)

func new_surface() -> WorkingSurface:
	return WorkingSurface.new(field.size, Stratigraphy.new(field.size, definitions), field)

func first_event(_cell: Vector2i, _component: int) -> void:
	first_events += 1

func cell_event(cell: Vector2i, component: int) -> void:
	cell_events += 1
	var index := cell.y * field.size.x + cell.x
	committed_events = committed_events and not event_cells.has(index)
	committed_events = committed_events and observed.value_at(cell) <= field.ceilings[index] + FossilField.EXPOSURE_EPSILON
	committed_events = committed_events and field.component_ids[index] == component
	event_cells[index] = true

func component_event(component: int, exposed: int, total: int) -> void:
	component_events += 1
	committed_events = committed_events and exposed == observed.fossil.component_exposed[component]
	committed_events = committed_events and total == field.component_totals[component]

func damage_event(condition: float, damage: float) -> void:
	damage_events += 1
	committed_events = committed_events and condition >= 0 and condition <= 100 and damage > 0 and damage <= 3

func verify_accounting(surface: WorkingSurface, description: String) -> void:
	# Oracle scans raw RF heights and immutable IDs, never reads cached flags to count.
	var count := 0
	var by_component := PackedInt32Array([0, 0, 0, 0, 0])
	var heights := surface.image.get_data().to_float32_array()
	var valid := true
	for index in range(heights.size()):
		var component := field.component_ids[index]
		var exposed := component != 0 and heights[index] <= field.ceilings[index] + FossilField.EXPOSURE_EPSILON
		valid = valid and (surface.fossil.exposed[index] != 0) == exposed
		if exposed:
			count += 1
			by_component[component] += 1
	check(valid and count == surface.fossil.exposed_cells, description + ": flags/count match RF oracle")
	check(is_equal_approx(surface.fossil.exposure_percent(), 100.0 * count / field.total_cells), description + ": overall percent")
	for component in range(1, 5):
		check(by_component[component] == surface.fossil.component_exposed[component]
			and is_equal_approx(surface.fossil.exposure_percent(component), 100.0 * by_component[component] / field.component_totals[component]),
			description + ": component %d" % component)

func test_layout() -> void:
	field = FossilField.new()
	var twin := FossilField.new()
	check(field.image.get_data() == twin.image.get_data() and field.ceilings == twin.ceilings and field.component_ids == twin.component_ids, "B-17 deterministic byte for byte")
	check(field.image.get_format() == Image.FORMAT_RGF and field.image.get_size() == field.size, "one static RGF aligned with the height RF")
	var totals := PackedInt32Array([0, 0, 0, 0, 0])
	var bounds := true
	var valid_ceiling := true
	var valid_ids := true
	var minimum := 1.0
	var maximum := 0.0
	for index in range(field.component_ids.size()):
		var id := field.component_ids[index]
		valid_ids = valid_ids and id >= 0 and id <= 4
		if id == 0:
			valid_ceiling = valid_ceiling and field.ceilings[index] == 0.0
			continue
		totals[id] += 1
		var x := index % field.size.x
		var y := index / field.size.x
		bounds = bounds and x > 8 and x < field.size.x - 9 and y > 8 and y < field.size.y - 9
		valid_ceiling = valid_ceiling and field.ceilings[index] > 0 and field.ceilings[index] < 1.0 - FossilField.EXPOSURE_EPSILON
		minimum = minf(minimum, field.ceilings[index])
		maximum = maxf(maximum, field.ceilings[index])
	check(bounds, "all bone lies strictly inside block")
	check(valid_ceiling and maximum - minimum > 0.05, "ceilings above floor, buried, with rounded height variation")
	check(valid_ids and totals == field.component_totals, "component IDs and totals counted independently")
	for component in range(1, 5): check(totals[component] > 500, "component %d has substantial area" % component)
	check(field.total_cells == totals[1] + totals[2] + totals[3] + totals[4], "overall denominator is union of bone cells")
	check(field.index_at_map(Vector2(-1, 0)) == -1 and field.index_at_map(Vector2.INF) == -1, "invalid impact centres rejected")
	check(field.index_at_map(Vector2(11.49, 9.1)) == 9 * field.size.x + 11 and field.index_at_map(Vector2(11.5, 9.1)) == 9 * field.size.x + 12, "centre mapping matches UV cell boundaries")
	var surface := new_surface()
	check(surface.fossil.condition == 100 and not surface.fossil.first_contact and surface.fossil.exposed_cells == 0, "initial specimen completely hidden, pristine condition")
	verify_accounting(surface, "pristine")
	print("P3 LAYOUT: %d cells, components %s, ceiling %.6f..%.6f" % [field.total_cells, totals, minimum, maximum])

func test_contact_damage_and_reset() -> void:
	observed = new_surface()
	var surface := observed
	var fossil := surface.fossil
	fossil.bone_first_contact.connect(first_event)
	fossil.bone_cell_exposed.connect(cell_event)
	fossil.bone_component_exposure_changed.connect(component_event)
	fossil.bone_condition_changed.connect(damage_event)
	var pristine := surface.image.get_data()
	var residue_zero := surface.residue.image.get_data()
	var residue_fraction_zero := surface.residue._values.to_byte_array()
	var static_bytes := field.image.get_data()
	var strata_bytes := surface.strata.boundaries.get_data()
	var cell := sample_cell(FossilField.Component.SKULL)
	var point := Vector2(cell)
	var index := cell.y * field.size.x + cell.x
	var strong := chisel.duplicate() as ToolDefinition
	strong.power = 5
	strong.radius = 1
	check(surface.apply_impact(point, strong) == 1, "tiny direct impact edits exactly one cell")
	check(absf(surface.value_at(cell) - field.ceilings[index] - surface.precision_margin) < 0.0000001,
		"Chisel stops at the new precision margin")
	check(fossil.exposed_cells == 0 and first_events == 0 and fossil.condition == 100,
		"Chisel approach alone does not reveal bone or emit contact")
	var finishing := brush.duplicate() as ToolDefinition
	finishing.radius = 1
	surface.apply_continuous(point, point, finishing, 3.0)
	check(surface.value_at(cell) == field.ceilings[index], "material removal clamps exactly at ceiling")
	check(fossil.condition == 100 and damage_events == 0, "first hidden contact protected before damage decision")
	check(first_events == 1 and fossil.first_contact and cell_events == 1, "first and per-cell contact emitted once")
	check(fossil.exposed_cells == 1 and fossil.exposure_percent() < 0.01, "one-cell reveal is a tiny fraction of fossil")
	check(component_events == 1, "component change emitted once per affected component per operation")
	surface.apply_impact(point, strong)
	check(fossil.condition == 97 and damage_events == 1, "second direct impact subtracts three points exactly once")
	check(first_events == 1 and cell_events == 1 and component_events == 1, "no repeat reveal events when hitting exposed cell")
	strong.radius = 50
	surface.apply_impact(point, strong)
	check(fossil.condition == 94 and damage_events == 2, "large footprint still pays one penalty maximum")
	finishing.radius = strong.radius
	surface.apply_continuous(point, point, finishing, 20.0)
	check(fossil.exposed_cells > 1 and committed_events, "signals observe synchronized height and counters")
	verify_accounting(surface, "partial reveal")
	# Hidden centre adjacent to exposed cells is safe despite the overlapping footprint.
	var hidden := Vector2(sample_cell(FossilField.Component.SPINE))
	surface.apply_impact(hidden, strong)
	check(fossil.condition == 94, "new hidden centre protected after specimen-level discovery")
	var outside := point + Vector2(0, -55)
	check(field.component_ids[field.index_at_map(outside)] == 0, "matrix-centred overlap fixture contains no centre bone")
	strong.radius = 90
	surface.apply_impact(outside, strong)
	check(fossil.condition == 94, "matrix centre touching exposed bone at footprint edge is safe")
	# Hard bound independent of material resistance or any reasonable power/delta.
	surface.apply_segment(point, point, 20, 1e30, 1.0, 1e5)
	check(surface.value_at(cell) == field.ceilings[index], "enormous work cannot tunnel through bone")
	var free_cell := cell + Vector2i(0, -18)
	check(field.component_ids[free_cell.y * field.size.x + free_cell.x] == 0
		and surface.value_at(free_cell) == 0 and surface.value_at(free_cell) < surface.value_at(cell), "nearby non-bone matrix reaches floor below bone")
	var before := fossil.condition
	# Precision finishing already brushed this area clean; seed fresh residue to
	# preserve the historical cleaning assertion instead of comparing zero to zero.
	surface.residue.deposit_removed(cell.x, cell.y, 8.0)
	var residue_before := surface.residue.value_at((point + Vector2.ONE * 0.5) / Vector2(field.size))
	for repeat in range(10): surface.apply_continuous(point, point, brush, 1)
	check(fossil.condition == before and surface.value_at(cell) == field.ceilings[index], "Brush safe with fixed bone height")
	check(surface.residue.value_at((point + Vector2.ONE * 0.5) / Vector2(field.size)) < residue_before, "Brush still removes residue over bone")
	var heights_before := surface.image.get_data()
	var exposure_before := fossil.exposed.duplicate()
	for repeat in range(60): surface.apply_continuous(point, point, blower, 1.0 / 60.0)
	check(fossil.condition == before and surface.image.get_data() == heights_before and fossil.exposed == exposure_before, "Blower preserves geometry, condition and structural exposure byte exactly")
	check(surface.residue.value_at((point + Vector2.ONE * 0.5) / Vector2(field.size)) == 0, "Blower clears bone residue")
	for repeat in range(50): surface.apply_impact(point, chisel)
	check(fossil.condition == 0 and surface.value_at(cell) == field.ceilings[index], "condition clamps at zero, bone never destroyed")
	var events_at_zero := damage_events
	surface.apply_impact(point, chisel)
	fossil.damage_at(index, -20)
	check(fossil.condition == 0 and damage_events == events_at_zero, "no negative healing or condition event spam at zero")
	# Expose whole specimen through the same edit API (fixture only).
	surface.apply_segment(Vector2.ZERO, Vector2(field.size), 2000, 1e8, 1, 1)
	verify_accounting(surface, "fully exposed")
	check(fossil.exposure_percent() == 100 and first_events == 1 and cell_events == field.total_cells, "all bone cells counted once, global notice still once")
	var bounded := true
	for i in range(field.ceilings.size()): bounded = bounded and surface._heights[i] >= field.ceilings[i]
	check(bounded, "all height cells stay above their bone ceiling")
	check(field.image.get_data() == static_bytes and surface.strata.boundaries.get_data() == strata_bytes, "static maps unchanged by excavation and damage")
	surface.reset()
	check(surface.image.get_data() == pristine and surface.residue.image.get_data() == residue_zero
		and surface.residue._values.to_byte_array() == residue_fraction_zero, "height and residue reset exact, including sub-byte residue")
	check(fossil.condition == 100 and not fossil.first_contact and fossil.exposed_cells == 0
		and fossil.component_exposed == PackedInt32Array([0, 0, 0, 0, 0]), "reset restores all fossil counters and condition")
	verify_accounting(surface, "reset")
	check(fossil.last_bone_event == "—" and fossil.last_damage_event == "—", "reset clears event history")
	event_cells.clear()
	surface.apply_impact(point, strong)
	surface.apply_continuous(point, point, finishing, 20.0)
	check(first_events == 2 and fossil.condition == 100, "fresh discovery after reset again protected with one new notice")
	# Brush still works compatible matrix within a mixed bone/non-bone footprint.
	var mixed := WorkingSurface.new(field.size, null, field)
	mixed.apply_segment(point, point, 1, 100, 1, 1)
	var neighbour := cell + Vector2i(0, -18)
	mixed.apply_continuous(point, point, brush, 0.1)
	check(mixed.value_at(neighbour) < 1 and mixed.value_at(cell) == field.ceilings[index] and mixed.fossil.condition == 100, "Brush edits non-bone in same footprint while bone stays fixed")
	observed = null

func mouse(root_window: Window, screen: Vector2, pressed := false) -> void:
	var move := InputEventMouseMotion.new()
	move.position = screen
	root_window.push_input(move, true)
	if pressed:
		var event := InputEventMouseButton.new()
		event.position = screen
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = true
		root_window.push_input(event, true)

func test_exposure_epsilon() -> void:
	var small := FossilField.new(Vector2i(64, 40))
	var index := 0
	for i in range(small.ceilings.size()):
		if small.ceilings[i] > small.ceilings[index]: index = i
	var cell := Vector2i(index % small.size.x, index / small.size.x)
	var surface := WorkingSurface.new(small.size, null, small)
	for factor in [0.0, 0.5, 0.99999, 1.00001, 1.5, 2.0]:
		surface.reset()
		var target: float = small.ceilings[index] + FossilField.EXPOSURE_EPSILON * factor
		surface.apply_segment(Vector2(cell), Vector2(cell), 1, 1, 1, 1.0 - target)
		var expected := surface.value_at(cell) <= small.ceilings[index] + FossilField.EXPOSURE_EPSILON
		check((surface.fossil.exposed[index] != 0) == expected, "epsilon uses stored float32 at factor %.5f" % factor)

func test_scene() -> void:
	root.size = Vector2i(1920, 1080)
	var main := load("res://scenes/prototype_main.tscn").instantiate() as Node3D
	root.add_child(main)
	var block: ExcavationBlock = main.get_node("ExcavationBlock")
	var controller: ToolController = main.get_node("ToolController")
	var camera: Camera3D = main.get_node("Camera3D")
	controller.set_physics_process(false)
	await process_frame
	check(Engine.max_fps == 240 and ProjectSettings.get_setting("application/run/max_fps") == 240, "runtime reads official 240 FPS cap")
	check(Engine.physics_ticks_per_second == 60 and ProjectSettings.get_setting("physics/common/physics_ticks_per_second") == 60, "physics remains 60 Hz")
	check(not main.get_node("Debug/BoneNotice").visible and block.debug_view == 0, "no notice or fossil preview at start")
	var fossil := block.working_map.fossil
	var cell := sample_cell(FossilField.Component.HIND_LIMB)
	var point := Vector2(cell)
	var uv := (point + Vector2.ONE * 0.5) / Vector2(field.size)
	block.working_map.apply_segment(point, point, 60, 1e5, 1, 1)
	block.flush_texture()
	check(main.get_node("Debug/BoneNotice").visible and main.get_node("Debug/BoneNotice").text == "Bone detected\nDelicate material underneath", "first contact drives exact debug notification")
	var hit_bone := 0
	var hit_matrix := 0
	var worst := 0.0
	# Camera roundtrip traverses the bone, thin boundary, sloping walls and floor.
	for offset_y in range(-24, 25, 3):
		for offset_x in range(-28, 29, 2):
			var test_uv := uv + Vector2(offset_x, offset_y) / Vector2(field.size)
			var local := Vector3((test_uv.x - 0.5) * block.surface_size.x, block.relief.height_at(test_uv), (test_uv.y - 0.5) * block.surface_size.y)
			var hit := block.pick(camera.unproject_position(block.to_global(local)), camera)
			if not hit.inside:
				worst = INF
				continue
			# At near-vertical walls the camera may correctly hit an occluding bone
			# earlier. Only visible roundtrips may be compared to the chosen point.
			if hit.local.distance_to(local) > 0.00001:
				var repick := block.pick(camera.unproject_position(hit.world), camera)
				worst = maxf(worst, repick.local.distance_to(hit.local))
			else:
				worst = maxf(worst, hit.local.distance_to(local))
			if hit.bone_exposed: hit_bone += 1
			else: hit_matrix += 1
	check(worst < 0.00001 and hit_bone > 20 and hit_matrix > 20, "picking roundtrips exposed bone and adjacent cavity, including occlusion")
	print("P3 CAMERA: bone %d / matrix %d, max error %.8f m" % [hit_bone, hit_matrix, worst])
	var local := Vector3((uv.x - 0.5) * block.surface_size.x, block.relief.height_at(uv), (uv.y - 0.5) * block.surface_size.y)
	var screen := camera.unproject_position(block.to_global(local))
	var hit := block.pick(screen, camera)
	check(hit.bone_exposed and hit.bone_component == FossilField.Component.HIND_LIMB and hit.bone_ceiling > 0, "cursor exposes component, ceiling and exposed state")
	controller.select_tool(1)
	controller._focused = true
	controller._pointer_inside = true
	mouse(root, screen, true)
	controller._physics_process(1.0 / 60.0)
	check(fossil.condition == 97 and controller.total_impacts == 1, "production input schedules one direct bone penalty")
	controller.select_tool(0)
	for i in range(30): controller._physics_process(1.0 / 60.0)
	check(fossil.condition == 97 and not controller._held, "tool switch on bone cancels held stroke")
	controller.select_tool(1)
	mouse(root, screen, true)
	controller._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
	controller._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_IN)
	mouse(root, screen)
	for i in range(30): controller._physics_process(1.0 / 60.0)
	check(fossil.condition == 97 and not controller._held, "lost-focus bone contact never resumes on return")
	mouse(root, screen, true)
	controller._physics_process(1.0 / 60.0)
	check(fossil.condition == 94, "fresh click after focus works")
	var event := InputEventKey.new()
	event.physical_keycode = KEY_R
	event.pressed = true
	root.push_input(event, true)
	for i in range(30): controller._physics_process(1.0 / 60.0)
	check(fossil.condition == 100 and fossil.exposed_cells == 0 and not fossil.first_contact
		and not controller._held and controller.total_impacts == 0 and controller.impact_clock.emitted == 0, "R resets fossil plus held input and chisel cadence")
	check(not main.get_node("Debug/BoneNotice").visible, "R immediately clears notification")
	check(block.working_map.value_at(cell) == 1 and block.working_map.residue.value_at(uv) == 0, "R leaves pristine surface while mouse remains held")
	main.queue_free()
	await process_frame

func run() -> void:
	test_layout()
	test_contact_damage_and_reset()
	test_exposure_epsilon()
	await test_scene()
	print("P3 TESTS: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
