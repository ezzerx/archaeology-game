extends "res://tests/run_p6a2_hero.gd"
## Exact native input trajectories in the shared P6A2 excavation core.
const CASES := [
	["brush-soil",0,0,1,Vector2(470,310)],
	["brush-clay",1,0,3,Vector2(470,310)],
	["chisel-clay",1,1,3,Vector2(470,255)],
	["chisel-sandstone",4,1,3,Vector2(825,220)],
	["pick-matrix",1,3,3,Vector2(470,255)],
	["pick-near-bone",3,3,3,Vector2(280,245)],
	["blower-debris",2,2,3,Vector2(470,255)],
	["bone-film",3,0,3,Vector2(280,245)]]
var mode := "tests"

func feedback_tick() -> void:
	if main.sensory_enabled: main.feedback._physics_process(1.0/60)

func prepare(item: Array) -> void:
	if mode=="movie": AudioServer.set_bus_mute(0,true)
	main.controller.cancel_stroke()
	main.select_fixture(item[1])
	if item[0]=="chisel-sandstone":
		# Native Pick preparation reaches actual Sandstone across the Chisel footprint.
		var s:WorkingSurface=main.block.working_map
		for y in range(int(item[4].y)-40,int(item[4].y)+41,10):
			for x in range(int(item[4].x)-40,int(item[4].x)+41,10):
				for n in range(12):
					if s.value_at(Vector2i(x,y))<=s.strata.packed_limits[(y*s.size.x+x)*2+1]-.03: break
					s.apply_impact(Vector2(x,y),main.controller.tools[3])
		main.block.flush_texture()
	main.controller.select_tool(item[2])
	await zoom_to(item[3],item[4])
	main.feedback.reset()
	main.feedback.set_physics_process(false)
	main.feedback.proxies_enabled=true
	main.controller._focused=true
	main.controller._pointer_inside=true
	main.controller._window_size=root.size
	main.controller._screen=at(item[4])
	main.controller.refresh_view()
	await settle(5)
	if mode=="movie": AudioServer.set_bus_mute(0,false)

func step(item: Array, tick: int) -> void:
	main.controller._focused=true
	main.controller._pointer_inside=true
	main.controller._held=true
	main.controller._screen=at(item[4]+Vector2(sin(tick*.047)*22,cos(tick*.031)*9))
	if item[0]=="brush-soil": main.controller._screen=at(Vector2(lerpf(200,800,tick/119.0),310))
	main.controller._physics_process(1.0/60)
	feedback_tick()
	main.session.flush()

func snap(label: String) -> void:
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(out+label+".png")==OK,"capture "+label)
	evidence.captures.append(label+".png")

