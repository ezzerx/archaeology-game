extends "res://tests/run_p4v2_tests.gd"
## Closure contracts: independent admission, real Brush yield, anti-hover and film.

func seed_layer(dirt: LooseDebris, layer: int, count: int) -> void:
	for y in range(8, dirt.height_size.y - 8, 24):
		for x in range(8, dirt.height_size.x - 8, 24):
			if dirt.layer_counts[layer] >= count: return
			dirt.deposit_removed(x, y, 16, layer)
			if dirt.layer_counts[layer] < count: dirt.deposit_removed(x + 8, y, 16, layer)

func test_budgets() -> void:
	var dirt := LooseDebris.new(Vector2i(1024, 640))
	seed_layer(dirt, 0, 128)
	seed_layer(dirt, 1, 128)
	seed_layer(dirt, 2, 128)
	check(dirt.layer_counts == PackedInt32Array([128, 128, 128]), "full Soil cannot starve Clay or Sandstone, including same source buckets")
	for layer in range(3): dirt.deposit_removed(1000, 600, 16, layer)
	check(dirt.layer_counts == PackedInt32Array([128, 128, 128]) and dirt.cap_refusals == PackedInt32Array([1, 1, 1]), "separate strict Soil128/Matrix256 caps and rejection counters")
	check(dirt.persistent_count() == 384, "Fine Dust has no debris slot")
	dirt.clean(Vector2(512, 320), Vector2(512, 320), preload("res://config/soft_brush.tres"), 1)
	var actual := PackedInt32Array([0, 0, 0])
	for key: Vector3i in dirt.cells: actual[key.z] += 1
	check(actual == dirt.layer_counts, "local Brush releases exact layer ownership")
	dirt.reset()
	check(dirt.layer_counts == PackedInt32Array([0, 0, 0]) and dirt.soil_hops.is_empty(), "reset frees both budgets and Soil animation")
	var large := TerrainDebris.new(terrain(), preload("res://config/debris_physics_profile.tres"), 256)
	check(large.fragments.size() == 256, "no hidden 192 physical clamp")
	# Batched dirty marking/early saturated admission must preserve all quantities.
	var twin := LooseDebris.new(Vector2i(1024, 640))
	var batched := LooseDebris.new(Vector2i(1024, 640))
	batched.begin_deposition()
	var overflow_equal := true
	for y in range(48):
		for x in range(1024):
			var layer := (x + y) % 3
			overflow_equal = overflow_equal and twin.deposit_removed(x, y, 0.01, layer) == batched.deposit_removed(x, y, 0.01, layer)
	batched.end_deposition()
	check(overflow_equal and twin.cells == batched.cells and twin.dirty_cells == batched.dirty_cells, "batched deposition preserves exact per-pixel overflow, quantities and dirty keys")
	for kind in ["flat", "slope", "cavity"]:
		var sim := TerrainDebris.new(terrain(kind))
		var max_error := 0.0
		for i in range(500):
			var at := Vector3(0.55 * sin(i * 1.331), 0, 0.35 * cos(i * 0.712))
			max_error = maxf(max_error, absf(sim._height(at) - sim.relief.height_at(SurfaceMapping.local_to_uv(at, sim.relief.dimensions))))
		check(max_error == 0, "tick cache matches canonical relief exactly: " + kind)

func test_film() -> void:
	var film := BoneSurfaceFilm.new(Vector2i(64, 40))
	var brush: ToolDefinition = preload("res://config/soft_brush.tres")
	var p := Vector2i(20, 20)
	var uv := (Vector2(p) + Vector2.ONE * 0.5) / Vector2(64, 40)
	film.expose(p)
	check(is_equal_approx(film.value_at(uv), 0.85), "first exposure creates adherent film")
	for tool in [preload("res://config/air_blower.tres"), preload("res://config/chisel.tres"), preload("res://config/precision_pick.tres")]:
		film.clean(p, p, tool, 10)
		check(is_equal_approx(film.value_at(uv), 0.85) and film.last_cleared == 0, "only Brush cleans film: " + str(tool.id))
	film.clean(p, p, brush, 0.4)
	check(film.value_at(uv) > 0.4 and film.value_at(uv) < 0.5, "progressive half-clean at 0.4 seconds")
	var partial := film.value_at(uv)
	film.expose(p + Vector2i.RIGHT)
	check(is_equal_approx(film.value_at(uv), partial), "new neighbour never restores partially cleaned film")
	film.clean(p, p, brush, 0.6)
	check(film.value_at(uv) == 0, "small central zone clean in one second")
	film.expose(p + Vector2i.DOWN)
	film.expose(p)
	check(film.value_at(uv) == 0 and film.value_at(uv + Vector2(0, 1.0 / 40)) > 0.8, "clean old cell stays clean when same coarse tile reveals new Bone")
	film.flush_image()
	var encoded := film.image.get_pixel(5, 5)
	check((roundi(encoded.g * 255) & 16) != 0 and (roundi(encoded.g * 255) & 1) == 0, "GPU mask distinguishes clean and newly exposed fine cells")
	film.reset()
	check(film.value_at(uv) == 0, "reset erases film")
	film.expose(p)
	check(film.value_at(uv) > 0.8, "reset permits a fresh discovery film")

