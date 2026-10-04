extends "res://tests/run_p2_benchmark.gd"
## Production input + FX at 1x/3x, 1080p, 240 cap / 60 physics.

var proxy_frame_times: Array[float] = []
var peak_particles := PackedInt32Array([0, 0, 0, 0])
var peak_flying := 0

func on_frame() -> void:
	super.on_frame()
	if measuring:
		proxy_frame_times.append(main.feedback.last_proxy_usec / 1000.0)
		for family in range(4): peak_particles[family] = maxi(peak_particles[family], main.feedback.particles[family].size())
		peak_flying = maxi(peak_flying, block.working_map.loose_debris.flying.size())

func prepare_fixture(kind: String) -> void:
	if kind.ends_with("_dense"):
		prepare_fixture(kind.trim_suffix("_dense"))
		return
	if kind in ["pick_clay", "pick_stone"]:
		prepare_fixture("clay" if kind == "pick_clay" else "stone")
		return
	if kind == "proxy_cavity":
		block.working_map.apply_segment(Vector2(710, 140), Vector2(710, 140), 25, 100, 1.5, 1)
	if kind == "proxy_bone":
		block.working_map.apply_segment(Vector2(286, 194), Vector2(286, 194), 65, 100, 1.5, 1)
	if kind == "dusty_bone":
		var p := Vector2(286, 194)
		block.working_map.apply_segment(p, p, 70, 100, 1.5, 1, Vector3.ONE, 8)
		block.working_map.residue.apply_segment(p, p, 80, 1, 0)
	if kind == "dirty_idle":
		# Worst resting case: every local bucket across the block is occupied.
		for y in range(0, block.map_resolution.y, 8):
			for x in range(0, block.map_resolution.x, 8):
				block.working_map.loose_debris.deposit_removed(x, y, 100, (x / 8 as int) % 3)
		for y in range(block.map_resolution.y):
			for x in range(block.map_resolution.x): block.working_map.residue.deposit_removed(x, y, 0.65)
		block.working_map.residue.apply_segment(Vector2(0, 320), Vector2(1023, 320), 400, 1, 0)
	elif kind == "pick":
		for y in range(155, 236):
			for x in range(240, 331):
				var index := y * block.map_resolution.x + x
				block.working_map._heights[index] = maxf(0.22, block.working_map.fossil.field.ceilings[index] + 0.006)
		block.working_map.image.set_data(1024, 640, false, Image.FORMAT_RF, block.working_map._heights.to_byte_array())
		block.working_map.dirty = true
	if kind in ["clay", "stone", "blower"]:
		# Controlled material slab, outside fossil. Setup excluded from timings.
		for y in range(70, 221):
			for x in range(620, 821):
				var index := y * block.map_resolution.x + x
				block.working_map._heights[index] = 0.55 if kind == "clay" else 0.22
				if kind == "blower": block.working_map.residue.deposit_removed(x, y, 0.65)
				if kind == "blower" and x % 8 == 0 and y % 8 == 0:
					block.working_map.loose_debris.deposit_removed(x, y, 8, 2)
		block.working_map.image.set_data(1024, 640, false, Image.FORMAT_RF, block.working_map._heights.to_byte_array())
		block.working_map.dirty = true
		if kind == "blower": block.working_map.residue.apply_segment(Vector2(620, 140), Vector2(820, 140), 90, 1, 0)
	elif kind == "bone":
		var p := SurfaceMapping.uv_to_map(Vector2(0.28, 0.305), block.map_resolution)
		block.working_map.apply_segment(p, p, 65, 1.15, 1.5, 1)
	block.flush_texture()
	main.feedback.reset()

