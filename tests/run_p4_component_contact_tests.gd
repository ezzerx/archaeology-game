extends SceneTree
## Real B-17 components, production tool resources, events and audio routing.

const C = FossilField.Component
var checks := 0
var failures := 0
var main: Node3D
var surface: WorkingSurface
var fossil: FossilState
var control: ToolController
var sequence: Array[Dictionary] = []

func _initialize() -> void: call_deferred("run")

func check(ok: bool, description: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + description)

func point_near(component: int, anchor: Vector2) -> Vector2:
	var nearest := Vector2.ZERO
	var distance := INF
	for index in range(fossil.field.component_ids.size()):
		if fossil.field.component_ids[index] != component: continue
		var point := Vector2(index % surface.size.x, index / surface.size.x)
		var candidate := point.distance_squared_to(anchor)
		if candidate < distance:
			distance = candidate
			nearest = point
	check(distance < 25, "authored component %d exists at %s" % [component, anchor])
	return nearest

func reveal(point: Vector2, tool: ToolDefinition) -> void:
	var index := fossil.field.index_at_map(point)
	var flags := fossil.direct_contact_consumed.duplicate()
	var condition := fossil.condition
	for i in range(80):
		if fossil.exposed[index] != 0: break
		main.feedback.audio._process(1.0 / tool.cadence)
		surface.apply_impact(point, tool)
	check(fossil.exposed[index] != 0 and fossil.condition == condition and fossil.direct_contact_consumed == flags,
		"reveal keeps every component flag and global condition: %s" % point)

func hit(point: Vector2, protected: bool, expected_condition: float, label: String) -> void:
	var component := fossil.field.component_ids[fossil.field.index_at_map(point)]
	var before := fossil.condition
	var expected_flags := fossil.direct_contact_consumed.duplicate()
	expected_flags[component] = 1
	# Advance the real sound cooldown between impacts at the unchanged cadence.
	main.feedback.audio._process(1.0 / control.tools[1].cadence)
	surface.apply_impact(point, control.tools[1])
	var event := surface.last_action
	check(event.direct_bone_hit and event.bone_protected_contact == protected and fossil.condition == expected_condition
		and event.bone_damage == (0.0 if protected else 3.0) and before - fossil.condition == event.bone_damage,
		label + ": protected event and global condition")
	check(fossil.direct_contact_consumed == expected_flags, label + ": only this component can be consumed")
	var audio: StringName = main.feedback.audio.last_family
	check(audio == (&"bone_revealed" if protected else &"direct_bone_hit"), label + ": small tik or damaging DING")
	sequence.append({"action": label, "component": FossilField.COMPONENT_NAMES[component],
		"protected": event.bone_protected_contact, "damage": event.bone_damage, "condition": fossil.condition,
		"audio": audio, "consumed": Array(fossil.direct_contact_consumed)})

