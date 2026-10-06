class_name NaturalMatrixProfile
extends SoilFoundationProfile
## Authored mineral plates and open pockets, independent of every Bone input.
## Physical-width bevels connect broad interiors; no noise or new shader detail.
const FOOTPRINT_MM := Vector2(1100, 700)
const TOP_BIAS_MM := -6.0
const FORMS := [
	{"name":"Masse nord-ouest", "level_mm":0.0, "interface_mm":0.0, "bevel_mm":20.0,
	 "outline":[Vector2(-0.04,-0.04),Vector2(0.41,-0.02),Vector2(0.44,0.16),Vector2(0.365,0.25),Vector2(0.39,0.345),Vector2(0.29,0.45),Vector2(0.125,0.44),Vector2(0.1,0.515),Vector2(-0.04,0.56)]},
	{"name":"Poche centrale ouverte", "level_mm":-17.0, "interface_mm":-.6, "bevel_mm":22.0,
	 "outline":[Vector2(0.31,0.18),Vector2(0.45,0.13),Vector2(0.55,0.21),Vector2(0.52,0.265),Vector2(0.565,0.31),Vector2(0.5,0.385),Vector2(0.42,0.4),Vector2(0.36,0.355)]},
	{"name":"Palier nord-est", "level_mm":-9.0, "interface_mm":-.3, "bevel_mm":18.0,
	 "outline":[Vector2(0.65,-0.04),Vector2(0.9,-0.03),Vector2(1.03,0.08),Vector2(1.03,0.4),Vector2(0.88,0.41),Vector2(0.84,0.35),Vector2(0.67,0.38),Vector2(0.59,0.28),Vector2(0.62,0.2)]},
	{"name":"Banc ouest", "level_mm":-10.0, "interface_mm":-.5, "bevel_mm":20.0,
	 "outline":[Vector2(-0.03,0.46),Vector2(0.15,0.44),Vector2(0.255,0.515),Vector2(0.345,0.505),Vector2(0.39,0.585),Vector2(0.28,0.69),Vector2(0.115,0.665),Vector2(0.045,0.74),Vector2(-0.035,0.695)]},
	{"name":"Plaque centrale", "level_mm":1.0, "interface_mm":0.0, "bevel_mm":18.0,
	 "outline":[Vector2(0.45,0.425),Vector2(0.52,0.385),Vector2(0.64,0.4),Vector2(0.665,0.495),Vector2(0.745,0.525),Vector2(0.7,0.61),Vector2(0.61,0.635),Vector2(0.575,0.735),Vector2(0.44,0.77),Vector2(0.355,0.625),Vector2(0.4,0.535)]},
	{"name":"Masse est", "level_mm":0.0, "interface_mm":0.0, "bevel_mm":20.0,
	 "outline":[Vector2(0.75,0.425),Vector2(0.88,0.395),Vector2(0.9,0.45),Vector2(1.03,0.445),Vector2(1.025,0.685),Vector2(0.91,0.68),Vector2(0.82,0.745),Vector2(0.69,0.65),Vector2(0.73,0.585),Vector2(0.695,0.525)]},
	{"name":"Dalle sud-ouest", "level_mm":1.0, "interface_mm":0.0, "bevel_mm":18.0,
	 "outline":[Vector2(-0.02,0.76),Vector2(0.16,0.7),Vector2(0.265,0.755),Vector2(0.33,0.725),Vector2(0.42,0.85),Vector2(0.38,1.03),Vector2(-0.04,1.03)]},
	{"name":"Cuvette sud", "level_mm":-10.0, "interface_mm":-.5, "bevel_mm":20.0,
	 "outline":[Vector2(0.49,0.81),Vector2(0.615,0.715),Vector2(0.705,0.78),Vector2(0.665,0.84),Vector2(0.71,0.91),Vector2(0.65,1.03),Vector2(0.52,1.03),Vector2(0.435,0.95),Vector2(0.46,0.88)]},
	{"name":"Socle sud-est", "level_mm":-10.0, "interface_mm":-.2, "bevel_mm":18.0,
	 "outline":[Vector2(0.785,0.735),Vector2(0.93,0.69),Vector2(1.04,0.78),Vector2(1.04,1.03),Vector2(0.735,1.03),Vector2(0.715,0.845)]},
	{"name":"Replat imbrique", "level_mm":-3.0, "interface_mm":-.2, "bevel_mm":18.0,
	 "outline":[Vector2(0.5,0.51),Vector2(0.595,0.48),Vector2(0.655,0.535),Vector2(0.61,0.59),Vector2(0.625,0.635),Vector2(0.52,0.685),Vector2(0.45,0.63),Vector2(0.48,0.59)]}
]

var _bounds: Array[Rect2] = _prepare_bounds()

static func _prepare_bounds() -> Array[Rect2]:
	var result: Array[Rect2] = []
	for form in FORMS:
		var lo := Vector2.ONE
		var hi := Vector2.ZERO
		for v: Vector2 in form.outline:
			lo = lo.min(v); hi = hi.max(v)
		var margin: Vector2 = Vector2.ONE * form.bevel_mm * .5 / FOOTPRINT_MM
		result.append(Rect2(lo-margin,hi-lo+margin*2))
	return result

static func offsets_mm(uv: Vector2, bounds: Array[Rect2] = []) -> Vector2:
	if bounds.is_empty(): bounds = _prepare_bounds()
	var result := Vector2(TOP_BIAS_MM, 0)
	var point := uv * FOOTPRINT_MM
	for index in range(FORMS.size()):
		# Derived broad-phase boxes are cached once, without reading any map.
		if not bounds[index].has_point(uv): continue
		var form: Dictionary = FORMS[index]
		var inside := false
		var distance := INF
		var previous: Vector2 = form.outline[-1] * FOOTPRINT_MM
		for v: Vector2 in form.outline:
			var current := v * FOOTPRINT_MM
			var nearest := Geometry2D.get_closest_point_to_segment(point,previous,current)
			distance = minf(distance,point.distance_to(nearest))
			if (current.y > point.y) != (previous.y > point.y):
				if point.x < (previous.x-current.x)*(point.y-current.y)/(previous.y-current.y)+current.x: inside = not inside
			previous = current
		var signed_distance: float = distance if inside else -distance
		var w := smoothstep(-form.bevel_mm*.5,form.bevel_mm*.5,signed_distance)
		# Ordered overlapping masses: levels do not add up into spikes.
		result = result.lerp(Vector2(form.level_mm,form.interface_mm),w)
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
			var offset := offsets_mm(uv, _bounds) / (surface.excavatable_depth * 1000.0)
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