func scenario(kind: String, zoom: float) -> void:
	controller.reset_surface()
	(camera as PrecisionZoom).reset_view()
	controller._focused = true
	controller._pointer_inside = true
	select(3 if kind.begins_with("pick") else (0 if kind in ["soil", "dirty_idle", "proxy_cavity", "proxy_bone", "dusty_bone"] else (2 if kind == "blower" else 1)))
	prepare_fixture(kind)
	var center := Vector2(0.28, 0.305) if kind in ["bone", "pick", "proxy_bone", "dusty_bone"] else Vector2(0.70, 0.22)
	move_to(center)
	if zoom > 1:
		(camera as PrecisionZoom)._focused = true
		(camera as PrecisionZoom).request_zoom(log(zoom) / log((camera as PrecisionZoom).wheel_step), controller._screen)
	for i in range(90): await physics_frame
	if kind == "blower": await screenshot("p4-dirty-before-%dx" % int(zoom))
	var initial_height := block.working_map.image.get_data()
	var uploads := block.upload_count
	var fracture_uploads := block.fracture_upload_count
	var edits: Array[float] = []
	var active: Array[float] = []
	var picks: Array[float] = []
	var upload_times: Array[float] = []
	var changed := 0
	var marked := 0
	var detached := 0
	frame_times.clear()
	proxy_frame_times.clear()
	peak_particles.fill(0)
	peak_flying = 0
	previous_frame = 0
	measuring = true
	var started := Time.get_ticks_usec()
	press_at(center)
	for tick in range(360):
		await physics_frame
		controller._focused = true
		controller._pointer_inside = true
		controller._held = kind not in ["dirty_idle", "proxy_cavity", "proxy_bone", "dusty_bone"]
		var p := Vector2(655 + (tick / 40 as int % 5) * 29, 115 + (tick / 200 as int) * 32)
		var uv := (p + Vector2.ONE * 0.5) / Vector2(block.map_resolution)
		if kind.ends_with("_dense"):
			# Nine held impacts per position, enough to repeatedly break the hard
			# material instead of mostly marking fresh patches while moving.
			uv = (Vector2(655 + (tick / 120 as int) * 58, 140) + Vector2.ONE * 0.5) / Vector2(block.map_resolution)
		if kind in ["soil", "blower"]: uv = center + Vector2(0.065 * sin(tick / 80.0), 0.07 * cos(tick / 67.0))
		if kind == "bone": uv = center + Vector2(0.012 * sin(tick / 100.0), 0.006 * cos(tick / 90.0))
		# Stationary bursts, then move to the next small remnant.
		if kind.begins_with("pick"): uv = center + Vector2((tick / 60 as int % 3 - 1) * 0.008, (tick / 180 as int) * 0.008)
		if kind == "dusty_bone": uv = center
		if kind == "proxy_cavity": uv = (Vector2(710 + 24 * sin(tick / 15.0), 140 + 24 * cos(tick / 21.0)) + Vector2.ONE * 0.5) / Vector2(block.map_resolution)
		if kind == "proxy_bone": uv = (Vector2(286 + 24 * sin(tick / 15.0), 194 + 24 * cos(tick / 21.0)) + Vector2.ONE * 0.5) / Vector2(block.map_resolution)
		move_to(uv)
		controller._physics_process(1.0 / 60.0)
		edits.append(controller.last_edit_usec / 1000.0)
		if controller.impacts_this_tick > 0 or kind in ["soil", "blower"] or kind.begins_with("pick"): active.append(controller.last_edit_usec / 1000.0)
		picks.append(controller.last_pick_usec / 1000.0)
		upload_times.append((block.last_upload_usec + block.last_residue_upload_usec + block.last_fracture_upload_usec) / 1000.0)
		changed += controller.changed_texels
		if controller.impacts_this_tick > 0:
			marked += block.working_map.last_action.get("marks", 0)
			detached += block.working_map.last_action.get("chunks", []).size()
	measuring = false
	var seconds := (Time.get_ticks_usec() - started) / 1e6
	controller.cancel_stroke()
	var label := "%s_%dx" % [kind, int(zoom)]
	report[label] = {"render_fps": frame_times.size() / seconds, "frame_ms": stats(frame_times),
		"cpu_edit_ms": stats(edits), "cpu_active_edit_ms": stats(active), "cpu_pick_ms": stats(picks), "cpu_proxy_ms": stats(proxy_frame_times),
		"upload_submit_ms": stats(upload_times), "changed_texels": changed, "marks": marked, "chunks": detached,
		"particles_emitted": Array(main.feedback.emitted), "audio_events": main.feedback.audio.played,
		"peak_particles": Array(peak_particles), "peak_flying": peak_flying,
		"loose_bins": block.working_map.loose_debris.cells.size(), "flying_debris": block.working_map.loose_debris.flying.size(),
		"brush_loop_starts": main.feedback.audio.brush_starts,
		"impacts": controller.total_impacts, "height_uploads": block.upload_count - uploads,
		"fracture_uploads": block.fracture_upload_count - fracture_uploads,
		"exposed_cells": block.working_map.fossil.exposed_cells, "condition": block.working_map.fossil.condition,
		"zoom": (camera as PrecisionZoom).zoom_factor}
	check(report[label].render_fps >= 58 and report[label].frame_ms.p95 < 20, "60 FPS budget: " + label)
	check(report[label].render_fps < 242, "cap respected: " + label)
	if kind not in ["dirty_idle", "proxy_cavity", "proxy_bone", "dusty_bone"]: check(main.feedback.audio.played > 0, "audio event routing active: " + label)
	if kind in ["clay", "stone", "clay_dense", "stone_dense"]: check(marked > 0 and detached > 0, "actual marks AND chunks measured: " + label)
	if kind == "blower": check(initial_height == block.working_map.image.get_data() and block.upload_count == uploads, "Blower structural state exact: " + label)
	if kind == "dirty_idle":
		check(initial_height == block.working_map.image.get_data() and block.upload_count == uploads
			and block.working_map.loose_debris.cells.size() == 2322, "fully dirtied resting block is stable: " + label)
	if kind.begins_with("pick"):
		check(changed > 0 and controller.total_impacts == 36 and block.working_map.fossil.condition == 100
			and detached == 0 and marked == 0, "real Pick input removes caps without damage or fracture: " + label)
	if kind.begins_with("proxy_"): check(initial_height == block.working_map.image.get_data() and block.upload_count == uploads, "visual cavity sweep changes no gameplay geometry")
	if kind == "dusty_bone": check(initial_height == block.working_map.image.get_data() and block.working_map.fossil.exposed_cells > 0, "dirty exposed Bone remains stable")
	print("P4 BENCH ", label, " ", JSON.stringify(report[label]))
	await screenshot("p4-" + label)

