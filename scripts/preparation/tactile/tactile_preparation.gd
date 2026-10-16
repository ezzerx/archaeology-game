extends "res://scripts/specimens/mesh_overlay_base/fossil_mesh_pilot.gd"
## Human-authorized local correction; previous candidates remain runnable.
var local_damage: RefCounted
var distinction: RefCounted

func _create_feedback() -> MaterialFeedback:
	if sensory_enabled and readability_enabled:
		return preload("res://scripts/preparation/tactile/cleaning_feedback.gd").new()
	return super._create_feedback()

func _create_mastery_ui() -> PreparationUI:
	var ui := preload("res://scripts/preparation/tactile/preparation_ui.gd").new()
	ui.distinction = distinction
	return ui

func _ready() -> void:
	super._ready()
	local_damage = preload("res://scripts/preparation/tactile/local_bone_damage.gd").new()
	local_damage.setup(block.working_map.fossil)
	baseline_surface_shader = _local_shader(baseline_surface_shader)
	mesh_surface_shader = _local_shader(mesh_surface_shader)
	mesh_view.material.shader = _local_shader(mesh_view.material.shader)
	mesh_enabled = false # Preferred historical Bone style; F6 still compares Tripo.
	_apply_mesh()
	_apply_cleaning_profile()
	distinction = preload("res://scripts/preparation/tactile/preparation_distinction.gd").new()
	# Tests isolate storage, so QA never awards the player's collection badge.
	var args := OS.get_cmdline_user_args()
	var path := "user://preparation_distinctions.json"
	for argument in args:
		if argument.begins_with("--distinction-store="): path = argument.trim_prefix("--distinction-store=")
	distinction.setup(session,path)
	session_ui.distinction = distinction
	distinction.changed.connect(_refresh_distinction)
	_refresh_distinction()
	get_window().title = "ArchaeologyGame — P6A3.3 Préparation tactile"
	panel.get_child(0).get_child(0).text = "P6A3.3 / PRÉPARATION TACTILE"
	_update_comparison_labels()

func _local_shader(source: Shader) -> Shader:
	var shader := Shader.new()
	var include := '#include "res://shaders/p6a31_readability.gdshaderinc"'
	var code := _hook(source.code,include,include+'\n#include "res://shaders/p6a33_local_damage.gdshaderinc"')
	code = code.replace("mastery_wear(vec2(cell), mastery_condition)","local_bone_wear(vec2(cell))")
	code = code.replace("mastery_wear(vec2(cell),b17_condition)","local_bone_wear(vec2(cell))")
	# Keep residual dirt readable without stretching its apparent lifetime.
	shader.code = code.replace("mastery_film(amount)","pow(clamp(amount / .85,0.0,1.0),.65)*.85")
	return shader

func _sync_visuals() -> void:
	super._sync_visuals()
	if local_damage == null: return
	for mat in [block.material,block.skirt_material,mesh_view.material]:
		mat.set_shader_parameter("local_damage_map",local_damage.texture)

func _apply_cleaning_profile() -> void:
	var film := block.working_map.bone_film
	film.stationary_clear_multiplier = .35 if readability_enabled else 1.0
	film.moving_clear_multiplier = 2.4 if readability_enabled else 1.0
	film.cleaning_falloff_scale = .55 if readability_enabled else 1.0
	film.finish_threshold = .025 if readability_enabled else 0.0

func toggle_readability() -> void:
	super.toggle_readability()
	_apply_cleaning_profile()
	_sync_visuals()
	_update_comparison_labels()

func toggle_mesh() -> void:
	super.toggle_mesh()
	_update_comparison_labels()

func _update_comparison_labels() -> void:
	if mesh_button == null: return
	var actually_visible := mesh_enabled and readability_enabled and hero_enabled
	mesh_button.text = "F6 · Crâne : Tripo actif" if actually_visible else "F6 · Crâne : os précédents actifs"
	if mesh_enabled and not actually_visible: mesh_button.text += " (Tripo masqué par comparaison)"
	readability_button.text = "F7 · Préparation : nouvelle passe active" if readability_enabled else "F7 · Préparation : témoin P6A3 actif"

func _refresh_distinction() -> void:
	if is_instance_valid(session_ui): session_ui.refresh()

func _process(delta: float) -> void:
	super._process(delta)
	debug_label.text = debug_label.text.replace("DEV F6/F7: radius -/+ | Shift: power | Ctrl: falloff", "F6: crâne Tripo / os précédents | F7: préparation nouvelle / témoin\nDEV Alt+wheel: radius | Shift+wheel: power | Ctrl+wheel: falloff")
	_update_comparison_labels()
