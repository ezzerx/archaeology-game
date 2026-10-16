extends RefCounted
## Authored angular profiles on the accepted outline; never reads the fossil.
const LEVELS := [0.0,.25,.57,.85,1.0]
const OFFSETS := [.0015,.012,.004,.005,0.0]
var shape: RefCounted
var dimensions: Vector2
var band := {}
var caps := {}
var padding := {}
var wall_samples := {}
var mesh: ArrayMesh
static func fraction(n: int, salt: int) -> float:
	var value := (n*374761393+salt*668265263)&0x7fffffff
	value = ((value^(value>>13))*1274126177)&0x7fffffff
	return float(value^(value>>16))/2147483647.0
func width(n: int) -> float:
	return .008+.026*fraction(n,1)
func depth(n: int) -> float:
	return 0.0 if n%7 in [0,1,2] else .006+.018*fraction(n,2)
func _init(footprint: RefCounted, size_m: Vector2) -> void:
	shape = footprint
	dimensions = size_m
	# Populate only a bounded strip around the polygon, not every map cell.
	for n in range(shape.outline.size()):
		var a: Vector2 = shape.outline[n]*dimensions
		var b: Vector2 = shape.outline[(n+1)%shape.outline.size()]*dimensions
		var low := Vector2i(((a.min(b)-Vector2.ONE*.033)/dimensions*Vector2(shape.size)).floor()).max(Vector2i.ZERO)
		var high := Vector2i(((a.max(b)+Vector2.ONE*.033)/dimensions*Vector2(shape.size)).ceil()).min(shape.size-Vector2i.ONE)
		for y in range(low.y,high.y+1):
			for x in range(low.x,high.x+1):
				var i: int = y*shape.size.x+x
				if shape.mask[i] == 0: continue
				var p := (Vector2(x,y)+Vector2.ONE*.5)/Vector2(shape.size)*dimensions
				var t := clampf((p-a).dot(b-a)/(b-a).length_squared(),0,1)
				var distance := p.distance_to(a.lerp(b,t))
				if distance < .032 and (not band.has(i) or distance < band[i].distance):
					band[i] = {"distance":distance,"segment":n,"t":t}
	for edge in shape.edge_segments:
		var delta := Vector2(edge.z-edge.x,edge.w-edge.y)
		var inside := Vector2i((Vector2(edge.x,edge.y)+delta*.5+Vector2(-delta.y,delta.x)*.5).floor())
		var source: int = inside.y*shape.size.x+inside.x
		for dy in range(-1,2):
			for dx in range(-1,2):
				var cell := inside+Vector2i(dx,dy)
				if cell.x < 0 or cell.y < 0 or cell.x >= shape.size.x or cell.y >= shape.size.y: continue
				var i: int = cell.y*shape.size.x+cell.x
				if shape.mask[i] != 0: continue
				if not padding.has(i): padding[i] = source
				else:
					var previous: int = padding[i]
					@warning_ignore("integer_division")
					var previous_cell := Vector2i(previous%shape.size.x,previous/shape.size.x)
					if previous_cell.distance_squared_to(cell) > inside.distance_squared_to(cell): padding[i] = source
	mesh = build_wall()
func build_caps(initial: PackedFloat32Array, excavatable_depth: float) -> void:
	for i in band:
		var sample: Dictionary = band[i]
		var n: int = sample.segment
		var next: int = (n+1)%shape.outline.size()
		var span := lerpf(width(n),width(next),sample.t)
		var cut := lerpf(depth(n),depth(next),sample.t)*maxf(0,1.0-sample.distance/span)
		if n%4 == 2: cut += .006*maxf(0,1.0-absf(sample.t-.46)/.35)*maxf(0,1.0-sample.distance/span)
		if cut > .00001: caps[i] = maxf(0,initial[i]-cut/excavatable_depth)
func capped(data: PackedFloat32Array) -> PackedFloat32Array:
	var result := data.duplicate()
	for i in caps: result[i] = minf(result[i],caps[i])
	return result
func sample_wall(cell: Vector2i) -> Dictionary:
	if wall_samples.has(cell): return wall_samples[cell]
	var uv := Vector2(cell)/Vector2(shape.size)
	var p := uv*dimensions
	var best := INF
	var result := {}
	for n in range(shape.outline.size()):
		var a: Vector2 = shape.outline[n]*dimensions
		var b: Vector2 = shape.outline[(n+1)%shape.outline.size()]*dimensions
		var t := clampf((p-a).dot(b-a)/(b-a).length_squared(),0,1)
		var distance := p.distance_squared_to(a.lerp(b,t))
		if distance >= best: continue
		best = distance
		var next: int = (n+1)%shape.outline.size()
		var tangent := (b-a).normalized()
		result = {"uv":uv,"outward":Vector2(tangent.y,-tangent.x),"strength":lerpf(.5+fraction(n,3),.5+fraction(next,3),t),"levels":PackedFloat32Array([0.0,lerpf(.15+.18*fraction(n,4),.15+.18*fraction(next,4),t),lerpf(.48+.18*fraction(n,5),.48+.18*fraction(next,5),t),lerpf(.76+.15*fraction(n,6),.76+.15*fraction(next,6),t),1.0])}
	wall_samples[cell] = result
	return result
func build_wall() -> ArrayMesh:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	for edge in shape.edge_segments:
		var a := sample_wall(Vector2i(edge.x,edge.y))
		var b := sample_wall(Vector2i(edge.z,edge.w))
		for level in range(LEVELS.size()-1):
			var v := vertices.size()
			var lo: float = (a.levels[level]+b.levels[level])*.5
			var hi: float = (a.levels[level+1]+b.levels[level+1])*.5
			var outward: Vector2 = (a.outward+b.outward).normalized()
			var strength: float = (a.strength+b.strength)*.5
			var slope: float = (OFFSETS[level+1]-OFFSETS[level])*strength/(.085*(hi-lo))
			var normal := Vector3(outward.x,-slope,outward.y).normalized()
			for point in [a,b]:
				for ring in [level,level+1]:
					var planar: Vector2 = (point.uv-Vector2.ONE*.5)*dimensions+point.outward*OFFSETS[ring]*point.strength
					vertices.append(Vector3(planar.x,point.levels[ring],planar.y))
					normals.append(normal)
					uvs.append(point.uv)
			indices.append_array(PackedInt32Array([v,v+1,v+2,v+2,v+1,v+3]))
	var arrays := [];arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var result := ArrayMesh.new()
	result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	return result
