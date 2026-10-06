extends "res://tests/run_p6a15_soil.gd"
## Reuse lab hashing/capture/camera/timing helpers; geometry gets its own oracles.

func distribution(values: Array[float]) -> Dictionary:
	values.sort()
	var n := values.size()
	return {"min": values[0], "median": (values[(n - 1) / 2] + values[n / 2]) * 0.5,
		"P90": values[ceili(n * 0.90) - 1], "P95": values[ceili(n * 0.95) - 1], "max": values[-1]}

func measure_geometry() -> Dictionary:
	var s: WorkingSurface = main.block.working_map
	var height: Array[float] = []
	var clay: Array[float] = []
	var slopes: Array[float] = []
	var soil: Array[float] = []
	var effort := [[], [], [], [], []]
	var stone := [[], [], [], [], []]
	var gaps: Array[float] = []
	var bad_order := 0
	var flat := 0
	var stepped := 0
	var outside := 0
	for y in range(s.size.y):
		for x in range(s.size.x):
			var i := y * s.size.x + x
			var top := s.strata.packed_limits[i * 2]
			var bottom := s.strata.packed_limits[i * 2 + 1]
			height.append(top * 102)
			clay.append((top - bottom) * 102)
			soil.append((s._heights[i] - top) * 102)
			if bottom <= 0 or top <= bottom: bad_order += 1
			if s._heights[i] > 1 or s._heights[i] < top: outside += 1
			if x < s.size.x - 1 and y < s.size.y - 1:
				var dx: float = (s.strata.packed_limits[(i + 1) * 2] - top) * 0.102 * s.size.x / main.block.surface_size.x
				var dy: float = (s.strata.packed_limits[(i + s.size.x) * 2] - top) * 0.102 * s.size.y / main.block.surface_size.y
				var slope := rad_to_deg(atan(Vector2(dx, dy).length()))
				slopes.append(slope)
				if slope < 6: flat += 1
				if slope > 15: stepped += 1
			var component: int = s.fossil.field.component_ids[i]
			if component == 0: continue
			var ceiling := s.structural_ceilings[i]
			gaps.append((top - ceiling) * 102)
			var work := s.strata.hard_work_to_bone(Vector2(top, bottom), ceiling, 102, main.controller.tools[1])
			var hard := (bottom - ceiling) * 102
			for id in [0, component]:
				effort[id].append(work)
				stone[id].append(hard)
	var populations := []
	for id in range(5):
		var work: Array[float] = []; work.assign(effort[id])
		var hard: Array[float] = []; hard.assign(stone[id])
		populations.append({"component": id, "cells": work.size(), "work": distribution(work), "stone_mm": distribution(hard)})
	return {"height_mm_above_base": distribution(height), "clay_mm": distribution(clay),
		"flat_fraction_under_6deg": float(flat)/slopes.size(), "step_fraction_over_15deg": float(stepped)/slopes.size(),
		"slope_degrees": distribution(slopes), "soil_mm": distribution(soil), "matrix_bone_gap_mm": distribution(gaps),
		"bad_order_cells": bad_order, "invalid_initial_cells": outside, "populations": populations}

