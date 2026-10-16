extends "res://scripts/preparation/readability/mastery_readability.gd"
## Bounded actual Tripo skull pilot, with native Bone fallback outside its coverage.
var mesh_enabled := true
var mesh_button: Button
var mesh_view: Node3D
var mesh_surface_shader: Shader
var baseline_surface_shader: Shader

func _ready() -> void:
	super._ready()
	get_window().title="ArchaeologyGame — B-17 Tripo Skull Pilot"
	baseline_surface_shader=readability_shader
	mesh_surface_shader=Shader.new()
	var code := _hook(readability_shader.code,"void vertex() {", "uniform sampler2D b17_mesh_coverage : filter_nearest, repeat_disable;\nvoid vertex() {")
	mesh_surface_shader.code=_hook(code,"if (exposed_bone) { color = bone_color.rgb; }", "if (exposed_bone && debug_view == 0 && texelFetch(b17_mesh_coverage, cell, 0).r > .5) { discard; }\nif (exposed_bone) { color = bone_color.rgb; }")
	mesh_view=preload("res://scripts/specimens/mesh_overlay_base/fossil_mesh_view.gd").new()
	block.add_child(mesh_view)
	mesh_view.setup(block,preload("res://assets/p6a32/b17_tripo_skull.glb"))
	mesh_button = _button("F6 · Crâne Tripo / témoin",panel.get_child(0),toggle_mesh)
	_apply_mesh()

func _apply_mesh() -> void:
	readability_shader=mesh_surface_shader if mesh_enabled else baseline_surface_shader
	hero_shader=readability_shader if readability_enabled else original_hero_shader
	set_hero_look(hero_enabled)
	for mat in [block.material,block.skirt_material]:
		mat.set_shader_parameter("b17_mesh_coverage",preload("res://assets/p6a32/b17_skull_coverage.png"))
	mesh_view.enabled=mesh_enabled and readability_enabled and hero_enabled
	mesh_view.sync_state()
	_sync_visuals()

func toggle_mesh() -> void:
	controller.cancel_stroke()
	mesh_enabled=not mesh_enabled
	_apply_mesh()

func _input(event:InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F6:
		toggle_mesh();get_viewport().set_input_as_handled();return
	super._input(event)

func _process(delta:float) -> void:
	super._process(delta)
	if mesh_view == null: return
	var want := mesh_enabled and readability_enabled and hero_enabled
	if mesh_view.enabled != want:
		mesh_view.enabled=want
		mesh_view.sync_state()
