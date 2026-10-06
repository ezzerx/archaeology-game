class_name NaturalMatrixProfile
extends SoilFoundationProfile
## Four emergent outcrops on continuous substrate; two companions, two pockets.
## Authored unions of elliptical lobes, asymmetric fronts, no Bone inputs/no noise.
const FOOTPRINT_MM := Vector2(1100, 700)
const TOP_BIAS_MM := -10.0
# Lobes are (center_u, center_v, radius_u, radius_v). back points to the side
# that merges gradually with the substrate, breaking the enclosing step contour.
const FORMS := [
	{"name":"Affleurement nord-ouest", "level_mm":0.0, "crown_mm":3.0, "tilt_mm":1.0,
	 "back":Vector2(-.7,-1), "bevel_mm":20.0, "merge_mm":140.0,
	 "lobes":[Vector4(.22,.17,.175,.22),Vector4(.335,.255,.11,.105),Vector4(.105,.27,.09,.13)]},
	{"name":"Affleurement central", "level_mm":1.0, "crown_mm":2.8, "tilt_mm":-.8,
	 "back":Vector2(.7,-1), "bevel_mm":20.0, "merge_mm":125.0,
	 "lobes":[Vector4(.535,.52,.14,.18),Vector4(.642,.465,.10,.105),Vector4(.455,.64,.092,.10)]},
	{"name":"Affleurement est", "level_mm":-.5, "crown_mm":3.0, "tilt_mm":1.1,
	 "back":Vector2(1,.5), "bevel_mm":21.0, "merge_mm":150.0,
	 "lobes":[Vector4(.85,.235,.16,.16),Vector4(.94,.39,.10,.14),Vector4(.74,.20,.073,.08)]},
	{"name":"Affleurement sud-ouest", "level_mm":-.8, "crown_mm":2.8, "tilt_mm":-.7,
	 "back":Vector2(-.6,1), "bevel_mm":19.0, "merge_mm":130.0,
	 "lobes":[Vector4(.18,.86,.155,.16),Vector4(.30,.91,.095,.10),Vector4(.09,.745,.085,.11)]},
	{"name":"Epaulement sud", "level_mm":-3.5, "crown_mm":.9, "tilt_mm":.5,
	 "back":Vector2(0,-1), "bevel_mm":19.0, "merge_mm":85.0,
	 "lobes":[Vector4(.57,.705,.09,.08),Vector4(.635,.718,.066,.05)]},
	{"name":"Epaulement est", "level_mm":-4.0, "crown_mm":.8, "tilt_mm":-.5,
	 "back":Vector2(1,-1), "bevel_mm":19.0, "merge_mm":95.0,
	 "lobes":[Vector4(.91,.50,.078,.105),Vector4(.847,.49,.057,.06)]},
	{"name":"Poche nord ouverte au sud", "level_mm":-19.0, "crown_mm":.6, "tilt_mm":.5,
	 "back":Vector2(.2,1), "bevel_mm":21.0, "merge_mm":130.0,
	 "lobes":[Vector4(.475,.18,.073,.08),Vector4(.49,.265,.048,.084)]},
	{"name":"Poche sud-est ouverte a l'est", "level_mm":-17.0, "crown_mm":.5, "tilt_mm":-.4,
	 "back":Vector2(1,.5), "bevel_mm":20.0, "merge_mm":110.0,
	 "lobes":[Vector4(.738,.67,.064,.064),Vector4(.758,.735,.045,.076)]}
]

var _bounds: Array[Rect2] = _prepare_bounds()

static func _prepare_bounds() -> Array[Rect2]:
	var result: Array[Rect2] = []
	for form in FORMS:
		var lo := Vector2.ONE
		var hi := Vector2.ZERO
		for lobe: Vector4 in form.lobes:
			var center := Vector2(lobe.x,lobe.y)
			var radius := Vector2(lobe.z,lobe.w)
			lo = lo.min(center-radius); hi = hi.max(center+radius)
		var margin: Vector2 = Vector2.ONE * (form.merge_mm + 12.0) / FOOTPRINT_MM
		result.append(Rect2(lo-margin,hi-lo+margin*2))
	return result

static func offsets_mm(uv: Vector2, bounds: Array[Rect2] = []) -> Vector2:
	if bounds.is_empty(): bounds = _prepare_bounds()
	var result := TOP_BIAS_MM
	var physical := uv * FOOTPRINT_MM
	# Low-frequency boundary deformation only (wavelengths 230–480 mm).
	# This perturbs the silhouettes, never adds a noisy height layer.
	var warped := physical + Vector2(8*sin(physical.y/43)+4*sin((physical.x+physical.y)/77),
		11*sin(physical.x/61)+3*cos(physical.y/37))
	for index in range(FORMS.size()):
		if not bounds[index].has_point(uv): continue
		var form: Dictionary = FORMS[index]
		var distance := -INF
		for lobe: Vector4 in form.lobes:
			var radius := Vector2(lobe.z,lobe.w) * FOOTPRINT_MM
			var p := warped-Vector2(lobe.x,lobe.y)*FOOTPRINT_MM
			var r := (p/radius).length()
			# Elliptical radial distance in mm, scaled by the minor radius.
			# Conservative on elongated lobes; not an exact Euclidean SDF.
			var d := (1.0-r) * minf(radius.x,radius.y)
			# Smooth union rounds the lobe junction, not the whole outcrop.
			var join := maxf(12.0-absf(distance-d),0.0)/12.0
			distance = maxf(distance,d) + join*join*3.0
		var first: Vector4 = form.lobes[0]
		var local := (uv-Vector2(first.x,first.y))*FOOTPRINT_MM
		var back: Vector2 = form.back.normalized()
		var merge := smoothstep(.15,.8,local.normalized().dot(back))
		var width: float = lerpf(form.bevel_mm,form.merge_mm,merge)
		var weight := smoothstep(-width*.6,width*.4,distance)
		# Slight crown and tilt across the top; no high-frequency surface noise.
		var crown := smoothstep(0,75,distance) * float(form.crown_mm)
		var tilt: float = clampf(local.dot(Vector2(.8,.6))/150.0,-1,1) * form.tilt_mm
		result = lerpf(result,float(form.level_mm)+crown+tilt,weight)
	# The lower Clay/Sandstone interface stays canonical, fully Bone-independent.
	return Vector2(result,0)

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
