extends "res://tests/run_p4_tests.gd"
## Exact contact and fixed angle, with static meshes and bounded pose work.
## Full triangle/face clearance is intentionally no longer a P4 requirement.

func meshes_below(node: Node) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	for child in node.get_children():
		if child is MeshInstance3D: result.append(child)
		result.append_array(meshes_below(child))
	return result

func run() -> void:
	var main := load("res://scenes/prototype_main.tscn").instantiate() as Node3D
	root.add_child(main)
	main.set_process(false)
	var block: ExcavationBlock = main.block
	var control: ToolController = main.controller
	control.set_physics_process(false)
	var fx: MaterialFeedback = main.feedback
	var originals: Dictionary = {}
	for part in meshes_below(fx):
		originals[part.get_instance_id()] = {"rid": part.mesh.get_rid(), "arrays": part.mesh.surface_get_arrays(0)}
	var hits := 0
	var maximum_lift := 0.0
	for tool in range(4):
		check(ToolProxyPose.fixed_basis(tool).is_equal_approx(Basis.from_euler(Vector3(0.5, 0, -0.62))),
			"restored P4-A/B camera-relative angle for tool %d" % tool)
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
				var pose := fx.proxy_poses[tool]
				maximum_lift = maxf(maximum_lift, pose.body_lift)
				var nearest_tip := INF
				for part in meshes_below(pose.tip):
					for vertex: Vector3 in part.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]:
						nearest_tip = minf(nearest_tip, part.to_global(vertex).distance_to(control.hit.world))
				check(proxy.global_position.distance_to(control.hit.world) < 0.000001
					and pose.tip.global_position.distance_to(control.hit.world) < 0.000001 and nearest_tip < 0.000001,
					"root, tip and rendered apex stay at exact hit: %s tool %d" % [kind, tool])
				check(pose.body.global_basis.is_equal_approx(ToolProxyPose.fixed_basis(tool))
					and (pose.body.global_position - proxy.global_position).is_equal_approx(Vector3.UP * pose.body_lift),
					"body only translates vertically, with the fixed original angle")
				check(pose.probes.size() <= 12 and pose.last_probe_count <= 12
					and (kind != "flat" or tool == 1 or pose.body_lift == 0), "bounded probes; no blanket flat-ground float")
				var transform := pose.body.global_transform
				fx._process(0)
				check(pose.body.global_transform == transform and pose.last_probe_count == 0,
					"unchanged surface/contact reuse clearance with zero terrain queries")
				control.hit.normal = Vector3(0.99999, 0.0001, 0.00001).normalized()
				fx._process(0)
				check(pose.body.global_transform == transform and proxy.global_basis == ToolProxyPose.fixed_basis(tool),
					"surface normal cannot rotate the body or tip")
		check(block.working_map.image.get_data() == geometry and block.working_map.fossil.condition == condition
			and block.working_map.fossil.field.ceilings == ceiling, "proxy cannot change gameplay: " + kind)
	for part in meshes_below(fx):
		var saved: Dictionary = originals[part.get_instance_id()]
		check(part.mesh.get_rid() == saved.rid and part.mesh.surface_get_arrays(0) == saved.arrays,
			"actual vertices/normals and mesh resource remain static across every contact")
	check(maximum_lift <= block.relief.top_height - block.relief.floor_height + 0.012001,
		"body offset bounded to block depth plus existing recoil")
	main.queue_free()
	await process_frame
	print("P4 PROXY TESTS: %d checks, %d failures; %d contacts" % [checks, failures, hits])
	print("P4 PROXY MAX BODY LIFT: ", maximum_lift * 1000, " mm including recoil")
	quit(0 if failures == 0 else 1)
