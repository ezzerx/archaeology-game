class_name PreparationUI
extends CanvasLayer
## Fixed UI tree; the request owns completion, the dossier describes optional quality.
const DONE := Color(0.65, 0.9, 0.78)
const GOLD := Color(1.0, 0.84, 0.48)
var session: PreparationSession
var controller: ToolController
var root_control: Control
var dossier: PanelContainer
var objectives: PanelContainer
var tray: FragmentTray3D
var modal: ColorRect
var card: PanelContainer
var archive_button: Button
var keep_button: Button
var card_archive_button: Button
var another_button: Button
var classification_label: Label
var stats_label: Label
var component_labels: Array[Label] = []
var objective_labels: Array[Label] = []
var objective_details: Array[Label] = []
var request_status: Label
var notice_label: Label
var hover_label: Label
var card_title: Label
var card_subtitle: Label
var card_identity: Label
var card_stats: Label
var card_delta: Label
var card_badge: Label
var notice_timer: Timer
var _notices: Array[String] = []
var refresh_count := 0
var last_refresh_usec := 0
var headings: Array[Label] = []
var archive_sound: AudioStreamPlayer
var archive_tween: Tween
var quality_tweens: Array[Tween] = []
var quality_cue_count := 0
var archive_cue_count := 0

func _label(parent: Node, text: String, font_size := 19) -> Label:
	var result := Label.new()
	result.text = text
	result.add_theme_font_size_override("font_size", font_size)
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(result)
	return result

func _button(parent: Node, text: String, action: Callable, font_size := 22) -> Button:
	var result := Button.new()
	result.text = text
	result.custom_minimum_size.y = 42
	result.add_theme_font_size_override("font_size", font_size)
	result.focus_mode = Control.FOCUS_NONE
	result.pressed.connect(action)
	parent.add_child(result)
	return result

func _panel(at: Vector2, dimensions: Vector2, parent: Node = null) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.position = at
	panel.custom_minimum_size = dimensions
	panel.size = dimensions
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.12, 0.13, 0.96)
	style.border_color = Color(0.34, 0.39, 0.40)
	style.set_border_width_all(1)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", style)
	(parent if parent != null else root_control).add_child(panel)
	return panel

func _column(panel: Control, gap := 10) -> VBoxContainer:
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", gap)
	panel.add_child(column)
	return column

