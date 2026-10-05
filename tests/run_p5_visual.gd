extends "res://tests/run_p5_tests.gd"
## Real production scene / UI / input. Fixture setup is only for test duration.
var captures: Array[String] = []

func screenshot(label: String) -> Image:
	await process_frame
	await RenderingServer.frame_post_draw
	var picture := root.get_texture().get_image()
	var path := "res://work/test-logs/p5-" + label + ".png"
	picture.save_png(path)
	captures.append(path)
	return picture

func settle() -> void:
	session.flush()
	main.block.flush_texture()
	await process_frame
	await process_frame

func click_button(button: Button) -> void:
	var point := button.get_global_rect().get_center()
	mouse(point, true)
	mouse(point, false)
	await settle()

func point_at(point: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = screen_at(point)
	root.push_input(motion, true)
	control.refresh_view()

func check_layout() -> void:
	var ui: PreparationUI = main.session_ui
	for panel in [ui.objectives, ui.dossier, ui.tray]:
		var rect: Rect2 = panel.get_global_rect()
		check(rect.position.x >= 0 and rect.position.y >= 0 and rect.end.x <= 1920 and rect.end.y < 975, "panel fits reference viewport: " + str(rect))
	check(ui.objectives.get_global_rect().end.x <= 245 and ui.dossier.position.x >= 1675, "both panels stay in desk margins at overview")
	check(ui.objectives.get_global_rect().end.y < ui.tray.get_global_rect().position.y - 25, "request leaves physical tray and its count unobstructed")
	check(main.toolbar.get_global_rect().end.x <= 1920, "five tools fit toolbar")
	for label in ui.objective_labels + ui.objective_details + [ui.stats_label, ui.classification_label, ui.request_status] + ui.component_labels:
		check(label.get_global_rect().end.x <= 1910 and label.get_global_rect().end.y < 975, "visible labels fit")

func visual_fixture() -> void:
	# A partly worked block with real, authored ceiling silhouettes.
	for y in range(165, 570):
		for x in range(150, 830):
			var index := y * surface.size.x + x
			surface._heights[index] = maxf(surface.structural_ceilings[index] + 0.025, 0.19)
	P5Fixture.commit(surface)
	P5Fixture.reveal(surface, [68, 65, 65, 65])
	P5Fixture.clean(surface)

func run() -> void:
	if DisplayServer.get_name() == "headless": quit(1); return
	root.size = Vector2i(1920, 1080)
	root.content_scale_size = root.size
	AudioServer.set_bus_mute(0, true)
	main = load("res://scenes/prototype_main.tscn").instantiate()
	root.add_child(main)
	surface = main.block.working_map
	session = main.session
	control = main.controller
	control.set_physics_process(false)
	control._focused = true
	control._pointer_inside = true
	await settle()
	check_layout()
	check(main.session_ui.classification_label.text == "Unknown" and not main.session_ui.modal.visible, "start dossier Unknown and no modal")
	await screenshot("01-start")
	P5Fixture.reveal(surface, [12, 0, 0, 0])
	await settle()
	check(main.session_ui.classification_label.text == "Vertebrate remains", "dossier stage 1")
	await screenshot("02-discovery")
	P5Fixture.reveal(surface, [12, 15, 0, 10])
	await settle()
	check(main.session_ui.classification_label.text == "Possible Theropod", "dossier stage 2")
	P5Fixture.reveal(surface, [35, 15, 0, 10])
	await settle()
	check(main.session_ui.classification_label.text == "Likely small theropod", "dossier stage 3")
	visual_fixture()
	P5Fixture.ready_fragment(surface, 0)
	await settle()
	control.select_tool(4)
	point_at(surface.fragments.field.centers[0])
	check(main.session_ui.hover_label.text.begins_with("Ready to recover") and main.block.material.get_shader_parameter("highlighted_fragment") == 0, "ready hover/highlight")
	await screenshot("03-ready")
	# Independent GPU check: source is ivory Bone, then becomes substrate while
	# the actual fragment is held. No terrain byte is allowed to change.
	var geometry := surface.image.get_data()
	var source_pixel := Vector2i(screen_at(surface.fragments.field.centers[0]))
	main.forceps_view.hide()
	main.block.set_debug_view(2)
	main.block.show_cursor({"inside": false}, 8)
	var bone_image := await screenshot("03a-fragment-bone-gpu")
	var bone_color: Color = main.block.material.get_shader_parameter("bone_color")
	check(bone_image.get_pixelv(source_pixel).is_equal_approx(bone_color) or
		absf(bone_image.get_pixelv(source_pixel).r - bone_color.r) < 0.02, "fragment source rendered as Bone")
	mouse(control._screen, true)
	await settle()
	var source_image := await screenshot("03b-fragment-held-source-gpu")
	check(absf(source_image.get_pixelv(source_pixel).r - bone_image.get_pixelv(source_pixel).r) > 0.05, "grab removes Bone from source pixels")
	check(surface.image.get_data() == geometry, "GPU source transition preserves terrain bytes")
	main.forceps_view.show()
	main.block.set_debug_view(0)
	check(surface.fragments.grabbed == 0 and main.forceps_view.pieces[0].visible, "fragment lifts with Forceps")
	var motion := InputEventMouseMotion.new()
	motion.position = Vector2(470, 680)
	root.push_input(motion, true)
	await screenshot("04-drag")
	check(main.block.material.get_shader_parameter("fragment_visible").x == 0, "held fragment leaves its source")
	mouse(main.session_ui.tray.get_global_rect().get_center(), false)
	await settle()
	check(surface.fragments.recovered_count() == 1 and main.forceps_view.pieces[0].visible, "tray has Fragment A")
	await screenshot("05-tray-one")
	P5Fixture.ready_fragment(surface, 1)
	await settle()
	point_at(surface.fragments.field.centers[1])
	mouse(control._screen, true)
	mouse(main.session_ui.tray.get_global_rect().get_center(), false)
	await settle()
	check(session.preparation_complete and main.session_ui.modal.visible and main.forceps_view.pieces[1].visible, "two fragments complete real UI loop")
	check(main.session_ui.card_stats.get_global_rect().end.x < 1300 and main.session_ui.card_archive_button.get_global_rect().end.y < 950, "completion card fits")
	await screenshot("06-complete")
	var completion := session.completion_snapshot.duplicate()
	await click_button(main.session_ui.keep_button)
	check(session.keep_cleaning_chosen and not main.session_ui.modal.visible and main.session_ui.archive_button.visible, "real Keep Cleaning click resumes")
	check_layout()
	await screenshot("07-keep-cleaning")
	P5Fixture.reveal(surface, [96, 96, 76, 89])
	P5Fixture.clean(surface)
	surface.apply_impact(Vector2(252, 199), control.tools[1])
	surface.apply_impact(Vector2(252, 199), control.tools[1])
	await settle()
	check(session.quality_marks == [true, true, false, false], "two optional stars visible after refinement")
	await create_timer(0.2).timeout
	await screenshot("07a-quality")
	check(session.completion_snapshot == completion, "completion card immutable after continued work")
	await click_button(main.session_ui.archive_button)
	check(session.archived and session.archive_snapshot.exposure > completion.exposure, "real Archive click captures improved specimen")
	check(main.session_ui.another_button.get_global_rect().end.y < 1020, "archive card fits")
	await create_timer(0.35).timeout
	check(main.session_ui.card.modulate.a == 1 and main.session_ui.archive_cue_count == 1, "archive confirmation animation finishes once")
	await screenshot("08-archive")
	await click_button(main.session_ui.another_button)
	check(session.classification_stage == 0 and surface.fragments.recovered_count() == 0 and not main.session_ui.modal.visible, "real Another Block click resets")
	await screenshot("09-another-block")
	root.size = Vector2i(1280, 720)
	await settle()
	check_layout()
	await screenshot("10-1280x720")
	root.size = Vector2i(1920, 1080)
	await settle()
	main.debug_panel.show()
	main.bone_panel.show()
	main.session_ui.set_debug_visible(true)
	main._process(0.2)
	check(main.bone_panel.get_global_rect().end.y < 970, "F1 session metrics fit above toolbar")
	await screenshot("11-debug")
	main.debug_panel.hide()
	main.bone_panel.hide()
	main.session_ui.set_debug_visible(false)
	P5Fixture.reveal(surface, [65, 65, 65, 65])
	P5Fixture.clean(surface)
	P5Fixture.recover(surface, 0)
	P5Fixture.recover(surface, 1)
	await settle()
	await click_button(main.session_ui.card_archive_button)
	await create_timer(0.35).timeout
	check(session.archive_snapshot.quality_count == 0 and main.session_ui.another_button.visible, "archive without optional marks is equally complete")
	await screenshot("12-archive-request-only")
	evidence = {"checks": checks, "failures": failures, "captures": captures, "completion": completion}
	FileAccess.open("res://work/test-logs/p5-visual.json", FileAccess.WRITE).store_string(JSON.stringify(evidence, "\t"))
	print("P5 VISUAL: %d checks, %d failures" % [checks, failures])
	main.queue_free()
	await process_frame
	session = null
	surface = null
	quit(0 if failures == 0 else 1)
