class_name LooseDebris
extends RefCounted
## Secondary dirt only. Spawn keys own amount/budget, physical XYZ owns position.
## Amount is normalized visual accumulation, not a physical mass measurement.
signal ejected(point: Vector2, direction: Vector2, amount: float, layer: int)
signal physical_ejected(position_local: Vector3, direction_local: Vector3, amount: float, layer: int)
const STRIDE := 8
var height_size: Vector2i
var profile: DebrisProfile
var cells: Dictionary = {}
var occupancy: Dictionary = {}
var dirty_cells: Dictionary = {}
var flying: Array[Dictionary] = []
var _packets: Dictionary = {}
var last_cleared := 0.0
var jet := Vector2(-1, -1).normalized()
var physics: TerrainDebris
var physical_slots: Dictionary = {}
var _rest_points: Dictionary = {} # Preserve current positions when F3 turns OFF.
var _size_dirty: Dictionary = {}
var last_blown := 0
var samples_pending := 0
var samples_last_frame := 0
var refused_count := 0
var layer_counts := PackedInt32Array([0, 0, 0]) # Resting + flying, O(1) spawn admission.
var created_counts := PackedInt32Array([0, 0, 0])
var cap_refusals := PackedInt32Array([0, 0, 0]) # Deposition attempts, not physical grains.
var local_refusals := PackedInt32Array([0, 0, 0])
var _deposit_batch := false
var _deposit_bin := Vector2i(-1, -1)

func begin_deposition() -> void:
	_deposit_batch = true
	_deposit_bin = Vector2i(-1, -1)

func end_deposition() -> void:
	_deposit_batch = false

var physics_enabled := true:
	set(value):
		if physics_enabled == value: return
		physics_enabled = value
		if physics == null: return
		if value:
			for key: Vector3i in cells:
				if key.z > 0: _spawn_physical(key, false)
		else:
			for key: Vector3i in physical_slots:
				_rest_points[key] = _map_point(physics.fragments[physical_slots[key]].position)
			physical_slots.clear()
			physics.reset()
		for key in cells: dirty_cells[key] = true
		samples_pending = 0
		samples_last_frame = 0

func _init(resolution: Vector2i, settings: DebrisProfile = preload("res://config/debris_profile.tres")) -> void:
	height_size = resolution
	profile = settings

func setup_physics(terrain: ReliefSurface) -> void:
	assert(physics == null)
	physics = TerrainDebris.new(terrain, preload("res://config/debris_physics_profile.tres"), profile.matrix_crumb_cap)
	physics.debris_ejected.connect(_on_physical_exit)
	if physics_enabled:
		for key: Vector3i in cells:
			if key.z > 0: _spawn_physical(key, false)

func persistent_count() -> int:
	return cells.size() + flying.size()

func count_for(layer: int) -> int:
	return 0 if layer == 0 else layer_counts[1] + layer_counts[2]

func cap_for(layer: int) -> int:
	return 0 if layer == 0 else profile.matrix_crumb_cap

func visual_width(_point: Vector2, amount: float, _layer: int) -> float:
	return profile.matrix_crumb_width * clampf(sqrt(amount / profile.crumb_capacity), 0.08, 1.0)

func moving_count() -> int:
	return flying.size() + (physics.active_count - physics.sleeping_count if physics != null else 0)

func size_for(key: Vector3i) -> Vector3:
	var width := visual_width(_spawn_point(key), cells[key], key.z)
	return Vector3(width, width * 0.32, width * 0.75)

func _map_point(at: Vector3) -> Vector2:
	return SurfaceMapping.local_to_uv(at, physics.relief.dimensions) * Vector2(height_size) - Vector2.ONE * 0.5

func _spawn_physical(key: Vector3i, hop := true) -> void:
	var point := point_for(key)
	var uv := (point + Vector2.ONE * 0.5) / Vector2(height_size)
	var shape := size_for(key)
	var at := Vector3((uv.x - 0.5) * physics.relief.dimensions.x,
		physics.relief.height_at(uv) + shape.length() * 0.5 + physics.profile.contact_skin,
		(uv.y - 0.5) * physics.relief.dimensions.y)
	# Stable independent motion; never consume the Chisel/audio/gameplay RNG.
	var rotation := point.x * 1.7 + point.y * 2.3
	var velocity := Vector3(cos(rotation), 0, sin(rotation)) * physics.profile.spawn_lateral_speed \
		+ Vector3.UP * physics.profile.spawn_lift if hop else Vector3.ZERO
	var slot := physics.spawn(at, velocity, shape, key.z, rotation, key)
	assert(slot >= 0, "Matrix spawn budget reserves a physical slot")
	physical_slots[key] = slot
	_rest_points.erase(key)

