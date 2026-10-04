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
	var visible_count := s.loose_debris.layer_counts[0]
	var label := "p4-closure-soil-%dx" % int(zoom)
	var visible_grains := await screenshot(label + "-grains-dust")
	# Hide Soil instances only, keeping all Matrix/Dust/terrain identical.
	var view: LooseDebrisView = main.feedback.loose_view
	var poses := {}
	for key: Vector3i in view.slots:
		if key.z == 0:
			var slot: int = view.slots[key]
			poses[slot] = view.multimesh.get_instance_transform(slot)
			view.multimesh.set_instance_transform(slot, Transform3D(Basis.IDENTITY.scaled(Vector3.ONE * 0.000001), poses[slot].origin))
	var dust_only := await screenshot(label + "-dust-only-reference")
	for slot in poses: view.multimesh.set_instance_transform(slot, poses[slot])
	var pixels := coverage(visible_grains, dust_only)
	check(pixels >= 30, "Soil grains have separate measurable pixel presence: " + label)
	check(visible_count == 128, "actual five-second Brush fixture fills Soil cap: " + label)
	report[label] = {"visible": visible_count, "grain_pixels": pixels, "created_per_s": s.loose_debris.created_counts[0] / 5.0, "cap_refused_attempts": s.loose_debris.cap_refusals[0]}
	for key: Vector3i in s.loose_debris.cells.keys():
		if key.z != 0 or not s.loose_debris.cells.has(key): continue
		var point := s.loose_debris.point_for(key)
		s.apply_continuous(point - Vector2.RIGHT, point, controller.tools[2], 0.1)
	step_visual(8)
	block.flush_texture()
	await screenshot(label + "-blowing")
	step_visual(420)
	await screenshot(label + "-blown")
	check(s.loose_debris.count_for(0) == 0, "Soil is visibly ejected by Blower: " + label)

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
	var label := "p4-closure-bone-%dx" % int(zoom)
	await screenshot(label + "-dirty")
	for y in range(130, 521, 35):
		s.apply_continuous(Vector2(130, y), Vector2(915, y), controller.tools[2], 1)
	block.flush_texture()
	main.feedback.reset()
	check(s.bone_film._bytes == film_before, "Blower leaves film byte-exact: " + label)
	var blown := await screenshot(label + "-blown")
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
	report[label] = {"dirty_clean_pixels": coverage(blown, clean), "partial_clean_pixels": coverage(brushed, blown), "film_bytes": s.bone_film.image.get_data_size(), "exposed": s.fossil.exposed_cells}

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
	await screenshot("p4-closure-debug")
	check(main.debug_panel.get_global_rect().end.y < 960 and "Soil grains:" in main.debug_label.text and "Matrix crumbs:" in main.debug_label.text and "Bone Film" in main.debug_label.text, "separate F1 budgets/film fit above toolbar")
	report["checks"] = bench_checks
	report["failures"] = failures
	FileAccess.open("res://work/test-logs/p4-closure-visual.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("P4 CLOSURE VISUAL: %d checks, %d failures\n%s" % [bench_checks, failures, JSON.stringify(report)])
	main.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
