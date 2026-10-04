extends "res://tests/run_p2_benchmark.gd"
## CPU-only oracle: count actual relief calls and mesh change notifications.
## No renderer/FPS dependency; density must not multiply the proxy hot path.
class CountedRelief extends ReliefSurface:
	var vertex_queries := 0
	var height_queries := 0
	func vertex_at(grid: Vector2i) -> Vector3:
		vertex_queries += 1
		return super.vertex_at(grid)
	func height_at(uv: Vector2) -> float:
		height_queries += 1
		return super.height_at(uv)

func meshes_below(node: Node) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	for child in node.get_children():
		if child is MeshInstance3D: result.append(child)
		result.append_array(meshes_below(child))
	return result

func run() -> void:
	main = load("res://scenes/prototype_main.tscn").instantiate()
	root.add_child(main)
	main.set_process(false)
	block = main.block
	controller = main.controller
	controller.set_physics_process(false)
	main.feedback.set_process(false)
	var baseline := "--baseline" in OS.get_cmdline_user_args()
	var original := block.relief
	var counted := CountedRelief.new(original.image, original.dimensions, original.cells, original.floor_height, original.top_height)
	block.relief = counted
	var proxy: Node3D = main.feedback.proxies[0]
	var pose: ToolProxyPose = main.feedback.proxy_poses[0]
	var mutations := [0]
	var originals: Dictionary = {}
	for part in meshes_below(proxy):
		part.mesh.changed.connect(func(): mutations[0] += 1)
		originals[part.get_instance_id()] = part.mesh.surface_get_arrays(0)
	for kind in ["flat", "dug", "deep"]:
		controller.reset_surface()
		var p := Vector2(710, 140)
		if kind != "flat": block.working_map.apply_segment(p, p, 25 if kind == "deep" else 65, 100 if kind == "deep" else 2, 1.5, 1)
		block.flush_texture()
		for density in [1, 2]:
			counted.cells = original.cells * density
			var times: Array[float] = []
			var maximum_queries := 0
			var maximum_height_queries := 0
			var before_mutations: int = mutations[0]
			for tick in range(120):
				var uv := (p + Vector2(24 * sin(tick / 15.0), 24 * cos(tick / 21.0)) + Vector2.ONE * 0.5) / Vector2(block.map_resolution)
				proxy.global_transform = Transform3D(ToolProxyPose.fixed_basis(0), block.to_global(Vector3(
					(uv.x - 0.5) * block.surface_size.x, counted.height_at(uv), (uv.y - 0.5) * block.surface_size.y)))
				block.upload_count += 1 # Force invalidation, as continuous Soil does.
				counted.vertex_queries = 0
				counted.height_queries = 0
				var start := Time.get_ticks_usec()
				pose.fit(proxy, block)
				times.append(Time.get_ticks_usec() - start)
				maximum_queries = maxi(maximum_queries, counted.vertex_queries)
				maximum_height_queries = maxi(maximum_height_queries, counted.height_queries)
			var label := "%s_density_%d" % [kind, density]
			report[label] = {"fit_usec": stats(times), "max_vertex_queries": maximum_queries,
				"max_height_queries": maximum_height_queries, "mesh_change_notifications": mutations[0] - before_mutations}
			if not baseline:
				check(maximum_queries <= 48 and maximum_height_queries <= 12, "constant <=12 height probes regardless of terrain density")
				check(mutations[0] == before_mutations, "no mesh rebuilds on the pose hot path")
			print("PROXY COST ", label, " ", JSON.stringify(report[label]))
	if not baseline:
		for part in meshes_below(proxy):
			var arrays := part.mesh.surface_get_arrays(0)
			check(arrays == originals[part.get_instance_id()], "static vertex/index/normal arrays survive all poses")
	report["failures"] = failures
	FileAccess.open("res://work/test-logs/p4-proxy-cost-%s.json" % ("before" if baseline else "after"), FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	main.queue_free()
	await process_frame
	print("P4 PROXY COST: %d failures" % failures)
	quit(0 if failures == 0 else 1)
