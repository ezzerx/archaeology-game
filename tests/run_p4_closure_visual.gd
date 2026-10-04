extends "res://tests/run_p4v2_look_visual.gd"
## Same real 1080p camera/renderer: Soil visibility and discovery preparation.

func expose_bone_fixture() -> void:
	var s := block.working_map
	var exposed := PackedInt32Array()
	for y in range(s.size.y):
		for x in range(s.size.x):
			var index := y * s.size.x + x
			var ceiling := s.fossil.field.ceilings[index]
			s._heights[index] = maxf(0.05, ceiling)
			if ceiling > 0: exposed.append(index)
	s.image.set_data(s.size.x, s.size.y, false, Image.FORMAT_RF, s._heights.to_byte_array())
	s.dirty = true
	s.fossil.expose_cells(exposed)
	block.flush_texture()

func hide_pointer() -> void:
	controller.hit = {"inside": false}
	block.show_cursor(controller.hit, 40)
	main.feedback.proxies_enabled = false
	main.feedback.bone_ring.hide()

func soil_visual(zoom: float) -> void:
	controller.reset_surface()
	camera.reset_view()
	select(0)
	move_to(Vector2(0.45, 0.20))
	await settle_zoom(zoom)
	var s := block.working_map
	for i in range(300):
		var previous := Vector2(110 + 800.0 * maxi(0, i - 1) / 299, 110 + 30 * sin(maxi(0, i - 1) / 45.0))
		var point := Vector2(110 + 800.0 * i / 299, 110 + 30 * sin(i / 45.0))
		s.apply_continuous(previous, point, controller.tools[0], 1.0 / 60)
		s.loose_debris.advance(1.0 / 60)
	block.flush_texture()
	main.feedback.reset()
	hide_pointer()
	main.feedback.loose_view._process(0)
	var label := "p4-final-soil-%dx" % int(zoom)
	var dusty := await screenshot(label + "-dust-only")
	var empty := Image.create(s.residue.image.get_width(), s.residue.image.get_height(), false, Image.FORMAT_R8)
	block.material.set_shader_parameter("residue_map", ImageTexture.create_from_image(empty))
	var bare := await screenshot(label + "-no-dust-reference")
	block.material.set_shader_parameter("residue_map", block.residue_texture)
	check(coverage(dusty, bare) > 100, "Soil Fine Dust retains measurable visible patches: " + label)
	check(s.loose_debris.layer_counts[0] == 0 and main.feedback.pools[0] == null, "no Soil instance or GPU pool: " + label)
	report[label] = {"dust_pixels": coverage(dusty, bare), "matrix_count": s.loose_debris.persistent_count()}

func film_visual(zoom: float) -> void:
	controller.reset_surface()
	camera.reset_view()
	expose_bone_fixture()
	select(0)
	move_to((Vector2(285, 230) + Vector2.ONE * 0.5) / Vector2(block.map_resolution))
	await settle_zoom(zoom)
	var s := block.working_map
	var geometry := s.image.get_data()
	# Real loose Dust in addition to the automatic adherent film.
	for y in range(125, 520, 4):
		for x in range(130, 915, 4): s.residue.deposit_removed(x, y, 8)
	s.residue.apply_segment(Vector2(130, 320), Vector2(915, 320), 220, 1, 0)
	block.flush_texture()
	main.feedback.reset()
	hide_pointer()
	var film_before := s.bone_film._bytes.duplicate()
	var label := "p4-final-bone-%dx" % int(zoom)
	await screenshot(label + "-dirty")
	for y in range(130, 521, 35):
		s.apply_continuous(Vector2(130, y), Vector2(915, y), controller.tools[2], 1)
	block.flush_texture()
	main.feedback.reset()
	check(s.bone_film._bytes == film_before, "Blower leaves film byte-exact: " + label)
	var blown := await screenshot(label + "-blown")
	var production_shader := block.material.shader
	var old_shader := Shader.new()
	old_shader.code = production_shader.code.replace("vec3(0.32, 0.25, 0.19)", "vec3(0.66, 0.56, 0.40)")
	block.material.shader = old_shader
	var old_tint := await screenshot(label + "-old-tint-reference")
	block.material.shader = production_shader
	var darker := 0
	var lighter := 0
	for y in range(100, 950):
		for x in range(160, 1760):
			var delta := blown.get_pixel(x, y).get_luminance() - old_tint.get_pixel(x, y).get_luminance()
			if delta < -0.025: darker += 1
			if delta > 0.025: lighter += 1
	check(darker > 200 and lighter == 0, "new earth-brown film is darker in paired GPU render: " + label)

	# Progressive 0.4s pass centred on Skull, independent of its exposure.
	s.apply_continuous(Vector2(235, 230), Vector2(285, 230), controller.tools[0], 0.4)
	block.flush_texture()
	var brushed := await screenshot(label + "-brushed")
	for y in range(125, 521, 20):
		s.apply_continuous(Vector2(130, y), Vector2(915, y), controller.tools[0], 1.5)
	block.flush_texture()
	var clean := await screenshot(label + "-clean")
	check(coverage(blown, clean) > 200 and coverage(brushed, blown) > 20, "GPU film supports visible progressive and complete cleaning: " + label)
	check(s.image.get_data() == geometry and s.fossil.condition == 100, "film sequence changes no structural byte or Bone Condition: " + label)
	report[label] = {"darker_pixels_vs_old": darker, "dirty_clean_pixels": coverage(blown, clean), "partial_clean_pixels": coverage(brushed, blown), "film_bytes": s.bone_film.image.get_data_size(), "exposed": s.fossil.exposed_cells}

func run() -> void:
	if DisplayServer.get_name() == "headless": quit(1); return
	root.size = Vector2i(1920, 1080)
	root.content_scale_size = root.size
	AudioServer.set_bus_mute(0, true)
	main = load("res://scenes/prototype_main.tscn").instantiate()
	root.add_child(main)
	block = main.block
	controller = main.controller
	camera = main.camera
	controller.set_physics_process(false)
	main.feedback.set_process(false)
	main.feedback.loose_view.set_process(false)
	for node in ["Debug/Panel", "Debug/BonePanel", "Debug/BoneNotice"]: main.get_node(node).hide()
	for zoom in [1.0, 3.0]:
		await soil_visual(zoom)
		await film_visual(zoom)
	main.debug_panel.show()
	main.get_node("Debug/BonePanel").show()
	move_to((Vector2(250, 230) + Vector2.ONE * 0.5) / Vector2(block.map_resolution))
	controller._focused = true
	controller._pointer_inside = true
	controller.refresh_view()
	main._process(0.2)
	await screenshot("p4-final-debug")
	check(main.debug_panel.get_global_rect().end.y < 960 and not "Soil grains:" in main.debug_label.text and "Matrix crumbs:" in main.debug_label.text and "Bone Film" in main.debug_label.text, "Matrix-only F1 counters/film fit above toolbar")
	report["checks"] = bench_checks
	report["failures"] = failures
	FileAccess.open("res://work/test-logs/p4-closure-visual.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("P4 CLOSURE VISUAL: %d checks, %d failures\n%s" % [bench_checks, failures, JSON.stringify(report)])
	main.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
