extends "res://tests/run_issue33_demos.gd"
func _output_directory() -> String:return "res://work/issue37/"
func run() -> void:
 out=_output_directory();DirAccess.make_dir_recursive_absolute(out)
 AudioServer.set_bus_mute(0,true);root.size=Vector2i(1440,810)
 suite=load("res://scenes/experiments/preparation_demos.tscn").instantiate();root.add_child(suite)
 while suite.busy:await process_frame
 var quick:bool="--quick" in OS.get_cmdline_user_args()
 var reports:Array[Dictionary]=[]
 for variant in range(3):
  if variant>0:await suite.open_demo(0,variant)
  main=suite.preparation;main.display.persist=false;main.controller.set_physics_process(false)
  root.mode=Window.MODE_WINDOWED;root.size=Vector2i(1440,810)
  await settle(10)
  var initial:=state()
  var s=main.block.working_map
  check(main.profile.lenses.size()==[2,3,2][variant],"expected admitted pockets %d"%variant)
  await zoom_to(1.3,Vector2(500,330));await shot("compact-%d-01-intact"%variant)
  main.feedback.proxies_enabled=false;main.session_ui.notice_label.hide();await settle(5)
  var sealed:=await frame_image()
  main.mesh_view.model.hide();await settle(3)
  check(sealed.get_data()==(await frame_image()).get_data(),"hidden skeleton and shadows invisible %d"%variant)
  main.mesh_view.model.show()
  var zero:=ImageTexture.create_from_image(Image.create(1024,640,false,Image.FORMAT_RGBAF))
  main.block.material.set_shader_parameter("friable_field",zero);await settle(3)
  check(sealed.get_data()==(await frame_image()).get_data(),"sealed pockets do not mark the surface %d"%variant)
  main.block.material.set_shader_parameter("friable_field",main.pocket.texture)
  main.feedback.proxies_enabled=true
  var lens_reports:Array[Dictionary]=[]
  for n in range(main.profile.lenses.size()):
   var lens=main.profile.lenses[n]
   var center:Vector2=lens.centre.round()
   await zoom_to(2.3,center)
   var previous:PackedFloat32Array=s._heights.duplicate()
   await tool_sweep(center-Vector2(15,0),center+Vector2(15,0),.3,2)
   check(s._heights==previous,"air cannot open sealed lens %d/%d"%[variant,n])
   var before:float=main.pocket.remaining_volume()
   var cuts:=open_at(center)
   await settle(8);await shot("compact-%d-pocket-%d-contact"%[variant,n])
   await tool_sweep(center-Vector2(18,0),center+Vector2(18,0),.65,2)
   var small_volume:float=before-main.pocket.remaining_volume()
   check(small_volume>1,"a short native jet gains real depth %d/%d"%[variant,n])
   await settle(4);await shot("compact-%d-pocket-%d-first-air"%[variant,n])
   # Follow a bounded geological band using real contacts. No fixture cutting.
   for side in [-.30,0.0,.30]:
    for step in [-.62,-.32,0.0,.32,.62]:
     var p:Vector2=lens.centre+Vector2(lens.axes.x*step,lens.axes.y*side).rotated(lens.angle)
     cuts+=open_at(p.round())
     await process_frame
   for side in [-.30,.30]:
    var a:Vector2=lens.centre+Vector2(-lens.axes.x*.70,lens.axes.y*side).rotated(lens.angle)
    var b:Vector2=lens.centre+Vector2(lens.axes.x*.70,lens.axes.y*side).rotated(lens.angle)
    await tool_sweep(a,b,.85,2);await tool_sweep(b,a,.85,2)
   main.feedback.proxies_enabled=false;main.block.show_cursor({"inside":false},1)
   await create_timer(.6).timeout
   await shot("compact-%d-pocket-%d-cavity"%[variant,n])
   check(s.fossil.condition==100,"pocket exploration preserves bone %d/%d"%[variant,n])
   lens_reports.append({"center":str(center),"opening_impacts":cuts,"first_jet_volume":small_volume,"removed_volume":before-main.pocket.remaining_volume()})
   main.feedback.proxies_enabled=true
  await zoom_to(1.3,Vector2(500,330));main.feedback.proxies_enabled=false
  await shot("compact-%d-02-openings"%variant)
  if not quick:
   # A connected working window crosses hard banks and the discovered pockets.
   # Coarse Chisel work stops at the first shell guard; Pick then follows details.
   for y in range(235,385,23):
    for x in range(330,565,23):
     if ((Vector2(x,y)-Vector2(448,307))/Vector2(126,80)).length()>1:continue
     var i:=y*1024+x
     if s.fossil.exposed[i]==0 and s._heights[i]>s.structural_ceilings[i]+.10:
      native_impact(Vector2(x,y),1)
     native_impact(Vector2(x,y),3)
    await process_frame
   await zoom_to(1.9,Vector2(460,320));await settle(10)
   main.feedback.proxies_enabled=false;main.block.show_cursor({"inside":false},1)
   await shot("compact-%d-03-following-form"%variant)
   await complete_demo(0)
   await shot("compact-%d-04-complete"%variant)
  var final_snapshot:Dictionary=main.session.snapshot()
  var impact_count:int=main.controller.total_impacts
  var finished:=state()
  await click(suite.compact_buttons[(variant+1)%3])
  check(suite.confirmation.visible and suite.compact_selected==variant,"changing disposition requires confirmation %d"%variant)
  suite.confirmation.hide()
  check(state()==finished,"cancelling disposition retains work %d"%variant)
  main.reset_specimen();await settle(4)
  await click(suite.buttons[0].get_parent().get_child(3))
  check(suite.confirmation.visible,"restart button protects current disposition %d"%variant)
  await click(suite.confirmation.get_ok_button())
  while suite.busy:await process_frame
  main=suite.preparation;main.display.persist=false;main.controller.set_physics_process(false)
  await settle(4)
  check(suite.compact_selected==variant and main.compact_variant==variant,"restart retains selected disposition %d"%variant)
  check(state()==initial,"reset restores the same exact disposition %d"%variant)
  reports.append({"variant":variant,"lenses":lens_reports,"complete":not quick,"snapshot":final_snapshot,"impacts":impact_count})
 await click(suite.compact_buttons[0])
 check(suite.confirmation.visible,"real disposition selector requests permission")
 await click(suite.confirmation.get_ok_button())
 while suite.busy:await process_frame
 main=suite.preparation;main.display.persist=false;main.controller.set_physics_process(false)
 check(suite.compact_selected==0 and main.compact_variant==0,"real confirmation loads the requested composition")
 await suite.open_demo(1)
 main=suite.preparation
 check(not suite.compact_bar.visible and main.demo_kind==1,"compact selector stays out of marine recipe")
 evidence.results=reports;evidence.checks=checks;evidence.failures=failures
 FileAccess.open(out+("quick.json" if quick else "native.json"),FileAccess.WRITE).store_string(JSON.stringify(evidence,"  "))
 print("ISSUE37 NATIVE ",checks," checks ",failures.size()," failures")
 suite.queue_free();await create_timer(.2).timeout;quit(0 if failures.is_empty() else 1)
func open_at(point:Vector2) -> int:
 var s=main.block.working_map
 var i:=int(point.y)*1024+int(point.x)
 if main.pocket.roofs[i]<=0:return 0
 var cuts:=0
 while s._heights[i]>main.pocket.roofs[i]+.0001 and cuts<12:
  native_impact(point,1);cuts+=1
 return cuts

