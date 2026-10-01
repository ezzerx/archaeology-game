class_name ReliefSurface
extends RefCounted
## CPU counterpart of the displaced PlaneMesh, including its triangle diagonal.
## No collision rebuild: ordered 2D DDA visits only cells crossed by the ray.

var image: Image
var dimensions: Vector2
var cells: Vector2i
var floor_height: float
var top_height: float

func _init(height_image: Image, surface_size: Vector2, grid_cells: Vector2i,
		minimum_y: float, maximum_y: float) -> void:
	image = height_image
	dimensions = surface_size
	cells = grid_cells
	floor_height = minimum_y
	top_height = maximum_y

static func sample_image(source: Image, uv: Vector2) -> Color:
	# Match filter_linear, repeat_disable and the P0 texel-centre convention.
	var last := source.get_size() - Vector2i.ONE
	var point := (uv * Vector2(source.get_size()) - Vector2(0.5, 0.5)).clamp(Vector2.ZERO, Vector2(last))
	var low := Vector2i(point.floor())
	var high := (low + Vector2i.ONE).min(last)
	var blend := point - Vector2(low)
	return source.get_pixel(low.x, low.y).lerp(source.get_pixel(high.x, low.y), blend.x).lerp(
		source.get_pixel(low.x, high.y).lerp(source.get_pixel(high.x, high.y), blend.x), blend.y)

func vertex_at(grid: Vector2i) -> Vector3:
	var uv := Vector2(grid) / Vector2(cells)
	var height := sample_image(image, uv).r
	return Vector3((uv.x - 0.5) * dimensions.x,
		lerpf(floor_height, top_height, height), (uv.y - 0.5) * dimensions.y)

func height_at(uv: Vector2) -> float:
	var point := uv.clamp(Vector2.ZERO, Vector2.ONE) * Vector2(cells)
	var cell := Vector2i(point.floor()).min(cells - Vector2i.ONE)
	var fraction := point - Vector2(cell)
	var a := vertex_at(cell).y
	var b := vertex_at(cell + Vector2i(1, 0)).y
	var c := vertex_at(cell + Vector2i(0, 1)).y
	var d := vertex_at(cell + Vector2i.ONE).y
	if fraction.x + fraction.y <= 1.0:
		return a + (b - a) * fraction.x + (c - a) * fraction.y
	return d + (c - d) * (1.0 - fraction.x) + (b - d) * (1.0 - fraction.y)

func normalized_height_at(uv: Vector2) -> float:
	return clampf((height_at(uv) - floor_height) / (top_height - floor_height), 0.0, 1.0)

static func intersect_triangle(origin: Vector3, direction: Vector3, a: Vector3, b: Vector3, c: Vector3) -> Variant:
	# Godot's general ray helper has an absolute epsilon larger than these mm²
	# triangles. Moller-Trumbore with a scale-relative parallel tolerance instead.
	var edge_b := b - a
	var edge_c := c - a
	var cross_direction := direction.cross(edge_c)
	var determinant := edge_b.dot(cross_direction)
	if absf(determinant) <= edge_b.length() * cross_direction.length() * 0.0000001:
		return null
	var inverse := 1.0 / determinant
	var offset := origin - a
	var u := offset.dot(cross_direction) * inverse
	if u < -0.0001 or u > 1.0001:
		return null
	var cross_offset := offset.cross(edge_b)
	var v := direction.dot(cross_offset) * inverse
	if v < -0.0001 or u + v > 1.0001:
		return null
	var t := edge_c.dot(cross_offset) * inverse
	return origin + direction * t if t >= 0.0 else null

