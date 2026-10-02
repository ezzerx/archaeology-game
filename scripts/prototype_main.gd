extends Node3D

@export_range(82.0, 86.0, 0.1) var camera_elevation_degrees := 84.0
@export_range(0.8, 1.5, 0.01) var camera_size := 0.85

@onready var block: ExcavationBlock = $ExcavationBlock
@onready var controller: ToolController = $ToolController
@onready var camera: PrecisionZoom = $Camera3D
@onready var debug_panel: PanelContainer = $Debug/Panel
@onready var debug_label: Label = $Debug/Panel/Text
@onready var toolbar: HBoxContainer = $Debug/Toolbar
@onready var bone_panel: PanelContainer = $Debug/BonePanel
@onready var bone_label: Label = $Debug/BonePanel/Text
@onready var bone_notice: Label = $Debug/BoneNotice

var _debug_elapsed := 0.0
var _notice_remaining := 0.0
var feedback: MaterialFeedback

func _ready() -> void:
	get_window().title = "ArchaeologyGame — P4 Material Reactions"
	feedback = MaterialFeedback.new()
	feedback.name = "MaterialFeedback"
	add_child(feedback)
	feedback.setup(block, controller)
	block.working_map.fossil.bone_first_contact.connect(_on_bone_first_contact)
	block.working_map.fossil.specimen_reset.connect(_on_specimen_reset)
	var button_group := ButtonGroup.new()
	for i in range(controller.tools.size()):
		var button := Button.new()
		button.name = controller.tools[i].display_name.replace(" ", "")
		button.text = "[%d] %s" % [i + 1, controller.tools[i].display_name]
		button.toggle_mode = true
		button.button_group = button_group
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(215, 44)
		button.add_theme_font_size_override("font_size", 22)
		button.pressed.connect(controller.select_tool.bind(i))
		toolbar.add_child(button)
	controller.tool_selected.connect(_update_toolbar)
	_update_toolbar(controller.selected_index)
	var angle := deg_to_rad(camera_elevation_degrees)
	var target := block.to_global(Vector3(0.0, block.thickness, 0.0))
	camera.position = target + Vector3(0.0, sin(angle), cos(angle)) * 3.0
	camera.look_at(target)
	camera.size = camera_size
	camera.initialize_view()
	camera.zoom_started.connect(controller.cancel_stroke)
	camera.pan_started.connect(controller.cancel_stroke)
	camera.view_changed.connect(controller.refresh_view)
	bone_panel.visible = debug_panel.visible
	bone_notice.hide()

func _on_bone_first_contact(_cell: Vector2i, _component: int) -> void:
	bone_notice.text = "Bone detected\nDelicate material underneath"
	bone_notice.show()
	_notice_remaining = 8.0

func _on_specimen_reset() -> void:
	_notice_remaining = 0.0
	bone_notice.hide()

func _update_toolbar(index: int) -> void:
	for i in range(toolbar.get_child_count()):
		var button := toolbar.get_child(i) as Button
		button.set_pressed_no_signal(i == index)
		button.modulate = Color(1.0, 0.85, 0.45) if i == index else Color.WHITE

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_R:
			controller.reset_surface()
			camera.reset_view()
		elif event.physical_keycode == KEY_F1:
			debug_panel.visible = not debug_panel.visible
			bone_panel.visible = debug_panel.visible
		elif event.physical_keycode == KEY_F2:
			block.set_debug_view(block.debug_view + 1)

