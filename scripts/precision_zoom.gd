class_name PrecisionZoom
extends Camera3D
## Fixed-orientation orthographic zoom and bounded RMB drag in the camera plane.

signal zoom_started
signal pan_started
signal view_changed

@export var block: ExcavationBlock
@export_range(1.0, 3.0, 0.1) var max_zoom := 3.0
@export_range(1.05, 1.5, 0.01) var wheel_step := 1.18
@export_range(5.0, 25.0, 0.5) var response := 14.0

var zoom_factor: float:
	get: return _base_size / size
var target_zoom := 1.0
var _base_size := 0.85
var _home := Transform3D.IDENTITY
var _anchor_world := Vector3.ZERO
var _anchor_screen := Vector2.ZERO
var _anchored := false
var _focused := true
var _window_size := Vector2i.ZERO
var panning := false
var _pan_screen := Vector2.ZERO

func _ready() -> void:
	process_priority = -10
	get_window().size_changed.connect(_stop_transition)
	if get_viewport() != get_window():
		get_viewport().size_changed.connect(_stop_transition)

func initialize_view() -> void:
	assert(projection == PROJECTION_ORTHOGONAL)
	_base_size = size
	_window_size = get_window().size
	_home = global_transform
	target_zoom = 1.0
	_anchored = false
	panning = false

func reset_view() -> void:
	zoom_started.emit()
	_window_size = get_window().size
	target_zoom = 1.0
	size = _base_size
	global_transform = _home
	_anchored = false
	panning = false
	view_changed.emit()

func _stop_transition() -> void:
	_window_size = get_window().size
	target_zoom = zoom_factor
	_anchored = false
	panning = false
	if is_node_ready() and block != null:
		_constrain_pan()
		view_changed.emit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		_focused = false
		_stop_transition()
	elif what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		_focused = true
	elif what == NOTIFICATION_WM_MOUSE_EXIT:
		_stop_transition()

func _input(event: InputEvent) -> void:
	# Finish a captured gesture even over UI. LMB during a pan never arms a tool;
	# after release the player must click again to excavate.
	if not panning:
		return
	if event is InputEventMouseMotion:
		if not event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
			panning = false
		else:
			global_position += project_ray_origin(_pan_screen) - project_ray_origin(event.position)
			_pan_screen = event.position
			_constrain_pan()
			view_changed.emit()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if not event.pressed:
				panning = false
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_LEFT:
			get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if not _focused:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_stop_transition()
		panning = true
		_pan_screen = event.position
		pan_started.emit()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton and event.pressed \
			and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		# Modified wheel input belongs to developer tool tuning, in any node order.
		if event.shift_pressed or event.ctrl_pressed or event.alt_pressed:
			return
		var direction := 1.0 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -1.0
		request_zoom(direction * maxf(event.factor, 0.01), event.position)
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_HOME:
		reset_view()
		get_viewport().set_input_as_handled()

func request_zoom(steps: float, screen: Vector2) -> void:
	if not _focused or not get_viewport().get_visible_rect().has_point(screen):
		return
	var next_zoom := clampf(target_zoom * pow(wheel_step, clampf(steps, -30.0, 30.0)), 1.0, max_zoom)
	if is_equal_approx(next_zoom, target_zoom):
		return
	# Pick the actual first surface hit, including sloping cavities and bone.
	var hit := block.pick(screen, self)
	_anchored = hit.inside
	if _anchored:
		_anchor_world = hit.world
		_anchor_screen = screen
	# Outside the block, zoom changes around the current view centre.
	target_zoom = next_zoom
	panning = false
	zoom_started.emit()

func _constrain_pan() -> void:
	# Keep a strip of the block's top rectangle visible on both axes. The fixed
	# camera has no roll/yaw, so this rectangle is also axis-aligned on screen.
	# Bounds depend on viewport size and zoom, never on mutable height samples.
	var viewport_size := get_viewport().get_visible_rect().size
	var lo := Vector2(INF, INF)
	var hi := Vector2(-INF, -INF)
	for x in [-0.5, 0.5]:
		for z in [-0.5, 0.5]:
			var corner := unproject_position(block.to_global(Vector3(
				x * block.surface_size.x, block.thickness, z * block.surface_size.y)))
			lo = lo.min(corner)
			hi = hi.max(corner)
	var margin := viewport_size.min(hi - lo) * 0.15
	var correction := Vector2(clampf(0.0, margin.x - hi.x, viewport_size.x - margin.x - lo.x),
		clampf(0.0, margin.y - hi.y, viewport_size.y - margin.y - lo.y))
	global_position += project_ray_origin(Vector2.ZERO) - project_ray_origin(correction)

func _process(delta: float) -> void:
	# With fixed viewport stretch, native-window resize may not emit size_changed.
	if get_window().size != _window_size:
		_stop_transition()
		zoom_started.emit()
	var target_size := _base_size / target_zoom
	# Camera properties use float32; equality to the float64 quotient may never
	# hold. Stop once that precision is reached instead of repicking forever.
	if absf(size - target_size) < 0.0000001:
		return
	size = lerpf(size, target_size, 1.0 - exp(-response * maxf(delta, 0.0)))
	if absf(size - target_size) < 0.000001:
		size = target_size
	if _anchored:
		# Orthogonal rays are parallel: translate in the camera plane so the
		# captured 3D point stays on exactly the same screen ray at every frame.
		var origin := project_ray_origin(_anchor_screen)
		var direction := project_ray_normal(_anchor_screen)
		global_position += _anchor_world - (origin + direction * (_anchor_world - origin).dot(direction))
	_constrain_pan()
	view_changed.emit()