func ray_hit(origin: Vector3, direction: Vector3, far_distance: float) -> Dictionary:
	var bounds_min := Vector3(-dimensions.x * 0.5, floor_height, -dimensions.y * 0.5)
	var bounds_max := Vector3(dimensions.x * 0.5, top_height, dimensions.y * 0.5)
	var enter := 0.0
	var leave := far_distance
	for axis in range(3):
		if absf(direction[axis]) < 0.00000001:
			if origin[axis] < bounds_min[axis] or origin[axis] > bounds_max[axis]:
				return {}
		else:
			var first := (bounds_min[axis] - origin[axis]) / direction[axis]
			var last := (bounds_max[axis] - origin[axis]) / direction[axis]
			enter = maxf(enter, minf(first, last))
			leave = minf(leave, maxf(first, last))
	if leave < enter:
		return {}
	var entry_point := origin + direction * enter
	var uv := SurfaceMapping.local_to_uv(entry_point, dimensions).clamp(Vector2.ZERO, Vector2.ONE)
	# The skirt occludes any top behind it. Do not paint through a solid side.
	if entry_point.y < height_at(uv) - 0.000005:
		return {}
	var grid := uv * Vector2(cells)
	var velocity := Vector2(direction.x / dimensions.x, direction.z / dimensions.y) * Vector2(cells)
	var cell := Vector2i((grid + velocity * 0.0000001).floor()).clamp(Vector2i.ZERO, cells - Vector2i.ONE)
	var step := Vector2i(signf(velocity.x), signf(velocity.y))
	var next := Vector2(INF, INF)
	var increment := Vector2(INF, INF)
	for axis in range(2):
		if step[axis] != 0:
			var boundary := cell[axis] + (1 if step[axis] > 0 else 0)
			next[axis] = enter + (boundary - grid[axis]) / velocity[axis]
			increment[axis] = absf(1.0 / velocity[axis])
	for visited in range(cells.x + cells.y + 2):
		var end := minf(leave, minf(next.x, next.y))
		var a := vertex_at(cell)
		var b := vertex_at(cell + Vector2i(1, 0))
		var c := vertex_at(cell + Vector2i(0, 1))
		var d := vertex_at(cell + Vector2i.ONE)
		var best: Dictionary = {}
		var best_t := INF
		for triangle in [[a, b, c], [d, c, b]]:
			var intersection: Variant = intersect_triangle(origin, direction, triangle[0], triangle[1], triangle[2])
			if intersection == null:
				continue
			var point: Vector3 = intersection
			var t := (point - origin).dot(direction) / direction.length_squared()
			if t >= enter - 0.000005 and t <= end + 0.000005 and t < best_t:
				var normal: Vector3 = (triangle[2] - triangle[0]).cross(triangle[1] - triangle[0]).normalized()
				best = {"local": point, "local_normal": normal, "visited_cells": visited + 1}
				best_t = t
		if not best.is_empty():
			return best
		if end >= leave:
			break
		var cross_x := next.x <= next.y
		var cross_y := next.y <= next.x
		if cross_x:
			cell.x += step.x
			next.x += increment.x
		if cross_y:
			cell.y += step.y
			next.y += increment.y
		if cell.x < 0 or cell.y < 0 or cell.x >= cells.x or cell.y >= cells.y:
			break
		enter = end
	return {}

func create_skirt() -> ArrayMesh:
	var vertices := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	for side in range(4):
		var count := cells.x if side % 2 == 0 else cells.y
		var start := vertices.size()
		for i in range(count + 1):
			var t := float(i) / count
			var uv: Vector2
			match side:
				0: uv = Vector2(t, 0.0)
				1: uv = Vector2(1.0, t)
				2: uv = Vector2(1.0 - t, 1.0)
				3: uv = Vector2(0.0, 1.0 - t)
			for top in range(2):
				vertices.append(Vector3((uv.x - 0.5) * dimensions.x, float(top), (uv.y - 0.5) * dimensions.y))
				uvs.append(uv)
			if i < count:
				var base := start + i * 2
				indices.append_array(PackedInt32Array([base, base + 2, base + 1, base + 1, base + 2, base + 3]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh
