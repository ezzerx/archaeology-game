extends SceneTree
## Real ReliefSurface fixtures, then full scene/input/structural-state integration.
var checks := 0
var failures := 0
var report := {}
const DT := 1.0 / 60.0
const SIZE := Vector3(0.005, 0.0035, 0.005)

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func terrain(kind := "flat") -> ReliefSurface:
	var image := Image.create(256, 160, false, Image.FORMAT_RF)
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var local_x := ((x + 0.5) / image.get_width() - 0.5) * 1.1
			var h := 0.045
			if kind == "cavity": h = 0.095 if local_x < 0 else 0.025
			if kind == "slope": h = 0.065 + local_x * 0.15
			image.set_pixel(x, y, Color((h - 0.018) / 0.102, 0, 0))
	return ReliefSurface.new(image, Vector2(1.1, 0.7), image.get_size(), 0.018, 0.12)

func tick(sim: TerrainDebris, count: int) -> void:
	for i in range(count): sim.advance(DT)

func test_gravity_and_flat() -> void:
	var sim := TerrainDebris.new(terrain())
	var id := sim.spawn(Vector3(0, 0.1, 0), Vector3.ZERO, SIZE, 1, 0)
	var f := sim.fragments[id]
	sim.advance(DT)
	check(f.position.y < 0.1 and f.velocity.y < 0, "gravity lowers Y and vertical velocity")
	check(absf(f.velocity.y + sim.profile.gravity * DT) < 0.000001, "data-driven gravity integrated once per tick")
	for layer in [1, 2]:
		sim.reset()
		id = sim.spawn(Vector3(0, 0.1, 0), Vector3(0.035, 0, 0), SIZE, layer, 0.8)
		f = sim.fragments[id]
		var max_penetration := 0.0
		var max_samples := 0
		var max_up_speed := 0.0
		for i in range(100):
			sim.advance(DT)
			max_penetration = maxf(max_penetration, 0.045 - (f.position.y - f.support_height()))
			max_samples = maxi(max_samples, sim.last_samples)
			max_up_speed = maxf(max_up_speed, f.velocity.y)
		check(max_penetration < 0.000001, "rotating fragment bottom never tunnels through flat ground: %d" % layer)
		check(f.active and f.state == TerrainDebris.State.SLEEPING and f.velocity == Vector3.ZERO, "flat fragment settles and remains briefly visible: %d" % layer)
		check(f.contacts <= 3 and max_up_speed < 0.07, "at most a small secondary bounce, no pinball: %d" % layer)
		check(max_samples <= 11, "at most two centre+four-neighbour samples, plus sleep probe: %d" % layer)
		report["flat_%d" % layer] = {"settled_y": f.position.y, "penetration_m": max_penetration,
			"contacts": f.contacts, "peak_bounce_m_s": max_up_speed, "max_samples_tick": max_samples}
		tick(sim, 180)
		check(sim.active_count == 0, "sleep hold/fade returns slot, never permanent clutter: %d" % layer)
	check(sim.profile.restitution.x < sim.profile.restitution.y and sim.profile.friction.x > sim.profile.friction.y,
		"Clay less bouncy and more damped than Sandstone")

