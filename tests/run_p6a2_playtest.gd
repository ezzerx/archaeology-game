extends "res://tests/run_p6a2_hero.gd"
## Isolated presentation/Soil tests; inherited native fixtures are unchanged.

func morphology(top: PackedFloat32Array, substrate: PackedFloat32Array) -> Dictionary:
	var size: Vector2i = main.block.working_map.size
	var visited := PackedByteArray()
	visited.resize(top.size())
	var areas: Array[int] = []
	var covered := 0
	var total_mm := 0.0
	var max_mm := 0.0
	var bounds_mm: Array[float] = []
	for i in range(top.size()):
		var thickness := (top[i]-substrate[i])*102
		total_mm += thickness
		max_mm = maxf(max_mm,thickness)
		if thickness <= .01: visited[i] = 1
		else: covered += 1
	for start in range(top.size()):
		if visited[start]: continue
		var queue := PackedInt32Array([start])
		visited[start] = 1
		var cursor := 0
		var lo := Vector2i(start%size.x,start/size.x)
		var hi := lo
		while cursor < queue.size():
			var i := queue[cursor]
			cursor += 1
			var cell := Vector2i(i%size.x,i/size.x)
			lo = lo.min(cell);hi = hi.max(cell)
			# Eight neighbours count diagonal bridges as continuous as well.
			for offset in [Vector2i(-1,-1),Vector2i(0,-1),Vector2i(1,-1),Vector2i(-1,0),Vector2i(1,0),Vector2i(-1,1),Vector2i(0,1),Vector2i(1,1)]:
				var next: Vector2i = cell+offset
				if next.x<0 or next.y<0 or next.x>=size.x or next.y>=size.y: continue
				var j := next.y*size.x+next.x
				if not visited[j]: visited[j]=1;queue.append(j)
		areas.append(queue.size())
		bounds_mm.append((Vector2(hi-lo+Vector2i.ONE)*Vector2(1100,700)/Vector2(size)).length())
	areas.sort();bounds_mm.sort()
	return {"coverage":float(covered)/top.size(),"components":areas.size(),"largest_component_fraction":float(areas[-1])/top.size(),"largest_share_of_soil":float(areas[-1])/covered,"component_area_cells_p50":areas[areas.size()/2],"component_area_cells_p95":areas[int(areas.size()*.95)],"largest_bounds_diagonal_mm":bounds_mm[-1],"mean_thickness_mm":total_mm/top.size(),"max_thickness_mm":max_mm,"threshold_mm":.01,"connectivity":8}

func functional() -> void:
	var p = main.profile
	var s: WorkingSurface = main.block.working_map
	var old := morphology(p.thin_tops[1],p.substrates[1])
	var fresh := morphology(p.fragmented_top,p.substrates[1])
	evidence["morphology"] = {"before":old,"after":fresh}
	print("SOIL MORPHOLOGY ",JSON.stringify(evidence.morphology))
	check(fresh.largest_component_fraction < old.largest_component_fraction*.25,"large continuous Soil islands substantially reduced")
	check(fresh.coverage>.15 and fresh.coverage<.5,"Soil retained with clearly open Clay gaps")
	check(fresh.components>old.components*2 and fresh.max_thickness_mm<2.00002,"fragmented and thin real Soil")
	var before := state()
	main.set_patina(false)
	check(state()==before,"patina remains a separate visual-only switch")
	main.set_patina(true)
	brush_pass()
	check(soil_line_count()==0,"native Brush clears fragmented Soil quickly")
	var below := 0
	for i in range(s._heights.size()):
		if s._heights[i]<p.substrates[1][i]: below+=1
	check(below==0,"Brush never alters Clay substrate")
	# Historical invariant tests remain valid with the old Soil witness selected.
	p.fragmented=false
	main.reset_specimen()
	await super.functional()
	p.fragmented=true
	main.reset_specimen()
	check(s._heights==p.fragmented_top,"reset restores new Soil without changing B strata")
	await presentation_checks()