func setup(state: PreparationSession, input: ToolController, reset_action: Callable) -> void:
	session = state
	controller = input
	tray = controller.fragment_tray
	layer = 2
	root_control = Control.new()
	root_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_control)
	var header := _label(root_control, "MUSEUM PREPARATION LAB", 26)
	header.position = Vector2(28, 18)
	header.size = Vector2(600, 38)
	var subtitle := _label(root_control, "B-17 / Bring the specimen to light", 19)
	subtitle.position = Vector2(28, 53)
	subtitle.size = Vector2(600, 35)
	headings = [header, subtitle]
	objectives = _panel(Vector2(16, 130), Vector2(224, 0))
	var column := _column(objectives, 8)
	_label(column, "MUSEUM REQUEST", 21)
	_label(column, "Required work", 17).modulate = DONE
	for i in range(3):
		objective_labels.append(_label(column, "", 19))
		objective_details.append(_label(column, "", 16))
	request_status = _label(column, "", 17)
	archive_button = _button(column, "Archive Specimen", session.archive, 18)
	dossier = _panel(Vector2(1680, 130), Vector2(224, 0))
	column = _column(dossier)
	_label(column, "SPECIMEN B-17", 22)
	classification_label = _label(column, "Unknown", 20)
	_label(column, "PREPARATION RECORD\nInformation, not requirements", 15).modulate = Color(0.75, 0.79, 0.80)
	stats_label = _label(column, "", 18)
	_label(column, "OPTIONAL REFINEMENT", 16).modulate = GOLD
	for id in range(4): component_labels.append(_label(column, "", 16))
	_label(column, "★ Fine preparation\n95% exposed + 95% clean\nNever required to archive", 16).modulate = GOLD
	notice_label = _label(root_control, "", 21)
	notice_label.position = Vector2(680, 30)
	notice_label.size = Vector2(930, 65)
	notice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hover_label = _label(root_control, "", 22)
	hover_label.position = Vector2(430, 933)
	hover_label.size = Vector2(1070, 40)
	hover_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notice_timer = Timer.new()
	notice_timer.one_shot = true
	notice_timer.wait_time = 3.2
	add_child(notice_timer)
	notice_timer.timeout.connect(_next_notice)
	modal = ColorRect.new()
	modal.color = Color(0.025, 0.035, 0.04, 0.70)
	modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_control.add_child(modal)
	card = _panel(Vector2(630, 210), Vector2(660, 580), modal)
	column = _column(card, 18)
	card_badge = _label(column, "✓", 54)
	card_badge.modulate = DONE
	card_title = _label(column, "Museum request complete", 31)
	card_subtitle = _label(column, "Your museum job is done.", 23)
	card_identity = _label(column, "", 22)
	card_stats = _label(column, "", 20)
	card_delta = _label(column, "", 19)
	for label in [card_badge, card_title, card_subtitle, card_identity, card_stats, card_delta]:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	keep_button = _button(column, "Keep Cleaning · optional", session.keep_cleaning)
	card_archive_button = _button(column, "Archive Specimen", session.archive)
	another_button = _button(column, "Prepare Another Block", reset_action)
	controller.ui_blockers = [objectives, dossier, modal]
	controller.forceps_hover_changed.connect(_on_hover)
	session.changed.connect(refresh)
	session.notice.connect(_queue_notice)
	session.component_polished.connect(_shine_component)
	session.archive_created.connect(_celebrate_archive)
	session.surface.surface_reset.connect(_reset_notices)
	session.surface.fragments.changed.connect(_refresh_tray)
	archive_sound = AudioStreamPlayer.new()
	archive_sound.stream = _confirmation_sound()
	archive_sound.volume_db = -15
	add_child(archive_sound)
	refresh()

func _confirmation_sound() -> AudioStreamWAV:
	# A quiet, short two-note confirmation, generated once without external assets.
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	var bytes := PackedByteArray()
	bytes.resize(8820 * 2)
	for i in range(8820):
		var t := i / 22050.0
		var sample := sin(TAU * 523.25 * t) * exp(-t * 15) * minf(t * 150, 1)
		if t > 0.10: sample += sin(TAU * 783.99 * (t - 0.10)) * exp(-(t - 0.10) * 18) * minf((t - 0.10) * 150, 1)
		bytes.encode_s16(i * 2, int(clampf(sample * 0.35, -1, 1) * 32767))
	stream.data = bytes
	return stream

