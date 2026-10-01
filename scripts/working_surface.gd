class_name WorkingSurface
extends RefCounted
## A temporary scalar mask, NOT material depth. 1 = initial, 0 = fully marked.

var image: Image
var size: Vector2i
var dirty := true

func _init(resolution := Vector2i(1024, 640)) -> void:
	assert(resolution.x > 0 and resolution.y > 0)
	size = resolution
	image = Image.create(size.x, size.y, false, Image.FORMAT_RF)
	reset()

func reset() -> void:
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
			var offset := Vector2(x, y) - from
			var t := clampf(offset.dot(segment) / length_squared, 0.0, 1.0) if length_squared > 0.0 else 0.0
			var distance_squared := (offset - segment * t).length_squared()
			if distance_squared >= radius_squared:
				continue
			var old_value := image.get_pixel(x, y).r
			var amount := strength * delta * weight(sqrt(distance_squared) / radius, falloff)
			var next_value := maxf(0.0, old_value - amount)
			if next_value < old_value:
				image.set_pixel(x, y, Color(next_value, 0.0, 0.0, 1.0))
				changed += 1
	dirty = dirty or changed > 0
	return changed
