extends SceneTree
## P1 checks complement, rather than replace, the untouched 45 P0 checks.

var checks := 0
var failures := 0
var definitions: Array[MaterialDefinition] = [preload("res://config/loose_soil.tres"),
	preload("res://config/compact_clay.tres"), preload("res://config/sandstone.tres")]

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + description)

func test_materials() -> void:
	var strata := Stratigraphy.new(Vector2i(64, 40), definitions)
	var twin := Stratigraphy.new(Vector2i(64, 40), definitions)
	check(strata.boundaries.get_data() == twin.boundaries.get_data(), "byte-exact deterministic stratigraphy")
	var limits := strata.boundaries.get_pixel(32, 20)
	var cell := Vector2i(32, 20)
	var uv := (Vector2(cell) + Vector2(0.5, 0.5)) / Vector2(64, 40)
	check(strata.material_at(uv, 1).id == &"loose_soil", "initial Loose Soil")
	check(strata.material_at(uv, limits.r).id == &"compact_clay", "exact first interface belongs to Clay")
	check(strata.material_at(uv, limits.g).id == &"sandstone", "exact second interface belongs to Sandstone")
	check(strata.material_at(uv, 0).id == &"sandstone", "floor remains Sandstone")
	check(strata.boundaries.get_pixel(0, 0) != limits, "interfaces are not flat bands")
	var ordered := true
	for y in range(40):
		for x in range(64):
			var value := strata.boundaries.get_pixel(x, y)
			ordered = ordered and value.r < 1.0 and value.r > value.g and value.g > 0.0
	check(ordered, "all columns have ordered bounded layers")
	var soil_rate := 1.0 - strata.remove_work(1.0, 0.01, cell)
	var clay_rate := 0.55 - strata.remove_work(0.55, 0.01, cell)
	var stone_rate := 0.20 - strata.remove_work(0.20, 0.01, cell)
	check(is_equal_approx(soil_rate / clay_rate, 3.0), "Clay is three times slower")
	check(is_equal_approx(soil_rate / stone_rate, 8.0), "Sandstone is eight times slower")
	var soil_cost := (1.0 - limits.r) * definitions[0].resistance
	var clay_cost := (limits.r - limits.g) * definitions[1].resistance
	check(absf(strata.remove_work(1.0, soil_cost, cell) - limits.r) < 0.000001, "work reaches first layer exactly")
	check(absf(strata.remove_work(1.0, soil_cost + clay_cost + 0.08, cell) - (limits.g - 0.01)) < 0.000001, "large work crosses layers without skipping resistance")
	check(strata.remove_work(1.0, 1000.0, cell) == 0.0, "large work saturates at floor")
	var definition := MaterialDefinition.new()
	definition.resistance = 0.0
	check(definition.resistance > 0, "resistance cannot divide by zero")
	var surface := WorkingSurface.new(Vector2i(64, 40), strata)
	var initial := surface.image.get_data()
	var layer_bytes := strata.boundaries.get_data()
	var centre := Vector2(32, 20)
	var seen := {}
	for i in range(360):
		surface.apply_segment(centre, centre, 8, 0.8, 1.5, 1.0 / 60.0)
		seen[strata.material_at(uv, surface.value_at(cell)).id] = true
	check(seen.size() == 3, "same debug stroke reaches all three materials")
	check(surface.value_at(cell) == 0.0, "continuous excavation reaches but cannot pass floor")
	var bounded := true
	for value in surface.image.get_data().to_float32_array():
		bounded = bounded and value >= 0.0 and value <= 1.0
	check(bounded, "height map remains within 0..1")
	var carved := surface.image.get_data()
	surface.reset()
	check(surface.image.get_data() == initial, "P1 reset is byte exact")
	check(strata.boundaries.get_data() == layer_bytes, "stratigraphy stays immutable")
	for i in range(360):
		surface.apply_segment(centre, centre, 8, 0.8, 1.5, 1.0 / 60.0)
	check(surface.image.get_data() == carved, "material excavation repeatability")
	var split := surface.value_at(cell + Vector2i(3, 0))
	surface.reset()
	surface.apply_segment(centre, centre, 8, 0.8, 1.5, 6.0)
	check(absf(surface.value_at(cell + Vector2i(3, 0)) - split) < 0.00002, "layer transitions independent of stationary timestep")
	surface.reset()
	surface.apply_segment(Vector2(-0.5, -0.5), Vector2(63.5, 39.5), 3, 0.8, 1.5, 0.1)
	var continuous := true
	for i in range(64):
		var point := Vector2.ZERO.lerp(Vector2(63, 39), i / 63.0)
		continuous = continuous and surface.value_at(Vector2i(point.round())) < 1.0
	check(continuous, "fast P1 diagonal covers corners without gaps")
	check(surface.value_at(Vector2i(63, 0)) == 1, "P1 stroke stays local")

