extends "res://tests/run_p6a37_skeleton.gd"
func _pilot_scene() -> PackedScene:
	return preload("res://scenes/preparation/base/centered_light.tscn")
func _output_directory() -> String:
	return "res://work/test-logs/p6a39/"
func _collection_store() -> String:
	return "res://work/test-logs/p6a39/collection-test.json"
func _suite_name() -> String:
	return "P6A3.9"
func pilot_checks() -> void:
	await super.pilot_checks()
	check(ProjectSettings.get_setting("application/run/main_scene") == "res://scenes/preparation/base/centered_light.tscn","default project opens the fixed centred light candidate")
	check(main.task_light.position.x == 0 and main.bench_bounce.position.x == 0,"source and bounce share the centre axis")
	check(main.task_light.light_color == Color(1,.94,.83) and is_equal_approx(main.task_light.light_energy,1.2) and main.task_light.spot_angle == 50,"accepted warm colour, intensity and beam width remain exact")
	var before := state()
	var pose: Transform3D = main.task_light.transform
	for n in range(2):
		main.toggle_task_light()
		main.toggle_look()
		main.toggle_look()
	check(state() == before and main.task_light.transform == pose,"lighting witnesses preserve specimen and centred pose")
	check(main.get_node_or_null("OrientableLamp") == null,"candidate introduces no movable lamp controller")

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
	var intact := await skull_picture("centered-intact")
	main.mesh_view.model.hide()
	var without_model := await frame_image()
	check(digest(intact.get_data()) == digest(without_model.get_data()) and main.mesh_view.shadow_caster.mesh == null,"centred light reveals no source pixel or casting geometry through intact matrix")
	main.mesh_view.model.show()
	var s: WorkingSurface = main.block.working_map
	P5Fixture.reveal(s,[35,0,0,0])
	var partial := await skull_picture("centered-partial")
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
	await skull_picture("centered-prepared-overview")
	main.camera.set_process(true)
	await zoom_to(3,Vector2(430,330))
	main.camera.set_process(false)
	var shadow_on := await skull_picture("centered-prepared-detail")
	main.mesh_view.shadows_enabled = false
	var shadow_off := await skull_picture("centered-prepared-shadow-off")
	var darker := 0
	for y in range(130,630):
		for x in range(200,1180):
			if shadow_off.get_pixel(x,y).get_luminance()-shadow_on.get_pixel(x,y).get_luminance() > .025: darker += 1
	check(darker > 200,"centred illumination retains visible exposed-bone relief shadows")
	evidence["exposed_shadow_darkened_pixels"] = darker
	main.mesh_view.shadows_enabled = true
	check(state() == stable,"all graphical lighting comparisons preserve preparation")
