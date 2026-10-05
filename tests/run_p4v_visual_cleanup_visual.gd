extends "res://tests/run_p4_final_feel_visual.gd"
## Paired same-state readbacks: frozen V1.1 shader, clean interfaces, face contrast.

const BEFORE = preload("res://tests/fixtures/p4v11_surface.gdshader")

func screenshot(name: String) -> Image:
	# A mesh/shader swap can occur during frame_post_draw. Let the next complete
	# frames upload it before readback; the simulation is explicitly frozen.
	await process_frame
	await process_frame
	return await super.screenshot(name)

func color_distance(a: Color, b: Color) -> float:
	return maxf(absf(a.r - b.r), maxf(absf(a.g - b.g), absf(a.b - b.b)))

func settle_zoom(zoom: float) -> void:
	for attempt in range(3):
		camera._focused = true
		camera.request_zoom(log(zoom / camera.target_zoom) / log(camera.wheel_step), controller._screen)
		for i in range(90): await physics_frame
		if absf(camera.zoom_factor - zoom) < 0.001: break

func interface_case(layer: int, offset: float, zoom: float) -> void:
	controller.reset_surface()
	camera.reset_view()
	for i in range(block.working_map._heights.size()):
		block.working_map._heights[i] = block.working_map.strata.packed_limits[i * 2 + layer] + offset
	block.working_map.image.set_data(1024, 640, false, Image.FORMAT_RF, block.working_map._heights.to_byte_array())
	# P5's two independent fragments can stand above this synthetic whole-map
	# cut. Commit their exposure, then include their Bone pixels in the oracle.
	block.working_map.update_fragments(Rect2i(Vector2i.ZERO, block.map_resolution))
	block.working_map.dirty = true
	block.flush_texture()
	main.feedback.reset()
	main.feedback.hide()
	move_to(Vector2(0.5, 0.5))
	if zoom > 1: await settle_zoom(zoom)
	check(absf(camera.zoom_factor - zoom) < 0.001, "interface capture reaches requested zoom")
	controller.hit = {"inside": false}
	block.show_cursor({"inside": false}, 3)
	var label := "p4v12-%s-%s-%dx" % ["clay-floor" if layer == 1 else "soil-floor", str(offset), zoom]
	var current := block.material.shader
	var geometry := block.working_map.image.get_data()
	block.material.shader = BEFORE
	block.set_debug_view(0)
	await screenshot(label + "-before-shaded")
	block.set_debug_view(2)
	var before := await screenshot(label + "-before-material")
	block.material.shader = current
	block.set_debug_view(0)
	await screenshot(label + "-after-shaded")
	block.set_debug_view(2)
	var after := await screenshot(label + "-after-material")
	var samples := 0
	var before_wrong := 0
	var after_wrong := 0
	var cursor_wrong := 0
	var max_color_error := 0.0
	var expected: MaterialDefinition = block.material_definitions[layer if offset > 0 else layer + 1]
	for y in range(220, 870, 4):
		for x in range(330, 1590, 4):
			var hit := block.pick(Vector2(x + 0.5, y + 0.5), camera)
			if not hit.inside: continue
			samples += 1
			var expected_color: Color = block.material.get_shader_parameter("bone_color") if hit.bone_exposed else expected.debug_color
			if color_distance(before.get_pixel(x, y), expected_color) > 0.02: before_wrong += 1
			var error := color_distance(after.get_pixel(x, y), expected_color)
			max_color_error = maxf(max_color_error, error)
			if error > 0.02: after_wrong += 1
			if hit.material != expected: cursor_wrong += 1
	check(samples > 50000 and after_wrong == 0 and cursor_wrong == 0, "all floor/film pixels and cursor classifications agree: " + label)
	check(before_wrong > 1000 if offset == 0 else before_wrong == 0, "frozen reference reproduces aliasing only at the interface")
	check(block.working_map.image.get_data() == geometry, "interface cleanup cannot change the excavated RF")
	report[label] = {"pixels": samples, "before_wrong": before_wrong, "after_wrong": after_wrong,
		"cursor_wrong": cursor_wrong, "max_color_error": max_color_error}

func no_face_colors(source: Mesh) -> ArrayMesh:
	var arrays := source.surface_get_arrays(0)
	arrays[Mesh.ARRAY_COLOR] = null
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh

func contrast_measure(before: Image, after: Image, background: Image) -> Dictionary:
	var old_sum := 0.0
	var new_sum := 0.0
	var pixels := 0
	for y in range(100, 950):
		for x in range(160, 1760):
			var base := background.get_pixel(x, y)
			var old_delta := color_distance(before.get_pixel(x, y), base)
			var new_delta := color_distance(after.get_pixel(x, y), base)
			if maxf(old_delta, new_delta) > 0.025:
				pixels += 1
				old_sum += old_delta
				new_sum += new_delta
	return {"pixels": pixels, "before_contrast": old_sum, "after_contrast": new_sum,
		"ratio": new_sum / maxf(old_sum, 0.000001)}

