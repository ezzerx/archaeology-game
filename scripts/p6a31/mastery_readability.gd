extends "res://scripts/p6a3/tool_feel.gd"
## Isolated P6A3.1 look/readability candidate; no tool or session retuning.
var readability_enabled := true
var original_hero_shader: Shader
var readability_shader: Shader
var readability_button: Button

func _create_feedback() -> MaterialFeedback:
	if sensory_enabled and readability_enabled:
		return preload("res://scripts/p6a31/cleaning_feedback.gd").new()
	return super._create_feedback()

func _ready() -> void:
	super._ready()
	get_window().title = "ArchaeologyGame — P6A3.1 Mastery & Readability"
	original_hero_shader = hero_shader
	readability_shader = Shader.new()
	var code := hero_shader.code
	code = _hook(code, "void vertex() {", '#include "res://shaders/p6a31_readability.gdshaderinc"\nvoid vertex() {')
	# Keep the accepted Film pattern, dirty-cell mask and amount authority.
	code = _hook(code, "film_cover = amount * (0.20 + 0.64 * smoothstep(0.28, 0.72, patch));",
		"film_cover = mastery_film(amount) * (0.20 + 0.64 * smoothstep(0.28, 0.72, patch));")
	code = _hook(code, "distance_texels - cursor_radius", "distance_texels - cursor_radius * mastery_cursor_scale")
	code = _hook(code, "ALBEDO = mix(color, cursor_color.rgb, marker);", """
if (exposed_bone && debug_view == 0) {
 float wear = mastery_wear(vec2(cell), mastery_condition);
 color *= 1.0 - wear * .60;
}
ALBEDO = mix(color, cursor_color.rgb, marker);
""")
	readability_shader.code = code
	readability_button = _button("F7 · Lisibilité P6A3 / P6A3.1", panel.get_child(0), toggle_readability)
	block.working_map.fossil.bone_condition_changed.connect(_sync_condition)
	block.working_map.surface_reset.connect(_sync_visuals)
	controller.tool_selected.connect(_sync_cursor)
	apply_readability()

func _create_mastery_ui() -> PreparationUI:
	return preload("res://scripts/p6a31/mastery_ui.gd").new()

func apply_readability() -> void:
	hero_shader = readability_shader if readability_enabled else original_hero_shader
	set_hero_look(hero_enabled)
	# Keep the existing fullscreen affordance (and its controller blocker).
	var fullscreen_button: Button = display.fullscreen_button
	if fullscreen_button.get_parent() != null:
		fullscreen_button.get_parent().remove_child(fullscreen_button)
	session_ui.free()
	session_ui = _create_mastery_ui() if readability_enabled else preload("res://scripts/p6a/playtest_preparation_ui.gd").new()
	add_child(session_ui)
	session_ui.setup(session, controller, reset_specimen)
	session_ui.root_control.add_child(fullscreen_button)
	controller.ui_blockers.append(fullscreen_button)
	controller.ui_blockers.append(panel)
	_sync_visuals()

func toggle_readability() -> void:
	controller.cancel_stroke()
	readability_enabled = not readability_enabled
	apply_readability()
	# Rebuild the consumer through the existing F12 route, without state reset.
	toggle_sensory()
	toggle_sensory()

func _sync_condition(_condition: float, _damage: float) -> void:
	_sync_visuals()

func _sync_cursor(_index: int) -> void:
	_sync_visuals()

func _sync_visuals() -> void:
	for mat in [block.material, block.skirt_material]:
		mat.set_shader_parameter("mastery_condition", block.working_map.fossil.condition)
		mat.set_shader_parameter("mastery_cursor_scale", .55 if controller.selected_index == 1 else 1.0)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_F7:
		toggle_readability()
		get_viewport().set_input_as_handled()
		return
