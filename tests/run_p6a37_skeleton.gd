extends "res://tests/run_p6a35_aesthetic.gd"
func _pilot_scene() -> PackedScene:
	return preload("res://scenes/p6a37_modeled_skeleton.tscn")
func _output_directory() -> String:
	return "res://work/test-logs/p6a37/"
func _expected_triangles() -> int:
	return int(_manifest().triangles)
func _expected_source_pieces() -> int:
	return _manifest().parts.size()
func _triangle_budget() -> int:
	return 100000
func _expects_native_occlusion() -> bool:
	return false
func _selected_native(_field: FossilField, native: FossilField, i: int) -> bool:
	return native.component_ids[i] != 0
func _collection_store() -> String:
	return "res://work/test-logs/p6a37/collection-test.json"
func _suite_name() -> String:
	return "P6A3.7"
func _contact_point() -> Vector2:
	return Vector2(235,243)
func _manifest() -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string("res://assets/p6a37/production-manifest.json"))

func pilot_checks() -> void:
	await super.pilot_checks()
	var field: FossilField = main.block.working_map.fossil.field
	var previous: FossilField = load("res://scripts/p6a36/mesh_fossil_field.gd").new()
	var wrong_skull := 0
	var legacy := 0
	for i in range(field.component_ids.size()):
		if (field.component_ids[i] == 1 or previous.component_ids[i] == 1) and (field.component_ids[i] != previous.component_ids[i] or field.ceilings[i] != previous.ceilings[i]): wrong_skull += 1
		if field.component_ids[i] != 0 and field.replacement[i] == 0: legacy += 1
	check(wrong_skull == 0,"approved skull field and ceilings are preserved exactly")
	check(legacy == 0 and field.native_occlusion_cells == 0,"every B-17 bone comes from the new source without raster fallback")
	for component in range(1,5): check(field.component_totals[component] > 1000,"all four canonical preparation components remain populated: "+str(component))
	var current_source: Node3D = load("res://assets/p6a37/b17_skeleton.glb").instantiate()
	var approved_source: Node3D = load("res://assets/p6a36/b17_production_patch.glb").instantiate()
	var current_skull: MeshInstance3D = current_source.find_child("*Skull*",true,false)
	var approved_skull: MeshInstance3D = approved_source.find_child("*Skull*",true,false)
	var equal := current_skull.mesh.get_surface_count() == approved_skull.mesh.get_surface_count()
	for surface in range(current_skull.mesh.get_surface_count()):
		var a := current_skull.mesh.surface_get_arrays(surface)
		var b := approved_skull.mesh.surface_get_arrays(surface)
		for attribute in [Mesh.ARRAY_VERTEX,Mesh.ARRAY_NORMAL,Mesh.ARRAY_TEX_UV,Mesh.ARRAY_COLOR,Mesh.ARRAY_INDEX]:
			if var_to_bytes(a[attribute]) != var_to_bytes(b[attribute]): equal = false
	check(equal,"approved skull imported vertices, normals, UV, AO and indices are byte-identical")
	current_source.free()
	approved_source.free()
	var stable := state()
	main.inspection.toggle()
	for part in range(5):
		main.inspection.select_part(part)
		var visible := 0
		for mesh in main.inspection.meshes:
			if mesh.visible: visible += 1
		check(visible > 0,"inspection frames a real source region: "+str(part))
	main.inspection.select_part(2)
	var scale: float = main.inspection.camera.size
	main.inspection.toggle_reference()
	main.inspection.toggle_shape_study()
	check(main.inspection.using_previous and main.inspection.shape_study and main.inspection.camera.size == scale,"rib reference and shape study retain comparison scale")
	main.inspection.select_part(3)
	check(not main.inspection.using_previous and main.inspection.reference_button.disabled,"new vertebra inspection does not pretend the previous pilot had vertebra meshes")
	main.inspection.toggle_shape_study()
	main.inspection.toggle()
	check(state() == stable,"all source-region controls preserve the full preparation")
	main.reset_specimen()
	var s: WorkingSurface = main.block.working_map
	var sites := [Vector2(235,243),Vector2(480,307),Vector2(441,360),Vector2(628,383)]
	for component in range(1,5):
		var p: Vector2 = sites[component-1]
		check(field.component_ids[field.index_at_map(p)] == component,"contact sample is on its intended modeled component: "+str(component))
		var hidden: Dictionary = main.block.pick(at(p),main.camera)
		check(not hidden.bone_exposed and not hidden.get("mesh_contact_refined",false),"buried component keeps matrix picking: "+str(component))
	P5Fixture.reveal(s,[100,100,100,100])
	for component in range(1,5):
		var p: Vector2 = sites[component-1]
		var hit: Dictionary = main.block.pick(at(p),main.camera)
		check(hit.bone_exposed and hit.get("mesh_contact_refined",false),"exposed modeled component refines actual triangle contact: "+str(component))
		var condition: float = s.fossil.condition
		var marks: int = main.local_damage.marks.size()
		s.apply_impact(p,main.controller.tools[1])
		check(s.fossil.condition == condition and main.local_damage.marks.size() == marks,"first Chisel contact remains protected per component: "+str(component))
		s.apply_impact(p,main.controller.tools[1])
		check(s.fossil.condition < condition and main.local_damage.marks.size() == marks+1,"subsequent damage is committed locally on component: "+str(component))
		var tile := Vector2(floor(p.x/4)*4+1.5,floor(p.y/4)*4+1.5)
		for n in range(4): s.apply_continuous(tile+Vector2(-12 if n%2==0 else 12,0),tile+Vector2(12 if n%2==0 else -12,0),main.controller.tools[0],.12)
		check(s.bone_film.value_at((p+Vector2.ONE*.5)/Vector2(s.size)) == 0,"accepted short Brush strokes clean this modeled component: "+str(component))
	main.reset_specimen()
	P5Fixture.reveal(s,[30,30,30,30])
	await settle()
	var caster_set := {}
	for i in main.mesh_view.caster_cells: caster_set[i] = true
	var wrong := 0
	for i in range(field.component_ids.size()):
		var wanted: bool = field.replacement[i] != 0 and s.fossil.exposed[i] != 0 and s._heights[i] <= field.ceilings[i]+FossilField.EXPOSURE_EPSILON
		if caster_set.has(i) != wanted: wrong += 1
	check(wrong == 0,"partial reveal across every anatomical region submits no buried casting cell")
	var shadow_arrays: Array = main.mesh_view.shadow_caster.mesh.surface_get_arrays(0)
	var submitted: PackedInt32Array = shadow_arrays[Mesh.ARRAY_INDEX]
	var safe_indices: bool = submitted.size() == main.mesh_view.caster_cells.size()*6
	for n in range(main.mesh_view.caster_cells.size()):
		var cell: int = main.mesh_view.caster_cells[n]
		for j in range(6):
			@warning_ignore("integer_division")
			if submitted[n*6+j]/4 != main.mesh_view.cell_slots[cell]: safe_indices = false
	check(safe_indices,"bulk shadow runs submit exactly the exposed cell indices across all components")
	main.reset_specimen()
	var review_started := Time.get_ticks_usec()
	main.prepare_native_skeleton_review()
	evidence["native_review_cost"] = {"impacts":main.native_review_impacts,"seconds":(Time.get_ticks_usec()-review_started)/1000000.0}
	for component in range(1,5): check(s.fossil.exposure_percent(component) == 100,"unchanged native Pick can reveal every modeled component fully: "+str(component))
	check(s.fossil.condition == 100,"native complete-skeleton review preserves perfect Condition")
	P5Fixture.clean(s)
	main.session.flush()
	check(main.session.preparation_complete and main.distinction.earned,"full new skeleton reaches real guarded 100/100 completion")
	evidence["native_skeleton_review"] = main.session.snapshot()
	main.reset_specimen()

