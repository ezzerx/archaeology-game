extends CanvasLayer
## Isolated review of the same source GLB. Never writes preparation or collection state.
var owner_pilot: Node3D
var root_control: Control
var viewport: SubViewport
var camera: Camera3D
var pivot: Node3D
var model: Node3D
var meshes: Array[MeshInstance3D] = []
var opened := false
var dragging := false

func setup(pilot: Node3D) -> void:
	owner_pilot = pilot
	layer = 8
	root_control = Control.new()
	add_child(root_control)
	root_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_control.mouse_filter = Control.MOUSE_FILTER_STOP
	root_control.gui_input.connect(_on_gui_input)
	var container := SubViewportContainer.new()
	root_control.add_child(container)
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.stretch = true
	viewport = SubViewport.new()
	viewport.size = Vector2i(1280,720)
	viewport.own_world_3d = true
	container.add_child(viewport)
	var world := Node3D.new()
	viewport.add_child(world)
	var environment := WorldEnvironment.new()
	world.add_child(environment)
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color(.12,.105,.08)
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color(.94,.89,.79)
	environment.environment.ambient_light_energy = .6
	var key := DirectionalLight3D.new()
	world.add_child(key)
	key.rotation_degrees = Vector3(-55,-35,0)
	key.light_color = Color(1.0,.94,.82)
	key.light_energy = 1.2
	var fill := DirectionalLight3D.new()
	world.add_child(fill)
	fill.rotation_degrees = Vector3(-25,130,0)
	fill.light_color = Color(.75,.82,.95)
	fill.light_energy = .35
	pivot = Node3D.new()
	world.add_child(pivot)
	model = preload("res://assets/p6a34/b17_production_patch.glb").instantiate()
	pivot.add_child(model)
	var material := ShaderMaterial.new()
	material.shader = preload("res://shaders/p6a34_production_bone.gdshader")
	material.set_shader_parameter("inspection",true)
	material.set_shader_parameter("hero_bone",preload("res://assets/p6a2/textures/bone/p6a2_bone_albedo_v02.png"))
	for mesh: MeshInstance3D in model.find_children("*","MeshInstance3D",true,false):
		meshes.append(mesh)
		mesh.material_override = material
	camera = Camera3D.new()
	world.add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.current = true
	camera.position = Vector3(.06,.36,.32)
	camera.look_at(Vector3.ZERO)
	var header := VBoxContainer.new()
	root_control.add_child(header)
	header.position = Vector2(36,24)
	header.add_theme_constant_override("separation",12)
	var title := Label.new()
	title.text = "Étude de collection · hors matrice"
	title.add_theme_font_size_override("font_size",30)
	header.add_child(title)
	var hint := Label.new()
	hint.text = "Modèle source propre · glisser pour tourner · molette pour rapprocher"
	hint.add_theme_font_size_override("font_size",19)
	header.add_child(hint)
	var row := HBoxContainer.new()
	header.add_child(row)
	for item in [["Ensemble",0],["Crâne",1],["Côtes",2],["Retour · F5 / Échap",-1]]:
		var button := Button.new()
		button.text = item[0]
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(150,44)
		row.add_child(button)
		if item[1] < 0: button.pressed.connect(toggle)
		else: button.pressed.connect(select_part.bind(item[1]))
	owner_pilot.controller.ui_blockers.append(root_control)
	select_part(0)
	root_control.hide()
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED

func select_part(which: int) -> void:
	var bounds := AABB()
	var first := true
	for mesh in meshes:
		mesh.visible = which == 0 or (which == 1 and "Skull" in mesh.name) or (which == 2 and "Rib" in mesh.name)
		if not mesh.visible: continue
		var local := model.global_transform.affine_inverse() * mesh.global_transform
		var box: AABB = local * mesh.get_aabb()
		bounds = box if first else bounds.merge(box)
		first = false
	model.position = -bounds.get_center()
	pivot.rotation = Vector3.ZERO
	camera.size = maxf(bounds.size.x*.95,bounds.size.z*1.4)+.055

func toggle() -> void:
	opened = not opened
	dragging = false
	owner_pilot.controller.cancel_stroke()
	root_control.visible = opened
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS if opened else SubViewport.UPDATE_DISABLED

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT: dragging = event.pressed
		if event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
			camera.size = clampf(camera.size * (.9 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.1),.08,.8)
	if event is InputEventMouseMotion and dragging:
		pivot.rotation.y += event.relative.x*.008
		pivot.rotation.x = clampf(pivot.rotation.x+event.relative.y*.008,-1.35,1.35)
	root_control.accept_event()
