extends "res://tests/run_p6a33_tactile.gd"
var imported_faces := PackedVector3Array()

const PILOT_STORE := "res://work/test-logs/p6a34/collection-test.json"

func geometry_checks() -> void:
	var field: FossilField = main.block.working_map.fossil.field
	var native := FossilField.new()
	var wrong := 0
	var old_skull_fallback := 0
	var old_rib_fallback := 0
	var selected_cells := 0
	for i in range(field.component_ids.size()):
		var selected: bool = native.component_ids[i] == 1 or (native.component_ids[i] == 3 and field.patch.old_rib_selection[i] != 0)
		if not selected and field.replacement[i] == 0:
			if native.component_ids[i] != field.component_ids[i] or native.ceilings[i] != field.ceilings[i]: wrong += 1
		if field.component_ids[i] == 1 and field.replacement[i] == 0: old_skull_fallback += 1
		if selected and native.component_ids[i] == 3 and field.component_ids[i] == 3 and field.replacement[i] == 0: old_rib_fallback += 1
		selected_cells += field.replacement[i]
	check(wrong == 0,"every unrelated native Bone cell retains exact ID and ceiling")
	check(old_skull_fallback == 0 and old_rib_fallback == 0,"tested pieces have no historical Bone fallback")
	check(field.native_occlusion_cells > 0,"higher existing vertebrae keep authority above rib joints")
	check(main.mesh_view.source_piece_count == 7 and main.mesh_view.meshes.size() == 1,"seven source pieces are batched into one rendering surface")
	var faces := PackedVector3Array()
	var triangle_count := 0
	for mesh: MeshInstance3D in main.mesh_view.meshes:
		var transform: Transform3D = main.block.global_transform.affine_inverse()*mesh.global_transform
		# Read exact render arrays: Mesh.get_faces() snaps its cached triangle
		# representation to 0.1 mm, which is unsuitable for this roof oracle.
		for surface in range(mesh.mesh.get_surface_count()):
			var arrays := mesh.mesh.surface_get_arrays(surface)
			var positions: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			for index in indices: faces.append((transform*positions[index])*1000.0)
			triangle_count += indices.size()/3
		check(mesh.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF,"hidden mesh cannot cast an outline shadow: "+str(mesh.name))
	check(triangle_count > 5000 and triangle_count <= 40000,"imported triangle budget matches the finalized source")
	check(main.mesh_view.model.find_children("*","CollisionObject3D",true,false).is_empty(),"display meshes add no tool-picking collision")
	# Independent triangle raster oracle. Millimetre coordinates avoid tiny-face
	# determinant tolerances in TriangleMesh ray helpers.
	imported_faces = faces
	var projected := PackedFloat32Array()
	projected.resize(1024*640)
	var present := PackedByteArray()
	present.resize(projected.size())
	for t in range(0,faces.size(),3):
		var va := faces[t]*.001
		var vb := faces[t+1]*.001
		var vc := faces[t+2]*.001
		var a := Vector2((va.x+.55)/1.1*1024,(va.z+.35)/.7*640)
		var b := Vector2((vb.x+.55)/1.1*1024,(vb.z+.35)/.7*640)
		var c := Vector2((vc.x+.55)/1.1*1024,(vc.z+.35)/.7*640)
		var ab := b-a
		var ac := c-a
		var determinant := ab.cross(ac)
		if absf(determinant) < .000001: continue
		var low := Vector2i(a.min(b).min(c).floor()).max(Vector2i.ZERO)
		var high := Vector2i(a.max(b).max(c).ceil()).min(Vector2i(1023,639))
		for y in range(low.y,high.y+1):
			for x in range(low.x,high.x+1):
				var ap := Vector2(x+.5,y+.5)-a
				var u := ap.cross(ac)/determinant
				var v := ab.cross(ap)/determinant
				if u < -.000001 or v < -.000001 or u+v > 1.000001: continue
				var index := y*1024+x
				projected[index] = maxf(projected[index],va.y+(vb.y-va.y)*u+(vc.y-va.y)*v)
				present[index] = 1
	var misses := 0
	var max_error := 0.0
	var samples := 0
	for i in range(field.patch.components.size()):
		if field.patch.components[i] == 0: continue
		if present[i] == 0: misses += 1
		else: max_error = maxf(max_error,absf(projected[i]-(.018+field.patch.ceilings[i]*.102)))
		samples += 1
	check(misses == 0 and samples > 9000,"every baked mesh cell is covered by the actual imported geometry")
	check(max_error < .000001,"all imported roof samples match the bake within one micrometre")
	evidence["geometry"] = {"triangles":triangle_count,"baked_samples":samples,"winning_mesh_cells":selected_cells,"native_joint_occlusion":field.native_occlusion_cells,"roof_max_error_m":max_error,"misses":misses}

