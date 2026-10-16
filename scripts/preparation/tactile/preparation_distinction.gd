extends RefCounted
## A lightweight archive record, ready for future collection UI. No museum/meta loop.
signal changed
var session: PreparationSession
var earned := false
var earned_snapshot: Dictionary = {}
var records: Dictionary = {}
var storage_path := "user://preparation_distinctions.json"
var save_error := OK

func setup(state: PreparationSession, path := "user://preparation_distinctions.json") -> void:
	session = state
	storage_path = path
	if FileAccess.file_exists(storage_path):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(storage_path))
		if parsed is Dictionary and parsed.get("records") is Dictionary:
			records = parsed.records
	session.changed.connect(observe)
	session.archive_created.connect(on_archive)
	session.surface.surface_reset.connect(reset)
	observe()

static func qualifies(values: Dictionary) -> bool:
	return values.exposure >= 99.0 and values.cleanliness >= 99.0 and values.coverage_passed

func observe() -> void:
	if earned or session.archived: return
	var values := session.snapshot()
	if qualifies(values):
		earned = true
		earned_snapshot = values.duplicate(true)
		session.notice.emit("Préparation intégrale · 100 / 100")
		changed.emit()

func on_archive(_values: Dictionary) -> void:
	observe()
	session.archive_snapshot["integral_preparation"] = earned
	if not earned: return
	records[session.surface.fossil.field.specimen_name()] = {"integral_preparation":true, "achievement":earned_snapshot.duplicate(true)}
	var file := FileAccess.open(storage_path,FileAccess.WRITE)
	if file == null:
		save_error = FileAccess.get_open_error()
		push_warning("Preparation distinction could not be saved: " + error_string(save_error))
	else:
		file.store_string(JSON.stringify({"version":1,"records":records},"\t"))
		save_error = file.get_error()
	changed.emit()

func has_collection_distinction() -> bool:
	return records.get(session.surface.fossil.field.specimen_name(),{}).get("integral_preparation",false)

func reset() -> void:
	earned = false
	earned_snapshot.clear()
	changed.emit()