func _celebrate_archive(_snapshot: Dictionary) -> void:
	archive_cue_count += 1
	archive_sound.play()
	if archive_tween: archive_tween.kill()
	card.modulate.a = 0
	card.position.y = 226
	archive_tween = create_tween().set_parallel(true)
	archive_tween.tween_property(card, "modulate:a", 1.0, 0.25)
	archive_tween.tween_property(card, "position:y", 210.0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _shine_component(id: int) -> void:
	quality_cue_count += 1
	var row := component_labels[id - 1]
	row.modulate = Color(1.4, 1.25, 0.7)
	var tween := create_tween()
	tween.tween_property(row, "modulate", GOLD, 0.85)
	quality_tweens.append(tween)

func _reset_notices() -> void:
	_notices.clear()
	notice_timer.stop()
	notice_label.text = ""
	hover_label.text = ""
	archive_sound.stop()
	if archive_tween: archive_tween.kill()
	for tween in quality_tweens:
		if tween and tween.is_valid(): tween.kill()
	quality_tweens.clear()
	quality_cue_count = 0
	archive_cue_count = 0
	card.modulate = Color.WHITE
	card.position.y = 210
	for row in component_labels: row.modulate = Color.WHITE

func _queue_notice(message: String) -> void:
	if message in _notices or message == notice_label.text: return
	if _notices.size() >= 5: _notices.pop_front()
	_notices.append(message)
	if notice_timer.is_stopped(): _next_notice()

func _next_notice() -> void:
	notice_label.text = "" if _notices.is_empty() else _notices.pop_front()
	if not notice_label.text.is_empty(): notice_timer.start()

func _on_hover(_id: int, message: String) -> void:
	if session.surface.fragments.grabbed >= 0:
		hover_label.text = "Release inside the desk tray" if tray.in_view() else "Home: return the fragment and show the desk tray"
	else:
		hover_label.text = message
		if controller.selected_index == 4 and not tray.in_view(): hover_label.text = "Home: show the desk tray before picking up a fragment"

func _refresh_tray() -> void:
	if session.surface.fragments.grabbed >= 0: _on_hover(-1, "")
	elif hover_label.text.begins_with("Release inside"): hover_label.text = ""

func refresh() -> void:
	var start := Time.get_ticks_usec()
	var values := session.snapshot()
	classification_label.text = values.classification
	stats_label.text = "Exposure       %.1f %%\nCleanliness    %.1f %%\nCondition      %.0f %%" % [values.exposure, values.cleanliness, values.condition]
	for id in range(1, 5):
		var marked := session.quality_marks[id - 1]
		component_labels[id - 1].text = "%s — %s%s\n%.1f%% exposed · %.1f%% clean" % [
			["", "Skull", "Spine", "Ribs", "Hind Limb"][id], session.component_states[id - 1], " ★" if marked else "",
			session.surface.fossil.exposure_percent(id), session.surface.bone_film.cleanliness_percent(id)]
		if not marked: component_labels[id - 1].modulate = Color.WHITE
	for i in range(3):
		objective_labels[i].text = ("✓ " if session.objective_done[i] else "□ ") + ["Prepare the skull", "Reveal 60% of skeleton", "Recover both fragments"][i]
		objective_labels[i].modulate = DONE if session.objective_done[i] else Color.WHITE
		objective_details[i].modulate = DONE if session.objective_done[i] else Color(0.78, 0.81, 0.82)
	var skull_exposure := session.surface.fossil.exposure_percent(1)
	var skull_cleanliness := session.surface.bone_film.cleanliness_percent(1)
	objective_details[0].text = "%.1f%% exposed · %.1f%% clean" % [skull_exposure, skull_cleanliness] if session.objective_done[0] else "Expose %.0f / 60%%\nClean %.0f / 50%%" % [floorf(skull_exposure), floorf(skull_cleanliness)]
	objective_details[1].text = "%.1f%% revealed" % values.exposure if session.objective_done[1] else "%.0f / 60%% revealed" % floorf(values.exposure)
	objective_details[2].text = "%d / 2 in the desk tray" % values.fragments
	request_status.text = "✓ Request complete\nReady to archive.\nFurther work: optional." if session.preparation_complete else "These are the only required goals. Further work is optional."
	request_status.modulate = DONE if session.preparation_complete else Color(0.78, 0.81, 0.82)
	_refresh_tray()
	archive_button.visible = session.preparation_complete and not session.archived and not session.card_open
	modal.visible = session.card_open or session.archived
	if modal.visible:
		controller.cancel_stroke()
		hover_label.text = ""
		var shown := session.archive_snapshot if session.archived else session.completion_snapshot
		card_title.text = "Specimen archived ✓" if session.archived else "Museum request complete ✓"
		card_subtitle.text = "Museum records updated." if session.archived else "Your museum job is done."
		card_identity.text = "B-17 · " + shown.classification
		card_stats.text = "Required work complete\n%d fragments recovered · Condition %.0f%%" % [shown.fragments, shown.condition]
		if session.archived:
			var quality := "Prepared for the museum. Extra polishing was optional."
			if shown.quality_count > 0: quality = "★ Optional fine preparation · %d component%s" % [shown.quality_count, "s" if shown.quality_count > 1 else ""]
			card_delta.text = quality + "\n\nThank you for bringing B-17 to light."
		else:
			card_stats.text += "\n%.1f%% exposed · %.1f%% clean" % [shown.exposure, shown.cleanliness]
			card_delta.text = "Archive now, or keep cleaning for optional ★ marks.\nYou do not need to reach 100%."
		card_delta.modulate = GOLD if session.archived else Color(0.80, 0.85, 0.83)
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
