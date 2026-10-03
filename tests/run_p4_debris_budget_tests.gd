extends "res://tests/run_p4_dirt_tests.gd"
## Real deposition/cleanup and bounded transient lifetime; no mesh-only authority.

func run() -> void:
	var dirt := LooseDebris.new(Vector2i(96, 64))
	var overflow := 0.0
	var supplied := 0.0
	for repeat in range(5):
		for layer in range(3):
			for y in range(0, 24, 8):
				for x in range(0, 24, 8):
					supplied += 8
					overflow += dirt.deposit_removed(x, y, 8, layer)
	check(dirt.cells.size() == 2, "one local budget is shared by repeated excavation and all three materials")
	var retained := 0.0
	var bounded := true
	for amount in dirt.cells.values():
		retained += amount * LooseDebris.STRIDE * LooseDebris.STRIDE
		bounded = bounded and amount <= dirt.profile.crumb_capacity + 0.000001
	check(bounded, "saturated crumbs never grow into persistent chunks")
	check(absf(supplied - overflow - retained) < 0.001 and overflow >= supplied * 0.92,
		"retention cap returns every excess portion to fine dust, without silently deleting it")
	dirt.deposit_removed(24, 0, 8, 2)
	check(dirt.cells.size() == 3, "adjacent bucket has its own budget")
	var stored := dirt.cells.duplicate()
	dirt.advance(120)
	check(dirt.cells == stored, "resting budgeted crumbs persist indefinitely")
	dirt.clean(Vector2(12, 12), Vector2(12, 12), brush, 10)
	check(dirt.cells.is_empty() and dirt.occupancy.is_empty(), "Brush cleanup frees the occupied budget")
	dirt.deposit_removed(16, 16, 8, 1)
	check(dirt.cells.size() == 1, "new excavation can reuse a cleaned local budget")
	dirt.reset()
	check(dirt.cells.is_empty() and dirt.occupancy.is_empty(), "reset releases every budget entry")
	var surface := dirty_fixture(0.6)
	for i in range(150): surface.apply_impact(point + Vector2((i % 5 - 2) * 5, (i / 5 as int % 3 - 1) * 6), chisel)
	var counts: Dictionary = {}
	for key in surface.loose_debris.cells:
		var bucket := surface.loose_debris.bucket_for(key)
		counts[bucket] = counts.get(bucket, 0) + 1
	bounded = true
	for count in counts.values(): bounded = bounded and count <= 2
	check(bounded and not counts.is_empty(), "long real Chisel session never accumulates more than two crumbs per zone")
	check(Array(surface.residue._values).max() > 0.1, "fracturing still leaves persistent Fine Dust")
	var main := load("res://scenes/prototype_main.tscn").instantiate() as Node3D
	root.add_child(main)
	var block: ExcavationBlock = main.get_node("ExcavationBlock")
	main.get_node("ToolController").set_physics_process(false)
	var fx: MaterialFeedback = main.feedback
	var structural := block.working_map.image.get_data()
	var dust := block.working_map.residue.image.get_data()
	for i in range(30):
		fx._emit(1, Vector2(700, 140), 16)
		fx._emit(2, Vector2(700, 140), 16)
	check(fx.particles[1].size() == profile.particles_per_family
		and fx.particles[2].size() == profile.particles_per_family, "repeated chunk emission respects fixed family pools")
	var lifetime_ok := true
	for family in [1, 2]:
		for particle in fx.particles[family]: lifetime_ok = lifetime_ok and particle.life >= 1 and particle.life <= 2
	check(lifetime_ok, "all transient hard chunks live between one and two seconds")
	fx._process(0.9)
	check(not fx.particles[1].is_empty() and not fx.particles[2].is_empty(), "chunks remain visible long enough to fly and bounce")
	fx._process(1.1)
	check(fx.particles[1].is_empty() and fx.particles[2].is_empty(), "hard chunks leave no persistent pile after two seconds")
	check(block.working_map.image.get_data() == structural and block.working_map.residue.image.get_data() == dust
		and block.working_map.loose_debris.cells.is_empty() and block.working_map.fossil.condition == 100,
		"transient creation/bounce/expiry never owns gameplay geometry, dirt or damage")
	block.working_map.loose_debris.deposit_removed(700, 140, 1000, 2)
	fx.loose_view._process(0)
	check(fx.loose_view.multimesh.visible_instance_count == 1, "saturated persistent deposit renders one crumb")
	main.queue_free()
	await process_frame
	print("P4 DEBRIS BUDGET TESTS: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
