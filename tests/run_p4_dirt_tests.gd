extends "res://tests/run_p4_tests.gd"
## Persistent dirt is independent of the structural field and transient effects.

func dirty_fixture(height: float) -> WorkingSurface:
	var surface := fixture(height)
	surface.loose_debris = LooseDebris.new(surface.size)
	return surface

func run() -> void:
	for height in [0.9, 0.6, 0.25]:
		var surface := dirty_fixture(height)
		var twin := dirty_fixture(height)
		for i in range(4):
			surface.apply_impact(point, chisel)
			twin.apply_impact(point, chisel)
		check(not surface.loose_debris.cells.is_empty(), "excavation reaching hard material creates detached crumbs")
		check(surface.loose_debris.cells == twin.loose_debris.cells and surface.residue._values == twin.residue._values,
			"identical excavation produces deterministic persistent dirt")
		var cells := surface.loose_debris.cells.duplicate()
		var dust := surface.residue.image.get_data()
		for i in range(600): surface.loose_debris.advance(1.0 / 60.0)
		check(surface.loose_debris.cells == cells and surface.residue.image.get_data() == dust,
			"resting crumbs and dust do not age away after ten seconds")
		surface.reset()
		check(surface.loose_debris.cells.is_empty() and surface.loose_debris.flying.is_empty()
			and surface.residue._values == fixture().residue._values, "reset clears both dirt representations exactly")

	var surface := dirty_fixture(0.25)
	for i in range(4): surface.apply_impact(point, chisel)
	var structural := surface.image.get_data()
	var dirty_count := surface.loose_debris.cells.size()
	for i in range(180): surface.apply_continuous(point, point, brush, 1.0 / 60.0)
	check(surface.image.get_data() == structural, "Brush never gains structural Sandstone removal")
	check(surface.loose_debris.cells.size() < dirty_count, "Brush polishes detached stone crumbs safely")
	var ejections: Array = []
	surface.loose_debris.ejected.connect(func(p, d, amount, layer): ejections.append([p, d, amount, layer]))
	surface.loose_debris.deposit_removed(48, 32, 32, 2)
	surface.residue.deposit_removed(48, 32, 8)
	surface.residue.apply_segment(point, point, 60, 1, 0)
	var before_dust := surface.residue.value_at((point + Vector2.ONE * 0.5) / Vector2(surface.size))
	var mass := 0.0
	for value in surface.loose_debris.cells.values(): mass += value
	surface.dirty = false
	for i in range(60): surface.apply_continuous(point - Vector2.RIGHT, point, blower, 1.0 / 60.0)
	check(surface.image.get_data() == structural and not surface.dirty, "blower neither edits nor dirties any structural byte")
	check(surface.residue.value_at((point + Vector2.ONE * 0.5) / Vector2(surface.size)) < before_dust,
		"blower removes fine dust")
	check(not surface.loose_debris.flying.is_empty(), "blower launches detached material visibly along the jet")
	var flying_before: Vector2 = surface.loose_debris.flying[0].point
	surface.loose_debris.advance(0.02)
	check(surface.loose_debris.flying[0].point.x > flying_before.x
		and surface.loose_debris.flying[0].point.y == flying_before.y, "jet follows tool movement in map space")
	surface.loose_debris.advance(10)
	check(surface.loose_debris.flying.is_empty() and not ejections.is_empty(), "EJECTING flight expires after logical evacuation")
	var exited_mass := 0.0
	var valid_exits := true
	for event in ejections:
		exited_mass += event[2]
		valid_exits = valid_exits and event[0].x >= -0.5 and event[0].x <= 95.5 and event[1] == Vector2.RIGHT and event[2] > 0 and event[3] in [0, 1, 2]
	for value in surface.loose_debris.cells.values(): exited_mass += value
	check(valid_exits and absf(mass - exited_mass) < 0.0001, "ejection position/direction/material and accumulated amount are coherent")
	var packets := LooseDebris.new(Vector2i(1024, 640))
	packets.deposit_removed(512, 320, 64, 2)
	for i in range(12):
		packets.clean(Vector2(511, 320), Vector2(512, 320), blower, 1.0 / 60.0)
		packets.advance(1.0 / 60.0)
	check(packets.flying.size() < 8 and not packets.flying.is_empty(),
		"one logical evacuation creates one temporary directional flight")

	var main := load("res://scenes/prototype_main.tscn").instantiate() as Node3D
	root.add_child(main)
	var block: ExcavationBlock = main.get_node("ExcavationBlock")
	main.get_node("ToolController").set_physics_process(false)
	var fx: MaterialFeedback = main.feedback
	block.working_map.apply_continuous(Vector2(700, 140), Vector2(720, 140), brush, 0.1)
	var cells := block.working_map.loose_debris.cells.duplicate()
	var dust := block.working_map.residue.image.get_data()
	fx._process(4)
	fx.loose_view._process(0)
	check(fx.particles[0].is_empty() and cells.is_empty() and fx.loose_view.multimesh.visible_instance_count == 0 and Array(block.working_map.residue._values).max() == 0,
		"Soil Brush leaves no persistent dust or grains")
	check(block.working_map.loose_debris.cells == cells and block.working_map.residue.image.get_data() == dust,
		"transient FX cannot erase persistent dirt")
	block.flush_texture() # Commit the preceding Brush edit before measuring Blower.
	var uploads := block.upload_count
	var condition := block.working_map.fossil.condition
	# Legacy F3 OFF hook: explicit Matrix dirt, Soil is dust-only.
	fx.crumb_physics_enabled = false
	block.working_map.loose_debris.deposit_removed(712, 140, 16, 1)
	var world_events: Array = []
	block.debris_ejected.connect(func(p, d, amount, material): world_events.append([p, d, amount, material]))
	block.working_map.apply_continuous(Vector2(690, 140), Vector2(720, 140), blower, 1)
	block.working_map.loose_debris.advance(20)
	block.flush_texture()
	check(block.upload_count == uploads and block.working_map.fossil.condition == condition,
		"production blower emits no height upload and causes no bone damage")
	check(not world_events.is_empty() and absf(world_events[0][0].x) < block.surface_size.x * 0.5
		and world_events[0][1].is_equal_approx(Vector3.RIGHT) and world_events[0][3] == &"compact_clay",
		"future debris_ejected hook uses cleanup world coordinates and material id")
	block.working_map.reset()
	check(fx.loose_view.multimesh.visible_instance_count == 0 and block.working_map.loose_debris.flying.is_empty(),
		"R clears settled and airborne visuals immediately")
	fx.loose_view._process(0)
	check(block.working_map.loose_debris.dirty_cells.is_empty(), "idle dirt renderer has no persistent update backlog")
	main.queue_free()
	await process_frame
	print("P4 DIRT TESTS: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
