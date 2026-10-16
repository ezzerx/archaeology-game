extends "res://scripts/collection/specimen_profile.gd"
var kind:=0
var geology:ImageTexture
var crust:ImageTexture
var grain_roofs:=PackedFloat32Array()
var grain_floors:=PackedFloat32Array()
var crust_caps:=PackedFloat32Array()
func _init(surface:WorkingSurface,shape:RefCounted,rim:RefCounted,mode:int) -> void:
 kind=mode
 super(surface,shape,rim)
 var count:=size.x*size.y
 grain_roofs.resize(count);grain_floors.resize(count);crust_caps.resize(count)
 var geo:=PackedFloat32Array();geo.resize(count*4)
 var coat:=PackedFloat32Array();coat.resize(count*2)
 var broad:=FastNoiseLite.new();broad.seed=33017;broad.frequency=.012
 var detail:=FastNoiseLite.new();detail.seed=33089;detail.frequency=.09
 for y in range(size.y):
  for x in range(size.x):
   var i:=y*size.x+x
   if fragmented_top[i]<=0:continue
   var n:=broad.get_noise_2d(x,y)
   var d:=detail.get_noise_2d(x,y)
   # Spatial geological bands, independent of anatomy. No universal flat sandwich.
   if kind==0:
    var bank:=smoothstep(-.08,.24,n+.18*sin(x*.016+y*.025))
    for f in range(limits.size()):
     limits[f][i*2+1]=lerpf(.08,substrates[f][i]-.028,bank)
    continue
   var top:=substrates[1][i]
   var grain_weight:=1.0-smoothstep(.14,.28,n+.11*sin(x*.023-y*.037))
   if kind==2:grain_weight=1.0
   # Roof and irregular sediment floor ignore fossil shape. Collision is resolved only on removal.
   if grain_weight>.25 and top>.30:
    grain_roofs[i]=top-(.032 if kind==1 else .022)-.010*d
    grain_floors[i]=.10+.045*n+.014*d
    geo[i*4]=grain_roofs[i];geo[i*4+1]=grain_floors[i];geo[i*4+2]=grain_weight
   for f in range(limits.size()):limits[f][i*2+1]=.08
   if kind==2 and surface.structural_ceilings[i]>0:
    # Three localized nodules. They may adhere to the actual solid but never deform the buried roof.
    var a:=((Vector2(x,y)-Vector2(467,301))/Vector2(28,22)).length()
    var b:=((Vector2(x,y)-Vector2(553,359))/Vector2(30,21)).length()
    var c:=((Vector2(x,y)-Vector2(489,392))/Vector2(20,18)).length()
    var weight:=1.0-smoothstep(.60,1.0,minf(a,minf(b,c))+d*.32)
    if weight>.06:
     var bone:=surface.structural_ceilings[i]
     crust_caps[i]=bone+.010+weight*(.035+.018*d+.006*sin(x*.7+y*.36))
     coat[i*2]=bone;coat[i*2+1]=crust_caps[i]
 var geo_image:=Image.create_from_data(size.x,size.y,false,Image.FORMAT_RGBAF,geo.to_byte_array())
 geology=ImageTexture.create_from_image(geo_image)
 crust=ImageTexture.create_from_image(Image.create_from_data(size.x,size.y,false,Image.FORMAT_RGF,coat.to_byte_array()))
 if kind!=0:layout.present=false;layout.cells=PackedInt32Array()
func apply(block:ExcavationBlock,candidate:int,fixture:int,cleared:bool) -> void:
 super.apply(block,candidate,fixture,cleared)
 block.working_map.configure_demo(grain_roofs,grain_floors,crust_caps)
