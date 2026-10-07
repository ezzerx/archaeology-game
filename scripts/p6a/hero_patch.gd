extends "res://scripts/p6a/natural_matrix_lab.gd"
## P6A2 isolated assembly. Geometry/profile/actions remain the inherited B.
var hero_enabled := true
var hero_shader: Shader
var witness_shader: Shader
var jacket: Node3D
var original_table: Material
var original_environment: Environment
var original_colors: Array = []
var original_crumb_colors: Array = []
var ready_for_look := false
var look_button: Button
var task_light: SpotLight3D
var bench_bounce: OmniLight3D
var task_light_enabled := true
var light_button: Button
var shadow_height_revision := -1
var display: Node
var soil_button: Button
var desk_art: Node3D

func _create_profile() -> SoilFoundationProfile:
	return preload("res://scripts/p6a/playtest_soil_profile.gd").new(block.working_map)

func _ready() -> void:
	super._ready()
	select_candidate(1)
	get_window().title = "ArchaeologyGame — Preparation B-17"
	witness_shader = soil_shader
	hero_shader = Shader.new()
	var code := witness_shader.code
	code = _hook(code, "void vertex() {", '#include "res://shaders/p6a2_materials.gdshaderinc"\nvoid vertex() {')
	code = _hook(code, "float contact_deposit = 0.0;", """
if (debug_view == 0) {
 vec3 hero_position = (inverse(MODEL_MATRIX)*INV_VIEW_MATRIX*vec4(VERTEX,1.0)).xyz;
 vec3 hero_normal = normalize(transpose(mat3(VIEW_MATRIX*MODEL_MATRIX))*relief_normal);
 color = hero_albedo(hero_position, hero_normal, exposed_bone ? 3 : layer);
 if (!exposed_bone && layer == 0 && hero_fragmented_soil) {
  // Only the actual, submillimetric Soil fringe blends toward its substrate.
  // No colour extends beyond the real Soil mask; picking/height stay native.
  float fringe = smoothstep(.025,.32,surface_layer_delta.r*excavatable_height*1000.0);
  vec3 substrate_color = hero_albedo(hero_position,hero_normal,1);
  float substrate_deposit = soil_lab_patina ? soil_contact_deposit(UV,vec2(0.0,surface_layer_delta.g),1) : 0.0;
  substrate_color = mix(substrate_color,soil_color.rgb*vec3(.80,.85,.88),substrate_deposit);
  color = mix(substrate_color,color,fringe);
 }
 color *= 1.0 - hero_cavity(UV, surface_height) * (exposed_bone ? .35 : 1.0);
}
float contact_deposit = 0.0;
""")
	code = _hook(code, "bone_color.rgb * vec3(0.32, 0.25, 0.19)", "bone_color.rgb * vec3(0.48, 0.37, 0.24)")
	code = _hook(code, "vec3(0.56, 0.46, 0.31)", "vec3(0.25, 0.19, 0.12)")
	code = _hook(code, "vec3(0.86, 0.76, 0.58)", "vec3(0.47, 0.37, 0.25)")
	code = _hook(code, "if (debug_view != 0) {", """
if (debug_view == 0) {
 float dry = exposed_bone ? .73 : (layer == 0 ? .98 : (layer == 1 ? .89 : .94));
 ROUGHNESS = clamp(dry + film_cover*.28 + dust_cover*.12, .4, 1.0);
 vec3 cosmetic_normal = exposed_bone ? normalize((VIEW_MATRIX*MODEL_MATRIX*vec4(hero_bone_normal(UV),0.0)).xyz) : relief_normal;
 NORMAL = cosmetic_normal;
}
if (debug_view != 0) {
""")
	hero_shader.code = code
	original_table = $TableEnvironment/Table.material_override
	original_environment = $TableEnvironment/WorldEnvironment.environment
	original_colors = feedback.colors.duplicate()
	original_crumb_colors = feedback.loose_view.colors.duplicate()
	jacket = preload("res://assets/p6a2/static/b17_jacket.glb").instantiate()
	jacket.name = "StaticJacket"
	add_child(jacket)
	for mesh: MeshInstance3D in jacket.find_children("*", "MeshInstance3D", true, false):
		mesh.material_override = preload("res://materials/p6a2/canvas.tres") if mesh.name == "jacket_burlap" else preload("res://materials/p6a2/plaster.tres")
	task_light = SpotLight3D.new()
	task_light.name = "PreparationLamp"
	add_child(task_light)
	task_light.position = Vector3(-.45,.80,-.30)
	task_light.look_at(Vector3(-.06,.04,-.01),Vector3.UP)
	task_light.light_color = Color(1.0,.94,.83)
	task_light.light_energy = 1.20
	task_light.spot_range = 1.9
	task_light.spot_attenuation = 1.1
	task_light.spot_angle = 50.0
	task_light.spot_angle_attenuation = 1.3
	task_light.shadow_enabled = true
	task_light.shadow_bias = .03
	task_light.shadow_normal_bias = .5
	# Restrained table bounce keeps the front matrix wall readable. It does not
	# cast competing shadows or flatten the main upper-left lamp direction.
	bench_bounce = OmniLight3D.new()
	bench_bounce.name = "WorkbenchBounce"
	add_child(bench_bounce)
	bench_bounce.position = Vector3(.12,.18,.65)
	bench_bounce.light_color = Color(1.0,.91,.80)
	bench_bounce.light_energy = .30
	bench_bounce.omni_range = 1.2
	bench_bounce.omni_attenuation = 2.0
	bench_bounce.shadow_enabled = false
	panel.hide()
	var box := panel.get_child(0)
	box.get_child(0).text = "P6A2 / HERO LOOKDEV"
	for button in buttons: button.hide()
	look_button = _button("F8 · Voir le témoin B", box, toggle_look)
	light_button = _button("F11 · Lampe locale / témoin directionnel",box,toggle_task_light)
	box.get_child(0).tooltip_text = "Même état de fouille et même caméra."
	# Replace the inherited geometry-key hint, not the gameplay HUD.
	for child in box.get_children():
		if child is Label and (child.text.begins_with("F8:") or child.text.begins_with("F8 :")):
			child.text = "F8 : look Hero / témoin B (sans reset)\nF9 : matrice nue · H : panneau\nR : départ · Home : vue · 1–4 : outils"
	ready_for_look = true
	set_hero_look(true)
	soil_button = _button("F10 · Soil précédent (réinitialise)",box,toggle_soil)
	# Replace presentation only; the shared PreparationSession is never replaced.
	session_ui.free()
	session_ui = preload("res://scripts/p6a/playtest_preparation_ui.gd").new()
	add_child(session_ui)
	session_ui.setup(session,controller,reset_specimen)
	controller.ui_blockers.append(panel)
	_restyle_workbench_ui()
	display = preload("res://scripts/p6a/playtest_display.gd").new()
	add_child(display)
	display.setup(controller)
	var screen_button := Button.new()
	screen_button.text = "Window · Alt+Enter" if get_window().mode == Window.MODE_FULLSCREEN else "Fullscreen · Alt+Enter"
	screen_button.focus_mode = Control.FOCUS_NONE
	session_ui.style_button(screen_button)
	session_ui.root_control.add_child(screen_button)
	screen_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	screen_button.position = Vector2(1670,18)
	screen_button.size = Vector2(230,38)
	screen_button.pressed.connect(display.toggle_fullscreen)
	display.fullscreen_button = screen_button
	controller.ui_blockers.append(screen_button)
	if ResourceLoader.exists("res://assets/p6a2/static/preparation_desk.glb"):
		desk_art = load("res://assets/p6a2/static/preparation_desk.glb").instantiate()
		add_child(desk_art)
		# The visible fixture explains the existing lamp; it adds no new light.
		for mesh: MeshInstance3D in desk_art.find_children("*","MeshInstance3D",true,false):
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF if mesh.name == "task_lamp" else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	if "--export-smoke" in OS.get_cmdline_user_args(): _export_smoke.call_deferred()

