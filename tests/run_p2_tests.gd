extends SceneTree
## Independent numerical checks and production input routing. No testing addon.

var checks := 0
var failures := 0
var brush: ToolDefinition = preload("res://config/soft_brush.tres")
var chisel: ToolDefinition = preload("res://config/chisel.tres")
var blower: ToolDefinition = preload("res://config/air_blower.tres")
var definitions: Array[MaterialDefinition] = [preload("res://config/loose_soil.tres"),
	preload("res://config/compact_clay.tres"), preload("res://config/sandstone.tres")]
var centre := Vector2(48, 32)
var cell := Vector2i(48, 32)
var main: Node3D
var block: ExcavationBlock
var controller: ToolController
var camera: Camera3D

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + description)

func surface_at(height: float = 1.0) -> WorkingSurface:
	var result := WorkingSurface.new(Vector2i(96, 64))
	# Set the central height via the P0 API, then enable P1 strata.
	result.apply_segment(centre, centre, 10000, 1.0, 1.0, 1.0 - height)
	result.strata = Stratigraphy.new(result.size, definitions)
	result.dirty = false
	return result

func test_definitions() -> void:
	check([brush.id, chisel.id, blower.id] == [&"soft_brush", &"chisel", &"air_blower"], "three named resource profiles")
	check(brush.interaction_mode == ToolDefinition.InteractionMode.CONTINUOUS and blower.interaction_mode == ToolDefinition.InteractionMode.CONTINUOUS, "continuous brush and blower")
	check(chisel.interaction_mode == ToolDefinition.InteractionMode.IMPACT, "chisel impact profile")
	check(brush.radius == 40 and chisel.radius == 22 and blower.radius == 60, "P4 human-validated nominal footprints")
	check(chisel.cadence >= 4 and chisel.cadence <= 5, "nominal chisel cadence")
	check(brush.effectiveness == Vector3(1, 0.06, 0), "brush material table")
	check(chisel.effectiveness.y > chisel.effectiveness.x and chisel.effectiveness.z > 0, "chisel material table")
	check(blower.effectiveness == Vector3.ZERO and blower.power == 0, "blower structural zeros")
	check(blower.residue_clear > brush.residue_clear * 10, "blower clears far more strongly")
	check(brush.effectiveness_for(&"missing") == 0, "unknown material is not excavated")
	for tool in [brush, chisel, blower]:
		for material in definitions:
			var expected: float = tool.power * tool.effectiveness_for(material.id) / material.resistance
			if tool == chisel:
				expected *= tool.cadence
			check(is_equal_approx(tool.structural_rate(material), expected), "debug rate matches work/resistance for %s/%s" % [tool.id, material.id])
	var bounded := ToolDefinition.new()
	bounded.radius = -1
	bounded.power = -1
	bounded.falloff = 0
	bounded.cadence = 0
	bounded.effectiveness = Vector3(-1, 0, 100)
	bounded.residue_clear = -1
	bounded.residue_generation = 100
	check(bounded.radius == 1 and bounded.power == 0 and bounded.falloff == 0.25 and bounded.cadence == 0.1, "lower parameter bounds")
	check(bounded.effectiveness == Vector3(0, 0, 8) and bounded.residue_clear == 0 and bounded.residue_generation == 20, "material/residue bounds")
	bounded.radius = 500
	bounded.power = 500
	bounded.falloff = 500
	bounded.cadence = 500
	check(bounded.radius == 128 and bounded.power == 5 and bounded.falloff == 8 and bounded.cadence == 20, "upper parameter bounds")

