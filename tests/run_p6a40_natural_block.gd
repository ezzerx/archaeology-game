extends "res://tests/run_p6a37_skeleton.gd"
func _pilot_scene() -> PackedScene:
	return preload("res://scenes/preparation/base/natural_block.tscn")
func _output_directory() -> String:
	return "res://work/test-logs/p6a40/"
func _collection_store() -> String:
	return "res://work/test-logs/p6a40/collection-test.json"
func _suite_name() -> String:
	return "P6A4.0"
func pilot_checks() -> void:
	await super.pilot_checks()
	main.reset_specimen()
	var s: WorkingSurface = main.block.working_map
	var shape: RefCounted = main.block.footprint
	var lost_bone := 0
	for i in shape.outside:
		if s.fossil.field.component_ids[i] != 0: lost_bone += 1
	check(lost_bone == 0 and shape.outside.size() > 50000,"natural cuts remove rectangle corners while retaining every approved Bone cell")
	var reference: FossilField = load("res://scripts/specimens/skeleton/mesh_fossil_field.gd").new()
	check(reference.image.get_data() == s.fossil.field.image.get_data(),"entire approved source-derived Bone field is byte-identical")
	check(main.block.natural_wall.mesh.get_surface_count() == 1 and not main.jacket.visible,"actual silhouette walls replace the rectangular support jacket")
	check(main.matrix_edges.edges.count(255) == 0,"intact matrix correction mask contains no buried Bone hint")
	for fixture_id in [0,1,2,3,4]:
		main.select_fixture(fixture_id)
		var wrong := 0
		for i in shape.outside:
			if s._heights[i] != 0: wrong += 1
		check(wrong == 0,"reset/review fixture contains no material outside the footprint: "+str(fixture_id))
	main.reset_specimen()
	main.camera.reset_view()
	var outside_hits := 0
	var inside_misses := 0
	for cell in [Vector2(20,20),Vector2(1000,20),Vector2(20,620),Vector2(1000,620)]:
		if main.block.pick(at(cell),main.camera).inside: outside_hits += 1
	for cell in [Vector2(220,210),Vector2(512,100),Vector2(640,450)]:
		if not main.block.pick(at(cell),main.camera).inside: inside_misses += 1
	check(outside_hits == 0 and inside_misses == 0,"ray picking rejects every removed corner and retains interior access")
	var direct: Dictionary = main.block.relief.ray_hit(Vector3(-.55,.04,-.335),Vector3.RIGHT,1.1)
	check(direct.is_empty(),"a grazing ray cannot select top through a solid irregular side wall")
	var physics: TerrainDebris = s.loose_debris.physics
	check(physics.spawn(Vector3(-.53,.13,-.33),Vector3.ZERO,Vector3.ONE*.003,1,0) == -1,"debris cannot spawn on an invisible rectangular corner")
	var edge_cell := Vector2i(-1,-1)
	var edge_key := Vector3i.ZERO
	for segment in shape.edge_segments:
		var cell := Vector2i(segment.x,segment.y)
		if cell.x >= 1024 or cell.y >= 640 or shape.mask[cell.y*1024+cell.x] == 0: continue
		@warning_ignore("integer_division")
		var key := Vector3i(cell.x/8,cell.y/8,1)
		var jitter: Vector2 = s.loose_debris._spawn_point(key)
		if not shape.contains_uv((jitter+Vector2.ONE*.5)/Vector2(1024,640)):
			edge_cell = cell;edge_key = key;break
	check(edge_cell.x >= 0,"test finds a real occupied border bin whose historical jitter lands outside the new shape")
	s.loose_debris.deposit_removed(edge_cell.x,edge_cell.y,.2,1)
	var slot: int = s.loose_debris.physical_slots.get(edge_key,-1)
	check(slot >= 0 and shape.contains_uv(SurfaceMapping.local_to_uv(physics.fragments[slot].position,main.block.surface_size)),"real removed material retains its owner and spawns on the solid part of its edge bin")
	if slot >= 0:
		var f: TerrainDebris.Fragment = physics.fragments[slot]
		f.position.y += .03
		f.velocity = Vector3(f.position.x,.1,f.position.z).normalized()*.6
	for n in range(60): physics.advance(1.0/60)
	check(slot >= 0 and physics.ejected_count > 0 and physics.active_count == 0 and not s.loose_debris.cells.has(edge_key),"a real owned crumb exits the natural boundary and releases logical state instead of sleeping on a ghost corner")
	for n in range(2):
		main.toggle_look();main.toggle_sensory();main.toggle_task_light()
	check(not main.lamp_art.is_visible_in_tree() and not main.old_lamp.is_visible_in_tree() and main.task_light.visible,"decorative lamp never returns over the block through look/tool/light comparisons")
	check(main.task_light.position == Vector3(0,.8,-.265),"actual warm centred illumination remains at its accepted pose")
	P5Fixture.reveal(s,[35,0,0,0])
	main.matrix_edges.sync()
	var invalid := 0
	for i in range(main.matrix_edges.edges.size()):
		if main.matrix_edges.edges[i] == 0: continue
		var found := false
		for offset in [-1025,-1024,-1023,-1,1,1023,1024,1025]:
			if s.fossil.exposed[i+offset] != 0: found = true
		if not found or s.fossil.field.component_ids[i] != 0: invalid += 1
	check(invalid == 0 and main.matrix_edges.edges.count(255) > 0,"every material correction cell borders actually exposed Bone and contains no Bone itself")
	var uploads: int = main.matrix_edges.uploads
	for n in range(10): main.matrix_edges.sync()
	check(main.matrix_edges.uploads == uploads,"idle frames never upload the matrix correction texture")
	main.reset_specimen()
	check(main.matrix_edges.edges.count(255) == 0 and main.matrix_edges.pending.is_empty(),"reset synchronously clears the entire material correction")
	evidence["footprint"] = {"outside_cells":shape.outside.size(),"boundary_segments":shape.edge_segments.size(),"lost_bone_cells":lost_bone}

