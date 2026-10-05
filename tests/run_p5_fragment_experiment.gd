extends "res://tests/run_p5_tests.gd"
## Historical experiment: explicitly opted in only by this test.

func test_authoring_and_readiness() -> void:
	main.reset_specimen()
	var field := surface.fragments.field
	var repeat_field := RecoverableFragmentField.new(surface.size)
	check(field.cells.size() == 2 and not field.cells[0].is_empty() and not field.cells[1].is_empty(), "exactly two independent fragments")
	check(field.ids == repeat_field.ids and field.ceilings == repeat_field.ceilings and field.collars == repeat_field.collars, "deterministic IDs, ceilings, collars")
	var baseline := FossilField.new(surface.size)
	check(surface.fossil.field.component_ids == baseline.component_ids and surface.fossil.field.component_totals == baseline.component_totals
		and surface.fossil.field.ceilings == baseline.ceilings and baseline.total_cells == 32290, "main silhouette, totals and ceilings unchanged")
	evidence.component_totals = Array(baseline.component_totals)
	for id in range(2):
		var disjoint := true
		for index in field.cells[id]: disjoint = disjoint and baseline.component_ids[index] == 0
		for index in field.collars[id]: disjoint = disjoint and baseline.component_ids[index] == 0
		check(disjoint, "fragment and complete clearance collar are disjoint from skeleton")
		check(field.cells[id].size() + field.collars[id].size() < 1100, "bounded local checks per fragment")
		evidence["fragment_" + str(id)] = {"cells": field.cells[id].size(), "collar": field.collars[id].size(), "center": str(field.centers[id])}
	var target_cells := field.cells[0]
	for index in field.collars[0]: surface._heights[index] = field.clearance_heights[0]
	for n in range(floori(target_cells.size() * 0.89)): surface._heights[target_cells[n]] = field.ceilings[target_cells[n]]
	surface.update_fragments(field.bounds[0])
	check(surface.fragments.exposure[0] < 90 and not surface.fragments.ready[0], "89 percent with full collar cannot recover")
	check(not surface.fragments.grab(0), "unready grab rejected")
	for n in range(ceili(target_cells.size() * 0.90)): surface._heights[target_cells[n]] = field.ceilings[target_cells[n]]
	surface._heights[field.collars[0][0]] = field.clearance_heights[0] + 0.02
	surface.update_fragments(field.bounds[0])
	check(surface.fragments.exposure[0] >= 90 and not surface.fragments.ready[0], "90 percent with one matrix bridge rejected")
	surface._heights[field.collars[0][0]] = field.clearance_heights[0]
	surface.update_fragments(field.bounds[0])
	check(surface.fragments.ready[0] and surface.fragments.exposure[0] < 91, "90 percent plus collar allows recovery without perfect exposure")
	var count := notices.size()
	surface.update_fragments(field.bounds[0])
	check(notices.size() == count, "ready notification fires once")
	var check_count := surface.fragments.checks
	surface.update_fragments(Rect2i(0, 0, 20, 20))
	check(surface.fragments.checks == check_count and surface.fragments.last_inspected_cells == 0, "unrelated edits do not scan fragments")
	main.reset_specimen()
	check(surface.fragments.exposure == [0.0, 0.0] and surface.fragments.ready == [false, false], "readiness reset")
	# Exercise production Brush + Chisel, no fixture depth or tool tuning.
	for id in range(2):
		var center := field.centers[id]
		for offset in [-12, 0, 12]:
			var p := center + Vector2(offset, 0)
			surface.apply_continuous(p, p, control.tools[0], 2.0)
		var impacts := 0
		while not surface.fragments.ready[id] and impacts < 450:
			surface.apply_impact(center + Vector2((impacts % 3 - 1) * 12, 0), control.tools[1])
			impacts += 1
		check(surface.fragments.ready[id], "authored fragment reachable with unchanged tools " + str(id))
		var protected := true
		for index in field.cells[id]: protected = protected and surface._heights[index] >= field.ceilings[index]
		check(protected, "fracture never passes fragment ceiling")
		for tool in [control.tools[0], control.tools[3]]:
			for step in range(4): surface.apply_continuous(center, center, tool, 10)
			for index in field.cells[id]: protected = protected and surface._heights[index] >= field.ceilings[index]
		check(protected, "continuous and Pick never pass fragment ceiling")
		evidence["fragment_" + str(id)].baseline_impacts = impacts
	check(surface.fossil.condition == 100 and surface.fossil.direct_contact_consumed == PackedByteArray([0, 0, 0, 0, 0]), "fragments consume no anatomical protection or condition")


