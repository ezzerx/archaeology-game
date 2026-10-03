extends "res://tests/run_p4_tests.gd"
## Inspect the actual render vertices (Mesh.get_faces() snaps its derived
## triangle mesh, which is unsuitable for sub-mm clearance checks).

func run() -> void:
	var main := load("res://scenes/prototype_main.tscn").instantiate() as Node3D
	root.add_child(main)
	main.set_process(false)
	var block: ExcavationBlock = main.block
	var control: ToolController = main.controller
	control.set_physics_process(false)
	var fx: MaterialFeedback = main.feedback
	var hits := 0
	var vertices_checked := 0
	var faces_checked := 0
	for kind in ["flat", "slope", "deep", "bone", "fracture"]:
		control.reset_surface()
		var p := Vector2(286, 194) if kind == "bone" else Vector2(700, 140)
		if kind != "flat": block.working_map.apply_segment(p, p, 25 if kind == "deep" else 65, 100 if kind in ["deep", "bone"] else 1.15, 1.5, 1)
		if kind == "fracture":
			for i in range(15): block.working_map.apply_impact(p + Vector2(i % 3 * 8, i / 3 as int * 4), chisel)
		block.flush_texture()
		var geometry := block.working_map.image.get_data()
		var condition := block.working_map.fossil.condition
		var ceiling := block.working_map.fossil.field.ceilings.duplicate()
		for offset: Vector2 in [Vector2.ZERO, Vector2(-24, 0), Vector2(24, 0), Vector2(0, -24), Vector2(0, 24), Vector2(12, 12), Vector2(-40, 0)]:
			var uv := (p + offset + Vector2.ONE * 0.5) / Vector2(block.map_resolution)
			var local := Vector3((uv.x - 0.5) * block.surface_size.x, block.relief.height_at(uv), (uv.y - 0.5) * block.surface_size.y)
			control.hit = block.pick(main.camera.unproject_position(block.to_global(local)), main.camera)
			if not control.hit.inside: continue
			hits += 1
			for tool in range(4):
				control.select_tool(tool)
				fx.recoil_remaining = 0.07 if tool == 1 else 0.0
				fx._process(0)
				var proxy := fx.proxies[tool]
				var plane_ok := true
				var terrain_ok := true
				var faces_ok := true
				var nearest_tip := INF
				for part: MeshInstance3D in proxy.get_children():
					var vertices: PackedVector3Array = part.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
					for vertex: Vector3 in vertices:
						var world := part.to_global(vertex)
						nearest_tip = minf(nearest_tip, world.distance_to(control.hit.world))
						plane_ok = plane_ok and (world - control.hit.world).dot(control.hit.normal) >= -0.000002
						var v := block.to_local(world)
						var at := SurfaceMapping.local_to_uv(v, block.surface_size)
						terrain_ok = terrain_ok and v.y >= block.relief.height_at(at) - 0.000002
						vertices_checked += 1
					for i in range(0, vertices.size(), 3):
						# The second probe is independent of the fitter's own samples.
						for weights: Vector3 in [Vector3.ONE / 3, Vector3(0.23, 0.41, 0.36)]:
							var face_point := block.to_local(part.to_global(vertices[i] * weights.x + vertices[i + 1] * weights.y + vertices[i + 2] * weights.z))
							faces_ok = faces_ok and face_point.y >= block.relief.height_at(SurfaceMapping.local_to_uv(face_point, block.surface_size)) - 0.0001
							faces_checked += 1
				check(proxy.global_position.distance_to(control.hit.world) < 0.000001 and nearest_tip < 0.000001 and plane_ok and terrain_ok,
					"tip anchored; real visual body outside contact plane/relief: %s tool %d" % [kind, tool])
				check(faces_ok, "face interiors stay outside cavity walls within 0.1 mm: %s tool %d" % [kind, tool])
				var transform := proxy.global_transform
				var first: PackedVector3Array = proxy.get_child(0).mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX].duplicate()
				fx._process(0)
				check(proxy.global_transform == transform and proxy.get_child(0).mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] == first,
					"unchanged contact is exactly stable without pose jitter")
		check(block.working_map.image.get_data() == geometry and block.working_map.fossil.condition == condition
			and block.working_map.fossil.field.ceilings == ceiling, "proxy fitting cannot modify gameplay: " + kind)
	var a := ToolProxyPose.contact_basis(Vector3(0.99999, 0.0001, 0).normalized())
	var b := ToolProxyPose.contact_basis(Vector3(0.99999, 0.0001, 0.000001).normalized())
	check(a.x.distance_to(b.x) < 0.0001 and a.z.distance_to(b.z) < 0.0001, "steep normal has no look-at roll pole")
	main.queue_free()
	await process_frame
	print("P4 PROXY TESTS: %d checks, %d failures; %d contacts, %d rendered vertices, %d face probes" % [checks, failures, hits, vertices_checked, faces_checked])
	quit(0 if failures == 0 else 1)
