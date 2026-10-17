extends "res://tests/run_p6a50_collection.gd"
var suite:Node
var results:Array[Dictionary]=[]
func shot(name:String) -> void:
 await super.shot(name)
 evidence.captures.append(name+".png")
func _output_directory() -> String:return "res://work/issue33/"
func tool_sweep(a:Vector2,b:Vector2,seconds:float,tool:int) -> void:
 main.controller.select_tool(tool);main.controller._focused=true;main.controller._pointer_inside=true
 var press:=InputEventMouseButton.new();press.button_index=MOUSE_BUTTON_LEFT;press.pressed=true;press.position=at(a)
 root.push_input(press,true)
 var frames_count:=roundi(seconds*60)
 for n in range(frames_count):
  main.block.flush_texture()
  var motion:=InputEventMouseMotion.new();motion.position=at(a.lerp(b,float(n+1)/frames_count));motion.button_mask=MOUSE_BUTTON_MASK_LEFT
  root.push_input(motion,true);main.controller._physics_process(1.0/60);await process_frame
 var release:=InputEventMouseButton.new();release.button_index=MOUSE_BUTTON_LEFT;release.pressed=false;release.position=main.controller._screen
 root.push_input(release,true)
func run() -> void:
 out=_output_directory();DirAccess.make_dir_recursive_absolute(out)
 AudioServer.set_bus_mute(0,true)
 root.size=Vector2i(1440,810)
 suite=load("res://scenes/experiments/preparation_demos.tscn").instantiate();root.add_child(suite)
 while suite.busy:await process_frame
 for kind in range(3):
  if kind>0:await suite.open_demo(kind)
  main=suite.preparation;main.display.persist=false;main.controller.set_physics_process(false)
  root.mode=Window.MODE_WINDOWED;root.size=Vector2i(1440,810)
  await settle(12)
  var s=main.block.working_map
  var initial:=state()
  var covered:=0;var coated:=0;var grain_cells:=0
  for i in range(s._heights.size()):
   if s.structural_ceilings[i]>0 and s._heights[i]<=s.structural_ceilings[i]+FossilField.EXPOSURE_EPSILON:covered+=1
   if s.crust_caps[i]>0:coated+=1
   if s.grain_roofs[i]>0:grain_cells+=1
  check(covered==0,"demo %d starts fully buried"%kind)
  check(main.controller.tools[1].radius==26 and main.controller.tools[1].power==.84 and main.controller.tools[3].power==.44,"validated tool feeling preserved %d"%kind)
  check(main.distinction.storage_path.begins_with("res://work/issue33/"),"isolated trial storage %d"%kind)
  print("DEMO ",kind," coated ",coated," grains ",grain_cells)
  await shot("demo-%d-01-covered"%kind)
  await zoom_to(2.2 if kind==0 else 2.5,Vector2(400,245) if kind==0 else Vector2(515,350))
  main.feedback.proxies_enabled=false;main.session_ui.notice_label.hide();await settle(10)
  var before:Image=await frame_image()
  main.mesh_view.model.hide();await settle(4)
  var hidden:Image=await frame_image()
  check(before.get_data()==hidden.get_data(),"no hidden fossil pixels or shadow %d"%kind)
  main.mesh_view.model.show()
  if kind==2:
   var zero:=Image.create(1024,640,false,Image.FORMAT_RGF)
   var zero_texture:=ImageTexture.create_from_image(zero)
   main.block.material.set_shader_parameter("demo_crust",zero_texture)
   main.block.skirt_material.set_shader_parameter("demo_crust",zero_texture)
   var no_coating:Image=await frame_image()
   check(before.get_data()==no_coating.get_data(),"hidden adherent deposits do not imprint the intact roof")
   main.block.material.set_shader_parameter("demo_crust",main.profile.crust)
   main.block.skirt_material.set_shader_parameter("demo_crust",main.profile.crust)
  main.feedback.proxies_enabled=true;main.session_ui.notice_label.show()
  if kind==0:
   for y in range(190,300,24):
    for x in range(260,425,24):
     if ((Vector2(x,y)-Vector2(340,245))/Vector2(85,60)).length()>1:continue
     for repeat in range(2):native_impact(Vector2(x,y))
     await process_frame
   await settle(8);await shot("demo-0-02-native-excavation")
  else:
   var sealed:PackedFloat32Array=s._heights.duplicate()
   await tool_sweep(Vector2(450,300),Vector2(570,360),.6,2)
   check(s._heights==sealed,"air cannot remove sealed cover %d"%kind)
   if kind==2:
    await tool_sweep(Vector2(450,300),Vector2(570,360),.5,4)
    check(s._heights==sealed,"abrasion cannot pass through buried matrix")
   for y in range(270,410,28):
    for x in range(430,600,28):
     if ((Vector2(x,y)-Vector2(515,340))/Vector2(94,82)).length()>1:continue
     native_impact(Vector2(x,y));await process_frame
   await settle(10);await shot("demo-%d-02-opened"%kind)
   var pre:float=s.fossil.exposure_percent()
   for y in [285,330,375,405]:
    await tool_sweep(Vector2(425,y),Vector2(610,y),.8,2)
    await tool_sweep(Vector2(610,y),Vector2(425,y),.8,2)
   await settle(10);await shot("demo-%d-03-blown"%kind)
   check(s.grains_removed>100,"native air clears real grains %d"%kind)
   check(s.fossil.exposure_percent()>pre+5,"air genuinely discovers the fossil %d"%kind)
   if kind==2:
    await tool_sweep(Vector2(458,299),Vector2(477,303),.3,4)
    await shot("demo-2-03b-abrasive-contact")
    for y in [295,315,340,365,390,410]:
     await tool_sweep(Vector2(430,y),Vector2(610,y),1.1,4)
     await tool_sweep(Vector2(610,y),Vector2(430,y),1.1,4)
    check(s.crust_removed>1,"abrasive removes actual deposits")
    await shot("demo-2-04-abraded")
   print("NATIVE SNAPSHOT ",kind," ",main.session.snapshot()," grains ",s.grains_removed," abrasion ",s.crust_removed)
  main.controller.cancel_stroke();main.feedback.proxies_enabled=false;main.block.show_cursor({"inside":false},1)
  await create_timer(.8).timeout
  await shot("demo-%d-05-detail"%kind)
  await complete_demo(kind)
  results.append({"kind":kind,"snapshot":main.session.snapshot(),"grain_volume":s.grains_removed,"crust_volume":s.crust_removed,"impacts":main.controller.total_impacts})
  var finished:=state()
  suite.choose((kind+1)%3)
  check(suite.confirmation.visible and suite.selected==kind,"unfinished work requires confirmation %d"%kind)
  suite.confirmation.hide()
  check(state()==finished,"cancel changing trial retains the working state %d"%kind)
  await click(main.session_ui.archive_button)
  check(main.session.archived,"archive trial through its actual button %d"%kind)
  main.reset_specimen();await settle(4)
  check(state()==initial,"reset restores exact preparation and clears new materials %d"%kind)
 evidence.results=results
 evidence.checks=checks;evidence.failures=failures
 FileAccess.open(out+"native-review.json",FileAccess.WRITE).store_string(JSON.stringify(evidence,"  "))
 print("ISSUE33 ",checks," checks ",failures.size()," failures")
 suite.queue_free();await create_timer(.2).timeout;quit(0 if failures.is_empty() else 1)

