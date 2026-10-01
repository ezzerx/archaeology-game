class_name Stratigraphy
extends RefCounted
## One fixed test block, not a level generator. Thresholds are immutable at runtime.

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
			# Authored gentle folds, same in every run and at every resolution.
			var soil_bottom := 0.70 + 0.026 * sin(u * 13.0 + v * 5.0) + 0.012 * cos(v * 17.0 - u * 4.0)
			var clay_bottom := 0.36 + 0.022 * sin(u * 9.0 - v * 11.0) + 0.010 * cos(u * 21.0 + v * 8.0)
			boundaries.set_pixel(x, y, Color(soil_bottom, clay_bottom, 0.0, 1.0))
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

func remove_work(height: float, work: float, cell: Vector2i) -> float:
	var limits := boundaries.get_pixelv(cell)
	# Consume work piecewise at each interface. A long tick cannot skip resistance.
	for layer in range(3):
		var bottom := limits.r if layer == 0 else (limits.g if layer == 1 else 0.0)
		if height <= bottom:
			continue
		var resistance := materials[layer].resistance
		var cost := (height - bottom) * resistance
		if work < cost:
			return maxf(bottom, height - work / resistance)
		height = bottom
		work -= cost
	return 0.0
