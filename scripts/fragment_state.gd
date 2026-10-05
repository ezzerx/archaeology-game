class_name FragmentState
extends RefCounted
## Only local, dirty-rectangle checks; no map scan or update at idle.
signal changed
signal fragment_ready(id: int)
signal fragment_detected(id: int)
signal fragment_recovered(id: int, count: int)
signal cell_exposed(cell: Vector2i, component: int)

var field: RecoverableFragmentField
var exposure: Array[float] = [0.0, 0.0]
var ready: Array[bool] = [false, false]
var recovered: Array[bool] = [false, false]
var clearance: Array[bool] = [false, false]
var detected: Array[bool] = [false, false]
var grabbed := -1
var checks := 0
var last_inspected_cells := 0
var _seen := {}

func _init(authored: RecoverableFragmentField) -> void:
	field = authored

func reset() -> void:
	exposure = [0.0, 0.0]
	ready = [false, false]
	recovered = [false, false]
	clearance = [false, false]
	detected = [false, false]
	grabbed = -1
	_seen.clear()
	checks = 0
	last_inspected_cells = 0
	changed.emit()

func recovered_count() -> int:
	return int(recovered[0]) + int(recovered[1])

func update_region(heights: PackedFloat32Array, region: Rect2i) -> void:
	last_inspected_cells = 0
	var did_change := false
	for id in range(field.COUNT):
		if recovered[id] or not field.bounds[id].intersects(region): continue
		checks += 1
		var count := 0
		for index in field.cells[id]:
			last_inspected_cells += 1
			if heights[index] <= field.ceilings[index] + FossilField.EXPOSURE_EPSILON:
				count += 1
				if not _seen.has(index):
					_seen[index] = true
					@warning_ignore("integer_division")
					cell_exposed.emit(Vector2i(index % field.size.x, index / field.size.x), 0)
		var percent := 100.0 * count / maxi(1, field.cells[id].size())
		var clear := true
		for index in field.collars[id]:
			last_inspected_cells += 1
			if heights[index] > field.clearance_heights[id] + FossilField.EXPOSURE_EPSILON:
				clear = false
				break
		var is_ready := percent >= PreparationRules.FRAGMENT_EXPOSURE and clear
		did_change = did_change or exposure[id] != percent or clearance[id] != clear or ready[id] != is_ready
		exposure[id] = percent
		if not detected[id] and percent >= PreparationRules.FRAGMENT_DETECTED:
			detected[id] = true
			fragment_detected.emit(id)
		clearance[id] = clear
		var just_ready := is_ready and not ready[id]
		ready[id] = is_ready
		if just_ready: fragment_ready.emit(id)
	if did_change: changed.emit()

func target_at(index: int) -> int:
	if index < 0 or index >= field.ids.size(): return -1
	var id := int(field.ids[index]) - 1
	# No target leaks through unexcavated matrix.
	return id if id >= 0 and not recovered[id] and grabbed != id and _seen.has(index) else -1

func grab(id: int) -> bool:
	if grabbed >= 0 or id < 0 or id >= field.COUNT or not ready[id] or recovered[id]: return false
	grabbed = id
	changed.emit()
	return true

func release(over_tray: bool) -> bool:
	if grabbed < 0: return false
	var id := grabbed
	grabbed = -1
	if over_tray:
		recovered[id] = true
		fragment_recovered.emit(id, recovered_count())
	changed.emit()
	return over_tray