func comparison_captures() -> void:
	controller.reset_surface()
	(camera as PrecisionZoom).reset_view()
	controller._focused = true
	controller._pointer_inside = true
	select(1)
	prepare_fixture("clay")
	var p := Vector2(710, 140)
	move_to((p + Vector2.ONE * 0.5) / Vector2(block.map_resolution))
	(camera as PrecisionZoom)._focused = true
	(camera as PrecisionZoom).request_zoom(log(3.0) / log((camera as PrecisionZoom).wheel_step), controller._screen)
	for i in range(80): await physics_frame
	controller.refresh_view()
	block.working_map.apply_impact(p, controller.config)
	block.flush_texture()
	controller.refresh_view()
	await screenshot("p4-clay-mark")
	block.working_map.apply_impact(p, controller.config)
	block.flush_texture()
	controller.refresh_view()
	await screenshot("p4-clay-chip")
	prepare_fixture("stone")
	block.working_map.fracture.reset()
	block.working_map.apply_impact(p, controller.config)
	block.flush_texture()
	controller.refresh_view()
	await screenshot("p4-stone-mark")
	for i in range(2): block.working_map.apply_impact(p, controller.config)
	block.flush_texture()
	controller.refresh_view()
	await screenshot("p4-stone-chip")
	check(block.fracture_texture.get_image().get_data() == block.working_map.fracture.image.get_data(), "fracture atlas GPU byte equality")

func cleanup_captures() -> void:
	controller.reset_surface()
	(camera as PrecisionZoom).reset_view()
	var p := Vector2(286, 194)
	block.working_map.apply_segment(p, p, 70, 100, 1.5, 1, Vector3.ONE, 8)
	block.working_map.residue.apply_segment(p, p, 75, 1, 0)
	block.flush_texture()
	var structural := block.working_map.image.get_data()
	var condition := block.working_map.fossil.condition
	move_to((p + Vector2.ONE * 0.5) / Vector2(block.map_resolution))
	(camera as PrecisionZoom)._focused = true
	(camera as PrecisionZoom).request_zoom(30, controller._screen)
	for i in range(90): await physics_frame
	controller.hit = {"inside": false}
	block.show_cursor({"inside": false}, 60)
	main.get_node("Debug/BoneNotice").hide()
	await screenshot("p4-fix-bone-dirty")
	var blower := controller.tools[2]
	for i in range(240):
		var point := p + Vector2(25 * sin(i * 0.03), 15 * cos(i * 0.02))
		block.working_map.apply_continuous(point - Vector2.RIGHT, point, blower, 1.0 / 60.0)
		block.working_map.loose_debris.advance(1.0 / 60.0)
	block.working_map.loose_debris.advance(20)
	block.flush_texture()
	main.feedback._process(4)
	main.feedback.loose_view._process(0)
	await screenshot("p4-fix-bone-clean")
	check(block.working_map.image.get_data() == structural and block.working_map.fossil.condition == condition,
		"dirty/clean bone comparison changes neither geometry nor condition")