func test_sweep() -> void:
	var dirt := dirt_fixture()
	seed_layer(dirt, 1, 40)
	seed_layer(dirt, 2, 40)
	var starts := {}
	var distances: Array[float] = []
	var exits: Array = []
	var capture := func(key_position, direction, amount, layer): exits.append([key_position, direction, amount, layer])
	dirt.physical_ejected.connect(capture)
	var n := 0
	for key: Vector3i in dirt.physical_slots:
		var f := dirt.physics.fragments[dirt.physical_slots[key]]
		f.position = Vector3(-0.06 + (n % 10) * 0.009, 0.05, (n / 10 as int - 3.5) * 0.006)
		f.velocity = Vector3.ZERO
		f.angular_velocity = 0
		n += 1
	step_dirt(dirt, 120)
	check(dirt.physics.sleeping_count == 80, "open sweep fixture: 80 sleeping full-amount Clay/Stone crumbs")
	var fragments: Array = []
	for key: Vector3i in dirt.physical_slots:
		var f := dirt.physics.fragments[dirt.physical_slots[key]]
		starts[f.source] = f.position
		fragments.append(f)
	var affected := {}
	var peak_height := 0.0
	for i in range(60):
		var point := Vector2(115 + i * 2.2, 79.5)
		dirt.physics.blow(point - Vector2.RIGHT * 2.2, point, 15, 1, DT, Vector2.RIGHT)
		for f in fragments:
			if f.active and f.blown_recently > 0: affected[f.source] = true
		dirt.advance(DT)
		for f in fragments:
			peak_height = maxf(peak_height, f.position.y - f.support_height() - 0.045)
	var sum_distance := 0.0
	var max_distance := 0.0
	for f in fragments:
		var distance := Vector2(f.position.x - starts[f.source].x, f.position.z - starts[f.source].z).length()
		sum_distance += distance
		max_distance = maxf(max_distance, distance)
	var remaining := 0.0
	for amount in dirt.cells.values(): remaining += amount
	var exited := 0.0
	for event in exits: exited += event[2]
	check(affected.size() == 80 and exits.size() >= 56, "one-second correctly aimed sweep ejects >=70% of affected open-path sleepers")
	check(peak_height < 0.005, "no levitation: maximum height above oriented support <5 mm")
	check(absf(80 * 0.02 - remaining - exited) < 0.00001, "sweep conserves exact amount until ejection")
	check(dirt.count_for(1) == dirt.physics.active_count and dirt.physics.ejected_count == exits.size(), "one ejection frees both ownership and physical slot")
	report["blower_sweep_1s"] = {"initial": 80, "affected": affected.size(), "ejected": exits.size(), "remaining": dirt.count_for(1), "mean_distance_m": sum_distance / 80, "max_distance_m": max_distance, "peak_height_m": peak_height, "initial_amount": 1.6, "remaining_amount": remaining, "exited_amount": exited}
	var sim := TerrainDebris.new(terrain())
	var slot := sim.spawn(Vector3(0, 0.1, 0), Vector3(0, -0.1, 0), SIZE, 1, 0)
	sim.blow(Vector2(127.5, 79.5), Vector2(127.5, 79.5), 15, 1, DT, Vector2.RIGHT)
	check(is_equal_approx(sim.fragments[slot].velocity.y, -0.1) and sim.fragments[slot].velocity.x > 0, "already airborne fragment receives horizontal push with no upward force")

