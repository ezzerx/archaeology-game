class_name FossilField
extends RefCounted
## One authored B-17, rasterized once. No random seed or content generation.
## Coordinates below are authoring coordinates on the canonical 1024 x 640 map.

enum Component { NONE, SKULL, SPINE, RIBS, HIND_LIMB }
const COMPONENT_NAMES := ["—", "Skull", "Spine / Vertebrae", "Ribs", "Hind Limb"]
const SPECIMEN_NAME := "Specimen B-17"
const EXPOSURE_EPSILON := 1.0 / 65536.0 # Binary-exact in both CPU and shader float32.
const AUTHOR_SIZE := Vector2(1024, 640)

var size: Vector2i
var ceilings := PackedFloat32Array()
var component_ids := PackedByteArray()
var component_totals := PackedInt32Array([0, 0, 0, 0, 0])
var total_cells := 0
var highest_ceiling := 0.0
var image: Image # Static RGF: ceiling, integer component ID (0 also means no bone).

func _init(resolution := Vector2i(1024, 640)) -> void:
	assert(resolution.x > 0 and resolution.y > 0)
	size = resolution
	ceilings.resize(size.x * size.y)
	component_ids.resize(size.x * size.y)
	_author_b17()
	image = Image.create(size.x, size.y, false, Image.FORMAT_RGF)
	for index in range(component_ids.size()):
		var component := component_ids[index]
		if component == Component.NONE:
			continue
		# Resolve overlaps in the original authoring space first. Translating the
		# winner is equivalent to adding the same offset to every candidate, and
		# keeps ownership exact even if a safety clamp would tie two candidates.
		var uv := (Vector2(index % size.x, index / size.x) + Vector2.ONE * 0.5) / Vector2(size)
		ceilings[index] = BlockVerticalityProfile.buried_ceiling(ceilings[index], uv)
		component_totals[component] += 1
		total_cells += 1
		highest_ceiling = maxf(highest_ceiling, ceilings[index])
		image.set_pixel(index % size.x, index / size.x, Color(ceilings[index], component, 0, 1))

func index_at_map(point: Vector2) -> int:
	if not point.is_finite() or point.x < -0.5 or point.y < -0.5 or point.x > size.x - 0.5 or point.y > size.y - 0.5:
		return -1
	var cell := Vector2i((point + Vector2.ONE * 0.5).floor()).clamp(Vector2i.ZERO, size - Vector2i.ONE)
	return cell.y * size.x + cell.x

func _author_b17() -> void:
	# Skull: an open eye socket, tapered snout, separate lower jaw and small teeth.
	_path(Component.SKULL, [Vector2(317, 231), Vector2(306, 207), Vector2(280, 193),
		Vector2(252, 199), Vector2(235, 216), Vector2(182, 227), Vector2(188, 240),
		Vector2(244, 239), Vector2(267, 247), Vector2(296, 245), Vector2(317, 231)], 9, 0.29, 0.065)
	_bone(Component.SKULL, Vector2(239, 217), Vector2(262, 238), 8, 0.28, 0.065)
	_path(Component.SKULL, [Vector2(192, 260), Vector2(259, 271), Vector2(291, 265), Vector2(312, 250)], 7, 0.26, 0.05)
	for x in [201, 217, 233]:
		_bone(Component.SKULL, Vector2(x, 240), Vector2(x + 2, 248), 3, 0.27, 0.035)
	# Separate vertebrae and short processes; the articulated chain curves into a tail.
	var spine := [Vector2(329, 251), Vector2(349, 266), Vector2(371, 282),
		Vector2(396, 293), Vector2(423, 300), Vector2(451, 305), Vector2(480, 307),
		Vector2(510, 307), Vector2(540, 309), Vector2(570, 311), Vector2(600, 311),
		Vector2(629, 307), Vector2(657, 298), Vector2(682, 286), Vector2(706, 271),
		Vector2(730, 255), Vector2(754, 241), Vector2(777, 232), Vector2(799, 228), Vector2(819, 229)]
	for i in range(spine.size()):
		var p: Vector2 = spine[i]
		var radius := 9.5 if i < 11 else lerpf(8.5, 3.0, (i - 11) / 8.0)
		_bone(Component.SPINE, p - Vector2(3, 0), p + Vector2(3, 0), radius, 0.275, 0.075)
		if i >= 2 and i <= 12:
			_bone(Component.SPINE, p - Vector2(0, 17), p + Vector2(1, 16), 3.5, 0.265, 0.04)
	# A partial rib cage, with gaps rather than a filled oval.
	for i in range(6):
		var x := 394.0 + i * 28.0
		var length := 57.0 + sin(i / 5.0 * PI) * 33.0
		_path(Component.RIBS, [Vector2(x, 314), Vector2(x - 10, 340),
			Vector2(x - 11, 340 + length * 0.55), Vector2(x + 3, 340 + length),
			Vector2(x + 21, 351 + length)], 4.3, 0.235, 0.06)
		_path(Component.RIBS, [Vector2(x, 290), Vector2(x - 6, 265),
			Vector2(x + 1, 243 - length * 0.25), Vector2(x + 17, 232 - length * 0.25)], 4.0, 0.25, 0.055)
	# Pelvis, one folded hind limb, a thin parallel lower-leg bone and three toes.
	_bone(Component.HIND_LIMB, Vector2(568, 335), Vector2(618, 336), 11, 0.27, 0.085)
	_bone(Component.HIND_LIMB, Vector2(601, 353), Vector2(662, 410), 9, 0.26, 0.08)
	_bone(Component.HIND_LIMB, Vector2(660, 427), Vector2(593, 494), 7, 0.25, 0.065)
	_bone(Component.HIND_LIMB, Vector2(672, 430), Vector2(612, 493), 3, 0.25, 0.045)
	_path(Component.HIND_LIMB, [Vector2(595, 508), Vector2(633, 516), Vector2(674, 510)], 4.8, 0.255, 0.045)
	_bone(Component.HIND_LIMB, Vector2(633, 516), Vector2(674, 530), 3.5, 0.25, 0.04)
	_bone(Component.HIND_LIMB, Vector2(627, 517), Vector2(657, 545), 3, 0.25, 0.04)

func _path(component: int, points: Array, radius: float, base: float, dome: float) -> void:
	for i in range(points.size() - 1):
		_bone(component, points[i], points[i + 1], radius, base, dome)

func _bone(component: int, a: Vector2, b: Vector2, radius: float, base: float, dome: float) -> void:
	var scale := Vector2(size) / AUTHOR_SIZE
	var low := Vector2i(((a.min(b) - Vector2.ONE * radius) * scale).floor()).max(Vector2i.ZERO)
	var high := Vector2i(((a.max(b) + Vector2.ONE * radius) * scale).ceil()).min(size - Vector2i.ONE)
	for y in range(low.y, high.y + 1):
		for x in range(low.x, high.x + 1):
			var p := (Vector2(x, y) + Vector2.ONE * 0.5) / scale
			var nearest := Geometry2D.get_closest_point_to_segment(p, a, b)
			var ratio_squared := p.distance_squared_to(nearest) / (radius * radius)
			if ratio_squared >= 1.0:
				continue
			var index := y * size.x + x
			var ceiling := base + dome * sqrt(1.0 - ratio_squared)
			# In an overlap, the upper surface owns the cell and its component.
			if ceiling > ceilings[index]:
				ceilings[index] = ceiling
				component_ids[index] = component
