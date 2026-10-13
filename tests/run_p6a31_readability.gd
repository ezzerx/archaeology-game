extends "res://tests/run_p6a3_sensory.gd"
const MasteryUI := preload("res://scripts/p6a31/mastery_ui.gd")

func functional() -> void:
	# Native trajectories and complete state hashes from P6A3, with P6A3.1 active.
	await super.functional()
	for pair in [[0.0, 0], [84.99, 84], [94.99, 94], [98.999, 98], [99.0, 100], [100.0, 100]]:
		check(MasteryUI.display_percent(pair[0], true) == pair[1], "player display boundary " + str(pair))
	check(MasteryUI.display_percent(99.0, false) == 99 and MasteryUI.display_percent(100.0, false) == 99,
		"coverage guard never permits displayed 100 when blocked")
	main.reset_specimen()
	var s: WorkingSurface = main.block.working_map
	P5Fixture.distributed(s, 99.1)
	P5Fixture.clean(s)
	main.session.flush()
	check(main.session.coverage_passed and main.session_ui.exposure_label.text == "100%", "native >=99 with scattered tiny residuals resolves to 100")
	check(main.session.snapshot().exposure < 100 and main.session.snapshot().exposure >= 99, "display does not rewrite raw exposure")
	var baseline := state()
	var completion: Dictionary = main.session.completion_snapshot.duplicate(true)
	main.toggle_readability()
	check(state() == baseline and main.session.completion_snapshot == completion, "comparison preserves native state and latched completion snapshot")
	main.toggle_readability()
	check(state() == baseline, "comparison back preserves native state")
	check(main.session.archive() and main.session_ui.archive_metrics.text.contains("Reveal 100%"), "archive uses same display precision")
	check(main.session.archive_snapshot.exposure < 100, "archive retains exact raw exposure")
	main.reset_specimen()
	check(main.session_ui.condition_bar.value == 100 and main.session_ui.exposure_label.text == "0%", "reset clears presentation and restores care gauge")
	P5Fixture.reveal(s, [100, 100, 100, 100])
	main.session.flush()
	var point := Vector2(280, 245)
	# Stationary Brush emits from real removal, with no movement requirement.
	s.apply_continuous(point, point, main.controller.tools[0], 1.0 / 60)
	check(main.feedback.film_puffs == 1, "stationary real cleaning releases one bounded dust puff")
	var cell := Vector2i(main.feedback.last_film_point)
	var index := cell.y * s.size.x + cell.x
	check(s.fossil.exposed[index] != 0 and s.bone_film.last_cleaned_cell == cell, "dust origin is an actual exposed cell whose Film decreased")
	check(s.last_action.bone_film_cleared > 0, "dust is synchronized with committed removal")
	P5Fixture.clean(s)
	main.feedback.reset()
	s.apply_continuous(point, point, main.controller.tools[0], 1.0 / 60)
	check(main.feedback.film_puffs == 0 and s.bone_film.last_cleaned_cell == Vector2i(-1,-1), "already clean Bone emits no fake Film-removal dust")
	var before := state()
	s.fossil.damage_at(index, 3)
	main.session.flush()
	check(main.session_ui.condition_bar.value == 97 and main.session_ui.condition_label.text.contains("Excellent"), "minor native damage lowers gauge without inventing a tier")
	check(main.block.material.get_shader_parameter("mastery_condition") == 97.0, "visual damage consumes exact native Condition")
	s.fossil.damage_at(index, 15)
	main.session.flush()
	check(main.session_ui.condition_bar.value == 82 and main.session_ui.condition_label.text.contains("Fair"), "care gauge and qualitative tier stay aligned")
	var after := state()
	for key in ["height", "ceilings", "film", "exposed"]:
		check(before[key] == after[key], "cosmetic Condition does not alter " + key)
	main.controller.select_tool(1)
	check(main.controller.config.radius == 26 and main.block.material.get_shader_parameter("mastery_cursor_scale") == .55, "smaller Chisel marker preserves real 26-cell radius")
	main.controller.select_tool(3)
	check(main.block.material.get_shader_parameter("mastery_cursor_scale") == 1.0, "other tool marker retains real radius")
	main.reset_specimen()
	check(main.block.material.get_shader_parameter("mastery_condition") == 100.0 and main.feedback.film_puffs == 0, "reset restores undamaged Bone and clears new VFX")

func visual() -> void:
	main.select_fixture(3)
	await zoom_to(3, Vector2(280,245))
	main.feedback.proxies_enabled = false
	main.controller.set_physics_process(false)
	main.controller.cancel_stroke()
	main.session_ui.notice_label.hide()
	var s: WorkingSurface = main.block.working_map
	# Same real Film state with before/after presentation at low residual dirt.
	var brush: ToolDefinition = main.controller.tools[0].duplicate()
	brush.radius = 1.0 # QA-only isolated tile-centre cleanup, no runtime preset change.
	for y in range(s.bone_film.size.y):
		for x in range(s.bone_film.size.x):
			var point := Vector2(x,y)*BoneSurfaceFilm.STRIDE+Vector2.ONE*1.5
			s.bone_film.clean(point,point,brush,BoneSurfaceFilm.INITIAL*.94/brush.bone_film_clear)
	check(absf(s.bone_film.cleanliness_percent()-94.0)<.01, "Film comparison is really at 94% cleanliness")
	await settle()
	var baseline := state()
	for enabled in [false, true]:
		if main.readability_enabled != enabled: main.toggle_readability()
		main.feedback.proxies_enabled = false
		main.session_ui.notice_label.hide()
		main.block.show_cursor({"inside":false}, 1)
		await snap("film-" + ("after" if enabled else "before"))
		check(state() == baseline, "Film readability comparison preserves real film and geometry")
	if mode == "film94": return
	P5Fixture.clean(s)
	await settle()
	for condition in [100.0, 97.0, 85.0, 70.0]:
		if condition < s.fossil.condition:
			for index in range(s.fossil.exposed.size()):
				if s.fossil.exposed[index] != 0:
					s.fossil.damage_at(index, s.fossil.condition-condition)
					break
		await settle()
		main.block.show_cursor({"inside":false}, 1)
		await snap("condition-"+str(int(condition)))

func run() -> void:
	out = "res://work/test-logs/p6a31/"
	DirAccess.make_dir_recursive_absolute(out)
	root.size = Vector2i(1920,1080)
	root.content_scale_size = root.size
	var args := OS.get_cmdline_user_args()
	mode = args[0] if not args.is_empty() else "tests"
	AudioServer.set_bus_mute(0, true)
	main = load("res://scenes/p6a31_mastery_readability.tscn").instantiate()
	root.add_child(main)
	main.display.persist = false
	root.mode = Window.MODE_WINDOWED
	root.size = Vector2i(1920,1080)
	main.controller.set_physics_process(false)
	main.panel.hide()
	if mode == "film94": root.size = Vector2i(1280,720)
	await settle()
	evidence["runtime"] = {"engine":Engine.get_version_info().string, "gpu":RenderingServer.get_video_adapter_name(), "physics_hz":Engine.physics_ticks_per_second}
	if mode == "tests": await functional()
	elif mode in ["visual", "film94"]: await visual()
	evidence["checks"] = checks
	evidence["failures"] = failures
	FileAccess.open(out+mode+".json", FileAccess.WRITE).store_string(JSON.stringify(evidence,"\t"))
	print("P6A3.1 ", mode, ": ", checks, " checks, ", failures.size(), " failures")
	main.queue_free()
	await create_timer(.3).timeout
	quit(0 if failures.is_empty() else 1)
