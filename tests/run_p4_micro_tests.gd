extends "res://tests/run_p4_closure_tests.gd"
## Product contracts for final micro-pass, independent of the old border oracle.
const DEFINITIONS: Array[MaterialDefinition] = [preload("res://config/loose_soil.tres"), preload("res://config/compact_clay.tres"), preload("res://config/sandstone.tres")]
const BRUSH: ToolDefinition = preload("res://config/soft_brush.tres")
const BLOWER: ToolDefinition = preload("res://config/air_blower.tres")

func micro_fixture(layer: int) -> WorkingSurface:
	var s := WorkingSurface.new(Vector2i(96, 64), Stratigraphy.new(Vector2i(96, 64), DEFINITIONS), null, preload("res://config/material_reactions.tres"))
	for i in range(s._heights.size()): s._heights[i] = MicroRemnant.bottom(s, i, layer)
	sync(s)
	return s

func sync(s: WorkingSurface) -> void:
	s.image.set_data(s.size.x, s.size.y, false, Image.FORMAT_RF, s._heights.to_byte_array())
	s.dirty = true

func island(s: WorkingSurface, p: Vector2i, layer: int, depth_m: float, footprint := Vector2i.ONE) -> void:
	for y in range(p.y, p.y + footprint.y):
		for x in range(p.x, p.x + footprint.x):
			var i := y * s.size.x + x
			s._heights[i] = MicroRemnant.bottom(s, i, layer) + depth_m / s.excavatable_depth
	sync(s)

func test_micro() -> void:
	for layer in [1, 2]:
		var s := micro_fixture(layer)
		island(s, Vector2i(38, 30), layer, 0.006, Vector2i(3, 3))
		island(s, Vector2i(56, 32), layer, 0.0012)
		var thick := s._heights[31 * 96 + 39]
		s.apply_continuous(Vector2(48, 32), Vector2(48, 32), BRUSH, DT)
		check(s._heights[31 * 96 + 39] == thick, "side-by-side thick attached material unchanged: %d" % layer)
		check(s._heights[32 * 96 + 56] == MicroRemnant.bottom(s, 32 * 96 + 56, layer) and s.last_micro_cells == 1, "thin isolated remnant detaches exactly to interface: %d" % layer)
		check(s.loose_debris.layer_counts[layer] == 1 and s.loose_debris.cells.values()[0] > 0, "detachment produces actual Matrix crumb: %d" % layer)
		check(s.last_action.chunks.is_empty() and s.fracture.stress.is_empty() and not s.last_action.direct_bone_hit, "no Chisel reaction or damage path: %d" % layer)
		s.apply_continuous(Vector2(56, 32), Vector2(56, 32), BRUSH, DT)
		check(s.loose_debris.cells.is_empty(), "following Brush tick cleans the detached tiny mess: %d" % layer)
		for kind in ["thick", "large", "diagonal", "thin_sheet"]:
			s = micro_fixture(layer)
			if kind == "thin_sheet": island(s, Vector2i(20, 20), layer, 0.001, Vector2i(50, 25))
			elif kind == "large": island(s, Vector2i(46, 32), layer, 0.001, Vector2i(5, 1))
			elif kind == "thick": island(s, Vector2i(48, 32), layer, 0.0021)
			else:
				island(s, Vector2i(48, 32), layer, 0.001)
				island(s, Vector2i(49, 33), layer, 0.006)
			var before := s.image.get_data()
			for tick in range(12): s.apply_continuous(Vector2(48, 32), Vector2(48, 32), BRUSH, 0.25)
			check(s.image.get_data() == before and s.loose_debris.cells.is_empty(), "rejects %s, no iterative Brush erosion: %d" % [kind, layer])
			check(s.last_micro_probes <= 64, "bounded local inspection budget: %s" % kind)
		s = micro_fixture(layer)
		island(s, Vector2i(48, 32), layer, 0.0015, Vector2i(2, 2))
		s.apply_continuous(Vector2(48, 32), Vector2(48, 32), BRUSH, DT)
		check(s.last_micro_cells == 4 and s.loose_debris.persistent_count() == 1, "2x2 island at maximum depth becomes one crumb: %d" % layer)
		# A full remote cap must not silently erase a local structural island.
		s = micro_fixture(layer)
		s.loose_debris.profile = s.loose_debris.profile.duplicate()
		s.loose_debris.profile.matrix_crumb_cap = 1
		s.loose_debris.deposit_removed(0, 0, 16, layer)
		island(s, Vector2i(56, 32), layer, 0.0012)
		var blocked_height := s._heights[32 * 96 + 56]
		s.apply_continuous(Vector2(56, 32), Vector2(56, 32), BRUSH, DT)
		check(s._heights[32 * 96 + 56] == blocked_height and s.last_micro_cells == 0,
			"cap refusal preserves structural remnant: %d" % layer)
		var remote := s.loose_debris.point_for(s.loose_debris.cells.keys()[0])
		s.loose_debris.clean(remote, remote, BLOWER, 0.1)
		s.apply_continuous(Vector2(56, 32), Vector2(56, 32), BRUSH, DT)
		check(s.last_micro_cells == 1 and s.loose_debris.flying.size() == 1 and s.loose_debris.persistent_count() == 1,
			"cleanup immediately permits detachment while old FX remains: %d" % layer)

