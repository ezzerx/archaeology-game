extends "res://tests/run_p4_tests.gd"
## Additional P4 regressions: semantic bone feedback and continuous brush audio.

func test_material_reveals(fx: MaterialFeedback, layer: int) -> void:
	# Two controlled slabs around the real authored specimen. Only this fixture
	# moves the Clay/Stone interface, to exercise the same reveal in each material.
	var size := Vector2i(128, 80)
	var strata := Stratigraphy.new(size, definitions)
	for i in range(size.x * size.y):
		strata.packed_limits[i * 2] = 0.8
		strata.packed_limits[i * 2 + 1] = 0.15 if layer == 1 else 0.6
	var surface := WorkingSurface.new(size, strata, FossilField.new(size), profile)
	var strong := chisel.duplicate() as ToolDefinition
	strong.power = 5
	strong.radius = 12
	var family := &"chisel_clay" if layer == 1 else &"chisel_stone"
	for cycle in range(2):
		surface.reset()
		fx.reset()
		surface._heights.fill(0.4)
		surface.image.set_data(size.x, size.y, false, Image.FORMAT_RF, surface._heights.to_byte_array())
		var discoveries := 0
		var later_reveals := 0
		var bone_sounds := 0
		var material_correct := true
		var first_correct := true
		var exposure_increases := true
		var mixed_correct := true
		for y in range(18, 59, 5):
			for x in range(20, 106, 5):
				var at := Vector2(x, y)
				# Adjacent matrix only: no direct centre hit can obscure this test.
				if surface.fossil.field.ceilings[y * size.x + x] > 0: continue
				for impact in range(3):
					var exposed := surface.fossil.exposed_cells
					surface.apply_impact(at, strong)
					var event := surface.last_action
					if event.is_empty(): continue
					var played := fx.audio.played
					fx.on_action(event)
					if fx.audio.played > played and fx.audio.last_family in [&"bone_revealed", &"direct_bone_hit"]:
						bone_sounds += 1
					if event.bone_first_contact:
						discoveries += 1
						var dominant := &"chisel_stone" if event.removed.z > event.removed.y else &"chisel_clay"
						first_correct = first_correct and fx.audio.last_family == dominant and fx.audio.played == played + 1
					elif event.bone_revealed and event.removed[layer] > 0 and event.removed[3 - layer] == 0:
						later_reveals += 1
						material_correct = material_correct and fx.audio.last_family == family and fx.audio.played == played + 1
						exposure_increases = exposure_increases and surface.fossil.exposed_cells > exposed
					elif event.bone_revealed and event.removed.y > 0 and event.removed.z > 0:
						var dominant := &"chisel_stone" if event.removed.z > event.removed.y else &"chisel_clay"
						mixed_correct = mixed_correct and fx.audio.last_family == dominant
		check(discoveries == 1 and bone_sounds == 0 and first_correct and surface.fossil.condition == 100
			and not surface.fossil.first_direct_contact_consumed,
			"all adjacent discoveries keep material audio and direct protection: layer %d cycle %d" % [layer, cycle])
		check(later_reveals >= 2 and material_correct and exposure_increases,
			"additional adjacent reveals keep material audio AND count exposure: layer %d cycle %d" % [layer, cycle])
		check(mixed_correct, "mixed fracture keeps the dominant worked material, never repeated Bone audio")
		print("P4 AUDIO MATERIAL: layer=", layer, " reset=", cycle, " later reveals=", later_reveals, " Bone sounds=", bone_sounds)

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
	var strata := Stratigraphy.new(size, definitions)
	for i in range(size.x * size.y):
		strata.packed_limits[i * 2] = 0.8
		strata.packed_limits[i * 2 + 1] = 0.6
	var surface := WorkingSurface.new(size, strata, field, profile)
	surface._heights.fill(0.4) # Sandstone over the real specimen.
	surface.image.set_data(size.x, size.y, false, Image.FORMAT_RF, surface._heights.to_byte_array())
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
	check(audio.last_family == &"chisel_stone" and not surface.fossil.first_direct_contact_consumed,
		"A: adjacent Sandstone discovery keeps Stone audio and available direct protection")
	check(surface.last_action.bone_first_contact and surface.last_action.bone_damage == 0,
		"first specimen discovery is distinct from per-cell reveal and actual damage")
	for i in range(surface.fossil.exposed.size()):
		if surface.fossil.exposed[i] != 0:
			contact = Vector2(i % size.x, i / size.x)
			break
	surface.apply_impact(contact, strong)
	fx.on_action(surface.last_action)
	check(surface.last_action.direct_bone_hit and surface.last_action.bone_protected_contact
		and surface.last_action.bone_damage == 0 and surface.fossil.condition == 100 and counters[1] == 0
		and surface.fossil.first_direct_contact_consumed and audio.last_family == &"bone_revealed",
		"B: first direct hit after adjacent reveal spends protection, plays small tik, condition stays 100")
	surface.apply_impact(contact, strong)
	check(surface.last_action.direct_bone_hit and surface.fossil.condition == 97 and counters[1] == 1,
		"C: second direct Chisel impact emits one three-point damage event")
	fx.on_action(surface.last_action)
	check(audio.last_family == &"direct_bone_hit", "damage sound takes precedence over any simultaneous adjacent reveal")
	check(surface.last_action.bone_damage == 3 and not surface.last_action.bone_first_contact and not surface.last_action.bone_protected_contact,
		"direct cue reports the existing three condition points, never another discovery")
	check(audio.samples[&"bone_revealed"][0].data != audio.samples[&"direct_bone_hit"][0].data,
		"reveal tik and direct-hit clack have different timbres")
	surface.apply_continuous(contact, contact, brush, 1)
	check(not surface.last_action.get("direct_bone_hit", false) and surface.fossil.condition == 97,
		"Brush on exposed bone never claims a direct hit")
	surface.apply_continuous(contact, contact, blower, 1)
	check(not surface.last_action.get("direct_bone_hit", false) and surface.fossil.condition == 97 and counters[0] == 1,
		"Blower safe; specimen discovery remains once per reset")
	test_material_reveals(fx, 1)
	test_material_reveals(fx, 2)
	# A direct contact at zero condition is still recorded, but cannot claim
	# another damaging Bone cue. No change to the pre-existing damage policy.
	for i in range(40): surface.apply_impact(contact, strong)
	surface.apply_impact(contact, strong)
	audio.reset()
	fx.on_action(surface.last_action)
	check(surface.last_action.direct_bone_hit and surface.last_action.bone_damage == 0
		and audio.last_family != &"direct_bone_hit" and audio.last_family != &"bone_revealed",
		"Bone sounds are reserved for protected direct contact or actual condition loss")
	surface.reset()
	check(not surface.fossil.first_direct_contact_consumed and surface.fossil.condition == 100,
		"D: reset rearms direct-contact protection independently of discovery")
	# Safe tools reveal/visit the cap before Chisel: none may spend protection.
	var pick := load("res://config/precision_pick.tres").duplicate() as ToolDefinition
	pick.power = 5
	for i in range(30):
		surface.apply_impact(contact, pick)
		if surface.fossil.exposed[field.index_at_map(contact)] != 0: break
	check(surface.fossil.first_contact and surface.fossil.exposed[field.index_at_map(contact)] != 0,
		"E fixture: Pick itself reveals the centre")
	for i in range(5): surface.apply_impact(contact, pick)
	surface.apply_continuous(contact, contact, brush, 1)
	surface.apply_continuous(contact, contact, blower, 1)
	check(surface.fossil.condition == 100 and not surface.fossil.first_direct_contact_consumed,
		"E: Pick/Brush/Blower direct visits never damage or consume Chisel protection")
	surface.apply_impact(contact, strong)
	check(surface.last_action.bone_protected_contact and surface.fossil.condition == 100,
		"first Chisel after safe-tool exposure is still protected")
	surface.reset()
	var center_reveal := strong.duplicate() as ToolDefinition
	center_reveal.radius = 1
	for i in range(30):
		surface.apply_impact(contact, center_reveal)
		if surface.fossil.exposed[field.index_at_map(contact)] != 0: break
	fx.on_action(surface.last_action)
	check(surface.last_action.bone_revealed and not surface.last_action.bone_protected_contact
		and not surface.last_action.direct_bone_hit and not surface.fossil.first_direct_contact_consumed
		and surface.fossil.condition == 100 and surface.last_action.bone_damage == 0 and audio.last_family == &"chisel_stone",
		"hidden centre reveal keeps material sound, zero damage and protection STILL available")
	surface.apply_impact(contact, center_reveal)
	fx.on_action(surface.last_action)
	check(surface.last_action.bone_protected_contact and surface.last_action.direct_bone_hit
		and surface.fossil.condition == 100 and surface.last_action.bone_damage == 0
		and surface.fossil.first_direct_contact_consumed and audio.last_family == &"bone_revealed",
		"first following hit on now-visible Bone is the protected tik at condition 100")
	surface.apply_impact(contact, center_reveal)
	fx.on_action(surface.last_action)
	check(surface.fossil.condition == 97 and surface.last_action.bone_damage == 3
		and not surface.last_action.bone_protected_contact and audio.last_family == &"direct_bone_hit",
		"second visible-Bone hit gives DING and three damage, after reveal then protected contact")
	surface.reset()
	check(surface.fossil.condition == 100 and not surface.fossil.first_direct_contact_consumed,
		"reset rearms protection after the complete hidden-visible-protected-damage sequence")
	audio.reset()
	check(audio.brush_level == 0 and audio.brush_starts == 0 and audio.brush_voices[0].stream == null,
		"reset immediately clears continuous audio")
	main.queue_free()
	await process_frame
	print("P4 AUDIO TESTS: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