func pilot_checks() -> void:
	geometry_checks()
	var baseline := state()
	var radius: float = main.controller.config.radius
	await press_key(KEY_F6)
	check(not main.mesh_enabled and state() == baseline and main.controller.config.radius == radius,"actual F6 selects relief without tuning or changing state")
	await press_key(KEY_F6)
	check(main.mesh_enabled and state() == baseline,"actual F6 restores the production mesh without reset")
	await press_key(KEY_F7)
	check(not main.readability_enabled and not main.mesh_view.enabled and state() == baseline,"F7 selects the historical feel without changing field or preparation")
	await press_key(KEY_F7)
	check(main.readability_enabled and main.mesh_view.enabled and main.controller.config.radius == radius and state() == baseline,"F7 restores the validated feel and production mesh without tuning")
	await press_key(KEY_F5)
	check(main.inspection.opened and main.controller.ui_blockers.has(main.inspection.root_control),"F5 opens isolated source inspection and blocks excavation input")
	main.controller._focused = true
	main.controller._pointer_inside = true
	var click := InputEventMouseButton.new()
	click.position = Vector2(960,540)
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	Input.parse_input_event(click)
	await process_frame
	check(not main.controller._held,"a real click in asset inspection cannot start an excavation stroke")
	click = InputEventMouseButton.new()
	click.position = Vector2(960,540)
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = false
	Input.parse_input_event(click)
	main.inspection.select_part(1)
	main.inspection.pivot.rotation = Vector3(.3,.6,0)
	await press_key(KEY_ESCAPE)
	check(not main.inspection.opened and state() == baseline,"inspection rotation and closing preserve the complete preparation state")
	var s: WorkingSurface = main.block.working_map
	P5Fixture.reveal(s,[100,100,100,100])
	var index := s.fossil.field.index_at_map(Vector2(240,220))
	check(s.fossil.exposed[index] != 0,"contact test targets real mesh-authored Bone")
	var point := Vector2(index%1024,index/1024)
	s.apply_impact(point,main.controller.tools[1])
	check(s.fossil.condition == 100 and main.local_damage.marks.is_empty(),"mesh-authored first Chisel contact remains protected")
	s.apply_impact(point,main.controller.tools[1])
	check(s.fossil.condition < 100 and main.local_damage.marks.size() == 1,"subsequent real impact damages the canonical Condition and only the local map")
	var height_before := digest(s.image.get_data())
	var tile := Vector2(floor(point.x/4)*4+1.5,floor(point.y/4)*4+1.5)
	var uv := (point+Vector2.ONE*.5)/Vector2(s.size)
	for n in range(4):
		var a := tile+Vector2(-12 if n%2==0 else 12,0)
		var b := tile+Vector2(12 if n%2==0 else -12,0)
		s.apply_continuous(a,b,main.controller.tools[0],.12)
		main.feedback._physics_process(.12)
	check(s.bone_film.value_at(uv) == 0 and main.feedback.film_puffs >= 2,"validated short Brush strokes clean actual mesh Bone and emit real removal dust")
	check(main.block.working_map.bone_film.moving_clear_multiplier == 2.4,"validated P6A3.3 Brush profile is inherited exactly")
	P5Fixture.clean(s)
	main.session.flush()
	check(main.session.preparation_complete and main.distinction.earned,"mesh-authored preparation can reach guarded full completion")
	check(main.session.archive() and main.session.archive_snapshot.integral_preparation,"archive retains the full preparation distinction")
	main.reset_specimen()
	check(s.fossil.exposed_cells == 0 and s.fossil.condition == 100 and main.local_damage.marks.is_empty(),"reset restores the new specimen and clears local damage")
	main.prepare_review_patch()
	var oracle := TriangleMesh.new()
	oracle.create_from_faces(imported_faces)
	var samples := 0
	var max_contact_error := 0.0
	for i in range(s.fossil.field.component_ids.size()):
		if i%37 != 0 or s.fossil.field.replacement[i] == 0: continue
		var interior := true
		for offset in [-2,2,-2048,2048]:
			if s.fossil.field.replacement[i+offset] == 0: interior = false
		if not interior: continue
		var screen := at(Vector2(i%1024,i/1024))
		var picked: Dictionary = main.block.pick(screen,main.camera)
		if not picked.inside or not picked.bone_exposed: continue
		var origin: Vector3 = main.block.to_local(main.camera.project_ray_origin(screen))
		var direction: Vector3 = main.block.global_basis.inverse()*main.camera.project_ray_normal(screen)
		var hit := oracle.intersect_ray(origin*1000.0,direction)
		if hit.is_empty(): continue
		max_contact_error = maxf(max_contact_error,(hit.position*.001).distance_to(picked.local))
		samples += 1
	check(samples >= 12 and max_contact_error < .0015,"actual camera-ray contacts match the visible mesh within the native grid tolerance")
	evidence["contact"] = {"samples":samples,"max_gap_m":max_contact_error}
	check(Engine.physics_ticks_per_second == 60 and Engine.max_fps == 240,"reference runtime cap and physics frequency preserved")

