extends "res://tests/run_p5_visual.gd"
## Actual 1080p renderer + P5 UI. 60 Hz input workloads; 240 FPS cap unchanged.
var frame_times: Array[float] = []
var previous_frame := 0
var measuring := false
var results := {}
var benchmark_path := "res://work/test-logs/p5s-benchmark.json"

func on_frame() -> void:
	var now := Time.get_ticks_usec()
	if measuring and previous_frame > 0: frame_times.append((now - previous_frame) / 1000.0)
	previous_frame = now

func stats(values: Array[float]) -> Dictionary:
	if values.is_empty(): return {"mean": 0.0, "p95": 0.0, "max": 0.0}
	var sorted := values.duplicate()
	sorted.sort()
	var sum := 0.0
	for value in values: sum += value
	return {"mean": sum / values.size(), "p95": sorted[int((sorted.size() - 1) * 0.95)], "max": sorted[-1]}

func minimum_window_fps() -> float:
	var elapsed := 0.0
	var frames := 0
	var minimum := INF
	for dt in frame_times:
		elapsed += dt
		frames += 1
		if elapsed >= 1000:
			minimum = minf(minimum, frames * 1000.0 / elapsed)
			elapsed = 0
			frames = 0
	return minimum

func local_fixture(center: Vector2, kind: String) -> void:
	for y in range(int(center.y) - 90, int(center.y) + 91):
		for x in range(int(center.x) - 90, int(center.x) + 91):
			var index := y * surface.size.x + x
			var ceiling := surface.structural_ceilings[index]
			var height := surface.strata.packed_limits[index * 2]
			if kind == "chisel_stone": height = surface.strata.packed_limits[index * 2 + 1] - 0.002
			if kind in ["pick_bone", "progress_updates", "keep_cleaning"]:
				height = ceiling + 0.008 if ceiling > 0 else 0.17
			surface._heights[index] = minf(surface._heights[index], maxf(height, ceiling))
	P5Fixture.commit(surface)

func populate_crumbs(center: Vector2) -> void:
	var dirt := surface.loose_debris
	for y in range(40, 600, 24):
		for x in range(40, 980, 24):
			if dirt.persistent_count() < 128: dirt.deposit_removed(x, y, 16, 1 if x % 48 == 40 else 2)
	var n := 0
	for f in dirt.physics.fragments:
		if not f.active: continue
		var point := center + Vector2((n % 16 - 7.5) * 2, (n / 16 as int - 3.5) * 2)
		var uv := (point + Vector2.ONE * 0.5) / Vector2(surface.size)
		f.position = Vector3((uv.x - 0.5) * main.block.surface_size.x,
			main.block.relief.height_at(uv) + f.size.y * 0.5 + 0.001, (uv.y - 0.5) * main.block.surface_size.y)
		f.velocity = Vector3.ZERO
		f.angular_velocity = 0
		dirt.dirty_cells[f.source] = true
		n += 1
	for tick in range(100): dirt.advance(1.0 / 60)

