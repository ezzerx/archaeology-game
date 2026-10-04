extends "res://tests/run_p4_dirt_tests.gd"
## Third human corrective pass: source-based feedback and readable finishing.

func test_clear_packets() -> void:
	var residue := SurfaceResidue.new(Vector2i(96, 64))
	for p in [Vector2i(12, 12), Vector2i(76, 12), Vector2i(36, 48)]:
		for y in range(p.y, p.y + 8):
			for x in range(p.x, p.x + 8): residue.deposit_removed(x, y, 0.8)
	residue.apply_segment(point, point, 100, 1, 0)
	var initial := residue._values.duplicate()
	var bytes := residue.image.get_data()
	residue.apply_segment(Vector2(0, 32), Vector2(95, 32), 60, 1, 0.3, true)
	var total := 0.0
	var valid_sources := true
	for packet in residue.cleared_packets:
		var p := Vector2i((packet.point + Vector2.ONE * 0.5) / SurfaceResidue.STRIDE)
		var index := p.y * residue.size.x + p.x
		valid_sources = valid_sources and initial[index] > residue._values[index] and packet.amount > 0
		total += packet.amount
	check(valid_sources and residue.cleared_packets.size() > 1 and residue.cleared_packets.size() <= 16,
		"cleanup packets originate in actual dirty islands, never at a clean cursor or centroid")
	check(absf(total - residue.last_cleared) < 0.00001, "bounded packets account for the whole actual cleared quantity")
	check(residue.image.get_data() != bytes, "cleaning changes the persistent rendered R8 state")
	residue.apply_segment(point, point, 60, 1, 0)
	check(residue.cleared_packets.is_empty() and residue.last_cleared == 0, "feedback packets last one action and cannot be replayed at idle")
	var after := residue.image.get_data()
	residue.apply_segment(point, point, 60, 1, 0)
	check(residue.image.get_data() == after, "remaining dust does not fade during idle feedback updates")
	residue.reset()
	check(residue.cleared_packets.is_empty() and residue.image.get_data() == SurfaceResidue.new(Vector2i(96, 64)).image.get_data(),
		"reset clears dust and ephemeral packets exactly")

func test_pick_readability_and_semantics() -> void:
	var pick: ToolDefinition = preload("res://config/precision_pick.tres")
	var removals: Array[float] = []
	for height in [0.6, 0.25]:
		var surface := dirty_fixture(height)
		var original := surface.value_at(cell)
		# One click must work immediately, without movement or long scraping.
		surface.apply_impact(point, pick)
		var removal := original - surface.value_at(cell)
		removals.append(removal)
		check(removal > 0.035, "one stationary Pick click produces immediately visible depth: %.2f" % height)
		check(surface.fracture.stress.is_empty() and surface.last_action.chunks.is_empty(), "visible Pick removal still creates no plate fracture")
	check(removals[0] > removals[1] * 1.5 and removals[1] > 0, "Sandstone remains distinctly harder than Clay with the same finishing gesture")
	check(absf(removals[0] - 0.146666667) < 0.000001 and absf(removals[1] - 0.0825) < 0.000001,
		"human Pick power 0.44 clears strong local depths with unchanged material effectiveness/resistance")
	print("P4 PICK READABILITY: one stationary impact; Clay depth=", removals[0], "; Sandstone depth=", removals[1])
	var flake := LooseDebrisView.crumb_mesh().surface_get_arrays(0)
	var outward := true
	for i in range(flake[Mesh.ARRAY_VERTEX].size()):
		var v: Vector3 = flake[Mesh.ARRAY_VERTEX][i]
		if absf(v.y) > 0.49: outward = outward and flake[Mesh.ARRAY_NORMAL][i].y * v.y > 0
	check(outward, "detached flake has outward faces for visible shaded top and bottom")
	var surface := dirty_fixture(0.25)
	surface.loose_debris.deposit_removed(48, 32, 8, 1)
	var key: Vector3i = surface.loose_debris.cells.keys()[0]
	var at := surface.loose_debris.point_for(key)
	var crumbs := surface.loose_debris.cells.duplicate()
	var before := surface.image.get_data()
	surface.apply_impact(at, pick)
	check(surface.image.get_data() != before and surface.loose_debris.cells[key] >= crumbs[key],
		"Pick works the attached substrate below a crumb without pretending to clean that crumb")
	check(surface.loose_debris.nearby_count(at) > 0, "bounded dev inspection detects a detached crumb at its actual position")
	before = surface.image.get_data()
	surface.apply_continuous(at, at, brush, 1)
	check(surface.image.get_data() == before and not surface.loose_debris.cells.has(key),
		"Brush visibly removes detached Clay crumb on Stone without editing underlying structure")
	surface.loose_debris.deposit_removed(48, 32, 8, 2)
	surface.apply_continuous(at - Vector2.RIGHT, at, blower, 1)
	check(surface.image.get_data() == before and not surface.loose_debris.flying.is_empty(),
		"Blower launches detached crumb without structural removal")