func run() -> void:
	AudioServer.set_bus_mute(0, true)
	main = load("res://scenes/prototype_main.tscn").instantiate()
	root.add_child(main)
	control = main.controller
	control.set_physics_process(false)
	main.set_process(false)
	surface = main.block.working_map
	fossil = surface.fossil
	await process_frame
	var skull := point_near(C.SKULL, Vector2(260, 198))
	var ribs := point_near(C.RIBS, Vector2(383, 370))
	var other_rib := point_near(C.RIBS, Vector2(523, 380))
	var spine := point_near(C.SPINE, Vector2(329, 251))
	var other_vertebra := point_near(C.SPINE, Vector2(754, 241))
	var limb := point_near(C.HIND_LIMB, Vector2(593, 335))
	check(ribs.distance_to(other_rib) > 100 and spine.distance_to(other_vertebra) > 400,
		"same-component targets are distinct ribs and distant vertebrae, not neighbouring texels")
	check(fossil.condition == 100 and fossil.direct_contact_consumed == PackedByteArray([0, 0, 0, 0, 0]),
		"initial state has four available protections and unused NONE")
	for component in [C.SKULL, C.SPINE, C.RIBS, C.HIND_LIMB]:
		check(fossil.is_direct_contact_protected(component), "component %d starts READY" % component)
	check(not fossil.is_direct_contact_protected(C.NONE), "NONE has no protection")

	# Discovery through a safe tool never counts as a damaging direct contact.
	reveal(skull, control.tools[3])
	hit(skull, true, 100, "Skull first")
	hit(skull, false, 97, "Skull second")
	reveal(ribs, control.tools[3])
	hit(ribs, true, 97, "Ribs first after Skull")
	hit(ribs, false, 94, "Ribs second")
	check(fossil.is_direct_contact_protected(C.SPINE) and fossil.is_direct_contact_protected(C.HIND_LIMB),
		"Skull and Ribs consumption leaves Spine and Hind Limb READY")

	# Even a new central Chisel reveal cannot rearm a consumed component.
	check(fossil.exposed[fossil.field.index_at_map(other_rib)] == 0, "other rib starts hidden")
	reveal(other_rib, control.tools[1])
	check(not surface.last_action.bone_protected_contact and not surface.last_action.direct_bone_hit
		and main.feedback.audio.last_family in [&"chisel_clay", &"chisel_stone"], "hidden other-rib centre reveal keeps material audio")
	hit(other_rib, false, 91, "Different rib, same Ribs component")
	reveal(spine, control.tools[3])
	hit(spine, true, 91, "Spine first")
	reveal(limb, control.tools[3])
	hit(limb, true, 91, "Hind Limb first")
	reveal(other_vertebra, control.tools[3])
	hit(other_vertebra, false, 88, "Different vertebra, same Spine component")
	hit(limb, false, 85, "Hind Limb second")
	var protected_hits := 0
	for event in sequence:
		if event.protected: protected_hits += 1
	check(protected_hits == 4 and fossil.direct_contact_consumed == PackedByteArray([0, 1, 1, 1, 1]),
		"B-17 grants exactly four protected hits, one per anatomical component")
	main.debug_panel.show()
	main.bone_panel.show()
	main._process(0.2)
	check(main.bone_label.text.contains("Direct protection") and main.bone_label.text.count("USED") == 4,
		"existing F1 panel reports the four consumed protections")

	control.reset_surface()
	check(fossil.condition == 100 and fossil.exposed_cells == 0 and not fossil.first_contact
		and fossil.direct_contact_consumed == PackedByteArray([0, 0, 0, 0, 0]), "reset rearms all components and global condition")
	main._process(0.2)
	check(main.bone_label.text.count("READY") == 4 and main.bone_label.text.count("USED") == 0,
		"F1 reports all four protections READY after reset")
	for point in [skull, ribs, spine, limb]:
		reveal(point, control.tools[3])
		var flags := fossil.direct_contact_consumed.duplicate()
		surface.apply_impact(point, control.tools[3])
		check(fossil.direct_contact_consumed == flags and fossil.condition == 100, "Pick preserves every protection")
		surface.apply_continuous(point, point, control.tools[0], 0.1)
		check(fossil.direct_contact_consumed == flags and fossil.condition == 100, "Brush preserves every protection")
		surface.apply_continuous(point, point, control.tools[2], 0.1)
		check(fossil.direct_contact_consumed == flags and fossil.condition == 100, "Blower preserves every protection")
	var skull_index := fossil.field.index_at_map(skull)
	check(not fossil.contact_at(skull_index, 3, false) and not fossil.contact_at(skull_index, 0, true),
		"pre-impact exposure and positive damage remain required")
	check(not fossil.contact_at(-1, 3, true) and not fossil.contact_at(fossil.exposed.size(), 3, true), "invalid indices cannot consume protection")
	# Explicit NONE guard, even if a caller supplied a spurious exposed flag.
	fossil.exposed[0] = 1
	check(fossil.field.component_ids[0] == C.NONE and not fossil.contact_at(0, 3, true)
		and fossil.condition == 100 and fossil.direct_contact_consumed.count(1) == 0, "NONE is ignored without damage or consumption")
	fossil.exposed[0] = 0
	var report := {"checks": checks, "failures": failures, "sequence": sequence, "maximum_protected_hits": protected_hits,
		"after_reset_and_safe_tools": {"condition": fossil.condition, "consumed": Array(fossil.direct_contact_consumed)}}
	FileAccess.open("res://work/test-logs/p4-component-contact.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("P4 COMPONENT CONTACT TESTS: %d checks, %d failures" % [checks, failures])
	print("P4 COMPONENT SEQUENCE: ", JSON.stringify(sequence))
	main.queue_free()
	await create_timer(0.4).timeout
	quit(0 if failures == 0 else 1)
