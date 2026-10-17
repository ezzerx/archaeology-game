extends "res://scripts/experiments/preparation_demos/demo_profile.gd"
## A connected granular cover above discontinuous consolidated banks.
## Every field is built from position and noise, never the hidden specimen.
const ISLANDS := [
 [Vector2(501,321),Vector2(13,24),-.38],
 [Vector2(570,392),Vector2(19,12),.35],
 [Vector2(384,255),Vector2(28,17),-.2],
 [Vector2(637,270),Vector2(22,35),.5]
]
# Broad buried banks cross the specimen area and extend into surrounding matrix.
# They describe geology only; the shell is consulted later by removal/collision.
const BANKS := [
 [Vector2(460,373),Vector2(43,40),-.30],
 [Vector2(548,306),Vector2(55,30),.48],
 [Vector2(581,400),Vector2(46,35),-.42]
]
var grain_ease:=PackedFloat32Array()
var entry := Vector2(444,302)
var encounters := [
 {"name":"Fenêtre granulaire","center":Vector2(451,304)},
 {"name":"Nappe et îlot","center":Vector2(506,332)},
 {"name":"Accumulation profonde","center":Vector2(551,391)}
]
func _init(surface:WorkingSurface,shape:RefCounted,rim:RefCounted) -> void:
 super(surface,shape,rim,1)
 var fine:=FastNoiseLite.new();fine.seed=41037;fine.frequency=.095
 var broad:=FastNoiseLite.new();broad.seed=41011;broad.frequency=.018
 var data:=PackedFloat32Array();data.resize(size.x*size.y*4)
 grain_ease.resize(size.x*size.y)
 for y in range(size.y):
  for x in range(size.x):
   var i:=y*size.x+x
   grain_roofs[i]=0;grain_floors[i]=0
   var top:=fragmented_top[i]
   if top<=.30:continue
   var p:=Vector2(x,y)
   var n:=broad.get_noise_2dv(p)
   var d:=fine.get_noise_2dv(p)
   var bank:=0.0
   for form in BANKS:
    var q:Vector2=(p-form[0]).rotated(-form[2])/form[1]
    bank=maxf(bank,1.0-smoothstep(.35,1.14,q.length()+d*.24+n*.16))
   var island:=0.0
   for form in ISLANDS:
    var q:Vector2=(p-form[0]).rotated(-form[2])/form[1]
    island=maxf(island,1.0-smoothstep(.42,1.14,q.length()+d*.30))
   # Thin sealed roof over both grains and lenses. No automatic access.
   var cover:=.014+.006*(n+.5)
   var roof:=top-cover
   var basin:=1.0-smoothstep(.25,1.1,((p-Vector2(551,391))/Vector2(83,58)).length())
   var floor_height:=.24+.045*n+.012*d-basin*.11
   # The fast loose cover now ends on broad, irregular consolidated shoulders.
   # Preserve roof and grain response exactly: more precision work, not slower air.
   var bank_top:=roof-(.052+.018*(n+.5))
   floor_height=maxf(floor_height,lerpf(floor_height,bank_top,pow(bank,.72)))
   # An island rises through the loose bed; its tapered shoulders can be blown,
   # its mineral core must be worked with Pick. No checkerboard of hard specks.
   floor_height=lerpf(floor_height,roof-.025,pow(island,1.7))
   grain_ease[i]=1.0+d*.55+n*.20
   grain_roofs[i]=roof
   grain_floors[i]=minf(floor_height,roof-.012)
   data[i*4]=roof;data[i*4+1]=grain_floors[i]
   data[i*4+2]=1.0-maxf(island,bank);data[i*4+3]=cover
 geology=ImageTexture.create_from_image(Image.create_from_data(size.x,size.y,false,Image.FORMAT_RGBAF,data.to_byte_array()))

func apply(block:ExcavationBlock,candidate:int,fixture:int,cleared:bool) -> void:
 super.apply(block,candidate,fixture,cleared)
 block.working_map.marine_grain_ease=grain_ease