func test_cavity_ledge_slope() -> void:
	var sim := TerrainDebris.new(terrain("cavity"))
	var id := sim.spawn(Vector3(-0.012, 0.12, 0), Vector3(0.12, 0.035, 0), SIZE, 2, 0.3)
	var f := sim.fragments[id]
	var spawn_floor := sim.relief.height_at(Vector2(0.48, 0.5))
	tick(sim, 110)
	check(f.active and f.state == TerrainDebris.State.SLEEPING and f.position.x > 0.01, "chunk crosses high ledge and settles inside cavity")
	check(f.position.y < spawn_floor - 0.05, "CAVITY: final_y << spawn_floor_y, no invisible birth floor")
	check(absf(f.position.y - f.support_height() - 0.025 - sim.profile.contact_skin) < 0.000002,
		"cavity landing uses actual lower terrain height")
	report["cavity"] = {"spawn_floor_y": spawn_floor, "final_y": f.position.y,
		"bottom_y": f.position.y - f.support_height(), "drop_mm": (spawn_floor - f.position.y) * 1000}
	sim.reset()
	id = sim.spawn(Vector3(-0.002, 0.097, 0), Vector3(0.15, 0, 0), SIZE, 1, 0)
	f = sim.fragments[id]
	f.state = TerrainDebris.State.CONTACT
	f.angular_velocity = 0
	tick(sim, 3)
	check(f.state == TerrainDebris.State.AIRBORNE and f.velocity.y < 0, "leaving a ledge becomes AIRBORNE")
	# A sleeping chunk must fall when a real mutable RF image is excavated below it.
	sim = TerrainDebris.new(terrain())
	id = sim.spawn(Vector3(0, 0.055, 0), Vector3.ZERO, SIZE, 1, 0)
	tick(sim, 90)
	f = sim.fragments[id]
	check(f.state == TerrainDebris.State.SLEEPING, "dynamic-support fixture starts sleeping")
	var old_y := f.position.y
	sim.relief.image.fill(Color(0, 0, 0))
	sim.advance(DT)
	check(f.state == TerrainDebris.State.AIRBORNE and f.position.y < old_y, "sleep rechecks current relief after excavation")
	for sign_value in [-1.0, 1.0]:
		var slope := terrain("slope")
		if sign_value < 0: slope.image.flip_x()
		sim = TerrainDebris.new(slope)
		id = sim.spawn(Vector3(0, 0.067, 0), Vector3.ZERO, SIZE, 2, 0)
		f = sim.fragments[id]
		f.angular_velocity = 0
		tick(sim, 20)
		check(f.position.x * sign_value < -0.0005 and f.velocity.x * sign_value <= 0,
			"slope adds downhill movement, never uphill energy (both directions)")
		check(absf(f.velocity.x) <= sim.profile.slide_speed_limit and absf(f.position.z) < 0.000001,
			"slope speed bounded, no cross-slope energy")
		tick(sim, 100)
		check(f.state == TerrainDebris.State.SLEEPING, "slope settles quickly instead of sliding ten seconds")

