extends "res://tests/run_p5_tests.gd"

func test_quality() -> void:
	main.reset_specimen()
	for item in [[94.999, 100, false], [100, 94.999, false], [95, 95, true], [98, 99, true]]:
		check(PreparationRules.fine_preparation(item[0], item[1]) == item[2], "95/95 quality boundary " + str(item))
	P5Fixture.reveal(surface, [96, 0, 0, 0])
	session.flush()
	check(session.quality_marks == [false, false, false, false], "exposure alone earns no star")
	var terrain := surface.image.get_data()
	P5Fixture.clean(surface)
	session.flush()
	check(session.quality_marks == [true, false, false, false], "cleaned skull earns first mark")
	check(main.session_ui.quality_cue_count == 1 and main.session_ui.component_labels[0].text.contains("★"), "one local shine and persistent dossier star")
	check(surface.fossil.condition == 100 and surface.image.get_data() == terrain, "quality does not modify condition or terrain")
	check(not session.preparation_complete and not session.archive(), "quality is not museum completion")
	for i in range(4): session.invalidate(); session.flush()
	check(main.session_ui.quality_cue_count == 1, "no repeated quality reward")
	P5Fixture.reveal(surface, [96, 96, 96, 96])
	P5Fixture.clean(surface)
	session.flush()
	check(session.quality_marks == [true, true, true, true] and main.session_ui.quality_cue_count == 4, "four independent quality marks")
	check(not session.preparation_complete, "four stars never replace required recovery")
	P5Fixture.recover(surface, 0)
	P5Fixture.recover(surface, 1)
	session.flush()
	check(session.completion_snapshot.quality_count == 4, "completion snapshot carries optional quality")
	session.keep_cleaning()
	check(session.quality_marks.count(true) == 4, "Keep Cleaning preserves stars")
	check(session.archive() and session.archive_snapshot.quality_count == 4, "archive captures optional quality")
	check(main.session_ui.archive_cue_count == 1, "one archive closure cue")
	session.archive()
	session.changed.emit()
	check(main.session_ui.archive_cue_count == 1, "refresh cannot replay archive reward")
	main.reset_specimen()
	check(session.quality_marks.count(true) == 0 and main.session_ui.quality_cue_count == 0 and not main.session_ui.archive_sound.playing, "reset re-arms marks and stops presentation")
	P5Fixture.reveal(surface, [65, 65, 65, 65])
	P5Fixture.clean(surface)
	P5Fixture.recover(surface, 0)
	P5Fixture.recover(surface, 1)
	session.flush()
	check(session.preparation_complete and session.quality_marks.count(true) == 0, "museum request completes with zero optional stars")
	check(session.archive(), "zero stars never block archive")
	check(main.session_ui.card_delta.text.contains("Extra polishing was optional.") and not main.session_ui.card_delta.text.contains("0 of 4"), "zero-star archive remains positive, no unfinished checklist")
	evidence.zero_star_archive = session.archive_snapshot.duplicate(true)

func test_discovery_and_tray() -> void:
	main.reset_specimen()
	notices.clear()
	var field := surface.fragments.field
	for id in range(2):
		check(surface.fragments.target_at(field.cells[id][0]) == -1 and not surface.fragments.detected[id], "intact matrix hides fragment and cue")
		var nearest := INF
		for index in surface.fossil.field.component_ids.size():
			if surface.fossil.field.component_ids[index] == 0: continue
			@warning_ignore("integer_division")
			nearest = minf(nearest, field.centers[id].distance_to(Vector2(index % surface.size.x, index / surface.size.x)))
		check(nearest < 35, "fragment is adjacent to normal anatomical preparation")
		evidence["fragment_%d_distance_to_anatomy" % id] = nearest
		for n in range(floori(field.cells[id].size() * 0.09)):
			var index := field.cells[id][n]
			surface._heights[index] = field.ceilings[index]
		surface.update_fragments(field.bounds[id])
		check(not surface.fragments.detected[id], "less than ten percent has no discovery cue")
		for n in range(ceili(field.cells[id].size() * 0.10)):
			var index := field.cells[id][n]
			surface._heights[index] = field.ceilings[index]
		surface.update_fragments(field.bounds[id])
		check(surface.fragments.detected[id] and not surface.fragments.ready[id], "meaningful exposed fragment is detected before ready")
	var discoveries := notices.filter(func(message: String): return message.begins_with("Loose fragment detected")).size()
	surface.update_fragments(Rect2i(Vector2i.ZERO, surface.size))
	check(discoveries == 2 and notices.filter(func(message: String): return message.begins_with("Loose fragment detected")).size() == 2, "one discovery event per fragment")
	var tray: FragmentTray3D = main.fragment_tray
	check(tray.in_view() and tray.global_position.x + 0.083 < -main.block.surface_size.x / 2, "physical tray sits outside block, visible at overview")
	check(tray.accepts_drop(tray.get_global_rect().get_center()), "ray hits physical inner floor")
	check(not tray.accepts_drop(tray.get_global_rect().position + Vector2(2, 2)), "tray rim does not act like an oversized UI target")
	check(not tray.accepts_drop(Vector2(960, 540)), "specimen is not a drop target")
	P5Fixture.ready_fragment(surface, 0)
	control._focused = true
	control._pointer_inside = true
	control.select_tool(4)
	main.block.flush_texture()
	mouse(screen_at(field.centers[0]), true)
	mouse(tray.get_global_rect().position + Vector2(2, 2), false)
	check(not surface.fragments.recovered[0] and surface.fragments.grabbed == -1, "release on rim returns safely")
	mouse(screen_at(field.centers[0]), true)
	mouse(tray.get_global_rect().get_center(), false)
	check(surface.fragments.recovered[0] and main.forceps_view.pieces[0].global_position.is_equal_approx(tray.slot_world(0)), "recovered mesh physically rests in tray")
	check(tray.count_label.text == "FRAGMENTS 1 / 2", "physical count updated")
	main.reset_specimen()
	check(surface.fragments.detected == [false, false] and tray.count_label.text == "FRAGMENTS 0 / 2", "reset clears discovery and tray")

func run() -> void:
	main = load("res://scenes/prototype_main.tscn").instantiate()
	root.add_child(main)
	surface = main.block.working_map
	session = main.session
	control = main.controller
	control.set_physics_process(false)
	session.notice.connect(on_notice)
	await process_frame
	test_quality()
	test_discovery_and_tray()
	evidence.checks = checks
	evidence.failures = failures
	FileAccess.open("res://work/test-logs/p5c-tests.json", FileAccess.WRITE).store_string(JSON.stringify(evidence, "\t"))
	print("P5 CORRECTION: %d checks, %d failures" % [checks, failures])
	main.queue_free()
	await process_frame
	session = null
	surface = null
	quit(0 if failures == 0 else 1)
