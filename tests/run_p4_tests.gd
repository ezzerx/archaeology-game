extends SceneTree
## P4 production-path invariants, independent of cosmetic particle positions.
var checks := 0
var failures := 0
var profile: ReactionProfile = preload("res://config/material_reactions.tres")
var brush: ToolDefinition = preload("res://config/soft_brush.tres")
var chisel: ToolDefinition = preload("res://config/chisel.tres")
var blower: ToolDefinition = preload("res://config/air_blower.tres")
var definitions: Array[MaterialDefinition] = [preload("res://config/loose_soil.tres"), preload("res://config/compact_clay.tres"), preload("res://config/sandstone.tres")]
var point := Vector2(48, 32)
var cell := Vector2i(48, 32)
var events := 0
var condition_report: Dictionary = {}

func _initialize() -> void: call_deferred("run")

func check(valid: bool, description: String) -> void:
	checks += 1
	if not valid:
		failures += 1
		push_error("P4 FAIL: " + description)

func fixture(height := 0.6, settings: ReactionProfile = profile) -> WorkingSurface:
	var surface := WorkingSurface.new(Vector2i(96, 64))
	surface.apply_segment(point, point, 100000, 1, 1, 1.0 - height)
	surface.strata = Stratigraphy.new(surface.size, definitions)
	surface.fracture = MaterialFracture.new(surface.size, settings)
	return surface

func on_action(_event: Dictionary) -> void: events += 1

func test_fracture() -> void:
	# Fixed historical workload isolates fracture semantics from resource tuning.
	var fracture_tool := chisel.duplicate() as ToolDefinition
	fracture_tool.radius = 12
	fracture_tool.power = 0.24
	fracture_tool.falloff = 2.0
	var clay := fixture()
	var stone := fixture(0.25)
	var clay_initial := clay.image.get_data()
	var stone_initial := stone.image.get_data()
	clay.apply_impact(point, fracture_tool)
	stone.apply_impact(point, fracture_tool)
	check(clay.image.get_data() == clay_initial and stone.image.get_data() == stone_initial, "default first impact marks hard materials before removal")
	check(clay.fracture.last_marks > 0 and stone.fracture.last_marks > clay.fracture.last_marks, "stone partition smaller than clay plates")
	check(clay.fracture.image.get_data() != fixture().fracture.image.get_data(), "stress has a visible atlas representation")
	clay.apply_impact(point, fracture_tool)
	stone.apply_impact(point, fracture_tool)
	check(clay.value_at(cell) < 0.5 and stone.image.get_data() == stone_initial, "second clay impact detaches; stone resists")
	stone.apply_impact(point, fracture_tool)
	check(stone.value_at(cell) < 0.2 and stone.fracture.last_chunks.size() > 0, "third stone impact releases small hard fragments")
	check(absf(0.6 - clay.value_at(cell) - profile.clay_chunk_depth) < 0.00001, "clay removal is discrete configured plate depth")
	check(absf(0.25 - stone.value_at(cell) - profile.stone_chunk_depth) < 0.00001, "stone depth differs from clay")
	var equal_depth_cells := 0
	var changed_outside := false
	for y in range(clay.size.y):
		for x in range(clay.size.x):
			var before := clay_initial.to_float32_array()[y * clay.size.x + x]
			var removed := before - clay.value_at(Vector2i(x, y))
			if absf(removed - profile.clay_chunk_depth) < 0.00001: equal_depth_cells += 1
			if Vector2(x, y).distance_to(point) >= fracture_tool.radius and removed != 0: changed_outside = true
	check(equal_depth_cells > 15, "many adjacent texels drop as a plate, not a smooth radial kernel")
	check(not changed_outside, "all structural fracture remains strictly inside footprint")
	var twin := fixture()
	for i in range(2): twin.apply_impact(point, fracture_tool)
	check(twin.image.get_data() == clay.image.get_data() and twin.fracture.stress == clay.fracture.stress, "same inputs reproduce geometry and stress exactly")
	check(twin.fracture.image.get_data() == clay.fracture.image.get_data() and twin.residue._values == clay.residue._values, "same seed gives exact marks and dust")
	var different_profile := profile.duplicate() as ReactionProfile
	different_profile.seed += 23
	var different := fixture(0.6, different_profile)
	for i in range(2): different.apply_impact(point, fracture_tool)
	check(different.image.get_data() != clay.image.get_data(), "seed changes the fracture partition")
	var initial := fixture()
	var initial_bytes := initial.image.get_data()
	for i in range(4):
		initial.apply_impact(Vector2(16, 32), fracture_tool)
		initial.apply_impact(Vector2(80, 32), fracture_tool)
	check(initial.value_at(cell) == initial_bytes.to_float32_array()[cell.y * initial.size.x + cell.x], "separate Chisel impacts do not bridge")
	var powerful := fracture_tool.duplicate() as ToolDefinition
	powerful.power = 5
	var layered := fixture(0.71)
	var before_values := layered.image.get_data().to_float32_array()
	layered.apply_impact(point, powerful)
	var layer_clamps := true
	for i in range(before_values.size()):
		var upper := layered.strata.packed_limits[i * 2]
		var lower := layered.strata.packed_limits[i * 2 + 1]
		var floor_value := upper if before_values[i] > upper else lower
		layer_clamps = layer_clamps and layered._heights[i] >= minf(before_values[i], floor_value)
	check(layer_clamps, "one powerful impact never skips the starting material interface")
	check(clay.fracture.image.get_data_size() < clay.image.get_data_size(), "stress atlas is smaller than height even on small fixtures")
	var full := MaterialFracture.new(Vector2i(1024, 640), profile)
	check(full.image.get_data_size() < 80000, "full-resolution block needs under 80 KB mutable stress atlas")