func functional() -> void:
	var reset:=state()
	evidence["models"] = []
	var names := ["brush","chisel","blower","pick"]
	for i in range(4):
		var proxy:Node3D = main.feedback.proxies[i]
		var meshes := proxy.find_children("*","MeshInstance3D",true,false)
		var triangles := 0
		check(meshes.size()==1,"one continuous authored mesh: "+names[i])
		for mesh:MeshInstance3D in meshes:
			for s in range(mesh.mesh.get_surface_count()):
				var arrays := mesh.mesh.surface_get_arrays(s)
				triangles += arrays[Mesh.ARRAY_INDEX].size()/3
				var material := mesh.get_active_material(s) as StandardMaterial3D
				check(arrays[Mesh.ARRAY_TEX_UV].size()>0 and material!=null and material.albedo_texture!=null and material.normal_enabled,"authored UV/albedo/normal imported: "+names[i])
		check(triangles>=5000 and triangles<=20000,"retopo runtime budget: "+names[i])
		check(proxy.find_children("*","CollisionObject3D",true,false).is_empty(),"tool art has no picking collider: "+names[i])
		evidence.models.append({"asset":names[i],"triangles":triangles})
	check(main.lamp_art.find_children("*","CollisionObject3D",true,false).is_empty() and main.lamp_art.find_children("*","Light3D",true,false).is_empty(),"lamp adds no collider or light")
	check(Engine.physics_ticks_per_second==60 and Engine.max_fps==240,"60Hz physics / 240FPS cap")
	check(main.candidate==1 and main.profile.fragmented,"locked B geometry and accepted fragmented Soil")
	var light:Transform3D=main.task_light.transform
	var settings:=[main.task_light.light_energy,main.task_light.light_color,main.task_light.spot_angle]
	main.toggle_sensory()
	check(state()==reset,"comparison preserves full excavation state")
	check(main.old_lamp.visible and not main.lamp_art.visible,"comparison shows old lamp only")
	main.toggle_sensory()
	check(not main.old_lamp.visible and main.lamp_art.visible,"comparison restores authored lamp only")
	check(state()==reset and main.task_light.transform==light and settings==[main.task_light.light_energy,main.task_light.light_color,main.task_light.spot_angle],"comparison preserves reset and accepted lighting")
	var expected:=[Vector3(40,.7,1.25),Vector3(22,.64,2.25),Vector3(60,0,1),Vector3(11,.44,1.75)]
	for i in range(4):
		var t:ToolDefinition=main.controller.tools[i]
		check(Vector3(t.radius,t.power,t.falloff)==expected[i],"native tool tuning "+str(i))
	var states:={}
	var poses:={}
	evidence["interactions"]=[]
	for sensory in [false,true]:
		if main.sensory_enabled!=sensory: main.toggle_sensory()
		for item in CASES:
			await prepare(item)
			if not sensory: poses[item[0]]=main.camera.global_transform
			else: main.camera.global_transform=poses[item[0]]
			var before:=state()
			var inside:=0
			var motion:=false
			var pose:Basis=main.feedback.proxies[item[2]].basis
			for tick in range(90):
				await physics_frame
				step(item,tick)
				if main.controller.hit.inside: inside+=1
				if main.feedback.proxies[item[2]].basis!=pose: motion=true
			main.controller.cancel_stroke()
			main.block.flush_texture()
			var after:=state()
			if not sensory: states[item[0]]=after
			else:
				for key in after:
					if after[key]!=states[item[0]][key]: print("STATE DIFFERENCE ",item[0]," ",key," ",states[item[0]][key]," / ",after[key])
				check(after==states[item[0]],"byte-identical gameplay P6A2/P6A3: "+item[0])
				check(inside==90,"native picking stays valid: "+item[0])
				check(motion,"input moves the tool: "+item[0])
				check(main.feedback.peak_particles<=416,"bounded VFX: "+item[0])
				if item[0]=="brush-clay":
					check(before.height==after.height and before.ceilings==after.ceilings,"dry Brush never excavates Clay")
					check(main.feedback.dry_contacts>0 and main.feedback.emitted[3]>0,"dry Clay contact receives real visual feedback")
				if item[0]=="brush-soil": check(main.feedback.emitted[0]>0,"Soil brushing emits fine grains")
				if item[0]=="bone-film": check(before.film!=after.film and before.condition==after.condition,"Brush cleans native Film without Condition damage")
				var row:={"case":item[0],"emitted":Array(main.feedback.emitted),"peak_particles":main.feedback.peak_particles,"motion_impacts":main.feedback.motion_impacts,"dry_contacts":main.feedback.dry_contacts,"audio_family":main.feedback.audio.last_family,"native_impacts":main.controller.total_impacts}
				evidence.interactions.append(row)
				print("SENSORY ",JSON.stringify(row))
	main.reset_specimen()
	check(main.feedback.particles[1].is_empty() and main.feedback.particles[3].is_empty(),"reset clears transient feedback")
	# Real UI blocker and focus rules cancel both simulation and presentation.
	main.controller._screen=main.session_ui.preparation_card.get_global_rect().get_center()
	main.controller._held=true
	main.controller._physics_process(1.0/60);feedback_tick()
	check(not main.controller.hit.inside and not main.feedback.working_last_tick,"UI receives no ground feedback")
	main.controller.notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
	feedback_tick()
	check(not main.controller._held and not main.feedback.working_last_tick,"focus loss releases tools and feedback")

func visual() -> void:
	var poses:={}
	for sensory in [false,true]:
		if main.sensory_enabled!=sensory: main.toggle_sensory()
		for item in CASES:
			await prepare(item)
			if not sensory: poses[item[0]]=main.camera.global_transform
			else: main.camera.global_transform=poses[item[0]]
			for tick in range(42):
				await physics_frame
				step(item,tick)
				if tick==28: await snap(("after-" if sensory else "before-")+item[0])
			main.controller.cancel_stroke()
	await prepare(CASES[0])
	await zoom_to(1)
	await snap("workbench-1x")
	main.toggle_sensory()
	await settle(4)
	await snap("workbench-before-1x")
	main.toggle_sensory()
	for item in [["brush-3x",0,0,3,Vector2(470,310)],["chisel-1x",1,1,1,Vector2(470,310)],["pick-1x",1,3,1,Vector2(470,310)],["blower-1x",1,2,1,Vector2(470,310)]]:
		await prepare(item)
		await snap(item[0])
	# Documentary wider view only; interactive camera limits remain untouched.
	await prepare(CASES[0])
	main.camera.set_process(false)
	main.camera.size=1.18
	main.feedback.proxies_enabled=false
	await settle(4)
	await snap("lamp-after-overview")
	main.toggle_sensory()
	main.feedback.proxies_enabled=false
	await settle(4)
	await snap("lamp-before-overview")