func functional() -> void:
	var s: WorkingSurface = main.block.working_map
	var canonical := FossilField.new(s.size)
	var accepted := SoilFoundationProfile.new(s)
	var reference := {}
	evidence["geometry"] = []
	for c in range(2):
		main.select_fixture(0)
		main.select_candidate(c)
		var start := state()
		check(s.fossil.field.image.get_data() == canonical.image.get_data() and s.structural_ceilings == canonical.ceilings,
			"unchanged Bone heights / occupancy / component IDs")
		check(s.fossil.field.component_totals == canonical.component_totals and canonical.total_cells == 32290,
			"same 32290 cells and anatomical totals")
		check(s.fossil.exposed_cells == 0 and s.bone_film.cleanliness_percent() == 0, "zero initial Bone exposure/film")
		if c == 0:
			check(s._heights == accepted.thin_tops[0] and s.strata.packed_limits == accepted.limits[0], "A byte-exact accepted P6A1.5 thin Soil")
		var measured := measure_geometry()
		evidence.geometry.append(measured)
		print("GEOMETRY ", c, " ", JSON.stringify(measured))
		check(measured.bad_order_cells == 0 and measured.invalid_initial_cells == 0, "all-cell valid order / height bounds")
		check(measured.matrix_bone_gap_mm.min > 5 and measured.populations[0].stone_mm.min > 0, "matrix AND Stone interface safely above every Bone ceiling")
		check(measured.soil_mm.min >= 0 and measured.soil_mm.max <= 2.00002, "accepted bounded Soil conforms")
		if c == 0: reference = measured
		else:
			check(measured.populations[0].work.P95 <= 180 and measured.populations[0].work.max <= 205,
				"existing absolute P4 effort budgets: P95<=180 / max<=205")
			check(measured.populations[0].stone_mm.P95 <= 18 and measured.populations[0].stone_mm.max <= 22,
				"existing hard material budget: P95<=18 mm / max<=22 mm")
			for id in range(5):
				for metric in ["median", "P90", "P95", "max"]:
					check(measured.populations[id].work[metric] <= reference.populations[id].work[metric] * 1.10,
						"no anatomical work inflation >10%%: %d %s" % [id, metric])
			check(measured.slope_degrees.P95 > reference.slope_degrees.P95 * 1.5 and measured.slope_degrees.max < 60,
				"bounded macro slopes for the structured geometry trial")
			check(measured.flat_fraction_under_6deg > .55 and measured.step_fraction_over_15deg > .08,
				"broad interiors plus readable step faces, not uniformly rolling terrain")
			# Structured steps need ~11 mm sampling; the former 34 mm sampling
			# only represented soft lobes. Keep submillimeter reconstruction error.
			var coarse := Image.create(97, 61, false, Image.FORMAT_RF)
			for y in range(61):
				for x in range(97): coarse.set_pixel(x, y, Color(NaturalMatrixProfile.offsets_mm(Vector2(x / 96.0, y / 60.0)).x, 0, 0))
			var error2 := 0.0
			var samples := 0
			var low := INF
			var high := -INF
			for y in range(3, s.size.y, 11):
				for x in range(3, s.size.x, 11):
					var uv := Vector2(x, y) / Vector2(s.size)
					var delta := NaturalMatrixProfile.offsets_mm(uv).x
					var filtered := ReliefSurface.sample_image(coarse, (uv * Vector2(96, 60) + Vector2.ONE * 0.5) / Vector2(97, 61)).r
					error2 += pow(delta - filtered, 2)
					samples += 1
					low = minf(low, delta); high = maxf(high, delta)
			var rms := sqrt(error2 / samples)
			check(rms < 0.35 and high - low >= 18, "coarse field explains structured >=18 mm forms, RMS <0.35 mm")
			evidence["macro"] = {"coarse_grid": [97,61], "rms_mm": rms, "offset_min_mm": low, "offset_max_mm": high}
			var max_soil_delta := 0.0
			for i in range(s._heights.size()):
				max_soil_delta = maxf(max_soil_delta, absf((s._heights[i] - s.strata.packed_limits[i*2]) - (accepted.thin_tops[0][i] - accepted.substrates[0][i])) * 102)
			check(max_soil_delta < 0.00002, "exact same Soil quantity translated onto B (RF tolerance)")
		# Same native Brush crossing relief, no structural Clay excavation.
		brush_pass()
		check(soil_line_count() == 0, "Brush clears Soil over relief")
		var below := 0
		for i in range(s._heights.size()):
			if s._heights[i] < s.strata.packed_limits[i * 2]: below += 1
		check(below == 0, "Brush stops on the actual matrix")
		main.reset_specimen()
		check(state() == start, "deterministic full reset")
		main.show_substrate()
		var before := state()
		var uploads: int = main.block.upload_count
		await settle(120)
		check(main.profile.build_count == 1 and state() == before and uploads == main.block.upload_count, "no idle profile reconstruction or uploads")
		for f in [2,3,4]:
			main.select_fixture(f)
			var fixture_state := state()
			check(fixture_state.height != before.height, "fixture edits real geometry " + str(f))
			var illegal := 0
			var bad_exposure := 0
			for i in range(s._heights.size()):
				if s._heights[i] < s.structural_ceilings[i]: illegal += 1
				if s.structural_ceilings[i] > 0:
					var exposed := s._heights[i] <= s.structural_ceilings[i] + FossilField.EXPOSURE_EPSILON
					if exposed != (s.fossil.exposed[i] != 0): bad_exposure += 1
			check(illegal == 0 and bad_exposure == 0, "ceilings/exposure exact after native preparation/cut")
			if f == 3: check(s.fossil.exposed_cells > 600 and s.fossil.condition == 100, "native Pick opens Bone safely")
			main.reload()
			check(state() == fixture_state, "deterministic prepared fixture " + str(f))
		# Integration with real P5 latch/archive after a test-only fully prepared state.
		main.reset_specimen()
		P5Fixture.reveal(s, [100,100,100,100])
		P5Fixture.clean(s)
		main.session.flush()
		check(main.session.preparation_complete and main.session.fine_preparation and main.session.can_use_tools(), "P5 85/95 milestones still active")
		check(main.session.archive() and not main.session.can_use_tools(), "P5 archive locks tools")
		main.reset_specimen()
		check(state() == start and main.session.can_use_tools(), "reset rearms P5 and geometry")
	check(Engine.max_fps == 240 and Engine.physics_ticks_per_second == 60, "unchanged runtime cadence")
	var expected := [Vector3(40,.70,1.25),Vector3(22,.64,2.25),Vector3(60,0,1),Vector3(11,.44,1.75)]
	for i in range(4):
		var t: ToolDefinition = main.controller.tools[i]
		check(Vector3(t.radius,t.power,t.falloff).is_equal_approx(expected[i]), "locked tool "+str(i))
	# Rebuild independently and prove bit determinism (no previous-frame state).
	# Fresh canonical geology, deliberately WITHOUT a FossilField: geometry must
	# be independent of Bone input as well as independent of previous frames.
	var independent := WorkingSurface.new(s.size, Stratigraphy.new(s.size, main.block.material_definitions))
	var rebuilt := NaturalMatrixProfile.new(independent)
	check(rebuilt.limits[1] == main.profile.limits[1] and rebuilt.thin_tops[1] == main.profile.thin_tops[1], "independent deterministic geometry build")
	evidence["profile_build_usec"] = main.profile.build_usec

