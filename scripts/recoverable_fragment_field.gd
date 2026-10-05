class_name RecoverableFragmentField
extends RefCounted
## Authored capsules, separate from FossilField and its four anatomical totals.
## The complete 4-texel clearance collar must be <= the lowest fragment ceiling.
const COUNT := 2
const NAMES := ["Fragment A", "Fragment B"]
# Beside the lower jaw and pelvis: encountered while following the specimen.
const ENDS := [Vector4(264, 295, 286, 297), Vector4(642, 342, 664, 348)]
const RADIUS := 6.0
const COLLAR := 4.0

var size: Vector2i
var ids := PackedByteArray() # 0 = none, 1/2 = recoverable, never anatomy IDs.
var ceilings := PackedFloat32Array()
var cells: Array[PackedInt32Array] = []
var collars: Array[PackedInt32Array] = []
var bounds: Array[Rect2i] = []
var clearance_heights := PackedFloat32Array()
var centers: Array[Vector2] = []

func _init(resolution := Vector2i(1024, 640)) -> void:
	size = resolution
	ids.resize(size.x * size.y)
	ceilings.resize(ids.size())
	var scale := Vector2(size) / FossilField.AUTHOR_SIZE
	for id in range(COUNT):
		var ends: Vector4 = ENDS[id]
		var a := Vector2(ends.x, ends.y)
		var b := Vector2(ends.z, ends.w)
		centers.append((a + b) * 0.5 * scale - Vector2.ONE * 0.5)
		var low := Vector2i(((a.min(b) - Vector2.ONE * (RADIUS + COLLAR)) * scale).floor()).max(Vector2i.ZERO)
		var high := Vector2i(((a.max(b) + Vector2.ONE * (RADIUS + COLLAR)) * scale).ceil()).min(size - Vector2i.ONE)
		bounds.append(Rect2i(low, high - low + Vector2i.ONE))
		var body := PackedInt32Array()
		var collar := PackedInt32Array()
		var lowest := 1.0
		for y in range(low.y, high.y + 1):
			for x in range(low.x, high.x + 1):
				var p := (Vector2(x, y) + Vector2.ONE * 0.5) / scale
				var distance := p.distance_to(Geometry2D.get_closest_point_to_segment(p, a, b))
				var index := y * size.x + x
				if distance < RADIUS:
					ids[index] = id + 1
					# Shallower than the main specimen; an authored, reachable side find.
					ceilings[index] = 0.42 + 0.05 * sqrt(1.0 - pow(distance / RADIUS, 2))
					lowest = minf(lowest, ceilings[index])
					body.append(index)
				elif distance <= RADIUS + COLLAR:
					collar.append(index)
		cells.append(body)
		collars.append(collar)
		clearance_heights.append(lowest)

func outline(id: int) -> PackedVector2Array:
	var ends: Vector4 = ENDS[id]
	var a := Vector2(ends.x, ends.y)
	var b := Vector2(ends.z, ends.w)
	var angle := (b - a).angle()
	var points := PackedVector2Array()
	for i in range(9):
		points.append(b + Vector2.from_angle(angle - PI / 2 + i * PI / 8) * RADIUS)
	for i in range(9):
		points.append(a + Vector2.from_angle(angle + PI / 2 + i * PI / 8) * RADIUS)
	return points