func test_materials_and_residue() -> void:
	# P4-V layers are no longer near fixed 0.70/0.36 heights. Start within
	# local Clay with enough thickness for the unchanged 0.64/3 work check.
	var clay_height := surface_at().strata.boundaries.get_pixelv(cell).r - 0.01
	var soil := surface_at()
	var clay := surface_at(clay_height)
	var stone := surface_at(0.2)
	var stone_bytes := stone.image.get_data()
	soil.apply_continuous(centre, centre, brush, 0.1)
	clay.apply_continuous(centre, centre, brush, 0.1)
	stone.apply_continuous(centre, centre, brush, 30)
	var soil_removed := 1.0 - soil.value_at(cell)
	var clay_removed := clay_height - clay.value_at(cell)
	check(absf(soil_removed - 0.07) < 0.000001, "brush removes soil at P4 baseline 0.70 depth/s")
	check(absf(clay_removed - 0.0014) < 0.000001 and soil_removed / clay_removed > 49, "brush Soil is 50x Clay")
	check(stone.image.get_data() == stone_bytes and not stone.dirty, "brush never excavates Sandstone, even a long tick")
	check(stone.residue.value_at(Vector2(0.5, 0.5)) == 0, "ineffective brush creates no residue")
	var crossing := surface_at()
	crossing.apply_continuous(centre, centre, brush, 1000)
	var floor_limit := crossing.strata.boundaries.get_pixelv(cell).g
	check(crossing.value_at(cell) == floor_limit, "long brush tick stops exactly at Sandstone interface")
	soil = surface_at()
	clay = surface_at(clay_height)
	stone = surface_at(0.2)
	soil.apply_impact(centre, chisel)
	clay.apply_impact(centre, chisel)
	stone.apply_impact(centre, chisel)
	check(absf(1.0 - soil.value_at(cell) - 0.0768) < 0.000001, "chisel weak on soil")
	check(absf(clay_height - clay.value_at(cell) - 0.64 / 3.0) < 0.000001, "chisel suited to clay")
	check(absf(0.2 - stone.value_at(cell) - 0.12) < 0.000001, "chisel useful on Sandstone")
	check(chisel.structural_rate(definitions[1]) > brush.structural_rate(definitions[1]) * 20, "chisel clay rate over 20x brush")
	var initial_residue := surface_at().residue.image.get_data()
	check(clay.residue.image.get_data() != initial_residue, "actual excavation creates visible residue")
	var twin := surface_at(clay_height)
	twin.apply_impact(centre, chisel)
	check(clay.residue.image.get_data() == twin.residue.image.get_data() and clay.residue._values == twin.residue._values, "residue deterministic including sub-byte accumulation")
	# Keep both deposits below saturation to compare generation per removed depth.
	var residue_tool := chisel.duplicate() as ToolDefinition
	residue_tool.power = 0.12
	var rich_deposit := surface_at(clay_height)
	rich_deposit.apply_impact(centre, residue_tool)
	var weak_deposit := residue_tool.duplicate() as ToolDefinition
	weak_deposit.residue_generation = brush.residue_generation
	twin = surface_at(clay_height)
	twin.apply_impact(centre, weak_deposit)
	var uv := (Vector2(cell) + Vector2.ONE * 0.5) / Vector2(clay.size)
	check(rich_deposit.residue.value_at(uv) > twin.residue.value_at(uv) * 5, "chisel produces more residue per removed depth")
	var height_bytes := clay.image.get_data()
	var boundaries := clay.strata.boundaries.get_data()
	var dirty_height := clay.dirty
	var before := clay.residue.value_at(uv)
	var slow_cleaner := brush.duplicate() as ToolDefinition
	slow_cleaner.power = 0
	var lightly_cleaned := surface_at(clay_height)
	lightly_cleaned.apply_impact(centre, chisel)
	lightly_cleaned.apply_continuous(centre, centre, slow_cleaner, 0.1)
	check(lightly_cleaned.residue.value_at(uv) < before and lightly_cleaned.residue.value_at(uv) > before - 0.02, "brush can gently clean existing residue")
	clay.dirty = false
	clay.apply_continuous(centre, centre, blower, 0.1)
	check(clay.residue.value_at(uv) < before - 0.2, "blower strongly clears residue")
	for i in range(120):
		clay.apply_continuous(centre, centre, blower, 1.0 / 60.0)
	check(clay.residue.value_at(uv) == 0, "blower reaches exact zero residue")
	check(clay.image.get_data() == height_bytes and not clay.dirty, "blower leaves height byte exact and clean")
	check(clay.strata.boundaries.get_data() == boundaries and dirty_height, "residue never moves geological interfaces")
	var high_power_air := blower.duplicate() as ToolDefinition
	high_power_air.power = 5
	clay.apply_continuous(centre, centre, high_power_air, 10)
	check(clay.image.get_data() == height_bytes and not clay.dirty, "debug power cannot turn blower into an excavator")
	var pristine := surface_at()
	var initial_height := pristine.image.get_data()
	var initial_values := pristine.residue._values.to_byte_array()
	pristine.apply_impact(centre, chisel)
	pristine.reset()
	check(pristine.image.get_data() == initial_height and pristine.residue.image.get_data() == initial_residue, "byte-exact height and R8 reset")
	check(pristine.residue._values.to_byte_array() == initial_values, "reset clears fractional CPU residue too")
	var full := WorkingSurface.new()
	check(full.residue.size == Vector2i(256, 160) and full.residue.image.get_data_size() == 40960, "residue payload is 40 KiB, 64x smaller than height RF")
	# A single tiny removal is not quantized away in CPU state.
	full.residue.deposit_removed(100, 100, 0.0001)
	check(full.residue._cell_value(Vector2i(25, 25)) > 0, "fractional residue survives below R8 resolution")
	var residue_bounds := true
	for value in lightly_cleaned.residue._values:
		residue_bounds = residue_bounds and value >= 0 and value <= 1
	check(residue_bounds, "CPU residue stays within 0..1")
	# Independent mass check on unsaturated soil: generation follows actual removal.
	var deposited := surface_at()
	deposited.apply_impact(centre, chisel)
	var removed_sum := 0.0
	for h in deposited.image.get_data().to_float32_array(): removed_sum += 1.0 - h
	var residue_sum := 0.0
	for value in deposited.residue._values: residue_sum += value
	check(absf(residue_sum * 16.0 - removed_sum * chisel.residue_generation) < 0.001, "coarse residue conserves generated removal before saturation")

