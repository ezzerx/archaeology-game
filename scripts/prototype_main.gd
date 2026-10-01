extends Node3D

@export_range(82.0, 86.0, 0.1) var camera_elevation_degrees := 84.0
@export_range(0.8, 1.5, 0.01) var camera_size := 0.85

@onready var block: ExcavationBlock = $ExcavationBlock
@onready var controller: ToolController = $ToolController
@onready var camera: Camera3D = $Camera3D
@onready var debug_panel: PanelContainer = $Debug/Panel
@onready var debug_label: Label = $Debug/Panel/Text

var _debug_elapsed := 0.0

func _ready() -> void:
	get_window().title = "ArchaeologyGame — P1 Materials"
	var angle := deg_to_rad(camera_elevation_degrees)
	var target := block.to_global(Vector3(0.0, block.thickness, 0.0))
	camera.position = target + Vector3(0.0, sin(angle), cos(angle)) * 3.0
	camera.look_at(target)
	camera.size = camera_size

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
		surface_info = "Height %.4f | Depth %.1f mm\n%s | Resistance %.1f" % [hit.height, hit.depth * 1000.0, definition.display_name, definition.resistance]
	debug_label.text = ("P1 / DEBUG EXCAVATOR | %d FPS | %s\n" % [Engine.get_frames_per_second(), ["SHADED", "HEIGHT", "LAYERS", "NORMALS"][block.debug_view]]
		+ "Radius %.0f texels | Power %.2f/s | Falloff %.2f\n" % [config.radius, config.strength, config.falloff]
		+ "Screen: %s | %s\n" % [hit.screen, "IN BOUNDS" if hit.inside else "OUT OF BOUNDS"]
		+ "World: %s\nLocal: %s\n" % [hit.get("world", "—"), hit.get("local", "—")]
		+ "UV: %s | Map: %s\n" % [hit.get("uv", "—"), hit.get("map", "—")]
		+ "Cell: %s | %s\n" % [hit.get("cell", "—"), surface_info]
		+ "CPU edit %.2f ms | Upload submit %.2f ms | Pick %.2f ms\n" % [controller.last_edit_usec / 1000.0, block.last_upload_usec / 1000.0, controller.last_pick_usec / 1000.0]
		+ "Changed texels: %d | DDA cells: %d" % [controller.changed_texels, hit.get("visited_cells", 0)])
