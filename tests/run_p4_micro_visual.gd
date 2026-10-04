extends "res://tests/run_p4_closure_visual.gd"

func micro_visual(zoom: float) -> void:
	controller.reset_surface()
	camera.reset_view()
	expose_bone_fixture()
	var s := block.working_map
	s.bone_film.reset() # Isolate structural remnants from the separately tested film.
	for p in [Vector2i(250, 230), Vector2i(274, 230)]:
		var width := 2 if p.x == 250 else 10
		var depth := 0.0012 if p.x == 250 else 0.006
		for y in range(p.y, p.y + width):
			for x in range(p.x, p.x + width):
				var i := y * s.size.x + x
				s._heights[i] = s.fossil.field.ceilings[i] + depth / s.excavatable_depth
	s.image.set_data(s.size.x, s.size.y, false, Image.FORMAT_RF, s._heights.to_byte_array())
	s.dirty = true
	block.flush_texture()
	select(0)
	move_to((Vector2(262, 230) + Vector2.ONE * 0.5) / Vector2(block.map_resolution))
	await settle_zoom(zoom)
	hide_pointer()
	var before := await screenshot("p4-micro-remnants-%dx-before" % int(zoom))
	var thick := s._heights[234 * s.size.x + 278]
	s.apply_continuous(Vector2(250, 230), Vector2(250, 230), controller.tools[0], 1.0 / 60)
	block.flush_texture()
	main.feedback.loose_view._process(0)
	var after := await screenshot("p4-micro-remnants-%dx-detached" % int(zoom))
	check(s.last_micro_cells == 4 and s.loose_debris.persistent_count() == 1, "real Bone micro-cap becomes one visible crumb")
	check(s._heights[234 * s.size.x + 278] == thick and s.fossil.condition == 100, "adjacent real piece and Bone Condition unchanged")
	check(coverage(before, after) > 2, "micro-remnant conversion has a rendered before/after")
	s.apply_continuous(Vector2(250, 230), Vector2(250, 230), controller.tools[0], 0.1)
	block.flush_texture()
	main.feedback.loose_view._process(0)
	await screenshot("p4-micro-remnants-%dx-clean" % int(zoom))

func evacuation_visual(zoom: float) -> void:
	controller.reset_surface()
	camera.reset_view()
	var dirt := block.working_map.loose_debris
	for i in range(64): dirt.deposit_removed(400 + i % 16 * 24, 100 + (i / 16 as int) * 24, 16, 1 + i % 2)
	var n := 0
	for f in dirt.physics.fragments:
		if not f.active: continue
		f.position = local_at(Vector2(710 + (n % 8 - 3.5) * 5, 140 + (n / 8 as int - 3.5) * 5))
		f.velocity = Vector3.ZERO
		f.angular_velocity = 0
		n += 1
	for tick in range(120): dirt.advance(1.0 / 60)
	select(2)
	move_to((Vector2(710, 140) + Vector2.ONE * 0.5) / Vector2(block.map_resolution))
	await settle_zoom(zoom)
	hide_pointer()
	main.feedback.loose_view._process(0)
	await screenshot("p4-micro-eject-%dx-before" % int(zoom))
	for tick in range(12): block.working_map.apply_continuous(Vector2(709, 140), Vector2(710, 140), controller.tools[2], 1.0 / 60)
	check(dirt.persistent_count() == 0 and dirt.flying.size() == 64, "logical cap released while all 64 flight FX exist")
	dirt.advance(0.1)
	main.feedback.loose_view._process(0)
	var flying_image := await screenshot("p4-micro-eject-%dx-flight" % int(zoom))
	main.feedback.loose_view.hide()
	var background := await screenshot("p4-micro-eject-%dx-no-fx-reference" % int(zoom))
	main.feedback.loose_view.show()
	var pixels := coverage(flying_image, background)
	check(pixels > 100, "evacuation flight is clearly present in GPU pixels")
	dirt.advance(0.3)
	main.feedback.loose_view._process(0)
	await screenshot("p4-micro-eject-%dx-expired" % int(zoom))
	check(dirt.flying.is_empty() and dirt.evacuated_count == 64, "visual expires with exactly one evacuation per crumb")
	report["ejection_%dx" % int(zoom)] = {"before":64, "after":0, "flight_pixels":pixels}

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
		await micro_visual(zoom)
		await evacuation_visual(zoom)
		await film_visual(zoom)
	main.debug_panel.show()
	main.get_node("Debug/BonePanel").show()
	move_to((Vector2(250, 230) + Vector2.ONE * 0.5) / Vector2(block.map_resolution))
	controller._focused = true
	controller._pointer_inside = true
	controller.refresh_view()
	main._process(0.2)
	await screenshot("p4-micro-debug")
	check(main.debug_panel.get_global_rect().end.y < 960 and "Ejecting FX:" in main.debug_label.text, "Matrix/FX debug fits above toolbar")
	report["checks"] = bench_checks
	report["failures"] = failures
	FileAccess.open("res://work/test-logs/p4-micro-visual.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("P4 MICRO VISUAL: %d checks, %d failures" % [bench_checks, failures])
	main.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
