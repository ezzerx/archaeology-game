extends "res://tests/run_issue33_runtime.gd"
var encounters_report:Array[Dictionary]=[]
func _output_directory() -> String:return "res://work/issue39/"
func key(code:int,echo:=false) -> void:
 var event:=InputEventKey.new();event.physical_keycode=code;event.pressed=true;event.echo=echo
 root.push_input(event,true)
 event=InputEventKey.new();event.physical_keycode=code;event.pressed=false
 root.push_input(event,true)
 await process_frame
func quiet() -> void:
 main.controller.cancel_stroke();main.feedback.proxies_enabled=false
 main.block.show_cursor({"inside":false},1)
 main.session_ui.notice_label.hide()
 await create_timer(.65).timeout

func run() -> void:
 out=_output_directory();DirAccess.make_dir_recursive_absolute(out);AudioServer.set_bus_mute(0,true)
 root.size=Vector2i(1440,810)
 suite=load("res://scenes/experiments/preparation_demos.tscn").instantiate();root.add_child(suite)
 while suite.busy:await process_frame
 await suite.open_demo(2)
 main=suite.preparation;main.display.persist=false;main.controller.set_physics_process(false)
 root.mode=Window.MODE_WINDOWED;root.size=Vector2i(1440,810)
 main.controller._focused=true;main.controller._pointer_inside=true
 var s=main.block.working_map
 var initial:=state()
 var original_caps:PackedFloat32Array=s.crust_caps.duplicate()
 var geometry:=[]
 var covered_count:=0
 for zone in range(1,4):
  var cells:=0;var minimum:=INF;var maximum:=0.0;var cover:=INF
  for i in range(s.crust_caps.size()):
   if main.profile.encounter_ids[i]!=zone:continue
   cells+=1
   minimum=minf(minimum,s.crust_caps[i]-s.structural_ceilings[i])
   maximum=maxf(maximum,s.crust_caps[i]-s.structural_ceilings[i])
   cover=minf(cover,s._heights[i]-s.crust_caps[i])
  covered_count+=cells
  check(cells>400 and maximum>minimum*2 and cover>.035,"encounter %d has real relief and initial burial"%zone)
  geometry.append({"zone":zone,"cells":cells,"thickness_mm":[minimum*102,maximum*102],"minimum_cover_mm":cover*102})
 check(covered_count<float(s.fossil.field.total_cells)*.20,"most of shell remains free of adherent deposits")
 check(main.toolbar.get_child_count()==4,"one finishing slot, four toolbar slots")
 await key(KEY_1);check(main.controller.selected_index==0,"first return selects Brush")
 await key(KEY_1,true);check(main.controller.selected_index==0,"key repeat does not cycle")
 await key(KEY_1);check(main.controller.selected_index==4,"fresh key 1 cycles to abrasive")
 await key(KEY_2);await key(KEY_1)
 check(main.controller.selected_index==4,"return from another family remembers abrasive")
 check(main.finishing_button.text.begins_with("[1] Pointe abrasive"),"toolbar displays active abrasive immediately")
 await key(KEY_KP_1);check(main.controller.selected_index==0,"keypad 1 cycles to Brush")
 check(main.finishing_button.text.begins_with("[1] Brush"),"toolbar displays active Brush immediately")
 await key(KEY_3);await key(KEY_5)
 check(main.controller.selected_index==2,"old key 5 cannot select hidden fifth slot")
 await click(main.finishing_button);check(main.controller.selected_index==0,"real toolbar recalls finishing variant")
 await click(main.finishing_button);check(main.controller.selected_index==4 and main.finishing_button.button_pressed,"real toolbar cycles and highlights abrasive")
 main.controller._held=true;await key(KEY_1)
 check(not main.controller._held,"changing variant cancels current stroke")
 suite.choose(1);await key(KEY_1)
 check(main.controller.selected_index==0 and not main.controller._held,"modal blocks family keys")
 await key(KEY_2);check(main.controller.selected_index==0,"modal blocks other tool keys")
 suite.confirmation.hide();await process_frame
 check(state()==initial,"keyboard and toolbar selection never excavate")
 await zoom_to(2.5,Vector2(515,350));await quiet()
 var before:Image=await frame_image()
 main.mesh_view.model.hide();await settle(4)
 var no_model:Image=await frame_image()
 check(before.get_data()==no_model.get_data(),"intact cover hides fossil pixels and shadow")
 main.mesh_view.model.show()
 var zero:=ImageTexture.create_from_image(Image.create(1024,640,false,Image.FORMAT_RGBAF))
 for mat in [main.block.material,main.block.skirt_material]:mat.set_shader_parameter("demo_crust",zero)
 var no_crust:Image=await frame_image()
 check(before.get_data()==no_crust.get_data(),"intact cover never prints mineral deposits")
 for mat in [main.block.material,main.block.skirt_material]:mat.set_shader_parameter("demo_crust",main.profile.crust)
 await shot("01-covered")
 var sealed:PackedFloat32Array=s._heights.duplicate()
 await tool_sweep(Vector2(450,300),Vector2(575,380),.5,4)
 await tool_sweep(Vector2(450,300),Vector2(575,380),.5,2)
 check(sealed==s._heights,"air and abrasive cannot cross intact cover")
 main.feedback.proxies_enabled=true
 for y in range(270,435,23):
  for x in range(425,610,23):
   if ((Vector2(x,y)-Vector2(515,345))/Vector2(98,87)).length()>1:continue
   native_impact(Vector2(x,y));await process_frame
 for y in [287,325,365,405,430]:
  await tool_sweep(Vector2(425,y),Vector2(612,y),.8,2)
  await tool_sweep(Vector2(612,y),Vector2(425,y),.8,2)
 await quiet();await shot("02-three-encounters")
 check(s.crust_caps==original_caps,"opening and air retain every adherent deposit")
 for k in range(3):
  var encounter:Dictionary=main.profile.encounters[k]
  var a:Vector2=encounter.from;var b:Vector2=encounter.to
  await zoom_to(3.0,encounter.center)
  await quiet();await shot("encounter-%d-before"%k)
  var pre:=zone_volume(k+1)
  main.feedback.proxies_enabled=true
  await tool_sweep(a,a.lerp(b,.3),.12,4)
  await shot("encounter-%d-contact"%k)
  var partial:=zone_volume(k+1)
  check(partial<pre and partial>0,"short stroke visibly erodes part of encounter %d"%k)
  for n in range(3):
   var from:Vector2=a if n%2==0 else b
   var to:Vector2=b if n%2==0 else a
   await timed_sweep(from,to,4)
  await quiet();await shot("encounter-%d-eroded"%k)
  var remaining:=zone_volume(k+1)
  check(remaining<pre*.45,"three short passes reveal most encounter %d"%k)
  check(main.feedback.abrasion_bursts>0,"real abrasion produces transient grit %d"%k)
  main.feedback.proxies_enabled=true
  await tool_sweep(a,b,.55,0);await tool_sweep(b,a,.55,0)
  await quiet();await shot("encounter-%d-brushed"%k)
  encounters_report.append({"name":encounter.name,"initial_volume":pre,"after_short_contact":partial,"after_three_passes":remaining})
 await zoom_to(2.5,Vector2(515,350));await quiet();await shot("03-restored-details")
 check(s.fossil.condition==100,"finishing gestures preserve condition")
 # The shared completion route expects an unbrushed start; the art route above
 # intentionally brushes after each encounter. Start a separate native run.
 main.reset_specimen();await settle(5)
 await complete_demo(2)
 var completed:Dictionary=main.session.snapshot()
 await create_timer(.9).timeout
 check(main.feedback.particles[2].is_empty() and main.feedback.particles[3].is_empty(),"mineral grit and dust disappear after release")
 await key(KEY_4);await key(KEY_1)
 var before_archive:int=main.controller.selected_index
 main.session.archive()
 await key(KEY_1)
 check(main.controller.selected_index==before_archive,"archived preparation blocks family switching")
 main.reset_specimen();await settle(5)
 check(state()==initial and s.crust_caps==original_caps,"reset restores exact geometry and deposits")
 check(main.controller.finishing_variant==0,"reset selects Brush as remembered variant")
 var report:={"checks":checks,"failures":failures,"encounters":encounters_report,"costs":{},"captures":evidence.captures,"geometry":geometry,"final_snapshot":completed}
 for name in costs:
  var values:Array=costs[name];values.sort()
  report.costs[name]={"samples":values.size(),"p95_ms":values[floori(values.size()*.95)]}
 await suite.open_demo(1)
 main=suite.preparation;main.display.persist=false;main.controller.set_physics_process(false)
 main.controller._focused=true;await key(KEY_1);await key(KEY_1)
 check(main.controller.selected_index==4 and main.toolbar.get_child_count()==4 and main.controller.has_finishing_family(),"marine late nodules use the existing finishing family")
 await suite.open_demo(0)
 main=suite.preparation;main.display.persist=false;main.controller.set_physics_process(false)
 main.controller._focused=true;await key(KEY_1);await key(KEY_1)
 check(main.controller.selected_index==0 and main.toolbar.get_child_count()==4 and not main.controller.has_finishing_family(),"compact earth keeps its single Brush slot")
 report.checks=checks;report.failures=failures
 FileAccess.open(out+"native.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("ISSUE39 NATIVE ",JSON.stringify(report))
 suite.queue_free();await create_timer(.2).timeout;quit(0 if failures.is_empty() else 1)

func zone_volume(zone:int) -> float:
 var total:=0.0
 var s=main.block.working_map
 for i in range(s.crust_caps.size()):
  if main.profile.encounter_ids[i]==zone and s.crust_caps[i]>0:total+=s.crust_caps[i]-s.structural_ceilings[i]
 return total
