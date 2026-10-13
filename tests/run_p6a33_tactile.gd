extends "res://tests/run_p6a32_binding.gd"
const QA_STORE := "res://work/test-logs/p6a33/collection-test.json"
const Distinction := preload("res://scripts/p6a33/preparation_distinction.gd")

func press_key(code: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = InputEventKey.new()
	event.physical_keycode = code
	event.pressed = false
	Input.parse_input_event(event)
	await process_frame

func tactile_checks() -> void:
	var s: WorkingSurface = main.block.working_map
	check(not main.mesh_enabled and main.readability_enabled,"preferred historical Bone style is the default")
	var baseline := state()
	var radius: float = main.controller.config.radius
	await press_key(KEY_F6)
	check(main.mesh_enabled and main.mesh_view.enabled,"actual dispatched F6 activates the Tripo comparison")
	check(main.controller.config.radius == radius and state() == baseline,"F6 neither tunes the true radius nor edits preparation")
	await press_key(KEY_F6)
	check(not main.mesh_enabled and main.controller.config.radius == radius,"second F6 restores historical Bone without tuning")
	await press_key(KEY_F7)
	check(not main.readability_enabled and s.bone_film.moving_clear_multiplier == 1.0,"actual F7 selects the previous preparation profile")
	check(main.controller.config.radius == radius and state() == baseline,"F7 preserves true radius and current state")
	await press_key(KEY_F7)
	check(main.readability_enabled and s.bone_film.moving_clear_multiplier > 1.0,"F7 restores the authorized fast moving Brush profile")
	check(load("res://config/soft_brush.tres").bone_film_clear == 1.0,"shared baseline Brush resource is unchanged")
	P5Fixture.reveal(s,[100,100,100,100])
	var point := Vector2(252,199)
	var index := s.fossil.field.index_at_map(point)
	check(s.fossil.exposed[index] != 0,"damage target really is exposed Skull")
	var before := state()
	s.apply_impact(point,main.controller.tools[1])
	check(s.fossil.condition == 100 and main.local_damage.marks.is_empty(),"first protected Chisel contact creates no local damage")
	s.apply_impact(point,main.controller.tools[1])
	check(s.fossil.condition < 100 and main.local_damage.marks.size() == 1,"real damaging Chisel impact creates one local mark")
	var picture: Image = main.local_damage.image
	check(picture.get_pixel(int(point.x),int(point.y)).r > 0,"damage appears at the committed contact")
	var remote := picture.get_region(Rect2i(390,230,400,320)).get_data()
	check(remote.count(0) == remote.size(),"unrelated ribs and spine remain unmarked")
	var first_map := picture.get_data()
	s.apply_impact(point,main.controller.tools[1])
	check(main.local_damage.marks.size() == 1 and picture.get_data() != first_map,"repeated local impact grows the same damage zone")
	var after := state()
	for key in ["ceilings","exposed","film"]:
		check(before[key] == after[key],"damage presentation does not edit " + key)
	main.reset_specimen()
	check(main.local_damage.marks.is_empty() and main.local_damage.image.get_data().count(0) == main.local_damage.image.get_data().size(),"reset clears every local mark")
	s.fossil.damage_at(index,10)
	check(main.local_damage.marks.is_empty(),"hidden Bone cannot receive a visible damage mark")
	P5Fixture.reveal(s,[100,100,100,100])
	var brush: ToolDefinition = main.controller.tools[0]
	var tile_point := Vector2(253.5,201.5)
	var uv := (tile_point+Vector2.ONE*.5)/Vector2(s.size)
	var film_before := s.bone_film.value_at(uv)
	for n in range(4):
		var a := tile_point+Vector2(-12 if n%2==0 else 12,0)
		var b := tile_point+Vector2(12 if n%2==0 else -12,0)
		s.apply_continuous(a,b,brush,.12)
		main.feedback._physics_process(.12)
	check(film_before > .8 and s.bone_film.value_at(uv) == 0.0,"four short back-and-forth passes clean a real local trace in .48 seconds")
	check(main.feedback.film_puffs >= 2,"short real cleaning strokes emit visible bounded puffs")
	check(s.fossil.condition == 100,"Brush preserves Condition")
	main.reset_specimen()
	P5Fixture.reveal(s,[100,100,100,100])
	for n in range(4): s.apply_continuous(tile_point,tile_point,brush,.12)
	check(s.bone_film.value_at(uv) > .5,"stationary hold is slower than deliberate back-and-forth movement")
	P5Fixture.clean(s)
	main.feedback.reset()
	s.apply_continuous(tile_point,tile_point,brush,.12)
	check(main.feedback.film_puffs == 0,"already clean Bone emits no false cleaning dust")
	# A genuinely faint edge trace finishes exactly, outside the footprint stays dirty.
	var film := BoneSurfaceFilm.new(Vector2i(16,16))
	film.expose(Vector2i(8,8),FossilField.Component.SKULL)
	var small: ToolDefinition = brush.duplicate()
	small.radius = 4.0
	var centre := Vector2(9.5,9.5)
	film.clean(centre,centre,small,.83)
	var residual := film.value_at(Vector2(8.5,8.5)/16.0)
	check(residual > .019 and residual < .021,"edge test starts with true low residual Film")
	film.finish_threshold = .025
	film.clean(centre+Vector2(5,0),centre+Vector2(5,0),small,1.0/60)
	check(is_equal_approx(film.value_at(Vector2(8.5,8.5)/16.0),residual),"finish assistance never removes dirt outside the actual Brush footprint")
	film.clean(centre+Vector2(3.8,0),centre+Vector2(3.8,0),small,1.0/60)
	check(film.value_at(Vector2(8.5,8.5)/16.0) == 0.0 and is_equal_approx(film.cleanliness_percent(),100.0),"a real faint edge stroke clears the exact Film and counters")
	check(is_equal_approx(film.last_cleared,residual),"edge finishing reports the actual removed Film for feedback")
	main.reset_specimen()
	P5Fixture.distributed(s,99.1)
	P5Fixture.clean(s)
	s.fossil.damage_at(s.fossil.field.index_at_map(point),18)
	main.session.flush()
	check(main.distinction.earned and main.session_ui.distinction_label.visible,"guarded displayed 100/100 awards the integral distinction")
	check(main.session.snapshot().condition < 100,"distinction does not require pristine Condition")
	check(main.session.archive(),"archive remains available after earning the distinction")
	check(main.session.archive_snapshot.get("integral_preparation",false) and main.session_ui.archive_distinction.visible,"archive shows and records the distinction")
	check(FileAccess.file_exists(QA_STORE) and main.distinction.save_error == OK,"distinction persists in isolated collection storage")
	var loaded := Distinction.new()
	loaded.setup(main.session,QA_STORE)
	check(loaded.has_collection_distinction(),"collection distinction survives a storage reload")
	main.reset_specimen()
	check(not main.distinction.earned and main.distinction.has_collection_distinction(),"new specimen resets current achievement while preserving the collection record")
	P5Fixture.distributed(s,90.0)
	P5Fixture.clean(s)
	main.session.flush()
	check(main.session.preparation_complete and not main.distinction.earned,"ordinary museum completion does not award 100/100 distinction")
	check(main.session.archive() and not main.session.archive_snapshot.integral_preparation,"an earlier archive is not mislabeled integral")
	check(main.distinction.has_collection_distinction(),"an earlier archive never erases an existing collection distinction")
	check(not Distinction.qualifies({"exposure":100.0,"cleanliness":100.0,"coverage_passed":false}),"coverage guard blocks the distinction even with full percentages")
	check(not Distinction.qualifies({"exposure":99.0,"cleanliness":98.99,"coverage_passed":true}),"both guarded bars must reach displayed 100")

func tactile_visual() -> void:
	check(DisplayServer.get_name() != "headless","visual evidence uses the real graphical renderer")
	main.select_fixture(3)
	main.feedback.proxies_enabled = false
	main.feedback.set_physics_process(false)
	await zoom_to(3,Vector2(270,235))
	main.camera.set_process(false)
	main.session_ui.notice_label.hide()
	var s: WorkingSurface = main.block.working_map
	await skull_picture("brush-dirty")
	for n in range(4):
		var a := Vector2(230 if n%2==0 else 285,225)
		var b := Vector2(285 if n%2==0 else 230,225)
		s.apply_continuous(a,b,main.controller.tools[0],.12)
		main.feedback._physics_process(.12)
		if n == 1: await skull_picture("brush-two-passes")
	await skull_picture("brush-four-passes")
	# Freeze only presentation time to compare the real emitted puffs on/off.
	main.feedback.set_process(false)
	main.feedback._process(.02)
	var dust_node: MultiMeshInstance3D = main.feedback.get_node("AirDust")
	check(dust_node.multimesh.visible_instance_count > 0,"real cleaning puffs reach the GPU instance pool")
	var dust_on := await skull_picture("brush-removal-dust")
	dust_node.hide()
	var dust_off := await skull_picture("brush-removal-dust-hidden")
	check(digest(dust_on.get_region(Rect2i(260,170,360,300)).get_data()) != digest(dust_off.get_region(Rect2i(260,170,360,300)).get_data()),"actual Brush removal dust changes visible pixels above the Bone")
	dust_node.show()
	main.feedback.reset()
	main.feedback.set_process(true)
	P5Fixture.clean(s)
	var undamaged := await skull_picture("bone-undamaged")
	var point := Vector2(240,220)
	var index := s.fossil.field.index_at_map(point)
	check(s.fossil.exposed[index] != 0,"visual damage target is real exposed Bone inside the native fixture")
	# Real contact authority, isolated from matrix fracture and transient rings.
	s.fossil.contact_at(index,main.controller.tools[1].bone_damage,true)
	s.fossil.contact_at(index,main.controller.tools[1].bone_damage,true)
	check(s.fossil.condition < 100 and main.local_damage.marks.size() == 1,"visual capture actually contains committed local damage")
	var local := await skull_picture("bone-local-impact")
	var pixel_scale := Vector2(root.size) / Vector2(root.content_scale_size)
	var target := Vector2i(at(point) * pixel_scale)
	var local_region := Rect2i(target-Vector2i(30,30),Vector2i(60,60))
	check(digest(undamaged.get_region(local_region).get_data()) != digest(local.get_region(local_region).get_data()),"local damage changes rendered Bone pixels at the contact")
	var remote := Vector2i(at(Vector2(309,258)) * pixel_scale)
	var remote_region := Rect2i(remote-Vector2i(12,12),Vector2i(24,24))
	check(digest(undamaged.get_region(remote_region).get_data()) == digest(local.get_region(remote_region).get_data()),"distant exposed jaw pixels are identical after local damage")
	for n in range(3): s.fossil.contact_at(index,main.controller.tools[1].bone_damage,true)
	await skull_picture("bone-repeated-local-impact")
	main.reset_specimen()
	P5Fixture.distributed(s,99.1)
	P5Fixture.clean(s)
	main.session.flush()
	await zoom_to(1)
	main.camera.set_process(false)
	await skull_picture("integral-distinction-live")
	main.session.archive()
	await create_timer(.35).timeout
	await skull_picture("integral-distinction-archive")

func run() -> void:
	out = "res://work/test-logs/p6a33/"
	DirAccess.make_dir_recursive_absolute(out)
	if FileAccess.file_exists(QA_STORE): DirAccess.remove_absolute(QA_STORE)
	root.size = Vector2i(1280,720)
	root.content_scale_size = root.size
	var args := OS.get_cmdline_user_args()
	mode = args[0] if not args.is_empty() else "tests"
	AudioServer.set_bus_mute(0,true)
	main = load("res://scenes/p6a33_tactile_preparation.tscn").instantiate()
	root.add_child(main)
	main.display.persist = false
	root.mode = Window.MODE_WINDOWED
	root.size = Vector2i(1280,720)
	main.controller.set_physics_process(false)
	main.panel.hide()
	await settle()
	if mode == "visual": await tactile_visual()
	else: await tactile_checks()
	evidence["runtime"] = {"engine":Engine.get_version_info().string,"adapter":RenderingServer.get_video_adapter_name(),"physics_hz":Engine.physics_ticks_per_second,"render_cap":Engine.max_fps}
	evidence["checks"] = checks
	evidence["failures"] = failures
	FileAccess.open(out+mode+".json",FileAccess.WRITE).store_string(JSON.stringify(evidence,"\t"))
	print("P6A3.3 ",mode,": ",checks," checks, ",failures.size()," failures")
	main.queue_free()
	await create_timer(.3).timeout
	quit(0 if failures.is_empty() else 1)

