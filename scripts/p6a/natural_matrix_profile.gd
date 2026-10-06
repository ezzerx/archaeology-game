class_name NaturalMatrixProfile
extends SoilFoundationProfile
## Five authored macro forms. UV only: no Bone sampling, clamping or silhouette mask.
## All amplitudes are millimetres; the 102 mm production vertical scale is unchanged.
const TOP_BIAS_MM := -4.0
const FORMS := [
	{"name": "Bassin", "center": Vector2(0.32, 0.32), "radius": Vector2(0.22, 0.23),
		"angle_deg": -12.0, "top_mm": -20.0, "interface_mm": -0.6, "shelf_inner": 0.45},
	{"name": "Crete", "center": Vector2(0.66, 0.44), "radius": Vector2(0.28, 0.09),
		"angle_deg": -24.0, "top_mm": 12.0, "interface_mm": -0.8, "shelf_inner": 0.0},
	{"name": "Creux aval", "center": Vector2(0.63, 0.76), "radius": Vector2(0.25, 0.205),
		"angle_deg": 14.0, "top_mm": -10.0, "interface_mm": -0.5, "shelf_inner": 0.0},
	{"name": "Palier", "center": Vector2(0.79, 0.18), "radius": Vector2(0.18, 0.22),
		"angle_deg": 18.0, "top_mm": -10.0, "interface_mm": -0.4, "shelf_inner": 0.50},
	{"name": "Butte", "center": Vector2(0.18, 0.73), "radius": Vector2(0.20, 0.24),
		"angle_deg": -16.0, "top_mm": 5.0, "interface_mm": 0.0, "shelf_inner": 0.0}
]

static func offsets_mm(uv: Vector2) -> Vector2:
	var result := Vector2(TOP_BIAS_MM, 0)
	for form in FORMS:
		var q: Vector2 = (uv - form.center).rotated(deg_to_rad(-form.angle_deg)) / form.radius
		var r: float = q.length()
		if r >= 1.0: continue
		var w := pow(1.0 - r * r, 2.0)
		if form.shelf_inner > 0.0: w = 1.0 - smoothstep(form.shelf_inner, 1.0, r)
		result += Vector2(form.top_mm, form.interface_mm) * w
	return result

func _init(surface: WorkingSurface) -> void:
	# Retain the accepted thin Soil cache exactly; skip the old corner witness.
	super(surface, 1)
	var started := Time.get_ticks_usec()
	var layers := limits[0].duplicate()
	var substrate := substrates[0].duplicate()
	var top := thin_tops[0].duplicate()
	for y in range(size.y):
		for x in range(size.x):
			var i := y * size.x + x
			var uv := (Vector2(x, y) + Vector2.ONE * 0.5) / Vector2(size)
			var offset := offsets_mm(uv) / (surface.excavatable_depth * 1000.0)
			layers[i * 2] += offset.x
			layers[i * 2 + 1] += offset.y
			substrate[i] = layers[i * 2]
			# Translate the same local Soil quantity; do not fill the bowls.
			top[i] = substrate[i] + (thin_tops[0][i] - substrates[0][i])
	limits.append(layers)
	substrates.append(substrate)
	thin_tops.append(top)
	build_usec += Time.get_ticks_usec() - started

func apply(block: ExcavationBlock, candidate: int, _fixture: int, cleared: bool) -> void:
	# Both A and B use accepted thin Soil. The index now selects MATRIX geometry.
	super.apply(block, 1, candidate, cleared)
