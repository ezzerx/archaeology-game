extends SceneTree
var checks:=0
var failures:Array[String]=[]
func _initialize() -> void:run.call_deferred()
func check(ok:bool,label:String) -> void:
 checks+=1
 if not ok:failures.append(label);push_error(label)
func run() -> void:
 DirAccess.make_dir_recursive_absolute("res://work/issue33")
 var reports:Array[Dictionary]=[]
 for kind in range(3):
  var main=load("res://scenes/experiments/demo_preparation.tscn").instantiate()
  main.demo_kind=kind;main.specimen_id="B17" if kind==0 else "M08"
  main.get_node("ExcavationBlock").demo_kind=kind;main.get_node("ExcavationBlock").specimen_id=main.specimen_id
  root.add_child(main);main.controller.set_physics_process(false)
  var s=main.block.working_map
  var minimum_cover:=INF;var coat_count:=0;var invalid:=0
  var min_height:=INF;var max_height:=-INF
  for i in range(s._heights.size()):
   if s.crust_caps[i]>0:
    minimum_cover=minf(minimum_cover,s._heights[i]-s.crust_caps[i]);coat_count+=1
   if s.grain_roofs[i]>0 and (s.grain_floors[i]>=s.grain_roofs[i] or s.grain_roofs[i]>s._heights[i]):invalid+=1
   if s.fossil.field.component_ids[i]!=0:
    min_height=minf(min_height,s._heights[i]);max_height=maxf(max_height,s._heights[i])
  check(invalid==0,"valid grain volumes %d"%kind)
  check(kind!=2 or minimum_cover>.035,"coatings remain deeply below the intact surface %d"%kind)
  if kind==1:
   # Deliberately thin, unsupported roof: one step may crumble an adjacent lip,
   # but must not propagate through the whole circle in row iteration order.
   s.grain_roofs=s.grain_roofs.duplicate();s.grain_floors=s.grain_floors.duplicate()
   for y in range(220,261):
    for x in range(380,421):
     var i:=y*1024+x
     s.grain_roofs[i]=.48;s.grain_floors[i]=.10;s._heights[i]=.50
   s._heights[240*1024+400]=.44
   s.image.set_data(1024,640,false,Image.FORMAT_RF,s._heights.to_byte_array())
   s.apply_continuous(Vector2(400,240),Vector2(400,240),main.controller.tools[2],1.0/60)
   check(s._heights[240*1024+403]<.50,"one jet tick can crumble a directly unsupported lip")
   check(s._heights[240*1024+406]==.50,"one jet tick cannot cascade through a covered roof")
   main.reset_specimen()
  if kind==2:
   check(coat_count>2000 and coat_count<4500,"localized coating occupies a minority of the specimen")
   # A deliberately tiny mineral remnant tests the general micro-debris escape route.
   # This is a unit fixture, never presented as native gameplay or art evidence.
   var ci:=-1
   for i in range(s.crust_caps.size()):
    if s.crust_caps[i]>0:ci=i;break
   var point:=Vector2(ci%1024,floori(float(ci)/1024))
   for y in range(int(point.y)-4,int(point.y)+5):
    for x in range(int(point.x)-4,int(point.x)+5):
     var i:=y*1024+x
     s._heights[i]=s.structural_ceilings[i];s.crust_caps[i]=0
   var original:float=s.structural_ceilings[ci]+.0015
   s._heights[ci]=original;s.crust_caps[ci]=original
   s.image.set_data(1024,640,false,Image.FORMAT_RF,s._heights.to_byte_array())
   for tick in range(60):s.apply_continuous(point,point,main.controller.tools[0],1.0/60)
   check(is_equal_approx(s._heights[ci],original),"Brush cannot detach a tiny adherent mineral as a generic loose remnant")
   s.apply_impact(point,main.controller.tools[3])
   check(is_equal_approx(s._heights[ci],original),"Pick cannot grind adherent coating")
   for tick in range(60):s.apply_continuous(point,point,main.controller.tools[2],1.0/60)
   check(is_equal_approx(s._heights[ci],original),"air cannot remove adherent coating")
   var before:PackedFloat32Array=s._heights.duplicate()
   s.apply_continuous(point,point,main.controller.tools[4],0)
   check(s._heights==before,"zero-duration abrasive stroke has no effect")
   for tick in range(4):s.apply_continuous(point,point,main.controller.tools[4],1.0/60)
   check(s.fossil.exposed[ci]!=0 and s.crust_caps[ci]==0 and is_equal_approx(s._heights[ci],s.structural_ceilings[ci]),"abrasive finishes the real deposit at the physical fossil surface")
   check(s.bone_film.cleanliness_percent()==0 and s.fossil.condition==100,"abrasion reveals dirty intact fossil, without conflating film or condition")
   var finished:PackedFloat32Array=s._heights.duplicate()
   var remaining:PackedFloat32Array=s.crust_caps.duplicate()
   for tick in range(60):s.apply_continuous(point,point,main.controller.tools[4],1.0/60)
   var unauthorized:=0
   for i in range(finished.size()):
    if remaining[i]==0 and finished[i]!=s._heights[i]:unauthorized+=1
    if s._heights[i]<s.structural_ceilings[i]:unauthorized+=1
   check(unauthorized==0,"abrasive never drills through clean fossil or other matrix")
   main.reset_specimen()
   check(s.crust_caps==main.profile.crust_caps and s.fossil.exposed_cells==0 and s.crust_removed==0,"reset restores all deposits and clears experiment counters")
  reports.append({"kind":kind,"min_crust_cover_mm":minimum_cover*102 if minimum_cover<INF else -1,"crust_cells":coat_count,"specimen_cells":s.fossil.field.total_cells,"initial_height_range":[min_height,max_height]})
  main.queue_free();await process_frame
 FileAccess.open("res://work/issue33/materials.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"reports":reports},"  "))
 print("ISSUE33 MATERIALS ",checks," checks ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
