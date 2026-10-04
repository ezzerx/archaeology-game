extends SceneTree
## Full-map invariants against the frozen P4 authoring, plus production fracture.

const P4 = preload("res://tests/fixtures/p4_fossil_field.gd")
const PROFILE = preload("res://scripts/block_verticality_profile.gd")
const ZONES := [Vector2i(250, 230), Vector2i(510, 307), Vector2i(646, 441)]
const DEPTH_MM := 102.0
var definitions: Array[MaterialDefinition] = [preload("res://config/loose_soil.tres"),
	preload("res://config/compact_clay.tres"), preload("res://config/sandstone.tres")]
var reactions: ReactionProfile = preload("res://config/material_reactions.tres")
var chisel: ToolDefinition = preload("res://config/chisel.tres")
var checks := 0
var failures := 0
var report := {}
var strata: Stratigraphy
var field: FossilField

func _initialize() -> void: call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("P4V FAIL: " + message)

func digest(bytes: PackedByteArray) -> String:
	var hash_context := HashingContext.new()
	hash_context.start(HashingContext.HASH_SHA256)
	hash_context.update(bytes)
	return hash_context.finish().hex_encode()

func validate_maps(size: Vector2i) -> void:
	var started := Time.get_ticks_usec()
	var layers := Stratigraphy.new(size, definitions)
	var layer_build_ms := (Time.get_ticks_usec() - started) / 1000.0
	started = Time.get_ticks_usec()
	var bones := FossilField.new(size)
	var bone_build_ms := (Time.get_ticks_usec() - started) / 1000.0
	var old := P4.new(size)
	check(bones.component_ids == old.component_ids, "P4 IDs / 2D silhouette byte exact: %s" % size)
	check(bones.component_totals == old.component_totals and bones.total_cells == old.total_cells,
		"P4 component totals and union unchanged: %s" % size)
	check(bones.ceilings != old.ceilings, "ceilings actually changed: %s" % size)
	var twin := Stratigraphy.new(size, definitions)
	var bone_twin := FossilField.new(size)
	check(layers.boundaries.get_data() == twin.boundaries.get_data(), "new instance / layers exact: %s" % size)
	check(bones.image.get_data() == bone_twin.image.get_data(), "new instance / fossil exact: %s" % size)
	check(layers.packed_limits == layers.boundaries.get_data().to_float32_array(), "packed / image exact: %s" % size)
	var soil_range := Vector2(INF, -INF)
	var clay_range := Vector2(INF, -INF)
	var old_depth := Vector2(INF, -INF)
	var new_depth := Vector2(INF, -INF)
	var separation := INF
	var max_offset_error := 0.0
	var valid := true
	var minimums := true
	var legal := true
	var max_layer_step := 0.0
	var max_offset_step := 0.0
	var max_offset_curvature := 0.0
	for y in range(size.y):
		for x in range(size.x):
			var index := y * size.x + x
			var upper := layers.packed_limits[index * 2]
			var lower := layers.packed_limits[index * 2 + 1]
			var uv := (Vector2(x, y) + Vector2.ONE * 0.5) / Vector2(size)
			valid = valid and 1 > upper and upper > lower and lower > 0
			minimums = minimums and 1 - upper >= PROFILE.MIN_SOIL_THICKNESS - 1e-7 \
				and upper - lower >= PROFILE.MIN_CLAY_THICKNESS - 1e-7 and lower >= PROFILE.MIN_STONE_THICKNESS - 1e-7
			soil_range = Vector2(minf(soil_range.x, 1 - upper), maxf(soil_range.y, 1 - upper))
			clay_range = Vector2(minf(clay_range.x, upper - lower), maxf(clay_range.y, upper - lower))
			if bones.component_ids[index] != 0:
				var ceiling := bones.ceilings[index]
				legal = legal and ceiling > 0 and ceiling < 1 and ceiling >= PROFILE.MIN_BONE_CEILING - 1e-7
				separation = minf(separation, upper - ceiling)
				max_offset_error = maxf(max_offset_error, absf(ceiling - old.ceilings[index] - PROFILE.burial_offset(uv)))
				old_depth = Vector2(minf(old_depth.x, 1 - old.ceilings[index]), maxf(old_depth.y, 1 - old.ceilings[index]))
				new_depth = Vector2(minf(new_depth.x, 1 - ceiling), maxf(new_depth.y, 1 - ceiling))
			else:
				legal = legal and bones.ceilings[index] == 0
			# Check the added field, not anatomical dome edges / gaps between bones.
			if x > 0 and y > 0:
				for delta: Vector2i in [Vector2i(1, 0), Vector2i(0, 1)]:
					var neighbour := index - delta.x - delta.y * size.x
					max_layer_step = maxf(max_layer_step, maxf(absf(upper - layers.packed_limits[neighbour * 2]),
						absf(lower - layers.packed_limits[neighbour * 2 + 1])))
					var step := Vector2(delta) / Vector2(size)
					max_offset_step = maxf(max_offset_step, absf(PROFILE.burial_offset(uv) - PROFILE.burial_offset(uv - step)))
					max_offset_curvature = maxf(max_offset_curvature, absf(PROFILE.burial_offset(uv + step)
						- 2 * PROFILE.burial_offset(uv) + PROFILE.burial_offset(uv - step)))
	check(valid and minimums, "every cell has ordered interfaces and minimum thickness: %s" % size)
	check(legal and separation >= PROFILE.BONE_SOIL_GAP - 1e-7, "every bone reachable above floor, below Soil: %s" % size)
	check(max_offset_error < 1e-7, "same additive burial offset; safety clamps inactive: %s" % size)
	var scale := 1024.0 / size.x
	check(max_layer_step < 0.0025 * scale and max_offset_step < 0.0006 * scale
		and max_offset_curvature < 0.000008 * scale * scale, "broad smooth fields, no cell noise: %s" % size)
	check(soil_range.x * DEPTH_MM <= 20 and soil_range.y * DEPTH_MM >= 40,
		"Soil has substantial shallow AND deep regions: %s" % size)
	check(clay_range.x * DEPTH_MM <= 15 and clay_range.y * DEPTH_MM >= 35,
		"Clay has substantial thin AND thick regions: %s" % size)
	check(new_depth.x * DEPTH_MM >= 52 and new_depth.x * DEPTH_MM <= 60 \
		and new_depth.y * DEPTH_MM >= 80 and new_depth.y * DEPTH_MM <= 89 \
		and (new_depth.y - new_depth.x) * DEPTH_MM >= 25,
		"Bone spans a meaningful 25+ mm range near target band: %s" % size)
	var surface := WorkingSurface.new(size, layers, bones)
	var layer_bytes := layers.boundaries.get_data()
	var bone_bytes := bones.image.get_data()
	surface.apply_segment(Vector2.ZERO, Vector2(size), size.x, 1000, 1, 1)
	check(surface.fossil.exposed_cells == bones.total_cells and surface.fossil.component_exposed == bones.component_totals,
		"every component fully exposable through production edit path: %s" % size)
	surface.reset()
	check(layer_bytes == layers.boundaries.get_data() and bone_bytes == bones.image.get_data(), "reset preserves static maps exactly: %s" % size)
	check(surface.fossil.exposed_cells == 0 and surface.fossil.condition == 100, "reset hides B-17 at original depths: %s" % size)
	report[str(size)] = {"soil_mm": [soil_range.x * DEPTH_MM, soil_range.y * DEPTH_MM], "clay_mm": [clay_range.x * DEPTH_MM, clay_range.y * DEPTH_MM],
		"bone_before_mm": [old_depth.x * DEPTH_MM, old_depth.y * DEPTH_MM], "bone_after_mm": [new_depth.x * DEPTH_MM, new_depth.y * DEPTH_MM],
		"component_totals_before": Array(old.component_totals), "component_totals_after": Array(bones.component_totals),
		"fossil_cells": bones.total_cells, "ids_sha256": digest(bones.component_ids),
		"layers_sha256": digest(layer_bytes), "fossil_sha256": digest(bone_bytes),
		"soil_bone_gap_min_mm": separation * DEPTH_MM, "max_offset_error": max_offset_error,
		"max_layer_step": max_layer_step, "max_offset_step": max_offset_step, "max_offset_curvature": max_offset_curvature,
		"layer_build_ms": layer_build_ms, "fossil_build_ms": bone_build_ms}
	if size == Vector2i(1024, 640):
		strata = layers
		field = bones

