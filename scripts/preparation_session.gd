class_name PreparationSession
extends RefCounted
## Observes committed P4 state. Coalesces signal bursts; caches hidden-region coverage after exposure.
signal changed
signal notice(text: String)
signal completed(snapshot: Dictionary)
signal archive_created(snapshot: Dictionary)
signal finely_prepared
signal condition_tier_dropped(tier: String)

var surface: WorkingSurface
var classification_stage := 0
var component_states: Array[String] = []
var fine_preparation := false
var preparation_complete := false
var archived := false
var coverage_passed := false
var coverage_checks := 0
var largest_hidden_cluster := -1 # Unknown until the global exposure threshold.
var coverage: HiddenBoneCoverage
var condition_tier := 0
var _coverage_dirty := true
var _notified_condition_tiers := 0
var keep_cleaning_chosen := false
var completion_snapshot: Dictionary = {}
var archive_snapshot: Dictionary = {}
var additional_tool_actions_after_completion := 0
var refresh_count := 0
var last_refresh_usec := 0
var _completion_usec := 0
var _archive_usec := 0
var _pending := false

func _init(source: WorkingSurface) -> void:
	surface = source
	coverage = HiddenBoneCoverage.new(source.fossil)
	surface.fossil.bone_component_exposure_changed.connect(_on_exposure)
	surface.fossil.bone_condition_changed.connect(_on_condition)
	surface.fossil.bone_first_contact.connect(_on_discovery)
	surface.bone_film.cleaned.connect(invalidate)
	surface.tool_applied.connect(record_tool_action)
	surface.surface_reset.connect(reset)
	reset()

func _on_exposure(_component: int, _exposed: int, _total: int) -> void:
	_coverage_dirty = true
	invalidate()

func _on_condition(condition: float, _damage: float) -> void:
	var next := PreparationRules.condition_tier(condition)
	var first_drop := next > condition_tier and (_notified_condition_tiers & (1 << next)) == 0
	condition_tier = next
	if first_drop:
		_notified_condition_tiers |= 1 << next
		var tier: String = PreparationRules.CONDITION_TIERS[next]
		condition_tier_dropped.emit(tier)
		notice.emit("Condition: " + tier)
	invalidate()

func _on_discovery(_cell: Vector2i, _component: int) -> void:
	notice.emit("Bone detected — delicate material underneath")

func invalidate() -> void:
	if _pending: return
	_pending = true
	flush.call_deferred()

func flush() -> void:
	if not _pending: return
	if archived:
		_pending = false
		return
	_pending = false
	var started := Time.get_ticks_usec()
	var fossil := surface.fossil
	var exposures: Array[float] = []
	component_states.clear()
	for id in range(1, 5):
		exposures.append(fossil.exposure_percent(id))
		component_states.append(PreparationRules.component_state(exposures.back(), surface.bone_film.cleanliness_percent(id)))
	if _coverage_dirty and fossil.exposure_percent() >= PreparationRules.REQUIRED_EXPOSURE:
		_coverage_dirty = false
		largest_hidden_cluster = coverage.largest_cluster()
		coverage_passed = largest_hidden_cluster < PreparationRules.coverage_threshold(fossil.field.total_cells)
		coverage_checks += 1
	var stage := PreparationRules.classification(classification_stage, fossil.exposure_percent(), exposures)
	if stage != classification_stage:
		classification_stage = stage
		notice.emit("Discovery updated: " + PreparationRules.CLASSIFICATIONS[stage])
	var values := snapshot()
	if not fine_preparation and PreparationRules.fine_preparation(values.exposure, values.cleanliness):
		fine_preparation = true
		finely_prepared.emit()
	values.fine_preparation = fine_preparation
	if not preparation_complete and PreparationRules.preparation_complete(values.exposure, values.cleanliness, coverage_passed):
		preparation_complete = true
		_completion_usec = Time.get_ticks_usec()
		completion_snapshot = values.duplicate(true)
		completed.emit(completion_snapshot.duplicate(true))
	refresh_count += 1
	last_refresh_usec = Time.get_ticks_usec() - started
	changed.emit()

func snapshot() -> Dictionary:
	return {"classification": PreparationRules.CLASSIFICATIONS[classification_stage],
		"exposure": surface.fossil.exposure_percent(), "cleanliness": surface.bone_film.cleanliness_percent(),
		"condition": surface.fossil.condition, "fine_preparation": fine_preparation,
		"condition_tier": PreparationRules.CONDITION_TIERS[PreparationRules.condition_tier(surface.fossil.condition)],
		"coverage_passed": coverage_passed, "largest_hidden_cluster": largest_hidden_cluster}

func can_use_tools() -> bool:
	return not archived

func keep_cleaning() -> bool:
	if not preparation_complete or archived or keep_cleaning_chosen: return false
	keep_cleaning_chosen = true
	changed.emit()
	return true

func archive() -> bool:
	flush()
	if not preparation_complete or archived: return false
	archive_snapshot = snapshot()
	_archive_usec = Time.get_ticks_usec()
	archived = true
	archive_created.emit(archive_snapshot.duplicate(true))
	changed.emit()
	return true

func record_tool_action() -> void:
	if preparation_complete and can_use_tools(): additional_tool_actions_after_completion += 1

func metrics() -> Dictionary:
	var elapsed := float((_archive_usec if archived else Time.get_ticks_usec()) - _completion_usec) / 1e6 if preparation_complete else 0.0
	return {"time_after_completion": elapsed, "keep_cleaning_chosen": keep_cleaning_chosen,
		"exposure_at_completion": completion_snapshot.get("exposure", 0.0),
		"exposure_at_archive": archive_snapshot.get("exposure", 0.0),
		"cleanliness_at_completion": completion_snapshot.get("cleanliness", 0.0),
		"cleanliness_at_archive": archive_snapshot.get("cleanliness", 0.0),
		"condition_at_completion": completion_snapshot.get("condition", 100.0),
		"condition_at_archive": archive_snapshot.get("condition", 100.0),
		"additional_tool_actions_after_completion": additional_tool_actions_after_completion,
		"fine_at_completion": completion_snapshot.get("fine_preparation", false),
		"fine_at_archive": archive_snapshot.get("fine_preparation", false)}

func reset() -> void:
	_pending = false
	classification_stage = 0
	coverage_passed = false
	coverage_checks = 0
	largest_hidden_cluster = -1
	_coverage_dirty = true
	condition_tier = PreparationRules.condition_tier(surface.fossil.condition)
	_notified_condition_tiers = 0
	component_states = ["Hidden", "Hidden", "Hidden", "Hidden"]
	fine_preparation = false
	preparation_complete = false
	archived = false
	keep_cleaning_chosen = false
	completion_snapshot.clear()
	archive_snapshot.clear()
	_completion_usec = 0
	_archive_usec = 0
	additional_tool_actions_after_completion = 0
	refresh_count = 0
	last_refresh_usec = 0
	changed.emit()