func presentation_checks() -> void:
	var initial := state()
	var ui:PreparationUI = main.session_ui
	check(ui.exposure_label.text=="0%" and ui.cleanliness_label.text=="0%" and ui.condition_label.text.contains("Excellent"),"paper UI retains Reveal / Clean / Condition")
	check(not ui.archive_button.visible and not ui.keep_button.visible,"no premature completion actions")
	main.controller._held=true
	main.controller.notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
	check(not main.controller._held,"focus loss cancels tool stroke")
	main.controller.notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_IN)
	var rect:=ui.preparation_card.get_global_rect()
	main.controller._screen=rect.get_center()
	check(not main.controller._pick_current().inside,"paper card still blocks excavation input")
	var tris:=0
	var faces:=PackedVector3Array()
	for mesh: MeshInstance3D in main.desk_art.find_children("*","MeshInstance3D",true,false):
		for vertex in mesh.mesh.get_faces(): faces.append(mesh.global_transform*vertex)
		tris+=mesh.mesh.get_faces().size()/3
	check(main.desk_art.find_children("*","CollisionObject3D",true,false).is_empty(),"desk art has no collisions")
	var blocked:=0
	# Floor-depth samples around every edge and a coarse grid. The fixed camera
	# direction means this same ray visibility applies throughout 1x–3x zoom.
	for y in range(0,15):
		for x in range(0,23):
			var point:=Vector3(lerpf(-.5499,.5499,x/22.0),.018,lerpf(-.3499,.3499,y/14.0))
			var screen:Vector2=main.camera.unproject_position(point)
			var origin:Vector3=main.camera.project_ray_origin(screen)
			var direction:Vector3=main.camera.project_ray_normal(screen)
			for j in range(0,faces.size(),3):
				var hit=Geometry3D.ray_intersects_triangle(origin,direction,faces[j],faces[j+1],faces[j+2])
				if hit!=null and origin.distance_to(hit)<origin.distance_to(point): blocked+=1;break
	check(blocked==0,"lamp and props leave 345 floor-depth core rays unobstructed")
	evidence["desk"]={"triangles":tris,"occluded_core_rays":blocked,"tested_rays":345,"new_lights":0,"accessories":2}
	check(state()==initial,"presentation and focus tests preserve excavation")
	# UI actions use actual emitted button signals, not a replacement session.
	var s:WorkingSurface=main.block.working_map
	P5Fixture.reveal(s,[100,100,100,100]);P5Fixture.clean(s);main.session.flush()
	var completed:=state()
	ui.keep_button.pressed.emit()
	check(main.session.keep_cleaning_chosen and main.session.can_use_tools() and state()==completed,"styled Keep Cleaning preserves work and tools")
	ui.archive_button.pressed.emit()
	check(main.session.archived and ui.modal.visible and not main.session.can_use_tools(),"styled Archive opens museum card and locks tools")
	ui.another_button.pressed.emit()
	check(state()==initial and main.session.can_use_tools(),"styled Another Block restores fragmented initial state")
	main.select_fixture(2)
	await settle()
	# Deletion is native; the render-key list intentionally has not caught up.
	for y in range(200,320,20):
		main.block.working_map.apply_continuous(Vector2(380,y),Vector2(580,y),main.controller.tools[2],3.0)
	main.block.flush_texture();main.session.flush()
	var post_blower:=state()
	main.set_hero_look(false);main.set_hero_look(true)
	check(state()==post_blower,"look switch immediately after Blower preserves pending debris deletion")
	main.reset_specimen()