func _process(delta: float) -> void:
	_notice_remaining = maxf(0.0, _notice_remaining - delta)
	if _notice_remaining <= 0.0:
		bone_notice.hide()
	_debug_elapsed += delta
	if not debug_panel.visible or _debug_elapsed < 0.1:
		return
	_debug_elapsed = 0.0
	var hit := controller.hit
	var config := controller.config
	var surface_info := "Height / Depth / Material: —"
	if hit.inside:
		var definition: MaterialDefinition = hit.material
		surface_info = ("Height %.4f | Depth %.1f mm\n%s | Resistance %.1f\n" % [hit.height, hit.depth * 1000.0, definition.display_name, definition.resistance]
			+ "Effectiveness %.2f | Base rate %.4f depth/s (%.2f mm/s), before fracture\n" % [config.effectiveness_for(definition.id), config.structural_rate(definition), config.structural_rate(definition) * (block.thickness - block.base_height) * 1000.0]
			+ "Residue %.3f | grey overlay in SHADED view" % block.working_map.residue.value_at(hit.uv))
	debug_label.text = ("P4 / %s / %s | %d FPS | %s\n" % [config.display_name, config.mode_name(), Engine.get_frames_per_second(), ["SHADED", "HEIGHT", "LAYERS", "NORMALS"][block.debug_view]]
		+ "Zoom %.2fx | Wheel: zoom | RMB drag: pan | Home: overview\n" % camera.zoom_factor
		+ "Radius %.0f texels | Power %.2f %s | Falloff %.2f\n" % [config.radius, config.power, "/impact" if config.interaction_mode == ToolDefinition.InteractionMode.IMPACT else "/s", config.falloff]
		+ "Screen: %s | %s\n" % [hit.screen, "IN BOUNDS" if hit.inside else "OUT OF BOUNDS"]
		+ "World: %s\nLocal: %s\n" % [hit.get("world", "—"), hit.get("local", "—")]
		+ "UV: %s | Map: %s\n" % [hit.get("uv", "—"), hit.get("map", "—")]
		+ "Cell: %s | %s\n" % [hit.get("cell", "—"), surface_info]
		+ "Chisel %.1f Hz | next %.3f s | impacts %d\n" % [controller.tools[1].cadence, controller.impact_clock.time_to_next(controller.tools[1].cadence), controller.total_impacts]
		+ "CPU edit %.2f ms (residue %.2f) | Pick %.2f ms\n" % [controller.last_edit_usec / 1000.0, controller.last_residue_edit_usec / 1000.0, controller.last_pick_usec / 1000.0]
		+ "Upload submit: height %.2f ms | residue %.3f ms (40 KiB)\n" % [block.last_upload_usec / 1000.0, block.last_residue_upload_usec / 1000.0]
		+ "Changed height %d / residue %d | DDA cells %d\n" % [controller.changed_texels, controller.changed_residue_cells, hit.get("visited_cells", 0)]
		+ "Fracture: %d stressed cells | %d chips last impact\n" % [block.working_map.fracture.stress.size(), block.working_map.fracture.last_chunks.size()]
		+ "DEV Wheel: Shift power | Ctrl falloff | Alt radius\n"
		+ "DEV F6/F7: radius -/+ | Shift: power | Ctrl: falloff")
	var fossil := block.working_map.fossil
	var hovered := "Hovered bone: — | Component: —"
	if hit.inside:
		var component: int = hit.bone_component
		hovered = "Hovered bone: %s | Exposed: %s\nComponent: %s\nCell height %.5f | Bone ceiling %s" % [
			"yes" if hit.bone else "no", "yes" if hit.bone_exposed else "no",
			FossilField.COMPONENT_NAMES[component], hit.cell_height, "%.5f" % hit.bone_ceiling if hit.bone else "—"]
	bone_label.text = ("%s / DEBUG\nExposure %.2f%% | %d / %d cells\nBone Condition %.0f%%\n" % [
		FossilField.SPECIMEN_NAME, fossil.exposure_percent(), fossil.exposed_cells, fossil.field.total_cells, fossil.condition]
		+ hovered + "\n")
	for component in range(1, FossilField.COMPONENT_NAMES.size()):
		bone_label.text += "%s: %.2f%%\n" % [FossilField.COMPONENT_NAMES[component], fossil.exposure_percent(component)]
	bone_label.text += "Contact: %s\nDamage: %s\nCap %d FPS | Physics %d Hz" % [fossil.last_bone_event,
		fossil.last_damage_event, Engine.max_fps, Engine.physics_ticks_per_second]
