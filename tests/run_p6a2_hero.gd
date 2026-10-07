extends "res://tests/run_p6a16_geometry.gd"
## Reuse native capture/zoom/state/timer helpers. P6A2 never edits the kernel.

func capture(label: String) -> Image:
	main.feedback.proxies_enabled=false
	main.session_ui.notice_label.hide()
	await settle(4)
	# Camera settling can refresh the cursor; hide only after that update.
	main.block.show_cursor({"inside":false},1)
	await RenderingServer.frame_post_draw
	var picture:=root.get_texture().get_image()
	check(picture.save_png(out+label+".png")==OK,"capture "+label)
	evidence.captures.append(label+".png")
	return picture

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
	await shadow_regression()
	hero_state(0)
	await zoom_to(1)
	main.task_light_enabled=false;main.set_hero_look(true)
	await capture("full-block-directional-debug")
	main.task_light_enabled=true;main.set_hero_look(true)
	await capture("full-block-task-light")
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
	main.select_fixture(1)
	await zoom_centered(3,Vector2(595,370))
	await capture("clay-source-3x")
	await stone_review()
	hero_state(3)
	await zoom_centered(3,Vector2(270,250))
	await capture("bone-film-dirty-3x")
	var unclean:=state()
	for y in range(195,308,12):
		main.block.working_map.apply_continuous(Vector2(195,y),Vector2(357,y),main.controller.tools[0],2.0)
	await settle()
	var cleaned:=state()
	check(unclean.height==cleaned.height and unclean.bone==cleaned.bone and unclean.ceilings==cleaned.ceilings,"Brush-only Film comparison preserves geometry")
	check(cleaned.clean>unclean.clean,"Brush-only comparison actually removes Film")
	await capture("bone-film-clean-3x")
	# Documentary overview only: controls/default 1x and max 3x stay untouched.
	hero_state(0)
	await zoom_to(1)
	main.camera.set_process(false)
	main.camera.size=1.05
	main.set_hero_look(true)
	await capture("full-block-overview-task")
	main.task_light_enabled=false;main.set_hero_look(true)
	await capture("full-block-overview-directional")
	main.task_light_enabled=true;main.set_hero_look(true)
	main.camera.set_process(true)
	await zoom_to(1)

func stone_review() -> void:
	# Native Chisel raster; skip fossil-bearing centres (nearby Bone may still
	# be revealed by the native footprint). Stop at the existing Stone boundary.
	main.select_fixture(1)
	var s: WorkingSurface=main.block.working_map
	var impacts:=0
	for y in range(110,311,12):
		for x in range(705,890,12):
			var cell:=Vector2i(x,y)
			var i:=y*s.size.x+x
			if s.structural_ceilings[i]>0: continue
			for n in range(80):
				if s._heights[i]<=s.strata.packed_limits[i*2+1]-.006: break
				s.apply_impact(Vector2(cell),main.controller.tools[1]);impacts+=1
	# Native air jet clears accumulated debris for the material close-up.
	for y in range(110,311,30):
		s.apply_continuous(Vector2(705,y),Vector2(890,y),main.controller.tools[2],1.0)
	await settle()
	await zoom_centered(3,Vector2(800,205))
	evidence["stone_review_native_impacts"]=impacts
	await capture("sandstone-source-3x")

func shadow_regression() -> void:
	# A local shadow atlas can cache the undisplaced MeshInstance while its
	# vertex height texture changes. Compare excavation with a newly made light.
	hero_state(0)
	await zoom_to(1)
	await settle(10)
	hero_state(4)
	await settle(10)
	await RenderingServer.frame_post_draw
	var edited := root.get_texture().get_image()
	var fresh := main.task_light.duplicate() as SpotLight3D
	main.task_light.free()
	main.add_child(fresh)
	main.task_light=fresh
	await settle(10)
	await RenderingServer.frame_post_draw
	var oracle := root.get_texture().get_image()
	var mean_error:=0.0
	var worst:=0.0
	var samples:=0
	for y in range(180,900,3):
		for x in range(300,1580,3):
			var a:=edited.get_pixel(x,y)
			var b:=oracle.get_pixel(x,y)
			var difference:=maxf(absf(a.r-b.r),maxf(absf(a.g-b.g),absf(a.b-b.b)))
			mean_error+=difference
			worst=maxf(worst,difference)
			samples+=1
	mean_error/=samples
	evidence["shadow_refresh"]={"mean_rgb_error":mean_error,"max_rgb_error":worst,"samples":samples,"oracle":"new SpotLight3D after real height edit"}
	check(mean_error<.002 and worst<.025,"height edit shadow matches freshly instantiated local light")
	var unchanged:=state()
	var radius: float=main.controller.config.radius
	var key:=InputEventKey.new()
	key.physical_keycode=KEY_F11;key.pressed=true
	root.push_input(key)
	check(not main.task_light_enabled,"F11 reaches local light debug through normal input routing")
	root.push_input(key)
	check(state()==unchanged and main.controller.config.radius==radius and main.task_light_enabled,"lighting debug preserves gameplay and tool radius")

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
	check(main.task_light is SpotLight3D and main.task_light.shadow_enabled and main.task_light.visible,"real local shadow-casting preparation lamp")
	check(not main.hero_shader.code.contains("hero_painted") and not main.hero_shader.code.contains("surface_data"),"rejected atlas and previous data plates absent")
	for material in ["soil","clay","stone","bone"]:
		var texture: Texture2D=main.block.material.get_shader_parameter("hero_"+material)
		check(texture!=null and texture.resource_path.ends_with("_albedo_v02.png") and texture.get_size()==Vector2(1024,1024),"selected v02 source bound: "+material)
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
	var occluded_points:=[]
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
					occluded_points.append({"target":str(target),"hit":str(hit),"triangle":j/3})
					break
			rays+=1
	check(occlusions==0,"jacket does not occlude 132 floor-depth boundary rays")
	evidence["jacket_occlusion"]={"rays":rays,"occluded":occlusions,"points":occluded_points}
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
	out = "res://work/test-logs/p6a2-correction/"
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
	elif mode == "shadows": await shadow_regression()
	elif mode == "lightstudy":
		main.panel.hide()
		for index in [0,4]:
			hero_state(index)
			await zoom_to(1)
			main.task_light_enabled=false;main.set_hero_look(true)
			await capture("study-"+str(index)+"-directional")
			main.task_light_enabled=true;main.set_hero_look(true)
			main.task_light.shadow_enabled=true
			await capture("study-"+str(index)+"-spot-shadow")
			main.task_light.shadow_enabled=false
			await capture("study-"+str(index)+"-spot-no-shadow")
			main.task_light.shadow_enabled=true
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
