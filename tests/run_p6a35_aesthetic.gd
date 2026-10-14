extends "res://tests/run_p6a34_production.gd"
func _pilot_scene() -> PackedScene:
	return preload("res://scenes/p6a35_aesthetic_pilot.tscn")
func _output_directory() -> String:
	return "res://work/test-logs/p6a35/"
func _expected_triangles() -> int:
	return int(JSON.parse_string(FileAccess.get_file_as_string("res://assets/p6a35/production-manifest.json")).triangles)

func pilot_checks() -> void:
	await super.pilot_checks()
	main.reset_specimen()
	var view: Node3D = main.mesh_view
	check(view.shadow_caster.mesh == null and view.caster_cells.is_empty(),"reset immediately removes every shadow caster before the next frame")
	await settle()
	check(view.shadow_caster.mesh == null,"fully buried source has zero casting geometry")
	var s: WorkingSurface = main.block.working_map
	P5Fixture.reveal(s,[50,0,0,0])
	await settle()
	var cell_set := {}
	for i in view.caster_cells: cell_set[i] = true
	var selected_exposed := 0
	var wrong := 0
	for i in range(s.fossil.exposed.size()):
		var wanted: bool = s.fossil.field.replacement[i] != 0 and s.fossil.exposed[i] != 0 and s._heights[i] <= s.structural_ceilings[i]+FossilField.EXPOSURE_EPSILON
		if wanted: selected_exposed += 1
		if cell_set.has(i) != wanted: wrong += 1
	check(wrong == 0 and selected_exposed > 1000,"partial caster contains every exposed pilot cell and no buried cell or unrelated rib")
	check(view.shadow_caster.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY,"exposed-only caster never draws a second visible bone surface")
	var arrays: Array = view.shadow_caster.mesh.surface_get_arrays(0)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	var safe: bool = indices.size() == view.caster_cells.size()*6
	for n in range(view.caster_cells.size()):
		var i: int = view.caster_cells[n]
		for j in range(6):
			@warning_ignore("integer_division")
			if indices[n*6+j]/4 != view.cell_slots[i]: safe = false
		@warning_ignore("integer_division")
		var p := Vector2(i%1024,i/1024)*Vector2(1.1/1024,.7/640)-Vector2(.55,.35)
		for j in range(4):
			var v := vertices[view.cell_slots[i]*4+j]
			if v.x < p.x-.0000001 or v.x > p.x+1.1/1024+.0000001 or v.z < p.y-.0000001 or v.z > p.y+.7/640+.0000001: safe = false
			if absf(v.y-(.018+s.structural_ceilings[i]*.102-view.ROOF_INSET_M)) > .0000001: safe = false
	check(safe,"every casting triangle stays inside its exposed cell and below its true roof")
	var stable := state()
	main.shadows_button.pressed.emit()
	check(not view.shadows_enabled and not view.shadow_caster.visible and state() == stable,"shadow comparison button disables only casting, preserving all gameplay")
	main.shadows_button.pressed.emit()
	check(view.shadows_enabled and view.shadow_caster.visible and state() == stable,"shadow comparison button restores exposed-only casting")
	await press_key(KEY_F6)
	check(not view.shadow_caster.is_visible_in_tree() and state() == stable,"F6 relief comparison hides the additional caster after partial excavation")
	await press_key(KEY_F6)
	check(view.shadow_caster.is_visible_in_tree() and state() == stable,"F6 restores the caster with the mesh without reset")
	var builds: int = view.shadow_rebuild_count
	for n in range(10): view.sync_state()
	check(view.shadow_rebuild_count == builds and state() == stable,"idle synchronization never rebuilds shadows or mutates gameplay")
	var full_source: Array = view.meshes[0].mesh.surface_get_arrays(0)
	var colors: PackedColorArray = full_source[Mesh.ARRAY_COLOR]
	var low := 1.0
	for color in colors: low = minf(low,color.r)
	check(not colors.is_empty() and low < .8,"actual imported mesh retains baked geometric recess occlusion")
	evidence["shadow_geometry"] = {"partial_cells":selected_exposed,"wrong_cells":wrong,"triangles":view.caster_cells.size()*2,"build_usec":view.last_shadow_build_usec,"max_build_usec":view.max_shadow_build_usec,"ao_min":low}
	main.reset_specimen()
	check(view.shadow_caster.mesh == null,"reset after partial excavation clears the caster synchronously")

func pilot_visual() -> void:
	main.feedback.proxies_enabled = false
	main.feedback.set_physics_process(false)
	main.camera.set_process(false)
	main.mesh_view.shadows_enabled = false
	var intact_off := await skull_picture("intact-shadow-off")
	main.mesh_view.shadows_enabled = true
	var intact_on := await skull_picture("intact-shadow-on")
	check(digest(intact_off.get_data()) == digest(intact_on.get_data()),"entire intact viewport is pixel-identical with shadow system on/off")
	var s: WorkingSurface = main.block.working_map
	P5Fixture.reveal(s,[35,0,0,0])
	main.camera.set_process(true)
	await zoom_to(3,Vector2(266,233))
	main.camera.set_process(false)
	var partial_on := await skull_picture("partial-shadow-on")
	main.mesh_view.shadows_enabled = false
	var partial_off := await skull_picture("partial-shadow-off")
	check(digest(partial_on.get_data()) != digest(partial_off.get_data()),"partial revelation casts visible shadows before the rest of the skull is uncovered")
	main.mesh_view.shadows_enabled = true
	main.reset_specimen()
	main.prepare_review_patch()
	P5Fixture.clean(s)
	main.camera.set_process(true)
	await zoom_to(3,Vector2(266,233))
	main.camera.set_process(false)
	await settle()
	var stable := state()
	var on := await skull_picture("skull-shadow-on")
	main.mesh_view.shadows_enabled = false
	var off := await skull_picture("skull-shadow-off")
	var darker := 0
	var brighter := 0
	for y in range(140,650):
		for x in range(100,1180):
			var delta := off.get_pixel(x,y).get_luminance()-on.get_pixel(x,y).get_luminance()
			if delta > .025: darker += 1
			if delta < -.025: brighter += 1
	check(darker > 200 and brighter < darker*.1,"exposed-only shadow comparison visibly darkens the receiving surface")
	check(state() == stable,"shadow comparisons preserve every preparation channel")
	evidence["shadow_pixels"] = {"darker":darker,"brighter":brighter}
	main.mesh_view.shadows_enabled = true
	main.reset_specimen()
	main.camera.set_process(true)
	await zoom_to(1)
	main.camera.set_process(false)
	await super.pilot_visual()
	var view: Node3D = main.mesh_view
	evidence["shadow_cost"] = {"cells":view.caster_cells.size(),"triangles":view.caster_cells.size()*2,"last_build_usec":view.last_shadow_build_usec,"max_build_usec":view.max_shadow_build_usec,"build_count":view.shadow_rebuild_count}

func _expected_shadow_triangles() -> int:
	return main.mesh_view.caster_cells.size()*2
func _collection_store() -> String:
	return "res://work/test-logs/p6a35/collection-test.json"

func _suite_name() -> String:
	return "P6A3.5"
