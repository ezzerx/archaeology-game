extends "res://tests/run_p4_benchmark.gd"
## Real shader/readback evidence. Pixel differences prove that accumulation is
## rendered at both zoom levels, not that the subjective game feel is approved.

const CENTER := Vector2(710, 140)
var visual_checks := 0

func check(condition: bool, message: String) -> void:
	visual_checks += 1
	super.check(condition, message)

func deposit(amount: float) -> void:
	for y in range(95, 185):
		for x in range(650, 790):
			var offset := Vector2((x - CENTER.x) / 70.0, (y - CENTER.y) / 45.0)
			if offset.length() < 0.85 + 0.12 * sin(offset.angle() * 5.0):
				block.working_map.residue.deposit_removed(x, y, amount)
	block.working_map.residue.apply_segment(CENTER, CENTER, 120, 1, 0)
	block.flush_texture()

func difference(a: Image, b: Image) -> Dictionary:
	var changed := 0
	var total := 0
	var sum := 0.0
	for y in range(115, 171, 2):
		for x in range(675, 746, 2):
			var uv := (Vector2(x, y) + Vector2.ONE * 0.5) / Vector2(block.map_resolution)
			var world := block.to_global(Vector3((uv.x - 0.5) * block.surface_size.x,
				block.relief.height_at(uv), (uv.y - 0.5) * block.surface_size.y))
			var screen := Vector2i(camera.unproject_position(world).round())
			var ca := a.get_pixelv(screen)
			var cb := b.get_pixelv(screen)
			var delta := maxf(absf(ca.r - cb.r), maxf(absf(ca.g - cb.g), absf(ca.b - cb.b)))
			if delta > 0.025: changed += 1
			sum += delta
			total += 1
	return {"samples": total, "changed_fraction": float(changed) / total, "mean_rgb_delta": sum / total}

func dust_captures(zoom: int) -> void:
	controller.reset_surface()
	camera.reset_view()
	prepare_fixture("clay")
	move_to((CENTER + Vector2.ONE * 0.5) / Vector2(block.map_resolution))
	camera._focused = true
	if zoom == 3: camera.request_zoom(30, controller._screen)
	for i in range(90): await physics_frame
	check(absf(camera.zoom_factor - zoom) < 0.001, "visual fixture uses requested zoom")
	controller.hit = {"inside": false}
	block.show_cursor({"inside": false}, 60)
	main.feedback._process(0)
	await process_frame
	var geometry := block.working_map.image.get_data()
	var empty := await screenshot("p4-final-dust-empty-%dx" % zoom)
	deposit(0.08)
	var low := await screenshot("p4-final-dust-low-%dx" % zoom)
	deposit(0.52)
	var high := await screenshot("p4-final-dust-before-%dx" % zoom)
	var low_diff := difference(empty, low)
	var high_diff := difference(empty, high)
	check(low_diff.changed_fraction > 0.10, "light accumulation is rendered at %dx" % zoom)
	check(high_diff.changed_fraction > 0.65 and high_diff.mean_rgb_delta > low_diff.mean_rgb_delta * 1.5,
		"heavier accumulation visibly increases patch coverage/intensity at %dx" % zoom)
	await create_timer(2).timeout
	var persistent := await screenshot("p4-final-dust-persistent-%dx" % zoom)
	check(difference(high, persistent).mean_rgb_delta < 0.001, "dust stays visible after all transient lifetimes")
	select(2)
	controller.refresh_view()
	var condition := block.working_map.fossil.condition
	block.working_map.apply_continuous(CENTER - Vector2.RIGHT * 6, CENTER, controller.tools[2], 0.15)
	block.flush_texture()
	await create_timer(0.08).timeout
	await screenshot("p4-final-dust-lift-%dx" % zoom)
	await create_timer(0.25).timeout
	await screenshot("p4-final-dust-drift-%dx" % zoom)
	for i in range(90):
		await physics_frame
		block.working_map.apply_continuous(CENTER - Vector2.RIGHT * 6, CENTER, controller.tools[2], 1.0 / 60.0)
		block.flush_texture()
	await create_timer(1).timeout
	controller.hit = {"inside": false}
	block.show_cursor({"inside": false}, 60)
	main.feedback._process(0)
	await process_frame
	var clean := await screenshot("p4-final-dust-clean-%dx" % zoom)
	var clean_diff := difference(empty, clean)
	check(clean_diff.mean_rgb_delta < high_diff.mean_rgb_delta * 0.1, "Blower leaves a visibly clean swept region")
	check(geometry == block.working_map.image.get_data() and condition == block.working_map.fossil.condition,
		"rendered before/after has exact structural and Bone Condition invariance")
	report["dust_%dx" % zoom] = {"low": low_diff, "high": high_diff, "clean": clean_diff}

func contact_captures() -> void:
	for kind in ["slope", "deep", "bone", "fracture"]:
		controller.reset_surface()
		camera.reset_view()
		var p := Vector2(286, 194) if kind == "bone" else Vector2(700, 140)
		block.working_map.apply_segment(p, p, 25 if kind == "deep" else 65, 100 if kind in ["deep", "bone"] else 1.15, 1.5, 1)
		if kind == "fracture":
			for i in range(15): block.working_map.apply_impact(p + Vector2(i % 3 * 8, i / 3 as int * 4), controller.tools[1])
		block.flush_texture()
		main.feedback.reset()
		move_to((p + Vector2.ONE * 0.5) / Vector2(block.map_resolution))
		camera._focused = true
		camera.request_zoom(30, controller._screen)
		for i in range(90): await physics_frame
		for tool in range(4):
			select(tool)
			controller.refresh_view()
			await screenshot("p4-final-%s-proxy-%d" % [kind, tool])
		if kind == "deep":
			move_to((p + Vector2(24.5, 0.5)) / Vector2(block.map_resolution))
			select(1)
			controller.refresh_view()
			await screenshot("p4-final-deep-edge-proxy-1")

func run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Feedback visual test requires the graphical renderer")
		quit(1)
		return
	root.size = Vector2i(1920, 1080)
	root.content_scale_size = root.size
	AudioServer.set_bus_mute(0, true)
	main = load("res://scenes/prototype_main.tscn").instantiate()
	root.add_child(main)
	block = main.block
	controller = main.controller
	camera = main.camera
	controller.set_physics_process(false)
	main.get_node("Debug/Panel").hide()
	main.get_node("Debug/BonePanel").hide()
	for zoom in [1, 3]: await dust_captures(zoom)
	await contact_captures()
	await debris_session_captures()
	report["failures"] = failures
	report["checks"] = visual_checks
	FileAccess.open("res://work/test-logs/p4-feedback-visual.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("P4 FEEDBACK VISUAL: %d checks, %d failures" % [visual_checks, failures])
	main.queue_free()
	await create_timer(0.4).timeout
	quit(0 if failures == 0 else 1)
