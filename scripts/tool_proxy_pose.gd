class_name ToolProxyPose
extends RefCounted
## Visual frame only. Continuous on the upper hemisphere: no look-at pole/roll
## switch. All proxy geometry lives at local y >= 0, outside the contact plane.

var parts: Array[Dictionary] = []
var last_transform := Transform3D.IDENTITY
var last_upload := -1

func register_part(part: MeshInstance3D, tip_length: float) -> void:
	# Read render arrays directly: get_faces() quantizes its derived triangle
	# mesh and can move these millimetre-scale parts by a visible fraction.
	var source := part.mesh.surface_get_arrays(0)
	var vertices := PackedVector3Array()
	for index in source[Mesh.ARRAY_INDEX]:
		var point: Vector3 = source[Mesh.ARRAY_VERTEX][index] + part.position
		if point.y <= 0.00051: point.y = 0.0
		var taper := clampf(point.y / tip_length, 0.0, 1.0)
		point.x *= taper
		point.z *= taper
		vertices.append(point - part.position)
	# Flat-shaded triangles repeat each corner many times. Fit each distinct
	# position once, then expand back into the original render topology.
	var unique := PackedVector3Array()
	var indices := PackedInt32Array()
	var lookup: Dictionary = {}
	for vertex in vertices:
		if not lookup.has(vertex):
			lookup[vertex] = unique.size()
			unique.append(vertex)
		indices.append(lookup[vertex])
	var mesh := ArrayMesh.new()
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals_for(vertices)
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays, [], {}, Mesh.ARRAY_FLAG_USE_DYNAMIC_UPDATE)
	part.mesh = mesh
	parts.append({"node": part, "source": unique, "indices": indices, "mesh": mesh, "fitted": false})

static func normals_for(vertices: PackedVector3Array) -> PackedVector3Array:
	var normals := PackedVector3Array()
	normals.resize(vertices.size())
	for i in range(0, vertices.size(), 3):
		var normal := (vertices[i + 2] - vertices[i]).cross(vertices[i + 1] - vertices[i]).normalized()
		for j in range(3): normals[i + j] = normal
	return normals

func fit(proxy: Node3D, block: ExcavationBlock, world_normal := Vector3.UP) -> void:
	# Contact-normal orientation solves the tangent plane. Concave cavities can
	# still intersect the distant handle: lift ONLY visual vertices above local
	# relief. The origin/tip and every gameplay query remain untouched.
	if proxy.global_transform == last_transform and block.upload_count == last_upload: return
	last_transform = proxy.global_transform
	last_upload = block.upload_count
	var contact := block.to_local(proxy.global_position)
	var normal := (block.global_basis.transposed() * world_normal).normalized()
	# A pose only touches a small patch. Reuse its relief lattice samples across
	# parts; no global scan/cache and no change to the authoritative picking code.
	var lattice: Dictionary = {}
	for item in parts:
		var part: MeshInstance3D = item.node
		var to_block := block.global_transform.affine_inverse() * part.global_transform
		var from_block := to_block.affine_inverse()
		var vertices: PackedVector3Array = item.source.duplicate()
		var changed := false
		var low := Vector3(INF, INF, INF)
		var high := Vector3(-INF, -INF, -INF)
		for i in range(vertices.size()):
			var point := to_block * vertices[i]
			var signed_distance := (point - contact).dot(normal)
			if signed_distance < 0:
				point -= normal * signed_distance
				changed = true
			var raised := contact if point.distance_squared_to(contact) < 0.000000000001 else _raise(point, block.relief, lattice)
			changed = changed or raised != point
			vertices[i] = raised
			low = low.min(raised)
			high = high.max(raised)
		var upper := _maximum_height(block.relief, low, high, lattice)
		changed = _clear_faces(vertices, item.indices, block.relief, lattice, upper, contact) or changed
		if changed or item.fitted:
			var expanded := PackedVector3Array()
			expanded.resize(item.indices.size())
			for i in range(expanded.size()): expanded[i] = from_block * vertices[item.indices[i]]
			var arrays := []
			arrays.resize(Mesh.ARRAY_MAX)
			arrays[Mesh.ARRAY_VERTEX] = expanded
			arrays[Mesh.ARRAY_NORMAL] = normals_for(expanded)
			item.mesh.clear_surfaces()
			item.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays, [], {}, Mesh.ARRAY_FLAG_USE_DYNAMIC_UPDATE)
		item.fitted = changed

