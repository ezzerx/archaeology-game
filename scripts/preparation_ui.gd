class_name PreparationUI
extends CanvasLayer
## One fixed preparation card. Archive is the only modal; neither milestone stops work.
const DONE := Color(0.65, 0.9, 0.78)
const GOLD := Color(1.0, 0.84, 0.48)
var session: PreparationSession
var controller: ToolController
var root_control: Control
var preparation_card: PanelContainer
var state_label: Label
var condition_label: Label
var coverage_label: Label
var closure_label: Label
var exposure_label: Label
var cleanliness_label: Label
var exposure_bar: ProgressBar
var cleanliness_bar: ProgressBar
var fine_label: Label
var archive_button: Button
var keep_button: Button
var modal: ColorRect
var card: PanelContainer
var card_title: Label
var card_subtitle: Label
var card_star: Label
var card_condition: Label
var another_button: Button
var notice_label: Label
var notice_timer: Timer
var archive_sound: AudioStreamPlayer
var fine_sound: AudioStreamPlayer
var archive_tween: Tween
var quality_tween: Tween
var quality_cue_count := 0
var archive_cue_count := 0
var refresh_count := 0
var last_refresh_usec := 0
var _debug_visible := false

func _label(parent: Node, text: String, font_size := 18) -> Label:
	var result := Label.new()
	result.text = text
	result.add_theme_font_size_override("font_size", font_size)
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(result)
	return result

func _button(parent: Node, text: String, action: Callable, font_size := 18) -> Button:
	var result := Button.new()
	result.text = text
	result.custom_minimum_size.y = 40
	result.add_theme_font_size_override("font_size", font_size)
	result.focus_mode = Control.FOCUS_NONE
	result.pressed.connect(action)
	parent.add_child(result)
	return result

func _panel(parent: Node, dimensions: Vector2) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = dimensions
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.12, 0.13, 0.88)
	style.set_content_margin_all(14)
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	return panel

func _column(panel: Control, gap := 10) -> VBoxContainer:
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", gap)
	panel.add_child(column)
	return column

func _bar(parent: Node) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size.y = 8
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.step = 0.01
	parent.add_child(bar)
	return bar

func _metric(parent: Node, title: String) -> Label:
	var row := HBoxContainer.new()
	parent.add_child(row)
	var label := _label(row, title)
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var value := _label(row, "0%")
	value.autowrap_mode = TextServer.AUTOWRAP_OFF
	return value

func setup(state: PreparationSession, input: ToolController, reset_action: Callable) -> void:
	session = state
	controller = input
	layer = 2
	root_control = Control.new()
	root_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_control)
	preparation_card = _panel(root_control, Vector2(224, 0))
	preparation_card.name = "PreparationCard"
	preparation_card.position = Vector2(16, 130)
	var column := _column(preparation_card)
	column.minimum_size_changed.connect(_fit_preparation_card)
	_label(column, "SPECIMEN B-17", 18)
	state_label = _label(column, "", 19)
	exposure_label = _metric(column, "Reveal skeleton")
	exposure_bar = _bar(column)
	cleanliness_label = _metric(column, "Clean fossil")
	cleanliness_bar = _bar(column)
	condition_label = _label(column, "", 17)
	coverage_label = _label(column, "Major section still covered", 17)
	closure_label = _label(column, "Further preparation is optional.", 17)
	closure_label.modulate = DONE
	fine_label = _label(column, "", 17)
	fine_label.modulate = GOLD
	archive_button = _button(column, "Archive Specimen", session.archive)
	keep_button = _button(column, "Keep Cleaning", session.keep_cleaning)
	notice_label = _label(root_control, "", 21)
	notice_label.anchor_left = 0.3
	notice_label.anchor_right = 0.85
	notice_label.offset_top = 30
	notice_label.offset_bottom = 80
	notice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notice_timer = Timer.new()
	notice_timer.one_shot = true
	notice_timer.wait_time = 3.2
	add_child(notice_timer)
	notice_timer.timeout.connect(_clear_notice)
	modal = ColorRect.new()
	modal.color = Color(0.025, 0.035, 0.04, 0.70)
	modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_control.add_child(modal)
	var center := CenterContainer.new()
	modal.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card = _panel(center, Vector2(520, 0))
	column = _column(card, 22)
	card_title = _label(column, "✓ Specimen archived", 31)
	card_title.modulate = DONE
	card_subtitle = _label(column, "Museum records updated.", 23)
	card_star = _label(column, "★ Fine Preparation", 21)
	card_star.modulate = GOLD
	card_condition = _label(column, "", 21)
	for label in [card_title, card_subtitle, card_star, card_condition]:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	another_button = _button(column, "Prepare Another Block", reset_action, 22)
	controller.ui_blockers = [preparation_card, modal]
	session.changed.connect(refresh)
	session.notice.connect(_show_notice)
	session.finely_prepared.connect(_shine_star)
	session.archive_created.connect(_celebrate_archive)
	session.surface.surface_reset.connect(_reset_cues)
	var sound := _confirmation_sound()
	archive_sound = AudioStreamPlayer.new()
	archive_sound.stream = sound
	archive_sound.volume_db = -15
	add_child(archive_sound)
	fine_sound = AudioStreamPlayer.new()
	fine_sound.stream = sound
	fine_sound.volume_db = -19
	add_child(fine_sound)
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
	archive_tween = create_tween()
	archive_tween.tween_property(card, "modulate:a", 1.0, 0.25)