func test_resolution() -> void:
	var max_error := 0.0
	var max_burial_error := 0.0
	for size in [Vector2i(512, 320), Vector2i(256, 160)]:
		var lower := Stratigraphy.new(size, definitions)
		for y in range(1, 20):
			for x in range(1, 20):
				var uv := Vector2(x, y) / 20.0
				var a := strata.sample_limits(uv)
				var b := lower.sample_limits(uv)
				max_error = maxf(max_error, maxf(absf(a.x - b.x), absf(a.y - b.y)))
		var bones := FossilField.new(size)
		var old := P4.new(size)
		for zone in ZONES:
			var uv := (Vector2(zone) + Vector2.ONE * 0.5) / Vector2(1024, 640)
			var observed_offset := ReliefSurface.sample_image(bones.image, uv).r - ReliefSurface.sample_image(old.image, uv).r
			max_burial_error = maxf(max_burial_error, absf(observed_offset - PROFILE.burial_offset(uv)))
	check(max_error < 0.00008, "361 normalized UV samples at 1024 / 512 / 256: layers within 0.0082 mm")
	check(max_burial_error < 0.00008, "burial field independent of resolution inside real bones")
	report["resolution"] = {"max_layer_error": max_error, "max_burial_offset_error": max_burial_error, "tolerance": 0.00008}

