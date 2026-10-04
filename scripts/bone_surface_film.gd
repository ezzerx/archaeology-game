class_name BoneSurfaceFilm
extends RefCounted
## Adherent dirt, independent of exposure, Fine Dust and Bone Condition.
## One RGBA8 texel per 4x4 height cells: R amount, GB 16-bit dirty-cell mask.
## Seen bits keep a cleaned cell clean when adjacent cells are first exposed.
const STRIDE := 4
const INITIAL := 0.85
var height_size: Vector2i
var size: Vector2i
var image: Image
var dirty := true
var last_cleared := 0.0
var last_edit_usec := 0
var _values := PackedFloat32Array()
var _seen := PackedInt32Array()
var _masks := PackedInt32Array()
var _bytes := PackedByteArray()
var _image_pending := false

func _init(resolution: Vector2i) -> void:
	height_size = resolution
	size = Vector2i(ceili(resolution.x / 4.0), ceili(resolution.y / 4.0))
	_values.resize(size.x * size.y)
	_seen.resize(_values.size())
	_masks.resize(_values.size())
	_bytes.resize(_values.size() * 4)
	image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	reset()

func reset() -> void:
	_values.fill(0)
	_seen.fill(0)
	_masks.fill(0)
	_bytes.fill(0)
	last_cleared = 0
	last_edit_usec = 0
	_image_pending = true
	dirty = true
	flush_image()

func _encode(index: int) -> void:
	_bytes[index * 4] = roundi(_values[index] * 255)
	_bytes[index * 4 + 1] = _masks[index] & 255
	_bytes[index * 4 + 2] = (_masks[index] >> 8) & 255
	_image_pending = true
	dirty = true

func flush_image() -> void:
	if _image_pending:
		image.set_data(size.x, size.y, false, Image.FORMAT_RGBA8, _bytes)
		_image_pending = false

@warning_ignore("integer_division")
func expose(cell: Vector2i, _component := 0) -> void:
	var index := (cell.y / STRIDE) * size.x + cell.x / STRIDE
	var bit := 1 << ((cell.y % STRIDE) * STRIDE + cell.x % STRIDE)
	if _seen[index] & bit: return
	_seen[index] |= bit
	# Never boost existing dirt during partial cleaning. A new neighbour shares
	# the tile's remaining film; an entirely clean tile starts a fresh cohort.
	if _masks[index] == 0: _values[index] = INITIAL
	_masks[index] |= bit
	_encode(index)

@warning_ignore("integer_division")
func value_at(uv: Vector2) -> float:
	var cell := Vector2i(uv * Vector2(height_size)).clamp(Vector2i.ZERO, height_size - Vector2i.ONE)
	var index := (cell.y / STRIDE) * size.x + cell.x / STRIDE
	var bit := 1 << ((cell.y % STRIDE) * STRIDE + cell.x % STRIDE)
	return _values[index] if _masks[index] & bit else 0.0

func clean(from: Vector2, to: Vector2, tool: ToolDefinition, delta: float) -> void:
	var start := Time.get_ticks_usec()
	last_cleared = 0
	last_edit_usec = 0
	if tool.id != &"soft_brush" or tool.bone_film_clear <= 0 or delta <= 0: return
	var radius := tool.radius
	var low := Vector2i(((from.min(to) - Vector2.ONE * radius) / STRIDE).floor()).max(Vector2i.ZERO)
	var high := Vector2i(((from.max(to) + Vector2.ONE * radius) / STRIDE).ceil()).min(size - Vector2i.ONE)
	var segment := to - from
	var inverse := 1.0 / segment.length_squared() if not segment.is_zero_approx() else 0.0
	for y in range(low.y, high.y + 1):
		for x in range(low.x, high.x + 1):
			var index := y * size.x + x
			if _masks[index] == 0: continue
			var point := Vector2(x, y) * STRIDE + Vector2.ONE * 1.5
			var t := clampf((point - from).dot(segment) * inverse, 0, 1)
			var amount := minf(_values[index], tool.bone_film_clear * delta * WorkingSurface.weight(point.distance_to(from + segment * t) / radius, tool.falloff))
			if amount <= 0: continue
			_values[index] -= amount
			last_cleared += amount
			if _values[index] < 0.000001:
				_values[index] = 0
				_masks[index] = 0
			_encode(index)
	last_edit_usec = Time.get_ticks_usec() - start