func test_cleanup() -> void:
	for enabled in [false, true]:
		var dirt := dirt_fixture()
		dirt.physics_enabled = enabled
		dirt.deposit_removed(128, 80, 16, 2)
		step_dirt(dirt, 120)
		var key: Vector3i = dirt.cells.keys()[0]
		var p := dirt.point_for(key)
		var events: Array = []
		dirt.physical_ejected.connect(func(at, direction, amount, layer): events.append([at, direction, amount, layer]))
		# Repeated grazing outside minimum weight cannot commit cleanup.
		for tick in range(30):
			dirt.clean(p + Vector2(59, 0), p + Vector2(59, 0), BLOWER, DT)
			dirt.advance(DT)
		check(dirt.persistent_count() == 1 and events.is_empty(), "edge glances never evacuate: ON=%s" % enabled)
		dirt.clean(p, p, BLOWER, DT)
		dirt.advance(0.3)
		check(dirt._jet_charge.is_empty() and dirt.persistent_count() == 1, "single-frame exposure forgotten without cleanup: ON=%s" % enabled)
		for tick in range(6): dirt.clean(p - Vector2.RIGHT, p, BLOWER, DT)
		check(dirt.persistent_count() == 0 and dirt.physics.active_count == 0 and dirt.occupancy.is_empty(), "commit releases logical/physical/local budgets immediately: ON=%s" % enabled)
		check(dirt.flying.size() == 1 and events.size() == 1 and dirt.evacuated_count == 1, "one EJECTING visual, one notification: ON=%s" % enabled)
		var at: Vector3 = dirt.flying[0].position
		dirt.advance(0.1)
		check(dirt.flying[0].position.x > at.x and dirt.flying[0].position.y > at.y, "visible directional flight with small lift: ON=%s" % enabled)
		for tick in range(30):
			dirt.clean(p, p, BLOWER, DT)
			dirt.advance(DT)
		check(dirt.flying.is_empty() and events.size() == 1, "FX expires without another ejection or cap mutation: ON=%s" % enabled)

