class_name PreparationUI
extends CanvasLayer
## A fixed Control tree. Signals update text, counters, and visibility only.
var session: PreparationSession
var controller: ToolController
var root_control: Control
var dossier: PanelContainer
var objectives: PanelContainer
var tray: PanelContainer
var modal: ColorRect
var archive_button: Button
var keep_button: Button
var card_archive_button: Button
var another_button: Button
var classification_label: Label
var stats_label: Label
var component_label: Label
var objective_labels: Array[Label] = []
var objective_details: Array[Label] = []
var fragment_label: Label
var tray_hint: Label
var slots: Array[FragmentToken] = []
var notice_label: Label
var hover_label: Label
var card_title: Label
var card_subtitle: Label
var card_stats: Label
var card_delta: Label
var notice_timer: Timer
var _notices: Array[String] = []
var refresh_count := 0
var last_refresh_usec := 0
var headings: Array[Label] = []

func _label(parent: Node, text: String, font_size := 23) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _button(parent: Node, text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 48
	button.add_theme_font_size_override("font_size", 23)
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(action)
	parent.add_child(button)
	return button

func _panel(at: Vector2, dimensions: Vector2, parent: Node = null) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.position = at
	panel.custom_minimum_size = dimensions
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.12, 0.13, 0.96)
	style.border_color = Color(0.34, 0.39, 0.40)
	style.set_border_width_all(1)
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 18
	style.content_margin_bottom = 18
	panel.add_theme_stylebox_override("panel", style)
	(parent if parent != null else root_control).add_child(panel)
	return panel

func _column(panel: Control) -> VBoxContainer:
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	panel.add_child(column)
	return column

func setup(state: PreparationSession, input: ToolController, reset_action: Callable) -> void:
	session = state
	controller = input
	layer = 2
	root_control = Control.new()
	root_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_control)
	var header := _label(root_control, "MUSEUM PREPARATION LAB", 28)
	header.position = Vector2(28, 22)
	var subtitle := _label(root_control, "B-17  /  Reveal, prepare and document the specimen", 21)
	subtitle.position = Vector2(28, 60)
	headings = [header, subtitle]
	objectives = _panel(Vector2(20, 130), Vector2(310, 280))
	var column := _column(objectives)
	_label(column, "PREPARATION REQUEST", 22)
	for i in range(3):
		objective_labels.append(_label(column, "", 21))
		objective_details.append(_label(column, "", 19))
	_label(column, "Perfect cleaning is optional.", 19)
	dossier = _panel(Vector2(1580, 130), Vector2(320, 510))
	column = _column(dossier)
	_label(column, "SPECIMEN B-17", 27)
	classification_label = _label(column, "Unknown", 23)
	stats_label = _label(column, "", 22)
	_label(column, "COMPONENTS", 20)
	component_label = _label(column, "", 21)
	_label(column, "Exposure: bone revealed\nCleanliness: exposed film removed\nCondition: bone preserved", 17)
	archive_button = _button(column, "Archive Specimen", session.archive)
	tray = _panel(Vector2(20, 730), Vector2(310, 195))
	column = _column(tray)
	fragment_label = _label(column, "FRAGMENTS  0 / 2", 23)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	column.add_child(row)
	for id in range(2):
		var token := FragmentToken.new()
		token.fragment_id = id
		token.custom_minimum_size = Vector2(125, 62)
		token.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(token)
		slots.append(token)
	tray_hint = _label(column, "[5] Forceps → drag here", 19)
	notice_label = _label(root_control, "", 23)
	notice_label.position = Vector2(480, 36)
	notice_label.size = Vector2(950, 65)
	notice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notice_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hover_label = _label(root_control, "", 24)
	hover_label.position = Vector2(450, 922)
	hover_label.size = Vector2(1050, 48)
	hover_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notice_timer = Timer.new()
	notice_timer.one_shot = true
	notice_timer.wait_time = 3.2
	add_child(notice_timer)
	notice_timer.timeout.connect(_next_notice)
	modal = ColorRect.new()
	modal.color = Color(0.025, 0.035, 0.04, 0.72)
	modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_control.add_child(modal)
	var card := _panel(Vector2(620, 220), Vector2(680, 580), modal)
	column = _column(card)
	card_title = _label(column, "Preparation Complete", 34)
	card_subtitle = _label(column, "The museum's preparation request is fulfilled.", 22)
	card_stats = _label(column, "", 25)
	card_delta = _label(column, "", 21)
	keep_button = _button(column, "Keep Cleaning", session.keep_cleaning)
	card_archive_button = _button(column, "Archive Specimen", session.archive)
	another_button = _button(column, "Prepare Another Block", reset_action)
	controller.fragment_tray = tray
	controller.ui_blockers = [objectives, dossier, tray, modal]
	controller.forceps_hover_changed.connect(func(_id: int, message: String): hover_label.text = message)
	session.changed.connect(refresh)
	session.notice.connect(_queue_notice)
	session.surface.surface_reset.connect(_reset_notices)
	session.surface.fragments.changed.connect(_refresh_tray)
	refresh()

