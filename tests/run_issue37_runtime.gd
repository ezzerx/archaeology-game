extends "res://tests/run_issue33_runtime.gd"
func _output_directory() -> String:return "res://work/issue37/"
func run() -> void:
 out=_output_directory();DirAccess.make_dir_recursive_absolute(out);AudioServer.set_bus_mute(0,true)
 root.size=Vector2i(1440,810)
 suite=load("res://scenes/experiments/preparation_demos.tscn").instantiate();root.add_child(suite)
 while suite.busy:await process_frame
 await suite.open_demo(0,1)
 main=suite.preparation;main.display.persist=false;main.controller.set_physics_process(false)
 root.mode=Window.MODE_WINDOWED;root.size=Vector2i(1440,810)
 var lens=main.profile.lenses[0]
 var center:Vector2=lens.centre.round()
 await zoom_to(3.2,center)
 var impact_costs:Array[float]=[]
 for side in [-.28,.14,.45]:
  for along in [-.60,-.25,.10,.45]:
   var p:Vector2=(lens.centre+Vector2(lens.axes.x*along,lens.axes.y*side).rotated(lens.angle)).round()
   var i:=int(p.y)*1024+int(p.x)
   for n in range(8):
    if main.block.working_map._heights[i]<=main.pocket.roofs[i]+.0001:break
    var started:=Time.get_ticks_usec()
    native_impact(p)
    impact_costs.append((Time.get_ticks_usec()-started)/1000.0)
    await process_frame
 main.feedback.proxies_enabled=false;main.block.show_cursor({"inside":false},1)
 await settle(5);await shot("compact-grains-discovered")
 main.feedback.proxies_enabled=true
 var axis:=Vector2(1,0).rotated(lens.angle)
 await tool_sweep(center-axis*25,center-axis*10,.12,2)
 await shot("compact-grains-in-motion")
 var grain_count:int=main.feedback.grains.size()
 check(grain_count>0 and grain_count<=176,"validated bounded particles visibly accompany real removal")
 var flow_times:Array[float]=[]
 main.controller.select_tool(2);main.controller._focused=true;main.controller._pointer_inside=true
 var start:=center-axis*48;var finish:=center+axis*48
 var press:=InputEventMouseButton.new();press.button_index=MOUSE_BUTTON_LEFT;press.pressed=true;press.position=at(start);root.push_input(press,true)
 for n in range(120):
  var previous:float=main.pocket.blown_volume
  var motion:=InputEventMouseMotion.new();motion.position=at(start.lerp(finish,float(n)/119));motion.button_mask=MOUSE_BUTTON_MASK_LEFT
  root.push_input(motion,true);main.controller._physics_process(1.0/60)
  if main.pocket.blown_volume>previous:flow_times.append(main.pocket.flow_usec/1000.0)
  await process_frame
 var release:=InputEventMouseButton.new();release.button_index=MOUSE_BUTTON_LEFT;release.pressed=false;release.position=main.controller._screen;root.push_input(release,true)
 check(flow_times.size()>10 and impact_costs.size()>10,"performance samples include actual compact-material work")
 main.feedback.proxies_enabled=false;main.block.show_cursor({"inside":false},1)
 await create_timer(.8).timeout;await shot("compact-working-cavity-detail")
 check(main.feedback.grains.is_empty(),"released jet leaves no persistent visual grain clutter")
 impact_costs.sort();flow_times.sort()
 var report:={"checks":checks,"failures":failures,"resolution":str(root.size),"disposition":1,"particles_in_capture":grain_count,
 "native_impact_samples":impact_costs.size(),"native_impact_p95_ms":impact_costs[floori(impact_costs.size()*.95)],
 "pocket_flow_samples":flow_times.size(),"pocket_flow_p95_ms":flow_times[floori(flow_times.size()*.95)],
 "note":"Native controlled gesture on the largest total pocket layout; no whole-game FPS claim."}
 FileAccess.open(out+"compact-runtime.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("ISSUE37 RUNTIME ",JSON.stringify(report))
 suite.queue_free();await create_timer(.2).timeout;quit(0 if failures.is_empty() else 1)

