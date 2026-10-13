class_name NaturalMatrixMeshOracle
extends RefCounted
## Test-only native mesh oracle; independent sampling and float64 plane intersection.
## Plane solver preserved from the P4V regression oracle.
static func height(block: ExcavationBlock, camera: Camera3D, pixel: Vector2) -> float:
	var arrays := (block.surface.mesh as PlaneMesh).get_mesh_arrays()
	var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	var origin := camera.project_ray_origin(pixel)
	var direction := camera.project_ray_normal(pixel)
	var top := origin + direction * ((block.thickness - origin.y) / direction.y)
	var floor_point := origin + direction * ((block.base_height - origin.y) / direction.y)
	var start := SurfaceMapping.local_to_uv(top, block.surface_size) * Vector2(block.map_resolution)
	var end := SurfaceMapping.local_to_uv(floor_point, block.surface_size) * Vector2(block.map_resolution)
	var low := (Vector2i(start.min(end).floor()) - Vector2i.ONE * 2).max(Vector2i.ZERO)
	var high := (Vector2i(start.max(end).ceil()) + Vector2i.ONE * 2).min(block.map_resolution - Vector2i.ONE)
	var nearest := Vector3.INF
	var distance := INF
	for y in range(low.y, high.y + 1):
		for x in range(low.x, high.x + 1):
			var cell := (block.map_resolution.y - 1 - y) * block.map_resolution.x + block.map_resolution.x - 1 - x
			for triangle in range(2):
				var points: Array[Vector3] = []
				for corner in range(3):
					var uv := uvs[indices[cell * 6 + triangle * 3 + corner]]
					var p := (uv * Vector2(block.map_resolution) - Vector2.ONE * .5).clamp(Vector2.ZERO, Vector2(block.map_resolution - Vector2i.ONE))
					var a := Vector2i(p.floor())
					var b := (a + Vector2i.ONE).min(block.map_resolution - Vector2i.ONE)
					var f := p - Vector2(a)
					var image := block.working_map.image
					var h := image.get_pixel(a.x,a.y).r*(1-f.x)*(1-f.y)+image.get_pixel(b.x,a.y).r*f.x*(1-f.y)+image.get_pixel(a.x,b.y).r*(1-f.x)*f.y+image.get_pixel(b.x,b.y).r*f.x*f.y
					points.append(Vector3((uv.x-.5)*block.surface_size.x, block.base_height+(block.thickness-block.base_height)*h, (uv.y-.5)*block.surface_size.y))
				var hit: Variant = plane_oracle(origin,direction,points[0],points[1],points[2])
				if hit != null and origin.distance_squared_to(hit) < distance:
					nearest = hit
					distance = origin.distance_squared_to(nearest)
	return (nearest.y-block.base_height)/(block.thickness-block.base_height)

static func plane_oracle(o: Vector3, d: Vector3, a: Vector3, b: Vector3, c: Vector3) -> Variant:
	# Scalar float64 plane equation + Gram barycentrics. The native helper uses
	# float32 vectors; at these near-tangent rays it adds its own amplified error.
	var ex: float = float(b.x) - a.x
	var ey: float = float(b.y) - a.y
	var ez: float = float(b.z) - a.z
	var fx: float = float(c.x) - a.x
	var fy: float = float(c.y) - a.y
	var fz: float = float(c.z) - a.z
	var nx := ey * fz - ez * fy
	var ny := ez * fx - ex * fz
	var nz := ex * fy - ey * fx
	var denominator := nx * d.x + ny * d.y + nz * d.z
	if absf(denominator) < 1e-16: return null
	var t := (nx * (float(a.x) - o.x) + ny * (float(a.y) - o.y) + nz * (float(a.z) - o.z)) / denominator
	if t < 0: return null
	var px := float(o.x) + d.x * t - a.x
	var py := float(o.y) + d.y * t - a.y
	var pz := float(o.z) + d.z * t - a.z
	var ee := ex * ex + ey * ey + ez * ez
	var ff := fx * fx + fy * fy + fz * fz
	var ef := ex * fx + ey * fy + ez * fz
	var ep := ex * px + ey * py + ez * pz
	var fp := fx * px + fy * py + fz * pz
	var determinant := ee * ff - ef * ef
	if absf(determinant) < 1e-22: return null
	var u := (ff * ep - ef * fp) / determinant
	var v := (ee * fp - ef * ep) / determinant
	if u < -1e-8 or v < -1e-8 or u + v > 1.00000001: return null
	return Vector3(px + a.x, py + a.y, pz + a.z)