func test_bone_and_events() -> void:
	var size := Vector2i(128, 80)
	var field := FossilField.new(size)
	var surface := WorkingSurface.new(size, Stratigraphy.new(size, definitions), field, profile)
	var index := 0
	for i in range(field.ceilings.size()):
		if field.ceilings[i] > field.ceilings[index]: index = i
	var contact := Vector2(index % size.x, index / size.x)
	var strong := chisel.duplicate() as ToolDefinition
	strong.power = 5
	var impacts := 0
	while surface.fossil.exposed[index] == 0 and impacts < 30:
		surface.apply_impact(contact, strong)
		impacts += 1
	check(surface.fossil.exposed[index] != 0 and surface.fossil.condition == 100, "P4 fracture first hidden contact protected")
	check(not surface.fossil.first_direct_contact_consumed and not surface.last_action.bone_protected_contact,
		"P4 centre reveal never consumes the visible-contact protection")
	surface.apply_impact(contact, strong)
	check(surface.fossil.condition == 100 and surface.last_action.bone_protected_contact,
		"first subsequent contact on visible Bone is protected")
	surface.apply_impact(contact, strong)
	check(surface.fossil.condition == 97, "P4 exposed centre pays at most one event per impact")
	strong.radius = 128
	for i in range(25): surface.apply_impact(contact, strong)
	var bounded := true
	for i in range(field.ceilings.size()): bounded = bounded and surface._heights[i] >= field.ceilings[i]
	check(bounded, "repeated enormous fracture footprints cannot tunnel below any bone ceiling")
	var condition := surface.fossil.condition
	surface.apply_continuous(contact, contact, brush, 20)
	var heights := surface.image.get_data()
	surface.apply_continuous(contact, contact, blower, 20)
	check(surface.fossil.condition == condition, "Brush and Blower remain safe after fracture")
	check(surface.image.get_data() == heights, "Blower does not change one structural byte")
	surface.material_action.connect(on_action)
	var count := events
	surface.apply_impact(Vector2(-100, -100), strong)
	check(events == count and surface.fossil.condition == condition, "out-of-map calls cannot emit actions or clamp damage to an edge")
	var no_power := strong.duplicate() as ToolDefinition
	no_power.power = 0
	surface.apply_impact(contact, no_power)
	check(events == count, "zero power creates no particles/event on bone")
	surface.reset()
	var pristine := WorkingSurface.new(size, surface.strata, field, profile)
	check(surface.image.get_data() == pristine.image.get_data() and surface.fracture.stress.is_empty(), "reset geometry and sparse stress exact")
	check(surface.fracture.image.get_data() == pristine.fracture.image.get_data(), "reset fracture atlas exact")
	check(surface.residue._values == pristine.residue._values and surface.residue.image.get_data() == pristine.residue.image.get_data(), "reset all dust including fractions exact")
	check(surface.last_action.is_empty() and surface.fossil.condition == 100, "reset clears last action and condition")
	count = events
	surface.apply_continuous(contact, contact, blower, 1)
	check(events == count, "clean blower produces no fictitious material particles")
	surface.apply_continuous(contact, contact, brush, 0.1)
	check(events == count + 1 and surface.last_action.removed.x > 0, "actual brush removal emits one aggregated action")
	var dust_before := surface.residue.value_at((contact + Vector2.ONE * 0.5) / Vector2(size))
	surface.apply_continuous(contact, contact, blower, 0.1)
	check(surface.last_action.residue_cleared > 0 and surface.residue.value_at((contact + Vector2.ONE * 0.5) / Vector2(size)) < dust_before, "actual residue clearing emits airflow/dust work")

