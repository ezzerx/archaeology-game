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

func _process(delta: float) -> void:
	_debug_elapsed += delta
	if not debug_panel.visible or _debug_elapsed < 0.1:
		return
	_debug_elapsed = 0.0
	var hit := controller.hit
	var config := controller.config
	var value := "—"
	if hit.inside:
		value = "%.6f" % block.working_map.value_at(hit.cell)
	debug_label.text = ("P0 / DEBUG EXCAVATOR   |   %d FPS\n" % Engine.get_frames_per_second()
		+ "Radius %.0f texels | Strength %.2f/s | Falloff %.2f\n" % [config.radius, config.strength, config.falloff]
		+ "Screen: %s | %s\n" % [hit.screen, "IN BOUNDS" if hit.inside else "OUT OF BOUNDS"]
		+ "World: %s\nLocal: %s\n" % [hit.get("world", "—"), hit.get("local", "—")]
		+ "UV: %s | Map: %s\n" % [hit.get("uv", "—"), hit.get("map", "—")]
		+ "Cell: %s | Value: %s\n" % [hit.get("cell", "—"), value]
		+ "CPU edit: %.2f ms | Changed texels: %d" % [controller.last_edit_usec / 1000.0, controller.changed_texels])
