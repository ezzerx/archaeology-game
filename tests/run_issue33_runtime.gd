extends "res://tests/run_issue33_demos.gd"
var costs:Dictionary={}
var frame_times:Array[float]=[]
func run() -> void:
 out=_output_directory();DirAccess.make_dir_recursive_absolute(out);AudioServer.set_bus_mute(0,true)
 suite=load("res://scenes/experiments/preparation_demos.tscn").instantiate();root.add_child(suite)
 while suite.busy:await process_frame
 main=suite.preparation;main.display.persist=false;main.controller.set_physics_process(false)
 root.mode=Window.MODE_WINDOWED;root.size=Vector2i(1440,810)
 await settle(4)
 var unchanged:=state()
 await click(suite.buttons[1])
 check(suite.confirmation.visible and suite.selected==0,"real selector protects current trial")
 await shot("demo-confirmation")
 suite.confirmation.hide();await process_frame
 check(state()==unchanged and not main.controller._held,"cancel selector preserves work and cancels held tools")
 await click(suite.buttons[1]);await dialog_click(suite.confirmation.get_ok_button())
 while suite.busy:await process_frame
 main=suite.preparation;main.display.persist=false;main.controller.set_physics_process(false)
 check(suite.selected==1 and main.demo_kind==1,"real selector loads granular preparation")
 var chosen_size:=root.size
 await suite.open_demo(2)
 main=suite.preparation;main.display.persist=false;main.controller.set_physics_process(false)
 check(root.size==chosen_size,"changing trial preserves native window size")
 main.controller._focused=true
 var key:=InputEventKey.new();key.physical_keycode=KEY_5;key.pressed=true;root.push_input(key,true);await process_frame
 check(main.controller.config.id==&"abrasive_tip","key 5 selects actual abrasive tool")
 var radius:float=main.controller.config.radius
 key=InputEventKey.new();key.physical_keycode=KEY_F6;key.pressed=true;root.push_input(key,true)
 check(main.controller.config.radius==radius,"old comparison shortcut cannot secretly retune abrasive")
 await zoom_to(2.5,Vector2(515,350))
 for y in range(275,410,22):
  for x in range(430,600,22):native_impact(Vector2(x,y))
  await process_frame
 await timed_sweep(Vector2(440,300),Vector2(590,300),2)
 await timed_sweep(Vector2(590,350),Vector2(440,350),2)
 await timed_sweep(Vector2(440,395),Vector2(590,395),2)
 await timed_sweep(Vector2(453,299),Vector2(482,305),4)
 await timed_sweep(Vector2(531,355),Vector2(571,360),4)
 main.controller.cancel_stroke()
 await create_timer(.8).timeout
 var times:Array[float]=[]
 var previous:=Time.get_ticks_usec()
 for n in range(180):
  await process_frame
  var now:=Time.get_ticks_usec();times.append((now-previous)/1000.0);previous=now
 times.sort()
 var report:={"checks":checks,"failures":failures,"resolution":str(root.size),"idle_frame_p50_ms":times[times.size()/2],"idle_frame_p95_ms":times[floori(times.size()*.95)],"tools":{}}
 for tool in costs:
  var values:Array=costs[tool];values.sort()
  check(not values.is_empty(),"native performance route performs material work: "+tool)
  if values.is_empty():continue
  report.tools[tool]={"active_ticks":values.size(),"edit_p50_ms":values[values.size()/2],"edit_p95_ms":values[floori(values.size()*.95)],"edit_max_ms":values.back()}
 frame_times.sort()
 report.checks=checks
 report.active_render_p95_ms=frame_times[floori(frame_times.size()*.95)]
 FileAccess.open(out+"runtime.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("ISSUE33 RUNTIME ",JSON.stringify(report))
 suite.queue_free();await create_timer(.2).timeout;quit(0 if failures.is_empty() else 1)
func timed_sweep(a:Vector2,b:Vector2,tool:int) -> void:
 main.controller.select_tool(tool);main.controller._focused=true;main.controller._pointer_inside=true
 var press:=InputEventMouseButton.new();press.button_index=MOUSE_BUTTON_LEFT;press.pressed=true;press.position=at(a);root.push_input(press,true)
 var name:String=main.controller.config.id
 if not costs.has(name):costs[name]=[]
 for n in range(60):
  var started:=Time.get_ticks_usec()
  var motion:=InputEventMouseMotion.new();motion.position=at(a.lerp(b,float(n)/59));motion.button_mask=MOUSE_BUTTON_MASK_LEFT
  root.push_input(motion,true);main.controller._physics_process(1.0/60)
  if main.controller.changed_texels>0:costs[name].append(main.controller.last_edit_usec/1000.0)
  await process_frame
  frame_times.append((Time.get_ticks_usec()-started)/1000.0)
 var release:=InputEventMouseButton.new();release.button_index=MOUSE_BUTTON_LEFT;release.pressed=false;release.position=main.controller._screen;root.push_input(release,true)

func dialog_click(button:Button) -> void:
 var target:Viewport=button.get_viewport()
 var press:=InputEventMouseButton.new();press.button_index=MOUSE_BUTTON_LEFT;press.pressed=true;press.position=button.get_global_rect().get_center()
 target.push_input(press,true);await process_frame
 var release:=InputEventMouseButton.new();release.button_index=MOUSE_BUTTON_LEFT;release.pressed=false;release.position=press.position
 target.push_input(release,true);await process_frame