func frame_image() -> Image:
	await settle(4)
	await RenderingServer.frame_post_draw
	return root.get_texture().get_image()
func plate_sample(picture: Image, x: float, z: float) -> float:
	var pixel := Vector2i(main.camera.unproject_position(Vector3(x,.121,z))*Vector2(root.size)/Vector2(root.content_scale_size))
	var sum := 0.0
	for dy in range(-2,3):
		for dx in range(-2,3): sum += picture.get_pixel(pixel.x+dx,pixel.y+dy).get_luminance()
	return sum/25.0
func balance(picture: Image) -> Dictionary:
	var left := 0.0
	var right := 0.0
	for z in [-.22,0.0,.22]:
		left += plate_sample(picture,-.42,z)
		right += plate_sample(picture,.42,z)
	return {"left":left/3.0,"right":right/3.0,"relative_difference":absf(left-right)/maxf(left,right)}
func pilot_visual() -> void:
	main.feedback.proxies_enabled = false
	main.feedback.set_physics_process(false)
	main.camera.set_process(true)
	await zoom_to(1)
	main.camera.set_process(false)
	var intact := await skull_picture("natural-intact")
	main.mesh_view.model.hide()
	var without_model := await frame_image()
	check(digest(intact.get_data()) == digest(without_model.get_data()) and main.mesh_view.shadow_caster.mesh == null,"centred light reveals no source pixel or casting geometry through intact matrix")
	main.mesh_view.model.show()
	var s: WorkingSurface = main.block.working_map
	P5Fixture.reveal(s,[35,0,0,0])
	var partial := await skull_picture("natural-partial")
	var caster := digest(main.mesh_view.shadow_caster.mesh.surface_get_arrays(0)[Mesh.ARRAY_INDEX].to_byte_array())
	main.mesh_view.model.hide()
	var hidden := await frame_image()
	for p in [Vector2(245,272),Vector2(480,307),Vector2(441,360),Vector2(628,383)]:
		var i: int = s.fossil.field.index_at_map(p)
		var centre := Vector2i(at(p)*Vector2(root.size)/Vector2(root.content_scale_size))
		var box := Rect2i(centre-Vector2i(10,10),Vector2i(20,20))
		check(s.fossil.exposed[i] == 0 and digest(partial.get_region(box).get_data()) == digest(hidden.get_region(box).get_data()),"truly buried jaw/spine/rib/leg has identical pixels with source absent: "+str(p))
	check(caster == digest(main.mesh_view.shadow_caster.mesh.surface_get_arrays(0)[Mesh.ARRAY_INDEX].to_byte_array()),"source visibility never adds buried shadow indices")
	main.mesh_view.model.show()
	main.reset_specimen()
	# A neutral flat witness isolates illumination from authored orange textures,
	# anatomy, excavated slopes and material occlusion.
	main.block.hide()
	var plate := MeshInstance3D.new()
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(1.1,.7)
	plate.mesh = mesh
	plate.position.y = .121
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(.15,.15,.15)
	material.roughness = 1.0
	plate.material_override = material
	main.add_child(plate)
	var central_light: Transform3D = main.task_light.transform
	var central_bounce: Transform3D = main.bench_bounce.transform
	var key: DirectionalLight3D = main.get_node("TableEnvironment/Light")
	var central_key: Transform3D = key.transform
	var centred := await skull_picture("neutral-centered")
	main.task_light.position = Vector3(-.45,.8,-.3)
	main.task_light.look_at(Vector3(-.06,.04,-.01),Vector3.UP)
	main.bench_bounce.position.x = .12
	key.rotation_degrees = Vector3(-52,-135,0)
	var previous := await skull_picture("neutral-previous-left")
	var a := balance(centred)
	var b := balance(previous)
	evidence["neutral_light_balance"] = {"centred":a,"previous":b,"positions_x":[-.42,.42],"positions_z":[-.22,0,.22],"patch_pixels":25}
	check(a.left < .9 and a.right < .9 and b.left < .9 and b.right < .9,"neutral light samples avoid display saturation")
	check(a.relative_difference < .05 and a.relative_difference < b.relative_difference,"neutral plate left/right luminance differs by less than 5 percent and improves on previous light")
	main.task_light.transform = central_light
	main.bench_bounce.transform = central_bounce
	key.transform = central_key
	plate.free()
	main.block.show()
	main.prepare_native_skeleton_review()
	P5Fixture.clean(s)
	await settle()
	var stable := state()
	await skull_picture("natural-prepared-overview")
	main.camera.set_process(true)
	await zoom_to(3,Vector2(430,330))
	main.camera.set_process(false)
	var shadow_on := await skull_picture("natural-prepared-detail")
	main.mesh_view.shadows_enabled = false
	var shadow_off := await skull_picture("natural-prepared-shadow-off")
	var darker := 0
	for y in range(130,630):
		for x in range(200,1180):
			if shadow_off.get_pixel(x,y).get_luminance()-shadow_on.get_pixel(x,y).get_luminance() > .025: darker += 1
	check(darker > 200,"centred illumination retains visible exposed-bone relief shadows")
	evidence["exposed_shadow_darkened_pixels"] = darker
	main.mesh_view.shadows_enabled = true
	check(state() == stable,"all graphical lighting comparisons preserve preparation")
	main.camera.set_process(true)
	await zoom_to(3,Vector2(512,75))
	main.camera.set_process(false)
	await skull_picture("natural-upper-workspace")
	check(not main.lamp_art.is_visible_in_tree() and main.block.pick(at(Vector2(512,100)),main.camera).inside,"upper work area is visible and pickable with lamp model absent")
	await orange_visual()