func debris_session_captures() -> void:
	# Two controlled exposed slabs, 60 s equivalent Chisel input each, no cleanup.
	# Frame timing is measured separately; only input cadence is simulated here.
	for kind in ["clay", "stone"]:
		controller.reset_surface()
		(camera as PrecisionZoom).reset_view()
		select(1)
		prepare_fixture(kind)
		var p := Vector2(710, 140)
		move_to((p + Vector2.ONE * 0.5) / Vector2(block.map_resolution))
		(camera as PrecisionZoom)._focused = true
		(camera as PrecisionZoom).request_zoom(30, controller._screen)
		for i in range(90): await physics_frame
		for i in range(270):
			var target := p + Vector2((i / 3 as int % 7 - 3) * 12, (i / 21 as int % 3 - 1) * 14)
			block.working_map.apply_impact(target, controller.tools[1])
			main.feedback._process(1.0 / 4.5)
		main.feedback._process(2)
		block.flush_texture()
		main.feedback.loose_view._process(0)
		controller.hit = {"inside": false}
		block.show_cursor({"inside": false}, 12)
		var state := block.working_map.loose_debris
		var small := true
		for i in range(main.feedback.loose_view.keys.size()):
			var basis: Basis = main.feedback.loose_view.multimesh.get_instance_transform(i).basis
			small = small and basis.x.length() <= 0.004501 and basis.y.length() < 0.001441
		check(small and state.cells.size() <= state.occupancy.size() * 2,
			"visible hard cleanup flakes <=4.5 mm remain bounded to two per local bucket")
		var snapshot := block.working_map.image.get_data()
		report["session_" + kind] = {"simulated_seconds": 60, "impacts": 270, "crumbs": state.cells.size(),
			"occupied_buckets": state.occupancy.size(), "peak_dust": Array(block.working_map.residue._values).max()}
		await screenshot("p4-feel-" + kind + "-60s-dirty-3x")
		(camera as PrecisionZoom).reset_view()
		for i in range(90): await physics_frame
		controller.hit = {"inside": false}
		block.show_cursor({"inside": false}, 12)
		main.feedback._process(0)
		await screenshot("p4-feel-" + kind + "-60s-dirty-1x")
		move_to((p + Vector2.ONE * 0.5) / Vector2(block.map_resolution))
		(camera as PrecisionZoom)._focused = true
		(camera as PrecisionZoom).request_zoom(30, controller._screen)
		for i in range(90): await physics_frame
		controller.hit = {"inside": false}
		block.show_cursor({"inside": false}, 12)
		for i in range(240):
			var target := p + Vector2(42 * sin(i * 0.04), 18 * cos(i * 0.02))
			block.working_map.apply_continuous(target - Vector2.RIGHT, target, controller.tools[2], 1.0 / 60.0)
			state.advance(1.0 / 60.0)
		state.advance(20)
		block.flush_texture()
		main.feedback._process(3)
		main.feedback.loose_view._process(0)
		check(snapshot == block.working_map.image.get_data(), "60s dirt cleanup preserves exact geometry")
		report["session_" + kind].crumbs_after_blower = state.cells.size()
		await screenshot("p4-feel-" + kind + "-60s-clean-3x")

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://work/test-logs")
	if DisplayServer.get_name() == "headless":
		push_error("P4 benchmark requires graphical renderer")
		quit(1)
		return
	check(Engine.max_fps == 240 and Engine.physics_ticks_per_second == 60, "normal project runtime settings")
	root.size = Vector2i(1920, 1080)
	root.content_scale_size = Vector2i(1920, 1080)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	# Exercise real mixer/voices without broadcasting repeated test audio.
	AudioServer.set_bus_mute(0, true)
	process_frame.connect(on_frame)
	main = load("res://scenes/prototype_main.tscn").instantiate()
	root.add_child(main)
	block = main.get_node("ExcavationBlock")
	controller = main.get_node("ToolController")
	camera = main.get_node("Camera3D")
	controller.set_physics_process(false)
	main.get_node("Debug/Panel").hide()
	main.get_node("Debug/BonePanel").hide()
	for i in range(90): await physics_frame
	var dense_only := "--dense-only" in OS.get_cmdline_user_args()
	var kinds := ["clay_dense", "stone_dense"] if dense_only else ["soil", "clay", "stone", "bone", "blower", "dirty_idle", "pick", "pick_clay", "pick_stone", "proxy_cavity", "proxy_bone", "dusty_bone", "clay_dense", "stone_dense"]
	for zoom in [1.0, 3.0]:
		for kind in kinds:
			await scenario(kind, zoom)
	if not dense_only:
		await comparison_captures()
		await cleanup_captures()
		await debris_session_captures()
	report["gpu"] = RenderingServer.get_video_adapter_name()
	report["cpu"] = OS.get_processor_name()
	report["engine"] = Engine.get_version_info().string
	report["viewport"] = str(root.size)
	report["stress_atlas_bytes"] = block.working_map.fracture.image.get_data_size()
	report["max_particles"] = block.reactions.particles_per_family * 4
	report["runtime_cap"] = Engine.max_fps
	report["physics_hz"] = Engine.physics_ticks_per_second
	report["failures"] = failures
	FileAccess.open("res://work/test-logs/p4-dense-benchmark.json" if dense_only else "res://work/test-logs/p4-benchmark.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("P4 GRAPHICAL: %d failures" % failures)
	controller.reset_surface()
	main.queue_free()
	# Let the audio thread retire stopped playbacks before the process exits.
	await create_timer(0.4).timeout
	quit(0 if failures == 0 else 1)
