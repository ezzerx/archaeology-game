class_name NaturalMatrixProfile
extends SoilFoundationProfile
## One deterministic macro + meso field, never driven by fossil data.
const FOOTPRINT_MM := Vector2(1100, 700)
const TOP_BIAS_MM := -2.0
const MESO_PITCH_MM := 32.0
const FORMS := [
	{"name":"Affleurement nord-ouest", "amplitude_mm":12.0, "back":Vector2(-.7,-1), "bevel_mm":32.0, "merge_mm":100.0,
	 "lobes":[Vector4(.16,.16,.125,.13),Vector4(.245,.18,.075,.075),Vector4(.12,.265,.075,.06)]},
	{"name":"Affleurement est", "amplitude_mm":13.0, "back":Vector2(1,.5), "bevel_mm":34.0, "merge_mm":110.0,
	 "lobes":[Vector4(.835,.31,.125,.18),Vector4(.92,.40,.07,.10),Vector4(.79,.20,.085,.075)]},
	{"name":"Affleurement sud-ouest", "amplitude_mm":11.0, "back":Vector2(-.6,1), "bevel_mm":30.0, "merge_mm":100.0,
	 "lobes":[Vector4(.17,.83,.13,.13),Vector4(.245,.89,.09,.075),Vector4(.12,.735,.065,.08)]},
	{"name":"Affleurement nord central", "amplitude_mm":10.5, "back":Vector2(-.5,-1), "bevel_mm":30.0, "merge_mm":95.0,
	 "lobes":[Vector4(.545,.18,.10,.09),Vector4(.615,.235,.07,.06)]},
	{"name":"Epaulement nord-est", "amplitude_mm":4.0, "back":Vector2(1,-1), "bevel_mm":30.0, "merge_mm":85.0,
	 "lobes":[Vector4(.70,.26,.055,.06)]},
	{"name":"Epaulement sud-ouest", "amplitude_mm":3.0, "back":Vector2(-1,1), "bevel_mm":28.0, "merge_mm":80.0,
	 "lobes":[Vector4(.245,.71,.065,.05)]},
	{"name":"Poche nord-ouest", "amplitude_mm":-10.0, "back":Vector2(.4,1), "bevel_mm":30.0, "merge_mm":95.0,
	 "lobes":[Vector4(.375,.29,.08,.075),Vector4(.38,.355,.042,.045)]},
	{"name":"Poche est", "amplitude_mm":-8.0, "back":Vector2(-1,.3), "bevel_mm":30.0, "merge_mm":90.0,
	 "lobes":[Vector4(.69,.50,.07,.09),Vector4(.72,.56,.045,.045)]},
	{"name":"Poche sud", "amplitude_mm":-8.0, "back":Vector2(1,1), "bevel_mm":28.0, "merge_mm":85.0,
	 "lobes":[Vector4(.51,.80,.085,.06)]}
]
var _bounds: Array[Rect2] = _prepare_bounds()
var meso_stats := {}

static func _prepare_bounds() -> Array[Rect2]:
	var result: Array[Rect2] = []
	for form in FORMS:
		var lo := Vector2(INF,INF)
		var hi := -lo
		for lobe: Vector4 in form.lobes:
			var center := Vector2(lobe.x,lobe.y)
			var radius := Vector2(lobe.z,lobe.w)
			var physical := radius*FOOTPRINT_MM
			var margin := (physical/minf(physical.x,physical.y)*(float(form.merge_mm)*.6+12)+Vector2(12,14))/FOOTPRINT_MM
			lo = lo.min(center-radius-margin); hi = hi.max(center+radius+margin)
		result.append(Rect2(lo,hi-lo))
	return result

static func offsets_mm(uv: Vector2, bounds: Array[Rect2] = []) -> Vector2:
	# Macro field only; the cached meso field is composed separately at build.
	if bounds.is_empty(): bounds = _prepare_bounds()
	var result := TOP_BIAS_MM
	var physical := uv * FOOTPRINT_MM
	var warped := physical + Vector2(8*sin(physical.y/43)+4*sin((physical.x+physical.y)/77),
		11*sin(physical.x/61)+3*cos(physical.y/37))
	for index in range(FORMS.size()):
		if not bounds[index].has_point(uv): continue
		var form: Dictionary = FORMS[index]
		var distance := -INF
		for lobe: Vector4 in form.lobes:
			var radius := Vector2(lobe.z,lobe.w)*FOOTPRINT_MM
			var p := warped-Vector2(lobe.x,lobe.y)*FOOTPRINT_MM
			var d := (1.0-(p/radius).length())*minf(radius.x,radius.y)
			var join := maxf(12.0-absf(distance-d),0.0)/12.0
			distance = maxf(distance,d)+join*join*3.0
		var first: Vector4 = form.lobes[0]
		var local := (uv-Vector2(first.x,first.y))*FOOTPRINT_MM
		var back: Vector2 = form.back.normalized()
		var width: float = lerpf(form.bevel_mm,form.merge_mm,smoothstep(.15,.8,local.normalized().dot(back)))
		var weight := smoothstep(-width*.6,width*.4,distance)
		# Signed additive relief, not closed regions lerped toward target levels.
		result += float(form.amplitude_mm)*weight*(.80+.20*smoothstep(0,65,distance))
	return Vector2(result,0)