func test_tool_oracle() -> void:
	var size := Vector2i(32, 20)
	var strata := Stratigraphy.new(size, definitions)
	var start := Vector2(2.2, 3.6)
	var end := Vector2(28.8, 16.4)
	for profile in [brush, chisel, blower]:
		var tool := profile.duplicate() as ToolDefinition
		tool.radius = 6.3
		var surface := WorkingSurface.new(size, strata)
		var reference := surface.image.duplicate() as Image
		for delta in [0.04, 0.4, 0.9, 3.0, 10.0]:
			var from := end if profile == chisel else start
			var amount: float = 1.0 if profile == chisel else delta
			if profile == chisel:
				surface.apply_impact(end, tool)
			else:
				surface.apply_continuous(start, end, tool, delta)
			for y in range(size.y):
				for x in range(size.x):
					var p := Vector2(x, y)
					var nearest := Geometry2D.get_closest_point_to_segment(p, from, end)
					var work := tool.power * amount * WorkingSurface.weight(p.distance_to(nearest) / tool.radius, tool.falloff)
					var h := strata.remove_work(reference.get_pixel(x, y).r, work, Vector2i(x, y), tool.effectiveness)
					reference.set_pixel(x, y, Color(h, 0, 0))
		var error := 0.0
		for y in range(size.y):
			for x in range(size.x):
				error = maxf(error, absf(reference.get_pixel(x, y).r - surface.value_at(Vector2i(x, y))))
		check(error < 0.00001, "tool surface agrees with independent layer/capsule oracle: %s" % profile.id)
	var impacts := surface_at()
	impacts.apply_impact(Vector2(16, 32), chisel)
	impacts.apply_impact(Vector2(80, 32), chisel)
	check(impacts.value_at(cell) == 1 and impacts.residue.value_at(Vector2(0.5, 0.5)) == 0, "separate impacts leave middle height and residue untouched")
	impacts.apply_continuous(Vector2(16, 32), Vector2(80, 32), brush, 0.1)
	check(impacts.value_at(cell) < 1, "brush sweeps the whole fast segment")
	var swept := surface_at()
	for x in range(8, 89, 8): swept.apply_impact(Vector2(x, 32), chisel)
	var height_before := swept.image.get_data()
	swept.apply_continuous(Vector2(8, 32), Vector2(88, 32), blower, 1.0)
	var clean_path := true
	for x in range(8, 89):
		clean_path = clean_path and swept.residue.value_at((Vector2(x, 32) + Vector2.ONE * 0.5) / Vector2(swept.size)) == 0
	check(clean_path and swept.image.get_data() == height_before, "fast blower sweep clears continuously without height changes")
	# Uneven dimensions still map the last height texel to the last residue cell.
	var edge := WorkingSurface.new(Vector2i(97, 65))
	edge.apply_impact(Vector2(96, 64), chisel)
	check(edge.residue.size == Vector2i(25, 17) and edge.residue.image.get_pixel(24, 16).r > 0, "partial residue edge tiles are included")

