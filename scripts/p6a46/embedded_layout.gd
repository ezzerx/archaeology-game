extends RefCounted
## One authored specimen layout. Shape, cover and stress never query Bone.
const CENTRE := Vector2(520,216)
const BOUNDS := Rect2i(402,126,234,178)
const ANCHORS := [Vector2(440,198),Vector2(462,172),Vector2(518,179),Vector2(554,165),Vector2(597,199),Vector2(591,238),Vector2(550,263),Vector2(491,252),Vector2(452,231)]
var POLYGON := PackedVector2Array()
var cells := PackedInt32Array()
var distances := {}
var lines: Array[PackedVector2Array] = []
# Authored fracture planes: irregularly spaced seeds, independent of anatomy.
var volume_points := PackedVector2Array(ANCHORS+[Vector2(473,202),Vector2(493,223),Vector2(522,202),Vector2(548,226),Vector2(522,247),Vector2(574,208)])
var volume_depths := PackedFloat32Array([9,8,7,6,9,10,7,8,9,27,35,16,32,23,19])
var volume_triangles := PackedInt32Array()
func _init() -> void:
 volume_triangles = Geometry2D.triangulate_delaunay(volume_points)
 for n in range(ANCHORS.size()):
  var a: Vector2 = ANCHORS[n]
  var b: Vector2 = ANCHORS[(n+1)%ANCHORS.size()]
  var count := maxi(3,ceili(a.distance_to(b)/5.0))
  for step in range(count):
   var t := float(step)/count
   var wear := sin(t*PI)*(2.4*sin(step*1.4+n*.7)+1.2*sin(step*3.1))
   POLYGON.append(a.lerp(b,t)+(b-a).orthogonal().normalized()*wear)
 # Sparse boundary joints: no continuous drawn perimeter around the whole slab.
 lines.append(curved(PackedVector2Array([Vector2(449,216),Vector2(475,202),Vector2(508,220),Vector2(536,202),Vector2(568,214),Vector2(594,218)])))
 lines.append(curved(PackedVector2Array([Vector2(508,220),Vector2(525,240),Vector2(548,262)])))
 lines.append(curved(PackedVector2Array([Vector2(493,180),Vector2(510,190),Vector2(508,220)])))
 lines.append(curved(PackedVector2Array([Vector2(553,166),Vector2(576,181),Vector2(597,199)])))
 lines.append(PackedVector2Array([Vector2(486,210),Vector2(482,218),Vector2(484,224)]))
 lines.append(PackedVector2Array([Vector2(539,251),Vector2(547,248),Vector2(551,250)]))
 for y in range(BOUNDS.position.y,BOUNDS.end.y):
  for x in range(BOUNDS.position.x,BOUNDS.end.x):
   var p := Vector2(x,y)
   var i := y*1024+x
   if Geometry2D.is_point_in_polygon(p,POLYGON): cells.append(i)
   var d := crack_distance(p)
   if d < 7: distances[i] = d
func curved(knots: PackedVector2Array) -> PackedVector2Array:
 # Broken rock follows angular facets; original knots remain working landmarks.
 var result := PackedVector2Array()
 for n in range(knots.size()-1):
  var a := knots[n]
  var b := knots[n+1]
  var count := maxi(3,ceili(a.distance_to(b)/8.0))
  for step in range(count):
   var t := float(step)/count
   var tooth := sin(t*PI)*(4.1*sin(step*4.13+n*2.71)+1.8*sin(step*1.93+n))
   result.append(a.lerp(b,t)+(b-a).orthogonal().normalized()*tooth)
 result.append(knots[-1])
 return result
func width_at(p: Vector2) -> float:
 return .7+.75*(.5+.5*sin(p.x*.29+p.y*.13))+.5*(.5+.5*sin(p.x*.71-p.y*.47))
func depth_at(p: Vector2) -> float:
 return .65+.6*(.5+.5*sin(p.x*.23-p.y*.31))
func crack_distance(p: Vector2) -> float:
 var d := INF
 for line in lines:
  for n in range(line.size()-1): d = minf(d,p.distance_to(Geometry2D.get_closest_point_to_segment(p,line[n],line[n+1])))
 return d
func border_distance(p: Vector2) -> float:
 var d := INF
 for n in range(POLYGON.size()): d = minf(d,p.distance_to(Geometry2D.get_closest_point_to_segment(p,POLYGON[n],POLYGON[(n+1)%POLYGON.size()])))
 return d
func cover_mm(p: Vector2) -> float:
 var north := 1.0-smoothstep(178,206,p.y+6*sin(p.x*.06))
 var east := smoothstep(566,598,p.x+8*sin(p.y*.07))
 var q := (p-Vector2(454,242))/Vector2(37,25)
 var southwest := exp(-q.length_squared())*.95
 var base := 3.0*smoothstep(.22,.86,maxf(maxf(north,east),southwest))
 var patches := .55*sin(p.x*.27+p.y*.11)+.30*sin(p.x*.63-p.y*.39)+.15*sin(p.x*.13-p.y*.41)
 var cover := maxf(0,base+smoothstep(0,.5,base)*.85*patches-.20)
 # Separate erosion windows reveal the same bed through the Clay coating.
 for window: Vector2 in [Vector2(476,185),Vector2(560,178),Vector2(585,222)]:
  var offset := (p-window)/Vector2(7,5)
  cover -= 3.6*exp(-offset.length_squared())
 return maxf(0,cover)
func relief_mm(p: Vector2) -> float:
 # Low folded bedding and erosion, not a uniformly extruded flat badge.
 return 1.2*sin((p.x-440)*.018+(p.y-190)*.026)+.45*sin(p.x*.093-p.y*.051)

func clay_fold_mm(p: Vector2, cover: float, distance: float) -> float:
 # Broad, shallow deformation of Clay itself, attenuated by true cover thickness.
 if cover <= 0: return 0
 return maxf(-cover*.75,-.65*exp(-cover/1.8)*(1.0-smoothstep(1,7,distance))*(.65+.35*sin(p.x*.21+p.y*.09)))
func thickness_mm(p: Vector2) -> float:
 for n in range(0,volume_triangles.size(),3):
  var ia := volume_triangles[n]
  var ib := volume_triangles[n+1]
  var ic := volume_triangles[n+2]
  var a := volume_points[ia]
  var u := volume_points[ib]-a
  var v := volume_points[ic]-a
  var q := p-a
  var denominator := u.cross(v)
  var b := q.cross(v)/denominator
  var c := u.cross(q)/denominator
  if b >= -.00001 and c >= -.00001 and b+c <= 1.00001:
   return volume_depths[ia]+(volume_depths[ib]-volume_depths[ia])*b+(volume_depths[ic]-volume_depths[ia])*c
 return 7.0
