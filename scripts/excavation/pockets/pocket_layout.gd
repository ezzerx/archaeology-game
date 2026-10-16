extends RefCounted
var seed_value:=0
var resolution:=Vector2i(1024,640)
var present:=false
var attempts:=0
var covered_bone:=0
var centre:=Vector2.ZERO
var bounds:=Rect2i()
var axes:=Vector2.ZERO
var angle:=0.0
var cells:=PackedInt32Array()
var weights:=PackedFloat32Array()
var noise_values:=PackedFloat32Array()
var cover:=PackedFloat32Array()
var depth:=PackedFloat32Array()
var roofs:=PackedFloat32Array()
var floors:=PackedFloat32Array()
func clear_shape() -> void:
 present=false
 cells.clear();weights.clear();noise_values.clear();cover.clear();depth.clear()
 roofs.resize(resolution.x*resolution.y);roofs.fill(0)
 floors.resize(roofs.size());floors.fill(0)
 bounds=Rect2i();centre=Vector2.ZERO
func sample(recipe:FriablePocketRecipe,random:RandomNumberGenerator) -> void:
 clear_shape()
 var envelope:Rect2=recipe.envelopes[random.randi_range(0,recipe.envelopes.size()-1)]
 centre=(envelope.position+envelope.size*Vector2(random.randf(),random.randf()))*Vector2(resolution)
 axes=recipe.axes_min.lerp(recipe.axes_max,random.randf())*Vector2(resolution)/Vector2(1024,640)
 angle=random.randf_range(-.55,.55)
 var extent:=ceili(axes.length()*1.25)
 bounds=Rect2i(Vector2i(centre)-Vector2i.ONE*extent,Vector2i.ONE*(extent*2+1)).intersection(Rect2i(Vector2i.ZERO,resolution))
 var cover_base:float=random.randf_range(recipe.cover_range.x,recipe.cover_range.y)
 var depth_base:float=random.randf_range(recipe.depth_range.x,recipe.depth_range.y)
 var noise:=FastNoiseLite.new()
 noise.seed=random.randi_range(1,999999)
 noise.frequency=.13
 noise.fractal_type=FastNoiseLite.FRACTAL_NONE
 for y in range(bounds.position.y,bounds.end.y):
  for x in range(bounds.position.x,bounds.end.x):
   var point:=Vector2(x,y)
   var v:Vector2=(point-centre).rotated(-angle)/axes
   v.x+=v.y*.18
   var theta:=atan2(v.y,v.x)
   var n:=noise.get_noise_2dv(point)
   var distance:=v.length()/(1.0+.10*sin(theta*3+angle)+.065*cos(theta*5))+.09*n
   if distance>=1:continue
   var weight:=smoothstep(1.0,.67,distance)
   cells.append(y*resolution.x+x)
   weights.append(weight);noise_values.append(n)
   cover.append(cover_base+v.x*.022+v.y*.012+n*.008)
   depth.append(.028+depth_base*weight+n*.012+.006*sin(x*.09+y*.07))
