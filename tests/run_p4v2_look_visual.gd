extends "res://tests/run_p4v2_benchmark.gd"
## Actual fractures, paired frozen GPU readbacks. Only the comparison render is
## shrunk to rejected 2.2 mm; production quantities/positions never change.

func coverage(a: Image, background: Image) -> int:
	var pixels := 0
	for y in range(100, 950):
		for x in range(160, 1760):
			var delta := a.get_pixel(x, y) - background.get_pixel(x, y)
			if maxf(absf(delta.r), maxf(absf(delta.g), absf(delta.b))) > 0.025: pixels += 1
	return pixels

func look_case(kind: String, zoom: float, enabled: bool) -> Dictionary:
	controller.reset_surface()
	camera.reset_view()
	main.feedback.crumb_physics_enabled = enabled
	prepare_fixture(kind)
	select(1)
	var center := Vector2(710, 140)
	move_to((center + Vector2.ONE * 0.5) / Vector2(block.map_resolution))
	await settle_zoom(zoom)
	for offset in [-32, 0, 32]:
		for hit in range(4): block.working_map.apply_impact(center + Vector2(offset, 0), controller.tools[1])
	block.flush_texture()
	controller.hit = {"inside": false}
	block.show_cursor(controller.hit, 40)
	step_visual(180)
	var dirt := block.working_map.loose_debris
	var view: LooseDebrisView = main.feedback.loose_view
	var amounts := dirt.cells.duplicate()
	var geometry := block.working_map.image.get_data()
	var label := "p4v2-look-%s-%dx-%s" % [kind, int(zoom), "on" if enabled else "off"]
	var restored := await screenshot(label + "-restored")
	var poses: Array[Transform3D] = []
	for i in range(view.multimesh.visible_instance_count):
		var pose: Transform3D = view.multimesh.get_instance_transform(i)
		poses.append(pose)
		view.multimesh.set_instance_transform(i, Transform3D(pose.basis.scaled_local(Vector3.ONE * (2.2 / 4.5)), pose.origin))
	var micro := await screenshot(label + "-micro-reference")
	view.hide()
	var background := await screenshot(label + "-background")
	for i in range(poses.size()): view.multimesh.set_instance_transform(i, poses[i])
	view.show()
	var restored_pixels := coverage(restored, background)
	var micro_pixels := coverage(micro, background)
	var amount := 0.0
	for value in dirt.cells.values(): amount += value
	check(restored_pixels > 8 and restored_pixels > micro_pixels * 1.7, "restored crumb presence exceeds micro reference: " + label)
	check(dirt.cells == amounts and block.working_map.image.get_data() == geometry, "paired scale captures preserve real quantity and structure: " + label)
	check(main.feedback.particles[1].is_empty() and main.feedback.particles[2].is_empty(), "presence comes only from persistent crumbs: " + label)
	if enabled: check(dirt.physics.sleeping_count == dirt.physics.active_count and dirt.physics.active_count > 0, "visible crumbs have settled: " + label)
	var data := {"crumbs": dirt.cells.size(), "amount": amount, "restored_pixels": restored_pixels,
		"micro_pixels": micro_pixels, "coverage_ratio": float(restored_pixels) / maxf(micro_pixels, 1)}
	report[label] = data
	print("P4V2 LOOK ", label, " ", JSON.stringify(data))
	return data

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
		for kind in ["clay", "stone"]:
			var off := await look_case(kind, zoom, false)
			var on := await look_case(kind, zoom, true)
			check(off.crumbs == on.crumbs and is_equal_approx(off.amount, on.amount), "physics does not reduce real fracture count/quantity: %s %dx" % [kind, int(zoom)])
	report["checks"] = bench_checks
	report["failures"] = failures
	FileAccess.open("res://work/test-logs/p4v2-look-visual.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("P4V2 LOOK VISUAL: %d checks, %d failures" % [bench_checks, failures])
	main.queue_free()
	await create_timer(0.4).timeout
	quit(0 if failures == 0 else 1)