func _export_smoke() -> void:
	# Explicit QA-only route proves packed shader includes + GLB + native tools
	# in the release executable, without exporting the tests or source DCC files.
	AudioServer.set_bus_mute(0,true)
	controller.set_physics_process(false)
	for n in range(20): await get_tree().physics_frame
	controller.cancel_stroke()
	block.show_cursor({"inside":false},1)
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("user://p6a2_export_smoke.png")
	var before := block.working_map.image.get_data()
	for i in range(4):
		controller.select_tool(i)
		if i in [1,3]: block.working_map.apply_impact(Vector2(470,255),controller.config)
		else: block.working_map.apply_continuous(Vector2(420,255),Vector2(520,255),controller.config,.5)
	block.flush_texture();session.flush()
	var edited := before!=block.working_map.image.get_data()
	reset_specimen()
	var ok := edited and before==block.working_map.image.get_data() and desk_art!=null and candidate==1 and Engine.physics_ticks_per_second==60 and Engine.max_fps==240
	print("P6A2 EXPORT SMOKE ","PASS" if ok else "FAIL"," | engine=",Engine.get_version_info().string," | template=",OS.has_feature("template")," | native tools/reset=",ok," | capture=",OS.get_user_data_dir(),"/p6a2_export_smoke.png")
	get_tree().quit(0 if ok else 1)

func _restyle_workbench_ui() -> void:
	for child: Button in toolbar.get_children():
		session_ui.style_button(child)
		child.custom_minimum_size = Vector2(176,44)
		child.add_theme_font_size_override("font_size",18)
	toolbar.offset_left = -370
	toolbar.offset_right = 370
	toolbar.offset_top = -70
	toolbar.offset_bottom = -26
	toolbar.add_theme_constant_override("separation",8)
	$Debug/Help.text = "Left click · work     1–4 · tools     Wheel · zoom     Right drag · move     Home · overview     R · restart"
	$Debug/Help.add_theme_font_size_override("font_size",13)
	$Debug/Help.offset_top = -24
	$Debug/Help.offset_bottom = -3
	$Debug/Help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_update_toolbar(controller.selected_index)

