extends "res://tests/run_p3_benchmark.gd"
## Real input/controller/FX at both ends of B-17; static setup excluded from timing.
## P3's independent GPU/picking oracle retains its original numerical tolerances.

const ZONES := [Vector2(250, 230), Vector2(646, 441)]
var proxy_times: Array[float] = []
var feedback_times: Array[float] = []

func on_frame() -> void:
	super.on_frame()
	if measuring:
		proxy_times.append(main.feedback.last_proxy_usec / 1000.0)
		feedback_times.append((main.feedback.last_particles_usec + main.feedback.loose_view.last_update_usec) / 1000.0)

func fixture(center: Vector2, kind: String) -> void:
	if kind == "brush": return
	var s := block.working_map
	var exposed := PackedInt32Array()
	for y in range(int(center.y) - 100, int(center.y) + 101):
		for x in range(int(center.x) - 100, int(center.x) + 101):
			var i := y * s.size.x + x
			var ceiling := s.fossil.field.ceilings[i]
			var height := s.strata.packed_limits[i * 2] # Top of local Clay.
			if kind in ["chisel_stone", "blower"]: height = s.strata.packed_limits[i * 2 + 1] - 0.002
			if kind == "pick": height = maxf(ceiling + 0.025, s.strata.packed_limits[i * 2 + 1] - 0.15)
			s._heights[i] = maxf(height, ceiling)
			if ceiling > 0 and s._heights[i] <= ceiling + FossilField.EXPOSURE_EPSILON: exposed.append(i)
			if kind == "blower":
				s.residue.deposit_removed(x, y, 0.65)
				if x % 8 == 0 and y % 8 == 0: s.loose_debris.deposit_removed(x, y, 8, 2)
	s.image.set_data(s.size.x, s.size.y, false, Image.FORMAT_RF, s._heights.to_byte_array())
	s.dirty = true
	s.fossil.expose_cells(exposed)
	if kind == "blower": s.residue.apply_segment(center, center, 150, 1, 0)
	block.flush_texture()
	main.feedback.reset()

func minimum_window_fps() -> float:
	var elapsed := 0.0
	var frames := 0
	var minimum := INF
	for dt in frame_times:
		elapsed += dt
		frames += 1
		if elapsed >= 1000.0:
			minimum = minf(minimum, frames * 1000.0 / elapsed)
			elapsed = 0.0
			frames = 0
	return minimum

