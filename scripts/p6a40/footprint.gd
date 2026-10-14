extends RefCounted
## One authored footprint, independent of fossil layout and excavation history.
const POINTS := [Vector2(.025,.28),Vector2(.065,.15),Vector2(.17,.055),Vector2(.39,.025),Vector2(.61,.06),Vector2(.77,.035),Vector2(.94,.14),Vector2(.98,.32),Vector2(.955,.54),Vector2(.975,.73),Vector2(.90,.94),Vector2(.68,.98),Vector2(.43,.95),Vector2(.19,.97),Vector2(.045,.84),Vector2(.018,.58)]
var mask := PackedByteArray()
var outside := PackedInt32Array()
var outline := PackedVector2Array()
var texture: ImageTexture
var size: Vector2i
var edge_segments: Array[Vector4] = []
func _init(resolution: Vector2i) -> void:
	size = resolution
	for n in range(POINTS.size()):
		var a: Vector2 = POINTS[n]
		var b: Vector2 = POINTS[(n+1)%POINTS.size()]
		for part in range(3):
			var p := a.lerp(b,float(part)/3.0)
			if part > 0: p += (b-a).orthogonal().normalized()*.006*sin(float(n*7+part*13))
			outline.append(p)
	mask.resize(size.x*size.y)
	for y in range(size.y):
		for x in range(size.x):
			var i := y*size.x+x
			if Geometry2D.is_point_in_polygon((Vector2(x,y)+Vector2.ONE*.5)/Vector2(size),outline): mask[i] = 255
			else: outside.append(i)
	for y in range(size.y):
		for x in range(size.x):
			if mask[y*size.x+x] == 0: continue
			# Counterclockwise boundary with the occupied cell on the left.
			if y == 0 or mask[(y-1)*size.x+x] == 0: edge_segments.append(Vector4(x,y,x+1,y))
			if x == size.x-1 or mask[y*size.x+x+1] == 0: edge_segments.append(Vector4(x+1,y,x+1,y+1))
			if y == size.y-1 or mask[(y+1)*size.x+x] == 0: edge_segments.append(Vector4(x+1,y+1,x,y+1))
			if x == 0 or mask[y*size.x+x-1] == 0: edge_segments.append(Vector4(x,y+1,x,y))
	texture = ImageTexture.create_from_image(Image.create_from_data(size.x,size.y,false,Image.FORMAT_R8,mask))
func contains_uv(uv: Vector2) -> bool:
	if not SurfaceMapping.contains_uv(uv): return false
	var cell := SurfaceMapping.uv_to_cell(uv,size)
	return mask[cell.y*size.x+cell.x] != 0
func wall_mesh(dimensions: Vector2) -> ArrayMesh:
	var vertices := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	for edge in edge_segments:
		var a := Vector2(edge.x,edge.y)/Vector2(size)
		var b := Vector2(edge.z,edge.w)/Vector2(size)
		var v := vertices.size()
		for point in [a,b]:
			var p: Vector2 = (point-Vector2.ONE*.5)*dimensions
			vertices.append(Vector3(p.x,0,p.y));uvs.append(point)
			vertices.append(Vector3(p.x,1,p.y));uvs.append(point)
		indices.append_array(PackedInt32Array([v,v+1,v+2,v+2,v+1,v+3]))
	var arrays := [];arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var result := ArrayMesh.new()
	result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	return result