func sample_oracle(source: Image, uv: Vector2) -> float:
	var p := uv * Vector2(source.get_size()) - Vector2(0.5, 0.5)
	var x := floori(p.x)
	var y := floori(p.y)
	var fx := p.x - x
	var fy := p.y - y
	var last := source.get_size() - Vector2i.ONE
	return (source.get_pixel(clampi(x, 0, last.x), clampi(y, 0, last.y)).r * (1 - fx) * (1 - fy)
		+ source.get_pixel(clampi(x + 1, 0, last.x), clampi(y, 0, last.y)).r * fx * (1 - fy)
		+ source.get_pixel(clampi(x, 0, last.x), clampi(y + 1, 0, last.y)).r * (1 - fx) * fy
		+ source.get_pixel(clampi(x + 1, 0, last.x), clampi(y + 1, 0, last.y)).r * fx * fy)

func test_edit_oracle() -> void:
	var size := Vector2i(32, 20)
	var strata := Stratigraphy.new(size, definitions)
	var surface := WorkingSurface.new(size, strata)
	var reference := surface.image.duplicate() as Image
	var start := Vector2(2.25, 3.6)
	var end := Vector2(28.8, 16.4)
	for delta in [0.04, 0.4, 0.9, 3.0, 10.0]:
		surface.apply_segment(start, end, 6.3, 1.3, 1.7, delta)
		for y in range(size.y):
			for x in range(size.x):
				var p := Vector2(x, y)
				var nearest := Geometry2D.get_closest_point_to_segment(p, start, end)
				var work: float = 1.3 * delta * WorkingSurface.weight(p.distance_to(nearest) / 6.3, 1.7)
				var h := strata.remove_work(reference.get_pixel(x, y).r, work, Vector2i(x, y))
				reference.set_pixel(x, y, Color(h, 0, 0))
	var error := 0.0
	for y in range(size.y):
		for x in range(size.x):
			error = maxf(error, absf(reference.get_pixel(x, y).r - surface.value_at(Vector2i(x, y))))
	check(error < 0.00001, "optimized packed edit agrees with independent work/capsule oracle across layers")

func test_mesh_oracle() -> void:
	var size := Vector2i(16, 10)
	var surface := WorkingSurface.new(size)
	for y in range(size.y):
		for x in range(size.x):
			var h := clampf(0.5 + 0.4 * sin(x * 0.9) * cos(y * 1.4), 0, 1)
			surface.image.set_pixel(x, y, Color(h, 0, 0))
	var relief := ReliefSurface.new(surface.image, Vector2(1.1, 0.7), size, 0.018, 0.12)
	var plane := PlaneMesh.new()
	plane.size = relief.dimensions
	plane.subdivide_width = size.x - 1
	plane.subdivide_depth = size.y - 1
	var arrays := plane.get_mesh_arrays()
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	# Actual native topology; oracle independently displaces its actual vertices.
	for i in range(vertices.size()):
		vertices[i].y = 0.018 + 0.102 * sample_oracle(surface.image, uvs[i])
	var worst_error := 0.0
	var matched := true
	var height_matched := true
	var rays := 0
	for elevation in [84.0, 60.0, 35.0]:
		for i in range(60):
			var uv := Vector2(0.06 + 0.88 * fmod(i * 0.61803398875, 1.0), 0.08 + 0.84 * fmod(i * 0.41421356237, 1.0))
			var angle := deg_to_rad(elevation)
			var direction := Vector3(0.15 * cos(angle), -sin(angle), -cos(angle)).normalized()
			var origin := Vector3((uv.x - 0.5) * 1.1, 0.12, (uv.y - 0.5) * 0.7) - direction * 0.3
			var expected: Variant = null
			var distance := INF
			for index in range(0, indices.size(), 3):
				# Scale the native helper's absolute epsilon away from mm² triangles.
				var point: Variant = Geometry3D.ray_intersects_triangle(origin * 1000, direction,
					vertices[indices[index]] * 1000, vertices[indices[index + 1]] * 1000, vertices[indices[index + 2]] * 1000)
				if point != null:
					point /= 1000.0
					var d := origin.distance_to(point)
					if d < distance:
						distance = d
						expected = point
			var hit := relief.ray_hit(origin, direction, 10.0)
			matched = matched and ((expected == null) == hit.is_empty())
			if expected != null and not hit.is_empty():
				worst_error = maxf(worst_error, expected.distance_to(hit.local))
				var hit_uv := SurfaceMapping.local_to_uv(expected, relief.dimensions)
				height_matched = height_matched and absf(relief.height_at(hit_uv) - expected.y) < 0.000005
			rays += 1
	check(matched and worst_error < 0.000005, "DDA first hit matches actual mesh triangles (180 oblique rays)")
	check(height_matched, "CPU displayed height uses triangle interpolation, not bilinear approximation")
	print("P1 PICK ORACLE: %d rays, maximum error %.8f m" % [rays, worst_error])
	check(relief.ray_hit(Vector3(0, 0.04, 1), Vector3.FORWARD, 10).is_empty(), "solid side cannot be painted through")
	check(relief.ray_hit(Vector3(2, 1, 0), Vector3.DOWN, 10).is_empty(), "outside vertical ray rejected")
	check(relief.ray_hit(Vector3(0, 1, 0), Vector3.DOWN, 0.1).is_empty(), "camera far bound respected")

