extends "res://scripts/p6a31/mastery_readability.gd"
## Binding proof only while Tripo Studio art is being produced.
var mesh_enabled := true
var mesh_view: Node3D
var mesh_surface_shader: Shader
var baseline_surface_shader: Shader

func _ready() -> void:
	super._ready()
	get_window().title="ArchaeologyGame — B-17 Mesh Binding Pilot"
	baseline_surface_shader=readability_shader
	mesh_surface_shader=Shader.new()
	mesh_surface_shader.code=_hook(readability_shader.code,"if (exposed_bone) { color = bone_color.rgb; }", "if (exposed_bone && debug_view == 0) { discard; }\nif (exposed_bone) { color = bone_color.rgb; }")
	mesh_view=preload("res://scripts/p6a32/fossil_mesh_view.gd").new()
	block.add_child(mesh_view)
	mesh_view.setup(block,preload("res://assets/p6a32/b17_binding_probe.glb"))
	_button("F6 · Squelette : mesh / témoin",panel.get_child(0),toggle_mesh)
	_apply_mesh()

func _apply_mesh() -> void:
	readability_shader=mesh_surface_shader if mesh_enabled else baseline_surface_shader
	hero_shader=readability_shader if readability_enabled else original_hero_shader
	set_hero_look(hero_enabled)
	mesh_view.enabled=mesh_enabled and readability_enabled and hero_enabled
	mesh_view.sync_state()
	_sync_visuals()

func toggle_mesh() -> void:
	controller.cancel_stroke()
	mesh_enabled=not mesh_enabled
	_apply_mesh()

func _unhandled_input(event:InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F6:
		toggle_mesh();get_viewport().set_input_as_handled();return
	super._unhandled_input(event)

func _process(delta:float) -> void:
	super._process(delta)
	if mesh_view == null: return
	var want := mesh_enabled and readability_enabled and hero_enabled
	if mesh_view.enabled != want:
		mesh_view.enabled=want
		mesh_view.sync_state()
