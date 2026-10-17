extends "res://tests/run_issue33_runtime.gd"
var route:Array[Dictionary]=[]
func _output_directory() -> String:return "res://work/issue41/"
func quiet() -> void:
 main.controller.cancel_stroke();main.feedback.proxies_enabled=false
 main.block.show_cursor({"inside":false},1);main.session_ui.notice_label.hide()
 await create_timer(.65).timeout
func record(label:String) -> void:
 var s=main.block.working_map
 route.append({"stage":label,"exposure":s.fossil.exposure_percent(),"grains":s.grains_removed,"impacts":main.controller.total_impacts})
func run() -> void:
 out=_output_directory();DirAccess.make_dir_recursive_absolute(out);AudioServer.set_bus_mute(0,true)
 root.size=Vector2i(1440,810)
 create_timer(180).timeout.connect(func():push_error("Marine native test timeout");quit(2))
 suite=load("res://scenes/experiments/preparation_demos.tscn").instantiate();root.add_child(suite)
 while suite.busy:await process_frame
 await suite.open_demo(1)
 main=suite.preparation;main.display.persist=false;main.controller.set_physics_process(false)
 root.mode=Window.MODE_WINDOWED;root.size=Vector2i(1440,810)
 main.controller._focused=true;main.controller._pointer_inside=true
 var s=main.block.working_map
 var initial:=state()
 var buried:=0;var invalid:=0;var on_bone:=0;var minimum:=INF
 for i in range(s._heights.size()):
  if s.structural_ceilings[i]>0:
   minimum=minf(minimum,s._heights[i]-s.structural_ceilings[i])
   if s.fossil.exposed[i]!=0:buried+=1
   if s.grain_roofs[i]>0:on_bone+=1
  if s.grain_roofs[i]>0 and (s.grain_floors[i]>=s.grain_roofs[i] or s.grain_roofs[i]>=s._heights[i]):invalid+=1
 check(buried==0 and minimum>.01,"every fossil cell initially buried")
 check(invalid==0,"marine beds have valid roof, floor and intact cover")
 check(on_bone>float(s.fossil.field.total_cells)*.90,"granular bed spans most of the preparation")
 check(main.controller.tools[1].radius==26 and main.controller.tools[1].power==.84 and main.controller.tools[3].power==.44,"validated tool parameters retained")
 check(Engine.max_fps==240 and Engine.physics_ticks_per_second==60,"runtime cadence unchanged")
 await zoom_to(2.5,Vector2(515,350));await quiet()
 var covered:Image=await frame_image()
 main.mesh_view.model.hide();var hidden:Image=await frame_image()
 check(covered.get_data()==hidden.get_data(),"intact cover hides fossil pixels and shadows")
 main.mesh_view.model.show();await shot("01-covered")
 var sealed:PackedFloat32Array=s._heights.duplicate()
 await tool_sweep(Vector2(425,290),Vector2(570,390),.8,2)
 check(sealed==s._heights,"blower never opens an intact distant crust")
 main.feedback.proxies_enabled=true
 var entry:Vector2=main.profile.entry
 var ci:=int(entry.y)*1024+int(entry.x)
 var impacts:=0
 for n in range(5):
  native_impact(entry);impacts+=1
  if s._heights[ci]<=s.grain_roofs[ci]+.0001:break
 check(impacts<=3,"first window opens in at most three Chisel contacts")
 record("opened");await quiet();await shot("02-first-window")
 var before:PackedFloat32Array=s._heights.duplicate()
 main.feedback.proxies_enabled=true
 await tool_sweep(entry,entry+Vector2(12,0),.16,2)
 record("first short breath");await shot("03-short-contact")
 var changed:=0;var outside:=0
 for i in range(before.size()):
  if before[i]==s._heights[i]:continue
  changed+=1
  var p:=Vector2(i%1024,floori(float(i)/1024))
  if p.distance_to(entry)>main.controller.tools[2].radius+13:outside+=1
 check(changed>150,"short breath makes a real visible opening")
 check(outside==0,"short breath changes only material reached by its footprint")
 check(main.feedback.grain_bursts>0,"real grains feed a local visible trail")
 await timed_sweep(entry,Vector2(488,302),2)
 await quiet();record("window extended");await shot("04-window-extended")
 var island:=321*1024+501
 var island_before:float=s._heights[island]
 for pair in [
  [Vector2(475,300),Vector2(525,290)],[Vector2(515,300),Vector2(555,330)],
  [Vector2(545,330),Vector2(573,370)],[Vector2(560,370),Vector2(540,410)],
  [Vector2(540,410),Vector2(490,408)],[Vector2(490,408),Vector2(450,370)],
  [Vector2(470,350),Vector2(530,350)]]:
  main.feedback.proxies_enabled=true
  await timed_sweep(pair[0],pair[1],2)
  record("follow bed")
  if route.size()==7:await shot("05-flow-over-ribs")
 await quiet();await shot("06-islands-and-relief")
 print("STAGE islands captured")
 check(s.fossil.exposure_percent()>65,"one entry and blower route reveal most of the shell")
 check(s._heights[island]>=s.grain_floors[island] and s._heights[island]>s.structural_ceilings[island]+.01,"solid island survives surrounding airflow")
 check(main.controller.total_impacts==impacts,"blower progression needs no grid of Chisel impacts")
 var film:float=s.bone_film.cleanliness_percent()
 check(film<1 and s.fossil.condition==100,"air reveals dirty intact shell without cleaning film")
 for point in [Vector2(496,307),Vector2(501,321),Vector2(506,335)]:
  for n in range(3):native_impact(point,3)
 print("STAGE island picked")
 check(s._heights[island]<minf(island_before,s.grain_floors[island]),"Pick works the consolidated island")
 await tool_sweep(Vector2(480,312),Vector2(525,338),.7,2)
 print("STAGE sweeping done")
 await quiet();await shot("07-picked-island")
 await zoom_to(3.2,Vector2(552,387))
 main.feedback.proxies_enabled=true
 await tool_sweep(Vector2(538,369),Vector2(565,405),.35,2)
 await shot("08-ribs-contact")
 await tool_sweep(Vector2(538,369),Vector2(565,405),1.0,0)
 await tool_sweep(Vector2(565,405),Vector2(538,369),1.0,0)
 await quiet();await shot("09-ribs-brushed")
 check(s.bone_film.cleanliness_percent()>film+5,"Brush gives a distinct final finish")
 check(main.feedback.grains.is_empty(),"grain feedback dissipates after release")
 check(main.toolbar.get_child_count()==4 and main.controller.tools.size()==4,"marine keeps its four original tools")
 # Independent full route starts fresh so the dirty-film check remains meaningful.
 main.reset_specimen();await settle(4)
 check(state()==initial and s.grains_removed==0,"reset restores complete geological state")
 await complete_demo(1)
 var completed:Dictionary=main.session.snapshot()
 await click(main.session_ui.archive_button)
 check(main.session.archived,"real archive button completes the trial")
 main.reset_specimen();await settle(4)
 check(state()==initial,"archive then reset restores pristine preparation")
 evidence.completion=completed
 evidence.checks=checks;evidence.failures=failures;evidence.route=route
 evidence.minimum_cover_mm=minimum*102
 var timings:={}
 for tool in costs:
  var values:Array=costs[tool];values.sort()
  if not values.is_empty():timings[tool]={"active_ticks":values.size(),"edit_p50_ms":values[values.size()/2],"edit_p95_ms":values[floori(values.size()*.95)],"edit_max_ms":values.back()}
 evidence.timings=timings
 FileAccess.open(out+"native.json",FileAccess.WRITE).store_string(JSON.stringify(evidence,"  "))
 print("ISSUE41 ",checks," checks ",failures.size()," failures; route ",route)
 suite.queue_free();await create_timer(.2).timeout;quit(0 if failures.is_empty() else 1)
