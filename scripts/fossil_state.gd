class_name FossilState
extends RefCounted
## Structural state only. No residue, UI, classification or objective dependency.

signal bone_first_contact(cell: Vector2i, component: int)
signal bone_cell_exposed(cell: Vector2i, component: int)
signal bone_component_exposure_changed(component: int, exposed: int, total: int)
signal bone_condition_changed(condition: float, damage: float)
signal specimen_reset

var field: FossilField
var exposed := PackedByteArray()
var component_exposed := PackedInt32Array([0, 0, 0, 0, 0])
var exposed_cells := 0
var first_contact := false
var condition: float:
	get: return _condition
var _condition := 100.0
var last_bone_event := "—"
var last_damage_event := "—"

func _init(fossil_field: FossilField) -> void:
	field = fossil_field
	reset()

func reset() -> void:
	exposed.resize(field.size.x * field.size.y)
	exposed.fill(0)
	component_exposed.fill(0)
	exposed_cells = 0
	first_contact = false
	_condition = 100.0
	last_bone_event = "—"
	last_damage_event = "—"
	specimen_reset.emit()

func exposure_percent(component := 0) -> float:
	var count := exposed_cells if component == 0 else component_exposed[component]
	var total := field.total_cells if component == 0 else field.component_totals[component]
	return 100.0 * count / total if total > 0 else 0.0

func expose_cells(indices: PackedInt32Array) -> void:
	# Called after the RF image is synchronized. Observers see a committed surface.
	var newly_exposed := PackedInt32Array()
	var changed_components := PackedByteArray([0, 0, 0, 0, 0])
	for index in indices:
		if exposed[index] != 0 or field.component_ids[index] == 0:
			continue
		exposed[index] = 1
		var component := field.component_ids[index]
		component_exposed[component] += 1
		exposed_cells += 1
		changed_components[component] = 1
		newly_exposed.append(index)
	if newly_exposed.is_empty():
		return
	if not first_contact:
		first_contact = true
		var first := newly_exposed[0]
		last_bone_event = "Bone detected"
		bone_first_contact.emit(Vector2i(first % field.size.x, first / field.size.x), field.component_ids[first])
	for index in newly_exposed:
		bone_cell_exposed.emit(Vector2i(index % field.size.x, index / field.size.x), field.component_ids[index])
	for component in range(1, changed_components.size()):
		if changed_components[component] != 0:
			bone_component_exposure_changed.emit(component, component_exposed[component], field.component_totals[component])

func damage_at(index: int, amount: float) -> void:
	if index < 0 or index >= exposed.size() or exposed[index] == 0 or amount <= 0.0:
		return
	var before := _condition
	_condition = clampf(_condition - amount, 0.0, 100.0)
	if _condition < before:
		last_damage_event = "Chisel / %s / -%.0f" % [FossilField.COMPONENT_NAMES[field.component_ids[index]], before - _condition]
		bone_condition_changed.emit(_condition, before - _condition)