func test_scene_and_audio() -> void:
	var main := load("res://scenes/prototype_main.tscn").instantiate() as Node3D
	root.add_child(main)
	var block: ExcavationBlock = main.get_node("ExcavationBlock")
	var control: ToolController = main.get_node("ToolController")
	control.set_physics_process(false)
	var fx: MaterialFeedback = main.feedback
	await process_frame
	# P4 human-validated baseline — tuning final deferred to P7.
	var baseline := [Vector3(40, 0.70, 1.25), Vector3(22, 0.64, 2.25), Vector3(60, 0, 1), Vector3(7, 0.24, 1.50)]
	for tool in range(4):
		check(Vector3(control.tools[tool].radius, control.tools[tool].power, control.tools[tool].falloff).is_equal_approx(baseline[tool]),
			"fresh scene uses human-validated resource baseline without debug input: tool %d" % tool)
	check(control.tools[1].cadence == 4.5 and control.tools[3].cadence == 6 and control.tools[1].bone_damage == 3
		and control.tools[3].bone_damage == 0 and control.tools[2].residue_clear == 2.5, "cadences, damage and Blower cleanup remain locked")
	check(block.working_map.fracture != null and block.reactions == profile, "normal scene activates production fracture profile")
	check(Engine.max_fps == 240 and Engine.physics_ticks_per_second == 60, "240 FPS / 60 Hz runtime preserved")
	check(fx.proxies.size() == 4 and fx.pools.size() == 4, "four tool proxies and four bounded particle families")
	var initial := block.working_map.image.get_data()
	control.hit = {"inside": true, "world": Vector3(0, 0.12, 0)}
	for i in range(4):
		control.select_tool(i)
		fx._process(0.01)
		check(fx.proxies[i].visible and fx.proxies[i].global_position.distance_to(control.hit.world) < 0.000001, "proxy follows exact hit without simulation offset")
	check(block.working_map.image.get_data() == initial and fx.action_count == 0, "moving proxies alone never excavates or emits effects")
	block.set_debug_view(1)
	fx._process(0.01)
	check(not fx.visible, "FX cannot occlude height/material debug or GPU oracle")
	block.set_debug_view(0)
	fx._process(0.01)
	check(fx.visible, "FX return in shaded play view")
	var fracture_point := Vector2(700, 140)
	block.working_map.apply_segment(fracture_point, fracture_point, 65, 1.15, 1.5, 1)
	for i in range(5): block.working_map.apply_impact(fracture_point, chisel)
	var camera: Camera3D = main.get_node("Camera3D")
	var error := 0.0
	for y in range(126, 155, 2):
		for x in range(686, 715, 2):
			var uv := (Vector2(x, y) + Vector2.ONE * 0.5) / Vector2(block.map_resolution)
			var local := Vector3((uv.x - 0.5) * block.surface_size.x, block.relief.height_at(uv), (uv.y - 0.5) * block.surface_size.y)
			var hit := block.pick(camera.unproject_position(block.to_global(local)), camera)
			if not hit.inside:
				error = INF
				continue
			var repick := block.pick(camera.unproject_position(hit.world), camera)
			error = maxf(error, repick.local.distance_to(hit.local)) if repick.inside else INF
	check(error < 0.00001, "225 picking roundtrips on real P4 fracture edges")
	var p := Vector2(200, 200)
	block.working_map.apply_continuous(p, p, brush, 0.1)
	check(fx.emitted[0] > 0 and fx.audio.last_family == &"brush_soil", "real soil action emits grains and soil sound")
	block.working_map.apply_continuous(p, p, blower, 0.1)
	check(fx.emitted[3] > 0 and fx.audio.last_family == &"air", "real blower clearing emits dust and air sound")
	for family in MaterialAudio.FAMILIES:
		var variants: Array = fx.audio.samples[family]
		var distinct := true
		for i in range(1, variants.size()): distinct = distinct and variants[i].data != variants[i - 1].data
		check(variants.size() == 4 and distinct, "four original variants: %s" % family)
		var pcm: PackedByteArray = variants[0].data
		var peak := 0
		var energy := 0.0
		for i in range(0, pcm.size(), 2):
			var sample := pcm.decode_s16(i)
			peak = maxi(peak, absi(sample))
			energy += sample * sample
		check(peak < 32767 and energy > 100000, "audio non-silent and unclipped: %s" % family)
	var before_particles := fx.emitted.duplicate()
	control.reset_surface()
	for tool in range(4):
		check(Vector3(control.tools[tool].radius, control.tools[tool].power, control.tools[tool].falloff).is_equal_approx(baseline[tool]),
			"specimen reset keeps the launch baseline without debug adjustment: tool %d" % tool)
	check(fx.emitted == PackedInt32Array([0, 0, 0, 0]) and fx.action_count == 0 and before_particles[0] > 0, "R clears particle counters and transient actions")
	var all_clear := fx.audio.played == 0 and fx.recoil_remaining == 0 and fx.bone_remaining == 0
	for family in range(4): all_clear = all_clear and fx.particles[family].is_empty() and fx.pools[family].visible_instance_count == 0
	check(all_clear, "R immediately clears all visible particle/audio/recoil state")
	main.free()
	await process_frame

func run() -> void:
	test_fracture()
	test_bone_and_events()
	await test_scene_and_audio()
	print("P4 TESTS: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