func _update_toolbar(index: int) -> void:
	super._update_toolbar(index)
	for button in toolbar.get_children(): button.modulate = Color.WHITE

func toggle_soil() -> void:
	profile.fragmented = not profile.fragmented
	fixture = 0
	cleared = false
	reload()
	for mat in [block.material,block.skirt_material]: mat.set_shader_parameter("hero_fragmented_soil",profile.fragmented)
	soil_button.text = "F10 · Soil précédent (réinitialise)" if profile.fragmented else "F10 · Soil fragmenté (réinitialise)"

func toggle_look() -> void:
	set_hero_look(not hero_enabled)

func set_hero_look(enabled: bool) -> void:
	hero_enabled = enabled
	if not ready_for_look: return
	for mat in [block.material, block.skirt_material]:
		mat.shader = hero_shader if enabled else witness_shader
		mat.set_shader_parameter("hero_fragmented_soil",profile.fragmented)
		mat.set_shader_parameter("hero_soil",preload("res://assets/p6a2/textures/soil/p6a2_soil_albedo_v02.png"))
		mat.set_shader_parameter("hero_clay",preload("res://assets/p6a2/textures/clay/p6a2_clay_albedo_v02.png"))
		mat.set_shader_parameter("hero_stone",preload("res://assets/p6a2/textures/sandstone/p6a2_sandstone_albedo_v02.png"))
		mat.set_shader_parameter("hero_bone",preload("res://assets/p6a2/textures/bone/p6a2_bone_albedo_v02.png"))
		mat.set_shader_parameter("soil_color", Color(.265,.175,.10) if enabled else block.material_definitions[0].debug_color)
		mat.set_shader_parameter("clay_color", Color(.30,.145,.075) if enabled else block.material_definitions[1].debug_color)
		mat.set_shader_parameter("sandstone_color", Color(.34,.285,.215) if enabled else block.material_definitions[2].debug_color)
		mat.set_shader_parameter("bone_color", Color(.46,.405,.31) if enabled else Color(.94,.87,.72))
	jacket.visible = enabled
	if desk_art: desk_art.visible = enabled
	$TableEnvironment/Table.material_override = preload("res://materials/p6a2/workbench.tres") if enabled else original_table
	var environment := original_environment.duplicate() as Environment
	if enabled:
		environment.background_color = Color(.14,.105,.069)
		environment.ambient_light_color = Color(.91,.89,.86)
		environment.ambient_light_energy = .30 if task_light_enabled else .45
	$TableEnvironment/WorldEnvironment.environment = environment
	var light: DirectionalLight3D = $TableEnvironment/Light
	light.light_color = Color(1,.95,.89) if enabled else Color(1,.91,.79)
	light.light_energy = (.20 if task_light_enabled else .65) if enabled else 1.0
	light.rotation_degrees = Vector3(-52,-135,0) if enabled else Vector3(-48,-145,0)
	task_light.visible = enabled and task_light_enabled
	bench_bounce.visible = enabled and task_light_enabled
	feedback.colors = [Color(.28,.18,.10),Color(.46,.23,.11),Color(.27,.23,.18),Color(.71,.65,.53)] if enabled else original_colors.duplicate()
	feedback.loose_view.colors = [Color(.26,.17,.09),Color(.42,.22,.11),Color(.27,.23,.18)] if enabled else original_crumb_colors.duplicate()
	# Refresh only display instance colors, never mark logical debris dirty.
	for i in range(feedback.loose_view.keys.size()):
		var key: Vector3i = feedback.loose_view.keys[i]
		# A native Brush/Blower action can delete a cell before the next view
		# refresh. Leave its removal to the normal view update, not the look toggle.
		if feedback.loose_view.state.cells.has(key): feedback.loose_view.draw_key(i,key)
	look_button.text = "F8 · Voir le témoin B" if enabled else "F8 · Voir le Hero Patch"
	light_button.text = "F11 · Voir l’éclairage directionnel" if task_light_enabled else "F11 · Voir la lampe locale"

func toggle_task_light() -> void:
	task_light_enabled = not task_light_enabled
	set_hero_look(hero_enabled)

func _process(delta: float) -> void:
	super._process(delta)
	if not ready_for_look or block.upload_count == shadow_height_revision: return
	shadow_height_revision = block.upload_count
	# Vertex texture edits do not move the MeshInstance. Invalidate the local
	# light shadow cache when the real height texture changes, not on Film edits.
	task_light.shadow_enabled = false
	task_light.shadow_enabled = true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_F10:
		toggle_soil()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_F11:
		toggle_task_light()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_F8:
		toggle_look()
		get_viewport().set_input_as_handled()
		return
	super._unhandled_input(event)
