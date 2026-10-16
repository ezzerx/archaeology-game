extends SceneTree
var checks:=0
var failures:Array[String]=[]
func _initialize() -> void:run.call_deferred()
func check(ok:bool,label:String) -> void:
 checks+=1
 if not ok:failures.append(label);push_error(label)
func digest(data:PackedByteArray) -> String:
 var hash:=HashingContext.new();hash.start(HashingContext.HASH_SHA256);hash.update(data);return hash.finish().hex_encode()
func run() -> void:
 DirAccess.make_dir_recursive_absolute("res://work/issue37")
 var reports:Array[Dictionary]=[]
 var top_hash:=""
 var volumes:Array[float]=[]
 var masks:Array[String]=[]
 for variant in range(3):
  var main=load("res://scenes/experiments/demo_preparation.tscn").instantiate()
  main.compact_variant=variant;root.add_child(main);main.controller.set_physics_process(false)
  var s=main.block.working_map
  var profile=main.profile
  var legacy_noise:=FastNoiseLite.new();legacy_noise.seed=33017;legacy_noise.frequency=.012
  check(profile.lenses.size()==[2,3,2][variant],"exact authored encounter count %d"%variant)
  var current_hash:=digest(s._heights.to_byte_array())
  if variant==0:top_hash=current_hash
  check(current_hash==top_hash,"all dispositions preserve the same intact topography %d"%variant)
  masks.append(digest(profile.layout.roofs.to_byte_array()))
  var initial:PackedFloat32Array=s._heights.duplicate()
  var ownership:=PackedByteArray();ownership.resize(initial.size())
  var invalid:=0;var duplicate:=0;var covered:=0
  var min_cover:=INF;var min_bone_cover:=INF;var depth_min:=INF;var depth_max:=0.0
  var floor_min:=INF;var floor_max:=0.0
  var useful_volume:=0.0
  for lens in profile.lenses:
   var center:Vector2=lens.centre.round()
   var before_air:PackedFloat32Array=s._heights.duplicate()
   for tick in range(30):s.apply_continuous(center,center,main.controller.tools[2],1.0/60)
   check(s._heights==before_air,"sealed inclusion resists actual air %d"%variant)
   for slot in range(lens.cells.size()):
    var i:int=lens.cells[slot]
    if ownership[i]!=0:duplicate+=1
    ownership[i]=1
    min_cover=minf(min_cover,initial[i]-lens.roofs[i])
    var depth:float=lens.roofs[i]-lens.floors[i]
    depth_min=minf(depth_min,depth);depth_max=maxf(depth_max,depth)
    floor_min=minf(floor_min,lens.floors[i]);floor_max=maxf(floor_max,lens.floors[i])
    if lens.floors[i]<=s.structural_ceilings[i]+.0179 or lens.roofs[i]>=initial[i] or depth<=0:invalid+=1
    if s.structural_ceilings[i]>0:
     covered+=1;useful_volume+=depth
     min_bone_cover=minf(min_bone_cover,lens.floors[i]-s.structural_ceilings[i])
  check(invalid==0 and duplicate==0,"all lenses are disjoint, buried and safe %d"%variant)
  check(covered>=2500,"pockets intersect a useful part of the preparation %d"%variant)
  check(min_cover>.07,"pockets remain discoverable only after real excavation %d"%variant)
  check(floor_max-floor_min>.04,"cavity floors have real uneven relief %d"%variant)
  var stone:=0.0;var old_stone:=0.0;var material:=0.0
  var bank_cells:=0
  for i in range(initial.size()):
   if s.structural_ceilings[i]<=0:continue
   var bottom:float=s.structural_ceilings[i]
   material+=initial[i]-bottom
   var new_depth:float=maxf(0,minf(initial[i],profile.limits[1][i*2+1])-bottom)
   stone+=new_depth
   var x:=i%1024;var y:=floori(float(i)/1024)
   var old_bank:=smoothstep(-.08,.24,legacy_noise.get_noise_2d(x,y)+.18*sin(x*.016+y*.025))
   old_stone+=maxf(0,minf(initial[i],lerpf(.08,profile.substrates[1][i]-.028,old_bank))-bottom)
   if new_depth>.03:bank_cells+=1
  check(stone<old_stone*.75 and stone>old_stone*.12,"grès remains present but no longer dominates %d"%variant)
  check(main.controller.tools.size()==4 and main.controller.tools[1].radius==26 and is_equal_approx(main.controller.tools[1].power,.84),"validated tools retained %d"%variant)
  check(main.pocket.get_script().resource_path=="res://scripts/excavation/pockets/final_pocket.gd","validated grain flow and feedback reused %d"%variant)
  var p:Vector2=profile.lenses[0].centre.round()
  var i:=int(p.y)*1024+int(p.x)
  var cuts:=0
  while s._heights[i]>main.pocket.roofs[i]+.0001 and cuts<12:
   s.apply_impact(p,main.controller.tools[1]);cuts+=1
  var before:float=main.pocket.remaining_volume()
  for tick in range(45):s.apply_continuous(p-Vector2(12,0),p+Vector2(12,0),main.controller.tools[2],1.0/60)
  var short_gain:float=before-main.pocket.remaining_volume()
  check(short_gain>1,"opened pocket gives useful gain in a short jet %d"%variant)
  var guarded:=0
  for cell in main.pocket.cells:
   if s._heights[cell]<main.pocket.floors[cell]-.00001:guarded+=1
  check(guarded==0 and s.fossil.condition==100,"jet stops on compact floor without fossil damage %d"%variant)
  main.reset_specimen();s=main.block.working_map
  check(s._heights==initial and is_zero_approx(main.pocket.blown_volume),"reset restores surface and pocket state %d"%variant)
  volumes.append(profile.composition_volume)
  reports.append({"variant":variant,"lenses":profile.lenses.size(),"cells":profile.layout.cells.size(),"bone_cells_under_pockets":covered,
   "granular_volume":profile.composition_volume,"useful_granular_volume":useful_volume,"stone_volume":stone,"legacy_stone_volume":old_stone,"total_cover_volume":material,
   "stone_work_cells":bank_cells,"min_cover_mm":min_cover*102,"min_bone_cover_mm":min_bone_cover*102,"depth_range_mm":[depth_min*102,depth_max*102],
   "surface_first_opening_impacts":cuts,"short_jet_gain":short_gain})
  main.queue_free();await process_frame
 check(volumes.max()/volumes.min()<1.20,"granular budgets remain comparable across compositions")
 check(masks[0]!=masks[1] and masks[1]!=masks[2] and masks[0]!=masks[2],"all three geological layouts differ")
 FileAccess.open("res://work/issue37/logic.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"reports":reports},"  "))
 print("ISSUE37 LOGIC ",checks," checks ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)

