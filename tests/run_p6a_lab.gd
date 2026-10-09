extends SceneTree
## tests (headless), visual, benchmark, or quick (four study captures).
var main: Node3D
var checks := 0
var failures: Array[String] = []
var evidence := {"presets": [], "captures": [], "benchmark": []}
var out := "res://work/test-logs/p6a/"
var frames: Array[float] = []
var gpu: Array[float] = []
var render_cpu: Array[float] = []
var measuring := false
var previous := 0

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures.append(label)
		push_error(label)

func digest(data: PackedByteArray) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(data)
	return context.finish().hex_encode()

func state() -> Dictionary:
	var s: WorkingSurface = main.block.working_map
	return {"height": digest(s.image.get_data()), "film": digest(s.bone_film.image.get_data()),
		"strata": digest(s.strata.boundaries.get_data()), "bone": digest(s.fossil.field.image.get_data()),
		"exposed": digest(s.fossil.exposed), "fracture": digest(s.fracture.image.get_data()),
		"dust": digest(s.residue.image.get_data()), "condition": s.fossil.condition,
		"protected": Array(s.fossil.direct_contact_consumed), "crumbs": s.loose_debris.persistent_count(),
		"progress": [main.session.preparation_complete, main.session.fine_preparation,
			main.session.archived, main.session.classification_stage, s.bone_film.cleanliness_percent()]}

func settle(count := 3) -> void:
	main.block.flush_texture()
	main.session.flush()
	for n in range(count): await process_frame

func at(point: Vector2) -> Vector2:
	var b: ExcavationBlock = main.block
	var uv := (point + Vector2.ONE * 0.5) / Vector2(b.map_resolution)
	return main.camera.unproject_position(b.to_global(Vector3((uv.x - 0.5) * b.surface_size.x,
		b.relief.height_at(uv), (uv.y - 0.5) * b.surface_size.y)))

func zoom_to(factor: float, point := Vector2(425, 305)) -> void:
	main.camera.reset_view()
	main.camera._focused = true
	if factor > 1: main.camera.request_zoom(log(factor) / log(main.camera.wheel_step), at(point))
	for n in range(120):
		await physics_frame
		if absf(main.camera.size - main.camera._base_size / factor) < 0.0000001: break

func capture(label: String) -> Image:
	main.controller.hit = {"inside": false}
	main.block.show_cursor({"inside": false}, 1)
	main.feedback.proxies_enabled = false
	main.session_ui.notice_label.hide()
	await settle(4)
	await RenderingServer.frame_post_draw
	var picture := root.get_texture().get_image()
	check(picture.save_png(out + label + ".png") == OK, "capture " + label)
	evidence.captures.append(label + ".png")
	return picture