func test_blower_distance_edge_cap() -> void:
	var sim := TerrainDebris.new(terrain("cavity"))
	var slots: Array[int] = []
	for x in [0.08, 0.105, 0.20]:
		slots.append(sim.spawn(Vector3(x, 0.035, 0), Vector3.ZERO, SIZE, 2, 0))
	tick(sim, 90)
	var center := SurfaceMapping.local_to_uv(Vector3(0.08, 0, 0), sim.relief.dimensions) * Vector2(sim.map_size) - Vector2.ONE * 0.5
	# Scaled to the same physical radius as the 1024x640 production map.
	var near := sim.fragments[slots[0]]
	var far := sim.fragments[slots[1]]
	var outside := sim.fragments[slots[2]]
	check(near.state == TerrainDebris.State.SLEEPING, "Blower fixture rests on cavity floor")
	var affected := sim.blow(center, center, 15, 1, 0.1, Vector2.RIGHT)
	check(affected == 2 and near.state == TerrainDebris.State.AIRBORNE, "Blower wakes only nearby sleeping chunks")
	check(near.velocity.x > 0 and near.velocity.y > 0 and near.velocity.z == 0, "impulse follows jet with positive lift")
	check(far.velocity.x > 0 and far.velocity.x < near.velocity.x, "farther fragment gets strictly weaker impulse")
	check(outside.state == TerrainDebris.State.SLEEPING and outside.velocity == Vector3.ZERO, "outside radius remains unchanged")
	check(near.sleeping_time == 0 and sim.visibility_scale(near) == 1, "wake restarts hold and cancels fading")
	var p := near.position
	sim.advance(DT)
	check(near.position.x > p.x and near.position.y > p.y, "real integrated wake rises and travels inside cavity")
	var steady := TerrainDebris.new(terrain())
	var steady_id := steady.spawn(Vector3(0, 0.05, 0), Vector3.ZERO, SIZE, 2, 0)
	tick(steady, 90)
	var resting_y := steady.fragments[steady_id].position.y
	for i in range(12):
		steady.blow(Vector2(127.5, 79.5), Vector2(127.5, 79.5), 15, 1, DT, Vector2.RIGHT)
		steady.advance(DT)
	check(steady.fragments[steady_id].position.y > resting_y + 0.002,
		"production 60 Hz Blower lifts a sleeper; contact tolerance cannot swallow small impulses")
	# Time integration, without collision, does not depend on call frequency.
	var speeds: Array[Vector3] = []
	for hz in [30, 60, 120]:
		var test := TerrainDebris.new(terrain())
		var slot := test.spawn(Vector3(0, 0.1, 0), Vector3.ZERO, SIZE, 1, 0)
		for i in range(hz / 10): test.blow(Vector2(127.5, 79.5), Vector2(127.5, 79.5), 15, 1, 1.0 / hz, Vector2.RIGHT)
		speeds.append(test.fragments[slot].velocity)
	check(speeds[0].is_equal_approx(speeds[1]) and speeds[1].is_equal_approx(speeds[2]), "Blower impulse integrated in seconds, independent of input rate")
	for i in range(100): sim.blow(center, center, 1000, 1, DT, Vector2.RIGHT)
	check(Vector2(near.velocity.x, near.velocity.z).length() <= sim.profile.blower_speed_limit + 0.000001
		and near.velocity.y <= sim.profile.blower_lift_limit + 0.000001, "held Blower cannot inject unbounded speed (float32 velocity)")
	sim = TerrainDebris.new(terrain())
	var exits: Array = []
	sim.debris_ejected.connect(func(at, direction, layer): exits.append([at, direction, layer]))
	var id := sim.spawn(Vector3(0.549, 0.10, 0), Vector3(0.2, 0, 0), SIZE, 2, 0)
	tick(sim, 60)
	check(exits.size() == 1 and sim.ejected_count == 1 and not sim.fragments[id].active and sim.active_count == 0,
		"block exit emits exactly once and frees slot forever")
	check(absf(exits[0][0].x - 0.55) < 0.000001 and exits[0][1].x > 0, "exit event is at actual border, directed outward")
	sim.reset()
	var ids: Array[int] = []
	for f in sim.fragments: ids.append(f.get_instance_id())
	for i in range(500): sim.spawn(Vector3(0, 0.12, 0), Vector3.ZERO, SIZE, 1 + i % 2, 0)
	check(sim.active_count == 48 and sim.skipped_count == 452, "global cap 48 across both hard materials under spam")
	check(sim.fragments[0].active and sim.fragments[0].age == 0, "full airborne pool skips new FX, never removes in-flight pieces")
	tick(sim, 100)
	check(sim.sleeping_count == 48, "full pool can settle")
	sim.spawn(Vector3(0, 0.12, 0), Vector3.ZERO, SIZE, 2, 0)
	check(sim.active_count == 48 and sim.recycled_count == 1, "oldest sleeping piece can be recycled at saturation")
	var stable := true
	for i in range(ids.size()): stable = stable and sim.fragments[i].get_instance_id() == ids[i]
	check(stable, "fragment records allocated once and reused without per-impact allocation")
	sim.reset()
	check(sim.active_count == 0 and sim.sleeping_count == 0 and sim.last_samples == 0, "reset clears pool and counters")
	# Slow gravity proves expiry cannot hide a still-airborne fragment at 3.5 s.
	var settings := sim.profile.duplicate() as DebrisPhysicsProfile
	settings.gravity = 0.001
	sim = TerrainDebris.new(terrain(), settings)
	id = sim.spawn(Vector3(0, 0.20, 0), Vector3.ZERO, SIZE, 2, 0)
	tick(sim, 240)
	check(sim.fragments[id].active and sim.fragments[id].state == TerrainDebris.State.AIRBORNE
		and sim.visibility_scale(sim.fragments[id]) == 1, "no timer/fade removes pieces in mid-air")

