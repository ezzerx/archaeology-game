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


# Controlled metrics exercise exact decimal boundaries through the real session;
# native-cell integration and an independent film oracle are tested separately.
class MeasuredFossil extends FossilState:
	var percent := 0.0
	var components: Array[float] = [100.0, 100.0, 100.0, 100.0]
	func exposure_percent(component: int = 0) -> float:
		return percent if component == 0 else components[component - 1]

class MeasuredFilm extends BoneSurfaceFilm:
	var percent := 0.0
	func cleanliness_percent(_component: int = 0) -> float:
		return percent

func test_boundaries() -> void:
	var source := WorkingSurface.new(Vector2i(16, 16))
	var fossil := MeasuredFossil.new(FossilField.new(Vector2i(16, 16)))
	var film := MeasuredFilm.new(Vector2i(16, 16))
	source.fossil = fossil
	source.bone_film = film
	var state := PreparationSession.new(source)
	var events := [0, 0]
	state.completed.connect(func(_value: Dictionary): events[0] += 1)
	state.finely_prepared.connect(func(): events[1] += 1)
	for pair in [[84.99, 100], [100, 84.99]]:
		fossil.percent = pair[0]
		film.percent = pair[1]
		state.invalidate(); state.flush()
		check(not state.preparation_complete and not state.archive(), "84.99 never allows archive " + str(pair))
	fossil.percent = 85; film.percent = 85
	state.invalidate(); state.flush()
	check(state.preparation_complete and events[0] == 1 and not state.fine_preparation, "exact 85/85 completes once, no star")
	check(state.coverage_passed, "exact global boundary test has passing coverage")
	var first := state.completion_snapshot.duplicate()
	check(state.can_use_tools(), "85/85 does not interrupt excavation")
	for pair in [[94.99, 100], [100, 94.99]]:
		fossil.percent = pair[0]; film.percent = pair[1]
		state.invalidate(); state.flush()
		check(not state.fine_preparation and events[1] == 0, "94.99 does not earn star " + str(pair))
	fossil._condition = 31
	fossil.percent = 95; film.percent = 95
	state.invalidate(); state.flush()
	check(state.fine_preparation and events[1] == 1 and state.can_use_tools(), "exact 95/95 earns one global star independent of Condition")
	for pair in [[100, 100], [100, 70], [100, 100]]:
		fossil.percent = pair[0]; film.percent = pair[1]
		state.invalidate(); state.flush()
		check(state.preparation_complete and state.fine_preparation and events == [1, 1], "milestones persist, no 100% reward " + str(pair))
	check(state.completion_snapshot == first and state.archive(), "completion snapshot immutable; star archive allowed")
	check(state.archive_snapshot.fine_preparation and state.archive_snapshot.condition == 31, "archive captures current star and Condition")
	state.reset()
	check(not state.fine_preparation and not state.preparation_complete and state.archive_snapshot.is_empty(), "reset clears milestones and snapshots")
	fossil.percent = 85; film.percent = 85
	state.invalidate(); state.flush()
	check(state.archive() and not state.archive_snapshot.fine_preparation and not state.archive(), "exact 85/85 archive succeeds once without star")
	evidence.boundary_events = events