func functional() -> void:
	var s: WorkingSurface = main.block.working_map
	check(s.fossil.field.total_cells == 32290, "real canonical B-17, 32290 cells")
	check(main.controller.tools.size() == 4 and s.fragments == null, "four tools; fragment experiment dormant")
	check(Engine.max_fps == 240 and Engine.physics_ticks_per_second == 60, "locked runtime cadence")
	var bone_height := ""
	var dirty_mask := ""
	for p in range(P6AMaterialPresets.NAMES.size()):
		main.load_preset(p)
		await settle()
		var before := state()
		var camera: Transform3D = main.camera.global_transform
		var size: float = main.camera.size
		var pick: Dictionary = main.block.pick(at(Vector2(510, 307)), main.camera)
		for candidate in range(4):
			main.select_candidate(candidate)
			for mat in [main.block.material, main.block.skirt_material]:
				check(mat.get_shader_parameter("working_map") == main.block.texture, "shared height texture")
			await settle()
			check(before == state(), "switch preserves ALL gameplay maps and progress: %d/%d" % [p, candidate])
			check(main.camera.global_transform == camera and main.camera.size == size, "switch preserves camera")
			check(main.block.pick(at(Vector2(510, 307)), main.camera) == pick, "switch preserves exact ray pick")
		if p == 0: check(s.fossil.exposed_cells == 0 and s._heights[0] == 1.0, "lab starts closed")
		if p == 6:
			bone_height = before.height
			dirty_mask = before.film
			check(s.fossil.exposed_cells > 24000 and s.bone_film.cleanliness_percent() < 0.01, "representative dirty Bone")
		if p in [7, 8, 9]: check(before.height == bone_height, "Bone presets use identical geometry")
		if p == 7: check(s.bone_film.cleanliness_percent() > 10 and s.bone_film.cleanliness_percent() < 90, "partial Brush cleaning")
		if p == 8: check(s.bone_film.cleanliness_percent() > 99.9, "native Brush cleaning reaches clean Bone")
		var data := {"preset": p, "state": before, "exposed_cells": s.fossil.exposed_cells}
		evidence.presets.append(data)
	# Visual controls must not rewrite film, terrain, protection, progression or picking.
	main.load_preset(6)
	var before := state()
	for value in [false, true]:
		main.patina = value; main.stone_patina = value; main.film_palette = value; main.detail = value
		main._apply_material()
		check(state() == before and state().film == dirty_mask, "appearance toggles never change film pattern/data")
	main.stone_patina = false
	# Real tools, identical deterministic replay per candidate (no shader involvement).
	var replay := {}
	for candidate in range(4):
		main.load_preset(9)
		main.select_candidate(candidate)
		for tool in range(4):
			main.controller.select_tool(tool)
			for tick in range(30):
				var point := Vector2(455 + tick, 305) if tool != 1 else Vector2(740 + tick, 180)
				main.controller._focused = true
				main.controller._pointer_inside = true
				main.controller._screen = at(point)
				main.controller._held = true
				main.controller._physics_process(1.0 / 60.0)
			main.controller.cancel_stroke()
		main.session.flush()
		main.block.flush_texture()
		if candidate == 0: replay = state()
		else: check(replay == state(), "all four real tools reproduce P5 outcome in candidate %d" % candidate)
	check(main.variants.shaders[0] == P6AMaterialVariants.BASE, "reference is the original P5 shader resource")
	main.load_preset(7)
	main.load_preset(-1)
	check(main.preset == 7 and main.preset_select.selected == 7, "reload retains selected preset")
	main.reset_specimen()
	check(main.preset == 0 and main.preset_select.selected == 0 and s.fossil.exposed_cells == 0,
		"P5 Prepare Another Block reset also resets lab state label")
	var event := InputEventKey.new()
	event.pressed = true
	event.physical_keycode = KEY_F8
	main._unhandled_input(event)
	check(main.candidate == 0, "F8 cycles C to original P5")
	main.controller._screen = Vector2(1590, 135)
	main.controller._focused = true
	main.controller._pointer_inside = true
	check(not main.controller._pick_current().inside, "lab controls block excavation underneath")
	# GPU mask equivalence is checked separately in graphical mode.

func visual(quick: bool, only_masks := false) -> void:
	main.lab_panel.hide()
	for p in ([] if only_masks else ([9] if quick else range(10))):
		main.load_preset(p)
		for zoom in ([1] if quick else [1, 3]):
			await zoom_to(zoom)
			var before := state()
			for c in range(4):
				main.select_candidate(c)
				await capture("state%02d-%s-%dx" % [p, ["P5", "A", "B", "C"][c], zoom])
				check(state() == before, "capture does not alter state")
	if quick: return
	# Read back the actual shader masks (not only source comparison): encode film
	# coverage + layer + exposed Bone, with lighting/texture color removed.
	main.load_preset(9)
	await zoom_to(3)
	var reference: PackedByteArray
	for c in range(4):
		main.select_candidate(c)
		var code: String = main.variants.shaders[c].code
		code = code.replace("render_mode cull_disabled, diffuse_burley;", "render_mode cull_disabled, unshaded;")
		code = code.substr(0, code.rfind("}")) + "\nALBEDO = vec3(film_cover, float(layer) / 2.0, exposed_bone ? 1.0 : 0.0); EMISSION = vec3(0.0);\n}"
		var shader := Shader.new()
		shader.code = code
		main.block.material.shader = shader
		var pic := await capture("mask-%s" % ["P5", "A", "B", "C"][c])
		# Only the central surface; HUD timers and outer skirt aren't mask diagnostics.
		var pixels := pic.get_region(Rect2i(400, 180, 1100, 680)).get_data()
		if c == 0: reference = pixels
		else: check(pixels == reference, "GPU layer/Bone/film coverage pixel-exact: %d" % c)
	main.select_candidate(2)
	for p in [2, 6]:
		main.load_preset(p)
		await zoom_to(3, Vector2(510, 230) if p == 2 else Vector2(270, 250))
		main.patina = false; main.film_palette = false; main._apply_material()
		await capture("toggle-%02d-before" % p)
		main.patina = true; main.film_palette = true; main._apply_material()
		await capture("toggle-%02d-after" % p)
	main.load_preset(0)
	main.lab_panel.show()
	await create_timer(1.3).timeout
	await capture("lab-controls")

