class_name ToolController
extends Node

@export var block: ExcavationBlock
@export var camera: Camera3D
@export var tools: Array[ToolDefinition] = [preload("res://config/soft_brush.tres"),
	preload("res://config/chisel.tres"), preload("res://config/air_blower.tres")]
@export var toolbar: Control

signal tool_selected(index: int)

var selected_index := 0
var config: ToolDefinition:
	get: return tools[selected_index]
var impact_clock := ImpactClock.new()
var impacts_this_tick := 0
var total_impacts := 0
var last_residue_edit_usec := 0
var changed_residue_cells := 0
var _impact_flash := 0.0

var hit: Dictionary = {"screen": Vector2.ZERO, "inside": false}
var last_edit_usec := 0
var last_pick_usec := 0
var changed_texels := 0
var _held := false
var _previous_valid := false
var _previous := Vector2.ZERO
var _focused := true
var _pointer_inside := true
var _screen := Vector2.ZERO

func _ready() -> void:
	for i in range(tools.size()):
		tools[i] = tools[i].duplicate() as ToolDefinition
	_update_pointer_position()
	get_window().size_changed.connect(_update_pointer_position)

func _update_pointer_position() -> void:
	_screen = get_viewport().get_mouse_position()
	_previous_valid = false
	impact_clock.reset()

func select_tool(index: int) -> bool:
	if index < 0 or index >= tools.size():
		return false
	if index != selected_index:
		cancel_stroke() # Selection is immediate; a fresh click starts the new tool.
		selected_index = index
		tool_selected.emit(index)
	return true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var index := -1
		match event.physical_keycode:
			KEY_1, KEY_KP_1: index = 0
			KEY_2, KEY_KP_2: index = 1
			KEY_3, KEY_KP_3: index = 2
		if index >= 0:
			select_tool(index)
			get_viewport().set_input_as_handled()
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_held = _focused and _pointer_inside
			_previous_valid = false
			impact_clock.reset()
		elif event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			var direction := 1.0 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -1.0
			if event.shift_pressed:
				config.power += direction * 0.1
			elif event.ctrl_pressed:
				config.falloff += direction * 0.25
			else:
				config.radius += direction * 2.0
			_previous_valid = false
			impact_clock.reset()

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		_screen = event.position # Already in stretched viewport coordinates.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		cancel_stroke()

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
	impact_clock.reset()
	_impact_flash = 0.0
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func reset_surface() -> void:
	cancel_stroke() # R while held stays pristine until a fresh click.
	block.working_map.reset()
	block.flush_texture()
	total_impacts = 0

func _physics_process(delta: float) -> void:
	var pick_start := Time.get_ticks_usec()
	hit = block.pick(_screen, camera)
	last_pick_usec = Time.get_ticks_usec() - pick_start
	if not _focused or not _pointer_inside:
		hit.inside = false
	if toolbar != null and toolbar.is_visible_in_tree() and toolbar.get_global_rect().has_point(_screen):
		hit.inside = false
	changed_texels = 0
	last_edit_usec = 0
	last_residue_edit_usec = 0
	changed_residue_cells = 0
	impacts_this_tick = 0
	_impact_flash = maxf(0.0, _impact_flash - delta)
	if _held and hit.inside:
		var point: Vector2 = hit.map
		var start := Time.get_ticks_usec()
		if config.interaction_mode == ToolDefinition.InteractionMode.IMPACT:
			impacts_this_tick = impact_clock.advance(delta, config.cadence)
			for impact in range(impacts_this_tick):
				# No interpolation between impact locations. A delayed tick uses the
				# current exact pick, never fabricated historical cursor positions.
				if impact > 0:
					hit = block.pick(_screen, camera)
					if not hit.inside:
						break
					point = hit.map
				changed_texels += block.working_map.apply_impact(point, config)
				last_residue_edit_usec += block.working_map.last_residue_edit_usec
				changed_residue_cells += block.working_map.changed_residue_cells
				total_impacts += 1
				_impact_flash = 0.07
		else:
			changed_texels = block.working_map.apply_continuous(
				_previous if _previous_valid else point, point, config, delta)
			last_residue_edit_usec = block.working_map.last_residue_edit_usec
			changed_residue_cells = block.working_map.changed_residue_cells
		last_edit_usec = Time.get_ticks_usec() - start
		_previous = point
		_previous_valid = true
	else:
		_previous_valid = false
		impact_clock.reset()
	block.flush_texture()
	if changed_texels > 0:
		# The marker and F1 describe the surface rendered after this very edit.
		pick_start = Time.get_ticks_usec()
		hit = block.pick(_screen, camera)
		last_pick_usec += Time.get_ticks_usec() - pick_start
	var color := [Color(0.95, 0.8, 0.2), Color(1.0, 0.45, 0.18), Color(0.3, 0.85, 1.0)][selected_index] as Color
	block.show_cursor(hit, config.radius, color.lerp(Color.WHITE, _impact_flash / 0.07))
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN if hit.inside else Input.MOUSE_MODE_VISIBLE
