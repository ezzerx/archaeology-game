extends SceneTree
## Real ReliefSurface fixtures, then full scene/input/structural-state integration.
var checks := 0
var failures := 0
var report := {}
const DT := 1.0 / 60.0
const SIZE := Vector3(0.0045, 0.00144, 0.003375)

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
		check(f.active and f.state == TerrainDebris.State.SLEEPING and f.velocity == Vector3.ZERO, "flat crumb settles and remains visible: %d" % layer)
		check(f.contacts <= 3 and max_up_speed < 0.07, "at most a small secondary bounce, no pinball: %d" % layer)
		check(max_samples <= 11, "at most two centre+four-neighbour samples, plus sleep probe: %d" % layer)
		report["flat_%d" % layer] = {"settled_y": f.position.y, "penetration_m": max_penetration,
			"contacts": f.contacts, "peak_bounce_m_s": max_up_speed, "max_samples_tick": max_samples}
		var resting := f.position
		tick(sim, 6000)
		check(sim.active_count == 1 and f.position == resting, "sleep persists 100 seconds without expiry or motion: %d" % layer)
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
	check(near.sleeping_time == 0 and near.active, "wake preserves the same persistent crumb")
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
	sim.debris_ejected.connect(func(source, at, direction): exits.append([at, direction, source]))
	var id := sim.spawn(Vector3(0.549, 0.10, 0), Vector3(0.2, 0, 0), SIZE, 2, 0)
	tick(sim, 60)
	check(exits.size() == 1 and sim.ejected_count == 1 and not sim.fragments[id].active and sim.active_count == 0,
		"block exit emits exactly once and frees slot forever")
	check(absf(exits[0][0].x - 0.55) < 0.000001 and exits[0][1].x > 0, "exit event is at actual border, directed outward")
	sim.reset()
	var ids: Array[int] = []
	for f in sim.fragments: ids.append(f.get_instance_id())
	for i in range(500): sim.spawn(Vector3(0, 0.12, 0), Vector3.ZERO, SIZE, 1 + i % 2, 0)
	check(sim.active_count == 128 and sim.skipped_count == 372, "global cap 128 across both hard materials under spam")
	check(sim.fragments[0].active and sim.fragments[0].age == 0, "full airborne pool skips new FX, never removes in-flight pieces")
	tick(sim, 100)
	check(sim.sleeping_count == 128, "full pool can settle")
	sim.spawn(Vector3(0, 0.12, 0), Vector3.ZERO, SIZE, 2, 0)
	check(sim.active_count == 128 and sim.skipped_count == 373, "saturation refuses new crumbs, never recycles a visible sleeper")
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
		and sim.fragments[id].age >= 3.99, "no timer/fade removes pieces in mid-air")

func hash_bytes(bytes: PackedByteArray) -> String:
	var hashing := HashingContext.new()
	hashing.start(HashingContext.HASH_SHA256)
	hashing.update(bytes)
	return hashing.finish().hex_encode()

