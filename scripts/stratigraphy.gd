class_name Stratigraphy
extends RefCounted
## One fixed test block, not a level generator. Thresholds are immutable at runtime.

# Rendering/picking only: float32 interpolation/physical-height roundoff, 0.102 µm
# at the production block depth. Cell work and geological maps stay exact.
const SURFACE_EPSILON := 0.000001

var boundaries: Image
var materials: Array[MaterialDefinition]
var packed_limits: PackedFloat32Array

func _init(size: Vector2i, definitions: Array[MaterialDefinition]) -> void:
	assert(definitions.size() == 3)
	materials = definitions
	boundaries = Image.create(size.x, size.y, false, Image.FORMAT_RGF)
	for y in range(size.y):
		var v := (y + 0.5) / size.y
		for x in range(size.x):
			var u := (x + 0.5) / size.x
			var limits := BlockVerticalityProfile.layer_limits(Vector2(u, v))
			assert(1.0 > limits.x and limits.x > limits.y and limits.y > 0.0)
			boundaries.set_pixel(x, y, Color(limits.x, limits.y, 0.0, 1.0))
	packed_limits = boundaries.get_data().to_float32_array()

static func index_at(height: float, limits: Vector2) -> int:
	if height > limits.x:
		return 0
	return 1 if height > limits.y else 2

func material_at(uv: Vector2, height: float) -> MaterialDefinition:
	var limits := sample_limits(uv)
	return materials[index_at(height, limits)]

func sample_limits(uv: Vector2) -> Vector2:
	var color := ReliefSurface.sample_image(boundaries, uv)
	return Vector2(color.r, color.g)

func surface_limits(uv: Vector2) -> Vector2:
	# The displayed height is a triangle interpolation of filtered grid vertices,
	# not a bilinear fragment sample. Use that same grid/diagonal for interfaces.
	var size := boundaries.get_size()
	var point := uv.clamp(Vector2.ZERO, Vector2.ONE) * Vector2(size)
	var cell := Vector2i(point.floor()).min(size - Vector2i.ONE)
	var f := point - Vector2(cell)
	var b := sample_limits(Vector2(cell + Vector2i(1, 0)) / Vector2(size))
	var c := sample_limits(Vector2(cell + Vector2i(0, 1)) / Vector2(size))
	if f.x + f.y <= 1.0:
		var a := sample_limits(Vector2(cell) / Vector2(size))
		return a + (b - a) * f.x + (c - a) * f.y
	var d := sample_limits(Vector2(cell + Vector2i.ONE) / Vector2(size))
	return d + (c - d) * (1.0 - f.x) + (b - d) * (1.0 - f.y)

func surface_material_at(uv: Vector2, height: float) -> MaterialDefinition:
	return materials[index_at(height - SURFACE_EPSILON, surface_limits(uv))]

func hard_work_to_bone(limits: Vector2, bone_ceiling: float, depth_mm: float, chisel: ToolDefinition) -> float:
	# Debug/test oracle from the intact top, not a time prediction or gameplay rule.
	# Clay below a Bone ceiling inside Clay is inaccessible and must not be charged.
	var clay_mm := maxf(0.0, limits.x - maxf(limits.y, bone_ceiling)) * depth_mm
	var stone_mm := maxf(0.0, limits.y - bone_ceiling) * depth_mm
	var effort := 0.0
	for layer in [1, 2]:
		var thickness: float = clay_mm if layer == 1 else stone_mm
		if thickness <= 0.0: continue
		var effectiveness := chisel.effectiveness_for(materials[layer].id)
		if effectiveness <= 0.0: return INF
		effort += thickness * materials[layer].resistance / effectiveness
	return effort

func remove_work(height: float, work: float, cell: Vector2i, effectiveness := Vector3.ONE) -> float:
	var limits := boundaries.get_pixelv(cell)
	# Consume work piecewise at each interface. A long tick cannot skip resistance.
	for layer in range(3):
		var bottom := limits.r if layer == 0 else (limits.g if layer == 1 else 0.0)
		if height <= bottom:
			continue
		if effectiveness[layer] <= 0.0:
			return height
		var resistance := materials[layer].resistance / effectiveness[layer]
		var cost := (height - bottom) * resistance
		if work < cost:
			return maxf(bottom, height - work / resistance)
		height = bottom
		work -= cost
	return 0.0