static func _raise(point: Vector3, relief: ReliefSurface, lattice: Dictionary) -> Vector3:
	if point.y >= relief.top_height + 0.0001: return point
	var uv := SurfaceMapping.local_to_uv(point, relief.dimensions)
	if uv.x < 0 or uv.y < 0 or uv.x > 1 or uv.y > 1: return point
	point.y = maxf(point.y, _height_at(relief, uv, lattice) + 0.0001)
	return point

static func _clear_faces(vertices: PackedVector3Array, indices: PackedInt32Array, relief: ReliefSurface,
		lattice: Dictionary, upper: float, contact: Vector3) -> bool:
	# Increasing Y cannot invalidate an earlier clearance. Shared vertices keep
	# the visual skin closed, with fixed topology and bounded local work.
	var changed := false
	for i in range(0, indices.size(), 3):
		var ids := Vector3i(indices[i], indices[i + 1], indices[i + 2])
		if minf(vertices[ids.x].y, minf(vertices[ids.y].y, vertices[ids.z].y)) >= upper + 0.000098: continue
		for weights: Vector3 in [Vector3.ONE / 3.0, Vector3(0.5, 0.5, 0), Vector3(0, 0.5, 0.5), Vector3(0.5, 0, 0.5),
				Vector3(4, 1, 1) / 6, Vector3(1, 4, 1) / 6, Vector3(1, 1, 4) / 6]:
			var point := vertices[ids.x] * weights.x + vertices[ids.y] * weights.y + vertices[ids.z] * weights.z
			var lift := _raise(point, relief, lattice).y - point.y
			if lift <= 0.000002: continue
			# Sub-mm reserve only on a face that actually intersects a cavity.
			# The contact tip is protected below; flat/free parts get no offset.
			lift += 0.0009
			var movable := Vector3.ONE
			for j in range(3):
				if vertices[ids[j]].distance_to(contact) < 0.0006: movable[j] = 0
			var share := weights.dot(movable)
			if share <= 0: continue
			for j in range(3): vertices[ids[j]].y += lift * movable[j] / share
			changed = true
	return changed

static func _maximum_height(relief: ReliefSurface, low: Vector3, high: Vector3, lattice: Dictionary) -> float:
	if low.y >= relief.top_height: return relief.top_height
	var first := Vector2i((SurfaceMapping.local_to_uv(low, relief.dimensions).clamp(Vector2.ZERO, Vector2.ONE) * Vector2(relief.cells)).floor())
	var last := Vector2i((SurfaceMapping.local_to_uv(high, relief.dimensions).clamp(Vector2.ZERO, Vector2.ONE) * Vector2(relief.cells)).ceil())
	var result := relief.floor_height
	for y in range(first.y, last.y + 1):
		for x in range(first.x, last.x + 1):
			var key := Vector2i(x, y)
			if not lattice.has(key): lattice[key] = relief.vertex_at(key).y
			result = maxf(result, lattice[key])
	return result

static func _height_at(relief: ReliefSurface, uv: Vector2, lattice: Dictionary) -> float:
	# Same triangle interpolation as ReliefSurface.height_at, with local lazy
	# memoization of vertex_at (including the CPU/GPU bilinear texture sample).
	var point := uv.clamp(Vector2.ZERO, Vector2.ONE) * Vector2(relief.cells)
	var cell := Vector2i(point.floor()).min(relief.cells - Vector2i.ONE)
	for offset in [Vector2i.ZERO, Vector2i(1, 0), Vector2i(0, 1), Vector2i.ONE]:
		var key: Vector2i = cell + offset
		if not lattice.has(key): lattice[key] = relief.vertex_at(key).y
	var fraction := point - Vector2(cell)
	var a: float = lattice[cell]
	var b: float = lattice[cell + Vector2i(1, 0)]
	var c: float = lattice[cell + Vector2i(0, 1)]
	var d: float = lattice[cell + Vector2i.ONE]
	if fraction.x + fraction.y <= 1.0:
		return a + (b - a) * fraction.x + (c - a) * fraction.y
	return d + (c - d) * (1.0 - fraction.x) + (b - d) * (1.0 - fraction.y)

static func contact_basis(normal: Vector3, twist := 0.0) -> Basis:
	var n := normal.normalized() if normal.length_squared() > 0.5 else Vector3.UP
	var denominator := maxf(1.0 + n.y, 0.0001)
	var x := Vector3(1.0 - n.x * n.x / denominator, -n.x, -n.x * n.z / denominator)
	var basis := Basis(x, n, x.cross(n)).orthonormalized()
	return basis * Basis(Vector3.UP, twist)
