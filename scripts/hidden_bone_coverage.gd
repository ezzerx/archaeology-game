class_name HiddenBoneCoverage
extends RefCounted
## Exact 8-connected hidden main-Bone regions. No fragment/terrain authority.
var field: FossilField
var hidden := PackedInt32Array()
var _all := PackedInt32Array()
var _positions := PackedInt32Array()
var _visited := PackedByteArray()
var _queue := PackedInt32Array()

func _init(source: FossilState) -> void:
	field = source.field
	for index in range(field.component_ids.size()):
		if field.component_ids[index] != 0: _all.append(index)
	_positions.resize(field.component_ids.size())
	_visited.resize(field.component_ids.size())
	_queue.resize(_all.size())
	reset()
	for index in _all:
		if source.exposed[index] != 0: _remove(index)
	source.bone_cell_exposed.connect(_on_exposed)
	source.specimen_reset.connect(reset)

func reset() -> void:
	hidden = _all.duplicate()
	_positions.fill(-1)
	for i in range(hidden.size()): _positions[hidden[i]] = i

func _on_exposed(cell: Vector2i, _component: int) -> void:
	_remove(cell.y * field.size.x + cell.x)

func _remove(index: int) -> void:
	var position := _positions[index]
	if position < 0: return
	var last := hidden[-1]
	hidden[position] = last
	_positions[last] = position
	hidden.resize(hidden.size() - 1)
	_positions[index] = -1

func largest_cluster() -> int:
	_visited.fill(0)
	var largest := 0
	var width := field.size.x
	for seed in hidden:
		if _visited[seed] != 0: continue
		_visited[seed] = 1
		_queue[0] = seed
		var head := 0
		var tail := 1
		while head < tail:
			var index := _queue[head]
			head += 1
			@warning_ignore("integer_division")
			var y := index / width
			var x := index % width
			for ny in range(maxi(0, y - 1), mini(field.size.y, y + 2)):
				for nx in range(maxi(0, x - 1), mini(width, x + 2)):
					var next := ny * width + nx
					if _positions[next] < 0 or _visited[next] != 0: continue
					_visited[next] = 1
					_queue[tail] = next
					tail += 1
		largest = maxi(largest, tail)
	return largest
