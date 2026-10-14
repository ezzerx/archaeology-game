extends "res://scripts/p6a41/rough_profile.gd"
var layout: RefCounted
func _init(surface: WorkingSurface, shape: RefCounted, rim: RefCounted) -> void:
 super(surface,shape,rim)
 layout = preload("res://scripts/p6a43/slab_layout.gd").new()
 var polygon := PackedVector2Array(layout.POLYGON)
 for y in range(layout.BOUNDS.position.y,layout.BOUNDS.end.y):
  for x in range(layout.BOUNDS.position.x,layout.BOUNDS.end.x):
   var p := Vector2(x,y)
   var weight := 1.0 if Geometry2D.is_point_in_polygon(p,polygon) else 1.0-smoothstep(0,18,layout.border_distance(p))
   var i := y*1024+x
   limits[1][i*2+1] = lerpf(limits[1][i*2+1],limits[1][i*2],weight)