func test_active_scene() -> void:
	main.reset_specimen()
	check(surface.fragments == null and main.fragment_tray == null and main.forceps_view == null, "normal P5 has no fragments, tray or forceps view")
	check(control.tools.size() == 4 and main.toolbar.get_child_count() == 4 and not control.select_tool(4), "four tools only, fifth slot unreachable")
	var key := InputEventKey.new()
	key.physical_keycode = KEY_5; key.pressed = true
	root.push_input(key, true)
	check(control.selected_index == 0, "5 cannot activate dormant experiment")
	check(surface.structural_ceilings == surface.fossil.field.ceilings and surface.bone_display_image == surface.fossil.field.image, "normal field contains original skeleton only")
	check(surface.fossil.field.total_cells == 32290, "P4 anatomical totals preserved")
	var ui: PreparationUI = main.session_ui
	var panels := 0
	for child in ui.root_control.get_children():
		if child is PanelContainer: panels += 1
	check(panels == 1 and ui.controller.ui_blockers.size() == 2, "exactly one permanent card plus hidden archive blocker")
	check(ui.root_control.find_children("*", "ProgressBar", true, false).size() == 2, "only two progress bars")
	check(ui.state_label.text == "Museum standard · 85%" and not ui.fine_label.visible and not ui.modal.visible and not ui.archive_button.visible, "start has only task and two metrics")
	check(not main.debug_panel.visible and not main.bone_panel.visible, "exact Condition and debug data are hidden by default")
	P5Fixture.reveal(surface, [100, 0, 0, 0]); P5Fixture.clean(surface); session.flush()
	check(not session.fine_preparation and ui.quality_cue_count == 0, "one perfectly prepared component earns no global star")
	main.reset_specimen()
	P5Fixture.reveal(surface, [84, 84, 84, 84]); P5Fixture.clean(surface); session.flush()
	check(not session.preparation_complete, "native full cleanliness with below85 global exposure is incomplete")
	P5Fixture.reveal(surface, [86, 86, 86, 86]); session.flush()
	check(session.preparation_complete and not session.fine_preparation, "exposure can be final requirement, no fragment gate")
	check(ui.state_label.text == "✓ Ready to archive" and ui.closure_label.text.contains("optional"), "persistent completion wording permits stopping")
	check(ui.fine_label.visible and ui.fine_label.text.contains("95%") and ui.fine_label.text.contains("Optional") and ui.archive_button.visible and ui.keep_button.visible, "single optional hint and both actions after85")
	check(not ui.modal.visible and session.can_use_tools(), "completion stays in existing card without modal")
	var initial_snapshot := session.completion_snapshot.duplicate()
	var terrain := surface.image.get_data()
	check(session.keep_cleaning() and not session.keep_cleaning() and surface.image.get_data() == terrain, "Keep Cleaning records choice once, preserves terrain")
	check(ui.archive_button.visible and not ui.keep_button.visible, "archive remains available during optional work")
	P5Fixture.reveal(surface, [96, 96, 96, 96]); P5Fixture.clean(surface)
	surface.apply_impact(Vector2(252, 199), control.tools[1])
	surface.apply_impact(Vector2(252, 199), control.tools[1])
	session.flush()
	check(surface.fossil.condition == 97 and session.fine_preparation, "P4 protected contact then damage still works; Condition does not gate star")
	check(ui.quality_cue_count == 1 and ui.fine_label.text == "★ Fine Preparation" and not ui.modal.visible, "one subtle global cue without interruption")
	check(ui.fine_sound.stream != null and ui.fine_sound.volume_db <= -19, "quiet positive star sound configured")
	check(session.additional_tool_actions_after_completion == 2 and session.completion_snapshot == initial_snapshot, "optional actions counted and first snapshot frozen")
	for i in range(4): session.invalidate(); session.flush()
	check(ui.quality_cue_count == 1, "UI refresh cannot duplicate star cue")
	check(session.archive() and not session.archive(), "archive captures state once")
	check(session.archive_snapshot.fine_preparation and session.archive_snapshot.condition == 97 and not session.can_use_tools(), "archive freezes current record and locks tools")
	check(ui.modal.visible and not ui.preparation_card.visible and ui.card_star.visible and ui.another_button.visible, "archive is a short independent closure")
	check(ui.card_title.text == "✓ Specimen archived" and ui.card_subtitle.text == "Museum records updated.", "positive concise archive wording")
	check(ui.card.get_child(0).get_child_count() == 5 and ui.archive_cue_count == 1, "archive contains concise closure, optional star, care tier and one action")
	evidence.metrics = session.metrics()
	terrain = surface.image.get_data()
	control._held = true; control._screen = screen_at(Vector2(800, 400)); control._physics_process(1.0 / 60)
	check(surface.image.get_data() == terrain and not control.select_tool(1), "archive locks excavation and tool selection")
	ui.another_button.pressed.emit()
	check(not session.preparation_complete and not session.fine_preparation and not session.archived and session.completion_snapshot.is_empty() and session.archive_snapshot.is_empty(), "Another Block clears exact session state")
	check(surface.fossil.exposed_cells == 0 and surface.fossil.condition == 100 and surface._heights.count(1.0) == surface.size.x * surface.size.y, "Another Block resets all heights, exposure, Condition")
	check(surface.fossil.direct_contact_consumed == PackedByteArray([0, 0, 0, 0, 0]) and surface.bone_film.cleanliness_percent() == 0, "Another Block rearms four P4 protections and film")
	check(session.additional_tool_actions_after_completion == 0 and session.metrics().time_after_completion == 0 and not session.keep_cleaning_chosen, "Another Block clears metrics and choice")
	check(ui.quality_cue_count == 0 and ui.archive_cue_count == 0 and not ui.archive_sound.playing and not ui.fine_sound.playing and ui.notice_label.text == "", "reset clears all cues and pending notices")
	check(control.selected_index == 0 and main.camera.zoom_factor == 1, "Another Block resets tool and camera")
	P5Fixture.reveal(surface, [86, 86, 86, 86]); session.flush()
	check(not session.preparation_complete, "native exposure alone is insufficient")
	P5Fixture.clean(surface); session.flush()
	check(session.preparation_complete and not session.fine_preparation and session.archive(), "native Brush completes then archives without star")
	check(not ui.card_star.visible and ui.another_button.visible, "no star line or unfinished checklist on ordinary archive")
	key.physical_keycode = KEY_R; root.push_input(key, true)
	check(not session.archived and not session.preparation_complete and surface.fossil.exposed_cells == 0, "R resets archived session too")