func stats(values: Array[float]) -> Dictionary:
	if values.is_empty(): return {"mean": 0.0, "p95": 0.0, "max": 0.0}
	var ordered := values.duplicate()
	ordered.sort()
	var sum := 0.0
	for v in values: sum += v
	return {"mean": sum / values.size(), "p95": ordered[int((ordered.size() - 1) * 0.95)], "max": ordered[-1]}

func on_frame() -> void:
	var now := Time.get_ticks_usec()
	if measuring and previous > 0:
		frames.append((now - previous) / 1000.0)
		gpu.append(RenderingServer.viewport_get_measured_render_time_gpu(root.get_viewport_rid()))
		render_cpu.append(RenderingServer.viewport_get_measured_render_time_cpu(root.get_viewport_rid()))
	previous = now

func benchmark(only_kind := "") -> void:
	main.lab_panel.hide()
	main.feedback.proxies_enabled = true
	RenderingServer.viewport_set_measure_render_time(root.get_viewport_rid(), true)
	process_frame.connect(on_frame)
	var views := {}
	var bench_name := "benchmark" + ("-" + only_kind if not only_kind.is_empty() else "")
	evidence["hardware"] = {"engine": Engine.get_version_info().string, "adapter": RenderingServer.get_video_adapter_name(),
		"cpu": OS.get_processor_name(), "renderer": RenderingServer.get_current_rendering_method(),
		"resolution": [root.size.x, root.size.y], "cap": Engine.max_fps, "physics_hz": Engine.physics_ticks_per_second,
		"gpu_note": "Viewport timer; zero means unavailable, never zero GPU cost. Timings exclude setup/readbacks."}
	for kind in ["intact_idle", "study_idle", "brush_soil", "brush_film", "chisel", "pick", "blower"]:
		if not only_kind.is_empty() and kind != only_kind: continue
		for zoom in [1, 3]:
			for c in range(4):
				main.load_preset(0 if kind in ["intact_idle", "brush_soil"] else (3 if kind == "chisel" else (5 if kind == "blower" else 6)))
				main.select_candidate(c)
				var tool := 1 if kind == "chisel" else (3 if kind == "pick" else (2 if kind == "blower" else 0))
				var center := Vector2(260, 230) if kind == "brush_film" else Vector2(510, 280)
				if kind == "blower": center = Vector2(724, 184)
				if kind == "pick": center = Vector2(725, 325)
				main.controller.select_tool(tool)
				await zoom_to(zoom, center)
				# Reuse the baseline's exact float32 pose. Different frame pacing while
				# easing can otherwise leave sub-micrometre transform differences.
				var view_key := "%s/%d" % [kind, zoom]
				if not views.has(view_key): views[view_key] = [main.camera.global_transform, main.camera.size]
				main.camera.global_transform = views[view_key][0]
				main.camera.size = views[view_key][1]
				await settle(45) # shader/driver warm-up excluded
				main.controller._screen = at(center)
				main.controller.cancel_stroke()
				var initial := state()
				var edits: Array[float] = []
				var picks: Array[float] = []
				var refresh: Array[float] = []
				var changed := 0
				frames.clear(); gpu.clear(); render_cpu.clear(); previous = 0
				measuring = true
				for tick in range(180):
					# A native focus/mouse-exit notification may cancel a held stroke.
					# Preserve the scripted gesture across the wait (lab benchmark only).
					var held_previous: Vector2 = main.controller._previous
					var held_valid: bool = main.controller._previous_valid
					var held_elapsed: float = main.controller.impact_clock.elapsed
					var held_emitted: int = main.controller.impact_clock.emitted
					await physics_frame
					main.controller._previous = held_previous
					main.controller._previous_valid = held_valid
					main.controller.impact_clock.elapsed = held_elapsed
					main.controller.impact_clock.emitted = held_emitted
					main.controller._focused = true
					main.controller._pointer_inside = true
					main.controller._held = not kind.ends_with("idle")
					main.controller._screen = at(center + Vector2(sin(tick * 0.026) * 28.0, cos(tick * 0.02) * 12.0))
					main.controller._physics_process(1.0 / 60.0)
					main.session.flush()
					changed += main.controller.changed_texels
					edits.append(main.controller.last_edit_usec / 1000.0)
					picks.append(main.controller.last_pick_usec / 1000.0)
					refresh.append(main.session.last_refresh_usec / 1000.0)
				measuring = false
				main.controller.cancel_stroke()
				var row := {"candidate": c, "kind": kind, "zoom": zoom, "frames": frames.size(), "frame_ms": stats(frames),
					"gpu_ms": stats(gpu), "render_cpu_ms": stats(render_cpu), "edit_ms": stats(edits), "pick_ms": stats(picks),
					"changed_cells": changed, "initial_state": initial, "final_state": state(),
					"camera_transform": str(main.camera.global_transform), "camera_size": main.camera.size,
					"draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
					"video_memory_bytes": Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)}
				evidence.benchmark.append(row)
				check(row.frame_ms.p95 < 16.667, "sustained 60fps: %s/%d/%d" % [kind, zoom, c])
				print("P6A BENCH ", kind, " ", zoom, "x ", c, " ", JSON.stringify({"frame": row.frame_ms, "gpu": row.gpu_ms, "cpu": row.render_cpu_ms, "changed": changed}))
				FileAccess.open(out + bench_name + ".json", FileAccess.WRITE).store_string(JSON.stringify(evidence, "\t"))
	for r in evidence.benchmark:
		var reference: Dictionary = evidence.benchmark.filter(func(b: Dictionary): return b.candidate == 0 and b.kind == r.kind and b.zoom == r.zoom)[0]
		check(r.initial_state == reference.initial_state, "same benchmark initial state")
		check(r.final_state == reference.final_state, "same benchmark final state")
		check(r.camera_transform == reference.camera_transform and r.camera_size == reference.camera_size, "same exact benchmark camera")

