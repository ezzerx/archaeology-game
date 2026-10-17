extends "res://scripts/experiments/preparation_demos/demo_profile.gd"
## A shallow entrance, deeper sediment reaches and discontinuous firm banks.
## Geological heights depend on space/noise only; adherent nodules use the solid.
const BANKS := [
 [Vector2(434,391),Vector2(57,53),-.30],
 [Vector2(556,291),Vector2(64,39),.48],
 [Vector2(603,426),Vector2(53,47),-.42]
]
var grain_ease:=PackedFloat32Array()
var deep_roofs:=PackedFloat32Array()
var deep_floors:=PackedFloat32Array()
var deep_geology:ImageTexture
var entry:=Vector2(409,292)
var encounters:=[
 {"name":"Ouverture proche", "center":Vector2(410,292)},
 {"name":"Banc et chenal profond", "center":Vector2(551,294)},
 {"name":"Dépôts des côtes profondes", "center":Vector2(582,414)}
]
func _init(surface:WorkingSurface,shape:RefCounted,rim:RefCounted) -> void:
 super(surface,shape,rim,1)
 var fine:=FastNoiseLite.new();fine.seed=41037;fine.frequency=.095
 var broad:=FastNoiseLite.new();broad.seed=41011;broad.frequency=.018
 var data:=PackedFloat32Array();data.resize(size.x*size.y*4)
 var coat:=PackedFloat32Array();coat.resize(size.x*size.y*4)
 grain_ease.resize(size.x*size.y)
 deep_roofs.resize(size.x*size.y);deep_floors.resize(size.x*size.y)
 var deep_data:=PackedFloat32Array();deep_data.resize(size.x*size.y*4)
 for y in range(size.y):
  for x in range(size.x):
   var i:=y*size.x+x
   grain_roofs[i]=0;grain_floors[i]=0
   var p:=Vector2(x,y)
   var old_top:=fragmented_top[i]
   if old_top<=.30:continue
   var n:=broad.get_noise_2dv(p);var d:=fine.get_noise_2dv(p)
   # Wide natural dome, independent of the enlarged/inclined shell below.
   var uplift:=.12*(1.0-smoothstep(.62,1.05,((p-Vector2(515,350))/Vector2(215,185)).length()))
   fragmented_top[i]+=uplift
   for f in range(limits.size()):
    limits[f][i*2]+=uplift;substrates[f][i]+=uplift;thin_tops[f][i]+=uplift
   var top:=fragmented_top[i]
   var bank:=0.0
   for form in BANKS:
    var q:Vector2=(p-form[0]).rotated(-form[2])/form[1]
    bank=maxf(bank,1.0-smoothstep(.35,1.14,q.length()+d*.24+n*.16))
   # The eastern bed lies deeper: the jet cannot open it through intact matrix.
   var descent:=smoothstep(435,605,p.x+n*32+d*8)
   var cover:=.014+.006*(n+.5)
   var roof:=top-cover
   var basin:=1.0-smoothstep(.25,1.1,((p-Vector2(565,399))/Vector2(102,71)).length())
   var floor_height:=.20+.045*n+.012*d-basin*.10
   var bank_top:=roof-(.050+.018*(n+.5)+descent*.14)
   floor_height=maxf(floor_height,lerpf(floor_height,bank_top,pow(bank,.72)))
   # Buried sediment lens under a firm roof, distinct from the upper loose cover.
   var lens:=smoothstep(442,477,p.x+n*22)*(1.0-smoothstep(.68,1.1,((p-Vector2(555,358))/Vector2(116,128)).length()))
   var lower_roof:=top-(.115+descent*.105+n*.015)
   if lens>.10 and lower_roof>floor_height+.045:
    deep_roofs[i]=lower_roof;deep_floors[i]=floor_height
    var lid:=.019+.045*bank+.009*(d+.5)
    floor_height=lerpf(floor_height,lower_roof+lid,smoothstep(.10,.75,lens))
    # Thin feathered margins merge into the upper reach, without a hidden wall.
    if floor_height<=lower_roof+.006:
     deep_roofs[i]=0;deep_floors[i]=0
    else:
     deep_data[i*4]=lower_roof;deep_data[i*4+1]=deep_floors[i];deep_data[i*4+2]=1-bank;deep_data[i*4+3]=lid
   grain_ease[i]=1.0+d*.55+n*.20
   grain_roofs[i]=roof;grain_floors[i]=minf(floor_height,roof-.012)
   data[i*4]=roof;data[i*4+1]=grain_floors[i];data[i*4+2]=1.0-bank;data[i*4+3]=cover
   var bone:=surface.structural_ceilings[i]
   if bone<=0:continue
   # One broken cluster fills local intercostal troughs, revealed only on excavation.
   var distance:=((p-Vector2(582,414)).rotated(-.55)/Vector2(31,24)).length()
   var cluster:=0.0
   for lobe in [[Vector2(564,403),Vector2(13,10)],[Vector2(582,414),Vector2(15,13)],[Vector2(598,429),Vector2(11,9)]]:
    var q:Vector2=(p-lobe[0]).rotated(-.55)/lobe[1]
    cluster=maxf(cluster,1.0-smoothstep(.30,1.05,q.length()+d*.34))
   var weight:float=cluster*(1.0-smoothstep(.75,1.15,distance+n*.15))
   if weight<.045:continue
   var crown:=bone
   for offset in [-4,4,-size.x*4,size.x*4]:crown=maxf(crown,surface.structural_ceilings[i+offset])
   var thickness:=.003+weight*(.020+.020*smoothstep(-.25,.35,d))+(crown-bone)*weight*.50
   var cap:=minf(bone+thickness,top-.045)
   if cap<=bone+.001:continue
   crust_caps[i]=cap
   coat[i*4]=bone;coat[i*4+1]=cap;coat[i*4+2]=2
 geology=ImageTexture.create_from_image(Image.create_from_data(size.x,size.y,false,Image.FORMAT_RGBAF,data.to_byte_array()))
 deep_geology=ImageTexture.create_from_image(Image.create_from_data(size.x,size.y,false,Image.FORMAT_RGBAF,deep_data.to_byte_array()))
 crust=ImageTexture.create_from_image(Image.create_from_data(size.x,size.y,false,Image.FORMAT_RGBAF,coat.to_byte_array()))
func apply(block:ExcavationBlock,candidate:int,fixture:int,cleared:bool) -> void:
 super.apply(block,candidate,fixture,cleared)
 block.working_map.marine_grain_ease=grain_ease
 block.working_map.deep_grain_roofs=deep_roofs;block.working_map.deep_grain_floors=deep_floors