func test_coverage() -> void:
	for id in range(4):
		var parts: Array[float] = [100.0, 100.0, 100.0, 100.0]
		parts[id] = 64.99
		check(not PreparationRules.coverage_passes(parts), "every major component must reach65: " + str(id))
		parts[id] = 65
		check(PreparationRules.coverage_passes(parts), "exact65 passes: " + str(id))
	main.reset_specimen()
	P5Fixture.reveal_counts(surface, [7756, 7243, 10771, 1956])
	P5Fixture.clean(surface); session.flush()
	var original := session.snapshot()
	check(original.exposure >= 85 and original.cleanliness >= 85 and not session.coverage_passed, "real B17 at85.865% leaves70% of hind limb buried")
	check(not session.preparation_complete and not session.archive() and main.session_ui.coverage_label.visible, "coverage blocks archive with one contextual line")
	check(not main.session_ui.fine_label.visible and not main.session_ui.archive_button.visible, "blocked preparation does not advertise mastery or archive")
	var count := session.coverage_checks
	for i in range(5): session.invalidate(); session.flush()
	check(session.coverage_checks == count, "film/condition/ordinary refresh cannot recheck coverage")
	main.reset_specimen()
	# Move exactly2282 exposed cells from Skull to Limb: same global score, adequate spread.
	P5Fixture.reveal_counts(surface, [5474, 7243, 10771, 4238])
	P5Fixture.clean(surface); session.flush()
	equal(session.snapshot().exposure, original.exposure, "same global exposure, different anatomical distribution")
	check(session.coverage_passed and session.preparation_complete and session.archive(), "same score with every major part65+ allows archive")
	evidence.coverage = {"blocked": original, "allowed": session.archive_snapshot.duplicate(true), "threshold": PreparationRules.COVERAGE_MIN_EXPOSURE}
	main.reset_specimen()
	check(not session.coverage_passed and session.coverage_checks == 0 and not main.session_ui.coverage_label.visible, "reset clears guard/cache/context")
	P5Fixture.reveal_counts(surface, [7756, 7243, 10771, 4237]); P5Fixture.clean(surface); session.flush()
	check(not session.preparation_complete, "one native cell below limb65 is blocked despite92.9 global")
	var before := completion_count
	P5Fixture.reveal_counts(surface, [7756, 7243, 10771, 4238]); session.flush()
	check(session.preparation_complete and completion_count == before + 1, "final coverage cell triggers completion, no near100 requirement")
	session.invalidate(); session.flush()
	check(completion_count == before + 1 and not main.session_ui.coverage_label.visible, "guard completion fires once and clears contextual blocker")

