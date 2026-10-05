class_name PreparationSession
extends RefCounted
## Observes committed P4 state. Coalesces signal bursts; reads four counters only.
signal changed
signal notice(text: String)
signal completed(snapshot: Dictionary)
signal archive_created(snapshot: Dictionary)
signal component_polished(component: int)

var surface: WorkingSurface
var classification_stage := 0
var component_states: Array[String] = []
var quality_marks: Array[bool] = [false, false, false, false]
var objective_done: Array[bool] = [false, false, false]
var preparation_complete := false
var card_open := false
var archived := false
var keep_cleaning_chosen := false
var completion_snapshot: Dictionary = {}
var archive_snapshot: Dictionary = {}
var additional_tool_actions_after_completion := 0
var refresh_count := 0
var last_refresh_usec := 0
var _completion_usec := 0
var _archive_usec := 0
var _pending := false
var _current: Dictionary = {}

func _init(source: WorkingSurface) -> void:
	surface = source
	surface.fossil.bone_component_exposure_changed.connect(_on_exposure)
	surface.fossil.bone_condition_changed.connect(_on_condition)
	surface.fossil.bone_first_contact.connect(_on_discovery)
	surface.bone_film.cleaned.connect(invalidate)
	surface.fragments.changed.connect(invalidate)
	surface.fragments.fragment_ready.connect(_on_ready)
	surface.fragments.fragment_detected.connect(_on_fragment_detected)
	surface.fragments.fragment_recovered.connect(_on_recovered)
	surface.tool_applied.connect(record_tool_action)
	surface.surface_reset.connect(reset)
	reset()

func _on_exposure(_component: int, _exposed: int, _total: int) -> void:
	invalidate()

func _on_condition(_condition: float, _damage: float) -> void:
	invalidate()

func _on_discovery(_cell: Vector2i, _component: int) -> void:
	notice.emit("Bone detected — delicate material underneath")

func _on_ready(id: int) -> void:
	notice.emit("%s — Ready to recover with [5] Forceps" % RecoverableFragmentField.NAMES[id])

func _on_fragment_detected(id: int) -> void:
	notice.emit("Loose fragment detected — %s · clear its edges, then [5] Forceps" % RecoverableFragmentField.NAMES[id])

func _on_recovered(_id: int, count: int) -> void:
	notice.emit("Fragment recovered — %d/2" % count)

func invalidate() -> void:
	if _pending: return
	_pending = true
	flush.call_deferred()

func flush() -> void:
	if not _pending: return
	_pending = false
	var started := Time.get_ticks_usec()
	var fossil := surface.fossil
	var exposures: Array[float] = []
	component_states.clear()
	for id in range(1, 5):
		exposures.append(fossil.exposure_percent(id))
		component_states.append(PreparationRules.component_state(exposures.back(), surface.bone_film.cleanliness_percent(id)))
		if not quality_marks[id - 1] and PreparationRules.fine_preparation(exposures.back(), surface.bone_film.cleanliness_percent(id)):
			quality_marks[id - 1] = true
			component_polished.emit(id)
			notice.emit("%s beautifully prepared ★ — optional quality mark" % ["", "Skull", "Spine", "Ribs", "Hind Limb"][id])
	var stage := PreparationRules.classification(classification_stage, fossil.exposure_percent(), exposures)
	if stage != classification_stage:
		classification_stage = stage
		notice.emit("Classification updated — " + PreparationRules.CLASSIFICATIONS[stage])
	var achieved := PreparationRules.objectives(exposures[0], surface.bone_film.cleanliness_percent(1),
		fossil.exposure_percent(), surface.fragments.recovered_count())
	for i in range(3):
		if achieved[i] and not objective_done[i]:
			objective_done[i] = true
			notice.emit("Objective completed — " + PreparationRules.OBJECTIVES[i])
	_current = snapshot()
	if not preparation_complete and not objective_done.has(false):
		preparation_complete = true
		card_open = true
		_completion_usec = Time.get_ticks_usec()
		completion_snapshot = _current.duplicate(true)
		completed.emit(completion_snapshot.duplicate(true))
	refresh_count += 1
	last_refresh_usec = Time.get_ticks_usec() - started
	changed.emit()

func snapshot() -> Dictionary:
	return {"classification": PreparationRules.CLASSIFICATIONS[classification_stage],
		"exposure": surface.fossil.exposure_percent(), "cleanliness": surface.bone_film.cleanliness_percent(),
		"condition": surface.fossil.condition, "fragments": surface.fragments.recovered_count(),
		"quality_marks": quality_marks.duplicate(), "quality_count": quality_marks.count(true)}

func can_use_tools() -> bool:
	return not card_open and not archived

func keep_cleaning() -> bool:
	if not preparation_complete or archived or not card_open: return false
	card_open = false
	keep_cleaning_chosen = true
	changed.emit()
	return true

func archive() -> bool:
	flush()
	if not preparation_complete or archived: return false
	archive_snapshot = snapshot()
	_archive_usec = Time.get_ticks_usec()
	archived = true
	card_open = false
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
		"additional_tool_actions_after_completion": additional_tool_actions_after_completion}

func reset() -> void:
	_pending = false
	classification_stage = 0
	objective_done = [false, false, false]
	component_states = ["Hidden", "Hidden", "Hidden", "Hidden"]
	quality_marks = [false, false, false, false]
	preparation_complete = false
	card_open = false
	archived = false
	keep_cleaning_chosen = false
	completion_snapshot.clear()
	archive_snapshot.clear()
	_completion_usec = 0
	_archive_usec = 0
	additional_tool_actions_after_completion = 0
	refresh_count = 0
	last_refresh_usec = 0
	_current = snapshot()
	changed.emit()