func test_zones() -> void:
	var rows := []
	for zone: Vector2i in ZONES:
		var index := zone.y * field.size.x + zone.x
		var limits := strata.boundaries.get_pixelv(zone)
		check(field.component_ids[index] != 0, "human test zone lies on real B-17: %s" % zone)
		rows.append({"cell": [zone.x, zone.y], "component": FossilField.COMPONENT_NAMES[field.component_ids[index]],
			"soil_mm": (1 - limits.r) * DEPTH_MM, "clay_mm": (limits.r - limits.g) * DEPTH_MM,
			"bone_mm": (1 - field.ceilings[index]) * DEPTH_MM,
			"sandstone_mm": maxf(0, limits.g - field.ceilings[index]) * DEPTH_MM})
	check(rows[0].soil_mm < 21 and rows[2].soil_mm > 39 and rows[1].soil_mm > rows[0].soil_mm + 8,
		"A / B / C offer clearly different Soil paths")
	# V1.1 redistributes Stone into Clay at A/C; the old >10 mm central contrast
	# would require preserving the excessive Stone columns this pass removes.
	check(rows[1].clay_mm > rows[0].clay_mm + 1 and rows[0].clay_mm > rows[2].clay_mm + 2,
		"Clay still varies independently of the progressively deeper Bone")
	check(rows[1].bone_mm > rows[0].bone_mm + 7 and rows[2].bone_mm > rows[1].bone_mm + 7,
		"real Bone centers are progressively deeper in A / B / C")
	check(rows[0].sandstone_mm > rows[1].sandstone_mm + 5 \
		and rows[2].sandstone_mm > rows[1].sandstone_mm + 5, "hard matrix above Bone is not constant")
	report["zones"] = rows

