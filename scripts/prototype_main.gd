extends Node3D

@export_range(82.0, 86.0, 0.1) var camera_elevation_degrees := 84.0
@export_range(0.8, 1.5, 0.01) var camera_size := 0.85

@onready var block: ExcavationBlock = $ExcavationBlock
@onready var controller: ToolController = $ToolController
@onready var camera: Camera3D = $Camera3D
@onready var debug_panel: PanelContainer = $Debug/Panel
@onready var debug_label: Label = $Debug/Panel/Text
@onready var toolbar: HBoxContainer = $Debug/Toolbar

var _debug_elapsed := 0.0

func _ready() -> void:
	get_window().title = "ArchaeologyGame — P2 Tools"
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

func _update_toolbar(index: int) -> void:
	for i in range(toolbar.get_child_count()):
		var button := toolbar.get_child(i) as Button
		button.set_pressed_no_signal(i == index)
		button.modulate = Color(1.0, 0.85, 0.45) if i == index else Color.WHITE

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_R:
			controller.reset_surface()
		elif event.physical_keycode == KEY_F1:
			debug_panel.visible = not debug_panel.visible
		elif event.physical_keycode == KEY_F2:
			block.set_debug_view(block.debug_view + 1)

func _process(delta: float) -> void:
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
			+ "Effectiveness %.2f | Rate %.4f depth/s (%.2f mm/s)\n" % [config.effectiveness_for(definition.id), config.structural_rate(definition), config.structural_rate(definition) * (block.thickness - block.base_height) * 1000.0]
			+ "Residue %.3f | grey overlay in SHADED view" % block.working_map.residue.value_at(hit.uv))
	debug_label.text = ("P2 / %s / %s | %d FPS | %s\n" % [config.display_name, config.mode_name(), Engine.get_frames_per_second(), ["SHADED", "HEIGHT", "LAYERS", "NORMALS"][block.debug_view]]
		+ "Radius %.0f texels | Power %.2f %s | Falloff %.2f\n" % [config.radius, config.power, "/impact" if config.interaction_mode == ToolDefinition.InteractionMode.IMPACT else "/s", config.falloff]
		+ "Screen: %s | %s\n" % [hit.screen, "IN BOUNDS" if hit.inside else "OUT OF BOUNDS"]
		+ "World: %s\nLocal: %s\n" % [hit.get("world", "—"), hit.get("local", "—")]
		+ "UV: %s | Map: %s\n" % [hit.get("uv", "—"), hit.get("map", "—")]
		+ "Cell: %s | %s\n" % [hit.get("cell", "—"), surface_info]
		+ "Chisel %.1f Hz | next %.3f s | impacts %d\n" % [controller.tools[1].cadence, controller.impact_clock.time_to_next(controller.tools[1].cadence), controller.total_impacts]
		+ "CPU edit %.2f ms (residue %.2f) | Pick %.2f ms\n" % [controller.last_edit_usec / 1000.0, controller.last_residue_edit_usec / 1000.0, controller.last_pick_usec / 1000.0]
		+ "Upload submit: height %.2f ms | residue %.3f ms (40 KiB)\n" % [block.last_upload_usec / 1000.0, block.last_residue_upload_usec / 1000.0]
		+ "Changed height %d / residue %d | DDA cells %d" % [controller.changed_texels, controller.changed_residue_cells, hit.get("visited_cells", 0)])
