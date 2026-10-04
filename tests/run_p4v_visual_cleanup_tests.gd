extends SceneTree
## Presentation-only cleanup: exact geology/geometry and surface classification.

var definitions: Array[MaterialDefinition] = [preload("res://config/loose_soil.tres"),
	preload("res://config/compact_clay.tres"), preload("res://config/sandstone.tres")]
var checks := 0
var failures := 0
var report := {}

func _initialize() -> void: call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("P4V12 FAIL: " + message)

func digest(bytes: PackedByteArray) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(bytes)
	return context.finish().hex_encode()

func test_interfaces(size: Vector2i) -> void:
	var strata := Stratigraphy.new(size, definitions)
	var values := PackedFloat32Array()
	values.resize(size.x * size.y)
	var cases := []
	for layer in [0, 1]:
		for offset in [0.0, 0.0005]: # An actual 0.051 mm film must remain visible.
			for i in range(values.size()): values[i] = strata.packed_limits[i * 2 + layer] + offset
			var field := Image.create_from_data(size.x, size.y, false, Image.FORMAT_RF, values.to_byte_array())
			var relief := ReliefSurface.new(field, Vector2(1.1, 0.7), size, 0.018, 0.12)
			var correct := true
			var error := 0.0
			for y in range(1, 40):
				for x in range(1, 64):
					# Non-centre samples exercise both triangle halves and curved areas.
					var uv := Vector2((x + 0.23) / 65, (y + 0.61) / 41)
					var height := relief.normalized_height_at(uv)
					var expected: int = layer if offset > 0 else layer + 1
					correct = correct and strata.surface_material_at(uv, height) == definitions[expected]
					error = maxf(error, absf(height - strata.surface_limits(uv)[layer] - offset))
			check(correct, "triangle surface has clean floor / genuine thin film at %s, layer %d, offset %s" % [size, layer, offset])
			check(error < Stratigraphy.SURFACE_EPSILON, "only float32 roundoff remains after aligned interpolation")
			cases.append({"layer": layer, "offset": offset, "max_roundoff": error, "samples": 2457})
	# CPU cell work intentionally keeps its strict original material threshold.
	var limits := strata.sample_limits(Vector2(0.4, 0.6))
	check(Stratigraphy.index_at(limits.y, limits) == 2 and Stratigraphy.index_at(limits.y + 1e-8, limits) == 1,
		"cell work still distinguishes every positive Clay thickness, including sub-render precision")
	report[str(size)] = cases
	if size == Vector2i(1024, 640):
		var bones := FossilField.new(size)
		check(digest(strata.boundaries.get_data()) == "189ff3573bf91c0c7742cd76d4d5e3b45e08f198d8302de1821c35059e9b06c9",
			"entire V1.1 geology byte exact")
		check(digest(bones.image.get_data()) == "1f1b9622b3aecb19cefb3b6a3266469c5ac170cf7579a695219fdee57ad8d73e",
			"entire V1.1 Bone map byte exact")

func test_face_meshes() -> void:
	var box := BoxMesh.new()
	box.size = Vector3.ONE
	for source: Mesh in [box, LooseDebrisView.crumb_mesh()]:
		var result := DebrisVisualMesh.with_face_contrast(source)
		var a := source.surface_get_arrays(0)
		var b := result.surface_get_arrays(0)
		check(a[Mesh.ARRAY_VERTEX] == b[Mesh.ARRAY_VERTEX] and a[Mesh.ARRAY_INDEX] == b[Mesh.ARRAY_INDEX]
			and a[Mesh.ARRAY_TEX_UV] == b[Mesh.ARRAY_TEX_UV], "face contrast preserves exact vertices / topology / UVs")
		var colors: PackedColorArray = b[Mesh.ARRAY_COLOR]
		var low := 1.0
		var high := 0.0
		for color in colors:
			low = minf(low, color.r)
			high = maxf(high, color.r)
		check(colors.size() == a[Mesh.ARRAY_VERTEX].size() and low >= 0.49 and high - low > 0.20,
			"bounded static face values separate tops / sides without adding geometry")
	var main := load("res://scenes/prototype_main.tscn").instantiate() as Node3D
	root.add_child(main)
	main.controller.set_physics_process(false)
	var fx: MaterialFeedback = main.feedback
	check(fx.pools[0].mesh is BoxMesh and fx.pools[3].mesh is QuadMesh, "Soil grains and lifted dust meshes unchanged")
	check(fx.pools[1].mesh is ArrayMesh and fx.pools[2].mesh is ArrayMesh, "hard chunks use static face contrast")
	var original := fx.pools[2].mesh.get_rid()
	fx._emit(2, Vector2(700, 140), 5)
	for i in range(60): fx._process(1.0 / 60.0)
	check(fx.pools[2].mesh.get_rid() == original and fx.particles[2].is_empty(), "same bounded lifetime and no runtime mesh rebuild")
	check(main.block.material.get_shader_parameter("surface_layer_epsilon") == Stratigraphy.SURFACE_EPSILON,
		"GPU and cursor share the same numerical roundoff allowance")
	main.free()

func run() -> void:
	for size in [Vector2i(1024, 640), Vector2i(512, 320), Vector2i(256, 160)]: test_interfaces(size)
	test_face_meshes()
	report["checks"] = checks
	report["failures"] = failures
	FileAccess.open("res://work/test-logs/p4v12-tests.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("P4V12 TESTS: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
