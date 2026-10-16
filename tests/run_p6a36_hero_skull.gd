extends "res://tests/run_p6a35_aesthetic.gd"
func _pilot_scene() -> PackedScene:
	return preload("res://scenes/preparation/base/sculpted_fossil.tscn")
func _output_directory() -> String:
	return "res://work/test-logs/p6a36/"
func _expected_triangles() -> int:
	return int(JSON.parse_string(FileAccess.get_file_as_string("res://assets/p6a36/production-manifest.json")).triangles)
func _collection_store() -> String:
	return "res://work/test-logs/p6a36/collection-test.json"
func _suite_name() -> String:
	return "P6A3.6"

func _contact_point() -> Vector2:
	return Vector2(235,243)

func pilot_checks() -> void:
	await super.pilot_checks()
	var field: FossilField = main.block.working_map.fossil.field
	for point in [Vector2(195,222),Vector2(236,218),Vector2(274,213),Vector2(305,218),Vector2(280,264)]:
		var i: int = int(point.y)*1024+int(point.x)
		check(field.component_ids[i] == 0,"modeled cranial/mandibular window remains physically open: "+str(point))
	var previous: FossilField = load("res://scripts/specimens/shaded_base/mesh_fossil_field.gd").new()
	var wrong := 0
	for i in range(field.component_ids.size()):
		if previous.component_ids[i] == 3 or field.component_ids[i] == 3:
			if previous.component_ids[i] != field.component_ids[i] or previous.ceilings[i] != field.ceilings[i]: wrong += 1
	check(wrong == 0,"every P6A35 rib cell and roof is retained exactly")
	var stable := state()
	main.inspection.toggle()
	main.inspection.select_part(1)
	var size: float = main.inspection.camera.size
	main.inspection.reference_button.pressed.emit()
	main.inspection.shape_button.pressed.emit()
	check(main.inspection.using_previous and main.inspection.shape_study and main.inspection.camera.size == size and state() == stable,"source and clay comparisons preserve review scale and all gameplay")
	main.inspection.reference_button.pressed.emit()
	main.inspection.shape_button.pressed.emit()
	main.inspection.toggle()
	check(not main.inspection.using_previous and not main.inspection.shape_study and state() == stable,"art review restores the new ivory model without mutation")
	main.reset_specimen()
	var s: WorkingSurface = main.block.working_map
	var screen := at(_contact_point())
	var untouched: Dictionary = main.block.pick(screen,main.camera)
	var inverse: Transform3D = main.block.global_transform.affine_inverse()
	var terrain: Dictionary = main.block.relief.ray_hit(inverse*main.camera.project_ray_origin(screen),inverse.basis*main.camera.project_ray_normal(screen),main.camera.far)
	check(not untouched.get("mesh_contact_refined",false) and untouched.local == terrain.local,"fully buried geometry never changes the terrain hit")
	P5Fixture.reveal(s,[20,0,0,0])
	var covered: Dictionary = main.block.pick(at(_contact_point()),main.camera)
	check(not covered.bone_exposed and not covered.get("mesh_contact_refined",false),"a still-covered part of the partial skull keeps the native matrix contact")
	P5Fixture.reveal(s,[100,100,100,100])
	var real: Dictionary = main.block.pick(at(_contact_point()),main.camera)
	check(real.bone_exposed and real.get("mesh_contact_refined",false),"an actually exposed plate uses the refined display contact")
	var query_stable := state()
	var began := Time.get_ticks_usec()
	for n in range(100): main.block.pick(at(_contact_point()),main.camera)
	evidence["contact_refinement"] = {"mean_pick_usec":(Time.get_ticks_usec()-began)/100.0,"query_count":100,"max_guard_distance_m":.005}
	check(state() == query_stable,"repeated triangle contact queries do not mutate preparation")
	main.reset_specimen()


func pilot_visual() -> void:
	await super.pilot_visual()
	var stable := state()
	main.inspection.toggle()
	main.inspection.select_part(1)
	var current := await skull_picture("hero-ivory")
	main.inspection.toggle_reference()
	var previous := await skull_picture("previous-ivory")
	check(digest(current.get_region(Rect2i(240,180,800,450)).get_data()) != digest(previous.get_region(Rect2i(240,180,800,450)).get_data()),"actual source silhouettes differ substantially in the same inspection view")
	main.inspection.toggle_shape_study()
	await skull_picture("previous-shape")
	main.inspection.toggle_reference()
	await skull_picture("hero-shape")
	main.inspection.pivot.rotation = Vector3(.65,.65,0)
	await skull_picture("hero-three-quarter-shape")
	main.inspection.toggle_shape_study()
	await skull_picture("hero-three-quarter-ivory")
	main.inspection.pivot.rotation = Vector3(-.8,-.5,0)
	await skull_picture("hero-underside")
	main.inspection.toggle()
	check(state() == stable,"all artistic source views preserve the preparation")

	# The final supplementary view comes from actual unchanged native Pick cuts.
	main.prepare_native_pick_review()
	main.camera.set_process(true)
	await zoom_to(3,Vector2(258,230))
	main.camera.set_process(false)
	await skull_picture("native-pick-dirty")
	var native_state: Dictionary = main.session.snapshot()
	check(main.block.working_map.fossil.condition == 100 and main.block.working_map.fossil.component_exposed[1] > 0,"native Pick review really reveals the new skull without damage")
	P5Fixture.clean(main.block.working_map)
	await skull_picture("native-pick-clean")
	evidence["native_pick_fixture"] = {"impacts":19*28*4,"condition":main.block.working_map.fossil.condition,"exposure_percent":main.block.working_map.fossil.exposure_percent(1),"snapshot_before_clean":native_state}