func _erase_cell(key: Vector3i) -> void:
	if physical_slots.has(key):
		physics.remove(physical_slots[key])
		physical_slots.erase(key)
	layer_counts[key.z] -= 1
	cells.erase(key)
	_rest_points.erase(key)
	_size_dirty.erase(key)
	var bucket := bucket_for(key)
	occupancy[bucket] -= 1
	if occupancy[bucket] == 0: occupancy.erase(bucket)
	dirty_cells[key] = true

func _on_physical_exit(key: Vector3i, at: Vector3, direction: Vector3) -> void:
	var amount: float = cells[key]
	_erase_cell(key) # Free persistent state and spawn budget before notifying.
	physical_ejected.emit(at, direction, amount, key.z)

func reset() -> void:
	for key in cells: dirty_cells[key] = true
	cells.clear()
	occupancy.clear()
	flying.clear()
	_packets.clear()
	last_cleared = 0.0
	jet = Vector2(-1, -1).normalized()
	physical_slots.clear()
	_rest_points.clear()
	_size_dirty.clear()
	last_blown = 0
	samples_pending = 0
	samples_last_frame = 0
	refused_count = 0
	layer_counts.fill(0)
	created_counts.fill(0)
	cap_refusals.fill(0)
	local_refusals.fill(0)
	end_deposition()
	if physics != null: physics.reset()

func bucket_for(key: Vector3i) -> Vector3i:
	@warning_ignore("integer_division")
	return Vector3i(key.x / profile.bucket_tiles, key.y / profile.bucket_tiles, key.z)

func deposit_removed(x: int, y: int, amount: float, layer: int) -> float:
	# Return unretained depth to the caller for Fine Dust deposition at the exact
	# excavation pixel. A bucket cannot acquire more or larger persistent chunks.
	if amount <= 0: return 0.0
	# Soil uses dust only; no admission bookkeeping or rendering work.
	if layer not in [1, 2]: return amount
	@warning_ignore("integer_division")
	var key := Vector3i(x / STRIDE, y / STRIDE, layer)
	var bin := Vector2i(key.x, key.y)
	# A stroke edits many pixels in the same 8x8 bin. Mark existing siblings once
	# per contiguous run, while keeping acceptance and Fine Dust exact per pixel.
	if not _deposit_batch or bin != _deposit_bin:
		for material in [1, 2]:
			var other := Vector3i(key.x, key.y, material)
			if cells.has(other): dirty_cells[other] = true
		_deposit_bin = bin
	var bucket := bucket_for(key)
	var accepted := 0.0
	var existing := cells.has(key)
	# A departed crumb must not absorb fresh matter from a distant source cell.
	var at_source := not physical_slots.has(key) or point_for(key).distance_to(_spawn_point(key)) < STRIDE
	if (existing and at_source) or (not existing and occupancy.get(bucket, 0) < profile.crumbs_per_bucket[layer - 1]
			and count_for(layer) < cap_for(layer)):
		accepted = minf(amount * profile.retained_fraction / (STRIDE * STRIDE),
			maxf(0.0, profile.crumb_capacity - cells.get(key, 0.0)))
		if accepted > 0:
			if not existing:
				occupancy[bucket] = occupancy.get(bucket, 0) + 1
				layer_counts[layer] += 1
				created_counts[layer] += 1
				dirty_cells[key] = true
			cells[key] = cells.get(key, 0.0) + accepted
			if physics_enabled and physics != null and layer > 0:
				if not existing: _spawn_physical(key)
				_size_dirty[key] = true
	if accepted == 0:
		refused_count += 1
		if not existing:
			if count_for(layer) >= cap_for(layer): cap_refusals[layer] += 1
			elif occupancy.get(bucket, 0) >= profile.crumbs_per_bucket[layer - 1]: local_refusals[layer] += 1
	return maxf(0.0, amount - accepted * STRIDE * STRIDE)

func point_for(key: Vector3i) -> Vector2:
	if physical_slots.has(key): return _map_point(physics.fragments[physical_slots[key]].position)
	return _rest_points.get(key, _spawn_point(key))