func test_production() -> void:
	var main := load("res://scenes/prototype_main.tscn").instantiate() as Node3D
	root.add_child(main)
	main.controller.set_physics_process(false)
	main.set_process(false)
	var s: WorkingSurface = main.block.working_map
	var dirt := s.loose_debris
	var brush: ToolDefinition = main.controller.tools[0]
	var removed := 0.0
	for i in range(300):
		var previous := Vector2(110 + 800.0 * maxi(0, i - 1) / 299, 110 + 30 * sin(maxi(0, i - 1) / 45.0))
		var point := Vector2(110 + 800.0 * i / 299, 110 + 30 * sin(i / 45.0))
		s.apply_continuous(previous, point, brush, DT)
		removed += s.last_removed.x
		dirt.advance(DT)
	check(dirt.layer_counts[0] >= 20 and dirt.layer_counts[0] <= 128, "five seconds of production Brush leaves visible Soil grains below cap")
	check(Array(s.residue._values).max() > 0.1, "Soil still creates distinct Fine Dust patches")
	var matrix_only := true
	for f in dirt.physics.fragments:
		if f.active: matrix_only = matrix_only and f.material in [1, 2]
	check(matrix_only, "Soil never allocates TerrainDebris; Brush can also reach underlying Clay")
	report["soil_5s"] = {"created": dirt.created_counts[0], "created_per_s": dirt.created_counts[0] / 5.0, "visible": dirt.layer_counts[0], "cap_refused_deposition_attempts": dirt.cap_refusals[0], "local_refused_attempts": dirt.local_refusals[0], "removed_normalized_sum": removed}
	# Follow the entire dirty strip, including its outer grains. Real radius/clear.
	for key: Vector3i in dirt.cells.keys():
		if key.z != 0 or not dirt.cells.has(key): continue
		var point := dirt.point_for(key)
		s.apply_continuous(point - Vector2.RIGHT, point, main.controller.tools[2], 0.1)
	check(not dirt.flying.is_empty() and dirt.count_for(0) > 0, "Soil is transported visibly before border exit, not deleted by Blower contact")
	step_dirt(dirt, 420)
	check(dirt.count_for(0) == 0, "Blower transports and ejects all Soil grains along the brushed strip")
	for layer in [1, 2]:
		s.reset()
		for y in range(60, 241):
			for x in range(580, 901):
				var index := y * s.size.x + x
				s._heights[index] = s.strata.packed_limits[index * 2 + layer - 1]
		s.image.set_data(s.size.x, s.size.y, false, Image.FORMAT_RF, s._heights.to_byte_array())
		var removed_depth := 0.0
		for x in [620, 680, 740, 800, 860]:
			for i in range(4):
				s.apply_impact(Vector2(x, 140), main.controller.tools[1])
				removed_depth += s.last_removed[layer]
		var retained := 0.0
		for key: Vector3i in dirt.cells:
			if key.z == layer: retained += dirt.cells[key]
		check(dirt.layer_counts[layer] >= 20 and removed_depth > 0, "controlled Chisel leaves individually visible hard crumbs: %d" % layer)
		report["matrix_%d" % layer] = {"count": dirt.layer_counts[layer], "created": dirt.created_counts[layer], "refused_attempts": dirt.refused_count, "cap_refused_attempts": dirt.cap_refusals[layer], "removed_normalized_sum": removed_depth, "removed_volume_mm3": removed_depth * 102 * (1100.0 / 1024) * (700.0 / 640), "retained_normalized": retained, "crumbs_per_removed_unit": dirt.layer_counts[layer] / removed_depth}
	s.reset()
	var point := Vector2(250, 230)
	s.apply_segment(point, point, 45, 100, 1, 1)
	var uv := (point + Vector2.ONE * 0.5) / Vector2(s.size)
	check(s.bone_film.value_at(uv) > 0.8 and s.fossil.exposed_cells > 0, "central FossilState first-exposure signal automatically deposits film")
	var exposure := s.fossil.exposed_cells
	var height := s.image.get_data()
	s.apply_continuous(point, point, main.controller.tools[2], 1)
	check(s.bone_film.value_at(uv) > 0.8, "production Blower leaves adherent Bone Film")
	s.residue.reset()
	dirt.reset()
	main.feedback.audio.reset()
	s.apply_continuous(point - Vector2.RIGHT, point, brush, 1)
	check(s.bone_film.value_at(uv) == 0 and s.last_action.get("bone_film_cleared", 0.0) > 0, "film-only Brush emits feedback event for continuous Brush audio")
	check(s.image.get_data() == height and s.fossil.exposed_cells == exposure and s.fossil.condition == 100, "film cleaning preserves height, exposure and condition")
	check(dirt.count_for(1) == 0, "film cleaning creates no Matrix crumbs")
	check(main.feedback.audio.brush_target > 0 and main.feedback.audio._brush_fresh > 0, "film-only cleaning refreshes the continuous Brush sound")
	s.reset()
	check(s.bone_film.value_at(uv) == 0, "production reset clears film with specimen")
	main.queue_free()
	await process_frame

func run() -> void:
	test_budgets()
	test_film()
	test_sweep()
	await test_production()
	report["checks"] = checks
	report["failures"] = failures
	FileAccess.open("res://work/test-logs/p4-closure-tests.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("P4 CLOSURE TESTS: %d checks, %d failures\n%s" % [checks, failures, JSON.stringify(report)])
	quit(0 if failures == 0 else 1)
