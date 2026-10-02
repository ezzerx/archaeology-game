extends "res://tests/run_p4_tests.gd"
## Additional P4 regressions: semantic bone feedback and continuous brush audio.

func run() -> void:
	var main := load("res://scenes/prototype_main.tscn").instantiate() as Node3D
	root.add_child(main)
	main.get_node("ToolController").set_physics_process(false)
	var fx: MaterialFeedback = main.feedback
	var audio := fx.audio
	audio.set_process(false)
	audio.update_brush(0, 4)
	var stationary := audio.brush_target
	audio.update_brush(80, 4)
	var slow := audio.brush_target
	audio.update_brush(650, 4)
	var fast := audio.brush_target
	check(stationary < 0.02 and slow > stationary and fast > slow, "brush sound follows speed; stationary contact almost silent")
	audio.update_brush(650, 12)
	check(audio.brush_target > fast, "actual work adds gentle brush intensity")
	for i in range(180):
		audio.update_brush(400, 4, i > 90)
		audio._process(1.0 / 60.0)
	check(audio.brush_starts == 1 and audio.played == 1, "three seconds of brushing start a single continuous texture, no grain spam")
	check(audio.brush_clay_mix > 0.95 and audio.brush_level > 0.1, "material transition crossfades without restarting loops")
	for family in [&"brush_soil", &"brush_clay"]:
		var sample: AudioStreamWAV = audio.samples[family][0]
		check(sample.loop_mode == AudioStreamWAV.LOOP_FORWARD and sample.loop_end == sample.data.size() / 2,
			"brush stream loops over the full continuous texture")
		var seam := absf(sample.data.decode_s16(0) - sample.data.decode_s16(sample.data.size() - 2))
		check(seam < 5000, "loop seam has no large discontinuity")
	var sustained := audio.brush_level
	audio._process(0.06)
	check(audio.brush_target == 0 and audio.brush_level > 0 and audio.brush_level < sustained, "no-work brush releases gradually")
	audio._process(2)
	check(audio.brush_level < 0.0001, "idle brush becomes silent")

	var size := Vector2i(128, 80)
	var field := FossilField.new(size)
	var surface := WorkingSurface.new(size, Stratigraphy.new(size, definitions), field, profile)
	var index := 0
	for i in range(field.ceilings.size()):
		if field.ceilings[i] > field.ceilings[index]: index = i
	var contact := Vector2(index % size.x, index / size.x)
	var adjacent := contact
	while field.ceilings[field.index_at_map(adjacent)] > 0: adjacent.x -= 1
	var strong := chisel.duplicate() as ToolDefinition
	strong.power = 5
	strong.radius = 20
	var counters := [0, 0]
	surface.fossil.bone_first_contact.connect(func(_cell, _component): counters[0] += 1)
	surface.fossil.bone_condition_changed.connect(func(_condition, _damage): counters[1] += 1)
	for i in range(30):
		surface.apply_impact(adjacent, strong)
		if surface.last_action.get("bone_revealed", false): break
	check(surface.last_action.get("bone_revealed", false) and not surface.last_action.get("direct_bone_hit", false)
		and surface.fossil.condition == 100 and counters[1] == 0, "adjacent fracture reveals bone without direct-hit event or damage")
	fx.on_action(surface.last_action)
	check(audio.last_family == &"bone_revealed", "adjacent discovery selects only delicate reveal sound")
	for i in range(surface.fossil.exposed.size()):
		if surface.fossil.exposed[i] != 0:
			contact = Vector2(i % size.x, i / size.x)
			break
	surface.apply_impact(contact, strong)
	check(surface.last_action.direct_bone_hit and surface.fossil.condition == 97 and counters[1] == 1,
		"one direct Chisel impact emits one damage event")
	fx.on_action(surface.last_action)
	check(audio.last_family == &"direct_bone_hit", "damage sound takes precedence over any simultaneous adjacent reveal")
	check(audio.samples[&"bone_revealed"][0].data != audio.samples[&"direct_bone_hit"][0].data,
		"reveal tik and direct-hit clack have different timbres")
	surface.apply_continuous(contact, contact, brush, 1)
	check(not surface.last_action.get("direct_bone_hit", false) and surface.fossil.condition == 97,
		"Brush on exposed bone never claims a direct hit")
	surface.apply_continuous(contact, contact, blower, 1)
	check(not surface.last_action.get("direct_bone_hit", false) and surface.fossil.condition == 97 and counters[0] == 1,
		"Blower safe; specimen discovery remains once per reset")
	audio.reset()
	check(audio.brush_level == 0 and audio.brush_starts == 0 and audio.brush_voices[0].stream == null,
		"reset immediately clears continuous audio")
	main.queue_free()
	await process_frame
	print("P4 AUDIO TESTS: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
