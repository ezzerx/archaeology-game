extends "res://tests/run_p4_benchmark.gd"
## Real renderer: substantial transient fracture, bounded mess and visible flight.
## Simulation is stepped explicitly for repeatable screenshots, never for timings.

var visual_checks := 0

func check(condition: bool, message: String) -> void:
	visual_checks += 1
	super.check(condition, message)

func changed_pixels(a: Image, b: Image) -> int:
	var count := 0
	for y in range(100, 950, 2):
		for x in range(160, 1760, 2):
			var ca := a.get_pixel(x, y)
			var cb := b.get_pixel(x, y)
			if maxf(absf(ca.r - cb.r), maxf(absf(ca.g - cb.g), absf(ca.b - cb.b))) > 0.025: count += 1
	return count

func step(seconds: float) -> void:
	var ticks := ceili(seconds * 60)
	for i in range(ticks):
		block.working_map.loose_debris.advance(seconds / ticks)
		main.feedback._process(seconds / ticks)
		main.feedback.loose_view._process(0)

func composition_capture(kind: String, zoom: int) -> void:
	controller.reset_surface()
	camera.reset_view()
	prepare_fixture(kind)
	select(1)
	var p := Vector2(710, 140)
	move_to((p + Vector2.ONE * 0.5) / Vector2(block.map_resolution))
	camera._focused = true
	if zoom == 3: camera.request_zoom(30, controller._screen)
	for i in range(90): await physics_frame
	controller.refresh_view()
	var fx: MaterialFeedback = main.feedback
	var family := 1 if kind == "clay" else 2
	for i in range(4):
		step(1.0 / 4.5)
		block.working_map.apply_impact(p, controller.tools[1])
		if fx.emitted[family] >= 8: break
	block.flush_texture()
	controller.refresh_view()
	fx._process(0)
	fx.loose_view._process(0)
	var label := "p4-feel-%s-%dx" % [kind, zoom]
	await screenshot(label + "-break")
	step(0.08)
	var with_chunks := await screenshot(label + "-flight")
	var node := fx.get_node("ClayChips" if family == 1 else "StoneFragments") as Node3D
	node.hide()
	var without_chunks := await screenshot(label + "-without-fx")
	node.show()
	var pixels := changed_pixels(with_chunks, without_chunks)
	check(pixels > 6, "transient chunks contribute visible rendered pixels: " + label)
	var emitted_count := fx.emitted[family]
	check(emitted_count > 3, "short ordinary Chisel burst restores multiple transient pieces: " + label)
	var geometry := block.working_map.image.get_data()
	var dust := block.working_map.residue.image.get_data()
	var dirt := block.working_map.loose_debris.cells.duplicate()
	step(0.75)
	check(fx.particles[family].is_empty() and block.working_map.loose_debris.cells == dirt
		and block.working_map.residue.image.get_data() == dust and block.working_map.image.get_data() == geometry,
		"spectacle expires without adding persistent dirt or changing structure: " + label)
	await screenshot(label + "-settled")
	report["break_%s_%dx" % [kind, zoom]] = {"particles": emitted_count, "fx_pixel_samples": pixels, "persistent_crumbs": dirt.size()}