func test_cadence() -> void:
	for hz in [30, 60, 144]:
		var clock := ImpactClock.new()
		var count := 0
		for tick in range(hz * 20):
			count += clock.advance(1.0 / hz, chisel.cadence)
		check(count == 90, "4.5 Hz gives 90 impacts / 20 seconds at %d Hz" % hz)
	var clock := ImpactClock.new()
	check(clock.advance(0, 4.5) == 0, "zero elapsed time schedules nothing")
	check(clock.advance(1.0 / 60, 4.5) == 1, "first impact is immediate")
	check(clock.time_to_next(4.5) > 0.2, "next impact timing is exposed")
	var impact_ticks: Array[int] = [0]
	for tick in range(1, 120):
		if clock.advance(1.0 / 60, 4.5) > 0:
			impact_ticks.append(tick)
	check(impact_ticks == [0, 13, 26, 40, 53, 66, 80, 93, 106], "60 Hz tick sequence retains fractional cadence phase")
	clock.reset()
	check(clock.advance(2.0, 4.5) == 9 and clock.advance(0, 4.5) == 0, "large timestep emits each due impact once")
	clock.reset()
	check(clock.emitted == 0 and clock.elapsed == 0, "cadence cancellation forgets previous tool timing")

func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	root.push_input(event, true)

func move(screen: Vector2) -> void:
	var event := InputEventMouseMotion.new()
	event.position = screen
	root.push_input(event, true)

func press(screen: Vector2) -> void:
	move(screen)
	var event := InputEventMouseButton.new()
	event.position = screen
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	root.push_input(event, true)

func tick() -> void:
	controller._physics_process(1.0 / 60.0)