func test_lift_off() -> void:
	var main := load("res://scenes/prototype_main.tscn").instantiate() as Node3D
	root.add_child(main)
	main.set_process(false)
	main.controller.set_physics_process(false)
	var surface: WorkingSurface = main.block.working_map
	var fx: MaterialFeedback = main.feedback
	var p := Vector2(700, 140)
	for y in range(128, 145):
		for x in range(672, 685): surface.residue.deposit_removed(x, y, 0.8)
	surface.residue.apply_segment(p, p, 60, 1, 0)
	var geometry := surface.image.get_data()
	var condition := surface.fossil.condition
	surface.apply_continuous(p - Vector2.RIGHT, p, blower, 0.1)
	check(not surface.last_action.cleared_dust.is_empty() and not fx.particles[3].is_empty(), "real Blower action routes cleared dust into lift-off effects")
	var origins_valid := true
	var directions_valid := true
	var total := 0.0
	for particle in fx.particles[3]:
		origins_valid = origins_valid and particle.source.x < 686 and particle.source.x > 670
		directions_valid = directions_valid and particle.velocity.x > 0.12 and particle.velocity.y > 0
		total += particle.amount
	check(origins_valid, "dust starts in the offset dirty patch, not at the clean cursor")
	check(directions_valid and absf(total - surface.residue.last_cleared) < 0.0001, "lift and direction follow the jet; emitted amount follows actual cleanup")
	var first: Vector3 = fx.particles[3][0].position
	fx._process(0.15)
	check(fx.particles[3][0].position.x > first.x + 0.01 and fx.particles[3][0].position.y > first.y,
		"lifted dust travels visibly before disappearing")
	var dust := surface.residue.image.get_data()
	fx._process(2)
	check(fx.particles[3].is_empty() and surface.residue.image.get_data() == dust,
		"lift-off effects expire while the remaining persistent dust stays unchanged")
	check(surface.image.get_data() == geometry and surface.fossil.condition == condition,
		"cleanup and airborne feedback never edit structure or Bone Condition")
	fx.reset()
	fx._lift_dust([{"point": p, "amount": 0.02}], Vector2.RIGHT)
	var small: Vector3 = fx.particles[3][0].shape
	fx.reset()
	fx._lift_dust([{"point": p, "amount": 0.2}], Vector2.RIGHT)
	check(fx.particles[3][0].shape.x > small.x * 2, "more actual dust produces a larger visible puff within the same pool")
	for i in range(100): fx._lift_dust([{"point": p, "amount": 0.1}], Vector2.RIGHT)
	check(fx.particles[3].size() == profile.particles_per_family, "massive cleanup cannot grow beyond the fixed AirDust pool")
	surface.reset()
	check(fx.particles[3].is_empty() and surface.residue.cleared_packets.is_empty(), "R clears persistent dust and all lift-off feedback")
	main.queue_free()
	await process_frame

func run() -> void:
	test_clear_packets()
	test_pick_readability_and_semantics()
	await test_lift_off()
	print("P4 FEEDBACK TESTS: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
