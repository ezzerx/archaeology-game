class_name LooseDebris
extends RefCounted
## Secondary dirt only: sparse 8x8 bins by source material, never structural.
## Amount is normalized visual accumulation, not a physical mass measurement.
signal ejected(point: Vector2, direction: Vector2, amount: float, layer: int)
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

func _init(resolution: Vector2i, settings: DebrisProfile = preload("res://config/debris_profile.tres")) -> void:
	height_size = resolution
	profile = settings

func reset() -> void:
	for key in cells: dirty_cells[key] = true
	cells.clear()
	occupancy.clear()
	flying.clear()
	_packets.clear()
	last_cleared = 0.0
	jet = Vector2(-1, -1).normalized()

func bucket_for(key: Vector3i) -> Vector2i:
	@warning_ignore("integer_division")
	return Vector2i(key.x / profile.bucket_tiles, key.y / profile.bucket_tiles)

func deposit_removed(x: int, y: int, amount: float, layer: int) -> float:
	# Return unretained depth to the caller for Fine Dust deposition at the exact
	# excavation pixel. A bucket cannot acquire more or larger persistent chunks.
	@warning_ignore("integer_division")
	var key := Vector3i(x / STRIDE, y / STRIDE, layer)
	var bucket := bucket_for(key)
	var accepted := 0.0
	if cells.has(key) or occupancy.get(bucket, 0) < profile.crumbs_per_bucket:
		accepted = minf(amount * profile.retained_fraction / (STRIDE * STRIDE),
			maxf(0.0, profile.crumb_capacity - cells.get(key, 0.0)))
		if accepted > 0:
			if not cells.has(key): occupancy[bucket] = occupancy.get(bucket, 0) + 1
			cells[key] = cells.get(key, 0.0) + accepted
	# All material crumbs in this bin settle on the newly excavated substrate.
	for material in range(3):
		var other := Vector3i(key.x, key.y, material)
		if cells.has(other): dirty_cells[other] = true
	return maxf(0.0, amount - accepted * STRIDE * STRIDE)

func point_for(key: Vector3i) -> Vector2:
	# Stable irregular placement; no frame RNG and no shared gameplay state.
	var code := absi(key.x * 73856093 ^ key.y * 19349663 ^ key.z * 83492791)
	var jitter := Vector2(float(code % 101) / 100.0, float((code / 101 as int) % 103) / 102.0)
	return ((Vector2(key.x, key.y) + Vector2.ONE * 0.15 + jitter * 0.7) * STRIDE - Vector2.ONE * 0.5).clamp(
		Vector2.ZERO, Vector2(height_size) - Vector2.ONE)

func nearby_count(point: Vector2, radius := 2.0) -> int:
	# F1 inspection only: bounded neighbours, never a scan of persistent dirt.
	var cell := Vector2i((point / STRIDE).floor())
	var count := 0
	for y in range(cell.y - 1, cell.y + 2):
		for x in range(cell.x - 1, cell.x + 2):
			for layer in range(3):
				var key := Vector3i(x, y, layer)
				if cells.has(key) and point_for(key).distance_to(point) <= radius: count += 1
	return count

func clean(from: Vector2, to: Vector2, tool: ToolDefinition, delta: float) -> void:
	last_cleared = 0.0
	if tool.residue_clear <= 0 or tool.radius <= 0 or delta <= 0: return
	var segment := to - from
	if segment.length_squared() > 0.01: jet = segment.normalized()
	var low := Vector2i(((from.min(to) - Vector2.ONE * tool.radius) / STRIDE).floor()).max(Vector2i.ZERO)
	var high := Vector2i(((from.max(to) + Vector2.ONE * tool.radius) / STRIDE).floor()).min(
		Vector2i((Vector2(height_size) / STRIDE).ceil()) - Vector2i.ONE)
	var inv_length := 1.0 / segment.length_squared() if segment.length_squared() > 0 else 0.0
	for y in range(low.y, high.y + 1):
		for x in range(low.x, high.x + 1):
			for layer in range(3):
				var key := Vector3i(x, y, layer)
				if not cells.has(key): continue
				var point := point_for(key)
				var t := clampf((point - from).dot(segment) * inv_length, 0, 1)
				var weight := WorkingSurface.weight(point.distance_to(from + segment * t) / tool.radius, tool.falloff)
				var amount := minf(cells[key], tool.residue_clear * delta * weight)
				if amount <= 0: continue
				cells[key] -= amount
				if cells[key] < 0.000001:
					amount += cells[key]
					cells.erase(key)
					var bucket := bucket_for(key)
					occupancy[bucket] -= 1
					if occupancy[bucket] == 0: occupancy.erase(bucket)
				dirty_cells[key] = true
				last_cleared += amount
				if tool.id == &"air_blower":
					# Nearby portions in the same jet share one visual packet. Cleaning
					# still accounts for every fraction; no tiny particle per physics tick.
					var packet: Dictionary = _packets.get(key, {})
					if not packet.is_empty() and packet.point.distance_to(point) < STRIDE * 2 \
							and packet.direction.dot(jet) > 0.9:
						packet.amount += amount
					else:
						packet = {"point": point, "direction": jet, "amount": amount, "layer": layer,
							"speed": tool.radius * tool.residue_clear, "travel": 0.0, "source": key}
						_packets[key] = packet
						flying.append(packet)

func advance(delta: float) -> void:
	# Only moving debris is visited. Resting dirt has no per-frame simulation.
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
			flying.remove_at(i)