func _spawn_point(key: Vector3i) -> Vector2:
	# Stable irregular placement; no frame RNG and no shared gameplay state.
	var code := absi(key.x * 73856093 ^ key.y * 19349663 ^ key.z * 83492791)
	var jitter := Vector2(float(code % 101) / 100.0, float((code / 101 as int) % 103) / 102.0)
	return ((Vector2(key.x, key.y) + Vector2.ONE * 0.15 + jitter * 0.7) * STRIDE - Vector2.ONE * 0.5).clamp(
		Vector2.ZERO, Vector2(height_size) - Vector2.ONE)

func nearby_count(point: Vector2, radius := 2.0) -> int:
	# Bounded by the global crumb cap; spawn buckets no longer imply location.
	var count := 0
	for key: Vector3i in cells:
		if point_for(key).distance_to(point) <= radius: count += 1
	return count

func clean(from: Vector2, to: Vector2, tool: ToolDefinition, delta: float) -> void:
	last_cleared = 0.0
	last_blown = 0
	if tool.residue_clear <= 0 or tool.radius <= 0 or delta <= 0: return
	var segment := to - from
	if segment.length_squared() > 0.01: jet = segment.normalized()
	var inv_length := 1.0 / segment.length_squared() if segment.length_squared() > 0 else 0.0
	if physics_enabled and physics != null and tool.id == &"air_blower":
		last_blown = physics.blow(from, to, tool.radius, tool.falloff, delta, jet)
	# All positions are queried at their current location, including moved sleepers.
	# At most the Matrix cap; no heightfield scan or destination occupancy.
	for key: Vector3i in cells.keys():
		if tool.id == &"air_blower" and physical_slots.has(key): continue
		var point := point_for(key)
		var t := clampf((point - from).dot(segment) * inv_length, 0, 1)
		var weight := WorkingSurface.weight(point.distance_to(from + segment * t) / tool.radius, tool.falloff)
		var amount := minf(cells[key], tool.residue_clear * delta * weight)
		if amount <= 0: continue
		var packet: Dictionary = _packets.get(key, {})
		var merge_packet: bool = not packet.is_empty() and packet.point.distance_to(point) < STRIDE * 2 \
			and packet.direction.dot(jet) > 0.9
		# F3 OFF flight also obeys the total cap. A partial transfer waits for a
		# free slot instead of destroying mass or silently exceeding the budget.
		if tool.id == &"air_blower" and not merge_packet and amount < cells[key] - 0.000001 \
				and count_for(key.z) >= cap_for(key.z): continue
		cells[key] -= amount
		if cells[key] < 0.000001:
			amount += cells[key]
			_erase_cell(key)
		elif physical_slots.has(key): _size_dirty[key] = true
		dirty_cells[key] = true
		last_cleared += amount
		if tool.id == &"air_blower":
			# Historical 2D flight for F3 OFF. Quantity remains accounted until exit.
			if merge_packet: packet.amount += amount
			else:
				packet = {"point": point, "direction": jet, "amount": amount, "layer": key.z,
					"speed": tool.radius * tool.residue_clear, "travel": 0.0, "source": key}
				_packets[key] = packet
				flying.append(packet)
				layer_counts[key.z] += 1

func advance(delta: float) -> void:
	if physics != null and physics_enabled:
		for key: Vector3i in _size_dirty:
			if physical_slots.has(key): physics.fragments[physical_slots[key]].size = size_for(key)
		_size_dirty.clear()
		# Mark moving pieces before the step, including their final settling frame.
		for f in physics.fragments:
			if f.active and f.state != TerrainDebris.State.SLEEPING: dirty_cells[f.source] = true
		physics.advance(delta)
		samples_pending += physics.last_samples
		for f in physics.fragments:
			if f.active and f.state != TerrainDebris.State.SLEEPING: dirty_cells[f.source] = true
	# Legacy flying crumbs have no expiry either; they exit through the block edge.
	for i in range(flying.size() - 1, -1, -1):
		var item: Dictionary = flying[i]
		var previous: Vector2 = item.point
		item.point += item.direction * item.speed * delta
		item.travel += item.speed * delta
		if not Rect2(Vector2.ONE * -0.5, Vector2(height_size)).has_point(item.point):
			var step: Vector2 = item.point - previous
			var fraction := 1.0
			for axis in range(2):
				if step[axis] > 0: fraction = minf(fraction, (height_size[axis] - 0.5 - previous[axis]) / step[axis])
				elif step[axis] < 0: fraction = minf(fraction, (-0.5 - previous[axis]) / step[axis])
			ejected.emit(previous + step * fraction, item.direction, item.amount, item.layer)
			if _packets.get(item.source, {}) == item: _packets.erase(item.source)
			layer_counts[item.layer] -= 1
			flying.remove_at(i)
