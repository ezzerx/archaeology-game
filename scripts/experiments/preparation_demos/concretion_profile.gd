extends "res://scripts/experiments/preparation_demos/demo_profile.gd"
## Three authored encounters. Only the adherent layer follows the solid;
## the intact geological cover never depends on this layer.
var encounter_ids := PackedByteArray()
var encounters := [
 {"name":"Voile mince", "center":Vector2(467,301), "from":Vector2(452,295), "to":Vector2(478,310)},
 {"name":"Amas entre les côtes", "center":Vector2(553,359), "from":Vector2(544,347), "to":Vector2(564,369)},
 {"name":"Traînée courbe", "center":Vector2(494,402), "from":Vector2(475,388), "to":Vector2(520,414)}
]

func _init(surface:WorkingSurface,shape:RefCounted,rim:RefCounted) -> void:
 super(surface,shape,rim,2)
 var count := size.x*size.y
 crust_caps.fill(0)
 encounter_ids.resize(count)
 var coat := PackedFloat32Array()
 coat.resize(count*4)
 var rough := FastNoiseLite.new()
 rough.seed=39017;rough.frequency=.105
 var growth := FastNoiseLite.new()
 growth.seed=39049;growth.frequency=.21
 for y in range(268,437):
  for x in range(430,590):
   var i := y*size.x+x
   var bone := surface.structural_ceilings[i]
   if bone<=0: continue
   var p := Vector2(x,y)
   var n := rough.get_noise_2d(x,y)
   var g := growth.get_noise_2d(x,y)
   var thin := ((p-Vector2(467,301)).rotated(-.45)/Vector2(25,17)).length()
   var lump := ((p-Vector2(553,359)).rotated(.35)/Vector2(23,20)).length()
   var trail := 100.0
   # Bent run on the outer whorl, with varying width and scalloped margins.
   var points := [Vector2(474,387),Vector2(484,400),Vector2(500,411),Vector2(520,415)]
   for k in range(points.size()-1):
    var a:Vector2=points[k];var b:Vector2=points[k+1]
    var t:=clampf((p-a).dot(b-a)/a.distance_squared_to(b),0,1)
    trail=minf(trail,p.distance_to(a.lerp(b,t))/(9.0+2.0*sin(t*PI+k)))
   var shapes := [thin,lump,trail]
   var zone := 0
   var best := 0.0
   for k in range(3):
    var weight := 1.0-smoothstep(.46,1.04,shapes[k]+n*.28+g*.12)
    if weight>best: best=weight;zone=k+1
   if best<.045: continue
   # The broad lumps fill shallow rib valleys but keep tall ribs readable.
   var crown := bone
   if zone!=1:
    for offset in [Vector2i(-4,0),Vector2i(4,0),Vector2i(0,-4),Vector2i(0,4)]:
     var j: int=(y+offset.y)*size.x+x+offset.x
     crown=maxf(crown,surface.structural_ceilings[j])
   var nodule := smoothstep(-.28,.42,n)
   var thickness := .002+best*(.013+.012*nodule)
   if zone==2:
    var lobes:=0.0
    for center in [Vector2(546,351),Vector2(558,353),Vector2(552,365),Vector2(565,366)]:
     var distance:float=((p-center)/Vector2(9,7)).length()
     lobes=maxf(lobes,exp(-distance*distance*1.6))
    thickness=.004+best*(.020+.052*lobes+.012*nodule)+(crown-bone)*best*.65
   if zone==3: thickness=.002+best*(.016+.025*nodule+.006*g)+(crown-bone)*best*.36
   var cap := minf(bone+thickness,fragmented_top[i]-.04)
   if cap<=bone+.001: continue
   crust_caps[i]=cap
   encounter_ids[i]=zone
   coat[i*4]=bone;coat[i*4+1]=cap;coat[i*4+2]=float(zone)
 crust=ImageTexture.create_from_image(Image.create_from_data(size.x,size.y,false,Image.FORMAT_RGBAF,coat.to_byte_array()))
