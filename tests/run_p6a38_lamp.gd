extends "res://tests/run_p6a37_skeleton.gd"
const ANGLES := [-125.0,-85.0,-45.0,0.0,35.0]
func _pilot_scene() -> PackedScene:
	return preload("res://scenes/p6a38_orientable_lamp.tscn")
func _output_directory() -> String:
	return "res://work/test-logs/p6a38/"
func _collection_store() -> String:
	return "res://work/test-logs/p6a38/collection-test.json"
func _suite_name() -> String:
	return "P6A3.8"

func mouse_button(button: MouseButton, pressed: bool, point: Vector2, double_click := false) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = button
	event.pressed = pressed
	event.position = point*Vector2(root.size)/Vector2(root.content_scale_size)
	event.global_position = Vector2(root.position)+event.position
	event.double_click = double_click
	Input.parse_input_event(event)
	await process_frame
	await process_frame
func motion(point: Vector2, relative: Vector2, buttons: int) -> void:
	var event := InputEventMouseMotion.new()
	event.position = point*Vector2(root.size)/Vector2(root.content_scale_size)
	event.global_position = Vector2(root.position)+event.position
	event.relative = relative*Vector2(root.size)/Vector2(root.content_scale_size)
	event.button_mask = buttons
	Input.parse_input_event(event)
	await process_frame
	await process_frame
func light_signature() -> Array:
	var light: SpotLight3D = main.task_light
	return [light.light_color,light.light_energy,light.spot_range,light.spot_attenuation,light.spot_angle,light.spot_angle_attenuation,light.shadow_enabled,light.shadow_bias,light.shadow_normal_bias,main.bench_bounce.light_color,main.bench_bounce.light_energy,main.get_node("TableEnvironment/WorldEnvironment").environment.ambient_light_color,main.get_node("TableEnvironment/WorldEnvironment").environment.ambient_light_energy]