func zone_scenario(zone: int, kind: String, zoom: float) -> void:
	controller.reset_surface()
	(camera as PrecisionZoom).reset_view()
	controller._focused = true
	controller._pointer_inside = true
	select(0 if kind == "brush" else (3 if kind == "pick" else (2 if kind == "blower" else 1)))
	var center: Vector2 = ZONES[zone]
	fixture(center, kind)
	var uv := (center + Vector2.ONE * 0.5) / Vector2(block.map_resolution)
	move_to(uv)
	if zoom == 3:
		await settle_zoom(zoom)
	for i in range(90): await physics_frame
	check(absf((camera as PrecisionZoom).zoom_factor - zoom) < 0.001, "benchmark reaches requested zoom")
	var height_before := block.working_map.image.get_data()
	var layer_bytes := block.working_map.strata.boundaries.get_data()
	var bone_bytes := block.working_map.bone_display_image.get_data()
	var edits: Array[float] = []
	var active_edits: Array[float] = []
	var picks: Array[float] = []
	var uploads: Array[float] = []
	var changed := 0
	var chunks := 0
	var removed := Vector3.ZERO
	var cleaned := 0.0
	var ticks := 720 if kind == "brush" else 360
	frame_times.clear()
	proxy_times.clear()
	feedback_times.clear()
	previous_frame = 0
	measuring = true
	var start := Time.get_ticks_usec()
	press_at(uv)
	for tick in range(ticks):
		# Native focus loss must not restart this fixed synthetic held stroke.
		var held_elapsed := controller.impact_clock.elapsed
		var held_emitted := controller.impact_clock.emitted
		await physics_frame
		controller.impact_clock.elapsed = held_elapsed
		controller.impact_clock.emitted = held_emitted
		controller._focused = true
		controller._pointer_inside = true
		controller._held = true
		var p := center
		if kind in ["brush", "blower"]:
			p += Vector2(56 * sin(tick / 80.0), 44 * cos(tick / 67.0))
		elif kind == "pick":
			p += Vector2((tick / 60 as int % 3 - 1) * 7, (tick / 180 as int) * 7)
		else:
			p += Vector2((tick / 120 as int - 1) * 24, 0)
		move_to((p + Vector2.ONE * 0.5) / Vector2(block.map_resolution))
		controller._physics_process(1.0 / 60.0)
		edits.append(controller.last_edit_usec / 1000.0)
		picks.append(controller.last_pick_usec / 1000.0)
		uploads.append((block.last_upload_usec + block.last_residue_upload_usec + block.last_fracture_upload_usec) / 1000.0)
		changed += controller.changed_texels
		if kind in ["brush", "blower"] or controller.impacts_this_tick > 0:
			active_edits.append(controller.last_edit_usec / 1000.0)
			removed += block.working_map.last_action.get("removed", Vector3.ZERO)
			chunks += block.working_map.last_action.get("chunks", []).size()
			cleaned += block.working_map.last_action.get("residue_cleared", 0.0)
	measuring = false
	var seconds := (Time.get_ticks_usec() - start) / 1e6
	controller.cancel_stroke()
	var label := "%s_%s_%dx" % ["A" if zone == 0 else "C", kind, int(zoom)]
	var data := {"render_fps": frame_times.size() / seconds, "min_1s_fps": minimum_window_fps(),
		"min_instant_fps": 1000.0 / stats(frame_times).max, "frame_ms": stats(frame_times),
		"edit_ms": stats(edits), "active_edit_ms": stats(active_edits), "pick_ms": stats(picks),
		"proxy_ms": stats(proxy_times), "feedback_ms": stats(feedback_times), "upload_ms": stats(uploads),
		"changed_cells": changed, "chunks": chunks, "removed": [removed.x, removed.y, removed.z], "dust_cleared": cleaned,
		"elapsed_seconds": seconds, "ticks": ticks, "impacts": controller.total_impacts, "zoom": (camera as PrecisionZoom).zoom_factor,
		"bone_exposed": block.working_map.fossil.exposed_cells, "condition": block.working_map.fossil.condition,
		"cell": [center.x, center.y]}
	check(data.render_fps >= 60 and data.min_1s_fps >= 60 and data.frame_ms.p95 < 1000.0 / 60,
		"stable >=60 FPS and P95 <16.67ms: " + label)
	check(data.render_fps <= 241, "240 FPS cap: " + label)
	if kind == "blower":
		check(height_before == block.working_map.image.get_data() and cleaned > 0, "Blower really cleans with zero structural change: " + label)
	else:
		check(changed > 0, "benchmark actually excavates: " + label)
	if kind.begins_with("chisel"): check(chunks > 0, "benchmark fractures hard matrix: " + label)
	if kind == "pick" or kind.begins_with("chisel"):
		check(controller.total_impacts == (36 if kind == "pick" else 27), "locked cadence on a six-second held stroke: " + label)
	check(layer_bytes == block.layer_texture.get_image().get_data() and bone_bytes == block.fossil_texture.get_image().get_data(),
		"layer/fossil GPU maps immutable after workload: " + label)
	report[label] = data
	print("P4V BENCH ", label, " ", JSON.stringify(data))
	controller.hit = {"inside": false}
	block.show_cursor({"inside": false}, 40)
	await screenshot("p4v-" + label)

