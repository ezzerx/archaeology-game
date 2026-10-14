extends "res://scripts/p6a33/tactile_preparation.gd"
## Mesh-authored pilot only. Validated tactile preparation is inherited unchanged.
var production_ready := false
var inspection: CanvasLayer

func _ready() -> void:
	super._ready()
	mesh_view.free()
	mesh_view = preload("res://scripts/p6a34/production_mesh_view.gd").new()
	block.add_child(mesh_view)
	mesh_view.setup(block)
	mesh_surface_shader = Shader.new()
	var code := _hook(baseline_surface_shader.code,"void vertex() {","uniform sampler2D production_coverage : filter_nearest, repeat_disable;\nvoid vertex() {")
	mesh_surface_shader.code = _hook(code,"if (exposed_bone) { color = bone_color.rgb; }","if (exposed_bone && debug_view == 0 && texelFetch(production_coverage,cell,0).r > .5) { discard; }\nif (exposed_bone) { color = bone_color.rgb; }")
	production_ready = true
	mesh_enabled = true
	_apply_mesh()
	inspection = preload("res://scripts/p6a34/asset_inspection.gd").new()
	add_child(inspection)
	inspection.setup(self)
	_button("F5 · Inspecter hors matrice",panel.get_child(0),inspection.toggle)
	_button("Zone pilote dégagée, os sales · réinitialise",panel.get_child(0),prepare_review_patch)
	get_window().title = "ArchaeologyGame — P6A3.4 Essai de production 3D"
	panel.get_child(0).get_child(0).text = "P6A3.4 / CRÂNE + CÔTES"
	_update_comparison_labels()

func _apply_mesh() -> void:
	if not production_ready:
		super._apply_mesh()
		return
	readability_shader = mesh_surface_shader if mesh_enabled else baseline_surface_shader
	hero_shader = readability_shader if readability_enabled else original_hero_shader
	set_hero_look(hero_enabled)
	for mat in [block.material,block.skirt_material]:
		mat.set_shader_parameter("production_coverage",mesh_view.coverage)
	mesh_view.enabled = mesh_enabled and readability_enabled and hero_enabled
	mesh_view.sync_state()
	_sync_visuals()

func toggle_readability() -> void:
	super.toggle_readability()
	# Rebuilding the preparation UI resets the blocker list; keep review modal registered.
	if inspection != null and not controller.ui_blockers.has(inspection.root_control):
		controller.ui_blockers.append(inspection.root_control)

func _update_comparison_labels() -> void:
	if not production_ready:
		super._update_comparison_labels()
		return
	var active := mesh_enabled and readability_enabled and hero_enabled
	mesh_button.text = "F6 · Pièces testées : mesh 3D actif" if active else "F6 · Pièces testées : relief témoin actif"
	readability_button.text = "F7 · Préparation tactile active" if readability_enabled else "F7 · Préparation P6A3 témoin active"

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_F5 or (inspection != null and inspection.opened and event.physical_keycode == KEY_ESCAPE):
			inspection.toggle()
			get_viewport().set_input_as_handled()
			return
		if inspection != null and inspection.opened:
			get_viewport().set_input_as_handled()
			return
	super._input(event)

func _process(delta: float) -> void:
	super._process(delta)
	if production_ready:
		debug_label.text = debug_label.text.replace("F6: crâne Tripo / os précédents","F5: inspection hors matrice | F6: mesh 3D / relief")

func prepare_review_patch() -> void:
	# Explicit controlled inspection fixture, not a recorded excavation session.
	# Normal launch stays fully covered. Only this announced reset stages a cut.
	controller.cancel_stroke()
	select_fixture(1)
	var surface := block.working_map
	var exposed := PackedInt32Array()
	for y in range(178,468):
		for x in range(166,498):
			var index := y*surface.size.x+x
			var ceiling := surface.structural_ceilings[index]
			surface._heights[index] = maxf(ceiling,.25)
			if ceiling > 0 and surface._heights[index] <= ceiling+FossilField.EXPOSURE_EPSILON:
				exposed.append(index)
	surface.image.set_data(surface.size.x,surface.size.y,false,Image.FORMAT_RF,surface._heights.to_byte_array())
	surface.dirty = true
	surface.fossil.expose_cells(exposed)
	block.flush_texture()
	session.flush()
	controller.select_tool(0)
	controller.refresh_view()