func display_checks() -> void:
	var previous_mode:=root.mode
	var previous_size:=root.size
	var initial:=state()
	evidence["display"]=[]
	for dimensions in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2560,1440),Vector2i(1600,1000)]:
		root.size=dimensions
		await settle(12)
		var logical:=root.get_visible_rect().size
		var errors:=0
		for zoom in [1,3]:
			await zoom_to(zoom)
			for cell in [Vector2(180,150),Vector2(520,350),Vector2(800,520)]:
				var pixel:=at(cell)
				if not Rect2(Vector2.ZERO,logical).has_point(pixel): continue
				var hit:Dictionary=main.block.pick(pixel,main.camera)
				if not hit.inside or (hit.uv*Vector2(main.block.map_resolution)-Vector2.ONE*.5).distance_to(cell)>.05: errors+=1
		check(errors==0,"logical pointer mapping after resize "+str(dimensions))
		check(Rect2(Vector2.ZERO,logical).encloses(main.session_ui.preparation_card.get_global_rect()),"paper card fits "+str(dimensions))
		check(Rect2(Vector2.ZERO,logical).encloses(main.toolbar.get_global_rect()),"tool strip fits "+str(dimensions))
		await zoom_to(1)
		evidence.display.append({"requested":str(dimensions),"actual_window":str(root.size),"logical_viewport":str(logical),"pick_errors":errors})
		await capture("display-"+str(dimensions.x)+"x"+str(dimensions.y))
	main.controller._held=true
	var key:=InputEventKey.new();key.physical_keycode=KEY_ENTER;key.alt_pressed=true;key.pressed=true
	root.push_input(key)
	await settle(15)
	check(root.mode==Window.MODE_FULLSCREEN and not main.controller._held,"Alt+Enter fullscreen cancels active stroke")
	await capture("display-native-fullscreen")
	evidence["fullscreen"]={"window":str(root.size),"image":str(root.get_texture().get_image().get_size()),"logical":str(root.get_visible_rect().size),"screen":str(DisplayServer.screen_get_size(root.current_screen)),"screen_scale":DisplayServer.screen_get_scale(root.current_screen),"screen_dpi":DisplayServer.screen_get_dpi(root.current_screen)}
	key=InputEventKey.new();key.physical_keycode=KEY_ESCAPE;key.pressed=true
	root.push_input(key)
	await settle(10)
	check(root.mode==Window.MODE_WINDOWED,"Escape exits fullscreen")
	check(state()==initial and Engine.physics_ticks_per_second==60 and Engine.max_fps==240,"all display transitions preserve simulation and session")
	root.mode=previous_mode;root.size=previous_size
	await settle(10)

func benchmark() -> void:
	RenderingServer.viewport_set_measure_render_time(root.get_viewport_rid(),true)
	process_frame.connect(sample_frame)
	var cases:=[ ["reset",0,0,1],["reset",0,0,3],["brush_soil",0,0,1],["chisel",1,1,1],["pick_near_bone",3,3,3],["blower_debris",2,2,1],["bone_film",3,0,3] ]
	var trials:=[false,true]
	var poses:={}
	if "benchmark-native" in OS.get_cmdline_user_args():
		root.mode=Window.MODE_FULLSCREEN
		await settle(20)
		cases=cases.slice(0,3)
		trials=[true]
		evidence.runtime["native_window"]=str(root.size)
		evidence.runtime["native_image"]=str(root.get_texture().get_image().get_size())
	var soil_center:=Vector2(470,255)
	var p=main.profile
	for y in range(210,300):
		for x in range(390,560):
			var i:int=y*p.size.x+x
			if (p.fragmented_top[i]-p.substrates[1][i])*102>1.0 and (p.thin_tops[1][i]-p.substrates[1][i])*102>1.0:
				soil_center=Vector2(x,y);break
	for trial in trials:
		main.profile.fragmented=trial
		main.set_hero_look(true)
		main.desk_art.visible=trial
		for item in cases:
			main.select_fixture(item[1]);main.select_candidate(1)
			main.controller.select_tool(item[2])
			var center:=Vector2(280,245) if item[0] in ["bone_film","pick_near_bone"] else (soil_center if item[0]=="brush_soil" else Vector2(470,255))
			await zoom_to(item[3],center)
			var pose_key:String=str(item)
			if not poses.has(pose_key): poses[pose_key]=main.camera.global_transform
			else:
				# Soil changes the anchor's height by fractions of a millimetre.
				# Copy the reference pose explicitly for a strict camera A/B.
				main.camera.global_transform=poses[pose_key]
			await settle(30)
			if trial and trials.size()>1: check(main.camera.global_transform==poses[pose_key],"exact camera A/B "+pose_key)
			frames.clear();gpu.clear();render_cpu.clear();previous=0
			var edits:Array[float]=[];var draws:Array[float]=[]
			measuring=true
			for tick in range(120):
				await physics_frame
				main.controller._focused=true;main.controller._pointer_inside=true
				main.controller._held=item[0]!="reset"
				main.controller._screen=at(center+Vector2(sin(tick*.026)*28,cos(tick*.02)*12))
				main.controller._physics_process(1.0/60)
				main.session.flush()
				edits.append(main.controller.last_edit_usec/1000.0)
				draws.append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
			measuring=false;main.controller.cancel_stroke()
			var row:={"new_soil_and_desk":trial,"kind":item[0],"zoom":item[3],"frame_ms":stats(frames),"gpu_ms":stats(gpu),"edit_ms":stats(edits),"draw_calls":stats(draws),"texture_memory_bytes":Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED)}
			row["camera"]=str(main.camera.global_transform)
			row["camera_size"]=main.camera.size
			evidence.benchmark.append(row)
			check(row.frame_ms.p95<16.667 and row.gpu_ms.mean>0,"frame/GPU "+str(item)+str(trial))
			print("PLAYTEST BENCH ",JSON.stringify(row))