func run() -> void:
	var args := OS.get_cmdline_user_args()
	var mode: String = args[0] if not args.is_empty() else "tests"
	DirAccess.make_dir_recursive_absolute(out)
	root.size = Vector2i(1920, 1080)
	root.content_scale_size = root.size
	AudioServer.set_bus_mute(0, true)
	main = load("res://scenes/p6a_material_lab.tscn").instantiate()
	root.add_child(main)
	main.controller.set_physics_process(false)
	await settle()
	if mode == "tests": await functional()
	elif mode in ["visual", "quick", "masks"]:
		if DisplayServer.get_name() == "headless": quit(1); return
		await visual(mode == "quick", mode == "masks")
	elif mode == "benchmark":
		if DisplayServer.get_name() == "headless": quit(1); return
		await benchmark(args[1] if args.size() > 1 else "")
		if args.size() > 1: mode += "-" + args[1]
	evidence["checks"] = checks
	evidence["failures"] = failures
	FileAccess.open(out + mode + ".json", FileAccess.WRITE).store_string(JSON.stringify(evidence, "\t"))
	print("P6A ", mode, ": ", checks, " checks, ", failures.size(), " failures")
	main.queue_free()
	await create_timer(0.8).timeout
	quit(0 if failures.is_empty() else 1)
