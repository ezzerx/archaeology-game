extends "res://scripts/experiments/preparation_demos/demo_profile.gd"
## Three authored geological compositions; no anatomy-shaped carving.
var compact_variant:=0
var lenses:Array[RefCounted]=[]
var composition_volume:=0.0
const COMPOSITIONS:=[
 # centre, axes, cover, depth. Depths use the RF work-surface unit.
 [[Vector2(405,358),Vector2(86,55),.130,.155],
  [Vector2(584,258),Vector2(55,38),.190,.125]],
 [[Vector2(400,340),Vector2(60,44),.135,.135],
  [Vector2(500,210),Vector2(60,44),.145,.125],
  [Vector2(560,430),Vector2(60,42),.135,.140]],
 [[Vector2(420,390),Vector2(111,34),.185,.130],
  [Vector2(510,210),Vector2(60,46),.135,.155]]
]
const BANKS:=[
 [[Vector2(468,235),Vector2(80,52),-.35],[Vector2(565,395),Vector2(63,87),.35]],
 [[Vector2(432,328),Vector2(57,91),-.35],[Vector2(605,415),Vector2(82,43),.35]],
 [[Vector2(358,335),Vector2(63,91),.30],[Vector2(590,324),Vector2(65,76),-.45]]
]
func _init(surface:WorkingSurface,shape:RefCounted,rim:RefCounted,choice:int) -> void:
 super(surface,shape,rim,0)
 compact_variant=posmod(choice,3)
 var noise:=FastNoiseLite.new();noise.seed=37051;noise.frequency=.033
 for y in range(size.y):
  for x in range(size.x):
   var i:=y*size.x+x
   if fragmented_top[i]<=0:continue
   var point:=Vector2(x,y)
   var bank:=0.0
   for deposit in BANKS[compact_variant]:
    var q:Vector2=(point-deposit[0]).rotated(-deposit[2])/deposit[1]
    bank=maxf(bank,1.0-smoothstep(.48,1.0,q.length()+noise.get_noise_2dv(point)*.24))
   for f in range(limits.size()):
    limits[f][i*2+1]=lerpf(.08,substrates[f][i]-.055,bank)
 _build_lenses(surface)
func _build_lenses(surface:WorkingSurface) -> void:
 var merged=preload("res://scripts/excavation/pockets/pocket_layout.gd").new()
 merged.resolution=size;merged.clear_shape();merged.seed_value=37000+compact_variant
 var occupied:=PackedByteArray();occupied.resize(size.x*size.y)
 var ordinal:=0
 for specification in COMPOSITIONS[compact_variant]:
  var random:=RandomNumberGenerator.new();random.seed=37001+compact_variant*100+ordinal*13
  var candidate:RefCounted
  # Admission rejects a whole geological volume; neither the floor nor the
  # outline can inherit the fossil shape. Search is deterministic and bounded.
  for attempt in range(32):
   var recipe_local:=FriablePocketRecipe.new()
   var center:Vector2=specification[0]+Vector2(random.randf_range(-18,18),random.randf_range(-15,15))
   recipe_local.envelopes=[Rect2(center/Vector2(size),Vector2.ZERO)]
   recipe_local.axes_min=specification[1];recipe_local.axes_max=specification[1]
   recipe_local.cover_range=Vector2.ONE*float(specification[2])
   recipe_local.depth_range=Vector2.ONE*float(specification[3])
   candidate=preload("res://scripts/excavation/pockets/pocket_layout.gd").new()
   candidate.resolution=size
   candidate.sample(recipe_local,random)
   # Orientation is part of the seeded sample. Composition axes control the
   # elongated third lens; local noise gives each boundary its own character.
   var valid:=true
   var overlap:=0
   for slot in range(candidate.cells.size()):
    var i:int=candidate.cells[slot]
    var roof:float=limits[1][i*2]-candidate.cover[slot]
    var floor_height:float=roof-candidate.depth[slot]
    candidate.roofs[i]=roof;candidate.floors[i]=floor_height
    if surface.structural_ceilings[i]>0:overlap+=1
    if occupied[i]!=0 or fragmented_top[i]<=0 or floor_height<=.02 or floor_height<surface.structural_ceilings[i]+.018:
     valid=false;break
   if valid and overlap>=400:
    candidate.present=true;candidate.covered_bone=overlap
    break
  if not candidate.present:
   push_error("Compact composition %d cannot admit lens %d"%[compact_variant,ordinal])
   ordinal+=1;continue
  lenses.append(candidate)
  merged.bounds=candidate.bounds if lenses.size()==1 else merged.bounds.merge(candidate.bounds)
  merged.covered_bone+=candidate.covered_bone
  for slot in range(candidate.cells.size()):
   var i:int=candidate.cells[slot]
   occupied[i]=1
   merged.cells.append(i);merged.weights.append(candidate.weights[slot]);merged.noise_values.append(candidate.noise_values[slot])
   merged.roofs[i]=candidate.roofs[i];merged.floors[i]=candidate.floors[i]
   merged.cover.append(candidate.cover[slot]);merged.depth.append(candidate.depth[slot])
   composition_volume+=candidate.roofs[i]-candidate.floors[i]
  ordinal+=1
 merged.present=not lenses.is_empty()
 merged.centre=lenses[0].centre if merged.present else Vector2.ZERO
 layout=merged
