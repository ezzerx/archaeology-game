extends RefCounted
## Authored alternatives are independent of Bone. No runtime random search.
const CENTRES := [Vector2(490,390),Vector2(510,215),Vector2(420,420)]
const DEPTHS := [.190,.195,.210]
var variant := 0
var centre := Vector2.ZERO
var bounds := Rect2i()
var cells := PackedInt32Array()
var weights := PackedFloat32Array()
var noise_values := PackedFloat32Array()
var cover := PackedFloat32Array()
func _init(index := 0) -> void:
 variant=posmod(index,CENTRES.size())
 centre=CENTRES[variant]
 bounds=Rect2i(Vector2i(centre)-Vector2i(86,56),Vector2i(173,113))
 var noise:=FastNoiseLite.new()
 noise.seed=64821+variant*17
 noise.frequency=.13
 noise.fractal_type=FastNoiseLite.FRACTAL_NONE
 for y in range(bounds.position.y,bounds.end.y):
  for x in range(bounds.position.x,bounds.end.x):
   var point:=Vector2(x,y)
   var v:Vector2=(point-centre)/Vector2(73,42)
   v.x+=v.y*.22
   var theta:=atan2(v.y,v.x)
   var n:=noise.get_noise_2dv(point)
   var distance:=v.length()/(1.0+.10*sin(theta*3)+.06*cos(theta*5))+.10*n
   if distance>=1:continue
   cells.append(y*1024+x)
   weights.append(smoothstep(1.0,.64,distance))
   noise_values.append(n)
   # The buried lens slopes inward: its position changes as excavation deepens.
   cover.append(DEPTHS[variant]+v.x*.030+v.y*.016+n*.010)