func test_condition() -> void:
	for pair in [[100, "Excellent"], [95, "Excellent"], [94.99, "Good"], [85, "Good"], [84.99, "Fair"], [70, "Fair"], [69.99, "Damaged"], [0, "Damaged"]]:
		check(PreparationRules.CONDITION_TIERS[PreparationRules.condition_tier(pair[0])] == pair[1], "exact care tier " + str(pair))
	main.reset_specimen()
	check(main.session_ui.condition_label.text == "Condition · Excellent", "care label visible from reset, no percentage")
	P5Fixture.reveal(surface, [96, 96, 96, 96]); session.flush()
	var index := surface.fossil.field.index_at_map(Vector2(252, 199))
	var drops: Array[String] = []
	var callback := func(tier: String): drops.append(tier)
	session.condition_tier_dropped.connect(callback)
	var exposure := surface.fossil.exposure_percent()
	var cleanliness := surface.bone_film.cleanliness_percent()
	var coverage_checks := session.coverage_checks
	for amount in [5, 1, 9, 1, 14, 1]:
		surface.fossil.damage_at(index, amount); session.flush()
	check(drops == ["Good", "Fair", "Damaged"], "one event per real downward tier transition, no repeats within tier")
	check(session.coverage_checks == coverage_checks, "care feedback never rescans coverage")
	check(surface.fossil.exposure_percent() == exposure and surface.bone_film.cleanliness_percent() == cleanliness, "Condition never changes exposure or cleanliness")
	check(main.session_ui.condition_label.text == "Condition · Damaged" and main.session_ui.notice_label.text == "Condition: Damaged", "subtle contextual notice and qualitative care state")
	main.session_ui._show_notice("Discovery updated: test")
	check(main.session_ui.notice_label.text == "Condition: Damaged", "simultaneous discovery does not erase care feedback")
	for i in range(5): session.invalidate(); session.flush()
	check(drops.size() == 3, "refresh does not replay tier drops")
	P5Fixture.clean(surface); session.flush()
	check(surface.fossil.condition == 69 and session.fine_preparation and session.preparation_complete, "cleaning cannot restore Condition or prevent mastery/readiness")
	check(session.archive() and main.session_ui.card_condition.text == "Condition · Damaged" and main.session_ui.card_star.visible, "Damaged plus Fine Preparation can archive legitimately")
	main.reset_specimen()
	P5Fixture.reveal(surface, [96, 96, 96, 96])
	surface.fossil.damage_at(index, 6); P5Fixture.clean(surface); session.flush()
	check(drops == ["Good", "Fair", "Damaged", "Good"] and session.fine_preparation, "reset rearms care feedback; Good plus Fine Preparation is valid")
	check(session.archive() and session.archive_snapshot.condition_tier == "Good", "Good archive tier uses final snapshot")
	session.condition_tier_dropped.disconnect(callback)
	main.reset_specimen()

func finish(label: String) -> void:
	evidence.checks = checks
	evidence.failures = failures
	FileAccess.open("res://work/test-logs/" + label + ".json", FileAccess.WRITE).store_string(JSON.stringify(evidence, "\t"))
	print("%s: %d checks, %d failures" % [label, checks, failures])
	main.queue_free()
	await process_frame
	session = null
	surface = null
	quit(0 if failures == 0 else 1)

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
	test_boundaries()
	test_film_and_progression()
	test_active_scene()
	test_coverage()
	test_condition()
	await process_frame
	await process_frame
	var count := session.refresh_count
	var ui_count: int = main.session_ui.refresh_count
	for i in range(10): await process_frame
	check(session.refresh_count == count and main.session_ui.refresh_count == ui_count, "zero idle polling or UI rebuild")
	await finish("p5g-tests")