func pilot_visual() -> void:
	await super.pilot_visual()
	var stable := state()
	main.inspection.toggle()
	for part in [0,2,3,4]:
		main.inspection.select_part(part)
		await skull_picture("modeled-source-"+str(part)+"-ivory")
		main.inspection.pivot.rotation = Vector3(.55,.25,0)
		await skull_picture("modeled-source-"+str(part)+"-three-quarter")
		main.inspection.toggle_shape_study()
		await skull_picture("modeled-source-"+str(part)+"-shape")
		main.inspection.toggle_shape_study()
	main.inspection.select_part(2)
	main.inspection.toggle_reference()
	await skull_picture("previous-ribs-reference")
	main.inspection.toggle_reference()
	main.inspection.toggle()
	check(state() == stable,"complete anatomical source review never alters preparation")
	main.prepare_native_skeleton_review()
	main.camera.set_process(true)
	await zoom_to(1)
	main.camera.set_process(false)
	await skull_picture("native-skeleton-dirty")
	P5Fixture.clean(main.block.working_map)
	await skull_picture("native-skeleton-clean")
	for target in [Vector2(430,352),Vector2(520,308),Vector2(624,423),Vector2(642,523)]:
		main.camera.set_process(true)
		await zoom_to(3,target)
		main.camera.set_process(false)
		await skull_picture("native-detail-"+str(int(target.x))+"-"+str(int(target.y)))
	evidence["native_skeleton_review"] = main.session.snapshot()

	# Measure adjacent completed draws with one persistent timestamp, so loop
	# bookkeeping is included rather than excluded from the frame interval.
	main.camera.set_process(true)
	await zoom_to(1)
	main.camera.set_process(false)
	await settle(10)
	await RenderingServer.frame_post_draw
	var previous_draw := Time.get_ticks_usec()
	var intervals: Array[float] = []
	for n in range(30):
		await RenderingServer.frame_post_draw
		var now := Time.get_ticks_usec()
		intervals.append((now-previous_draw)/1000.0)
		previous_draw = now
	intervals.sort()
	evidence["completed_draw_intervals"] = {"samples":30,"median_ms":intervals[15],"p95_ms":intervals[28],"min_ms":intervals[0],"max_ms":intervals[29]}

	# A wall-clock frame-counter sample complements individual signal timings,
	# which can include asynchronous renderer scheduling and viewport work.
	var frame_counter := Engine.get_frames_drawn()
	var wall_started := Time.get_ticks_usec()
	await create_timer(1.0).timeout
	var wall_seconds := (Time.get_ticks_usec()-wall_started)/1000000.0
	evidence["steady_native_frames"] = {"frames":Engine.get_frames_drawn()-frame_counter,"seconds":wall_seconds,"average_fps":(Engine.get_frames_drawn()-frame_counter)/wall_seconds,"engine_reported_fps":Engine.get_frames_per_second()}
