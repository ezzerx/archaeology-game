class_name ToolProxyPose
extends RefCounted
## Static tip/body meshes. Only a bounded terrain query and Body translation run
## during play; mesh splitting and normal generation happen once at setup.
const TIP_HEIGHT := 0.004
const MAX_PROBES := 12
var tip: Node3D
var body: Node3D
var probes := PackedVector3Array()
var _body_vertices := PackedVector3Array()
var last_transform := Transform3D.IDENTITY
var last_upload := -1
var body_lift := 0.0
var _clearance := 0.0
var last_probe_count := 0

static func fixed_basis(_tool: int) -> Basis:
	return Basis.from_euler(Vector3(0.5, 0, -0.62))

func setup(proxy: Node3D) -> void:
	tip = Node3D.new()
	tip.name = "Tip"
	proxy.add_child(tip)
	body = Node3D.new()
	body.name = "Body"
	proxy.add_child(body)

func register_part(part: MeshInstance3D, tip_length: float) -> void:
	var arrays := part.mesh.surface_get_arrays(0)
	var vertices := PackedVector3Array()
	for index in arrays[Mesh.ARRAY_INDEX]:
		var point: Vector3 = arrays[Mesh.ARRAY_VERTEX][index] + part.position
		if point.y <= 0.00051: point.y = 0.0
		var taper := clampf(point.y / tip_length, 0, 1)
		point.x *= taper
		point.z *= taper
		vertices.append(point)
	# Split the existing silhouette once. At rest the two pieces exactly meet;
	# in a cavity a small static tip remains at the hit while the body lifts.
	for upper in [false, true]:
		var clipped := PackedVector3Array()
		for i in range(0, vertices.size(), 3):
			var polygon := _clip_triangle(vertices[i], vertices[i + 1], vertices[i + 2], upper)
			for j in range(1, polygon.size() - 1):
				for point: Vector3 in [polygon[0], polygon[j], polygon[j + 1]]: clipped.append(point)
		if clipped.is_empty(): continue
		var node := MeshInstance3D.new()
		node.mesh = _static_mesh(clipped)
		node.material_override = part.material_override
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		(body if upper else tip).add_child(node)
		if upper: _body_vertices.append_array(clipped)
	part.free()

static func _clip_triangle(a: Vector3, b: Vector3, c: Vector3, upper: bool) -> PackedVector3Array:
	var polygon := PackedVector3Array()
	var previous := c
	var previous_inside := previous.y >= TIP_HEIGHT if upper else previous.y < TIP_HEIGHT
	for point: Vector3 in [a, b, c]:
		var inside := point.y >= TIP_HEIGHT if upper else point.y < TIP_HEIGHT
		if inside != previous_inside:
			polygon.append(previous.lerp(point, (TIP_HEIGHT - previous.y) / (point.y - previous.y)))
		if inside: polygon.append(point)
		previous = point
		previous_inside = inside
	return polygon

static func _static_mesh(vertices: PackedVector3Array) -> ArrayMesh:
	var normals := PackedVector3Array()
	normals.resize(vertices.size())
	for i in range(0, vertices.size(), 3):
		var normal := (vertices[i + 2] - vertices[i]).cross(vertices[i + 1] - vertices[i]).normalized()
		for j in range(3): normals[i + j] = normal
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh

func finish() -> void:
	# Three cross-sections, four corners each. This startup-only scan keeps the
	# probes inside the tapered silhouette instead of lifting a flat-ground tip.
	var top := TIP_HEIGHT
	for vertex in _body_vertices: top = maxf(top, vertex.y)
	for height in [TIP_HEIGHT, lerpf(TIP_HEIGHT, top, 0.35), lerpf(TIP_HEIGHT, top, 0.75)]:
		var low := Vector2(INF, INF)
		var high := Vector2(-INF, -INF)
		for i in range(0, _body_vertices.size(), 3):
			for j in range(3):
				var a := _body_vertices[i + j]
				var b := _body_vertices[i + (j + 1) % 3]
				if height < minf(a.y, b.y) or height > maxf(a.y, b.y): continue
				var p := a.lerp(b, (height - a.y) / (b.y - a.y)) if absf(b.y - a.y) > 0.000001 else a
				low = low.min(Vector2(p.x, p.z))
				high = high.max(Vector2(p.x, p.z))
		if not low.is_finite(): continue
		for corner in [low, Vector2(low.x, high.y), high, Vector2(high.x, low.y)]:
			probes.append(Vector3(corner.x, height, corner.y))
	_body_vertices.clear()

func fit(proxy: Node3D, block: ExcavationBlock, recoil := 0.0) -> void:
	last_probe_count = 0
	if proxy.global_transform != last_transform or block.upload_count != last_upload:
		last_transform = proxy.global_transform
		last_upload = block.upload_count
		_clearance = 0.0
		var to_block := block.global_transform.affine_inverse() * proxy.global_transform
		for source in probes:
			var point := to_block * source
			if point.y >= block.relief.top_height + 0.0001: continue
			var uv := SurfaceMapping.local_to_uv(point, block.surface_size)
			if uv.x < 0 or uv.y < 0 or uv.x > 1 or uv.y > 1: continue
			last_probe_count += 1
			var deficit := block.relief.height_at(uv) + 0.0001 - point.y
			if deficit > 0.000002: _clearance = maxf(_clearance, deficit + 0.0004)
		_clearance = minf(_clearance, block.relief.top_height - block.relief.floor_height)
	body_lift = _clearance + maxf(recoil, 0)
	body.global_position = proxy.global_position + block.global_basis.y * body_lift
