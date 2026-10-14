extends Node3D
## Presentation-only lamp manipulation. Source art and warm light parameters are
## reused unchanged; input capture prevents every excavation gesture while active.
const MIN_AZIMUTH := -125.0
const MAX_AZIMUTH := 35.0
var pilot: Node3D
var light: SpotLight3D
var art: Node3D
var home_light := Transform3D.IDENTITY
var home_art := Transform3D.IDENTITY
var focus := Vector3.ZERO
var azimuth_degrees := 0.0
var active := false
var dragging := false
var focused := true
var layer: CanvasLayer
var root_control: Control
var guard: Control
var toggle_button: Button
var help_panel: PanelContainer
var reset_button: Button

func setup(owner_pilot: Node3D) -> void:
	pilot = owner_pilot
	light = pilot.task_light
	art = pilot.lamp_art
	home_light = light.transform
	home_art = art.transform
	var forward := -home_light.basis.z
	focus = home_light.origin+forward*((.04-home_light.origin.y)/forward.y)
	layer = CanvasLayer.new()
	layer.layer = 7
	add_child(layer)
	root_control = Control.new()
	layer.add_child(root_control)
	root_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	guard = Control.new()
	root_control.add_child(guard)
	guard.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	guard.mouse_filter = Control.MOUSE_FILTER_IGNORE
	guard.hide()
	toggle_button = Button.new()
	root_control.add_child(toggle_button)
	toggle_button.position = Vector2(1670,66)
	toggle_button.size = Vector2(230,38)
	toggle_button.focus_mode = Control.FOCUS_NONE
	toggle_button.toggle_mode = true
	pilot.session_ui.style_button(toggle_button)
	toggle_button.pressed.connect(toggle)
	help_panel = PanelContainer.new()
	root_control.add_child(help_panel)
	help_panel.position = Vector2(570,22)
	help_panel.custom_minimum_size = Vector2(780,100)
	help_panel.add_theme_stylebox_override("panel",pilot.session_ui.paper_style())
	var box := VBoxContainer.new()
	help_panel.add_child(box)
	var title := Label.new()
	title.text = "Lampe de préparation"
	title.add_theme_font_override("font",pilot.session_ui.heading_font)
	title.add_theme_font_size_override("font_size",24)
	title.add_theme_color_override("font_color",pilot.session_ui.INK)
	box.add_child(title)
	var hint := Label.new()
	hint.text = "Glisser gauche/droite · L ou Échap : retour aux outils"
	hint.add_theme_font_size_override("font_size",18)
	hint.add_theme_color_override("font_color",pilot.session_ui.INK)
	box.add_child(hint)
	reset_button = Button.new()
	reset_button.text = "Replacer la lampe"
	reset_button.focus_mode = Control.FOCUS_NONE
	pilot.session_ui.style_button(reset_button)
	box.add_child(reset_button)
	reset_button.pressed.connect(reset_pose)
	help_panel.hide()
	register_blockers()
	get_window().size_changed.connect(cancel_drag)
	pilot.camera.zoom_started.connect(cancel_drag)
	pilot.camera.pan_started.connect(cancel_drag)
	refresh_availability()

func register_blockers() -> void:
	for control in [toggle_button,help_panel,guard]:
		if not pilot.controller.ui_blockers.has(control): pilot.controller.ui_blockers.append(control)

func available() -> bool:
	return pilot.hero_enabled and pilot.task_light_enabled and pilot.sensory_enabled and not pilot.inspection.opened and pilot.session.can_use_tools()

func refresh_availability() -> void:
	var usable := available()
	if active and not usable: set_active(false)
	toggle_button.disabled = not usable
	toggle_button.visible = pilot.hero_enabled
	toggle_button.text = "Retour outils · L" if active else "Lampe · L"
	toggle_button.set_pressed_no_signal(active)

func toggle() -> void:
	set_active(not active)

func set_active(enabled: bool) -> void:
	active = enabled and available()
	dragging = false
	pilot.controller.cancel_stroke()
	guard.visible = active
	help_panel.visible = active
	refresh_availability()
	pilot.controller.refresh_view()

func cancel_drag() -> void:
	dragging = false

func reset_pose() -> void:
	cancel_drag()
	set_azimuth(0.0)

func set_azimuth(degrees: float) -> void:
	azimuth_degrees = clampf(degrees,MIN_AZIMUTH,MAX_AZIMUTH)
	if is_zero_approx(azimuth_degrees):
		# Exact approved baseline, with no accumulated transform/rounding drift.
		art.transform = home_art
		light.transform = home_light
		return
	var swivel := Basis(Vector3.UP,deg_to_rad(azimuth_degrees))
	var base := swivel*home_art.origin
	# Keep the movable base on the tabletop perimeter. The source head/arm
	# remains rigid and swivels with it; no scaling or deformation of the art.
	base.x = clampf(base.x,-.70,.70)
	base.z = clampf(base.z,-.44,.44)
	art.transform = Transform3D(swivel*home_art.basis,base)
	light.position = base+swivel*(home_light.origin-home_art.origin)
	light.look_at(focus,Vector3.UP)

func _over_ui(point: Vector2) -> bool:
	for control in pilot.controller.ui_blockers:
		if control == guard: continue
		if control.is_visible_in_tree() and control.get_global_rect().has_point(point): return true
	return pilot.toolbar.is_visible_in_tree() and pilot.toolbar.get_global_rect().has_point(point)

func _input(event: InputEvent) -> void:
	if pilot == null or not focused: return
	if pilot.inspection.opened: return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_L:
			toggle()
			get_viewport().set_input_as_handled()
			return
		if active and event.physical_keycode == KEY_ESCAPE:
			set_active(false)
			get_viewport().set_input_as_handled()
			return
		if event.physical_keycode in [KEY_F5,KEY_F7,KEY_F8,KEY_F11,KEY_F12,KEY_1,KEY_2,KEY_3,KEY_4,KEY_KP_1,KEY_KP_2,KEY_KP_3,KEY_KP_4]:
			if active: set_active(false)
		if event.physical_keycode in [KEY_R,KEY_HOME]: cancel_drag()
	if not active: return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			# UI presses keep their release, including when the pointer leaves
			# the button. Consume only a gesture actually captured by the lamp.
			if not event.pressed and not dragging: return
			if event.pressed and _over_ui(event.position):
				cancel_drag()
				return
			pilot.controller.cancel_stroke()
			if event.pressed:
				if event.double_click: reset_pose()
				else: dragging = not pilot.camera.panning
			else: cancel_drag()
			get_viewport().set_input_as_handled()
		elif event.pressed: cancel_drag()
	elif event is InputEventMouseMotion and dragging:
		if not event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			cancel_drag()
		else:
			var width := maxf(1.0,get_viewport().get_visible_rect().size.x)
			set_azimuth(azimuth_degrees-event.relative.x/width*rad_to_deg(3.0))
		get_viewport().set_input_as_handled()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		focused = false
		cancel_drag()
	elif what == NOTIFICATION_WM_WINDOW_FOCUS_IN: focused = true
	elif what == NOTIFICATION_WM_MOUSE_EXIT: cancel_drag()

func _process(_delta: float) -> void:
	# A release can be consumed elsewhere (GUI/camera/window capture). The
	# global button state still ends the gesture; it never resumes on motion.
	if dragging and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): cancel_drag()
	if pilot != null: refresh_availability()
