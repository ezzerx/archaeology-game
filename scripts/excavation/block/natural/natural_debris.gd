extends TerrainDebris
## Use existing evacuation at the silhouette. A jittered 8x8 spawn bin may
## straddle the edge: keep its owner, place the crumb on its nearest solid cell.
func _inside(at: Vector3) -> bool:
	return super._inside(at) and relief.surface_domain.call(SurfaceMapping.local_to_uv(at,relief.dimensions))
func spawn(at: Vector3, velocity: Vector3, size: Vector3, layer: int, rotation: float, source := Vector3i.ZERO) -> int:
	if super._inside(at) and not _inside(at):
		var nearest := Vector2.ZERO
		var distance := INF
		var uv := SurfaceMapping.local_to_uv(at,relief.dimensions)
		for y in range(source.y*LooseDebris.STRIDE,(source.y+1)*LooseDebris.STRIDE):
			for x in range(source.x*LooseDebris.STRIDE,(source.x+1)*LooseDebris.STRIDE):
				var candidate := (Vector2(x,y)+Vector2.ONE*.5)/Vector2(map_size)
				if relief.surface_domain.call(candidate) and candidate.distance_squared_to(uv) < distance:
					distance = candidate.distance_squared_to(uv)
					nearest = candidate
		if distance == INF: return -1
		var plane := (nearest-Vector2.ONE*.5)*relief.dimensions
		at = Vector3(plane.x,relief.height_at(nearest)+size.length()*.5+profile.contact_skin,plane.y)
	return super.spawn(at,velocity,size,layer,rotation,source)
