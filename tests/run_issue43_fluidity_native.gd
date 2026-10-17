extends "res://tests/run_issue33_demos.gd"
var label:="before"
var report:Dictionary={}
func _output_directory() -> String:return "res://work/issue43/"
func stats(values:Array) -> Dictionary:
 if values.is_empty():return {"n":0}
 var sorted:=values.duplicate();sorted.sort()
 var total:=0.0
 for v in values:total+=v
 return {"n":values.size(),"mean":total/values.size(),"p50":sorted[sorted.size()/2],"p95":sorted[mini(sorted.size()-1,floori(sorted.size()*.95))],"max":sorted.back()}
func run() -> void:
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--label="):label=arg.trim_prefix("--label=")
 out=_output_directory();DirAccess.make_dir_recursive_absolute(out)
 create_timer(180).timeout.connect(func():push_error("Fluidity timeout");quit(2))
 AudioServer.set_bus_mute(0,true)
 suite=load("res://scenes/experiments/preparation_demos.tscn").instantiate();root.add_child(suite)
 while suite.busy:await process_frame
 root.mode=Window.MODE_WINDOWED;root.size=Vector2i(1440,810)
 report={"label":label,"engine":Engine.get_version_info().string,"renderer":RenderingServer.get_current_rendering_method(),"gpu":RenderingServer.get_video_adapter_name(),"screen_hz":DisplayServer.screen_get_refresh_rate(root.current_screen),"vsync":DisplayServer.window_get_vsync_mode(),"fps_cap":Engine.max_fps,"physics_hz":Engine.physics_ticks_per_second,"window":str(root.size),"input_accumulation":Input.use_accumulated_input,"trials":[]}
 for kind in range(3):
  if kind>0:await suite.open_demo(kind)
  main=suite.preparation;main.display.persist=false
  main.controller.set_physics_process(false)
  await zoom_to(2.2,Vector2(490,340));await settle(30)
  main.controller._focused=true;main.controller._pointer_inside=true
  main.controller.set_physics_process(true)
  var initial:=state()
  var stages:Array=[]
  stages.append(await stage("hover",Vector2(410,300),Vector2(585,375),-1,3.0))
  check(state()==initial,"hover has no preparation side effects %d"%kind)
  stages.append(await stage("chisel",Vector2(410,300),Vector2(580,390),1,3.0))
  stages.append(await stage("blower",Vector2(410,300),Vector2(580,390),2,4.0))
  stages.append(await stage("pick",Vector2(430,315),Vector2(575,375),3,3.0))
  stages.append(await stage("brush",Vector2(430,315),Vector2(575,375),0,3.0))
  if kind>0:
   main.controller.set_physics_process(false)
   var center:=Vector2(582,414) if kind==1 else Vector2(550,358)
   var s=main.block.working_map
   for y in range(int(center.y)-12,int(center.y)+13,6):
    for x in range(int(center.x)-12,int(center.x)+13,6):
     var i:=y*1024+x
     for n in range(25):
      if s._heights[i]<=maxf(s.crust_caps[i],s.structural_ceilings[i])+.001:break
      native_impact(Vector2(x,y),3)
    await process_frame
   main.controller.set_physics_process(true)
   stages.append(await stage("abrasive",center-Vector2(14,0),center+Vector2(14,0),4,3.0))
  if label.begins_with("after"):
   for sample in stages:
    check(sample.stale_frame_fraction<.02 and sample.screen_error_px.max<.05,"render follows current pointer %d %s"%[kind,sample.name])
  report.trials.append({"kind":kind,"stages":stages})
  main.controller.cancel_stroke();await create_timer(.7).timeout
  await shot(label+"-%d"%kind)
 report.checks=checks;report.failures=failures
 FileAccess.open(out+label+".json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("FLUIDITY ",label," ",checks," checks ",failures.size()," failures screen ",report.screen_hz)
 suite.queue_free();await create_timer(.2).timeout;quit(0 if failures.is_empty() else 1)
func stage(name:String,a:Vector2,b:Vector2,tool:int,seconds:float) -> Dictionary:
 var c=main.controller
 c.cancel_stroke();c._focused=true;c._pointer_inside=true
 c.select_tool(maxi(tool,0))
 var first:=at(a);var last:=at(b)
 if tool>=0:
  var press:=InputEventMouseButton.new();press.button_index=MOUSE_BUTTON_LEFT;press.pressed=true;press.position=first;root.push_input(press,true)
 var times:Array=[];var errors:Array=[];var edits:Array=[];var picks:Array=[];var uploads:Array=[];var proxies:Array=[]
 var previous_position:=Vector2(INF,INF);var moved:=0;var frames:=0;var edits_count:=0
 var begin:=Time.get_ticks_usec();var previous:=begin;var physics:=Engine.get_physics_frames()
 while (Time.get_ticks_usec()-begin)/1000000.0<seconds:
  await process_frame
  var t:float=(Time.get_ticks_usec()-begin)/1000000.0
  var point:=first.lerp(last,.5-.5*cos(t*TAU/1.5))
  var motion:=InputEventMouseMotion.new();motion.position=point;motion.button_mask=MOUSE_BUTTON_MASK_LEFT if tool>=0 else 0
  root.push_input(motion,true)
  await RenderingServer.frame_post_draw
  var now:=Time.get_ticks_usec();times.append((now-previous)/1000.0);previous=now;frames+=1
  var actual:Vector2=c.hit.screen
  errors.append(actual.distance_to(point)*float(root.size.x)/1920.0)
  if actual!=previous_position:moved+=1
  previous_position=actual
  proxies.append(main.feedback.last_proxy_usec/1000.0)
  if Engine.get_physics_frames()!=physics:
   physics=Engine.get_physics_frames();picks.append(c.last_pick_usec/1000.0)
   if c.changed_texels>0:edits.append(c.last_edit_usec/1000.0);edits_count+=1
   uploads.append((main.block.last_upload_usec+main.block.last_film_upload_usec+main.block.last_residue_upload_usec+main.block.last_fracture_upload_usec)/1000.0)
 var duration:float=(Time.get_ticks_usec()-begin)/1000000.0
 c.cancel_stroke()
 var entry:={"name":name,"seconds":duration,"frames":frames,"fps":frames/duration,"contact_updates_per_second":moved/duration,"stale_frame_fraction":1.0-float(moved)/frames,"screen_error_px":stats(errors),"frame_ms":stats(times),"edit_ms":stats(edits),"pick_ms":stats(picks),"upload_ms":stats(uploads),"proxy_ms":stats(proxies),"active_ticks":edits_count}
 print("STAGE ",name," fps ",snapped(entry.fps,.1)," updates ",snapped(entry.contact_updates_per_second,.1)," frame95 ",entry.frame_ms.p95," edit95 ",entry.edit_ms.get("p95",0))
 return entry