func test_input() -> void:
	root.size = Vector2i(1920, 1080)
	main = load("res://scenes/prototype_main.tscn").instantiate()
	root.add_child(main)
	block = main.get_node("ExcavationBlock")
	controller = main.get_node("ToolController")
	camera = main.get_node("Camera3D")
	controller.set_physics_process(false)
	await process_frame
	controller._focused = true
	controller._pointer_inside = true
	var left := camera.unproject_position(Vector3(-0.3, block.thickness, 0))
	var right := camera.unproject_position(Vector3(0.3, block.thickness, 0))
	for pair in [[KEY_2, 1], [KEY_3, 2], [KEY_1, 0]]:
		key(pair[0])
		check(controller.selected_index == pair[1], "keyboard selects slot %d" % (pair[1] + 1))
		check(main.get_node("Debug/Toolbar").get_child(pair[1]).button_pressed, "toolbar selected state follows key")
	check(not controller.select_tool(-1) and not controller.select_tool(controller.tools.size()) and controller.selected_index == 0, "invalid selections are harmless")
	check(controller.config != brush, "scene duplicates shared tool resources")
	press(left)
	tick()
	var edited := block.working_map.image.get_data()
	var residue_edited := block.working_map.residue.image.get_data()
	key(KEY_2)
	move(right)
	for i in range(30): tick()
	check(controller.config.id == &"chisel" and block.working_map.image.get_data() == edited, "held switch selects immediately without new-tool excavation")
	check(block.working_map.residue.image.get_data() == residue_edited and controller.total_impacts == 0, "held switch creates no residue or impact")
	press(right)
	tick()
	check(controller.total_impacts == 1 and block.working_map.value_at(Vector2i(512, 320)) == 1, "fresh click chisel has no cross-tool bridging")
	controller.reset_surface()
	press(left)
	tick()
	move(right)
	for i in range(13): tick()
	check(controller.total_impacts == 2 and block.working_map.value_at(Vector2i(512, 320)) == 1, "moving held chisel impacts without bridging")
	check(block.working_map.value_at(Vector2i(791, 320)) < 1, "second impact uses current cursor relief pick")
	for tool_index in range(3):
		controller.select_tool(tool_index)
		controller.reset_surface()
		press(left)
		tick()
		for notification in [Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT, Node.NOTIFICATION_WM_MOUSE_EXIT]:
			controller._notification(notification)
			var saved_height := block.working_map.image.get_data()
			var saved_residue := block.working_map.residue.image.get_data()
			tick()
			check(not controller.hit.inside and not controller._held, "focus/window loss cancels tool %d" % tool_index)
			controller._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_IN)
			controller._notification(Node.NOTIFICATION_WM_MOUSE_ENTER)
			move(right)
			for i in range(20): tick()
			check(block.working_map.image.get_data() == saved_height and block.working_map.residue.image.get_data() == saved_residue, "no resume after missed outside release, tool %d" % tool_index)
			press(left)
			tick()
		key(KEY_R)
		for i in range(20): tick()
		check(block.working_map.value_at(Vector2i(233, 320)) == 1 and block.working_map.residue.value_at(Vector2(0.23, 0.5)) == 0 and not controller._held, "R restores and disarms held tool %d" % tool_index)
	controller.select_tool(2)
	block.working_map.apply_impact(Vector2(512, 320), chisel)
	block.flush_texture()
	var uploads := block.upload_count
	var residue_uploads := block.residue_upload_count
	press(camera.unproject_position(Vector3(0, block.thickness, 0)))
	for i in range(30): tick()
	check(block.upload_count == uploads and block.residue_upload_count > residue_uploads, "blower uploads only the small residue map")
	controller.cancel_stroke()
	residue_uploads = block.residue_upload_count
	tick()
	check(block.residue_upload_count == residue_uploads, "no residue upload at idle")
	# Real UI event routing, including re-clicking the active slot.
	var button: Button = main.get_node("Debug/Toolbar").get_child(0)
	press(button.get_global_rect().get_center())
	var release := InputEventMouseButton.new()
	release.position = button.get_global_rect().get_center()
	release.button_index = MOUSE_BUTTON_LEFT
	root.push_input(release, true)
	await process_frame
	check(controller.selected_index == 0 and button.button_pressed and not controller._held, "clickable toolbar consumes click and selects brush")
	press(button.get_global_rect().get_center())
	root.push_input(release.duplicate(), true)
	check(button.button_pressed, "clicking active toolbar slot keeps selected state")
	controller.reset_surface()
	press(left)
	tick()
	move(Vector2(10, 900))
	tick()
	move(right)
	tick()
	check(block.working_map.value_at(Vector2i(512, 320)) == 1, "brush block exit/reentry never bridges")
	root.size = Vector2i(1280, 800)
	await process_frame
	controller._update_pointer_position()
	check(not controller._previous_valid and controller.impact_clock.emitted == 0, "resize clears old screen mapping and cadence")
	controller.cancel_stroke()
	var target := Vector3(0.05, block.relief.height_at(Vector2(0.5 + 0.05 / 1.1, 0.5)), 0)
	var hit := block.pick(camera.unproject_position(target), camera)
	check(hit.inside and hit.local.distance_to(target) < 0.00001, "resized viewport still uses exact relief pick")
	main.queue_free()
	await process_frame

func run() -> void:
	test_definitions()
	test_materials_and_residue()
	test_tool_oracle()
	test_cadence()
	await test_input()
	print("P2 TESTS: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
