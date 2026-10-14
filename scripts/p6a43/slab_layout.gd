extends RefCounted
## Authored matrix, never reads Bone. Coordinates are canonical 1024 x 640 texels.
const POLYGON := [Vector2(440,198),Vector2(462,172),Vector2(518,179),Vector2(554,165),Vector2(597,199),Vector2(591,238),Vector2(550,263),Vector2(491,252),Vector2(452,231)]
const CENTRE := Vector2(520,216)
const BOUNDS := Rect2i(420,145,198,139)
var cells := PackedInt32Array()
var distances := {}
var lines: Array[PackedVector2Array] = []
func _init() -> void:
 var boundary := PackedVector2Array(POLYGON)
 boundary.append(POLYGON[0])
 lines.append(boundary)
 lines.append(PackedVector2Array([Vector2(451,218),Vector2(475,202),Vector2(508,220),Vector2(536,202),Vector2(567,214),Vector2(594,218)]))
 lines.append(PackedVector2Array([Vector2(508,220),Vector2(525,240),Vector2(550,263)]))
 # Jagged geological joints, preserving authored intersections and endpoints.
 for line_id in range(lines.size()):
  var source: PackedVector2Array = lines[line_id]
  var jagged := PackedVector2Array()
  for n in range(source.size()-1):
   var a: Vector2 = source[n]
   var b: Vector2 = source[n+1]
   var count := maxi(2,ceili(a.distance_to(b)/6.0))
   for step in range(count):
    var t := float(step)/count
    var side := (b-a).orthogonal().normalized()
    var wave := sin(t*PI)*(1.1*sin(step*2.3+n*.8+line_id)+.7*sin(step*4.7))
    jagged.append(a.lerp(b,t)+side*wave)
  jagged.append(source[-1])
  lines[line_id] = jagged
 for y in range(BOUNDS.position.y,BOUNDS.end.y):
  for x in range(BOUNDS.position.x,BOUNDS.end.x):
   var p := Vector2(x,y)
   var i := y*1024+x
   if Geometry2D.is_point_in_polygon(p,PackedVector2Array(POLYGON)): cells.append(i)
   var d := crack_distance(p)
   if d < 7: distances[i] = d
func crack_distance(p: Vector2) -> float:
 var d := INF
 for line in lines:
  for n in range(line.size()-1):
   d = minf(d,p.distance_to(Geometry2D.get_closest_point_to_segment(p,line[n],line[n+1])))
 return d
func border_distance(p: Vector2) -> float:
 var d := INF
 for n in range(POLYGON.size()):
  d = minf(d,p.distance_to(Geometry2D.get_closest_point_to_segment(p,POLYGON[n],POLYGON[(n+1)%POLYGON.size()])))
 return d
