extends SceneTree
## Headless invariants, graphical evidence/mask oracle, and native GPU/CPU timings.
var main: Node3D
var checks := 0
var failures: Array[String] = []
var evidence := {"profiles": [], "brush": [], "captures": [], "benchmark": []}
var out := "res://work/test-logs/p6a15/"
var frames: Array[float] = []
var gpu: Array[float] = []
var render_cpu: Array[float] = []
var measuring := false
var previous := 0

func _initialize() -> void: run.call_deferred()

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures.append(label)
		push_error(label)

func digest(bytes: PackedByteArray) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(bytes)
	return context.finish().hex_encode()

func state() -> Dictionary:
	var s: WorkingSurface = main.block.working_map
	return {"height": digest(s.image.get_data()), "strata": digest(s.strata.boundaries.get_data()),
		"bone": digest(s.fossil.field.image.get_data()), "ceilings": digest(s.structural_ceilings.to_byte_array()),
		"exposed": digest(s.fossil.exposed), "film": digest(s.bone_film.image.get_data()),
		"fracture": digest(s.fracture.image.get_data()), "dust": digest(s.residue.image.get_data()),
		"condition": s.fossil.condition, "protected": Array(s.fossil.direct_contact_consumed),
		"crumbs": s.loose_debris.persistent_count(), "clean": s.bone_film.cleanliness_percent(),
		"progress": [main.session.preparation_complete, main.session.fine_preparation, main.session.archived, main.session.classification_stage]}

func settle(count := 3) -> void:
	main.block.flush_texture()
	main.session.flush()
	for n in range(count): await process_frame

func at(point: Vector2) -> Vector2:
	var b: ExcavationBlock = main.block
	var uv := (point + Vector2.ONE * 0.5) / Vector2(b.map_resolution)
	return main.camera.unproject_position(b.to_global(Vector3((uv.x - 0.5) * b.surface_size.x,
		b.relief.height_at(uv), (uv.y - 0.5) * b.surface_size.y)))

func zoom_to(factor: float, point := Vector2(520, 350)) -> void:
	main.camera.reset_view()
	main.camera._focused = true
	if factor > 1: main.camera.request_zoom(log(factor) / log(main.camera.wheel_step), at(point))
	for n in range(120):
		await physics_frame
		if absf(main.camera.size - main.camera._base_size / factor) < 0.0000001: break

func brush_pass() -> void:
	# Two seconds of the real, unmodified Soft Brush, at 60 Hz.
	var last := Vector2(100, 350)
	for tick in range(120):
		var p := Vector2(lerpf(100, 924, tick / 119.0), 350)
		main.block.working_map.apply_continuous(last, p, main.controller.tools[0], 1.0 / 60.0)
		last = p
	main.block.flush_texture()
	main.session.flush()

func soil_line_count() -> int:
	var s: WorkingSurface = main.block.working_map
	var count := 0
	for x in range(120, 905):
		var i := 350 * s.size.x + x
		if s._heights[i] > s.strata.packed_limits[i * 2] + Stratigraphy.SURFACE_EPSILON: count += 1
	return count