func blower_capture(zoom: int) -> void:
	controller.reset_surface()
	camera.reset_view()
	prepare_fixture("blower")
	select(2)
	var p := Vector2(745, 140)
	move_to((p + Vector2.ONE * 0.5) / Vector2(block.map_resolution))
	camera._focused = true
	if zoom == 3: camera.request_zoom(30, controller._screen)
	for i in range(90): await physics_frame
	controller.refresh_view()
	var fx: MaterialFeedback = main.feedback
	var state := block.working_map.loose_debris
	fx._process(0)
	fx.loose_view._process(0)
	var widths_ok := true
	var max_width := 0.0
	for i in range(fx.loose_view.keys.size()):
		var basis := fx.loose_view.multimesh.get_instance_transform(i).basis
		max_width = maxf(max_width, basis.x.length())
		widths_ok = widths_ok and basis.x.length() <= 0.004501 and basis.y.length() <= 0.001441
	check(widths_ok and max_width > 0.003, "P4-V1 persistent crumb presence restored, bounded to 4.5 mm")
	check(state.cells.size() <= state.occupancy.size() * 2, "larger visible mess retains the recent local occupancy bound")
	var geometry := block.working_map.image.get_data()
	var condition := block.working_map.fossil.condition
	var label := "p4-feel-blower-%dx" % zoom
	await screenshot(label + "-before")
	var exits: Array = []
	var capture_exit := func(at, direction, amount, layer): exits.append([at, direction, amount, layer])
	state.ejected.connect(capture_exit)
	block.working_map.apply_continuous(p - Vector2.RIGHT * 6, p, controller.tools[2], 0.1)
	block.flush_texture()
	var initial := state.flying.duplicate(true)
	check(initial.size() >= 8 and not fx.particles[3].is_empty(), "real cleanup launches multiple crumbs AND source dust")
	step(0.1)
	var all_moving := state.flying.size() == initial.size()
	for i in range(state.flying.size()):
		all_moving = all_moving and state.flying[i].point.x > initial[i].point.x + 14.9
		all_moving = all_moving and is_equal_approx(state.flying[i].point.y, initial[i].point.y)
		var rendered := fx.loose_view.multimesh.get_instance_transform(fx.loose_view.keys.size() + i)
		var uv: Vector2 = (state.flying[i].point + Vector2.ONE * 0.5) / Vector2(block.map_resolution)
		all_moving = all_moving and block.to_local(rendered.origin).y > block.relief.height_at(uv) + 0.004
	check(all_moving, "rendered crumbs lift and move 150 texels/s in the jet direction")
	var airborne := await screenshot(label + "-airborne")
	fx.loose_view.hide()
	var without_crumbs := await screenshot(label + "-without-crumbs")
	fx.loose_view.show()
	var pixels := changed_pixels(airborne, without_crumbs)
	check(pixels > 12, "crumbs make a measurable rendered contribution alongside lifted dust")
	step(0.4)
	await screenshot(label + "-travel")
	# Finish the real local sweep, then track the same packets through the edge.
	for i in range(120):
		block.working_map.apply_continuous(p - Vector2.RIGHT * 6, p, controller.tools[2], 1.0 / 60.0)
		step(1.0 / 60.0)
	block.flush_texture()
	await screenshot(label + "-edge")
	step(8)
	fx.loose_view._process(0)
	var coherent := not exits.is_empty()
	for event in exits:
		coherent = coherent and absf(event[0].x - 1023.5) < 0.001 and event[1] == Vector2.RIGHT and event[2] > 0 and event[3] == 2
	check(coherent and state.flying.is_empty(), "crumbs exit at the block edge with coherent amount/material, not a lifetime fade")
	check(block.working_map.image.get_data() == geometry and block.working_map.fossil.condition == condition,
		"visible cleanup changes no height byte or Bone Condition")
	await screenshot(label + "-clean")
	report["blower_%dx" % zoom] = {"initial_airborne": initial.size(), "ejections": exits.size(), "crumb_pixel_samples": pixels, "max_crumb_width_m": max_width}
	state.ejected.disconnect(capture_exit)
	controller.reset_surface()
	state.deposit_removed(700, 140, 1000, 0)
	fx.loose_view._process(0)
	await RenderingServer.frame_post_draw
	var soil := fx.loose_view.multimesh.get_instance_transform(0).basis
	var soil_point := state.point_for(Vector3i(87, 17, 0))
	# Closure explicitly increases only Soil; the six-sided flat mesh stays intact.
	var width := state.visual_width(soil_point, 0.02, 0)
	var expected := Basis(Vector3.UP, soil_point.x * 1.7 + soil_point.y * 2.3).scaled(Vector3(width, width * 0.14, width * 0.75))
	check(soil.is_equal_approx(expected) and width >= 0.0018 and width <= 0.0025, "closure Soil granules are 1.8–2.5 mm, flat, varied; Matrix remains 4.5 mm")

func run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Final Feel visual proof requires the real renderer")
		quit(1)
		return
	root.size = Vector2i(1920, 1080)
	root.content_scale_size = root.size
	AudioServer.set_bus_mute(0, true)
	main = load("res://scenes/prototype_main.tscn").instantiate()
	root.add_child(main)
	main.feedback.crumb_physics_enabled = false # Exact validated spectacle A/B reference.
	block = main.block
	controller = main.controller
	camera = main.camera
	controller.set_physics_process(false)
	main.feedback.set_process(false)
	main.feedback.loose_view.set_process(false)
	main.get_node("Debug/Panel").hide()
	main.get_node("Debug/BonePanel").hide()
	for zoom in [1, 3]:
		for kind in ["clay", "stone"]: await composition_capture(kind, zoom)
		await blower_capture(zoom)
	report["checks"] = visual_checks
	report["failures"] = failures
	FileAccess.open("res://work/test-logs/p4-final-feel-visual.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("P4 FINAL FEEL VISUAL: ", JSON.stringify(report))
	main.queue_free()
	await create_timer(0.4).timeout
	quit(0 if failures == 0 else 1)
