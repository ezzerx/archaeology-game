extends "res://scripts/prototype_main.gd"
## Separate playable scene. The production scene and its controls remain untouched.
var variants: P6AMaterialVariants
var candidate := 0
var preset := 0
var patina := true
var stone_patina := false
var film_palette := true
var detail := true
var lab_layer: CanvasLayer
var lab_panel: PanelContainer
var candidate_buttons: Array[Button] = []
var preset_select: OptionButton
var note: Label
var readout: Label
var elapsed := 0.0

func _ready() -> void:
	super._ready()
	get_window().title = "ArchaeologyGame — P6A-1 Material Lab"
	variants = P6AMaterialVariants.new()
	_make_controls()
	select_candidate(0)
	# The lab, like an incoming gameplay specimen, starts closed.
	load_preset(0)

func _button(text: String, parent: Node, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size.y = 34
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func _toggle(text: String, value: bool, parent: Node, callback: Callable) -> void:
	var check := CheckButton.new()
	check.text = text
	check.button_pressed = value
	check.focus_mode = Control.FOCUS_NONE
	check.toggled.connect(callback)
	parent.add_child(check)

func _make_controls() -> void:
	lab_layer = CanvasLayer.new()
	lab_layer.layer = 5
	add_child(lab_layer)
	lab_panel = PanelContainer.new()
	lab_panel.position = Vector2(1554, 14)
	lab_panel.custom_minimum_size = Vector2(350, 0)
	lab_panel.add_theme_font_size_override("font_size", 18)
	lab_layer.add_child(lab_panel)
	controller.ui_blockers.append(lab_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	lab_panel.add_child(box)
	var heading := Label.new()
	heading.text = "P6A-1 / MATERIAL LAB"
	heading.add_theme_font_size_override("font_size", 20)
	box.add_child(heading)
	for i in range(4):
		var button := _button(P6AMaterialVariants.NAMES[i], box, select_candidate.bind(i))
		button.toggle_mode = true
		candidate_buttons.append(button)
	preset_select = OptionButton.new()
	for name in P6AMaterialPresets.NAMES: preset_select.add_item(name)
	preset_select.focus_mode = Control.FOCUS_NONE
	preset_select.item_selected.connect(load_preset)
	box.add_child(preset_select)
	_button("Reload this state", box, load_preset.bind(-1))
	_toggle("Soil → Clay patina", patina, box, func(v: bool): patina = v; _apply_material())
	_toggle("Clay → Sandstone patina", stone_patina, box, func(v: bool): stone_patina = v; _apply_material())
	_toggle("Bone Film palette", film_palette, box, func(v: bool): film_palette = v; _apply_material())
	_toggle("Fine surface normals", detail, box, func(v: bool): detail = v; _apply_material())
	note = Label.new()
	note.custom_minimum_size.x = 342
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(note)
	var keys := Label.new()
	keys.text = "F8: candidate · F9: next state\nF10: reload · H: hide lab panel\nR: intact · Home: view · 1–4: tools\nP5 ignores material options."
	box.add_child(keys)
	readout = Label.new()
	box.add_child(readout)

func select_candidate(index: int) -> void:
	controller.cancel_stroke()
	candidate = clampi(index, 0, 3)
	_apply_material()
	for i in range(candidate_buttons.size()): candidate_buttons[i].set_pressed_no_signal(i == candidate)

func _apply_material() -> void:
	variants.apply(block, candidate, patina, stone_patina, film_palette, detail)

func load_preset(index: int) -> void:
	var requested := clampi(index, 0, P6AMaterialPresets.NAMES.size() - 1) if index >= 0 else preset
	P6AMaterialPresets.apply(self, requested)
	preset = requested
	preset_select.select(preset)
	note.text = P6AMaterialPresets.NOTES[preset]
	_apply_material()

func reset_specimen() -> void:
	super.reset_specimen()
	# P5's Prepare Another Block button also returns the lab label to Intact.
	preset = 0
	if preset_select != null:
		preset_select.select(0)
		note.text = P6AMaterialPresets.NOTES[0]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_F8: select_candidate((candidate + 1) % 4)
			KEY_F9: load_preset((preset + 1) % P6AMaterialPresets.NAMES.size())
			KEY_F10: load_preset(-1)
			KEY_H: lab_panel.visible = not lab_panel.visible
			KEY_R:
				load_preset(0)
			_:
				super._unhandled_input(event)
				return
		get_viewport().set_input_as_handled()
	else: super._unhandled_input(event)

func _process(delta: float) -> void:
	super._process(delta)
	elapsed += delta
	if elapsed < 0.5 or readout == null: return
	elapsed = 0
	readout.text = "%d FPS · edit %.2f ms · pick %.2f ms" % [Engine.get_frames_per_second(),
		controller.last_edit_usec / 1000.0, controller.last_pick_usec / 1000.0]