static func _fraction(index: int, salt: int) -> float:
	# Fixed integer mixing for one authored B-17 layout, no runtime seed system.
	var n := (index*374761393+salt*668265263) & 0x7fffffff
	n = ((n ^ (n >> 13))*1274126177) & 0x7fffffff
	return float(n ^ (n >> 16))/2147483647.0

func _meso_field() -> PackedFloat32Array:
	var positive := PackedFloat32Array(); positive.resize(size.x*size.y)
	var negative := PackedFloat32Array(); negative.resize(positive.size())
	var count := 0
	var cell_mm := FOOTPRINT_MM/Vector2(size)
	# Jittered, independently rotated irregular platelets. A broad density field
	# groups them and leaves calmer gaps; they never partition the whole plane.
	for gy in range(-1,24):
		for gx in range(-1,36):
			var id := (gy+2)*41+gx+2
			var center := Vector2(gx+.5,gy+.5)*MESO_PITCH_MM
			center += Vector2(_fraction(id,1)-.5,_fraction(id,2)-.5)*MESO_PITCH_MM*.7
			var density := .52+.34*sin(center.x/130+.8)*cos(center.y/105-.4)
			if _fraction(id,3) > density: continue
			var extent := Vector2(11+13*_fraction(id,4),9+11*_fraction(id,5))
			var angle := .30*sin(center.x/100+center.y/150)+(_fraction(id,6)-.5)*1.5
			var axis := Vector2(cos(angle),sin(angle))
			var side := Vector2(-axis.y,axis.x)
			var amount := lerpf(1.5,3.6,_fraction(id,7))
			if _fraction(id,8) < .32: amount = -lerpf(1.4,2.8,_fraction(id,9))
			var bevel := 5.0+2.0*_fraction(id,10)
			var corner := .66+.20*_fraction(id,11)
			var radius := extent.length()+16
			var lo := Vector2i((center-Vector2.ONE*radius)/cell_mm).clamp(Vector2i.ZERO,size-Vector2i.ONE)
			var hi := Vector2i((center+Vector2.ONE*radius)/cell_mm).clamp(Vector2i.ZERO,size-Vector2i.ONE)
			if center.x < -radius or center.y < -radius or center.x > FOOTPRINT_MM.x+radius or center.y > FOOTPRINT_MM.y+radius: continue
			var touched := false
			for y in range(lo.y,hi.y+1):
				for x in range(lo.x,hi.x+1):
					var p := (Vector2(x,y)+Vector2.ONE*.5)*cell_mm-center
					var q := Vector2(p.dot(axis),p.dot(side))
					# Clipped, skewed little flats. Different fades on two sides
					# prevent a constant-width closed rim around every platelet.
					var skew := q.x+.22*q.y
					var d := minf(extent.x-absf(skew),extent.y-absf(q.y))
					d = minf(d,(extent.x+extent.y)*corner-absf(skew*.8+q.y*.65))
					d = minf(d,extent.x*.9-(q.x*.6-q.y*.8))
					var width := lerpf(bevel,bevel*2.4,smoothstep(-extent.y*.3,extent.y*.7,q.y))
					var w := smoothstep(-width*.5,width*.5,d)
					if w == 0: continue
					touched = true
					var i := y*size.x+x
					if amount > 0: positive[i] = maxf(positive[i],amount*w)
					else: negative[i] = minf(negative[i],amount*w)
			if touched: count += 1
	var low := INF; var high := -INF; var affected := 0
	for i in range(positive.size()):
		positive[i] += negative[i]
		low = minf(low,positive[i]); high = maxf(high,positive[i])
		if absf(positive[i]) > .5: affected += 1
	meso_stats = {"platelets":count,"pitch_mm":MESO_PITCH_MM,"min_mm":low,"max_mm":high,"fraction_over_half_mm":float(affected)/positive.size()}
	return positive

func _init(surface: WorkingSurface) -> void:
	# Retain the accepted thin Soil cache exactly; skip the old corner witness.
	super(surface, 1)
	var started := Time.get_ticks_usec()
	var meso := _meso_field()
	var layers := limits[0].duplicate()
	var substrate := substrates[0].duplicate()
	var top := thin_tops[0].duplicate()
	for y in range(size.y):
		for x in range(size.x):
			var i := y * size.x + x
			var uv := (Vector2(x, y) + Vector2.ONE * 0.5) / Vector2(size)
			var offset := (offsets_mm(uv, _bounds) + Vector2(meso[i],0)) / (surface.excavatable_depth * 1000.0)
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