func chunk_capture(kind: String, zoom: float) -> void:
	controller.reset_surface()
	camera.reset_view()
	block.set_debug_view(0)
	prepare_fixture(kind)
	var p := Vector2(710, 140)
	move_to((p + Vector2.ONE * 0.5) / Vector2(block.map_resolution))
	if zoom > 1: await settle_zoom(zoom)
	controller.hit = {"inside": false}
	block.show_cursor({"inside": false}, 3)
	var fx: MaterialFeedback = main.feedback
	for i in range(4):
		step(1.0 / 4.5)
		block.working_map.apply_impact(p, controller.tools[1])
	block.flush_texture()
	step(0.08)
	for proxy in fx.proxies: proxy.hide()
	fx.bone_ring.hide()
	var family := 1 if kind == "clay" else 2
	for detached in [false, true]:
		var node: MultiMeshInstance3D = fx.loose_view if detached else fx.get_node("ClayChips" if family == 1 else "StoneFragments")
		var current := node.multimesh.mesh
		var state := fx.particles[family].duplicate(true)
		var label := "p4v12-%s-%s-%dx" % [kind, "crumbs" if detached else "chunks", zoom]
		node.show()
		var after := await screenshot(label + "-after")
		node.multimesh.mesh = no_face_colors(current)
		var before := await screenshot(label + "-before")
		node.hide()
		var background := await screenshot(label + "-background")
		node.multimesh.mesh = current
		node.show()
		var contrast := contrast_measure(before, after, background)
		check(contrast.pixels > 8 and contrast.ratio > 1.03, "detached face separation improves measured contrast: " + label)
		check(fx.particles[family] == state, "paired captures keep particle positions, quantities and lifetimes exact")
		report[label] = contrast
		print("P4V12 CONTRAST: ", label, " ", JSON.stringify(contrast))

func wall_capture() -> void:
	controller.reset_surface()
	camera.reset_view()
	block.set_debug_view(0)
	prepare_fixture("stone")
	var p := Vector2(710, 140)
	for i in range(12): block.working_map.apply_impact(p + Vector2(i % 3 * 10 - 10, i / 3 as int * 8 - 12), controller.tools[1])
	block.flush_texture()
	main.feedback.hide()
	move_to((p + Vector2.ONE * 0.5) / Vector2(block.map_resolution))
	await settle_zoom(3.0)
	controller.hit = {"inside": false}
	block.show_cursor({"inside": false}, 3)
	var current := block.material.shader
	block.material.shader = BEFORE
	var before := await screenshot("p4v12-walls-before")
	block.material.shader = current
	var after := await screenshot("p4v12-walls-after")
	var wall_samples := 0
	var ratio_sum := 0.0
	var top_samples := 0
	var top_error := 0.0
	for y in range(220, 870, 3):
		for x in range(330, 1590, 3):
			var hit := block.pick(Vector2(x + 0.5, y + 0.5), camera)
			if not hit.inside or hit.bone_exposed or hit.material.id != &"sandstone": continue
			var old := before.get_pixel(x, y)
			var value := after.get_pixel(x, y)
			if absf(hit.local_normal.y) < 0.5 and old.r > 0.1:
				wall_samples += 1
				ratio_sum += value.r / old.r
			elif absf(hit.local_normal.y) > 0.999:
				top_samples += 1
				top_error = maxf(top_error, color_distance(value, old))
	check(wall_samples > 100 and ratio_sum / wall_samples < 0.95, "hard cavity walls gain local face separation")
	check(top_samples > 1000 and top_error < 0.02, "hard flat tops retain their existing palette")
	report["walls"] = {"wall_samples": wall_samples, "mean_wall_ratio": ratio_sum / maxi(wall_samples, 1),
		"top_samples": top_samples, "max_top_difference": top_error}

func run() -> void:
	if DisplayServer.get_name() == "headless": quit(1); return
	root.size = Vector2i(1920, 1080)
	root.content_scale_size = root.size
	AudioServer.set_bus_mute(0, true)
	main = load("res://scenes/prototype_main.tscn").instantiate()
	root.add_child(main)
	main.feedback.crumb_physics_enabled = false # Static P4-V1 contrast oracle.
	block = main.block
	controller = main.controller
	camera = main.camera
	controller.set_physics_process(false)
	main.feedback.set_process(false)
	main.feedback.loose_view.set_process(false)
	for node in ["Debug/Panel", "Debug/BonePanel", "Debug/BoneNotice"]: main.get_node(node).hide()
	for layer in [0, 1]:
		for zoom in [1.0, 3.0]: await interface_case(layer, 0.0, zoom)
	await interface_case(1, 0.0005, 3.0)
	for kind in ["clay", "stone"]:
		for zoom in [1.0, 3.0]: await chunk_capture(kind, zoom)
	await wall_capture()
	report["checks"] = visual_checks
	report["failures"] = failures
	FileAccess.open("res://work/test-logs/p4v12-visual.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("P4V12 VISUAL: %d checks, %d failures" % [visual_checks, failures])
	main.free()
	await process_frame
	quit(0 if failures == 0 else 1)