func test_fracture() -> void:
	var surface := WorkingSurface.new(field.size, strata, field, reactions)
	var cases := []
	# Local layer slabs exercise both real thin/thick clay, shallow/deep stone,
	# and horizontal cavities intersecting sloping Soil/Clay and Clay/Stone.
	for spec in [{"point": ZONES[0], "mode": "clay"}, {"point": Vector2i(543, 192), "mode": "clay"},
		{"point": ZONES[0], "mode": "stone"}, {"point": ZONES[2], "mode": "stone"},
		{"point": Vector2i(440, 320), "mode": "soil_interface"}, {"point": Vector2i(610, 295), "mode": "clay_interface"}]:
		surface.reset()
		var point: Vector2i = spec.point
		var center := strata.boundaries.get_pixelv(point)
		for y in range(point.y - 30, point.y + 31):
			for x in range(point.x - 30, point.x + 31):
				var i := y * field.size.x + x
				var h := strata.packed_limits[i * 2] - 0.01 if spec.mode == "clay" else strata.packed_limits[i * 2 + 1] - 0.002
				if spec.mode == "soil_interface": h = center.r
				if spec.mode == "clay_interface": h = center.g
				surface._heights[i] = maxf(field.ceilings[i] + 0.001, h)
		surface.image.set_data(field.size.x, field.size.y, false, Image.FORMAT_RF, surface._heights.to_byte_array())
		var valid := true
		var chunks := 0
		var changed := 0
		var start_layers := {}
		for hit in range(8):
			var before := surface._heights.duplicate()
			changed += surface.apply_impact(Vector2(point), chisel)
			chunks += surface.fracture.last_chunks.size()
			for y in range(point.y - 24, point.y + 25):
				for x in range(point.x - 24, point.x + 25):
					var i := y * field.size.x + x
					var limits := Vector2(strata.packed_limits[i * 2], strata.packed_limits[i * 2 + 1])
					var layer := Stratigraphy.index_at(before[i], limits)
					if hit == 0: start_layers[layer] = true
					var floor_value := maxf(field.ceilings[i], limits.x if layer == 0 else (limits.y if layer == 1 else 0.0))
					valid = valid and surface._heights[i] >= minf(before[i], floor_value) - 1e-7 and surface._heights[i] <= before[i]
		check(valid and changed > 0 and chunks > 0, "fracture respects every local interface + Bone: %s at %s" % [spec.mode, point])
		if spec.mode.ends_with("interface"):
			check(start_layers.size() >= 2, "inclined-interface fixture actually spans materials: " + spec.mode)
		cases.append({"cell": [point.x, point.y], "mode": spec.mode, "changed_cells": changed, "chunks": chunks, "initial_layers": start_layers.keys()})
	report["fracture"] = cases

func test_debug() -> void:
	root.size = Vector2i(1920, 1080)
	var main := load("res://scenes/prototype_main.tscn").instantiate() as Node3D
	root.add_child(main)
	main.controller.set_physics_process(false)
	for cell in [ZONES[0], ZONES[2], Vector2i(80, 80)]:
		var uv := (Vector2(cell) + Vector2.ONE * 0.5) / Vector2(field.size)
		var local := Vector3((uv.x - 0.5) * main.block.surface_size.x, main.block.thickness, (uv.y - 0.5) * main.block.surface_size.y)
		var hit: Dictionary = main.block.pick(main.camera.unproject_position(main.block.to_global(local)), main.camera)
		var label: String = main.verticality_debug(hit)
		check(label.contains("Current Material: Loose Soil") and label.contains("Soil thickness:") and label.contains("Clay thickness:"), "F1 actual cursor layer diagnostics")
		check(label.contains("Bone depth from intact top:") if hit.bone else label.contains("Bone depth: —"), "F1 Bone depth or empty marker")
		check(label.contains("Hard work index (above Bone): ") and (not label.ends_with("—") if hit.bone else label.ends_with("—")),
			"F1 relative hard-work metric or empty marker")
		if hit.bone:
			main.block.working_map.apply_segment(Vector2(cell), Vector2(cell), 12, 100, 1, 1)
			local.y = main.block.relief.height_at(uv)
			hit = main.block.pick(main.camera.unproject_position(main.block.to_global(local)), main.camera)
			check(main.verticality_debug(hit).contains("Current Material: Bone"), "F1 reports exposed Bone, not underlying matrix")
	await native_mesh_oracle(main)
	main.free()
	await process_frame

