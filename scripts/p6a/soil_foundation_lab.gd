extends "res://scripts/prototype_main.gd"
## Controlled A/B initial conditions, identical production tools/camera/rendering.
const BASE = preload("res://shaders/surface_debug.gdshader")
var profile: SoilFoundationProfile
var candidate := 0
var fixture := 0
var cleared := false
var patina := true
var panel: PanelContainer
var note: Label
var buttons: Array[Button] = []
var fixture_select: OptionButton
var soil_shader: Shader

func _ready() -> void:
	super._ready()
	get_window().title = "ArchaeologyGame — P6A1.5 Soil Foundation A/B"
	profile = _create_profile()
	soil_shader = Shader.new()
	var code := BASE.code
	code = _hook(code, "void vertex() {", '#include "res://shaders/p6a15_contact_deposits.gdshaderinc"\nvoid vertex() {')
	code = _hook(code, "float dust_cover = 0.0;", "float contact_deposit = 0.0;\n"
		+ "if (soil_lab_patina && debug_view == 0 && !is_skirt && !exposed_bone && layer > 0) {\n"
		+ "contact_deposit = soil_contact_deposit(UV, surface_layer_delta, layer);\n"
		+ "color = mix(color, soil_color.rgb * vec3(0.80, 0.85, 0.88), contact_deposit);\n}\nfloat dust_cover = 0.0;")
	code = _hook(code, "SPECULAR *= 1.0 - film_cover * 0.65;",
		"SPECULAR *= 1.0 - film_cover * 0.65;\nROUGHNESS = mix(ROUGHNESS, 0.97, contact_deposit);")
	soil_shader.code = code
	for material in [block.material, block.skirt_material]: material.shader = soil_shader
	_controls()
	reload()

func _create_profile() -> SoilFoundationProfile:
	return SoilFoundationProfile.new(block.working_map)

static func _hook(code: String, anchor: String, replacement: String) -> String:
	assert(code.count(anchor) == 1, "Soil lab adapter needs review: " + anchor)
	return code.replace(anchor, replacement)

func _button(text: String, box: Node, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size.y = 36
	button.pressed.connect(callback)
	box.add_child(button)
	return button

func _controls() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	panel = PanelContainer.new()
	panel.position = Vector2(1562, 14)
	panel.custom_minimum_size.x = 342
	layer.add_child(panel)
	controller.ui_blockers.append(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 5)
	panel.add_child(box)
	var title := Label.new()
	title.text = "P6A1.5 / SOIL A–B"
	title.add_theme_font_size_override("font_size", 20)
	box.add_child(title)
	for i in range(2):
		var b := _button(["A · Soil actuel", "B · Couverture fine (0–2 mm)"][i], box, select_candidate.bind(i))
		b.toggle_mode = true
		buttons.append(b)
	fixture_select = OptionButton.new()
	fixture_select.add_item("B-17 · matrice d’origine")
	fixture_select.add_item("Témoin · coin Sandstone pré-dégagé")
	fixture_select.focus_mode = Control.FOCUS_NONE
	fixture_select.item_selected.connect(select_fixture)
	box.add_child(fixture_select)
	_button("Recommencer le brossage (R)", box, reset_specimen)
	_button("Voir la matrice sans Soil (F9)", box, show_substrate)
	var toggle := CheckButton.new()
	toggle.text = "Patine par dépôts · ON / OFF"
	toggle.button_pressed = patina
	toggle.focus_mode = Control.FOCUS_NONE
	toggle.toggled.connect(set_patina)
	box.add_child(toggle)
	note = Label.new()
	note.custom_minimum_size.x = 334
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(note)
	var keys := Label.new()
	keys.text = "F8 : A/B + reset, vue conservée\nR : départ · F9 : matrice nue\nH : masquer · Home : vue initiale\n1–4 : outils habituels"
	box.add_child(keys)

func select_candidate(index: int) -> void:
	candidate = clampi(index, 0, 1)
	reload()

func select_fixture(index: int) -> void:
	fixture = clampi(index, 0, 1)
	cleared = false
	reload()

func set_patina(value: bool) -> void:
	patina = value
	for material in [block.material, block.skirt_material]: material.set_shader_parameter("soil_lab_patina", patina)

func reload() -> void:
	# Changing Soil is a new controlled trial: clear progress/debris/film together.
	# Camera is deliberately kept, so A/B uses the same view including player zoom.
	controller.reset_surface()
	controller.select_tool(0)
	profile.apply(block, candidate, fixture, cleared)
	session.flush()
	controller.refresh_view()
	set_patina(patina)
	for i in range(buttons.size()): buttons[i].set_pressed_no_signal(i == candidate)
	fixture_select.select(fixture)
	note.text = "Matrice nue commune à A/B.\nChisel / Pick pour creuser." if cleared else (
		"Soil actuel : sommet plat, couche épaisse.\nBrush pour commencer." if candidate == 0 else
		"Soil mince et discontinu sur le relief réel.\nBrush → matrice patinée → Chisel / Pick.")
	if fixture == 1: note.text += "\nCoin témoin pré-creusé, pas une nouvelle géologie."

func show_substrate() -> void:
	cleared = true
	reload()

func reset_specimen() -> void:
	if profile == null:
		super.reset_specimen()
		return
	cleared = false
	reload()
	camera.reset_view()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_F8: select_candidate(1 - candidate)
			KEY_F9: show_substrate()
			KEY_H: panel.visible = not panel.visible
			_:
				super._unhandled_input(event)
				return
		get_viewport().set_input_as_handled()
	else: super._unhandled_input(event)
