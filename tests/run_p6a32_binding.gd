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
	check(view.meshes.size() == 1, "bounded actual Tripo skull imported")
	check(view.model.find_children("*", "CollisionObject3D", true, false).is_empty(), "bone artwork contributes no picking collision")
	var triangles := 0
	for mesh: MeshInstance3D in view.meshes:
		for surface in range(mesh.mesh.get_surface_count()):
			triangles += mesh.mesh.surface_get_arrays(surface)[Mesh.ARRAY_INDEX].size() / 3
		check(mesh.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF, "hidden component cannot cast a premature shadow")
	check(triangles > 0 and triangles <= 30000, "Tripo skull pilot has a bounded <=30k triangle budget")
	evidence["triangles"] = triangles
	check(view.material.get_shader_parameter("working_map") == main.block.texture, "mesh observes the live native height texture")
	check(view.material.get_shader_parameter("fossil_map") == main.block.fossil_texture, "mesh observes immutable native Bone ceilings")
	check(view.material.get_shader_parameter("bone_film_map") == main.block.bone_film_texture, "mesh observes the real native Film mask")
	check(view.material.get_shader_parameter("use_source_albedo") and view.material.get_shader_parameter("use_source_normal"), "real Tripo UV albedo and normal are used")
	check(view.material.get_shader_parameter("source_albedo").get_width() == 2048, "runtime albedo is reduced to 2K while original source is preserved")
	check(view.material.get_shader_parameter("component_filter") == FossilField.Component.SKULL, "pilot never displays another component using skull geometry")
	var mask := preload("res://assets/p6a32/b17_skull_coverage.png").get_image()
	var coverage := 0
	var false_coverage := 0
	for y in range(mask.get_height()):
		for x in range(mask.get_width()):
			if mask.get_pixel(x,y).r > .5:
				coverage += 1
				if main.block.working_map.fossil.field.component_ids[y*1024+x] != FossilField.Component.SKULL: false_coverage += 1
	check(false_coverage == 0 and coverage > 0 and coverage < 7756, "native fallback remains in every uncovered skull area; no other Bone is suppressed")
	evidence["skull_replacement_cells"] = coverage
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
	var args := OS.get_cmdline_user_args()
	mode = args[0] if not args.is_empty() else "tests"
	AudioServer.set_bus_mute(0,true)
	main = load("res://scenes/preparation/base/mesh_overlay.tscn").instantiate()
	root.add_child(main)
	main.display.persist = false
	root.mode = Window.MODE_WINDOWED
	root.size = Vector2i(1280,720)
	main.controller.set_physics_process(false)
	main.panel.hide()
	await settle()
	if mode == "visual": await skull_visual()
	elif mode == "budget": await skull_budget()
	else: await functional()
	evidence["checks"] = checks
	evidence["failures"] = failures
	FileAccess.open(out+"tripo-"+mode+".json",FileAccess.WRITE).store_string(JSON.stringify(evidence,"\t"))
	print("P6A3.2 Tripo ",mode,": ", checks, " checks, ", failures.size(), " failures")
	main.queue_free()
	await create_timer(.3).timeout
	quit(0 if failures.is_empty() else 1)

func skull_picture(label:String) -> Image:
	await settle(4)
	main.block.show_cursor({"inside":false},1)
	main.mesh_view._process(0)
	await RenderingServer.frame_post_draw
	var picture := root.get_texture().get_image()
	check(picture.save_png(out+label+".png") == OK,"capture "+label)
	evidence.captures.append(label+".png")
	return picture

func skull_visual() -> void:
	check(DisplayServer.get_name() != "headless", "real graphical renderer is required")
	main.feedback.proxies_enabled = false
	main.feedback.set_physics_process(false)
	await zoom_to(3,Vector2(275,235))
	main.camera.set_process(false)
	main.session_ui.notice_label.hide()
	var s:WorkingSurface = main.block.working_map
	var baseline := state()
	main.toggle_mesh()
	var hidden_before := await skull_picture("hidden-before")
	main.toggle_mesh()
	var hidden_after := await skull_picture("hidden-after")
	var region := Rect2i(320,150,740,430)
	check(digest(hidden_before.get_region(region).get_data()) == digest(hidden_after.get_region(region).get_data()), "intact matrix has identical pixels: no premature bones or shadows")
	check(state() == baseline, "hidden comparison preserves native state")
	P5Fixture.reveal(s,[50,0,0,0])
	await skull_picture("skull-half-dirty")
	check(s.fossil.exposed_cells == ceili(7756*.5), "partial capture uses exactly half the real skull cells")
	main.select_fixture(3)
	P5Fixture.clean(s)
	await settle()
	baseline=state()
	main.toggle_mesh()
	var before := await skull_picture("skull-before")
	var screen := at(Vector2(280,235))
	var pick_before:Dictionary = main.block.pick(screen,main.camera)
	main.toggle_mesh()
	var after := await skull_picture("skull-after")
	check(digest(before.get_region(region).get_data()) != digest(after.get_region(region).get_data()), "real Tripo geometry changes exposed skull pixels")
	check(main.block.pick(screen,main.camera) == pick_before and pick_before.inside, "actual camera ray picking is identical with mesh on/off")
	check(state() == baseline, "exposed comparison preserves native state")
	for condition in [85.0,70.0]:
		for index in range(s.fossil.exposed.size()):
			if s.fossil.exposed[index] != 0:
				s.fossil.damage_at(index,s.fossil.condition-condition);break
		await skull_picture("skull-condition-"+str(int(condition)))
		check(main.mesh_view.material.get_shader_parameter("b17_condition") == condition,"capture receives native Condition "+str(condition))
	await zoom_to(1)
	main.camera.set_process(false)
	await skull_picture("skull-overview")

func skull_budget() -> void:
	check(DisplayServer.get_name() != "headless", "budget requires a real renderer")
	main.feedback.proxies_enabled=false
	main.feedback.set_physics_process(false)
	main.select_fixture(3)
	P5Fixture.clean(main.block.working_map)
	await zoom_to(3,Vector2(275,235))
	main.camera.set_process(false)
	await settle(5)
	var baseline := state()
	evidence["runtime"]={"engine":Engine.get_version_info().string,"adapter":RenderingServer.get_video_adapter_name(),"size":[root.size.x,root.size.y],"physics_hz":Engine.physics_ticks_per_second,"render_cap":Engine.max_fps}
	evidence["budget"]=[]
	for enabled in [false,true]:
		if main.mesh_enabled != enabled:main.toggle_mesh()
		await settle(5)
		var sample:Array[float]=[]
		for n in range(10):
			var before := Time.get_ticks_usec()
			await process_frame
			sample.append((Time.get_ticks_usec()-before)/1000.0)
		evidence.budget.append({"mesh_enabled":enabled,"frame_ms":stats(sample),"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"rendered_primitives":Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),"texture_bytes":Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED)})
		check(state()==baseline,"budget sampling preserves gameplay "+str(enabled))