func complete_demo(kind:int) -> void:
 var s=main.block.working_map
 main.feedback.proxies_enabled=false
 print("COMPLETE ROUTE ",kind)
 await zoom_to(1.0 if kind==0 else 1.5)
 # Each call below uses the real controller's contact and cadence, never a reveal fixture.
 # Coarse Pick work is Bone-safe; residual grains are subsequently evacuated with air.
 var lo:=Vector2i(1024,640);var hi:=Vector2i.ZERO
 for i in range(s.fossil.field.component_ids.size()):
  if s.fossil.field.component_ids[i]==0:continue
  var p:=Vector2i(i%1024,floori(float(i)/1024));lo=lo.min(p);hi=hi.max(p)
 if kind==1:
  # Efficient bulk passes before systematic precision. Condition checks still apply;
  # every contact uses the controller, only the QA path knows exact safe clearances.
  for pass_index in range(2):
   for y in range(lo.y,hi.y+1,18):
    for x in range(lo.x,hi.x+1,18):
     var i:=y*1024+x
     for repeat in range(2):
      if s._heights[i]<=s.structural_ceilings[i]+.09:break
      native_impact(Vector2(x,y),1)
    await process_frame
   for y in range(lo.y,hi.y+15,35):
    await tool_sweep(Vector2(lo.x-10,y),Vector2(hi.x+10,y),1.0,2)
    await tool_sweep(Vector2(hi.x+10,y),Vector2(lo.x-10,y),1.0,2)
 if kind>0:
  for y in range(lo.y-8,hi.y+10,18):
   for x in range(lo.x-8,hi.x+10,18):
    native_impact(Vector2(x,y),3)
   await process_frame
  for y in range(lo.y,hi.y+15,35):
   await tool_sweep(Vector2(lo.x-10,y),Vector2(hi.x+10,y),.9,2)
   await tool_sweep(Vector2(hi.x+10,y),Vector2(lo.x-10,y),.9,2)
 if kind==0:
  for y in range(lo.y,hi.y+1,11):
   for x in range(lo.x,hi.x+1,11):
    var i:=y*1024+x
    if s.fossil.field.component_ids[i]==0:continue
    for repeat in range(4):native_impact(Vector2(x,y),3)
   await process_frame
 var misses:=0
 for i in range(s.fossil.exposed.size()):
  if s.fossil.field.component_ids[i]==0 or s.fossil.exposed[i]!=0:continue
  var p:=Vector2(i%1024,floori(float(i)/1024))
  if s.crust_caps[i]>0 and main.controller.tools.size()>4:
   for tick in range(60):
    if s._heights[i]<=s.crust_caps[i]+.001:break
    native_impact(p,3)
   await tool_sweep(p-Vector2(6,0),p+Vector2(6,0),.45,4)
  else:
   for repeat in range(32):
    if s.fossil.exposed[i]!=0:break
    native_impact(p,3)
  if s.fossil.exposed[i]==0:
   misses+=1
   if misses<6:print("UNREACHED ",kind," ",p," hit ",main.controller.hit)
   if misses>10:break
  if i%17==0:await process_frame
 check(s.fossil.exposure_percent()>=99,"real tools can expose at least 99 percent %d"%kind)
 # Preserve dirty film as a separate final gesture after real new revelations.
 check(s.bone_film.cleanliness_percent()<20,"newly exposed fossil still requires Brush %d"%kind)
 if kind==2:
  print("CRUST AFTER FINISH ",s.crust_removed)
 await settle(4)
 main.feedback.proxies_enabled=true
 for y in range(lo.y,hi.y+10,28):
  await tool_sweep(Vector2(lo.x-10,y),Vector2(hi.x+10,y),maxf(1.1,float(hi.x-lo.x)/180.0),0)
  await tool_sweep(Vector2(hi.x+10,y),Vector2(lo.x-10,y),maxf(1.1,float(hi.x-lo.x)/180.0),0)
 await settle(15)
 check(s.bone_film.cleanliness_percent()>=99,"accepted Brush finishes the real film %d"%kind)
 check(main.session.preparation_complete and main.distinction.earned,"integral trial is attainable %d"%kind)
 check(s.fossil.condition==100,"safe tools retain full condition %d"%kind)
 main.feedback.proxies_enabled=false;main.block.show_cursor({"inside":false},1)
 main.session_ui.notice_label.hide()
 await zoom_to(1.3 if kind==0 else 2.5,Vector2(520,330))
 await create_timer(.8).timeout
 await shot("demo-%d-06-complete-native"%kind)
 main.session_ui.notice_label.show()
