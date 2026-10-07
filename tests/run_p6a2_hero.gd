extends "res://tests/run_p6a16_geometry.gd"
## Reuse native capture/zoom/state/timer helpers. P6A2 never edits the kernel.

func hero_state(index: int) -> void:
	main.select_fixture(0)
	main.select_candidate(1)
	var s: WorkingSurface = main.block.working_map
	if index == 1:
		for y in [240,280,320]:
			for n in range(3): s.apply_continuous(Vector2(200,y),Vector2(700,y),main.controller.tools[0],1.0/60)
	if index >= 2:
		main.select_fixture(1)
		for i in range(120): s.apply_impact(Vector2(185+i%24*8,210+i/24*14),main.controller.tools[1])
	if index >= 3:
		main.select_fixture(3)
	if index >= 4:
		for y in range(185,325,8):
			for x in range(170,385,8):
				if ((Vector2(x,y)-Vector2(275,255))/Vector2(114,78)).length() > 1.0: continue
				for i in range(5): s.apply_impact(Vector2(x,y),main.controller.tools[3])
		for y in range(185,325,22):
			s.apply_continuous(Vector2(170,y),Vector2(385,y),main.controller.tools[0],2.0)
	main.block.flush_texture()
	main.session.flush()

func visual() -> void:
	main.panel.hide()
	var labels := ["reset","part-brushed","excavated","dirty-bone","cleaner-bone"]
	for i in range(5):
		hero_state(i)
		await zoom_to(1)
		var before := state()
		main.set_hero_look(false)
		await capture("baseline-"+labels[i])
		main.set_hero_look(true)
		await capture("hero-"+labels[i])
		check(state() == before,"visual toggle preserves all state "+labels[i])
		await zoom_centered(3,Vector2(270,250))
		await capture("hero-"+labels[i]+"-3x")
	main.select_fixture(4)
	await zoom_centered(3,Vector2(790,230))
	await capture("hero-stone-interface-3x")
	hero_state(0)
	await zoom_centered(3,Vector2(965,535))
	await capture("hero-jacket-integration-3x")

