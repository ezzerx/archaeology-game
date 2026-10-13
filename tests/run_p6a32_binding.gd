extends "res://tests/run_p6a31_readability.gd"
## Technical binding probe only; a pass does not approve the fossil artwork.

func functional() -> void:
	await super.functional()
	var baseline := state()
	main.toggle_mesh()
	check(state() == baseline, "F6 removes presentation without changing native gameplay")
	main.toggle_mesh()
	check(state() == baseline, "F6 restores presentation without changing native gameplay")
	var view: Node3D = main.mesh_view
	check(view.meshes.size() == 4, "four independent B-17 components imported")
	check(view.model.find_children("*", "CollisionObject3D", true, false).is_empty(), "bone artwork contributes no picking collision")
	var triangles := 0
	for mesh: MeshInstance3D in view.meshes:
		for surface in range(mesh.mesh.get_surface_count()):
			triangles += mesh.mesh.surface_get_arrays(surface)[Mesh.ARRAY_INDEX].size() / 3
		check(mesh.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF, "hidden component cannot cast a premature shadow")
	check(triangles > 0 and triangles <= 70000, "binding probe has a bounded <=70k triangle budget")
	evidence["triangles"] = triangles
	check(view.material.get_shader_parameter("working_map") == main.block.texture, "mesh observes the live native height texture")
	check(view.material.get_shader_parameter("fossil_map") == main.block.fossil_texture, "mesh observes immutable native Bone ceilings")
	check(view.material.get_shader_parameter("bone_film_map") == main.block.bone_film_texture, "mesh observes the real native Film mask")
	main.reset_specimen()
	var s: WorkingSurface = main.block.working_map
	P5Fixture.reveal(s, [100,100,100,100])
	for index in range(s.fossil.exposed.size()):
		if s.fossil.exposed[index] != 0:
			s.fossil.damage_at(index, 15)
			break
	check(view.material.get_shader_parameter("b17_condition") == 85.0, "3D material receives native Condition damage")
	main.reset_specimen()
	check(view.material.get_shader_parameter("b17_condition") == 100.0, "3D material restores Condition after native reset")

func run() -> void:
	out = "res://work/test-logs/p6a32/"
	DirAccess.make_dir_recursive_absolute(out)
	root.size = Vector2i(1280,720)
	root.content_scale_size = root.size
	mode = "tests"
	AudioServer.set_bus_mute(0,true)
	main = load("res://scenes/p6a32_fossil_mesh.tscn").instantiate()
	root.add_child(main)
	main.display.persist = false
	main.controller.set_physics_process(false)
	main.panel.hide()
	await settle()
	await functional()
	evidence["checks"] = checks
	evidence["failures"] = failures
	FileAccess.open(out+"binding.json",FileAccess.WRITE).store_string(JSON.stringify(evidence,"\t"))
	print("P6A3.2 binding: ", checks, " checks, ", failures.size(), " failures")
	main.queue_free()
	await create_timer(.3).timeout
	quit(0 if failures.is_empty() else 1)
