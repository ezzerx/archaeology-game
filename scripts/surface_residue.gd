class_name SurfaceResidue
extends RefCounted
## Debug-only scalar, one cell per 4x4 height texels. No geometry or physics.
## Float CPU accumulation avoids losing sub-byte edits; only R8 goes to the GPU.

const STRIDE := 4
var size: Vector2i
var height_size: Vector2i
var image: Image
var dirty := true
var last_cleared := 0.0
var _values := PackedFloat32Array()
var _bytes := PackedByteArray()

func _init(resolution: Vector2i) -> void:
	height_size = resolution
	size = Vector2i(ceili(resolution.x / float(STRIDE)), ceili(resolution.y / float(STRIDE)))
	image = Image.create(size.x, size.y, false, Image.FORMAT_R8)
	reset()

func reset() -> void:
	last_cleared = 0.0
	_values.resize(size.x * size.y)
	_values.fill(0.0)
	_bytes.resize(size.x * size.y)
	_bytes.fill(0)
	image.fill(Color(0, 0, 0, 1))
	dirty = true

func deposit_removed(x: int, y: int, amount: float) -> void:
	@warning_ignore("integer_division")
	var cell := Vector2i(x / STRIDE, y / STRIDE)
	var index := cell.y * size.x + cell.x
	# Average removed depth over the tile, including clipped edge tiles.
	var area := mini(STRIDE, height_size.x - cell.x * STRIDE) * mini(STRIDE, height_size.y - cell.y * STRIDE)
	_values[index] = minf(1.0, _values[index] + amount / area)

func value_at(uv: Vector2) -> float:
	# Same bilinear sampling convention as the debug shader, with float precision.
	var p := uv * Vector2(size) - Vector2(0.5, 0.5)
	var cell := Vector2i(p.floor())
	var blend := p - Vector2(cell)
	var a := _cell_value(cell)
	var b := _cell_value(cell + Vector2i.RIGHT)
	var c := _cell_value(cell + Vector2i.DOWN)
	var d := _cell_value(cell + Vector2i.ONE)
	return lerpf(lerpf(a, b, blend.x), lerpf(c, d, blend.x), blend.y)

func _cell_value(cell: Vector2i) -> float:
	cell = cell.clamp(Vector2i.ZERO, size - Vector2i.ONE)
	return _values[cell.y * size.x + cell.x]

func apply_segment(from: Vector2, to: Vector2, radius: float, falloff: float, clear_amount: float) -> int:
	last_cleared = 0.0
	if radius <= 0.0:
		return 0
	var low := Vector2i(((from.min(to) - Vector2.ONE * radius) / STRIDE).floor()).max(Vector2i.ZERO)
	var high := Vector2i(((from.max(to) + Vector2.ONE * radius) / STRIDE).floor()).min(size - Vector2i.ONE)
	var segment := to - from
	var inverse_length := 1.0 / segment.length_squared() if segment.length_squared() > 0.0 else 0.0
	var changed := 0
	for y in range(low.y, high.y + 1):
		for x in range(low.x, high.x + 1):
			var index := y * size.x + x
			if clear_amount > 0.0 and _values[index] > 0.0:
				var point := (Vector2(x, y) + Vector2(0.5, 0.5)) * STRIDE - Vector2(0.5, 0.5)
				var t := clampf((point - from).dot(segment) * inverse_length, 0.0, 1.0)
				var weight := WorkingSurface.weight(point.distance_to(from + segment * t) / radius, falloff)
				var before := _values[index]
				_values[index] = maxf(0.0, before - clear_amount * weight)
				last_cleared += before - _values[index]
			var encoded := roundi(_values[index] * 255.0)
			if encoded != _bytes[index]:
				_bytes[index] = encoded
				changed += 1
	if changed > 0:
		image.set_data(size.x, size.y, false, Image.FORMAT_R8, _bytes)
		dirty = true
	return changed