func native_mesh_oracle(main: Node3D) -> void:
	# Independent native PlaneMesh topology + float64 plane intersection on
	# the exact grazing rays seen by the GPU oracle, including a 0.25-height jump.
	# No use of ReliefSurface.vertex_at/intersect_triangle to construct the oracle.
	var block: ExcavationBlock = main.block
	var camera: PrecisionZoom = main.camera
	# Fixed time steps make these precision rays independent of OS scheduling.
	camera.set_process(false)
	main.controller.reset_surface()
	block.working_map.apply_segment(Vector2(295, 365), Vector2(745, 365), 220, 1000, 1.5, 1)
	var arrays := (block.surface.mesh as PlaneMesh).get_mesh_arrays()
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	check(uvs[0] == Vector2.ONE and uvs[-1] == Vector2.ZERO, "native PlaneMesh enumerates cells from UV (1,1)")
	var worst := 0.0
	var native_grid_drift := 0.0
	var rays := 0
	for zoom in [1.0, 3.0]:
		camera.reset_view()
		if zoom == 3:
			var uv := Vector2(0.28, 0.305)
			var anchor := Vector3((uv.x - 0.5) * block.surface_size.x, block.relief.height_at(uv), (uv.y - 0.5) * block.surface_size.y)
			camera._focused = true
			camera.request_zoom(log(zoom) / log(camera.wheel_step), camera.unproject_position(block.to_global(anchor)))
			for i in range(90): camera._process(1.0 / 60.0)
		check(absf(camera.zoom_factor - zoom) < 0.001, "native mesh oracle reaches requested %sx zoom" % zoom)
		for pixel: Vector2 in [Vector2(996.5, 414.5), Vector2(1101.5, 558.5), Vector2(1161.5, 690.5),
			Vector2(780.5, 450.5), Vector2(810.5, 519.5)]:
			var origin := camera.project_ray_origin(pixel)
			var direction := camera.project_ray_normal(pixel)
			var top := origin + direction * ((block.thickness - origin.y) / direction.y)
			var floor_point := origin + direction * ((block.base_height - origin.y) / direction.y)
			var start := SurfaceMapping.local_to_uv(top, block.surface_size) * Vector2(block.map_resolution)
			var end := SurfaceMapping.local_to_uv(floor_point, block.surface_size) * Vector2(block.map_resolution)
			var low := (Vector2i(start.min(end).floor()) - Vector2i.ONE * 2).max(Vector2i.ZERO)
			var high := (Vector2i(start.max(end).ceil()) + Vector2i.ONE * 2).min(block.map_resolution - Vector2i.ONE)
			var nearest := Vector3.INF
			var distance := INF
			for y in range(low.y, high.y + 1):
				for x in range(low.x, high.x + 1):
					var native_cell := (block.map_resolution.y - 1 - y) * block.map_resolution.x + block.map_resolution.x - 1 - x
					for triangle in range(2):
						var points: Array[Vector3] = []
						for corner in range(3):
							var vi := indices[native_cell * 6 + triangle * 3 + corner]
							var vertex := vertices[vi]
							var corrected_xz := (uvs[vi] - Vector2.ONE * 0.5) * block.surface_size
							native_grid_drift = maxf(native_grid_drift, Vector2(vertex.x, vertex.z).distance_to(corrected_xz))
							# Production shader anchors X/Z to UV, removing the native
							# accumulated grid drift. Topology/UV still come from Godot.
							vertex.x = (uvs[vi].x - 0.5) * block.surface_size.x
							vertex.z = (uvs[vi].y - 0.5) * block.surface_size.y
							# Bilinear scalar oracle, independent of production sampling.
							var p := (uvs[vi] * Vector2(block.map_resolution) - Vector2.ONE * 0.5).clamp(Vector2.ZERO, Vector2(block.map_resolution - Vector2i.ONE))
							var a := Vector2i(p.floor())
							var b := (a + Vector2i.ONE).min(block.map_resolution - Vector2i.ONE)
							var f := p - Vector2(a)
							var image := block.working_map.image
							var h := image.get_pixel(a.x, a.y).r * (1 - f.x) * (1 - f.y) + image.get_pixel(b.x, a.y).r * f.x * (1 - f.y) \
								+ image.get_pixel(a.x, b.y).r * (1 - f.x) * f.y + image.get_pixel(b.x, b.y).r * f.x * f.y
							vertex.y = block.base_height + (block.thickness - block.base_height) * h
							points.append(vertex)
						var hit: Variant = plane_oracle(origin, direction, points[0], points[1], points[2])
						if hit != null and origin.distance_squared_to(hit) < distance:
							nearest = hit
							distance = origin.distance_squared_to(nearest)
			var production := block.pick(pixel, camera)
			check(nearest.is_finite() and production.inside, "native mesh oracle finds grazing ray %s at %sx" % [pixel, zoom])
			if nearest.is_finite() and production.inside: worst = maxf(worst, nearest.distance_to(production.local))
			if nearest.is_finite() and production.inside and nearest.distance_to(production.local) >= 0.000005:
				print("NATIVE RAY: ", pixel, " zoom=", zoom, " native=", nearest, " dda=", production.local, " error=", nearest.distance_to(production.local))
			rays += 1
	check(worst < 0.000005, "canonical native mesh / DDA agree within historical 5 micrometers on grazing rays")
	report["native_mesh"] = {"rays": rays, "max_error_m": worst, "tolerance_m": 0.000005, "original_native_xz_drift_m": native_grid_drift}

