extends "res://scripts/p6a36/production_mesh_view.gd"
## Cache the immutable triangle pattern once, then copy consecutive exposed runs
## in native PackedArray operations. Never submit a buried cell, even transiently.
var roof_indices := PackedInt32Array()
func _source_scene() -> PackedScene:
	return preload("res://assets/p6a37/b17_skeleton.glb")
func _cache_roofs() -> void:
	super._cache_roofs()
	roof_indices.resize(pilot_cells.size()*6)
	for n in range(pilot_cells.size()):
		var v := n*4
		var j := n*6
		roof_indices[j] = v
		roof_indices[j+1] = v+1
		roof_indices[j+2] = v+2
		roof_indices[j+3] = v
		roof_indices[j+4] = v+2
		roof_indices[j+5] = v+3
func rebuild_shadows() -> void:
	var began := Time.get_ticks_usec()
	var s: WorkingSurface = block.working_map
	var field: FossilField = s.fossil.field
	caster_cells.clear()
	var indices := PackedInt32Array()
	var run_start := -1
	for n in range(pilot_cells.size()):
		var i := pilot_cells[n]
		var exposed: bool = s.fossil.exposed[i] != 0 and s._heights[i] <= field.ceilings[i]+FossilField.EXPOSURE_EPSILON
		if exposed:
			caster_cells.append(i)
			if run_start < 0: run_start = n
		elif run_start >= 0:
			indices.append_array(roof_indices.slice(run_start*6,n*6))
			run_start = -1
	if run_start >= 0: indices.append_array(roof_indices.slice(run_start*6))
	shadow_caster.mesh = null
	if not indices.is_empty():
		var arrays := []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = roof_vertices
		arrays[Mesh.ARRAY_INDEX] = indices
		var mesh := ArrayMesh.new()
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
		shadow_caster.mesh = mesh
	shadow_dirty = false
	last_shadow_build_usec = Time.get_ticks_usec()-began
	max_shadow_build_usec = maxi(max_shadow_build_usec,last_shadow_build_usec)
	shadow_rebuild_count += 1