func visual() -> void:
	main.panel.hide()
	var poses := {}
	for f in range(5):
		for zoom in ([1,3] if f != 0 else [1]):
			for c in range(2):
				main.select_fixture(f)
				main.select_candidate(c)
				await zoom_to(zoom, Vector2(275,250) if f == 3 else (Vector2(785,180) if f == 4 else Vector2(435,235)))
				var key := "%d-%d" % [f,zoom]
				if c == 0: poses[key] = [main.camera.global_transform,main.camera.size]
				else:
					main.camera.global_transform = poses[key][0]
					main.camera.size = poses[key][1]
				await capture("state%d-%s-%dx" % [f,["A","B"][c],zoom])
				if f == 1:
					main.set_patina(false)
					await capture("matrix-%s-%dx-no-patina" % [["A","B"][c],zoom])
					main.set_patina(true)
				check(main.camera.global_transform == poses[key][0] and main.camera.size == poses[key][1], "identical capture camera")
	main.reset_specimen()
	await zoom_to(1)
	main.panel.show()
	await capture("controls-B")
	main.panel.hide()
	await gpu_picking()

func gpu_picking() -> void:
	# Read back the SAME vertex function. Three 6-bit midtone channels avoid
	# Compatibility's known near-black conversion loss (see surface_debug).
	var diagnostic := Shader.new()
	var vertex_code: String = main.soil_shader.code.get_slice("void fragment()",0)
	diagnostic.code = vertex_code + """
void fragment() {
 float h = floor(clamp(surface_height, 0.0, 1.0) * 262143.0 + 0.5);
 ALBEDO = vec3(0.0);
 SPECULAR = 0.0;
 EMISSION = is_skirt ? vec3(0.0) : (vec3(floor(h / 4096.0), mod(floor(h / 64.0), 64.0), mod(h, 64.0)) + vec3(64.0, 128.0, 192.0)) / 255.0;
}
"""
	var oracle = preload("res://tests/natural_matrix_mesh_oracle.gd")
	var rays := 0
	var max_error_mm := 0.0
	var worst := {}
	var raw_max_mm := 0.0
	var adjusted := 0
	var native_max_mm := 0.0
	var native_rays := 0
	main.session_ui.root_control.hide()
	main.panel.hide()
	main.feedback.hide()
	main.get_node("Debug").hide()
	for c in range(2):
		for f in [0,1,2,3]:
			main.select_fixture(f)
			main.select_candidate(c)
			for zoom in [1,3]:
				await zoom_to(zoom,Vector2(275,250) if f == 3 else Vector2(435,235))
				for mat in [main.block.material,main.block.skirt_material]: mat.shader = diagnostic
				await settle(3)
				await RenderingServer.frame_post_draw
				var pic := root.get_texture().get_image()
				for y in range(180,930,29):
					for x in range(300,1530,31):
						var pixel := pic.get_pixel(x,y)
						if pixel.r < .249 or pixel.r > .50 or pixel.g < .50 or pixel.g > .75 or pixel.b < .75: continue
						var hit: Dictionary = main.block.pick(Vector2(x+.5,y+.5),main.camera)
						if not hit.inside: continue
						var height := ((roundf(pixel.r*255)-64)*4096+(roundf(pixel.g*255)-128)*64+roundf(pixel.b*255)-192)/262143.0
						var error: float = absf(height-hit.height)*102
						raw_max_mm = maxf(raw_max_mm,error)
						if error > .01:
							var alternative := nearby_height_error(Vector2(x+.5,y+.5),height)
							if alternative < error:
								error = alternative
								adjusted += 1
						if error > max_error_mm:
							max_error_mm = error
							var native: float = oracle.height(main.block,main.camera,Vector2(x+.5,y+.5))
							native_max_mm = maxf(native_max_mm,absf(native-hit.height)*102)
							native_rays += 1
							worst = {"native":native,"candidate":c,"fixture":f,"zoom":zoom,"screen":[x,y],"gpu":height,"cpu":hit.height,"rgb":str(pixel)}
						rays += 1
				for mat in [main.block.material,main.block.skirt_material]: mat.shader = main.soil_shader
	check(rays > 10000 and max_error_mm < .01, "GPU triangles vs CPU picking <0.01 mm on >10000 rays")
	check(native_rays > 0 and native_max_mm < .005,"independent native mesh oracle <5 micrometers on successive worst GPU rays")
	evidence["gpu_pick"] = {"rays":rays,"max_error_mm":max_error_mm,"raw_max_mm":raw_max_mm,
		"raster_probes":adjusted,"spatial_tolerance_texels":.01,"height_quantization_mm":102.0/262143,"worst":worst,
		"native_rays":native_rays,"native_max_mm":native_max_mm}
	print("GPU PICK ",JSON.stringify(evidence.gpu_pick))

