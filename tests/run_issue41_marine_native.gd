extends "res://tests/run_issue33_runtime.gd"
var route:Array[Dictionary]=[]
func _output_directory() -> String:return "res://work/issue41/journey/"
func quiet() -> void:
 main.controller.cancel_stroke();main.feedback.proxies_enabled=false
 main.block.show_cursor({"inside":false},1);main.session_ui.notice_label.hide()
 await create_timer(.65).timeout
func record(label:String) -> void:
 var s=main.block.working_map
 route.append({"stage":label,"exposure":s.fossil.exposure_percent(),"cleanliness":s.bone_film.cleanliness_percent(),"grains":s.grains_removed,"crust":s.crust_removed,"impacts":main.controller.total_impacts})
 print("JOURNEY ",route.back())
func key(code:int) -> void:
 var e:=InputEventKey.new();e.physical_keycode=code;e.pressed=true;root.push_input(e,true)
 e=InputEventKey.new();e.physical_keycode=code;e.pressed=false;root.push_input(e,true);await process_frame
func run() -> void:
 out=_output_directory();DirAccess.make_dir_recursive_absolute(out);AudioServer.set_bus_mute(0,true)
 create_timer(300).timeout.connect(func():push_error("Marine journey timeout");quit(2))
 root.size=Vector2i(1440,810)
 suite=load("res://scenes/experiments/preparation_demos.tscn").instantiate();root.add_child(suite)
 while suite.busy:await process_frame
 await suite.open_demo(1)
 main=suite.preparation;main.display.persist=false;main.controller.set_physics_process(false)
 root.mode=Window.MODE_WINDOWED;root.size=Vector2i(1440,810)
 main.controller._focused=true;main.controller._pointer_inside=true
 var s=main.block.working_map
 var initial:=state()
 var coats:PackedFloat32Array=s.crust_caps.duplicate()
 var minimum:=INF
 for i in range(s.structural_ceilings.size()):
  if s.structural_ceilings[i]>0:minimum=minf(minimum,s._heights[i]-s.structural_ceilings[i])
 check(s.fossil.exposed_cells==0 and minimum>.035,"inclined shell is completely buried")
 check(s.fossil.field.total_cells>40000 and s.fossil.field.total_cells<45000,"larger placement has a matching contact field")
 check(main.controller.tools[1].radius==26 and main.controller.tools[1].power==.84 and main.controller.tools[3].power==.44 and main.controller.tools[2].radius==60,"validated tools unchanged")
 check(Engine.max_fps==240 and Engine.physics_ticks_per_second==60,"runtime cadence preserved")
 check(main.toolbar.get_child_count()==4 and main.controller.tools.size()==5,"abrasive shares a finishing slot")
 await key(KEY_1);check(main.controller.selected_index==0,"first finishing return selects Brush")
 await key(KEY_1);check(main.controller.selected_index==4,"second key 1 selects abrasive")
 await key(KEY_2);await key(KEY_1);check(main.controller.selected_index==4,"finishing variant recalled")
 await zoom_to(1.9,Vector2(515,350));await quiet()
 var covered:Image=await frame_image();main.mesh_view.model.hide()
 check(covered.get_data()==(await frame_image()).get_data(),"intact cover has no fossil pixels or shadows")
 main.mesh_view.model.show()
 var zero:=ImageTexture.create_from_image(Image.create(1024,640,false,Image.FORMAT_RGBAF))
 for mat in [main.block.material,main.block.skirt_material]:mat.set_shader_parameter("demo_crust",zero)
 check(covered.get_data()==(await frame_image()).get_data(),"buried concretions do not imprint the roof")
 for mat in [main.block.material,main.block.skirt_material]:mat.set_shader_parameter("demo_crust",main.profile.crust)
 await shot("01-covered")
 var sealed:PackedFloat32Array=s._heights.duplicate()
 await tool_sweep(Vector2(400,290),Vector2(610,400),.8,2)
 check(sealed==s._heights,"blower cannot open a sealed preparation")
 var entry:Vector2=main.profile.entry;var ci:=int(entry.y)*1024+int(entry.x)
 for n in range(5):
  native_impact(entry)
  if s._heights[ci]<=s.grain_roofs[ci]+.0001:break
 check(main.controller.total_impacts<=3,"first access opens quickly")
 main.feedback.proxies_enabled=true
 await tool_sweep(entry,Vector2(440,300),.7,2);await shot("02-first-breath")
 await tool_sweep(Vector2(420,300),Vector2(464,343),1.0,2)
 await tool_sweep(Vector2(458,345),Vector2(431,391),1.0,2)
 await tool_sweep(Vector2(430,390),Vector2(488,427),1.0,2)
 await tool_sweep(Vector2(460,320),Vector2(615,360),1.2,2)
 await tool_sweep(Vector2(600,380),Vector2(500,440),1.0,2)
 await quiet();record("shallow discovery");await shot("03-shallow-discovery")
 var shallow:float=s.fossil.exposure_percent()
 check(shallow>5 and shallow<40,"first reach gives a recognizable partial discovery")
 var deep:=310*1024+570
 check(s._heights[deep]>s.deep_grain_roofs[deep]+.015,"deep reach still needs matrix excavation")
 # Further air alone cannot cut through either deep roof or a consolidated floor.
 var floor_cell:=391*1024+434;var floor_before:float=s._heights[floor_cell]
 await tool_sweep(Vector2(434,391),Vector2(570,310),.8,2)
 check(s._heights[deep]>s.deep_grain_roofs[deep]+.015,"prolonged airflow cannot bypass the deep roof")
 check(s._heights[floor_cell]>=s.grain_floors[floor_cell] and s._heights[floor_cell]>=floor_before-.0001,"air stops on the firm bank")
 # Open separate deeper accesses, then follow each newly reached sediment bed.
 for point in [Vector2(503,315),Vector2(550,350),Vector2(604,376),Vector2(543,436)]:
  var i:int=int(point.y)*1024+int(point.x)
  # Clear the upper loose bed before attempting its buried firm seam.
  if s._heights[i]>s.grain_roofs[i]+.0001:native_impact(point,1)
  await tool_sweep(point-Vector2(12,0),point+Vector2(12,0),.7,2)
  var roof:float=s.deep_grain_roofs[i] if s.deep_grain_roofs[i]>0 else s.grain_roofs[i]
  for n in range(8):
   if s._heights[i]<=maxf(roof,s.structural_ceilings[i])+.0001:break
   native_impact(point,1);await process_frame
  await tool_sweep(point-Vector2(16,0),point+Vector2(20,18),1.2,2)
 for pair in [[Vector2(503,315),Vector2(550,350)],[Vector2(550,350),Vector2(585,391)],[Vector2(604,376),Vector2(577,435)],[Vector2(568,440),Vector2(496,450)]]:
  await timed_sweep(pair[0],pair[1],2)
 await quiet();record("deeper reaches");await shot("04-deeper-reaches")
 check(s.fossil.exposure_percent()>shallow+10,"new fronts unlock a second discovery")
 check(s.fossil.exposure_percent()<85,"solid preparation remains after deeper airflow")
 # Follow two continuous solid shoulders. No reveal fixtures in captures.
 for path in [[Vector2(410,365),Vector2(430,394),Vector2(465,420)], [Vector2(532,270),Vector2(558,293),Vector2(583,317)]]:
  for segment in range(path.size()-1):
   var steps:int=ceili(path[segment].distance_to(path[segment+1])/5.0)
   for n in range(steps):
    var point:Vector2=path[segment].lerp(path[segment+1],float(n)/steps)
    for contact in range(4):native_impact(point,3)
    await process_frame
 await tool_sweep(Vector2(408,365),Vector2(485,430),.8,2)
 await quiet();record("precision shoulders");await shot("05-precision-shoulders")
 # Expose the finite late nodule cluster with Pick; it must survive these contacts.
 for y in range(393,440,8):
  for x in range(558,611,8):
   var i:=y*1024+x
   if coats[i]<=0:continue
   for n in range(16):
    if s._heights[i]<=coats[i]+.001:break
    native_impact(Vector2(x,y),3)
  await process_frame
 await tool_sweep(Vector2(556,400),Vector2(608,430),.9,2)
 await zoom_to(2.7,Vector2(579,411));await quiet();record("nodules reached");await shot("06-late-nodules")
 check(s.crust_caps==coats,"Chisel Pick and airflow preserve adherent deposits")
 var pre_abrade:float=s.crust_removed
 main.feedback.proxies_enabled=true
 await tool_sweep(Vector2(564,403),Vector2(600,422),.6,4);await shot("07-abrasive-contact")
 for y in [398,414,430]:
  await tool_sweep(Vector2(553,y),Vector2(615,y),.9,4)
  await tool_sweep(Vector2(615,y),Vector2(553,y),.9,4)
 await quiet();record("nodules finished");await shot("08-nodules-finished")
 check(s.crust_removed>pre_abrade+5,"abrasive removes a real local coating")
 check(s.bone_film.cleanliness_percent()<1,"abrasion leaves a distinct Brush finish")
 await tool_sweep(Vector2(559,400),Vector2(609,429),1.0,0)
 await tool_sweep(Vector2(609,429),Vector2(559,400),1.0,0)
 await quiet();await shot("09-finished-detail")
 check(s.bone_film.cleanliness_percent()>2,"Brush finishes the uncovered ribs")
 check(s.fossil.condition==100,"authored route preserves shell condition")
 main.reset_specimen();await settle(4)
 check(state()==initial and s.crust_caps==coats,"reset restores terrain and coatings exactly")
 await complete_demo(1)
 var completed:Dictionary=main.session.snapshot()
 record("systematic completion")
 await click(main.session_ui.archive_button);check(main.session.archived,"real completion button archives the trial")
 main.reset_specimen();await settle(4);check(state()==initial and s.crust_caps==coats,"archive then reset remains exact")
 evidence.completion=completed;evidence.route=route;evidence.checks=checks;evidence.failures=failures;evidence.minimum_cover_mm=minimum*102
 var timings:={}
 for tool in costs:
  var values:Array=costs[tool];values.sort()
  if not values.is_empty():timings[tool]={"active_ticks":values.size(),"edit_p50_ms":values[values.size()/2],"edit_p95_ms":values[floori(values.size()*.95)],"edit_max_ms":values.back()}
 evidence.timings=timings
 FileAccess.open(out+"native.json",FileAccess.WRITE).store_string(JSON.stringify(evidence,"  "))
 print("MARINE JOURNEY ",checks," checks ",failures.size()," failures")
 suite.queue_free();await create_timer(.2).timeout;quit(0 if failures.is_empty() else 1)
