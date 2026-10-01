class_name SurfaceMapping
extends RefCounted
## X/Z surface, +X = +U, +Z = +V. UV edges are inclusive.

static func local_to_uv(point: Vector3, size: Vector2) -> Vector2:
	return Vector2(point.x / size.x, point.z / size.y) + Vector2(0.5, 0.5)

static func contains_uv(uv: Vector2) -> bool:
	return uv.is_finite() and uv.x >= 0.0 and uv.x <= 1.0 and uv.y >= 0.0 and uv.y <= 1.0

static func uv_to_map(uv: Vector2, resolution: Vector2i) -> Vector2:
	# Integer coordinates identify texel centres, matching shader texture sampling.
	return uv * Vector2(resolution) - Vector2(0.5, 0.5)

static func uv_to_cell(uv: Vector2, resolution: Vector2i) -> Vector2i:
	return Vector2i(uv * Vector2(resolution)).clamp(Vector2i.ZERO, resolution - Vector2i.ONE)