func visual() -> void:
	var closeup_pose:=Transform3D.IDENTITY
	for old in [true,false]:
		main.profile.fragmented=not old
		hero_state(0)
		main.set_hero_look(true)
		await zoom_to(1)
		await capture("soil-"+("before" if old else "after")+"-1x")
		main.set_patina(false)
		await capture("soil-"+("before" if old else "after")+"-no-patina")
		main.set_patina(true)
		await zoom_centered(3,Vector2(420,290))
		if old: closeup_pose=main.camera.global_transform
		else:
			main.camera.global_transform=closeup_pose
			await settle()
			check(main.camera.global_transform==closeup_pose,"exact 3x Soil comparison camera")
		await capture("soil-"+("before" if old else "after")+"-3x")
	main.profile.fragmented=true
	main.set_hero_look(true)
	hero_state(1)
	await zoom_to(1)
	await capture("soil-part-brushed")
	main.select_fixture(1)
	await capture("soil-cleared")
	hero_state(4)
	await capture("bone-prepared")
	var s: WorkingSurface=main.block.working_map
	P5Fixture.reveal(s,[100,100,100,100]);P5Fixture.clean(s);main.session.flush()
	await capture("ready-to-archive")
	main.session.keep_cleaning()
	await capture("keep-cleaning")
	main.session.archive()
	await create_timer(.4).timeout
	await capture("archive")

func run() -> void:
	out="res://work/test-logs/p6a2-playtest/"
	DirAccess.make_dir_recursive_absolute(out)
	root.size=Vector2i(1920,1080);root.content_scale_size=root.size
	AudioServer.set_bus_mute(0,true)
	main=load("res://scenes/p6a2_hero_patch.tscn").instantiate()
	root.add_child(main)
	evidence["runtime"]={"engine":Engine.get_version_info().string,"cpu":OS.get_processor_name(),"gpu":RenderingServer.get_video_adapter_name(),"renderer":RenderingServer.get_current_rendering_method(),"window":str(root.size),"render":str(root.get_texture().get_size()),"fps_cap":Engine.max_fps,"physics_hz":Engine.physics_ticks_per_second}
	main.controller.set_physics_process(false)
	await settle()
	var args:=OS.get_cmdline_user_args()
	var mode:String=args[0] if not args.is_empty() else "visual"
	if mode=="tests": await functional()
	elif mode in ["benchmark","benchmark-native"]: await benchmark()
	elif mode=="display": await display_checks()
	else: await visual()
	evidence["checks"]=checks;evidence["failures"]=failures
	FileAccess.open(out+mode+".json",FileAccess.WRITE).store_string(JSON.stringify(evidence,"\t"))
	print("P6A2 PLAYTEST ",mode,": ",checks," checks, ",failures.size()," failures")
	main.queue_free()
	await create_timer(.5).timeout
	quit(0 if failures.is_empty() else 1)