func test_forceps_input() -> void:
	main.reset_specimen()
	control._focused = true
	control._pointer_inside = true
	check(control.select_tool(4) and control.config.id == &"forceps", "Forceps fifth slot")
	var field := surface.fragments.field
	P5Fixture.reveal(surface, [20, 0, 0, 0])
	P5Fixture.ready_fragment(surface, 0)
	main.block.flush_texture()
	var terrain := surface.image.get_data()
	var film := surface.bone_film._bytes.duplicate()
	var condition := surface.fossil.condition
	var exposed := surface.fossil.exposed.duplicate()
	var stress := surface.fracture.stress.duplicate()
	var malicious := control.config.duplicate() as ToolDefinition
	malicious.power = 5
	malicious.bone_film_clear = 4
	malicious.effectiveness = Vector3.ONE
	malicious.bone_damage = 100
	malicious.residue_clear = 10
	surface.apply_continuous(field.centers[0], field.centers[0], malicious, 10)
	surface.apply_impact(Vector2(250, 200), malicious)
	check(surface.image.get_data() == terrain and surface.bone_film._bytes == film and surface.fracture.stress == stress, "Forceps cannot enter any excavation or cleanup path")
	check(surface.fossil.condition == condition and surface.fossil.exposed == exposed, "Forceps cannot damage or expose skeleton")
	check(not surface.fragments.grab(-1) and not surface.fragments.grab(2) and not surface.fragments.grab(1), "invalid/skeleton/unready grabs rejected")
	mouse(screen_at(Vector2(260, 200)), true)
	check(surface.fragments.grabbed == -1, "clicking skeleton never grabs")
	mouse(screen_at(Vector2(260, 200)), false)
	mouse(screen_at(field.centers[0]), true)
	check(surface.fragments.grabbed == 0, "real READY LMB grabs")
	check(main.block.pick(screen_at(field.centers[0]), main.camera).fragment == -1, "held source no longer presents a recovery target")
	mouse(Vector2(1000, 850), false)
	check(surface.fragments.grabbed == -1 and surface.fragments.ready[0] and not surface.fragments.recovered[0], "release away returns READY")
	mouse(screen_at(field.centers[0]), true)
	control.select_tool(0)
	check(surface.fragments.grabbed == -1 and not surface.fragments.recovered[0], "switch tool safely cancels grab")
	control.select_tool(4)
	mouse(screen_at(field.centers[0]), true)
	control._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
	check(surface.fragments.grabbed == -1, "focus loss returns fragment")
	control._focused = true
	control._pointer_inside = true
	mouse(screen_at(field.centers[0]), true)
	mouse(main.fragment_tray.get_global_rect().get_center(), false)
	session.flush()
	check(surface.fragments.recovered_count() == 1 and main.forceps_view.pieces[0].visible, "real tray drop recovers one")
	check(not surface.fragments.grab(0) and not surface.fragments.release(true), "no duplicate recovery")
	check(surface.image.get_data() == terrain and surface.bone_film._bytes == film, "grab/drop never removes matrix or film")
	for index in field.cells[0]:
		if surface.structural_ceilings[index] != 0: check(false, "recovered ceiling must be freed"); break
	P5Fixture.ready_fragment(surface, 1)
	main.block.flush_texture()
	mouse(screen_at(field.centers[1]), true)
	mouse(main.fragment_tray.get_global_rect().get_center(), false)
	session.flush()
	check(surface.fragments.recovered_count() == 2 and main.forceps_view.pieces[1].visible, "second real tray drop 2/2")
	main.reset_specimen()
	check(surface.fragments.recovered_count() == 0 and not main.forceps_view.pieces[0].visible and not main.forceps_view.pieces[1].visible, "reset restores empty tray")
	check(main.block.material.get_shader_parameter("fragment_visible") == Vector2.ONE, "reset restores source rendering")
	for id in range(2):
		var restored := true
		for index in field.cells[id]: restored = restored and surface.structural_ceilings[index] == field.ceilings[index]
		check(restored, "reset restores exact fragment ceilings")


func run() -> void:
	root.size = Vector2i(1920, 1080)
	root.content_scale_size = root.size
	main = load("res://scenes/prototype_main.tscn").instantiate()
	main.get_node("ExcavationBlock").fragment_experiment = true
	main.get_node("ToolController").tools.append(load("res://config/forceps.tres"))
	root.add_child(main)
	surface = main.block.working_map
	session = main.session
	control = main.controller
	control.set_physics_process(false)
	await process_frame
	test_authoring_and_readiness()
	test_forceps_input()
	await finish("p5-fragment-experiment")