func plane_oracle(o: Vector3, d: Vector3, a: Vector3, b: Vector3, c: Vector3) -> Variant:
	# Scalar float64 plane equation + Gram barycentrics. The native helper uses
	# float32 vectors; at these near-tangent rays it adds its own amplified error.
	var ex: float = float(b.x) - a.x
	var ey: float = float(b.y) - a.y
	var ez: float = float(b.z) - a.z
	var fx: float = float(c.x) - a.x
	var fy: float = float(c.y) - a.y
	var fz: float = float(c.z) - a.z
	var nx := ey * fz - ez * fy
	var ny := ez * fx - ex * fz
	var nz := ex * fy - ey * fx
	var denominator := nx * d.x + ny * d.y + nz * d.z
	if absf(denominator) < 1e-16: return null
	var t := (nx * (float(a.x) - o.x) + ny * (float(a.y) - o.y) + nz * (float(a.z) - o.z)) / denominator
	if t < 0: return null
	var px := float(o.x) + d.x * t - a.x
	var py := float(o.y) + d.y * t - a.y
	var pz := float(o.z) + d.z * t - a.z
	var ee := ex * ex + ey * ey + ez * ez
	var ff := fx * fx + fy * fy + fz * fz
	var ef := ex * fx + ey * fy + ez * fz
	var ep := ex * px + ey * py + ez * pz
	var fp := fx * px + fy * py + fz * pz
	var determinant := ee * ff - ef * ef
	if absf(determinant) < 1e-22: return null
	var u := (ff * ep - ef * fp) / determinant
	var v := (ee * fp - ef * ep) / determinant
	if u < -1e-8 or v < -1e-8 or u + v > 1.00000001: return null
	return Vector3(px + a.x, py + a.y, pz + a.z)

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://work/test-logs")
	for size in [Vector2i(1024, 640), Vector2i(512, 320), Vector2i(256, 160)]: validate_maps(size)
	test_resolution()
	test_zones()
	test_fracture()
	await test_debug()
	report["checks"] = checks
	report["failures"] = failures
	FileAccess.open("res://work/test-logs/p4v-tests.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("P4V TESTS: %d checks, %d failures" % [checks, failures])
	print("P4V RANGES: ", JSON.stringify(report["(1024, 640)"]))
	print("P4V ZONES: ", JSON.stringify(report.zones))
	quit(0 if failures == 0 else 1)