func pilot_checks() -> void:
	await super.pilot_checks()
	var lamp: Node3D = main.lamp_control
	main.reset_specimen()
	var baseline := state()
	var settings := light_signature()
	var presets := []
	for tool in main.controller.tools: presets.append([tool.radius,tool.power,tool.falloff])
	check(main.task_light.transform == lamp.home_light and main.lamp_art.transform == lamp.home_art,"initial lamp art and light retain exact approved transforms")
	check(not lamp.active and not lamp.guard.visible and not lamp.help_panel.visible,"normal startup preserves normal excavation input")
	for degrees in ANGLES:
		lamp.set_azimuth(degrees)
		var base: Vector3 = main.lamp_art.position
		check(absf(base.x) >= .63 or absf(base.z) >= .43,"lamp base stays outside the excavation footprint: "+str(degrees))
		check(light_signature() == settings and state() == baseline,"orientation preserves warm illumination parameters and all preparation: "+str(degrees))
	lamp.set_azimuth(-999)
	check(lamp.azimuth_degrees == lamp.MIN_AZIMUTH,"left travel is bounded")
	lamp.set_azimuth(999)
	check(lamp.azimuth_degrees == lamp.MAX_AZIMUTH,"right travel is bounded")
	lamp.reset_pose()
	check(main.task_light.transform == lamp.home_light and main.lamp_art.transform == lamp.home_art,"lamp reset restores the baseline bit-for-bit")
	main.controller._focused = true
	main.controller._pointer_inside = true
	main.camera._focused = true
	main.controller.set_physics_process(true)
	await press_key(KEY_L)
	check(lamp.active and lamp.guard.visible and main.controller.ui_blockers.has(lamp.guard),"real L enters lamp mode and blocks every excavation hit")
	var centre := at(Vector2(500,350))
	await mouse_button(MOUSE_BUTTON_LEFT,true,centre)
	await motion(centre+Vector2(300,0),Vector2(300,0),MOUSE_BUTTON_MASK_LEFT)
	for n in range(3): await physics_frame
	check(lamp.dragging and lamp.azimuth_degrees < 0 and not main.controller._held,"real captured drag moves the source without arming a tool")
	await mouse_button(MOUSE_BUTTON_LEFT,false,centre+Vector2(300,0))
	check(not lamp.dragging and state() == baseline,"release ends lamp capture without height, Film, damage or progression changes")
	var angle: float = lamp.azimuth_degrees
	await mouse_button(MOUSE_BUTTON_WHEEL_UP,true,centre)
	check(main.camera.target_zoom > 1 and lamp.azimuth_degrees == angle,"wheel retains camera zoom in lamp mode")
	main.camera.reset_view()
	await mouse_button(MOUSE_BUTTON_RIGHT,true,centre)
	await motion(centre+Vector2(40,0),Vector2(40,0),MOUSE_BUTTON_MASK_RIGHT)
	await mouse_button(MOUSE_BUTTON_RIGHT,false,centre+Vector2(40,0))
	check(not main.camera.panning and lamp.azimuth_degrees == angle and state() == baseline,"right drag retains camera pan without rotating the lamp or editing Bone")
	main.camera.reset_view()
	await mouse_button(MOUSE_BUTTON_LEFT,true,centre)
	lamp._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
	await motion(centre+Vector2(90,0),Vector2(90,0),MOUSE_BUTTON_MASK_LEFT)
	check(not lamp.dragging and lamp.azimuth_degrees == angle,"focus loss cancels capture; held motion cannot resume it")
	lamp._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_IN)
	await mouse_button(MOUSE_BUTTON_LEFT,false,centre)
	await mouse_button(MOUSE_BUTTON_LEFT,true,centre)
	lamp._notification(Node.NOTIFICATION_WM_MOUSE_EXIT)
	check(not lamp.dragging,"mouse exit cancels lamp capture")
	await mouse_button(MOUSE_BUTTON_LEFT,false,centre)
	await mouse_button(MOUSE_BUTTON_LEFT,true,centre)
	root.size_changed.emit()
	check(not lamp.dragging,"window resize signal cancels lamp capture")
	await mouse_button(MOUSE_BUTTON_LEFT,false,centre)
	await mouse_button(MOUSE_BUTTON_LEFT,true,lamp.reset_button.get_global_rect().get_center())
	await mouse_button(MOUSE_BUTTON_LEFT,false,lamp.reset_button.get_global_rect().get_center())
	check(lamp.azimuth_degrees == 0 and lamp.active and state() == baseline,"lamp reset button restores only its pose and keeps preparation")
	await mouse_button(MOUSE_BUTTON_LEFT,true,centre)
	await press_key(KEY_ESCAPE)
	await motion(centre+Vector2(60,0),Vector2(60,0),MOUSE_BUTTON_MASK_LEFT)
	for n in range(2): await physics_frame
	check(not lamp.active and not lamp.dragging and not main.controller._held and state() == baseline,"Escape returns to tools without continuing the captured left stroke")
	await mouse_button(MOUSE_BUTTON_LEFT,false,centre)
	await mouse_button(MOUSE_BUTTON_LEFT,true,lamp.toggle_button.get_global_rect().get_center())
	await mouse_button(MOUSE_BUTTON_LEFT,false,lamp.toggle_button.get_global_rect().get_center())
	check(lamp.active,"on-screen Lamp button enables the same mode")
	await mouse_button(MOUSE_BUTTON_LEFT,true,lamp.toggle_button.get_global_rect().get_center())
	await mouse_button(MOUSE_BUTTON_LEFT,false,lamp.toggle_button.get_global_rect().get_center())
	check(not lamp.active,"the same on-screen button receives its release and returns to tools")
	await press_key(KEY_L)
	await press_key(KEY_F5)
	check(main.inspection.opened and not lamp.active,"F5 cancels manipulation before opening isolated source inspection")
	await press_key(KEY_L)
	check(not lamp.active and main.inspection.opened,"lamp shortcut does not operate through source inspection")
	await press_key(KEY_ESCAPE)
	await press_key(KEY_L)
	await press_key(KEY_F11)
	check(not lamp.active and not main.task_light_enabled and lamp.toggle_button.disabled,"light witness comparison safely leaves manipulation")
	await press_key(KEY_F11)
	check(not lamp.toggle_button.disabled and light_signature() == settings,"accepted local illumination returns without retuning")
	await press_key(KEY_L)
	await press_key(KEY_4)
	check(not lamp.active and main.controller.selected_index == 3,"tool selection exits lamp mode and selects the unchanged Pick")
	await mouse_button(MOUSE_BUTTON_LEFT,true,at(Vector2(500,350)))
	for n in range(6): await physics_frame
	await mouse_button(MOUSE_BUTTON_LEFT,false,at(Vector2(500,350)))
	check(state().height != baseline.height,"a fresh normal tool click still performs real excavation after lamp manipulation")
	main.controller.set_physics_process(false)
	main.reset_specimen()
	lamp.set_azimuth(-85)
	var pose: Transform3D = main.task_light.transform
	main.reset_specimen()
	check(main.task_light.transform == pose,"specimen reset does not silently reset the player's lamp position")
	var after := []
	for tool in main.controller.tools: after.append([tool.radius,tool.power,tool.falloff])
	check(presets == after,"all validated tool presets are unchanged after real lamp interactions")
	await press_key(KEY_F7)
	await press_key(KEY_F7)
	check(main.controller.ui_blockers.has(lamp.toggle_button) and main.controller.ui_blockers.has(lamp.guard),"readability UI rebuild retains lamp input blockers")
	if DisplayServer.get_name() != "headless":
		main.display.set_fullscreen(true)
		await settle(8)
		lamp.focused = true
		await press_key(KEY_L)
		await press_key(KEY_ESCAPE)
		check(not lamp.active and root.mode == Window.MODE_FULLSCREEN,"Escape exits lamp mode before the fullscreen handler sees the key")
		main.display.set_fullscreen(false)
		await settle(8)
		check(root.mode == Window.MODE_WINDOWED,"native fullscreen test restores the window without changing saved preferences")
	lamp.reset_pose()
	evidence["lamp_parameters"] = {"angles":ANGLES,"light_color":str(main.task_light.light_color),"energy":main.task_light.light_energy,"warm_signature_preserved":light_signature()==settings,"presets_preserved":presets==after}