func skull_picture(label: String) -> Image:
	main.session_ui.notice_label.hide()
	return await super.skull_picture(label)

func pilot_visual() -> void:
	check(DisplayServer.get_name() != "headless","native graphical renderer is required")
	main.feedback.proxies_enabled = false
	main.feedback.set_physics_process(false)
	main.camera.set_process(false)
	var before := await skull_picture("intact-mesh")
	main.toggle_mesh()
	var after := await skull_picture("intact-relief")
	check(digest(before.get_data()) == digest(after.get_data()),"intact matrix is pixel-identical with mesh on/off")
	main.toggle_mesh()
	var s: WorkingSurface = main.block.working_map
	P5Fixture.reveal(s,[50,0,0,0])
	main.camera.set_process(true)
	await zoom_to(3,Vector2(266,233))
	main.camera.set_process(false)
	await skull_picture("partial-skull")
	main.reset_specimen()
	main.prepare_review_patch()
	P5Fixture.clean(s)
	main.camera.set_process(true)
	await zoom_to(1)
	main.camera.set_process(false)
	await skull_picture("prepared-overview")
	main.camera.set_process(true)
	await zoom_to(3,Vector2(266,233))
	main.camera.set_process(false)
	var mesh := await skull_picture("skull-mesh")
	var picked: Dictionary = main.block.pick(at(Vector2(240,220)),main.camera)
	var state_before := state()
	main.toggle_mesh()
	var relief := await skull_picture("skull-relief")
	check(digest(mesh.get_data()) != digest(relief.get_data()),"production geometry visibly changes the fully exposed Skull")
	check(state() == state_before and main.block.pick(at(Vector2(240,220)),main.camera) == picked,"mesh/relief comparison preserves real picking and preparation")
	main.toggle_mesh()
	s.fossil.contact_at(s.fossil.field.index_at_map(Vector2(240,220)),3,true)
	s.fossil.contact_at(s.fossil.field.index_at_map(Vector2(240,220)),3,true)
	await skull_picture("skull-local-damage")
	main.camera.set_process(true)
	await zoom_to(3,Vector2(424,329))
	main.camera.set_process(false)
	await skull_picture("rib-mesh")
	main.toggle_mesh()
	await skull_picture("rib-relief")
	main.toggle_mesh()
	var stable := state()
	main.inspection.toggle()
	main.inspection.select_part(0)
	await skull_picture("inspection-ensemble")
	main.inspection.select_part(1)
	await skull_picture("inspection-skull")
	main.inspection.pivot.rotation = Vector3(.65,.5,0)
	await skull_picture("inspection-skull-underside")
	main.inspection.select_part(2)
	await skull_picture("inspection-ribs")
	main.inspection.toggle()
	check(state() == stable,"all source-inspection views preserve preparation")
	main.camera.set_process(true)
	await zoom_to(1)
	main.camera.set_process(false)
	await settle(10)
	evidence["budget"] = []
	for enabled in [false,true]:
		if main.mesh_enabled != enabled: main.toggle_mesh()
		await settle(10)
		await RenderingServer.frame_post_draw
		var frame_ms: Array[float] = []
		for n in range(20):
			var began := Time.get_ticks_usec()
			await process_frame
			frame_ms.append((Time.get_ticks_usec()-began)/1000.0)
		frame_ms.sort()
		evidence.budget.append({"mesh":enabled,"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"primitives":Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),"texture_bytes":Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED),"frame_median_ms":frame_ms[10]})
	check(evidence.budget[1].primitives-evidence.budget[0].primitives == _expected_triangles()+_expected_shadow_triangles(),"source meshes and exposed casters add exactly their separate triangle budgets at overview")
	check(evidence.budget[1].draw_calls-evidence.budget[0].draw_calls <= 10,"production overlay stays within ten additional draw calls")
	check(state() == stable,"render sampling never changes preparation")


func run() -> void:
	out = _output_directory()
	DirAccess.make_dir_recursive_absolute(out)
	if FileAccess.file_exists(_collection_store()): DirAccess.remove_absolute(_collection_store())
	root.size = Vector2i(1280,720)
	AudioServer.set_bus_mute(0,true)
	var args := OS.get_cmdline_user_args()
	mode = args[0] if not args.is_empty() else "tests"
	main = _pilot_scene().instantiate()
	root.add_child(main)
	main.display.persist = false
	root.mode = Window.MODE_WINDOWED
	root.size = Vector2i(1280,720)
	main.controller.set_physics_process(false)
	main.panel.hide()
	await settle()
	if mode == "visual": await pilot_visual()
	else: await pilot_checks()
	evidence["runtime"] = {"engine":Engine.get_version_info().string,"adapter":RenderingServer.get_video_adapter_name(),"physics_hz":Engine.physics_ticks_per_second,"render_cap":Engine.max_fps}
	evidence["checks"] = checks
	evidence["failures"] = failures
	FileAccess.open(out+mode+".json",FileAccess.WRITE).store_string(JSON.stringify(evidence,"\t"))
	print(_suite_name()," ",mode,": ",checks," checks, ",failures.size()," failures")
	main.queue_free()
	await create_timer(.3).timeout
	quit(0 if failures.is_empty() else 1)

func _pilot_scene() -> PackedScene:
	return preload("res://scenes/p6a34_production_pilot.tscn")
func _output_directory() -> String:
	return "res://work/test-logs/p6a34/"
func _expected_triangles() -> int:
	return 26562

func _expected_shadow_triangles() -> int:
	return 0
func _collection_store() -> String:
	return PILOT_STORE

func _suite_name() -> String:
	return "P6A3.4"