func hash_bytes(bytes: PackedByteArray) -> String:
	var hashing := HashingContext.new()
	hashing.start(HashingContext.HASH_SHA256)
	hashing.update(bytes)
	return hashing.finish().hex_encode()

func state_hashes(s: WorkingSurface) -> Dictionary:
	return {"height": hash_bytes(s.image.get_data()), "packed_height": hash_bytes(s._heights.to_byte_array()),
		"layers": hash_bytes(s.strata.boundaries.get_data()), "bone": hash_bytes(s.fossil.field.image.get_data()),
		"ids": hash_bytes(s.fossil.field.component_ids),
		"dust": hash_bytes(s.residue.image.get_data()), "dust_values": hash_bytes(var_to_bytes(s.residue._values)),
		"crumbs": hash_bytes(var_to_bytes([s.loose_debris.cells, s.loose_debris.occupancy, s.loose_debris.flying])),
		"fracture": hash_bytes(var_to_bytes([s.fracture.stress, s.fracture.image.get_data()])),
		"exposure": hash_bytes(s.fossil.exposed), "condition": s.fossil.condition,
		"protection": hash_bytes(s.fossil.direct_contact_consumed)}

func test_replay() -> void:
	var hashes: Array[String] = []
	for repeat in range(2):
		var sim := TerrainDebris.new(terrain("cavity"))
		for i in range(48):
			sim.spawn(Vector3(-0.02, 0.11, (i - 24) * 0.002), Vector3(0.10, i * 0.001, 0), SIZE, 1 + i % 2, i * 0.1)
		var data: Array = []
		for i in range(110):
			sim.advance(DT)
			if i in [5, 30, 80, 109]:
				for f in sim.fragments: data.append([f.position, f.velocity, f.rotation, f.state, f.active])
		hashes.append(hash_bytes(var_to_bytes(data)))
	check(hashes[0] == hashes[1], "same deterministic physics fixture replays exactly")
	report["replay_sha256"] = hashes[0]