func functional() -> void:
	check(main.candidate == 1, "Hero explicitly starts on B")
	var hero := main
	var baseline: Node3D = load("res://scenes/p6a16_natural_matrix_lab.tscn").instantiate()
	root.add_child(baseline)
	baseline.controller.set_physics_process(false)
	baseline.select_candidate(1)
	var reference := state()
	main=baseline
	check(state()==reference,"Hero initial state byte-identical to witness B")
	# Same synchronous native action sequence: no wall-clock physics drift.
	var sequence: Array[Dictionary] = []
	var blower_reference := {}
	for scene in [baseline,hero]:
		main=scene
		for index in [1,2,3,4]:
			hero_state(index)
			var snapshot:=state()
			if scene==baseline: sequence.append(snapshot)
			else: check(snapshot==sequence[index-1],"all native state identical after progression fixture "+str(index))
		main.select_fixture(2)
		for tick in range(120):
			main.block.working_map.apply_continuous(Vector2(430,255),Vector2(490,255),main.controller.tools[2],1.0/60)
		main.block.flush_texture();main.session.flush()
		if scene==baseline: blower_reference=state()
		else: check(state()==blower_reference,"Blower/debris state identical to witness B")
	main=hero
	var shader_vertex: String=main.hero_shader.code.get_slice("void vertex() {",1).get_slice("void fragment()",0)
	var base_vertex: String=main.witness_shader.code.get_slice("void vertex() {",1).get_slice("void fragment()",0)
	check(shader_vertex==base_vertex,"vertex authority byte-identical")
	var film_code: String=main.hero_shader.code.get_slice("vec4 film =",1).get_slice("color = mix",0)
	var film_base: String=main.witness_shader.code.get_slice("vec4 film =",1).get_slice("color = mix",0)
	check(film_code==film_base,"film amount, bit mask, pattern and density byte-identical")
	check(main.jacket.find_children("*","CollisionObject3D",true,false).is_empty(),"static jacket has no collision/picking authority")
	var triangles:=0
	var intruding:=0
	var faces := PackedVector3Array()
	for mesh: MeshInstance3D in main.jacket.find_children("*","MeshInstance3D",true,false):
		var local_faces:=mesh.mesh.get_faces()
		triangles+=local_faces.size()/3
		for v in local_faces:
			var world: Vector3=mesh.global_transform*v
			faces.append(world)
			if absf(world.x)<.55 and absf(world.z)<.35: intruding+=1
	check(intruding==0,"every static vertex outside the dynamic XZ footprint")
	check(triangles<20000,"static triangle budget under 20k")
	evidence["static_triangles"]=triangles
	# Fixed camera direction at any zoom: test the four boundary rows at floor
	# depth, where a static lip is most likely to hide an excavatable point.
	var occlusions:=0
	var rays:=0
	for side in range(4):
		for n in range(33):
			var t:=float(n)/32
			var target:=Vector3(lerpf(-.5499,.5499,t),.018,.3499 if side==0 else -.3499)
			if side>=2: target=Vector3(.5499 if side==2 else -.5499,.018,lerpf(-.3499,.3499,t))
			var screen: Vector2=main.camera.unproject_position(target)
			var origin: Vector3=main.camera.project_ray_origin(screen)
			var direction: Vector3=main.camera.project_ray_normal(screen)
			for j in range(0,faces.size(),3):
				var hit=Geometry3D.ray_intersects_triangle(origin,direction,faces[j],faces[j+1],faces[j+2])
				if hit!=null and origin.distance_to(hit)<origin.distance_to(target):
					occlusions+=1
					break
			rays+=1
	check(occlusions==0,"jacket does not occlude 132 floor-depth boundary rays")
	evidence["jacket_occlusion"]={"rays":rays,"occluded":occlusions}
	var s: WorkingSurface=main.block.working_map
	P5Fixture.reveal(s,[100,100,100,100]);P5Fixture.clean(s);main.session.flush()
	check(main.session.preparation_complete and main.session.fine_preparation,"85/85 and 95/95 milestones retained")
	check(main.session.archive() and not main.session.can_use_tools(),"Archive locks tools")
	main.reset_specimen()
	check(main.candidate==1 and main.session.can_use_tools() and state()==reference,"R / new block restores B and P5")
	check(Engine.max_fps==240 and Engine.physics_ticks_per_second==60,"240 FPS / 60 Hz preserved")
	baseline.queue_free()
	await process_frame
	var worst_mm := 0.0
	var pick_rays := 0
	for fixture in [0,3]:
		main.select_fixture(fixture)
		for zoom in [1,3]:
			await zoom_to(zoom,Vector2(280,245))
			for y in [350,550,750]:
				for x in [500,800,1100,1400]:
					var pixel:=Vector2(x+.5,y+.5)
					var hit: Dictionary=main.block.pick(pixel,main.camera)
					if not hit.inside: continue
					var native:=NaturalMatrixMeshOracle.height(main.block,main.camera,pixel)
					worst_mm=maxf(worst_mm,absf(native-hit.height)*102)
					pick_rays+=1
	check(pick_rays==48 and worst_mm<.005,"native mesh vs picking: 48 rays, reset/Bone, 1x/3x, <0.005 mm")
	evidence["picking"]={"rays":pick_rays,"worst_mm":worst_mm}