func functional() -> void:
	var s: WorkingSurface = main.block.working_map
	var original := Stratigraphy.new(s.size, main.block.material_definitions)
	var original_bone := digest(s.fossil.field.image.get_data())
	var original_ceiling := digest(s.structural_ceilings.to_byte_array())
	check(s.fossil.field.total_cells == 32290 and s.fragments == null, "canonical B-17, fragments dormant")
	check(main.controller.tools.size() == 4, "four tools")
	check(Engine.max_fps == 240 and Engine.physics_ticks_per_second == 60, "240 / 60 cadence")
	var expected := [Vector3(40, 0.70, 1.25), Vector3(22, 0.64, 2.25), Vector3(60, 0, 1), Vector3(11, 0.44, 1.75)]
	for t in range(4):
		var tool: ToolDefinition = main.controller.tools[t]
		check(Vector3(tool.radius, tool.power, tool.falloff).is_equal_approx(expected[t]), "locked tool " + str(t))
	for f in range(2):
		main.select_fixture(f)
		main.select_candidate(0)
		check(s._heights[0] == 1.0 and s._heights.count(1.0) == s._heights.size(), "A is current flat top")
		if f == 0: check(s.strata.boundaries.get_data() == original.boundaries.get_data(), "primary fixture identical P5 geology")
		var shared_layers := digest(s.strata.boundaries.get_data())
		var a_line := soil_line_count()
		brush_pass()
		evidence.brush.append({"fixture": f, "candidate": "A", "seconds": 2, "soil_line_before": a_line, "soil_line_after": soil_line_count()})
		main.select_candidate(1)
		check(digest(s.strata.boundaries.get_data()) == shared_layers, "A/B identical underlying matrix")
		var reset_state := state()
		var bare := 0
		var max_mm := 0.0
		var min_mm := INF
		var min_top := INF
		var max_top := -INF
		var unsafe_bone := 0
		var changed_stone := 0
		var worst_relief_error := 0.0
		var stone_cells := 0
		for i in range(s._heights.size()):
			var substrate := s.strata.packed_limits[i * 2]
			var thickness := (s._heights[i] - substrate) * s.excavatable_depth * 1000.0
			max_mm = maxf(max_mm, thickness)
			min_mm = minf(min_mm, thickness)
			min_top = minf(min_top, s._heights[i])
			max_top = maxf(max_top, s._heights[i])
			if thickness <= Stratigraphy.SURFACE_EPSILON * s.excavatable_depth * 1000.0: bare += 1
			if substrate <= s.structural_ceilings[i] + FossilField.EXPOSURE_EPSILON: unsafe_bone += 1
			if s.strata.packed_limits[i * 2 + 1] != original.packed_limits[i * 2 + 1]: changed_stone += 1
			if substrate == s.strata.packed_limits[i * 2 + 1]: stone_cells += 1
			if i >= 17:
				var dh := s._heights[i] - s._heights[i - 17]
				var db := substrate - s.strata.packed_limits[(i - 17) * 2]
				worst_relief_error = maxf(worst_relief_error, absf(dh - db) * s.excavatable_depth * 1000)
		check(min_mm >= 0 and max_mm <= 2.00001, "Soil bounded 0–2 mm on ALL cells")
		check(bare > s._heights.size() * 0.15 and bare < s._heights.size() * 0.65, "partial coverage, substantial bare matrix")
		check((max_top - min_top) * 102 > 25 and worst_relief_error <= 2.00001, "surface follows substrate, no independent plateau")
		check(unsafe_bone == 0 and s.fossil.exposed_cells == 0, "no Bone revealed or buried ceiling crossed")
		check(changed_stone == 0, "Sandstone boundary byte-exact")
		check(stone_cells == 0 if f == 0 else stone_cells > 10000, "explicit Stone witness only in secondary fixture")
		evidence.profiles.append({"fixture": f, "min_soil_mm": min_mm, "max_soil_mm": max_mm,
			"bare_percent": 100.0 * bare / s._heights.size(), "surface_relief_mm": (max_top - min_top) * 102,
			"witness_stone_cells": stone_cells, "profile_build_usec": main.profile.build_usec})
		# A long Brush pass crosses multiple covered/bare patches and must stop at matrix.
		var before := soil_line_count()
		brush_pass()
		check(soil_line_count() == 0, "2-second pass clears thin Soil centreline")
		var below := 0
		for i in range(s._heights.size()):
			if s._heights[i] < s.strata.packed_limits[i * 2]: below += 1
		check(below == 0, "Brush never excavates broad Clay/Stone substrate")
		check(s.loose_debris.persistent_count() == 0 and s.residue.image.get_data().count(0) == s.residue.image.get_data().size(), "Soil adds no persistent grains/dust")
		evidence.brush.append({"fixture": f, "candidate": "B", "seconds": 2, "soil_line_before": before, "soil_line_after": soil_line_count()})
		main.reset_specimen()
		check(state() == reset_state, "reset deterministic, all maps and P5 progress")
		check(state().bone == original_bone and state().ceilings == original_ceiling, "no new Bone authority")
		if f == 1:
			var witness := -1
			for i in range(s._heights.size()):
				if s.strata.packed_limits[i * 2] == s.strata.packed_limits[i * 2 + 1] and s._heights[i] - s.strata.packed_limits[i * 2] > 0.01:
					witness = i
					break
			check(witness >= 0, "witness has Soil over genuine Sandstone")
			if witness >= 0:
				var p := Vector2(witness % s.size.x, witness / s.size.x as int)
				for tick in range(6): s.apply_continuous(p, p, main.controller.tools[0], 1.0 / 60)
				check(s._heights[witness] == s.strata.packed_limits[witness * 2 + 1], "native Brush clears witness Soil and stops exactly on Sandstone")
				var before_stone := s._heights[witness]
				s.apply_impact(p, main.controller.tools[3])
				check(s._heights[witness] < before_stone, "native Pick then excavates exposed witness Sandstone")
			main.reset_specimen()
		var before_visual := state()
		main.set_patina(false)
		main.set_patina(true)
		check(state() == before_visual, "patina is visual only")
		main.show_substrate()
		var bare_state := state()
		main.select_candidate(0)
		check(state() == bare_state, "same cleared substrate and state A/B")
		# Exact original piecewise resistance below the prepared substrate.
		for point in [Vector2i(250, 230), Vector2i(510, 307), Vector2i(962, 60)]:
			var i: int = point.y * s.size.x + point.x
			var h := s.strata.packed_limits[i * 2]
			for tool in [main.controller.tools[1], main.controller.tools[3]]:
				check(s.strata.remove_work(h, 0.03, point, tool.effectiveness) == original.remove_work(h, 0.03, point, tool.effectiveness), "native matrix resistance below prepared surface")
		main.reset_specimen()
		var idle := state()
		var uploads: int = main.block.upload_count
		await settle(120)
		check(main.profile.build_count == 1 and main.block.upload_count == uploads and state() == idle, "idle: no map regeneration/upload/gameplay changes")
	# Replay a prepared Bone/cavity fixture through every actual tool, compare P5 scene.
	main.select_fixture(0)
	var lab := main
	var reference: Dictionary
	for version in range(3):
		if version == 0:
			main = load("res://scenes/prototype_main.tscn").instantiate()
			root.add_child(main)
			main.controller.set_physics_process(false)
		else:
			main = lab
			main.select_candidate(version - 1)
		P6AMaterialPresets.apply(main, 9)
		for t in range(4):
			for tick in range(24):
				var p := Vector2(720 + tick, 180) if t == 1 else Vector2(455 + tick, 305)
				if t in [1, 3]: s = main.block.working_map; s.apply_impact(p, main.controller.tools[t])
				else: main.block.working_map.apply_continuous(p, p + Vector2(1, 0), main.controller.tools[t], 1.0 / 60)
		main.block.flush_texture()
		main.session.flush()
		if version == 0:
			reference = state()
			main.queue_free()
			await process_frame
		else: check(state() == reference, "P5 exact four-tool / fracture / film / Condition / progression replay " + str(version))
	main = lab
	main.reset_specimen()
	var camera: Transform3D = main.camera.global_transform
	var camera_size: float = main.camera.size
	main.select_candidate(1)
	check(main.camera.global_transform == camera and main.camera.size == camera_size, "A/B preserves exact camera")
	var event := InputEventKey.new()
	event.pressed = true
	event.physical_keycode = KEY_F8
	main._unhandled_input(event)
	check(main.candidate == 0 and main.camera.global_transform == camera, "F8 switches trial without moving camera")
	main.show_substrate()
	main.reset_specimen()
	check(not main.cleared and main.block.working_map._heights[0] == 1.0, "P5 Another Block reset restores chosen Soil trial")
	main.controller._focused = true
	main.controller._pointer_inside = true
	main.controller._screen = Vector2(1600, 120)
	check(not main.controller._pick_current().inside, "controls block tool input")
	for point in [Vector2(250, 230), Vector2(510, 307), Vector2(962, 60)]:
		var hit: Dictionary = main.block.pick(at(point), main.camera)
		check(hit.inside and hit.map.distance_to(point) < 0.02, "real relief picking roundtrip")