func nearby_height_error(screen: Vector2, height: float) -> float:
	# P3/P4's existing +/-0.01-texel raster tolerance, never a height relaxation.
	var b: ExcavationBlock = main.block
	var origin: Vector2 = main.camera.unproject_position(b.to_global(Vector3.ZERO))
	var sx: Vector2 = main.camera.unproject_position(b.to_global(Vector3(b.surface_size.x/b.map_resolution.x,0,0))) - origin
	var sy: Vector2 = main.camera.unproject_position(b.to_global(Vector3(0,0,b.surface_size.y/b.map_resolution.y))) - origin
	var best := INF
	for y in range(-4,5):
		for x in range(-4,5):
			var hit: Dictionary = b.pick(screen + (sx*x+sy*y)*.0025, main.camera)
			if hit.inside: best = minf(best,absf(height-hit.height)*102)
	return best

func benchmark() -> void:
	RenderingServer.viewport_set_measure_render_time(root.get_viewport_rid(), true)
	process_frame.connect(sample_frame)
	main.panel.hide()
	var poses := {}
	var fixtures := {"start_idle":0,"matrix_idle":1,"brush":0,"chisel":1,"pick":1,"blower":2,"bone_brush":3}
	var tools_by_kind := {"start_idle":0,"matrix_idle":0,"brush":0,"chisel":1,"pick":3,"blower":2,"bone_brush":0}
	for zoom in [1,3]:
		for kind in fixtures:
			for c in range(2):
				main.select_fixture(fixtures[kind])
				main.select_candidate(c)
				main.controller.select_tool(tools_by_kind[kind])
				var center := Vector2(270,244) if kind == "bone_brush" else Vector2(470,255)
				await zoom_to(zoom,center)
				var key: String = str(zoom)+kind
				if c == 0: poses[key] = [main.camera.global_transform,main.camera.size]
				else:
					main.camera.global_transform = poses[key][0]
					main.camera.size = poses[key][1]
				await settle(45)
				main.controller.cancel_stroke()
				var initial := state()
				frames.clear();gpu.clear();render_cpu.clear();previous = 0
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
					main.controller._held = not kind.ends_with("idle")
					main.controller._screen = at(center+Vector2(sin(tick*.026)*28,cos(tick*.02)*12))
					main.controller._physics_process(1.0/60)
					main.session.flush()
					edits.append(main.controller.last_edit_usec/1000.0)
					picks.append(main.controller.last_pick_usec/1000.0)
				measuring = false
				main.controller.cancel_stroke()
				var row := {"candidate":c,"kind":kind,"zoom":zoom,"frame_ms":stats(frames),"gpu_ms":stats(gpu),
					"render_cpu_ms":stats(render_cpu),"edit_ms":stats(edits),"pick_ms":stats(picks),
					"initial":initial,"final":state(),"camera":str(main.camera.global_transform),"camera_size":main.camera.size,
					"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)}
				evidence.benchmark.append(row)
				check(row.frame_ms.p95 < 16.667 and row.gpu_ms.mean > 0,"representative timing "+key+str(c))
				check(main.camera.global_transform == poses[key][0] and main.camera.size == poses[key][1],"same benchmark framing")
				check(row.final.bone == initial.bone and row.final.ceilings == initial.ceilings,"immutable Bone during benchmark")
				print("MATRIX BENCH ",key," ",c," ",JSON.stringify({"frame":row.frame_ms,"gpu":row.gpu_ms,"edit":row.edit_ms}))
				FileAccess.open(out+"benchmark.json",FileAccess.WRITE).store_string(JSON.stringify(evidence,"\t"))

func run() -> void:
	out = "res://work/test-logs/p6a16-structured/"
	var args := OS.get_cmdline_user_args()
	var mode := args[0] if not args.is_empty() else "tests"
	DirAccess.make_dir_recursive_absolute(out)
	root.size = Vector2i(1920,1080)
	root.content_scale_size = root.size
	evidence["runtime"] = {"engine":Engine.get_version_info().string,"cpu":OS.get_processor_name(),
		"gpu":RenderingServer.get_video_adapter_name(),"renderer":RenderingServer.get_current_rendering_method(),
		"viewport":[1920,1080],"fps_cap":Engine.max_fps,"physics_hz":Engine.physics_ticks_per_second}
	AudioServer.set_bus_mute(0,true)
	main = load("res://scenes/p6a16_natural_matrix_lab.tscn").instantiate()
	root.add_child(main)
	main.controller.set_physics_process(false)
	await settle()
	if mode == "tests": await functional()
	elif mode == "preview":
		main.panel.hide()
		for c in range(2):
			main.select_fixture(1)
			main.select_candidate(c)
			await zoom_to(1)
			main.set_patina(false)
			await capture("preview-%s" % ["A","B"][c])
	elif mode == "visual": await visual()
	elif mode == "picking": await gpu_picking()
	elif mode == "benchmark": await benchmark()
	evidence["checks"] = checks; evidence["failures"] = failures
	FileAccess.open(out+mode+".json",FileAccess.WRITE).store_string(JSON.stringify(evidence,"\t"))
	print("P6A16 ",mode,": ",checks," checks, ",failures.size()," failures")
	main.queue_free()
	await create_timer(.5).timeout
	quit(0 if failures.is_empty() else 1)