func _shine_star() -> void:
	quality_cue_count += 1
	fine_sound.play()
	fine_label.modulate = Color(1.5, 1.3, 0.8)
	quality_tween = create_tween()
	quality_tween.tween_property(fine_label, "modulate", GOLD, 0.75)

func _fit_preparation_card() -> void:
	# Autowrap resolves after container sorting; shrink after its new minimum arrives.
	preparation_card.reset_size.call_deferred()

func _clear_notice() -> void:
	notice_label.text = ""

func _show_notice(message: String) -> void:
	# Only the latest discovery is relevant; no queued checklist after completion.
	if session.archived: return
	# A discovery in the same action must not immediately erase care feedback.
	if notice_label.text.begins_with("Condition:") and not notice_timer.is_stopped() and not message.begins_with("Condition:"): return
	notice_label.text = message
	notice_timer.start()

func _reset_cues() -> void:
	notice_timer.stop()
	_clear_notice()
	archive_sound.stop()
	fine_sound.stop()
	if archive_tween: archive_tween.kill()
	if quality_tween: quality_tween.kill()
	quality_cue_count = 0
	archive_cue_count = 0
	card.modulate = Color.WHITE
	fine_label.modulate = GOLD

func refresh() -> void:
	var start := Time.get_ticks_usec()
	var values := session.snapshot()
	# Floor to avoid advertising 85/95 before the underlying threshold is met.
	exposure_label.text = "%d%%" % floori(values.exposure)
	cleanliness_label.text = "%d%%" % floori(values.cleanliness)
	exposure_bar.value = values.exposure
	cleanliness_bar.value = values.cleanliness
	state_label.text = "✓ Ready to archive" if session.preparation_complete else "Museum standard · %d%%" % PreparationRules.REQUIRED_EXPOSURE
	condition_label.text = "Condition · " + values.condition_tier
	coverage_label.visible = not session.preparation_complete and not session.coverage_passed and values.exposure >= PreparationRules.REQUIRED_EXPOSURE and values.cleanliness >= PreparationRules.REQUIRED_CLEANLINESS
	state_label.modulate = DONE if session.preparation_complete else Color.WHITE
	closure_label.visible = session.preparation_complete
	fine_label.visible = session.preparation_complete
	fine_label.text = "★ Fine Preparation" if session.fine_preparation else "★ Fine Preparation · %d%%\nOptional · both bars" % PreparationRules.QUALITY_EXPOSURE
	archive_button.visible = session.preparation_complete
	keep_button.visible = session.preparation_complete and not session.keep_cleaning_chosen
	preparation_card.visible = not _debug_visible and not session.archived
	modal.visible = session.archived
	card_star.visible = session.archive_snapshot.get("fine_preparation", false)
	card_condition.text = "Condition · " + str(session.archive_snapshot.get("condition_tier", "Excellent"))
	if session.archived:
		controller.cancel_stroke()
		notice_timer.stop()
		_clear_notice()
	# Let a VBox shrink again after optional controls disappear/reset.
	preparation_card.reset_size()
	card.reset_size()
	refresh_count += 1
	last_refresh_usec = Time.get_ticks_usec() - start

func set_debug_visible(value: bool) -> void:
	_debug_visible = value
	preparation_card.visible = not value and not session.archived
	notice_label.visible = not value
