extends "res://tests/run_p4_closure_visual.gd"
## Timed 1080p production renderer. Setup/readback excluded, 60 Hz work, 240 cap.
## --soil-only repeats the long Soil cases without overwriting the full report.
var benchmark_path := "res://work/test-logs/p4-micro-benchmark.json"
var film_uploads: Array[float] = []
var edit_times: Array[float] = []
var debris_times: Array[float] = []
var residue_times: Array[float] = []
var residue_uploads: Array[float] = []

func fill_layer(layer: int, target: int) -> void:
	var dirt := block.working_map.loose_debris
	for y in range(40, 600, 24):
		for x in range(40, 980, 24):
			if dirt.layer_counts[layer] >= target: return
			dirt.deposit_removed(x, y, 16, layer)

func place_matrix(kind: String, tick := 0) -> void:
	var dirt := block.working_map.loose_debris
	var n := 0
	for f in dirt.physics.fragments:
		if not f.active: continue
		if f.state == TerrainDebris.State.SLEEPING: dirt.physics.sleeping_count -= 1
		dirt.physics._wake(f)
		var point := Vector2(740 + (n % 16 - 7.5) * 2, 140 + (n / 16 as int - 7.5) * 2)
		if kind == "cavity": point.x = 710 + (n % 16) * 2
		f.position = local_at(point) + Vector3.UP * (0.075 if kind == "cavity" else (0.003 if tick == 0 else 0.025))
		f.velocity = Vector3.ZERO if kind in ["sleeping", "blower", "brush"] else Vector3(0.035, 0.025, 0)
		f.angular_velocity = 0 if kind in ["sleeping", "blower", "brush"] else 4
		dirt.dirty_cells[f.source] = true
		n += 1

