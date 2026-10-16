extends RefCounted
const CENTRE := Vector2(496,305)
const BOUNDS := Rect2i(401,248,192,117)
var cells := PackedInt32Array()
var weights := PackedFloat32Array()
var noise_values := PackedFloat32Array()
func _init() -> void:
 var noise := FastNoiseLite.new()
 noise.seed = 64721
 noise.frequency = .13
 noise.fractal_type = FastNoiseLite.FRACTAL_NONE
 for y in range(BOUNDS.position.y,BOUNDS.end.y):
  for x in range(BOUNDS.position.x,BOUNDS.end.x):
   var p := Vector2(x,y)
   var v := (p-CENTRE)/Vector2(84,47)
   v.x += v.y*.22
   var theta := atan2(v.y,v.x)
   var n := noise.get_noise_2dv(p)
   var distance := v.length()/(1.0+.10*sin(theta*3)+.06*cos(theta*5))+.10*n
   if distance >= 1: continue
   cells.append(y*1024+x)
   weights.append(smoothstep(1.0,.64,distance))
   noise_values.append(n)
