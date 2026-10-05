extends SceneTree

var checks := 0
var failures := 0
var main: Node3D
var surface: WorkingSurface
var session: PreparationSession
var control: ToolController
var evidence := {}
var notices: Array[String] = []
var completion_count := 0

func _initialize() -> void:
	run.call_deferred()

func check(value: bool, description: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error("P5 FAIL: " + description)

func equal(a: float, b: float, description: String, tolerance := 0.0001) -> void:
	check(absf(a - b) <= tolerance, "%s (%f / %f)" % [description, a, b])

func on_notice(message: String) -> void:
	notices.append(message)

func on_complete(_snapshot: Dictionary) -> void:
	completion_count += 1

func test_rules() -> void:
	for item in [[0, 100, "Hidden"], [9.999, 100, "Hidden"], [10, 0, "Detected"], [49.999, 100, "Detected"],
		[50, 0, "Exposed"], [79.999, 100, "Exposed"], [80, 79.999, "Exposed"], [80, 80, "Prepared"], [100, 100, "Prepared"]]:
		check(PreparationRules.component_state(item[0], item[1]) == item[2], "component boundary " + str(item))
	check(PreparationRules.classification(0, 0, [0.0, 0.0, 0.0, 0.0]) == 0, "Unknown at start")
	check(PreparationRules.classification(0, 4.999, [9.99, 0.0, 0.0, 0.0]) == 0, "insignificant discovery stays Unknown")
	check(PreparationRules.classification(0, 5, [0.0, 0.0, 0.0, 0.0]) == 1, "overall 5 percent discovery")
	check(PreparationRules.classification(0, 1, [10.0, 0.0, 0.0, 0.0]) == 1, "one detected component discovery")
	check(PreparationRules.classification(1, 5, [40.0, 14.999, 0.0, 10.0]) == 1, "Spine required")
	check(PreparationRules.classification(1, 5, [40.0, 15.0, 0.0, 9.999]) == 1, "Hind Limb required")
	check(PreparationRules.classification(1, 5, [34.999, 15.0, 0.0, 10.0]) == 2, "Possible Theropod")
	check(PreparationRules.classification(2, 5, [35.0, 15.0, 0.0, 10.0]) == 3, "Likely small theropod")
	check(PreparationRules.classification(0, 5, [100.0, 0.0, 0.0, 0.0]) == 1, "skull alone cannot skip body evidence")
	for stage in range(4):
		check(PreparationRules.classification(stage, 0, [0.0, 0.0, 0.0, 0.0]) == stage, "classification monotone " + str(stage))
	check(PreparationRules.objectives(59.999, 100, 60, 2) == [false, true, true], "skull exposure exact")
	check(PreparationRules.objectives(60, 49.999, 60, 2) == [false, true, true], "skull cleanliness exact")
	check(PreparationRules.objectives(60, 50, 59.999, 1) == [true, false, false], "overall and both fragments exact")
	check(PreparationRules.objectives(60, 50, 60, 2) == [true, true, true], "all exact thresholds")

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

func film_oracle() -> void:
	var totals := [0, 0, 0, 0, 0]
	var dirt := [0.0, 0.0, 0.0, 0.0, 0.0]
	for index in range(surface.fossil.exposed.size()):
		if surface.fossil.exposed[index] == 0: continue
		var id := surface.fossil.field.component_ids[index]
		totals[id] += 1
		@warning_ignore("integer_division")
		var uv := (Vector2(index % surface.size.x, index / surface.size.x) + Vector2.ONE * 0.5) / Vector2(surface.size)
		dirt[id] += surface.bone_film.value_at(uv)
	var total := 0
	var total_dirt := 0.0
	for id in range(1, 5):
		total += totals[id]
		total_dirt += dirt[id]
		var expected: float = 100.0 * (1 - dirt[id] / (totals[id] * BoneSurfaceFilm.INITIAL)) if totals[id] > 0 else 0.0
		equal(surface.bone_film.cleanliness_percent(id), expected, "cached component film agrees with independent cell oracle", 0.002)
	equal(surface.bone_film.cleanliness_percent(), 100.0 * (1 - total_dirt / (total * BoneSurfaceFilm.INITIAL)) if total > 0 else 0.0, "overall film weighted by exposed cells", 0.002)

func test_film_and_progression() -> void:
	main.reset_specimen()
	P5Fixture.reveal(surface, [10, 0, 0, 0])
	session.flush()
	check(session.classification_stage == 1, "session observes first component detection")
	equal(surface.bone_film.cleanliness_percent(), 0, "newly exposed film starts unclean")
	film_oracle()
	P5Fixture.clean(surface)
	film_oracle()
	equal(surface.bone_film.cleanliness_percent(), 100, "exposed bone fully clean")
	P5Fixture.reveal(surface, [30, 15, 0, 10])
	session.flush()
	check(session.classification_stage == 2, "session body-plan classification")
	film_oracle()
	P5Fixture.reveal(surface, [35, 15, 0, 10])
	session.flush()
	check(session.classification_stage == 3, "session skull classification")
	var count := notices.size()
	session.invalidate()
	session.flush()
	check(notices.size() == count, "no duplicate classification/objective notices")
	P5Fixture.ready_fragment(surface, 0)
	film_oracle()
	var exposure := surface.fossil.exposure_percent()
	var clean := surface.bone_film.cleanliness_percent()
	var before := session.component_states.duplicate()
	var index := -1
	for i in range(surface.fossil.exposed.size()):
		if surface.fossil.exposed[i] != 0: index = i; break
	surface.fossil.damage_at(index, 3)
	session.flush()
	check(surface.fossil.condition == 97 and session.component_states == before, "condition independent of preparation state")
	equal(surface.fossil.exposure_percent(), exposure, "damage does not change exposure")
	equal(surface.bone_film.cleanliness_percent(), clean, "damage does not change cleanliness")
	main.reset_specimen()
	check(session.classification_stage == 0 and session.component_states == ["Hidden", "Hidden", "Hidden", "Hidden"], "reset classification and all component states")

func accomplish(id: int) -> void:
	match id:
		0:
			P5Fixture.reveal(surface, [61, 0, 0, 0])
			P5Fixture.clean(surface)
		1: P5Fixture.reveal(surface, [0, 100, 100, 100])
		2:
			P5Fixture.recover(surface, 0)
			P5Fixture.recover(surface, 1)
	session.flush()

func test_objective_orders() -> void:
	for order in [[0, 1, 2], [0, 2, 1], [1, 0, 2], [1, 2, 0], [2, 0, 1], [2, 1, 0]]:
		main.reset_specimen()
		var before := completion_count
		for step in range(3):
			accomplish(order[step])
			check(session.objective_done[order[step]], "objective independently completable " + str(order))
			check(session.preparation_complete == (step == 2), "all three required " + str(order))
		check(completion_count == before + 1 and session.card_open, "completion fires once " + str(order))
		var snapshot := session.completion_snapshot.duplicate()
		session.invalidate()
		session.flush()
		check(completion_count == before + 1 and session.completion_snapshot == snapshot, "completion snapshot stable")
		check(session.completion_snapshot.exposure < 100, "completion leaves optional exposure")

func mouse(at: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.position = at
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	root.push_input(event, true)

func screen_at(point: Vector2) -> Vector2:
	var uv := (point + Vector2.ONE * 0.5) / Vector2(surface.size)
	return main.camera.unproject_position(main.block.to_global(Vector3((uv.x - 0.5) * main.block.surface_size.x,
		main.block.relief.height_at(uv), (uv.y - 0.5) * main.block.surface_size.y)))

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
	mouse(main.session_ui.tray.get_global_rect().get_center(), false)
	session.flush()
	check(surface.fragments.recovered_count() == 1 and main.session_ui.slots[0].occupied, "real tray drop recovers one")
	check(not surface.fragments.grab(0) and not surface.fragments.release(true), "no duplicate recovery")
	check(surface.image.get_data() == terrain and surface.bone_film._bytes == film, "grab/drop never removes matrix or film")
	for index in field.cells[0]:
		if surface.structural_ceilings[index] != 0: check(false, "recovered ceiling must be freed"); break
	P5Fixture.ready_fragment(surface, 1)
	main.block.flush_texture()
	mouse(screen_at(field.centers[1]), true)
	mouse(main.session_ui.tray.get_global_rect().get_center(), false)
	session.flush()
	check(surface.fragments.recovered_count() == 2 and main.session_ui.slots[1].occupied, "second real tray drop 2/2")
	main.reset_specimen()
	check(surface.fragments.recovered_count() == 0 and not main.session_ui.slots[0].occupied and not main.session_ui.slots[1].occupied, "reset restores empty tray")
	check(main.block.material.get_shader_parameter("fragment_visible") == Vector2.ONE, "reset restores source rendering")
	for id in range(2):
		var restored := true
		for index in field.cells[id]: restored = restored and surface.structural_ceilings[index] == field.ceilings[index]
		check(restored, "reset restores exact fragment ceilings")

func test_keep_cleaning_archive() -> void:
	main.reset_specimen()
	for id in range(3): accomplish(id)
	var snapshot := session.completion_snapshot.duplicate()
	var state := surface.image.get_data()
	check(main.session_ui.modal.visible and not session.can_use_tools(), "completion card blocks tools")
	check(main.session_ui.card_stats.text == PreparationUI.summary(snapshot), "completion card uses completion snapshot")
	check(not control.select_tool(1), "card prevents tool selection")
	control._held = true
	control._screen = screen_at(Vector2(800, 400))
	control._physics_process(1.0 / 60)
	check(surface.image.get_data() == state, "completion blocks held excavation")
	check(session.keep_cleaning() and session.can_use_tools(), "Keep Cleaning restores tools")
	check(surface.image.get_data() == state and surface.fragments.recovered_count() == 2 and session.preparation_complete, "Keep Cleaning preserves exact state")
	check(main.session_ui.archive_button.visible and not main.session_ui.modal.visible, "archive remains accessible after Keep Cleaning")
	for id in range(5): check(control.select_tool(id), "all five tools restored")
	P5Fixture.reveal(surface, [100, 100, 100, 100])
	P5Fixture.clean(surface)
	var index := surface.fossil.field.index_at_map(Vector2(252, 199))
	surface.apply_impact(Vector2(252, 199), control.tools[1])
	surface.apply_impact(Vector2(252, 199), control.tools[1])
	session.flush()
	check(surface.fossil.condition == 97, "Keep Cleaning permits ordinary protected contact then damage")
	check(session.snapshot().exposure > snapshot.exposure and session.snapshot().cleanliness >= snapshot.cleanliness, "values evolve during Keep Cleaning")
	check(session.completion_snapshot == snapshot, "optional work cannot rewrite completion snapshot")
	check(session.additional_tool_actions_after_completion == 2, "post-completion actions counted once per applied action")
	check(session.archive() and not session.archive(), "archive is one-shot")
	check(session.archive_snapshot == session.snapshot() and session.archive_snapshot.condition == 97, "archive captures latest values")
	check(main.session_ui.modal.visible and main.session_ui.another_button.visible and not main.session_ui.keep_button.visible, "archived summary offers another block")
	check(main.session_ui.card_stats.text == PreparationUI.summary(session.archive_snapshot), "final UI uses archive snapshot")
	var metrics := session.metrics()
	check(metrics.time_after_completion > 0 and metrics.exposure_at_archive > metrics.exposure_at_completion and metrics.condition_at_archive == 97, "completion to archive metrics")
	evidence.metrics = metrics
	state = surface.image.get_data()
	control._held = true
	control._physics_process(1.0 / 60)
	check(not session.can_use_tools() and not control.select_tool(1) and surface.image.get_data() == state, "archive disables tools")
	main.session_ui.another_button.pressed.emit()
	check(not session.preparation_complete and not session.archived and session.classification_stage == 0, "Another Block resets session")
	check(surface.fossil.exposed_cells == 0 and surface.fossil.condition == 100 and surface.fossil.direct_contact_consumed == PackedByteArray([0, 0, 0, 0, 0]), "Another Block resets anatomy/protections")
	check(surface.fragments.recovered_count() == 0 and surface.fragments.grabbed == -1 and surface.fragments.ready == [false, false], "Another Block resets recovery")
	check(surface.loose_debris.persistent_count() == 0 and surface.loose_debris.flying.is_empty() and surface.fracture.stress.is_empty(), "Another Block resets mess/fracture")
	check(surface.bone_film.exposed_totals == PackedInt32Array([0, 0, 0, 0, 0]) and surface.residue.last_cleared == 0, "Another Block resets film and residue")
	check(session.metrics().time_after_completion == 0 and session.additional_tool_actions_after_completion == 0 and session.completion_snapshot.is_empty() and session.archive_snapshot.is_empty(), "Another Block resets all metrics/snapshots")
	check(surface._heights.count(1.0) == surface.size.x * surface.size.y and control.selected_index == 0 and main.camera.zoom_factor == 1, "Another Block returns exact deterministic terrain and view")
	check(not session.archive() and not session.keep_cleaning(), "premature completion actions rejected")
	for id in range(3): accomplish(id)
	var direct_snapshot := session.completion_snapshot.duplicate()
	check(session.archive() and session.archive_snapshot == direct_snapshot and not session.keep_cleaning_chosen, "direct Archive from completion card")
	var key := InputEventKey.new()
	key.physical_keycode = KEY_R
	key.pressed = true
	root.push_input(key, true)
	check(session.can_use_tools() and not session.archived and surface.fossil.exposed_cells == 0, "R also resets archived session")
	P5Fixture.ready_fragment(surface, 0)
	control.select_tool(4)
	mouse(screen_at(surface.fragments.field.centers[0]), true)
	check(surface.fragments.grabbed == 0, "reset test has an actual held fragment")
	root.push_input(key.duplicate(), true)
	check(surface.fragments.grabbed == -1 and not surface.fragments.ready[0] and surface._heights.count(1.0) == surface.size.x * surface.size.y, "R cancels and resets a held fragment exactly")

func run() -> void:
	root.size = Vector2i(1920, 1080)
	root.content_scale_size = root.size
	main = load("res://scenes/prototype_main.tscn").instantiate()
	root.add_child(main)
	surface = main.block.working_map
	session = main.session
	control = main.controller
	control.set_physics_process(false)
	session.notice.connect(on_notice)
	session.completed.connect(on_complete)
	await process_frame
	test_rules()
	test_authoring_and_readiness()
	test_film_and_progression()
	test_objective_orders()
	test_forceps_input()
	test_keep_cleaning_archive()
	# Deferred bursts finish once; there must be no P5 polling at idle.
	await process_frame
	await process_frame
	var refreshes := session.refresh_count
	var ui_refreshes: int = main.session_ui.refresh_count
	for i in range(10): await process_frame
	check(refreshes == session.refresh_count and ui_refreshes == main.session_ui.refresh_count, "idle has zero progression/UI recomputation")
	evidence.checks = checks
	evidence.failures = failures
	FileAccess.open("res://work/test-logs/p5-tests.json", FileAccess.WRITE).store_string(JSON.stringify(evidence, "\t"))
	print("P5 TESTS: %d checks, %d failures" % [checks, failures])
	main.queue_free()
	await process_frame
	session = null
	surface = null
	quit(0 if failures == 0 else 1)
