extends SceneTree
## PREFLIGHT ONLY: static import contract and unchanged dynamic baseline smoke test.
const OUT := "res://work/test-logs/p6a2-preflight/"
var checks: Array[Dictionary] = []
var references: Array[Dictionary] = []
var measurements: Dictionary = {}

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, label: String) -> void:
	checks.append({"pass": ok, "check": label})
	if not ok: push_error(label)

func capture(label: String) -> void:
	for i in range(4): await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		check(root.get_texture().get_image().save_jpg(OUT + label + ".jpg", 0.9) == OK, "capture " + label)

func digest(bytes: PackedByteArray) -> String:
	var hash_context := HashingContext.new()
	hash_context.start(HashingContext.HASH_SHA256)
	hash_context.update(bytes)
	return hash_context.finish().hex_encode()

func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	for file in ["00-style-north-star.jpg", "01-gameplay-target.jpg", "02-material-closeup.jpg", "03-closed-block.jpg", "04-progression-states.jpg", "05-workbench-target.jpg"]:
		var path: String = "res://docs/visual-references/p6a2/" + file
		var img := Image.load_from_file(path)
		check(img != null and not img.is_empty(), "reference decode " + file)
		references.append({"file": path, "width": img.get_width(), "height": img.get_height(), "sha256": FileAccess.get_sha256(path)})
	var scene: Node = load("res://scenes/preflight/pipeline_probe.tscn").instantiate()
	root.add_child(scene)
	var meshes := scene.find_children("*", "MeshInstance3D", true, false)
	check(meshes.size() == 4, "four authored meshes imported")
	var body := scene.find_child("probe_body", true, false) as MeshInstance3D
	check(body != null, "named body imported")
	if body == null:
		finish()
		return
	var low := Vector3(INF, INF, INF)
	var high := Vector3(-INF, -INF, -INF)
	for surface_index in body.mesh.get_surface_count():
		var body_vertices: PackedVector3Array = body.mesh.surface_get_arrays(surface_index)[Mesh.ARRAY_VERTEX]
		for vertex in body_vertices:
			low = low.min(vertex)
			high = high.max(vertex)
	measurements["body_size_godot_m"] = str(high - low)
	measurements["body_culling_aabb_size_m"] = str(body.mesh.get_aabb().size)
	measurements["body_position_godot_m"] = str(body.global_position)
	check((high - low).is_equal_approx(Vector3(.2, .05, .1)), "vertex dimensions XYZ = 200 / 50 / 100 mm")
	check(body.global_position.is_equal_approx(Vector3(.3, .025, -.2)), "parent and local translations survive axis conversion")
	check(body.global_basis.is_equal_approx(Basis.IDENTITY), "applied rotation/scale remains identity")
	check(body.mesh.get_surface_count() == 2, "two body material slots survive")
	var names: Array[String] = []
	for i in body.mesh.get_surface_count():
		var mat := body.mesh.surface_get_material(i) as StandardMaterial3D
		check(mat != null, "material imported as StandardMaterial3D")
		if mat:
			names.append(mat.resource_name)
			check(is_equal_approx(mat.roughness, .25 if mat.resource_name == "probe_top" else .8), "roughness survives " + mat.resource_name)
	check("probe_top" in names and "probe_neutral" in names, "material names retained")
	var positions := {"axis_x": Vector3(.46, .01, -.2), "axis_y": Vector3(.3, .015, -.34), "axis_z": Vector3(.3, .12, -.2)}
	for name in positions:
		var marker := scene.find_child(name, true, false) as Node3D
		check(marker != null and marker.global_position.is_equal_approx(positions[name]), "axis orientation " + name)
	var normal_ok := true
	var triangles := 0
	for instance in meshes:
		var mesh: Mesh = instance.mesh
		for surface in mesh.get_surface_count():
			var arrays := mesh.surface_get_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			triangles += indices.size() / 3
			normal_ok = normal_ok and vertices.size() == normals.size()
			for i in normals.size():
				normal_ok = normal_ok and absf(normals[i].length() - 1.0) < .0001 and vertices[i].dot(normals[i]) > 0.0
	check(normal_ok, "all mesh normals unit length and outward")
	check(triangles == 48, "48 source triangles retained")
	check(scene.find_children("*", "CollisionObject3D", true, false).is_empty(), "probe has no gameplay collision")
	measurements["triangles"] = triangles
	measurements["glb_sha256"] = FileAccess.get_sha256("res://assets/preflight/pipeline_probe.glb")
	await capture("probe")
	scene.queue_free()
	await process_frame
	var lab: Node = load("res://scenes/p6a16_natural_matrix_lab.tscn").instantiate()
	root.add_child(lab)
	lab.select_candidate(1) # The historical comparison scene intentionally still defaults to A.
	var surface: WorkingSurface = lab.block.working_map
	var before := [digest(surface.image.get_data()), digest(surface.strata.boundaries.get_data()), digest(surface.structural_ceilings.to_byte_array())]
	var static_probe: Node3D = load("res://assets/preflight/pipeline_probe.glb").instantiate()
	static_probe.scale = Vector3.ONE * .4
	static_probe.position = Vector3(.53, .14, .3) # Outside the 1.1 m excavation footprint.
	lab.add_child(static_probe)
	await capture("baseline-B-with-static-probe")
	var after := [digest(surface.image.get_data()), digest(surface.strata.boundaries.get_data()), digest(surface.structural_ceilings.to_byte_array())]
	check(before == after, "static sibling leaves heightfield, strata and Bone ceilings byte-identical")
	check(lab.candidate == 1 and lab.fixture == 0 and lab.patina, "working baseline B + intact thin Soil + contact patina")
	check(lab.controller.tools.size() == 4 and lab.session != null, "native tools and P5 session instantiated")
	check(Engine.physics_ticks_per_second == 60 and Engine.max_fps == 240, "60 Hz physics / 240 FPS cap retained")
	measurements["baseline_B_hashes_height_strata_ceilings"] = before
	lab.queue_free()
	await process_frame
	var production: Node = load("res://scenes/prototype_main.tscn").instantiate()
	root.add_child(production)
	await capture("baseline-P5")
	check(production.session != null and production.controller.tools.size() == 4, "normal P5 baseline opens")
	production.queue_free()
	await process_frame
	finish()

func finish() -> void:
	var failed := checks.filter(func(item: Dictionary) -> bool: return not item.pass).size()
	var report := {"godot": Engine.get_version_info().string, "display": DisplayServer.get_name(), "checks": checks, "failures": failed, "references": references, "measurements": measurements}
	var file := FileAccess.open(OUT + "results.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print("P6A2 PREFLIGHT: %d checks, %d failures" % [checks.size(), failed])
	quit(1 if failed else 0)