func test_production_micro() -> void:
	var main := load("res://scenes/prototype_main.tscn").instantiate() as Node3D
	root.add_child(main)
	main.controller.set_physics_process(false)
	main.set_process(false)
	var s: WorkingSurface = main.block.working_map
	var dirt := s.loose_debris
	# Hard dust far from the Soil stroke must not be regenerated or altered.
	s.residue.deposit_removed(900, 580, 8)
	s.residue.apply_segment(Vector2(900, 580), Vector2(900, 580), 10, 1, 0)
	var original_dust := s.residue._values.duplicate()
	for tick in range(1200):
		var p := Vector2(120 + (tick % 400) * 1.9, 120 + (tick / 400 as int) * 120)
		s.apply_continuous(p - Vector2.RIGHT * 1.9, p, BRUSH, DT)
		dirt.advance(DT)
	check(dirt.cells.is_empty() and dirt.created_counts == PackedInt32Array([0, 0, 0]), "20 seconds of native Soil Brush creates zero Matrix crumbs")
	check(s.residue._values == original_dust, "Soil removal creates no persistent dust and preserves remote hard dust exactly")
	check(main.feedback.audio.brush_target > 0 and main.feedback.emitted[0] == 0, "Soil audio stays active without grains")
	report["soil_20s"] = {"created_matrix": dirt.persistent_count(), "dust_byte_exact": s.residue._values == original_dust}
	# Dirty Bone film is unchanged; reveal a tiny structural cap on Skull.
	s.reset()
	var p := Vector2i(250, 230)
	for y in range(225, 237):
		for x in range(245, 257):
			var i := y * s.size.x + x
			s._heights[i] = s.fossil.field.ceilings[i]
	island(s, p, 2, 0.001)
	var i := p.y * s.size.x + p.x
	s.apply_continuous(p, p, BRUSH, DT)
	check(s._heights[i] == s.fossil.field.ceilings[i] and s.last_micro_cells == 1, "micro-remnant stops exactly at real Skull ceiling")
	check(s.fossil.condition == 100 and s.fossil.exposed[i] == 1 and s.bone_film.value_at((Vector2(p) + Vector2.ONE * 0.5) / Vector2(s.size)) > 0.8, "new Bone exposure keeps film and zero damage")
	# Full cap on Soil, including a crumb artificially hidden below its support.
	s.reset()
	seed_layer(dirt, 1, 128)
	seed_layer(dirt, 2, 128)
	var n := 0
	for f in dirt.physics.fragments:
		if not f.active: continue
		var uv := (Vector2(700 + n % 16, 140 + n / 16 as int) + Vector2.ONE * 0.5) / Vector2(s.size)
		f.position = Vector3((uv.x - 0.5) * 1.1, main.block.relief.height_at(uv), (uv.y - 0.5) * 0.7)
		f.velocity = Vector3.ZERO
		f.angular_velocity = 0
		n += 1
	step_dirt(dirt, 120)
	var before := dirt.persistent_count()
	for tick in range(12): s.apply_continuous(Vector2(706, 148), Vector2(707, 148), BLOWER, DT)
	var after := dirt.persistent_count()
	check(before == 256 and after == 0 and dirt.flying.size() == 256, "local Blower evacuates full cap on Soil with visible flight, before any border")
	check(dirt.physics.active_count == 0 and dirt.layer_counts == PackedInt32Array([0, 0, 0]), "camouflaged Matrix cannot retain logical/physical slots")
	for y in range(80, 201):
		for x in range(660, 801):
			var index := y * s.size.x + x
			s._heights[index] = s.strata.packed_limits[index * 2]
	sync(s)
	for hit in range(4): s.apply_impact(Vector2(740, 140), main.controller.tools[1])
	check(dirt.persistent_count() > 0 and dirt.flying.size() == 256, "Chisel admits new crumbs immediately while evacuation FX is still visible")
	report["local_cap_reuse"] = {"before": before, "after": after, "flight": dirt.flying.size(), "new_chisel_crumbs": dirt.persistent_count()}
	step_dirt(dirt, 30)
	check(dirt.flying.is_empty(), "mass evacuation FX ends within half a second")
	main.queue_free()
	await process_frame

func run() -> void:
	test_micro()
	test_cleanup()
	test_film()
	await test_production_micro()
	report["checks"] = checks
	report["failures"] = failures
	FileAccess.open("res://work/test-logs/p4-micro-tests.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("P4 MICRO TESTS: %d checks, %d failures\n%s" % [checks, failures, JSON.stringify(report)])
	quit(0 if failures == 0 else 1)
