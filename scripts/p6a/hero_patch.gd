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

func _ready() -> void:
	super._ready()
	select_candidate(1)
	get_window().title = "ArchaeologyGame — P6A2 Hero Patch"
	witness_shader = soil_shader
	hero_shader = Shader.new()
	var code := witness_shader.code
	code = _hook(code, "void vertex() {", '#include "res://shaders/p6a2_materials.gdshaderinc"\nvoid vertex() {')
	code = _hook(code, "float contact_deposit = 0.0;", """
vec4 hero_data = hero_plate(UV, layer, exposed_bone);
if (debug_view == 0) {
 float variation = (hero_data.r - .5) * (exposed_bone ? .20 : .65);
 color *= 1.0 + variation;
 color *= mix(1.0,hero_painted_value(UV,layer,exposed_bone),exposed_bone ? .32 : (layer == 0 ? .45 : .72));
 if (!exposed_bone) { color *= 1.0 - (hero_data.a-.5)*.22; }
 color *= 1.0 - hero_cavity(UV, surface_height) * (exposed_bone ? .35 : 1.0);
}
float contact_deposit = 0.0;
""")
	code = _hook(code, "bone_color.rgb * vec3(0.32, 0.25, 0.19)", "bone_color.rgb * vec3(0.48, 0.37, 0.24)")
	code = _hook(code, "vec3(0.56, 0.46, 0.31)", "vec3(0.25, 0.19, 0.12)")
	code = _hook(code, "vec3(0.86, 0.76, 0.58)", "vec3(0.47, 0.37, 0.25)")
	code = _hook(code, "if (debug_view != 0) {", """
if (debug_view == 0) {
 float dry = exposed_bone ? .49 : (layer == 0 ? .98 : (layer == 1 ? .87 : .91));
 ROUGHNESS = clamp(dry + (hero_data.b-.5)*.16 + film_cover*.28 + dust_cover*.12, .4, 1.0);
 vec3 cosmetic_normal = exposed_bone ? normalize((VIEW_MATRIX*MODEL_MATRIX*vec4(hero_bone_normal(UV),0.0)).xyz) : relief_normal;
 float micro = (hero_data.g-.5)*.3 + (hero_painted_value(UV,layer,exposed_bone)-1.0)*.7;
 NORMAL = hero_bump_normal(VERTEX, cosmetic_normal, micro*(exposed_bone ? .000025 : .00012));
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
		mesh.material_override = preload("res://materials/p6a2/plaster.tres") if mesh.name == "jacket_shell" else preload("res://materials/p6a2/canvas.tres")
	panel.hide()
	var box := panel.get_child(0)
	box.get_child(0).text = "P6A2 / HERO LOOKDEV"
	for button in buttons: button.hide()
	look_button = _button("F8 · Voir le témoin B", box, toggle_look)
	box.get_child(0).tooltip_text = "Même état de fouille et même caméra."
	# Replace the inherited geometry-key hint, not the gameplay HUD.
	for child in box.get_children():
		if child is Label and (child.text.begins_with("F8:") or child.text.begins_with("F8 :")):
			child.text = "F8 : look Hero / témoin B (sans reset)\nF9 : matrice nue · H : panneau\nR : départ · Home : vue · 1–4 : outils"
	ready_for_look = true
	set_hero_look(true)

func toggle_look() -> void:
	set_hero_look(not hero_enabled)

func set_hero_look(enabled: bool) -> void:
	hero_enabled = enabled
	if not ready_for_look: return
	for mat in [block.material, block.skirt_material]:
		mat.shader = hero_shader if enabled else witness_shader
		mat.set_shader_parameter("soil_color", Color(.265,.175,.10) if enabled else block.material_definitions[0].debug_color)
		mat.set_shader_parameter("clay_color", Color(.47,.225,.11) if enabled else block.material_definitions[1].debug_color)
		mat.set_shader_parameter("sandstone_color", Color(.34,.285,.215) if enabled else block.material_definitions[2].debug_color)
		mat.set_shader_parameter("bone_color", Color(.70,.67,.61) if enabled else Color(.94,.87,.72))
		mat.set_shader_parameter("hero_soil", preload("res://assets/p6a2/textures/soil/p6a2_soil_surface_data.png"))
		mat.set_shader_parameter("hero_clay", preload("res://assets/p6a2/textures/clay/p6a2_clay_surface_data.png"))
		mat.set_shader_parameter("hero_stone", preload("res://assets/p6a2/textures/sandstone/p6a2_sandstone_surface_data.png"))
		mat.set_shader_parameter("hero_bone", preload("res://assets/p6a2/textures/bone/p6a2_bone_surface_data.png"))
		mat.set_shader_parameter("hero_painted", preload("res://assets/p6a/material-atlas.png"))
	jacket.visible = enabled
	$TableEnvironment/Table.material_override = preload("res://materials/p6a2/workbench.tres") if enabled else original_table
	var environment := original_environment.duplicate() as Environment
	if enabled:
		environment.background_color = Color(.14,.105,.069)
		environment.ambient_light_color = Color(.91,.89,.86)
		environment.ambient_light_energy = .45
	$TableEnvironment/WorldEnvironment.environment = environment
	var light: DirectionalLight3D = $TableEnvironment/Light
	light.light_color = Color(1,.95,.89) if enabled else Color(1,.91,.79)
	light.light_energy = .65 if enabled else 1.0
	light.rotation_degrees = Vector3(-52,-135,0) if enabled else Vector3(-48,-145,0)
	feedback.colors = [Color(.33,.24,.14),Color(.59,.30,.155),Color(.34,.285,.215),Color(.78,.71,.55)] if enabled else original_colors.duplicate()
	feedback.loose_view.colors = [Color(.29,.20,.12),Color(.50,.28,.14),Color(.35,.29,.22)] if enabled else original_crumb_colors.duplicate()
	# Refresh only display instance colors, never mark logical debris dirty.
	for i in range(feedback.loose_view.keys.size()): feedback.loose_view.draw_key(i, feedback.loose_view.keys[i])
	look_button.text = "F8 · Voir le témoin B" if enabled else "F8 · Voir le Hero Patch"

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_F8:
		toggle_look()
		get_viewport().set_input_as_handled()
		return
	super._unhandled_input(event)