func capture(label: String) -> Image:
	main.block.show_cursor({"inside": false}, 1)
	main.feedback.proxies_enabled = false
	main.session_ui.notice_label.hide()
	await settle(4)
	await RenderingServer.frame_post_draw
	var pic := root.get_texture().get_image()
	check(pic.save_png(out + label + ".png") == OK, "capture " + label)
	evidence.captures.append(label + ".png")
	return pic

func visual() -> void:
	main.panel.hide()
	for f in range(2):
		main.select_fixture(f)
		for c in range(2):
			main.select_candidate(c)
			main.reset_specimen()
			await zoom_to(1)
			await capture("fixture%d-%s-start" % [f, ["A", "B"][c]])
			brush_pass()
			await capture("fixture%d-%s-brushed" % [f, ["A", "B"][c]])
		main.show_substrate()
		for zoom in [1, 3]:
			await zoom_to(zoom, Vector2(905, 105) if f == 1 else Vector2(520, 350))
			for patina in [true, false]:
				main.set_patina(patina)
				await capture("fixture%d-matrix-%dx-patina%s" % [f, zoom, str(patina)])
		main.set_patina(true)
	main.select_fixture(0)
	main.select_candidate(1)
	main.reset_specimen()
	main.panel.show()
	await zoom_to(1)
	await capture("controls-B-start")
	# Actual GPU deposit mask: prove unmodified material between separate deposits.
	main.panel.hide()
	main.show_substrate()
	var mask := Shader.new()
	mask.code = main.soil_shader.code.replace("diffuse_burley", "diffuse_burley, unshaded")
	mask.code = mask.code.replace("ALBEDO = mix(color, cursor_color.rgb, marker);", "ALBEDO = vec3(contact_deposit, float(layer) / 2.0, exposed_bone ? 1.0 : 0.0);")
	for mat in [main.block.material, main.block.skirt_material]: mat.shader = mask
	var pic := await capture("deposit-mask")
	var clear := 0
	var dirty := 0
	var intermediates := 0
	for y in range(220, 860):
		for x in range(420, 1450):
			var color := pic.get_pixel(x, y)
			if color.r < 0.003: clear += 1
			if color.r > 0.12: dirty += 1
			if color.r > 0.003 and color.r < 0.12: intermediates += 1
	check(clear > 100000 and dirty > 40000 and intermediates > 10000, "GPU: clear matrix + broken deposits + variable opacity")
	evidence["deposit_pixels"] = {"clear": clear, "dirty": dirty, "intermediate": intermediates}
	for mat in [main.block.material, main.block.skirt_material]: mat.shader = main.soil_shader
	# Gameplay masks must agree with the original shader on excavated Bone/cavity.
	main.select_fixture(0)
	P6AMaterialPresets.apply(main, 9)
	await zoom_to(1)
	var masks: Array[Image] = []
	var original_state := state()
	for shader in [main.BASE, main.soil_shader]:
		var diagnostic := Shader.new()
		diagnostic.code = shader.code.replace("diffuse_burley", "diffuse_burley, unshaded")
		diagnostic.code = diagnostic.code.replace("ALBEDO = mix(color, cursor_color.rgb, marker);", "ALBEDO = vec3(film_cover, float(layer) / 2.0, exposed_bone ? 1.0 : 0.0);")
		for mat in [main.block.material, main.block.skirt_material]: mat.shader = diagnostic
		masks.append(await capture("bone-mask-" + str(masks.size())))
	check(masks[0].get_region(Rect2i(400, 200, 1100, 680)).get_data() == masks[1].get_region(Rect2i(400, 200, 1100, 680)).get_data(), "GPU: original layer/Bone/film masks pixel-exact")
	check(state() == original_state, "mask/render toggle preserves all gameplay state")
	for mat in [main.block.material, main.block.skirt_material]: mat.shader = main.soil_shader
	await capture("bone-and-cavity")

