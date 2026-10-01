class_name ToolController
extends Node

@export var block: ExcavationBlock
@export var camera: Camera3D
@export var config: DebugExcavator

var hit: Dictionary = {"screen": Vector2.ZERO, "inside": false}
var last_edit_usec := 0
var changed_texels := 0
var _held := false
var _previous_valid := false
var _previous := Vector2.ZERO
var _focused := true
var _pointer_inside := true
var _screen := Vector2.ZERO

func _ready() -> void:
	config = config.duplicate() as DebugExcavator
	_update_pointer_position()
	get_window().size_changed.connect(_update_pointer_position)

func _update_pointer_position() -> void:
	_screen = get_viewport().get_mouse_position()
	_previous_valid = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_held = true
			_previous_valid = false
		elif event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			var direction := 1.0 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -1.0
			if event.shift_pressed:
				config.strength += direction * 0.1
			elif event.ctrl_pressed:
				config.falloff += direction * 0.25
			else:
				config.radius += direction * 2.0
			_previous_valid = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		_screen = event.position # Already in stretched viewport coordinates.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_held = false
		_previous_valid = false

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		_focused = false
		cancel_stroke()
	elif what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		_focused = true
		_update_pointer_position()
	elif what == NOTIFICATION_WM_MOUSE_EXIT:
		_pointer_inside = false
		cancel_stroke()
	elif what == NOTIFICATION_WM_MOUSE_ENTER:
		_pointer_inside = true

func cancel_stroke() -> void:
	_held = false
	_previous_valid = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func reset_surface() -> void:
	cancel_stroke() # R while held stays pristine until a fresh click.
	block.working_map.reset()
	block.flush_texture()

func _physics_process(delta: float) -> void:
	hit = block.pick(_screen, camera)
	if not _focused or not _pointer_inside:
		hit.inside = false
	block.show_cursor(hit, config.radius)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN if hit.inside else Input.MOUSE_MODE_VISIBLE
	changed_texels = 0
	last_edit_usec = 0
	if _held and hit.inside:
		var point: Vector2 = hit.map
		var start := Time.get_ticks_usec()
		changed_texels = block.working_map.apply_segment(
			_previous if _previous_valid else point, point,
			config.radius, config.strength, config.falloff, delta)
		last_edit_usec = Time.get_ticks_usec() - start
		_previous = point
		_previous_valid = true
	else:
		_previous_valid = false
	block.flush_texture()