func macro_layer_oracle() -> void:
	controller.reset_surface()
	(camera as PrecisionZoom).reset_view()
	main.get_node("Debug/Panel").hide()
	main.get_node("Debug/BonePanel").hide()
	main.get_node("Debug/BoneNotice").hide()
	# One horizontal cut intersects all three broad layers. No interface formula
	# is copied into the shader or oracle; each reads the uploaded RGF map.
	block.working_map.apply_segment(Vector2.ZERO, Vector2(1024, 640), 2000, 0.36, 1, 1, Vector3(1, 3, 8))
	block.flush_texture()
	block.show_cursor({"inside": false}, 1)
	controller.hit = {"inside": false}
	block.set_debug_view(2)
	for i in range(30): await physics_frame
	var picture := await screenshot("p4v-macro-layers")
	block.set_debug_view(1)
	var height_picture := await screenshot("p4v-macro-height")
	var counts := [0, 0, 0]
	var error := 0.0
	var mismatches := []
	var alternatives := []
	for y in range(220, 885, 4):
		for x in range(300, 1620, 4):
			var pixel := Vector2i(x, y)
			var hit := block.pick(Vector2(pixel) + Vector2.ONE * 0.5, camera)
			if not hit.inside: continue
			var layer := block.material_definitions.find(hit.material)
			counts[layer] += 1
			var pixel_error := color_distance(picture.get_pixelv(pixel), hit.material.debug_color)
			if pixel_error > 0.02:
				var alternative := raster_probe(Vector2(pixel) + Vector2.ONE * 0.5, height_picture.get_pixelv(pixel), picture.get_pixelv(pixel))
				if alternative.score <= 1.0:
					pixel_error = alternative.color_error
					alternatives.append(alternative)
			error = maxf(error, pixel_error)
			if pixel_error > 0.02 and mismatches.size() < 10:
				mismatches.append({"pixel": [x, y], "uv": str(hit.uv), "height": hit.height,
					"limits": str(block.working_map.strata.sample_limits(hit.uv)), "actual": str(picture.get_pixelv(pixel)), "expected": str(hit.material.debug_color)})
	check(counts[0] > 1000 and counts[1] > 1000 and counts[2] > 1000, "macro GPU oracle covers all three materials")
	check(error < 0.02, "macro CPU/GPU layer classification keeps historical 0.02 color tolerance")
	check(block.layer_texture.get_image().get_data() == block.working_map.strata.boundaries.get_data(), "RGF layer upload byte exact")
	report["macro_gpu"] = {"material_pixels": counts, "max_color_error": error, "layers_byte_exact": true, "raster_alternatives": alternatives}
	if not mismatches.is_empty(): print("P4V MACRO DIAGNOSTICS: ", JSON.stringify(mismatches))
	block.set_debug_view(0)

func debug_capture() -> void:
	controller.reset_surface()
	(camera as PrecisionZoom).reset_view()
	main.get_node("Debug/Panel").show()
	main.get_node("Debug/BonePanel").show()
	move_to((ZONES[0] + Vector2.ONE * 0.5) / Vector2(block.map_resolution))
	controller._focused = true
	controller._pointer_inside = true
	controller._physics_process(1.0 / 60.0)
	main._process(0.2)
	await screenshot("p4v-debug-shallow")
	check(main.debug_panel.get_global_rect().end.y < 960, "F1 remains above the toolbar at 1080p")

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://work/test-logs")
	if DisplayServer.get_name() == "headless":
		push_error("P4V benchmark requires graphical rendering")
		quit(1)
		return
	check(Engine.max_fps == 240 and Engine.physics_ticks_per_second == 60, "240 FPS / 60 Hz baseline")
	root.size = Vector2i(1920, 1080)
	root.content_scale_size = Vector2i(1920, 1080)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	AudioServer.set_bus_mute(0, true)
	process_frame.connect(on_frame)
	main = load("res://scenes/prototype_main.tscn").instantiate()
	root.add_child(main)
	block = main.block
	controller = main.controller
	camera = main.camera
	controller.set_physics_process(false)
	main.get_node("Debug/Panel").hide()
	main.get_node("Debug/BonePanel").hide()
	for i in range(90): await physics_frame
	if not "--gpu-only" in OS.get_cmdline_user_args():
		for zone in range(2):
			for zoom in [1.0, 3.0]:
				for kind in ["brush", "chisel_clay", "chisel_stone", "pick", "blower"]:
					await zone_scenario(zone, kind, zoom)
	await macro_layer_oracle()
	for zoom in [1.0, 2.0, 3.0]: await validate_bone_pixels(zoom)
	await debug_capture()
	report["gpu"] = RenderingServer.get_video_adapter_name()
	report["cpu"] = OS.get_processor_name()
	report["godot"] = Engine.get_version_info().string
	report["cap"] = Engine.max_fps
	report["physics_hz"] = Engine.physics_ticks_per_second
	report["failures"] = failures
	FileAccess.open("res://work/test-logs/p4v-benchmark.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("P4V GRAPHICAL: %d failures" % failures)
	controller.reset_surface()
	main.queue_free()
	await create_timer(0.4).timeout
	quit(0 if failures == 0 else 1)
