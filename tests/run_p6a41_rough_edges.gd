extends "res://tests/run_p6a40_natural_block.gd"
func _pilot_scene() -> PackedScene:
	return preload("res://scenes/preparation/base/rough_block.tscn")
func _output_directory() -> String:
	return "res://work/test-logs/p6a41/"
func _collection_store() -> String:
	return "res://work/test-logs/p6a41/collection-test.json"
func _suite_name() -> String:
	return "P6A4.1"
func pilot_checks() -> void:
	await super.pilot_checks()
	main.reset_specimen()
	var s: WorkingSurface = main.block.working_map
	var rim: RefCounted = main.block.rim
	var shape: RefCounted = main.block.footprint
	var fresh := WorkingSurface.new(s.size,Stratigraphy.new(s.size,main.block.material_definitions),s.fossil.field)
	var reference: RefCounted = preload("res://scripts/excavation/block/natural/natural_profile.gd").new(fresh,shape)
	var changed_core := 0
	var changed_bone := 0
	var changed_rim := 0
	for i in range(s._heights.size()):
		if shape.mask[i] == 0: continue
		if s._heights[i] != reference.fragmented_top[i]:
			if rim.caps.has(i): changed_rim += 1
			else: changed_core += 1
			if s.fossil.field.component_ids[i] != 0: changed_bone += 1
	check(changed_core == 0 and changed_bone == 0 and changed_rim > 1000,"rough edge cuts alter only the bounded outer strip and preserve all interior/Bone starting heights")
	var wrong_guard := 0
	var rendered: PackedFloat32Array = main.block.render_image.get_data().to_float32_array()
	for i in rim.padding:
		var source: int = rim.padding[i]
		if shape.mask[i] != 0 or shape.mask[source] == 0 or s._heights[i] != 0 or rendered[i] != s._heights[source]: wrong_guard += 1
	check(wrong_guard == 0 and rim.padding.size() > 1000 and main.block.relief.image == main.block.render_image,"linear sampling guard is outside the domain, keeps logical voids empty and is shared with the CPU picker")
	var arrays: Array = rim.mesh.surface_get_arrays(0)
	var positions: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
	var offsets := 0
	var inclined := 0
	for n in range(positions.size()):
		var p: Vector2 = (uvs[n]-Vector2.ONE*.5)*main.block.surface_size
		if Vector2(positions[n].x,positions[n].z).distance_to(p) > .007: offsets += 1
		if normals[n].y > .10: inclined += 1
	check(offsets > 100 and inclined > 1000,"wall actually has inclined geometric facets and uneven protrusions")
	var hits := 0
	var failures_at_edge := 0
	var max_error := 0.0
	var index := 0
	for i in rim.band:
		index += 1
		if index%1100 != 0 or rim.band[i].distance < .003: continue
		@warning_ignore("integer_division")
		var p := Vector2(i%1024,i/1024)
		var hit: Dictionary = main.block.pick(at(p),main.camera)
		if not hit.inside: failures_at_edge += 1
		else:
			hits += 1
			max_error = maxf(max_error,hit.map.distance_to(p))
	check(hits > 20 and failures_at_edge == 0 and max_error < .02,"near-edge rays contact the actual bevel height within 0.02 texel")
	var builds: int = main.block.render_builds
	for n in range(10): main.block.flush_texture()
	check(main.block.render_builds == builds,"idle frames never rebuild or upload the padded heightmap")
	evidence["rough_rim"] = {"changed_rim_cells":changed_rim,"changed_core_cells":changed_core,"changed_bone_cells":changed_bone,"padding_cells":rim.padding.size(),"wall_triangles":arrays[Mesh.ARRAY_INDEX].size()/3,"near_edge_rays":hits,"max_ray_error_texels":max_error}
func pilot_visual() -> void:
	await super.pilot_visual()
	main.reset_specimen()
	main.feedback.proxies_enabled = false
	main.feedback.set_physics_process(false)
	main.camera.set_process(true)
	await zoom_to(1)
	main.camera.set_process(false)
	await skull_picture("rough-intact-overview")
	main.camera.set_process(true)
	await zoom_to(3,Vector2(512,603))
	main.camera.set_process(false)
	centre_edge(Vector2(512,603))
	var front := await skull_picture("rough-front-edge")
	var stable := state()
	var mesh: Mesh = main.block.natural_wall.mesh
	var shader: Shader = main.block.skirt_material.shader
	main.block.natural_wall.mesh = main.block.footprint.wall_mesh(main.block.surface_size)
	main.block.skirt_material.shader = main.wall_shaders.find_key(shader)
	var flat := await skull_picture("vertical-wall-witness-same-heights")
	check(digest(front.get_data()) != digest(flat.get_data()) and state() == stable,"faceted wall comparison changes visible pixels while keeping exactly the same bevel heights and preparation")
	main.block.natural_wall.mesh = mesh
	main.block.skirt_material.shader = shader
	main.camera.set_process(true)
	await zoom_to(3,Vector2(105,515))
	main.camera.set_process(false)
	centre_edge(Vector2(105,515))
	await skull_picture("rough-left-edge")

func centre_edge(point: Vector2) -> void:
	var destination: Vector2 = main.camera.get_viewport().get_visible_rect().size*Vector2(.57,.51)
	main.camera.global_position += main.camera.project_ray_origin(at(point))-main.camera.project_ray_origin(destination)
	main.camera._constrain_pan()
