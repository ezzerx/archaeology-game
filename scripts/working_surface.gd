class_name WorkingSurface
extends RefCounted
## Normalized surface height: 1 = intact top; 0 = non-excavatable floor.
## Optional strata: omitted by the P0 kernel tests to isolate footprint behaviour.

var image: Image
var size: Vector2i
var dirty := true
var strata: Stratigraphy
var _heights := PackedFloat32Array()

func _init(resolution := Vector2i(1024, 640), stratigraphy: Stratigraphy = null) -> void:
	assert(resolution.x > 0 and resolution.y > 0)
	size = resolution
	strata = stratigraphy
	image = Image.create(size.x, size.y, false, Image.FORMAT_RF)
	reset()

func reset() -> void:
	_heights.resize(size.x * size.y)
	_heights.fill(1.0)
	image.fill(Color(1.0, 0.0, 0.0, 1.0))
	dirty = true

func value_at(cell: Vector2i) -> float:
	return image.get_pixelv(cell.clamp(Vector2i.ZERO, size - Vector2i.ONE)).r

static func weight(distance_ratio: float, falloff: float) -> float:
	var t := clampf(distance_ratio, 0.0, 1.0)
	var smooth_weight := 1.0 - t * t * (3.0 - 2.0 * t)
	return pow(smooth_weight, maxf(falloff, 0.01))

func apply_segment(from: Vector2, to: Vector2, radius: float, strength: float,
		falloff: float, delta: float) -> int:
	if radius <= 0.0 or strength <= 0.0 or delta <= 0.0:
		return 0
	# Sweep a capsule: the entire segment is covered, including fast movements.
	# Each texel is modified at most once per tick, independent of sample overlap.
	var low := Vector2i((from.min(to) - Vector2.ONE * radius).floor()).max(Vector2i.ZERO)
	var high := Vector2i((from.max(to) + Vector2.ONE * radius).ceil()).min(size - Vector2i.ONE)
	var segment := to - from
	var length_squared := segment.length_squared()
	var radius_squared := radius * radius
	var strip_half_width := radius * sqrt(length_squared) / absf(segment.y) if absf(segment.y) > 0.0001 else 0.0
	var inverse_length := 1.0 / length_squared if length_squared > 0.0 else 0.0
	var inverse_radius := 1.0 / radius
	var base_work := strength * delta
	var exponent := maxf(falloff, 0.01)
	var resistance := Vector3.ONE
	var limits := PackedFloat32Array()
	if strata != null:
		resistance = Vector3(strata.materials[0].resistance, strata.materials[1].resistance, strata.materials[2].resistance)
		limits = strata.packed_limits
	var changed := 0
	for y in range(low.y, high.y + 1):
		var row_low := low.x
		var row_high := high.x
		if strip_half_width > 0.0:
			# Intersect the bounding box with the infinite capsule strip per row.
			# This avoids scanning most of the map during long diagonal sweeps.
			var line_x := from.x + (y - from.y) * segment.x / segment.y
			row_low = maxi(row_low, ceili(line_x - strip_half_width))
			row_high = mini(row_high, floori(line_x + strip_half_width))
		for x in range(row_low, row_high + 1):
			var index := y * size.x + x
			var old_value := _heights[index]
			if old_value <= 0.0:
				continue
			var dx := x - from.x
			var dy := y - from.y
			var t := clampf((dx * segment.x + dy * segment.y) * inverse_length, 0.0, 1.0)
			dx -= segment.x * t
			dy -= segment.y * t
			var distance_squared := dx * dx + dy * dy
			if distance_squared >= radius_squared:
				continue
			var ratio := sqrt(distance_squared) * inverse_radius
			var work := base_work * pow(maxf(0.0, 1.0 - ratio * ratio * (3.0 - 2.0 * ratio)), exponent)
			var next_value := old_value
			if strata == null:
				next_value = maxf(0.0, old_value - work)
			else:
				# Inline the same piecewise work integration as Stratigraphy.remove_work.
				# Packed reads avoid per-texel Image calls and Resource dispatch.
				var upper := limits[index * 2]
				var lower := limits[index * 2 + 1]
				if next_value > upper:
					var removed := minf(next_value - upper, work / resistance.x)
					next_value -= removed
					work -= removed * resistance.x
				if work > 0.0 and next_value > lower:
					var removed := minf(next_value - lower, work / resistance.y)
					next_value -= removed
					work -= removed * resistance.y
				next_value = maxf(0.0, next_value - maxf(work, 0.0) / resistance.z)
			if next_value < old_value:
				_heights[index] = next_value
				changed += 1
	if changed > 0:
		# Image is the synchronized RF staging buffer, also used by CPU picking.
		image.set_data(size.x, size.y, false, Image.FORMAT_RF, _heights.to_byte_array())
	dirty = dirty or changed > 0
	return changed
