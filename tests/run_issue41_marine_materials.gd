extends SceneTree
var checks:=0
var failures:Array[String]=[]
func _initialize() -> void:run.call_deferred()
func check(ok:bool,label:String) -> void:
 checks+=1
 if not ok:failures.append(label);push_error(label)
func run() -> void:
 var main=load("res://scenes/experiments/demo_preparation.tscn").instantiate()
 main.demo_kind=1;main.specimen_id="M08"
 main.get_node("ExcavationBlock").demo_kind=1;main.get_node("ExcavationBlock").specimen_id="M08"
 root.add_child(main);main.controller.set_physics_process(false)
 var s=main.block.working_map
 var total:=0;var airy:=0;var min_floor:=INF;var max_floor:=-INF
 for i in range(s._heights.size()):
  if s.grain_roofs[i]>0:
   min_floor=minf(min_floor,s.grain_floors[i]);max_floor=maxf(max_floor,s.grain_floors[i])
  if s.structural_ceilings[i]<=0:continue
  total+=1
  var floor_height:float=s.deep_grain_floors[i] if s.deep_grain_roofs[i]>0 else s.grain_floors[i]
  if s.grain_roofs[i]>0 and floor_height<=s.structural_ceilings[i] and s.crust_caps[i]==0:airy+=1
 check(float(airy)/total>.35 and float(airy)/total<.75,"blower gives a substantial glimpse while leaving broad hard preparation")
 check(max_floor-min_floor>.15,"bed and mineral lenses have meaningful depth variation")
 var deep:=310*1024+570
 check(s.grain_floors[deep]-s.deep_grain_roofs[deep]>.015,"eastern bed needs a new excavation front")
 var coats:=0
 var cover:=INF
 for i in range(s.crust_caps.size()):
  if s.crust_caps[i]<=0:continue
  coats+=1;cover=minf(cover,s._heights[i]-s.crust_caps[i])
 check(coats>500 and coats<total*.10 and cover>.04,"one limited nodule encounter stays buried")
 check(main.controller.has_finishing_family(),"marine uses the approved finishing family")
 var pristine:PackedFloat32Array=s._heights.duplicate()
 s.apply_continuous(Vector2(450,300),Vector2(550,380),main.controller.tools[2],0)
 check(pristine==s._heights,"zero duration cannot excavate")
 # Unit fixture only: never used for captures or the native play route.
 s.grain_roofs=s.grain_roofs.duplicate();s.grain_floors=s.grain_floors.duplicate()
 for y in range(180,221):
  for x in range(310,351):
   var i:=y*1024+x
   s.grain_roofs[i]=.48;s.grain_floors[i]=.10;s._heights[i]=.50
 s._heights[200*1024+330]=.44
 s.image.set_data(1024,640,false,Image.FORMAT_RF,s._heights.to_byte_array())
 s.apply_continuous(Vector2(330,200),Vector2(330,200),main.controller.tools[2],1.0/60)
 check(s._heights[200*1024+333]<.50,"jet crumbles an exposed lip")
 check(s._heights[200*1024+336]==.50,"snapshot prevents same-tick cascade through sealed crust")
 var far:=200*1024+344
 check(s._heights[far]==.50,"distant covered cells cannot disappear")
 main.reset_specimen()
 # A synthetic empty-matrix fixture verifies the newly added buried layer.
 s.grain_roofs=s.grain_roofs.duplicate();s.grain_floors=s.grain_floors.duplicate()
 s.deep_grain_roofs=s.deep_grain_roofs.duplicate();s.deep_grain_floors=s.deep_grain_floors.duplicate()
 for y in range(180,221):
  for x in range(310,351):
   var i:=y*1024+x
   s.grain_roofs[i]=.8;s.grain_floors[i]=.65
   s.deep_grain_roofs[i]=.58;s.deep_grain_floors[i]=.2;s._heights[i]=.65
 s.image.set_data(1024,640,false,Image.FORMAT_RF,s._heights.to_byte_array())
 var buried:=200*1024+330
 for n in range(30):s.apply_continuous(Vector2(330,200),Vector2(330,200),main.controller.tools[2],1.0/60)
 check(is_equal_approx(s._heights[buried],.65),"air cannot cross the consolidated interbed seam")
 for n in range(5):s.apply_impact(Vector2(330,200),main.controller.tools[3])
 check(s._heights[buried]<=.5801 and s._heights[buried]>.2,"Pick opens the buried sediment reach")
 for n in range(90):s.apply_continuous(Vector2(330,200),Vector2(330,200),main.controller.tools[2],1.0/60)
 check(is_equal_approx(s._heights[buried],.2),"newly opened lower bed flows and stops at its own floor")
 main.reset_specimen()
 check(s.deep_grain_roofs==main.profile.deep_roofs and s.deep_grain_floors==main.profile.deep_floors,"reset restores buried geological arrays")
 # Real mineral core, with surface staged exactly at its geological floor.
 var core:=391*1024+434
 var p:=Vector2(434,391)
 var floor_height:float=s.grain_floors[core]
 s._heights[core]=floor_height
 s.image.set_data(1024,640,false,Image.FORMAT_RF,s._heights.to_byte_array())
 for n in range(10):s.apply_continuous(p,p,main.controller.tools[2],1.0/60)
 check(s._heights[core]==floor_height,"air cannot erode the consolidated core")
 s.apply_impact(p,main.controller.tools[3])
 check(s._heights[core]<floor_height,"Pick retains its role on the solid core")
 main.reset_specimen()
 var target:=-1
 for i in range(s.structural_ceilings.size()):
  if s.structural_ceilings[i]>.10 and s.grain_floors[i]<s.structural_ceilings[i]-.02 and s.crust_caps[i]==0:
   target=i;break
 check(target>=0,"real rib fixture available")
 p=Vector2(target%1024,floori(float(target)/1024))
 var bone:float=s.structural_ceilings[target]
 s._heights[target]=bone+.03
 s.image.set_data(1024,640,false,Image.FORMAT_RF,s._heights.to_byte_array())
 var before_brush:float=s._heights[target]
 for n in range(10):s.apply_continuous(p,p,main.controller.tools[0],1.0/60)
 check(s._heights[target]==before_brush,"Brush cannot replace the blower in the granular bed")
 for n in range(20):s.apply_continuous(p,p,main.controller.tools[2],1.0/60)
 check(is_equal_approx(s._heights[target],bone) and s.fossil.exposed[target]!=0,"air stops exactly at the real fossil relief")
 check(s.bone_film.cleanliness_percent()==0 and s.fossil.condition==100,"air reveals film without cleaning or damaging fossil")
 for n in range(10):s.apply_continuous(p,p,main.controller.tools[2],1.0/60)
 check(s._heights[target]==bone,"continued airflow cannot cut through the exposed fossil")
 main.reset_specimen()
 check(s._heights==pristine and s.grains_removed==0 and s.fossil.exposed_cells==0,"reset restores exact heights, counters and burial")
 var report:={"checks":checks,"failures":failures,"air_reachable_fossil_cells":airy,"total_fossil_cells":total,"floor_range":[min_floor,max_floor]}
 DirAccess.make_dir_recursive_absolute("res://work/issue41")
 FileAccess.open("res://work/issue41/materials.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("ISSUE41 MATERIALS ",checks," checks ",failures.size()," failures")
 main.queue_free();await process_frame;quit(0 if failures.is_empty() else 1)
