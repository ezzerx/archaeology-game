class_name ToolProxyPose
extends RefCounted
## Fixed orientation, anchored tip, minimal vertical body lift. No normal frame.

var parts: Array[Dictionary] = []
var last_transform := Transform3D.IDENTITY
var last_upload := -1
var last_recoil := -1.0
var body_lift := 0.0

static func fixed_basis(tool: int) -> Basis:
	return Basis.from_euler(Vector3(0.10, 0, -0.20 if tool != 2 else -0.18))

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

func fit(proxy: Node3D, block: ExcavationBlock, recoil := 0.0) -> void:
	if proxy.global_transform == last_transform and block.upload_count == last_upload and recoil == last_recoil: return
	last_transform = proxy.global_transform
	last_upload = block.upload_count
	last_recoil = recoil
	# One translation for the rigid body/handle. Only the first 4 mm of the
	# shaft blends that lift to zero at the exact tip. XY and global angle never
	# change. Probe the fixed geometry once, solve the required lift directly.
	body_lift = 0.0
	var lattice: Dictionary = {}
	var prepared: Array[Dictionary] = []
	for item in parts:
		var part: MeshInstance3D = item.node
		var to_block := block.global_transform.affine_inverse() * part.global_transform
		var vertices: PackedVector3Array = item.source.duplicate()
		var weights := PackedFloat32Array()
		var low := Vector3(INF, INF, INF)
		var high := Vector3(-INF, -INF, -INF)
		for i in range(vertices.size()):
			weights.append(clampf((vertices[i].y + part.position.y) / 0.004, 0, 1))
			vertices[i] = to_block * vertices[i]
			low = low.min(vertices[i])
			high = high.max(vertices[i])
		var upper := _maximum_height(block.relief, low, high, lattice)
		for i in range(vertices.size()):
			body_lift = maxf(body_lift, _required_lift(vertices[i], weights[i], block.relief, lattice))
		for i in range(0, item.indices.size(), 3):
			var ids := Vector3i(item.indices[i], item.indices[i + 1], item.indices[i + 2])
			if minf(vertices[ids.x].y, minf(vertices[ids.y].y, vertices[ids.z].y)) >= upper + 0.0001: continue
			for bary: Vector3 in [Vector3.ONE / 3, Vector3(0.5, 0.5, 0), Vector3(0, 0.5, 0.5), Vector3(0.5, 0, 0.5),
					Vector3(4, 1, 1) / 6, Vector3(1, 4, 1) / 6, Vector3(1, 1, 4) / 6]:
				var point := vertices[ids.x] * bary.x + vertices[ids.y] * bary.y + vertices[ids.z] * bary.z
				var weight := weights[ids.x] * bary.x + weights[ids.y] * bary.y + weights[ids.z] * bary.z
				body_lift = maxf(body_lift, _required_lift(point, weight, block.relief, lattice))
		prepared.append({"vertices": vertices, "weights": weights, "inverse": to_block.affine_inverse()})
	body_lift += maxf(recoil, 0)
	for index in range(parts.size()):
		var item := parts[index]
		var pose := prepared[index]
		if body_lift > 0 or item.fitted:
			var expanded := PackedVector3Array()
			expanded.resize(item.indices.size())
			for i in range(expanded.size()):
				var id: int = item.indices[i]
				expanded[i] = pose.inverse * (pose.vertices[id] + Vector3.UP * body_lift * pose.weights[id])
			var arrays := []
			arrays.resize(Mesh.ARRAY_MAX)
			arrays[Mesh.ARRAY_VERTEX] = expanded
			arrays[Mesh.ARRAY_NORMAL] = normals_for(expanded)
			item.mesh.clear_surfaces()
			item.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays, [], {}, Mesh.ARRAY_FLAG_USE_DYNAMIC_UPDATE)
		item.fitted = body_lift > 0

static func _required_lift(point: Vector3, weight: float, relief: ReliefSurface, lattice: Dictionary) -> float:
	if weight < 0.00001 or point.y >= relief.top_height + 0.0001: return 0.0
	var uv := SurfaceMapping.local_to_uv(point, relief.dimensions)
	if uv.x < 0 or uv.y < 0 or uv.x > 1 or uv.y > 1: return 0.0
	var deficit := _height_at(relief, uv, lattice) + 0.0001 - point.y
	# A small reserve only at an actual obstruction, never a blanket float.
	return (deficit + 0.0004) / weight if deficit > 0.000002 else 0.0

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