func state_hashes(s: WorkingSurface) -> Dictionary:
	return {"height": hash_bytes(s.image.get_data()), "packed_height": hash_bytes(s._heights.to_byte_array()),
		"layers": hash_bytes(s.strata.boundaries.get_data()), "bone": hash_bytes(s.fossil.field.image.get_data()),
		"ids": hash_bytes(s.fossil.field.component_ids),
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

func dirt_fixture(kind := "flat") -> LooseDebris:
	var relief := terrain(kind)
	var dirt := LooseDebris.new(relief.image.get_size())
	dirt.setup_physics(relief)
	return dirt

func step_dirt(dirt: LooseDebris, count: int) -> void:
	for i in range(count): dirt.advance(DT)

func test_persistent_state() -> void:
	var dirt := dirt_fixture()
	check(is_equal_approx(dirt.profile.matrix_crumb_width, 0.0045) and is_equal_approx(dirt.profile.crumb_width, 0.0014),
		"human-validated P4-V1 crumb scale restored: hard 4.5 mm, Soil 1.4 mm")
	check(dirt.profile.crumbs_per_bucket == 2 and dirt.profile.bucket_tiles * LooseDebris.STRIDE == 24
		and is_equal_approx(dirt.profile.retained_fraction, 0.08) and is_equal_approx(dirt.profile.crumb_capacity, 0.02),
		"P4-V1 local density and retained amount unchanged by physics")
	check(dirt.deposit_removed(96, 80, 0, 2) == 0 and dirt.cells.is_empty(), "zero removal never generates a crumb")
	var supplied := 0.0
	var overflow := 0.0
	for y in range(0, 160, 8):
		for x in range(0, 256, 8):
			for layer in [1, 2]:
				supplied += 10
				overflow += dirt.deposit_removed(x, y, 10, layer)
	var retained := 0.0
	for amount in dirt.cells.values(): retained += amount * 64
	check(dirt.cells.size() == 128 and dirt.physics.active_count == 128, "global persistent and physical cap both 128")
	check(dirt.physical_slots.size() == dirt.cells.size(), "exactly one physical record per persistent hard crumb")
	check(absf(supplied - retained - overflow) < 0.001, "every rejected portion returns to Fine Dust, no lost mass")
	var local_ok := true
	for count in dirt.occupancy.values(): local_ok = local_ok and count <= 2
	check(local_ok, "spawn bucket budget stays two crumbs per 24x24 texels")
	for f in dirt.physics.fragments:
		f.velocity = Vector3.ZERO
		f.angular_velocity = 0
	step_dirt(dirt, 120)
	var amounts := dirt.cells.duplicate()
	var ids := dirt.physical_slots.duplicate()
	step_dirt(dirt, 1800)
	check(dirt.cells == amounts and dirt.physical_slots == ids and dirt.physics.sleeping_count == 128,
		"full persistent state survives 30 seconds of sleep without fade, deletion or replacement")
	var before := dirt.physics.fragments[0].position
	overflow = dirt.deposit_removed(248, 152, 10, 1)
	check(overflow == 10 and dirt.cells == amounts and dirt.physics.fragments[0].position == before,
		"full global cap refuses new source without evicting visible dirt")
	dirt.reset()
	check(dirt.cells.is_empty() and dirt.occupancy.is_empty() and dirt.physics.active_count == 0
		and dirt.physical_slots.is_empty(), "reset clears amount, source occupancy and physical pool together")
	# Production ownership: cleaning and influence must use the moved coordinate.
	dirt.deposit_removed(64, 80, 10, 2)
	var key: Vector3i = dirt.cells.keys()[0]
	var source := dirt.point_for(key)
	var f := dirt.physics.fragments[dirt.physical_slots[key]]
	f.position = Vector3(0.30, 0.06, 0)
	f.velocity = Vector3.ZERO
	step_dirt(dirt, 120)
	var current := dirt.point_for(key)
	var amount: float = dirt.cells[key]
	var brush: ToolDefinition = load("res://config/soft_brush.tres")
	dirt.clean(source, source, brush, 1)
	check(dirt.cells[key] == amount, "Brush at birth bucket cannot delete a moved crumb")
	check(dirt.nearby_count(current) == 1 and dirt.nearby_count(source) == 0, "inspection uses physical position too")
	dirt.clean(current, current, brush, 0.0001)
	check(dirt.cells[key] < amount and dirt.cells[key] > 0, "Brush progressively removes amount at current physical position")
	dirt.clean(current, current, brush, 1)
	check(dirt.cells.is_empty() and dirt.physics.active_count == 0 and dirt.occupancy.is_empty(),
		"Brush completion frees the physical record and original spawn budget")
	dirt.deposit_removed(64, 80, 10, 2)
	key = dirt.cells.keys()[0]
	f = dirt.physics.fragments[dirt.physical_slots[key]]
	f.position = Vector3(0.30, 0.05, 0)
	f.velocity = Vector3.ZERO
	step_dirt(dirt, 120)
	amount = dirt.cells[key]
	var blower: ToolDefinition = load("res://config/air_blower.tres")
	dirt.clean(source - Vector2.RIGHT, source, blower, DT)
	check(f.state == TerrainDebris.State.SLEEPING and dirt.last_blown == 0, "Blower ignores departed birth coordinate")
	current = dirt.point_for(key)
	dirt.clean(current, current, brush, 0.0001)
	check(dirt.cells[key] < amount, "partial Brush cleanup precedes quantity-conserving physical ejection")
	amount = dirt.cells[key]
	dirt.clean(current - Vector2.RIGHT, current, blower, DT)
	check(f.velocity.x > 0 and f.velocity.y > 0 and dirt.last_blown == 1, "real LooseDebris Blower wakes/lifts current crumb")
	check(dirt.cells[key] == amount and dirt.last_cleared == 0 and dirt.flying.is_empty(),
		"ON Blower moves the full crumb without deleting quantity or emitting duplicate 2D flight")
	# Ejection has actual XYZ and retained amount, released before signal delivery.
	var exits: Array = []
	var dirt_ref: WeakRef = weakref(dirt)
	dirt.physical_ejected.connect(func(at, direction, mass, layer):
		exits.append([at, direction, mass, layer, dirt_ref.get_ref().cells.size(), dirt_ref.get_ref().physics.active_count]))
	f.position = Vector3(0.549, 0.08, 0)
	f.velocity = Vector3(0.5, 0.1, 0)
	step_dirt(dirt, 120)
	check(exits.size() == 1 and exits[0][2] == amount and exits[0][3] == 2
		and exits[0][4] == 0 and exits[0][5] == 0, "one ejection carries exact remaining amount, after freeing both states")
	check(absf(exits[0][0].x - 0.55) < 0.000001 and exits[0][1].x > 0, "physical ejection position is the real XYZ border")
	dirt.deposit_removed(64, 80, 10, 2)
	check(dirt.cells.size() == 1 and dirt.occupancy.size() == 1, "ejection releases original spawn budget for subsequent excavation")
	# Toggle is nondestructive; R is the recommended fresh A/B boundary.
	key = dirt.cells.keys()[0]
	f = dirt.physics.fragments[dirt.physical_slots[key]]
	f.position.x += 0.05
	current = dirt.point_for(key)
	amount = dirt.cells[key]
	dirt.physics_enabled = false
	check(dirt.point_for(key).is_equal_approx(current) and dirt.cells[key] == amount and dirt.physics.active_count == 0,
		"F3 OFF preserves position/amount and removes only the physical representation")
	dirt.physics_enabled = true
	check(dirt.point_for(key).is_equal_approx(current) and dirt.physics.active_count == 1 and dirt.cells[key] == amount,
		"F3 ON resumes the same dirt once, without teleporting to its spawn bucket")
	# Global budget also holds under partial OFF/Soil transfers and replenishment.
	dirt = dirt_fixture()
	dirt.physics_enabled = false
	for y in range(0, 160, 8):
		for x in range(0, 256, 8): dirt.deposit_removed(x, y, 10, 2)
	var max_count := dirt.persistent_count()
	for i in range(120):
		dirt.clean(Vector2(20, 30), Vector2(130, 30), blower, DT)
		dirt.deposit_removed(248, 152, 10, 1)
		dirt.advance(DT)
		max_count = maxi(max_count, dirt.persistent_count())
	check(max_count <= 128, "legacy flight + partial cleanup + new deposits never exceed the shared global cap")

func test_scene() -> void:
	var main := load("res://scenes/prototype_main.tscn").instantiate() as Node3D
	root.add_child(main)
	main.set_process(false)
	main.controller.set_physics_process(false)
	var fx: MaterialFeedback = main.feedback
	fx.set_process(false)
	fx.loose_view.set_process(false)
	var block: ExcavationBlock = main.block
	var s := block.working_map
	var dirt := s.loose_debris
	check(fx.crumb_physics_enabled, "new scene starts with Crumb Physics ON")
	var key := InputEventKey.new()
	key.physical_keycode = KEY_F3
	key.pressed = true
	main._unhandled_input(key)
	check(not fx.crumb_physics_enabled, "F3 debug input selects crumb OFF")
	main.controller.reset_surface()
	check(not fx.crumb_physics_enabled, "R preserves chosen crumb A/B mode")
	main._unhandled_input(key)
	check(fx.crumb_physics_enabled and "Crumb Physics: ON" in fx.debris_debug()
		and "Moving:" in fx.debris_debug(), "F3 + F1 expose the persistent crumb hypothesis")
	var node_count := get_node_count()
	var mesh := fx.loose_view.multimesh.mesh.get_rid()
	var transient_states: Array = []
	for enabled in [false, true]:
		fx.crumb_physics_enabled = enabled
		s.reset()
		for i in range(30):
			fx._emit(1, Vector2(700, 140), 5)
			fx._emit(2, Vector2(700, 140), 5)
		check(fx.particles[1].size() == 48 and fx.particles[2].size() == 48 and dirt.physics.active_count == 0
			and dirt.cells.is_empty(), "transient spectacle never owns any physical/persistent record in either mode")
		var shape_ok := true
		for family in [1, 2]:
			for part in fx.particles[family]:
				shape_ok = shape_ok and part.shape.x >= 0.003 and part.shape.x <= 0.006
				shape_ok = shape_ok and is_equal_approx(part.shape.y / part.shape.x, 0.24 if family == 1 else 0.7)
				shape_ok = shape_ok and part.life >= 0.51 and part.life <= 0.69
		check(shape_ok, "transient P4-V1 dimensions/proportions and 0.51-0.69s lifetime restored in both modes")
		fx._process(0.1)
		transient_states.append(hash_bytes(var_to_bytes([fx.particles[1], fx.particles[2]])))
		fx._process(0.6)
		check(fx.particles[1].is_empty() and fx.particles[2].is_empty(), "no large cubes survive 0.7 seconds in either mode")
	check(transient_states[0] == transient_states[1], "transient trajectories and RNG identical ON/OFF after 100ms")
	check(get_node_count() == node_count and fx.loose_view.multimesh.instance_count == 128
		and fx.loose_view.multimesh.mesh.get_rid() == mesh and not fx.has_node("TerrainHardFragments"),
		"one fixed persistent renderer, no parallel hard-fragment physics or node/mesh allocation")
	# Fracture generates its ordinary spectacle and exactly the retained dirty state.
	s.reset()
	var p := Vector2(700, 140)
	s.apply_segment(p, p, 65, 1.15, 1.5, 1)
	dirt.reset()
	fx.reset()
	var weak: ToolDefinition = main.controller.tools[1].duplicate()
	weak.power = 0.000001
	s.apply_impact(p, weak)
	check(dirt.cells.is_empty() and s.last_removed == Vector3.ZERO, "stress without actual removal creates no persistent crumbs")
	for i in range(12):
		s.apply_impact(p, main.controller.tools[1])
		if not s.last_action.get("chunks", []).is_empty(): break
	check(not s.last_action.get("chunks", []).is_empty() and dirt.physics.active_count > 0
		and fx.particles[1].size() + fx.particles[2].size() > 0, "one real fracture emits spectacle plus a small retained crumb budget")
	var all_keys := true
	for k: Vector3i in dirt.cells:
		if k.z > 0: all_keys = all_keys and dirt.physical_slots.has(k)
	check(all_keys and dirt.physics.active_count == dirt.physical_slots.size(), "no duplicate hard persistent representation per source")
	step_dirt(dirt, 120)
	fx._process(1)
	fx.loose_view._process(0)
	var tiny := true
	for k: Vector3i in dirt.physical_slots:
		var f := dirt.physics.fragments[dirt.physical_slots[k]]
		tiny = tiny and f.size.x <= 0.004501 and f.size.y <= 0.001441
	check(tiny and fx.particles[1].is_empty() and fx.particles[2].is_empty(),
		"aftermath contains only small physical flakes, no transient chunks")
	# Exact structural replay. Dirt movement/cleanup may differ by design.
	var states: Array[Dictionary] = []
	var checkpoints: Array[Array] = []
	for enabled in [false, true]:
		fx.crumb_physics_enabled = enabled
		s.reset()
		var sequence: Array = []
		for pos in [Vector2(250, 230), Vector2(646, 441), Vector2(700, 140)]:
			for i in range(12): s.apply_continuous(pos - Vector2.RIGHT * 20, pos + Vector2.RIGHT * 20, main.controller.tools[0], 0.5)
			for i in range(30):
				s.apply_impact(pos + Vector2(i % 3 * 4, i % 2 * 4), main.controller.tools[1])
				for step in range(13):
					dirt.advance(DT)
					fx._process(DT)
				if i in [0, 5, 12, 20, 29]: sequence.append(state_hashes(s))
			for i in range(6): s.apply_impact(pos, main.controller.tools[3])
			for i in range(30):
				s.apply_continuous(pos - Vector2.RIGHT, pos, main.controller.tools[2], DT)
				dirt.advance(DT)
		states.append(state_hashes(s))
		checkpoints.append(sequence)
	check(states[0] == states[1], "EXACT STRUCTURE: RF, packed height, geology, IDs, exposure, Bone and fracture identical ON/OFF")
	check(checkpoints[0] == checkpoints[1] and checkpoints[0].size() == 15, "15 intermediate structural checkpoints also match")
	report["intermediate_state_checks"] = 15
	report["structural_off"] = states[0]
	report["structural_on"] = states[1]
	s.reset()
	check(dirt.physics.active_count == 0 and fx.loose_view.multimesh.visible_instance_count == 0, "scene R clears physics and render slots immediately")
	fx.crumb_physics_enabled = true
	dirt.deposit_removed(960, 140, 10, 2)
	var source: Vector3i = dirt.cells.keys()[0]
	var f := dirt.physics.fragments[dirt.physical_slots[source]]
	step_dirt(dirt, 120)
	var before := state_hashes(s)
	var amount: float = dirt.cells[source]
	p = dirt.point_for(source)
	s.apply_continuous(p - Vector2.RIGHT, p, main.controller.tools[2], DT)
	check(s.last_action.is_empty() and f.velocity.x > 0 and dirt.cells[source] == amount,
		"real Blower on dust-free terrain moves persistent dirt, no fictitious structural action")
	check(before == state_hashes(s), "real Blower changes no structural/damage state")
	var exits: Array = []
	block.debris_ejected.connect(func(pos, direction, mass, material): exits.append([pos, direction, mass, material]))
	f.position = Vector3(0.549, 0.14, 0)
	f.velocity = Vector3.RIGHT * 0.3
	step_dirt(dirt, 30)
	check(exits.size() == 1 and exits[0][2] == amount and exits[0][3] == &"sandstone",
		"public world debris_ejected hook receives exact persistent quantity once")
	main.free()
	await process_frame

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://work/test-logs")
	AudioServer.set_bus_mute(0, true)
	test_gravity_and_flat()
	test_cavity_ledge_slope()
	test_blower_distance_edge_cap()
	test_replay()
	test_persistent_state()
	await test_scene()
	report["checks"] = checks
	report["failures"] = failures
	FileAccess.open("res://work/test-logs/p4v2-crumbs-tests.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("P4V2 CRUMBS TESTS: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