func stats(values: Array[float]) -> Dictionary:
	if values.is_empty(): return {"mean": 0, "p95": 0, "max": 0}
	var sorted := values.duplicate()
	sorted.sort()
	var total := 0.0
	for v in values: total += v
	return {"mean": total / values.size(), "p95": sorted[int((sorted.size() - 1) * 0.95)], "max": sorted[-1]}

func sample_frame() -> void:
	if not measuring: return
	var now := Time.get_ticks_usec()
	if previous > 0: frames.append((now - previous) / 1000.0)
	previous = now
	gpu.append(RenderingServer.viewport_get_measured_render_time_gpu(root.get_viewport_rid()))
	render_cpu.append(RenderingServer.viewport_get_measured_render_time_cpu(root.get_viewport_rid()))

func benchmark() -> void:
	RenderingServer.viewport_set_measure_render_time(root.get_viewport_rid(), true)
	process_frame.connect(sample_frame)
	main.panel.hide()
	main.select_fixture(0)
	var poses := {}
	for zoom in [1, 3]:
		for kind in ["idle", "brush", "chisel", "pick", "blower", "bone_brush"]:
			for c in range(2):
				main.select_candidate(c)
				main.reset_specimen()
				if kind in ["chisel", "pick", "blower", "bone_brush"]: P6AMaterialPresets.apply(main, 9)
				var t := {"idle": 0, "brush": 0, "chisel": 1, "pick": 3, "blower": 2, "bone_brush": 0}
				main.controller.select_tool(t[kind])
				var center := Vector2(720, 180) if kind == "chisel" else Vector2(510, 307)
				await zoom_to(zoom, center)
				var key: String = str(zoom) + kind
				if c == 0: poses[key] = [main.camera.global_transform, main.camera.size]
				else:
					main.camera.global_transform = poses[key][0]
					main.camera.size = poses[key][1]
				await settle(45)
				main.controller.cancel_stroke()
				var initial := state()
				frames.clear(); gpu.clear(); render_cpu.clear(); previous = 0
				var edits: Array[float] = []
				var picks: Array[float] = []
				measuring = true
				for tick in range(180):
					var prior: Vector2 = main.controller._previous
					var valid: bool = main.controller._previous_valid
					var elapsed: float = main.controller.impact_clock.elapsed
					var emitted: int = main.controller.impact_clock.emitted
					await physics_frame
					main.controller._previous = prior
					main.controller._previous_valid = valid
					main.controller.impact_clock.elapsed = elapsed
					main.controller.impact_clock.emitted = emitted
					main.controller._focused = true
					main.controller._pointer_inside = true
					main.controller._held = kind != "idle"
					main.controller._screen = at(center + Vector2(sin(tick * 0.026) * 28, cos(tick * 0.02) * 12))
					main.controller._physics_process(1.0 / 60)
					main.session.flush()
					edits.append(main.controller.last_edit_usec / 1000.0)
					picks.append(main.controller.last_pick_usec / 1000.0)
				measuring = false
				main.controller.cancel_stroke()
				var row := {"candidate": c, "kind": kind, "zoom": zoom, "frame_ms": stats(frames),
					"gpu_ms": stats(gpu), "render_cpu_ms": stats(render_cpu), "edit_ms": stats(edits), "pick_ms": stats(picks),
					"initial": initial, "final": state(), "camera": str(main.camera.global_transform), "camera_size": main.camera.size,
					"draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)}
				evidence.benchmark.append(row)
				check(row.frame_ms.p95 < 16.667 and row.gpu_ms.mean > 0, "representative timing " + key + str(c))
				print("SOIL BENCH ", key, " ", c, " ", JSON.stringify({"frame": row.frame_ms, "gpu": row.gpu_ms, "edit": row.edit_ms}))
				FileAccess.open(out + "benchmark.json", FileAccess.WRITE).store_string(JSON.stringify(evidence, "\t"))
	for row in evidence.benchmark:
		var a: Dictionary = evidence.benchmark.filter(func(r: Dictionary): return r.candidate == 0 and r.kind == row.kind and r.zoom == row.zoom)[0]
		check(row.camera == a.camera and row.camera_size == a.camera_size, "benchmark identical camera")
		if row.kind not in ["idle", "brush"]:
			check(row.initial == a.initial and row.final == a.final, "outside Soil identical four-tool outcomes")

func run() -> void:
	var args := OS.get_cmdline_user_args()
	var mode := args[0] if not args.is_empty() else "tests"
	DirAccess.make_dir_recursive_absolute(out)
	root.size = Vector2i(1920, 1080)
	root.content_scale_size = root.size
	AudioServer.set_bus_mute(0, true)
	main = load("res://scenes/p6a15_soil_lab.tscn").instantiate()
	root.add_child(main)
	main.controller.set_physics_process(false)
	await settle()
	if mode == "tests": await functional()
	elif mode == "visual": await visual()
	elif mode == "benchmark": await benchmark()
	evidence["checks"] = checks
	evidence["failures"] = failures
	FileAccess.open(out + mode + ".json", FileAccess.WRITE).store_string(JSON.stringify(evidence, "\t"))
	print("P6A15 ", mode, ": ", checks, " checks, ", failures.size(), " failures")
	main.queue_free()
	await create_timer(0.5).timeout
	quit(0 if failures.is_empty() else 1)