func pilot_visual() -> void:
	# The inherited native suite checks the complete accepted skeleton and tools
	# with this isolated scene before the additional multi-angle spoiler oracle.
	await super.pilot_visual()
	var lamp: Node3D = main.lamp_control
	main.reset_specimen()
	main.feedback.proxies_enabled = false
	main.feedback.set_physics_process(false)
	main.camera.set_process(true)
	await zoom_to(1)
	main.camera.set_process(false)
	evidence["intact_angles"] = []
	for degrees in ANGLES:
		lamp.set_azimuth(degrees)
		var before := await skull_picture("lamp-intact-"+str(int(degrees)))
		main.mesh_view.model.hide()
		await settle(4)
		await RenderingServer.frame_post_draw
		var hidden := root.get_texture().get_image()
		check(digest(before.get_data()) == digest(hidden.get_data()),"no buried source silhouette in any intact pixel: "+str(degrees))
		main.mesh_view.model.show()
		main.mesh_view.shadows_enabled = false
		await settle(4)
		await RenderingServer.frame_post_draw
		var off := root.get_texture().get_image()
		check(digest(before.get_data()) == digest(off.get_data()) and main.mesh_view.shadow_caster.mesh == null,"no buried shadow geometry or changed pixel at angle: "+str(degrees))
		main.mesh_view.shadows_enabled = true
		evidence.intact_angles.append({"degrees":degrees,"source_on_sha256":digest(before.get_data()),"source_off_sha256":digest(hidden.get_data()),"shadows_off_sha256":digest(off.get_data())})
	var s: WorkingSurface = main.block.working_map
	P5Fixture.reveal(s,[35,0,0,0])
	await settle()
	var scale := Vector2(root.size)/Vector2(root.content_scale_size)
	evidence["partial_angles"] = []
	for degrees in ANGLES:
		lamp.set_azimuth(degrees)
		var before := await skull_picture("lamp-partial-"+str(int(degrees)))
		var caster_before := digest(main.mesh_view.shadow_caster.mesh.surface_get_arrays(0)[Mesh.ARRAY_INDEX].to_byte_array())
		main.mesh_view.model.hide()
		await settle(4)
		await RenderingServer.frame_post_draw
		var hidden := root.get_texture().get_image()
		var safe := true
		for target in [Vector2(245,272),Vector2(480,307),Vector2(441,360),Vector2(628,383)]:
			var cell: int = s.fossil.field.index_at_map(target)
			check(s.fossil.exposed[cell] == 0,"partial screenshot oracle targets truly buried Bone: "+str(target)+" / "+str(degrees))
			var centre := Vector2i(at(target)*scale)
			var box := Rect2i(centre-Vector2i(10,10),Vector2i(20,20))
			if digest(before.get_region(box).get_data()) != digest(hidden.get_region(box).get_data()): safe = false
		check(safe,"covered jaw/spine/rib/limb pixels cannot reveal hidden source: "+str(degrees))
		check(digest(main.mesh_view.shadow_caster.mesh.surface_get_arrays(0)[Mesh.ARRAY_INDEX].to_byte_array()) == caster_before,"lamp movement never adds hidden cells to partial caster: "+str(degrees))
		main.mesh_view.model.show()
		evidence.partial_angles.append({"degrees":degrees,"covered_regions_equal":safe,"submitted_cells":main.mesh_view.caster_cells.size(),"caster_indices_sha256":caster_before})
	main.prepare_native_skeleton_review()
	P5Fixture.clean(s)
	main.camera.set_process(true)
	await zoom_to(3,Vector2(430,330))
	main.camera.set_process(false)
	await settle(4)
	var stable := state()
	var pictures := []
	for degrees in [-125.0,-45.0,0.0,35.0]:
		lamp.set_azimuth(degrees)
		pictures.append(await skull_picture("lamp-prepared-"+str(int(degrees))))
	check(digest(pictures[0].get_data()) != digest(pictures[3].get_data()),"real source relocation visibly changes prepared relief and shadows")
	check(state() == stable,"all lighting comparisons preserve the complete prepared specimen")
	lamp.reset_pose()
	lamp.set_active(true)
	await skull_picture("lamp-controls")
	lamp.set_active(false)
	main.camera.set_process(true)
	await zoom_to(1)
	main.camera.set_process(false)
	lamp.reset_pose()
