extends NaturalMatrixProfile
## Hero-only initial Soil. Never reads Bone, changes strata or fills depressions.
## The previous coverage remains available for controlled morphological review.
var fragmented := true
var fragmented_top := PackedFloat32Array()

func _init(surface: WorkingSurface) -> void:
	super(surface)
	var rng := RandomNumberGenerator.new()
	rng.seed = 620710
	var edge := FastNoiseLite.new()
	edge.seed = 81726
	edge.frequency = .19
	edge.fractal_type = FastNoiseLite.FRACTAL_NONE
	var grains := FastNoiseLite.new()
	grains.seed = 71928
	grains.frequency = .68
	grains.fractal_type = FastNoiseLite.FRACTAL_NONE
	var mm := PackedFloat32Array()
	mm.resize(size.x * size.y)
	var cell_mm := FOOTPRINT_MM / Vector2(size)
	var occupied: Array[Vector3] = []
	# Unevenly spaced parent deposits and small crumbs, not a thresholded broad
	# noise field. Max-union avoids piling overlapping deposits into thick slabs.
	for deposit in range(720):
		var center := Vector2(rng.randf_range(0,1100),rng.randf_range(0,700))
		var radius := rng.randf_range(4,10)
		if deposit < 270: radius = rng.randf_range(12,25)
		if deposit < 65: radius = rng.randf_range(27,39)
		var overlaps := false
		for other in occupied:
			if center.distance_to(Vector2(other.x,other.y)) < (radius+other.z)*1.12+3:
				overlaps = true
				break
		if overlaps: continue
		occupied.append(Vector3(center.x,center.y,radius))
		var extent := Vector2(radius,radius*rng.randf_range(.45,.95))
		var angle := rng.randf_range(0,TAU)
		var axis := Vector2(cos(angle),sin(angle))
		var side := Vector2(-axis.y,axis.x)
		var amount := rng.randf_range(.55,1.65)
		var lo := Vector2i((center-Vector2.ONE*radius*1.3)/cell_mm).clamp(Vector2i.ZERO,size-Vector2i.ONE)
		var hi := Vector2i((center+Vector2.ONE*radius*1.3)/cell_mm).clamp(Vector2i.ZERO,size-Vector2i.ONE)
		for y in range(lo.y,hi.y+1):
			for x in range(lo.x,hi.x+1):
				var world := (Vector2(x,y)+Vector2.ONE*.5)*cell_mm
				var p := world-center
				var q := Vector2(p.dot(axis),p.dot(side))/extent
				var irregular := edge.get_noise_2dv(world)
				var fine := grains.get_noise_2dv(world)
				# Several unequal lobes and a localized notch break the disc shape.
				var theta := atan2(q.y,q.x)
				var lobes := 1.0+.12*sin(theta*3+angle)+.08*cos(theta*5-angle)
				var notch := .18*exp(-pow((theta-.7)/.45,2))
				var distance := q.length()/lobes+notch+irregular*.34+fine*.17
				# Real gaps, not sub-micron bridges. Broken edges taper within
				# ~2–4 mm; retained grain heights stay below the 2 mm contract.
				var weight := smoothstep(1.0,.72,distance)
				if weight < .08: continue
				var height := amount*weight*(.78+.22*clampf(.5+fine,0,1))
				var i := y*size.x+x
				mm[i] = maxf(mm[i],height)
	fragmented_top = substrates[1].duplicate()
	for i in range(mm.size()):
		fragmented_top[i] += mm[i]/(surface.excavatable_depth*1000)

func apply(block: ExcavationBlock, candidate: int, fixture: int, cleared: bool) -> void:
	if not fragmented or candidate != 1 or cleared:
		super.apply(block,candidate,fixture,cleared)
		return
	# Reuse the existing upload and reset path with a local initial-condition cache.
	var previous := thin_tops[1]
	thin_tops[1] = fragmented_top
	super.apply(block,candidate,fixture,cleared)
	thin_tops[1] = previous