func benchmark() -> void:
	RenderingServer.viewport_set_measure_render_time(root.get_viewport_rid(),true)
	process_frame.connect(sample_frame)
	var cases:=[ ["reset-1x",0,0,1,Vector2(470,310)],["reset-3x",0,0,3,Vector2(470,310)] ]+CASES
	var poses:={}
	for sensory in [false,true]:
		if main.sensory_enabled!=sensory: main.toggle_sensory()
		for item in cases:
			await prepare(item)
			if not sensory: poses[item[0]]=main.camera.global_transform
			else: main.camera.global_transform=poses[item[0]]
			await settle(40)
			frames.clear();gpu.clear();render_cpu.clear();previous=0
			var edits:Array[float]=[];var draws:Array[float]=[];var fx:Array[float]=[]
			var contacts:Array[float]=[]
			measuring=true
			for tick in range(120):
				await physics_frame
				if not item[0].begins_with("reset"): step(item,tick)
				edits.append(main.controller.last_edit_usec/1000.0 if not item[0].begins_with("reset") else 0)
				draws.append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
				fx.append((main.feedback.last_proxy_usec+main.feedback.last_particles_usec)/1000.0)
				contacts.append(main.feedback.last_contact_usec/1000.0 if sensory else 0)
			measuring=false;main.controller.cancel_stroke()
			var row:={"sensory":sensory,"case":item[0],"zoom":item[3],"frame_ms":stats(frames),"gpu_ms":stats(gpu),"edit_ms":stats(edits),"feedback_ms":stats(fx),"draw_calls":stats(draws),"texture_bytes":Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED)}
			row["contact_feedback_ms"]=stats(contacts)
			if sensory: row["peak_particles"]=main.feedback.peak_particles
			evidence.benchmark.append(row)
			print("SENSORY BENCH ",JSON.stringify(row))

func movie() -> void:
	# Engine Movie Maker records actual engine rendering + mixed audio, no edits
	# to the gameplay rate. Each labeled segment drives the same native controller.
	var label:=Label.new()
	label.position=Vector2(690,22);label.add_theme_font_size_override("font_size",24)
	label.add_theme_color_override("font_color",Color(.95,.86,.68))
	main.session_ui.root_control.add_child(label)
	evidence["movie_segments"]=[]
	var poses:={}
	for sensory in [false,true]:
		if main.sensory_enabled!=sensory: main.toggle_sensory()
		for item in CASES:
			await prepare(item)
			if not sensory: poses[item[0]]=main.camera.global_transform
			else: main.camera.global_transform=poses[item[0]]
			label.text=("P6A3 · " if sensory else "P6A2 · ")+item[0]
			var start_frame:=Engine.get_frames_drawn()
			for tick in range(120):
				await physics_frame
				step(item,tick)
			main.controller.cancel_stroke()
			for n in range(20): await physics_frame
			evidence.movie_segments.append({"sensory":sensory,"case":item[0],"start_frame":start_frame,"end_frame":Engine.get_frames_drawn(),"fps":60})

func run() -> void:
	out="res://work/test-logs/p6a3/"
	DirAccess.make_dir_recursive_absolute(out)
	root.size=Vector2i(1920,1080);root.content_scale_size=root.size
	var args:=OS.get_cmdline_user_args()
	mode=args[0] if not args.is_empty() else "tests"
	AudioServer.set_bus_mute(0,mode!="movie")
	main=load("res://scenes/p6a3_tool_feel.tscn").instantiate()
	root.add_child(main)
	# The interactive display helper reads the user's saved window size on setup.
	# Restore the controlled review resolution after assembly; never persist QA.
	main.display.persist=false
	root.mode=Window.MODE_WINDOWED
	root.size=Vector2i(1920,1080)
	main.controller.set_physics_process(false)
	main.panel.hide()
	await settle()
	evidence["runtime"]={"engine":Engine.get_version_info().string,"gpu":RenderingServer.get_video_adapter_name(),"cpu":OS.get_processor_name(),"renderer":RenderingServer.get_current_rendering_method(),"window":str(root.size),"render_size":str(root.get_texture().get_size()),"fps_cap":Engine.max_fps,"physics_hz":Engine.physics_ticks_per_second}
	if mode=="tests": await functional()
	elif mode=="visual": await visual()
	elif mode=="benchmark": await benchmark()
	elif mode=="movie": await movie()
	evidence["checks"]=checks;evidence["failures"]=failures
	FileAccess.open(out+mode+".json",FileAccess.WRITE).store_string(JSON.stringify(evidence,"\t"))
	print("P6A3 ",mode,": ",checks," checks, ",failures.size()," failures")
	main.queue_free()
	await create_timer(.3).timeout
	quit(0 if failures.is_empty() else 1)
