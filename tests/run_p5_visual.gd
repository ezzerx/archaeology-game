extends "res://tests/run_p5_tests.gd"
## Real production scene / UI / input. Fixture setup is only for test duration.
var captures: Array[String] = []

func screenshot(label: String) -> Image:
	await process_frame
	await RenderingServer.frame_post_draw
	var picture := root.get_texture().get_image()
	var path := "res://work/test-logs/p5s-" + label + ".png"
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

func check_layout(overview := true) -> void:
	var ui: PreparationUI = main.session_ui
	var rect := ui.preparation_card.get_global_rect()
	var viewport := root.get_visible_rect()
	check(rect.position == Vector2(16, 130) and rect.size.x <= 224, "same compact top-left anchor")
	check(viewport.encloses(rect) and rect.end.y < main.toolbar.get_global_rect().position.y, "card fits above tools")
	if overview:
		var block_left: float = main.camera.unproject_position(main.block.to_global(Vector3(-0.55, 0.12, 0))).x
		check(rect.end.x < block_left, "card entirely outside block at overview")
	check(viewport.encloses(main.toolbar.get_global_rect()) and main.toolbar.get_child_count() == 4, "four-tool toolbar fits")
	for label in [ui.state_label, ui.exposure_label, ui.cleanliness_label, ui.closure_label, ui.fine_label]:
		if label.is_visible_in_tree(): check(rect.encloses(label.get_global_rect()), "text fits within only permanent card: " + label.text)
	for button in [ui.archive_button, ui.keep_button]:
		if button.is_visible_in_tree(): check(rect.encloses(button.get_global_rect()), "action fits within card")

func visual_fixture(percent: float) -> void:
	for y in range(165, 570):
		for x in range(150, 830):
			var index := y * surface.size.x + x
			surface._heights[index] = minf(surface._heights[index], maxf(surface.structural_ceilings[index] + 0.025, 0.19))
	P5Fixture.commit(surface)
	P5Fixture.reveal(surface, [percent, percent, percent, percent])
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
	await screenshot("01-start")
	P5Fixture.reveal(surface, [12, 0, 0, 0]); await settle()
	check(main.session_ui.notice_label.text == "Discovery updated: Vertebrate remains", "classification is transient notice only")
	await screenshot("02-discovery")
	await create_timer(3.3).timeout
	check(main.session_ui.notice_label.text == "", "discovery disappears")
	visual_fixture(67); await settle()
	check(not session.preparation_complete and not main.session_ui.fine_label.visible, "mastery hidden before required work is done")
	await screenshot("03-preparing")
	visual_fixture(86); await settle()
	check(session.preparation_complete and not main.session_ui.modal.visible and session.can_use_tools(), "native completion is nonblocking")
	check_layout()
	await screenshot("04-ready")
	var completion := session.completion_snapshot.duplicate()
	var geometry := surface.image.get_data()
	await click_button(main.session_ui.keep_button)
	check(session.keep_cleaning_chosen and surface.image.get_data() == geometry and main.session_ui.archive_button.visible, "real Keep Cleaning click keeps state and archive access")
	visual_fixture(96); await settle()
	check(session.fine_preparation and main.session_ui.quality_cue_count == 1 and not main.session_ui.modal.visible, "single global star without modal")
	check_layout()
	await create_timer(0.12).timeout
	await screenshot("05-fine-glint")
	await create_timer(0.8).timeout
	check(main.session_ui.fine_label.modulate == PreparationUI.GOLD, "brief glint settles to persistent gold star")
	await screenshot("06-fine")
	check(session.completion_snapshot == completion, "completion record remains frozen")
	await click_button(main.session_ui.archive_button)
	check(session.archived and main.session_ui.card_star.visible, "real archive click with star")
	await create_timer(0.3).timeout
	check(main.session_ui.card.modulate.a == 1 and root.get_visible_rect().encloses(main.session_ui.card.get_global_rect()), "short archive entrance and card fit")
	await screenshot("07-archive-fine")
	await click_button(main.session_ui.another_button)
	check(not session.preparation_complete and not session.fine_preparation and surface.fossil.exposed_cells == 0, "real Another Block click resets")
	await screenshot("08-another-block")
	visual_fixture(86); await settle()
	await click_button(main.session_ui.archive_button)
	await create_timer(0.3).timeout
	check(session.archived and not session.fine_preparation and not main.session_ui.card_star.visible, "archive without star is complete and concise")
	await screenshot("09-archive")
	await click_button(main.session_ui.another_button)
	root.size = Vector2i(1280, 720); await settle()
	check_layout()
	await screenshot("10-1280x720")
	# Narrower logical viewport (4:3): retain same anchor and translucent overlay.
	root.size = Vector2i(1440, 1080); root.content_scale_size = root.size; await settle()
	visual_fixture(86); await settle()
	check_layout(false)
	check(main.session_ui.preparation_card.get_theme_stylebox("panel").bg_color.a < 1, "compact narrow overlay is translucent")
	await screenshot("11-narrow")
	root.size = Vector2i(1920, 1080); root.content_scale_size = root.size; await settle()
	main.debug_panel.show(); main.bone_panel.show(); main.session_ui.set_debug_visible(true)
	main._process(0.2)
	check(main.bone_label.text.contains("Fine Preparation") and main.bone_label.text.contains("Completion E/C/Q"), "F1 retains detailed state and measurements")
	await screenshot("12-debug")
	evidence.captures = captures
	evidence.completion = completion
	await finish("p5s-visual")