func closure_scenario(kind: String, count: int, zoom: float) -> void:
	controller.reset_surface()
	camera.reset_view()
	var s := block.working_map
	var dirt := s.loose_debris
	dirt.profile = dirt.profile.duplicate()
	dirt.profile.matrix_crumb_cap = 256
	dirt.physics = null
	dirt.setup_physics(block.relief)
	if kind == "film": expose_bone_fixture()
	elif kind == "micro":
		for y in range(60, 241):
			for x in range(600, 961):
				var i := y * s.size.x + x
				s._heights[i] = maxf(0.0, s.fossil.field.ceilings[i])
		for y in range(100, 180, 6):
			for x in range(640, 920, 6):
				for dy in range(2):
					for dx in range(2): s._heights[(y + dy) * s.size.x + x + dx] += 0.0012 / s.excavatable_depth
		s.image.set_data(s.size.x, s.size.y, false, Image.FORMAT_RF, s._heights.to_byte_array())
		s.dirty = true
		block.flush_texture()
	elif kind != "soil_brush": prepare_v2(kind if kind in ["cavity", "chisel_clay"] else "chisel_stone")
	select(0)
	move_to((Vector2(740, 140) + Vector2.ONE * 0.5) / Vector2(block.map_resolution))
	await settle_zoom(zoom)
	fill_layer(1, count / 2)
	fill_layer(2, count / 2)
	place_matrix(kind)
	if kind in ["sleeping", "blower", "brush"]:
		for tick in range(120): dirt.advance(1.0 / 60)
	var initial := dirt.layer_counts.duplicate()
	check(initial == PackedInt32Array([0, count / 2, count / 2]), "requested Matrix occupancy populated before timing")
	main.feedback.loose_view._process(0)
	for frame in range(8): await physics_frame
	frame_times.clear()
	sim_times.clear()
	jet_times.clear()
	multi_times.clear()
	samples_frame.clear()
	film_uploads.clear()
	edit_times.clear()
	debris_times.clear()
	residue_times.clear()
	residue_uploads.clear()
	var initial_residue_uploads := block.residue_upload_count
	var max_probes := 0
	var detached_cells := 0
	previous_frame = 0
	var maximum_moving := 0
	var maximum_samples := 0
	var max_count := dirt.persistent_count()
	var start := Time.get_ticks_usec()
	measuring = true
	for tick in range(1200 if kind == "soil_brush" else 360):
		await physics_frame
		if kind in ["moving", "cavity"] and tick % 60 == 0: place_matrix(kind, tick + 1)
		if kind == "blower":
			var p := Vector2(740, 140)
			s.apply_continuous(p - Vector2.RIGHT * 5, p, controller.tools[2], 1.0 / 60)
			jet_times.append(dirt.last_clean_usec)
		elif kind.begins_with("chisel_") and floori(tick * 4.5 / 60) != floori((tick - 1) * 4.5 / 60):
			s.apply_impact(Vector2(600 + tick * 0.95, 140), controller.tools[1])
		elif kind == "micro":
			var p := Vector2(640 + (tick % 120) * 2.3, 110 + (tick / 120 as int) * 24)
			s.apply_continuous(p - Vector2.RIGHT * 2.3, p, controller.tools[0], 1.0 / 60)
		elif kind == "brush":
			s.apply_continuous(Vector2(735, 140), Vector2(740, 140), controller.tools[0], 1.0 / 60)
		elif kind == "soil_brush":
			var p := Vector2(120 + (tick % 400) * 1.9, 120 + (tick / 400 as int) * 120)
			s.apply_continuous(p - Vector2.RIGHT * 1.9, p, controller.tools[0], 1.0 / 60)
		elif kind == "film":
			var p := Vector2(180 + (tick % 120) * 5, 180 + (tick / 60 as int) * 90)
			s.apply_continuous(p - Vector2.RIGHT * 5, p, controller.tools[0], 1.0 / 60)
		var debris_started := Time.get_ticks_usec()
		dirt.advance(1.0 / 60)
		debris_times.append(Time.get_ticks_usec() - debris_started)
		block.flush_texture()
		sim_times.append(dirt.physics.last_step_usec)
		edit_times.append(s.last_edit_usec if kind in ["brush", "soil_brush", "film", "micro"] else 0)
		residue_times.append(s.last_residue_edit_usec)
		residue_uploads.append(block.last_residue_upload_usec)
		max_probes = maxi(max_probes, s.last_micro_probes)
		detached_cells += s.last_micro_cells
		if block.last_film_upload_usec > 0: film_uploads.append(block.last_film_upload_usec)
		maximum_samples = maxi(maximum_samples, dirt.physics.last_samples)
		maximum_moving = maxi(maximum_moving, dirt.physics.active_count - dirt.physics.sleeping_count)
		max_count = maxi(max_count, dirt.persistent_count())
	measuring = false
	var seconds := (Time.get_ticks_usec() - start) / 1e6
	var label := "%s_matrix%d_%dx" % [kind, count, int(zoom)]
	var data := {"duration_s": seconds, "fps": frame_times.size() / seconds, "min_1s_fps": minimum_1s_fps(), "frame_ms": stats(frame_times), "debris_update_us": stats(debris_times), "physics_us": stats(sim_times), "blower_us": stats(jet_times), "multimesh_us": stats(multi_times), "film_upload_us": stats(film_uploads), "film_uploads": film_uploads.size(), "edit_us": stats(edit_times), "residue_edit_us": stats(residue_times), "residue_upload_us": stats(residue_uploads), "residue_upload_count": block.residue_upload_count - initial_residue_uploads, "micro_probes_max": max_probes, "micro_detached_cells": detached_cells, "initial_counts": Array(initial), "final_counts": Array(dirt.layer_counts), "max_moving": maximum_moving, "max_samples_tick": maximum_samples, "matrix_cap": 256, "cap_refused_attempts": Array(dirt.cap_refusals), "max_count": max_count, "zoom": camera.zoom_factor}
	check(data.fps >= 60 and data.min_1s_fps >= 60 and data.frame_ms.p95 < 16.67, "frame budget: " + label)
	check(maximum_samples <= 256 * 11 and max_count <= 256, "bounded state and terrain probes: " + label)
	if kind in ["moving", "cavity"]: check(maximum_moving == count, "all Matrix records move in stress fixture: " + label)
	if kind == "blower": check(dirt.persistent_count() == 0, "all swept Matrix crumbs really leave state: " + label)
	if kind == "soil_brush": check(dirt.persistent_count() == 0 and main.feedback.emitted[0] == 0 and block.residue_upload_count == initial_residue_uploads and Array(s.residue._values).max() == 0, "Soil has no persistent mess or residue upload: " + label)
	if kind == "micro": check(detached_cells > 100 and max_probes <= 64, "micro-remnant stress exercises bounded conversion: " + label)
	if kind == "film": check(film_uploads.size() > 20, "film uploads exercised during real large-zone Brush: " + label)
	report[label] = data
	FileAccess.open(benchmark_path, FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("P4 MICRO BENCH ", label, " ", JSON.stringify(data))

func run() -> void:
	if DisplayServer.get_name() == "headless": quit(1); return
	var soil_only := "--soil-only" in OS.get_cmdline_user_args()
	if soil_only: benchmark_path = "res://work/test-logs/p4-micro-soil-repeat.json"
	root.size = Vector2i(1920, 1080)
	root.content_scale_size = root.size
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	AudioServer.set_bus_mute(0, true)
	process_frame.connect(on_frame)
	main = load("res://scenes/prototype_main.tscn").instantiate()
	root.add_child(main)
	block = main.block
	controller = main.controller
	camera = main.camera
	controller.set_physics_process(false)
	for node in ["Debug/Panel", "Debug/BonePanel", "Debug/BoneNotice"]: main.get_node(node).hide()
	for zoom in [1.0, 3.0]:
		for kind in ["soil_brush", "sleeping", "blower", "micro", "film"]:
			if soil_only and kind != "soil_brush": continue
			await closure_scenario(kind, 256 if kind in ["blower", "moving", "cavity", "sleeping"] else 0, zoom)
	report["checks"] = bench_checks
	report["failures"] = failures
	report["gpu"] = RenderingServer.get_video_adapter_name()
	report["cpu"] = OS.get_processor_name()
	report["godot"] = Engine.get_version_info().string
	report["physics_hz"] = Engine.physics_ticks_per_second
	report["fps_cap"] = Engine.max_fps
	FileAccess.open(benchmark_path, FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("P4 MICRO BENCHMARK: %d checks, %d failures" % [bench_checks, failures])
	main.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
