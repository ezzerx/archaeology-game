extends "res://scripts/p6a/playtest_preparation_ui.gd"
## Player-facing precision only. Session metrics/snapshots/85/95 gates stay raw.
const DISPLAY_COMPLETE := 99.0
var condition_bar: ProgressBar
var archive_metrics: Label

static func display_percent(value: float, coverage: bool) -> int:
	# Even a true 100 cannot bypass the authoritative coverage guard.
	if value >= DISPLAY_COMPLETE and coverage: return 100
	return mini(99, floori(clampf(value, 0.0, 100.0)))

func setup(state: PreparationSession, input: ToolController, reset_action: Callable) -> void:
	super.setup(state, input, reset_action)
	var column := preparation_card.get_child(0)
	condition_bar = _bar(column)
	condition_bar.name = "BoneConditionGauge"
	condition_bar.tooltip_text = "Specimen care · Chisel contact can damage exposed Bone. Brush and Pick preserve it."
	column.move_child(condition_bar, condition_label.get_index() + 1)
	archive_metrics = _label(card.get_child(0), "", 20)
	archive_metrics.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card.get_child(0).move_child(archive_metrics, card_condition.get_index())
	refresh()

func refresh() -> void:
	super.refresh()
	var values := session.snapshot()
	var shown_exposure := display_percent(values.exposure, values.coverage_passed)
	var shown_clean := display_percent(values.cleanliness, values.coverage_passed)
	exposure_label.text = "%d%%" % shown_exposure
	cleanliness_label.text = "%d%%" % shown_clean
	exposure_bar.value = shown_exposure
	cleanliness_bar.value = shown_clean
	# Super.setup calls refresh before this subclass has created its gauge.
	if condition_bar != null:
		condition_bar.value = values.condition
		var tier := PreparationRules.condition_tier(values.condition)
		var palette := [GREEN, OCHRE, Color("a56338"), Color("974d42")]
		var style := condition_bar.get_theme_stylebox("fill").duplicate() as StyleBoxFlat
		style.bg_color = palette[tier]
		condition_bar.add_theme_stylebox_override("fill", style)
		condition_label.add_theme_color_override("font_color", palette[tier])
	if archive_metrics != null and session.archived:
		var archived := session.archive_snapshot
		archive_metrics.text = "Reveal %d%%   ·   Clean %d%%" % [
			display_percent(archived.exposure, archived.coverage_passed),
			display_percent(archived.cleanliness, archived.coverage_passed)]