func benchmark() -> void:
	RenderingServer.viewport_set_measure_render_time(root.get_viewport_rid(),true)
	process_frame.connect(sample_frame)
	main.panel.hide()
	var fixtures := {"reset":0,"brush_soil":0,"chisel":1,"pick_near_bone":3,"blower_debris":2,"bone_film":3}
	var tool_ids := {"reset":0,"brush_soil":0,"chisel":1,"pick_near_bone":3,"blower_debris":2,"bone_film":0}
	var reference_poses := {}
	for zoom in [1,3]:
		for kind in fixtures:
			for look in [false,true]:
				main.select_fixture(fixtures[kind]);main.select_candidate(1)
				main.set_hero_look(look)
				main.controller.select_tool(tool_ids[kind])
				var center:=Vector2(280,245) if kind in ["bone_film","pick_near_bone"] else Vector2(470,255)
				await zoom_to(zoom,center)
				var pose_key: String=str(zoom)+kind
				if not look: reference_poses[pose_key]=[main.camera.global_transform,main.camera.size]
				else:
					main.camera.global_transform=reference_poses[pose_key][0]
					main.camera.size=reference_poses[pose_key][1]
				await settle(45)
				var initial:=state()
				frames.clear();gpu.clear();render_cpu.clear();previous=0
				var edits: Array[float]=[]
				var draws: Array[float]=[]
				var picks: Array[float]=[]
				measuring=true
				for tick in range(180):
					await physics_frame
					main.controller._focused=true;main.controller._pointer_inside=true
					main.controller._held=kind!="reset"
					main.controller._screen=at(center+Vector2(sin(tick*.026)*28,cos(tick*.02)*12))
					main.controller._physics_process(1.0/60)
					main.session.flush()
					edits.append(main.controller.last_edit_usec/1000.0)
					picks.append(main.controller.last_pick_usec/1000.0)
					draws.append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
				measuring=false
				main.controller.cancel_stroke()
				var row: Dictionary={"hero":look,"zoom":zoom,"kind":kind,"frame_ms":stats(frames),"gpu_ms":stats(gpu),"edit_ms":stats(edits),"draw_calls":stats(draws),"render_cpu_ms":stats(render_cpu),"initial":initial,"final":state()}
				row["pick_ms"]=stats(picks)
				row["camera"]=str(main.camera.global_transform)
				row["camera_size"]=main.camera.size
				row["texture_memory_bytes"]=Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED)
				evidence.benchmark.append(row)
				check(row.frame_ms.p95<16.667 and row.gpu_ms.mean>0,"frame/GPU "+kind+str(zoom)+str(look))
				check(main.camera.global_transform==reference_poses[pose_key][0] and main.camera.size==reference_poses[pose_key][1],"identical benchmark camera")
				check(row.final.bone==initial.bone and row.final.ceilings==initial.ceilings,"immutable Bone during benchmark")
				print("HERO BENCH ",JSON.stringify({"hero":look,"zoom":zoom,"kind":kind,"frame":row.frame_ms,"gpu":row.gpu_ms}))
				FileAccess.open(out+"benchmark.json",FileAccess.WRITE).store_string(JSON.stringify(evidence,"\t"))

func run() -> void:
	out = "res://work/test-logs/p6a2-hero/"
	DirAccess.make_dir_recursive_absolute(out)
	root.size=Vector2i(1920,1080);root.content_scale_size=root.size
	evidence["runtime"]={"engine":Engine.get_version_info().string,"cpu":OS.get_processor_name(),
		"gpu":RenderingServer.get_video_adapter_name(),"renderer":RenderingServer.get_current_rendering_method(),
		"viewport":[1920,1080],"fps_cap":Engine.max_fps,"physics_hz":Engine.physics_ticks_per_second}
	AudioServer.set_bus_mute(0,true)
	main=load("res://scenes/p6a2_hero_patch.tscn").instantiate()
	root.add_child(main)
	main.controller.set_physics_process(false)
	await settle()
	var args := OS.get_cmdline_user_args()
	var mode: String = args[0] if not args.is_empty() else "preview"
	if mode == "visual": await visual()
	elif mode == "tests": await functional()
	elif mode == "benchmark": await benchmark()
	elif mode == "preview":
		main.panel.hide()
		main.set_hero_look(false)
		await capture("preview-before")
		main.set_hero_look(true)
		await capture("preview-reset")
		hero_state(4)
		await capture("preview-prepared")
		await zoom_centered(3,Vector2(270,250))
		await capture("preview-closeup")
	evidence["checks"]=checks;evidence["failures"]=failures
	FileAccess.open(out+mode+".json",FileAccess.WRITE).store_string(JSON.stringify(evidence,"\t"))
	print("P6A2 HERO ",mode,": ",checks," checks, ",failures.size()," failures")
	main.queue_free()
	await create_timer(.5).timeout
	quit(0 if failures.is_empty() else 1)
