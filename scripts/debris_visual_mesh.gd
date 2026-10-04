class_name DebrisVisualMesh
extends RefCounted
## Bake face values once into existing mesh colors. Geometry and motion unchanged.

static func with_face_contrast(source: Mesh) -> ArrayMesh:
	var arrays := source.surface_get_arrays(0)
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var colors := PackedColorArray()
	for normal in normals:
		var value := clampf(0.62 + 0.38 * maxf(normal.y, 0.0) + 0.10 * absf(normal.z)
			- 0.12 * maxf(-normal.y, 0.0), 0.50, 1.0)
		colors.append(Color(value, value, value, 1.0))
	arrays[Mesh.ARRAY_COLOR] = colors
	var result := ArrayMesh.new()
	result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return result