func _reset_notices() -> void:
	_notices.clear()
	notice_timer.stop()
	notice_label.text = ""
	hover_label.text = ""

func _queue_notice(message: String) -> void:
	if message in _notices or message == notice_label.text: return
	if _notices.size() >= 5: _notices.pop_front()
	_notices.append(message)
	if notice_timer.is_stopped(): _next_notice()

func _next_notice() -> void:
	notice_label.text = "" if _notices.is_empty() else _notices.pop_front()
	if not notice_label.text.is_empty(): notice_timer.start()

func _refresh_tray() -> void:
	var state := session.surface.fragments
	fragment_label.text = "FRAGMENTS  %d / 2" % state.recovered_count()
	for id in range(2): slots[id].occupied = state.recovered[id]
	tray_hint.text = "Release here to recover" if state.grabbed >= 0 else "[5] Forceps → drag here"
	tray.modulate = Color(0.7, 1, 0.86) if state.grabbed >= 0 else Color.WHITE
	if state.grabbed >= 0: hover_label.text = "Drag to the fragment tray • release elsewhere to return"
	elif hover_label.text.begins_with("Drag to the fragment tray"): hover_label.text = ""

static func summary(values: Dictionary) -> String:
	return "%s\n\nSkeleton exposed     %.1f %%\nBone cleanliness     %.1f %%\nFragments recovered  %d / 2\nCondition                %.0f %%" % [
		values.classification, values.exposure, values.cleanliness, values.fragments, values.condition]

func refresh() -> void:
	var start := Time.get_ticks_usec()
	var values := session.snapshot()
	classification_label.text = values.classification
	stats_label.text = "Exposure       %.1f %%\nCleanliness    %.1f %%\nCondition      %.0f %%" % [values.exposure, values.cleanliness, values.condition]
	component_label.text = ""
	for id in range(1, 5):
		component_label.text += "%s — %s\n  %.0f %% exposed · %.0f %% clean\n" % [
			["", "Skull", "Spine", "Ribs", "Hind Limb"][id], session.component_states[id - 1],
			floorf(session.surface.fossil.exposure_percent(id) + 0.0001), floorf(session.surface.bone_film.cleanliness_percent(id) + 0.0001)]
	for i in range(3):
		objective_labels[i].text = ("✓ " if session.objective_done[i] else "□ ") + ["Prepare the skull", "Reveal 60 % of skeleton", "Recover both fragments"][i]
		objective_labels[i].modulate = Color(0.65, 0.9, 0.78) if session.objective_done[i] else Color.WHITE
	objective_details[0].text = "  Reveal %.0f / 60 %%\n  Clean %.0f / 50 %%" % [floorf(session.surface.fossil.exposure_percent(1) + 0.0001), floorf(session.surface.bone_film.cleanliness_percent(1) + 0.0001)]
	objective_details[1].text = "  %.0f / 60 %% exposed" % floorf(values.exposure)
	objective_details[2].text = "  %d / 2 safely in tray" % values.fragments
	_refresh_tray()
	archive_button.visible = session.preparation_complete and not session.archived and not session.card_open
	modal.visible = session.card_open or session.archived
	if modal.visible:
		controller.cancel_stroke()
		hover_label.text = ""
		card_title.text = "Specimen Archived" if session.archived else "Preparation Complete"
		card_subtitle.text = "Museum records updated." if session.archived else "The museum's preparation request is fulfilled."
		card_stats.text = summary(session.archive_snapshot if session.archived else session.completion_snapshot)
		card_delta.text = "You can keep revealing and cleaning before archiving."
		if session.archived:
			var final := session.archive_snapshot
			var first := session.completion_snapshot
			card_delta.text = "Additional preparation\nExposure %+.1f pts · Cleanliness %+.1f pts\nCondition %+.0f pts\nPrepare another B-17 block when you're ready." % [final.exposure - first.exposure,
				final.cleanliness - first.cleanliness, final.condition - first.condition]
	keep_button.visible = session.card_open
	card_archive_button.visible = session.card_open
	another_button.visible = session.archived
	refresh_count += 1
	last_refresh_usec = Time.get_ticks_usec() - start

func set_debug_visible(value: bool) -> void:
	dossier.visible = not value
	objectives.visible = not value
	for label in headings: label.visible = not value
	notice_label.visible = not value
	tray.position.y = 810 if value else 730