func test_scene_relief() -> void:
	root.size = Vector2i(1920, 1080)
	var main := load("res://scenes/prototype_main.tscn").instantiate() as Node3D
	root.add_child(main)
	var block: ExcavationBlock = main.get_node("ExcavationBlock")
	var controller: ToolController = main.get_node("ToolController")
	var camera: Camera3D = main.get_node("Camera3D")
	controller.set_physics_process(false)
	await physics_frame
	var initial := block.working_map.image.get_data()
	# P3 adds bone near the old centre fixture. Test the P1 free-matrix floor
	# above the fossil; bone/cavity contacts have their own P3 oracle.
	block.working_map.apply_segment(Vector2(512, 100), Vector2(512, 100), 80, 5, 1, 2)
	block.flush_texture()
	check(block.relief.height_at(Vector2(0.5, 0.15625)) < block.thickness - 0.09, "deep cavity has physical depth")
	for uv in [Vector2(0.5, 0.15625), Vector2(0.54, 0.15625), Vector2(0.57, 0.15625), Vector2(0.2, 0.2)]:
		var local := Vector3((uv.x - 0.5) * 1.1, block.relief.height_at(uv), (uv.y - 0.5) * 0.7)
		var screen := camera.unproject_position(block.to_global(local))
		var hit := block.pick(screen, camera)
		check(hit.inside and hit.local.distance_to(local) < 0.00001, "deep floor/slope/interface/intact camera roundtrip %s" % uv)
		if hit.inside:
			block.show_cursor(hit, 40)
			check((block.material.get_shader_parameter("cursor_uv") as Vector2).distance_to(uv) < 0.00001, "cursor is attached to picked triangle")
	for uv in [Vector2(0.001, 0.5), Vector2(0.999, 0.5), Vector2(0.001, 0.001), Vector2(0.999, 0.999)]:
		block.working_map.apply_segment(SurfaceMapping.uv_to_map(uv, block.map_resolution), SurfaceMapping.uv_to_map(uv, block.map_resolution), 40, 5, 1, 2)
		var local := Vector3((uv.x - 0.5) * 1.1, block.relief.height_at(uv), (uv.y - 0.5) * 0.7)
		var hit := block.pick(camera.unproject_position(block.to_global(local)), camera)
		check(hit.inside and hit.local.distance_to(local) < 0.00001, "excavated edge/corner %s" % uv)
	block.position = Vector3(0.03, 0.02, 0.01)
	block.rotation = Vector3(0.07, 0.15, -0.03)
	block.scale = Vector3(0.9, 1.1, 0.8)
	var target := Vector3(0.0, block.relief.height_at(Vector2(0.5, 0.15625)), (0.15625 - 0.5) * 0.7)
	var transformed := block.pick(camera.unproject_position(block.to_global(target)), camera)
	check(transformed.inside and transformed.local.distance_to(target) < 0.00001, "deep picking with translated/rotated/non-uniformly scaled block")
	check(transformed.inside and absf(transformed.normal.length() - 1.0) < 0.00001, "transformed contact normal is normalized")
	controller.reset_surface()
	check(block.working_map.image.get_data() == initial, "scene reset restores exact height")
	check(is_equal_approx(block.relief.height_at(Vector2(0.5, 0.5)), block.thickness), "reset also restores picked surface")
	var uploads := block.upload_count
	block.flush_texture()
	check(block.upload_count == uploads, "no upload on clean frames")
	check(block.material.get_shader_parameter("working_map") == block.texture, "renderer shares authoritative height texture")
	check(block.skirt_material.get_shader_parameter("working_map") == block.texture, "skirts share height texture")
	check(is_equal_approx(block.get_node("Sides").mesh.get_aabb().size.y, block.base_height), "solid base does not plug cavities")
	check(block.get_node("Sides").mesh.surface_get_array_index_len(0) == 30, "base has five faces, avoiding a coplanar floor cap")
	block.set_debug_view(3)
	check(block.material.get_shader_parameter("debug_view") == 3, "normal debug view")
	block.set_debug_view(4)
	check(block.debug_view == 0, "debug view wraps to shaded")
	main.queue_free()
	await process_frame

func run() -> void:
	test_materials()
	test_edit_oracle()
	test_mesh_oracle()
	await test_scene_relief()
	print("P1 TESTS: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