func test_scene() -> void:
	var main := load("res://scenes/prototype_main.tscn").instantiate() as Node3D
	root.add_child(main)
	main.set_process(false)
	main.controller.set_physics_process(false)
	var fx: MaterialFeedback = main.feedback
	fx.set_process(false)
	fx.set_physics_process(false)
	fx.loose_view.set_process(false)
	var block: ExcavationBlock = main.block
	var s := block.working_map
	check(fx.debris_physics_enabled, "new scene starts with experimental physics ON")
	var key := InputEventKey.new()
	key.physical_keycode = KEY_F3
	key.pressed = true
	main._unhandled_input(key)
	check(not fx.debris_physics_enabled, "F3 debug input selects OFF")
	main.controller.reset_surface()
	check(not fx.debris_physics_enabled, "R preserves chosen A/B mode")
	main._unhandled_input(key)
	check(fx.debris_physics_enabled and "Debris Physics: ON" in fx.debris_debug(), "F3 + F1 exposes ON and diagnostics")
	var node_count := get_node_count()
	var mesh := fx.terrain_view.multimesh.mesh.get_rid()
	for i in range(300): fx._emit(1 + i % 2, Vector2(700, 140), 5)
	fx._process(0)
	check(fx.particles[1].is_empty() and fx.particles[2].is_empty() and fx.terrain_debris.active_count == 48,
		"hard physics replaces the old spawn path without doubling pieces")
	check(get_node_count() == node_count and fx.terrain_view.multimesh.instance_count == 48
		and fx.terrain_view.multimesh.mesh.get_rid() == mesh, "spam creates no Nodes, meshes or pool growth")
	var same_shape := true
	for f in fx.terrain_debris.fragments:
		same_shape = same_shape and f.size.x >= 0.003 and f.size.x <= 0.006 and is_equal_approx(f.size.z, f.size.x)
		same_shape = same_shape and is_equal_approx(f.size.y / f.size.x, 0.24 if f.material == 1 else 0.7)
	check(same_shape and fx.terrain_view.multimesh.mesh == fx.pools[1].mesh, "P4-A dimensions, plate/shard proportions and face mesh preserved")
	s.reset()
	check(fx.terrain_debris.active_count == 0 and fx.terrain_view.multimesh.visible_instance_count == 0, "scene reset immediately clears physical render slots")
	# ON/OFF use real tool actions, varied depths, Bone + persistent mess.
	var states: Array[Dictionary] = []
	var checkpoints: Array[Array] = []
	for enabled in [false, true]:
		fx.debris_physics_enabled = enabled
		s.reset()
		var sequence: Array = []
		for p in [Vector2(250, 230), Vector2(646, 441), Vector2(700, 140)]:
			for i in range(12):
				s.apply_continuous(p - Vector2.RIGHT * 20, p + Vector2.RIGHT * 20, main.controller.tools[0], 0.5)
			for i in range(30):
				s.apply_impact(p + Vector2(i % 3 * 4, i % 2 * 4), main.controller.tools[1])
				for step in range(13):
					fx._physics_process(DT)
					fx._process(DT)
				if i in [0, 5, 12, 20, 29]: sequence.append(state_hashes(s))
			for i in range(6): s.apply_impact(p, main.controller.tools[3])
			for i in range(30):
				s.apply_continuous(p - Vector2.RIGHT, p, main.controller.tools[2], DT)
				fx._physics_process(DT)
		states.append(state_hashes(s))
		checkpoints.append(sequence)
	check(states[0] == states[1], "EXACT STATE: RF, geology, IDs, exposure, Bone, stress, dust and crumbs identical ON/OFF")
	check(checkpoints[0] == checkpoints[1] and checkpoints[0].size() == 15,
		"15 intermediate state hashes also match; end-state saturation cannot hide a divergence")
	report["intermediate_state_checks"] = 15
	report["structural_off"] = states[0]
	report["structural_on"] = states[1]
	s.reset()
	fx.debris_physics_enabled = true
	var p := Vector2(700, 140)
	var uv := (p + Vector2.ONE * 0.5) / Vector2(block.map_resolution)
	var at := Vector3((uv.x - 0.5) * block.surface_size.x, 0.13, (uv.y - 0.5) * block.surface_size.y)
	var id := fx.terrain_debris.spawn(at, Vector3.ZERO, SIZE, 2, 0)
	tick(fx.terrain_debris, 90)
	check(fx.terrain_debris.fragments[id].state == TerrainDebris.State.SLEEPING, "clean-surface scene fixture settled")
	var before := state_hashes(s)
	s.apply_continuous(p - Vector2.RIGHT, p, main.controller.tools[2], 0.1)
	check(s.last_action.is_empty() and fx.terrain_debris.fragments[id].velocity.x > 0,
		"real Blower wakes fragments even with zero dust/crumb cleanup, no fictitious material action")
	check(before == state_hashes(s), "Blower feedback wake has zero structural/dirt/exposure/damage side effect")
	var exits: Array = []
	block.debris_ejected.connect(func(pos, direction, amount, material): exits.append([pos, direction, amount, material]))
	fx.terrain_debris.reset()
	fx.terrain_debris.spawn(Vector3(0.549, 0.13, 0), Vector3.RIGHT * 0.3, SIZE, 2, 0)
	tick(fx.terrain_debris, 30)
	check(exits.size() == 1 and exits[0][2] == 0 and exits[0][3] == &"sandstone", "existing ejection hook receives one secondary chunk with zero persistent amount")
	main.free()
	await process_frame

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://work/test-logs")
	AudioServer.set_bus_mute(0, true)
	test_gravity_and_flat()
	test_cavity_ledge_slope()
	test_blower_distance_edge_cap()
	test_replay()
	await test_scene()
	report["checks"] = checks
	report["failures"] = failures
	FileAccess.open("res://work/test-logs/p4v2-tests.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("P4V2 TESTS: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
