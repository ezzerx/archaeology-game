extends "res://scripts/p6a41/rough_profile.gd"
var layout: RefCounted
var covered_cells := 0
var exposed_cells := 0
var groove_cells := 0
var folds_image: Image
var folds_texture: ImageTexture
func _init(surface: WorkingSurface, shape: RefCounted, rim: RefCounted) -> void:
 super(surface,shape,rim)
 layout = preload("res://scripts/p6a46/embedded_layout.gd").new()
 folds_image = Image.create(1024,640,false,Image.FORMAT_RGF)
 var mm := surface.excavatable_depth*1000.0
 for y in range(layout.BOUNDS.position.y,layout.BOUNDS.end.y):
  for x in range(layout.BOUNDS.position.x,layout.BOUNDS.end.x):
   var p := Vector2(x,y)
   var i := y*1024+x
   var inside := Geometry2D.is_point_in_polygon(p,layout.POLYGON)
   var weight := 1.0 if inside else 1.0-smoothstep(0,18,layout.border_distance(p))
   if weight <= 0: continue
   var old_upper: float = limits[1][i*2]
   var old_lower: float = limits[1][i*2+1]
   var ridge: float = layout.relief_mm(p)*weight/mm
   var cover: float = layout.cover_mm(p)*weight/mm
   var d: float = layout.distances.get(i,7.0)
   var width: float = layout.width_at(p)
   var groove: float = layout.depth_at(p)*(1.0-smoothstep(.18,width,d))*weight/mm
   var stone_top := old_upper+ridge-groove
   # Clay fills buried seams instead of reproducing their outline on its top.
   var top_groove := groove*(1.0-smoothstep(0,.5/mm,cover))
   var fold: float = layout.clay_fold_mm(p,cover*mm,d)*weight/mm
   var upper := old_upper+ridge+cover-top_groove+fold
   if fold < 0: folds_image.set_pixel(x,y,Color(clampf(-fold*mm/.55,0,1),upper,0,1))
   limits[1][i*2] = upper
   limits[1][i*2+1] = lerpf(old_lower,stone_top,weight)
   var delta := upper-old_upper
   substrates[1][i] += delta
   thin_tops[1][i] += delta
   fragmented_top[i] += delta
   if inside:
    if cover*mm > .1: covered_cells += 1
    else: exposed_cells += 1
    if groove*mm > .1: groove_cells += 1

 folds_texture = ImageTexture.create_from_image(folds_image)