func orange_visual() -> void:
	main.prepare_review_patch()
	var s: WorkingSurface = main.block.working_map
	for y in range(290,558):
		for x in range(560,790):
			var i := y*1024+x
			if s.fossil.field.component_ids[i] == 0: s._heights[i] = s.strata.packed_limits[i*2+1]
	s.image.set_data(1024,640,false,Image.FORMAT_RF,s._heights.to_byte_array());s.dirty = true
	P5Fixture.clean(s)
	await settle()
	main.matrix_edges.sync()
	main.camera.set_process(true)
	await zoom_to(3,Vector2(634,423))
	main.camera.set_process(false)
	var stable := state()
	var lower := PackedFloat32Array();lower.resize(1024*640)
	for i in range(lower.size()): lower[i] = s.strata.packed_limits[i*2+1]
	var image := Image.create_from_data(1024,640,false,Image.FORMAT_RF,lower.to_byte_array())
	var limits := ReliefSurface.new(image,main.block.surface_size,Vector2i(1024,640),0,1)
	var false_clay := 0
	var contact_candidates := PackedInt32Array()
	for y in range(300,550):
		for x in range(570,780):
			var i := y*1024+x
			if main.matrix_edges.edges[i] == 0: continue
			var uv := (Vector2(x,y)+Vector2.ONE*.5)/Vector2(1024,640)
			if s._heights[i] <= lower[i]+.000001 and main.block.relief.normalized_height_at(uv)-limits.height_at(uv) > .000001:
				false_clay += 1
				contact_candidates.append(i)
	check(false_clay > 20,"independent CPU triangle oracle reproduces false Clay classification on real Sandstone-floor cells beside exposed Bone")
	main.block.material.set_shader_parameter("correct_matrix_edges",false)
	var previous := await skull_picture("orange-contour-before")
	main.block.material.set_shader_parameter("correct_matrix_edges",true)
	var corrected := await skull_picture("orange-contour-after")
	var corrected_pixels := 0
	for y in range(130,630):
		for x in range(200,1180):
			var a := previous.get_pixel(x,y)
			var b := corrected.get_pixel(x,y)
			if a.r > a.g*1.4 and a.g > a.b*1.4 and b.r < a.r*.85: corrected_pixels += 1
	check(corrected_pixels > 20,"actual boundary correction removes orange pixels rather than recolouring the whole bone")
	check(state() == stable,"orange correction preserves every height, ceiling, exposure, Film, damage, crumb and session channel")
	var contacts := 0
	var wrong_contacts := 0
	for i in contact_candidates:
		@warning_ignore("integer_division")
		var p := Vector2(i%1024,i/1024)
		var hit: Dictionary = main.block.pick(at(p),main.camera)
		if not hit.inside or hit.bone or hit.cell != Vector2i(p): continue
		contacts += 1
		if hit.material.id != &"sandstone": wrong_contacts += 1
	check(contacts > 20 and wrong_contacts == 0,"real ray contacts label corrected Sandstone floors consistently with the shader")
	evidence["orange_contour"] = {"false_clay_cells":false_clay,"orange_pixels_corrected":corrected_pixels,"corrected_contacts":contacts,"wrong_contacts":wrong_contacts}