func scenario(kind: String, zoom: float) -> void:
	main.reset_specimen()
	var center := Vector2(510, 140)
	var tool := 0
	match kind:
		"chisel_clay", "chisel_stone": tool = 1
		"blower_crumbs": tool = 2
		"pick_bone", "progress_updates": tool = 3; center = Vector2(250, 218)
		"brush_film": center = Vector2(250, 218)
		"keep_cleaning": tool = 3; center = Vector2(260, 270)
	if kind in ["completion_card", "fine_preparation", "keep_cleaning", "archive_card"]:
		var percent := 96 if kind == "fine_preparation" else 86
		P5Fixture.reveal(surface, [percent, percent, percent, percent])
		if kind in ["completion_card", "fine_preparation"]:
			# Untimed uniform-film fixture. The timed ordinary Brush stroke crosses the gate.
			var amount := BoneSurfaceFilm.INITIAL * (1 - (84.99 if kind == "completion_card" else 94.99) / 100.0)
			var film := surface.bone_film
			film.dirt_totals.fill(0)
			for index in range(film._values.size()):
				if film._masks[index] == 0: continue
				film._values[index] = amount
				for id in range(5): film.dirt_totals[id] += film._values[index] * film._dirty_counts[index * 5 + id]
				film._encode(index)
			film.cleaned.emit()
			center = Vector2(250, 218)
			film_oracle()
		else:
			P5Fixture.clean(surface)
		session.flush()
		if kind == "keep_cleaning": session.keep_cleaning()
	if kind in ["chisel_clay", "chisel_stone", "pick_bone", "progress_updates", "keep_cleaning"]: local_fixture(center, kind)
	if kind == "brush_film": P5Fixture.reveal(surface, [75, 0, 0, 0])
	if kind == "blower_crumbs": populate_crumbs(center)
	await settle()
	control.select_tool(tool)
	control._focused = true
	control._pointer_inside = true
	point_at(center)
	main.camera._focused = true
	if zoom > 1: main.camera.request_zoom(log(zoom) / log(main.camera.wheel_step), control._screen)
	for i in range(60): await physics_frame
	var before_exposure := surface.fossil.exposed_cells
	var before_clean := surface.bone_film.cleanliness_percent()
	var before_session_refresh := session.refresh_count
	var before_ui_refresh: int = main.session_ui.refresh_count
	var geometry := surface.image.get_data()
	var changed := 0
	var edits: Array[float] = []
	var session_cost: Array[float] = []
	var ui_cost: Array[float] = []
	var seen_refresh := session.refresh_count
	var seen_ui_refresh: int = main.session_ui.refresh_count
	frame_times.clear()
	previous_frame = 0
	measuring = true
	var started := Time.get_ticks_usec()
	for tick in range(360):
		# Isolate native focus notifications from the reproducible held workload.
		var held_elapsed := control.impact_clock.elapsed
		var held_emitted := control.impact_clock.emitted
		await physics_frame
		control.impact_clock.elapsed = held_elapsed
		control.impact_clock.emitted = held_emitted
		control._focused = true
		control._pointer_inside = true
		if kind == "archive_card":
			if tick == 30: session.archive()
		else:
			control._held = true
			var point := center + Vector2(24 * sin(tick / 50.0), 12 * cos(tick / 65.0))
			if kind.begins_with("chisel"): point = center + Vector2((tick / 120 as int - 1) * 24, 0)
			point_at(point)
		control._physics_process(1.0 / 60)
		session.flush()
		changed += control.changed_texels
		edits.append(control.last_edit_usec / 1000.0)
		if seen_refresh != session.refresh_count:
			session_cost.append(float(session.last_refresh_usec))
			seen_refresh = session.refresh_count
		if seen_ui_refresh != main.session_ui.refresh_count:
			ui_cost.append(float(main.session_ui.last_refresh_usec))
			seen_ui_refresh = main.session_ui.refresh_count
	measuring = false
	var seconds := (Time.get_ticks_usec() - started) / 1e6
	control.cancel_stroke()
	var label := "%s_%dx" % [kind, int(zoom)]
	var data := {"render_fps": frame_times.size() / seconds, "min_1s_fps": minimum_window_fps(), "frame_ms": stats(frame_times),
		"edit_ms": stats(edits), "session_cpu_us": stats(session_cost), "ui_cpu_us": stats(ui_cost),
		"session_refreshes": session.refresh_count - before_session_refresh, "ui_refreshes": main.session_ui.refresh_count - before_ui_refresh,
		"changed_cells": changed, "exposure_delta_cells": surface.fossil.exposed_cells - before_exposure,
		"cleanliness_delta": surface.bone_film.cleanliness_percent() - before_clean, "remaining_crumbs": surface.loose_debris.persistent_count(),
		"fine_preparation": session.fine_preparation, "complete": session.preparation_complete, "keep_cleaning": session.keep_cleaning_chosen,
		"seconds": seconds, "zoom": main.camera.zoom_factor, "runtime_cap": Engine.max_fps, "physics_hz": Engine.physics_ticks_per_second}
	check(data.render_fps >= 60 and data.min_1s_fps >= 60 and data.frame_ms.p95 < 1000.0 / 60, "strict sustained 60 FPS: " + label)
	check(Engine.max_fps == 240 and Engine.physics_ticks_per_second == 60, "locked runtime cadence")
	if kind == "completion_card": check(session.preparation_complete and session.can_use_tools() and data.session_refreshes > 0, "native Brush crosses85, updates inline card without blocking")
	elif kind == "fine_preparation": check(session.fine_preparation and main.session_ui.quality_cue_count == 1 and session.can_use_tools(), "native Brush crosses95, glint and quiet sound without interruption")
	elif kind == "archive_card": check(session.archived and main.session_ui.archive_cue_count == 1 and data.ui_refreshes > 0, "archive animation and confirmation included")
	elif kind == "blower_crumbs": check(surface.loose_debris.persistent_count() == 0 and geometry == surface.image.get_data(), "blower clears real crumbs without excavation")
	elif kind == "brush_film": check(data.cleanliness_delta > 0 and data.session_refreshes > 0, "brush cleans film and updates the two bars")
	else:
		check(changed > 0, "real excavation workload " + label)
		if kind in ["progress_updates", "keep_cleaning"]: check(data.exposure_delta_cells > 0 and data.session_refreshes > 0, "new exposure updates P5 " + label)
	results[label] = data
	print("P5 BENCH ", label, " ", JSON.stringify(data))
	FileAccess.open(benchmark_path, FileAccess.WRITE).store_string(JSON.stringify(results, "\t"))

func run() -> void:
	if DisplayServer.get_name() == "headless": quit(1); return
	root.size = Vector2i(1920, 1080)
	root.content_scale_size = root.size
	AudioServer.set_bus_mute(0, true)
	main = load("res://scenes/prototype_main.tscn").instantiate()
	root.add_child(main)
	surface = main.block.working_map
	session = main.session
	control = main.controller
	control.set_physics_process(false)
	process_frame.connect(on_frame)
	var kinds := ["brush_soil", "chisel_clay", "chisel_stone", "pick_bone", "blower_crumbs", "brush_film", "fine_preparation", "completion_card", "keep_cleaning", "progress_updates", "archive_card"]
	for zoom in [1.0, 3.0]:
		for kind in kinds:
			await scenario(kind, zoom)
	results["validation"] = {"checks": checks, "failures": failures}
	FileAccess.open(benchmark_path, FileAccess.WRITE).store_string(JSON.stringify(results, "\t"))
	print("P5 BENCHMARK: %d checks, %d failures" % [checks, failures])
	main.queue_free()
	await process_frame
	session = null
	surface = null
	quit(0 if failures == 0 else 1)
