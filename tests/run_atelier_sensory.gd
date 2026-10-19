extends "res://tests/run_issue33_demos.gd"
func _output_directory() -> String:return "res://work/sensory/"
func same_render(a:Image,b:Image) -> bool:
 # MSAA resolves may round individual color channels by one 8-bit unit when
 # draw batches change. Reject every larger difference, including silhouettes.
 if a.get_size()!=b.get_size():return false
 var left:=a.get_data();var right:=b.get_data()
 if left.size()!=right.size():return false
 for i in range(left.size()):
  if absi(int(left[i])-int(right[i]))>1:return false
 return true
func run() -> void:
 out=_output_directory();DirAccess.make_dir_recursive_absolute(out)
 AudioServer.set_bus_mute(0,true)
 create_timer(180).timeout.connect(func():push_error("Atelier validation timed out");quit(2))
 suite=load("res://scenes/collection/exhibit_workshop.tscn").instantiate();root.add_child(suite)
 while suite.busy:await process_frame
 root.mode=Window.MODE_WINDOWED;root.size=Vector2i(1440,810)
 var samples:Array=[]
 for kind in range(3):
  if kind>0:await suite.open_demo(kind)
  main=suite.preparation;main.controller.set_physics_process(false)
  main.feedback.proxies_enabled=false;main.block.show_cursor({"inside":false},1)
  await settle(20)
  var pristine:=state()
  main.session_ui.notice_label.hide()
  main.process_mode=Node.PROCESS_MODE_DISABLED
  var pixels:Image=await frame_image()
  pixels.save_png(out+"oracle-%d-present.png"%kind)
  main.mesh_view.model.hide();await settle(4)
  var hidden:Image=await frame_image()
  hidden.save_png(out+"oracle-%d-hidden.png"%kind)
  check(same_render(pixels,hidden),"no buried fossil pixels or shadows in preparation %d"%kind)
  main.mesh_view.model.show()
  main.process_mode=Node.PROCESS_MODE_INHERIT
  check(Engine.max_fps==240 and Engine.physics_ticks_per_second==60,"frame/physics targets preserved %d"%kind)
  check(main.controller.tools[1].radius==26 and is_equal_approx(main.controller.tools[1].power,.84),"Chisel approved settings %d"%kind)
  var frame_ms:Array=[];var previous:=Time.get_ticks_usec()
  for frame in range(180):
   await process_frame
   var now:=Time.get_ticks_usec();frame_ms.append((now-previous)/1000.0);previous=now
  frame_ms.sort()
  samples.append({"kind":kind,"idle_frame_p50_ms":frame_ms[90],"idle_frame_p95_ms":frame_ms[171],"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"objects":Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)})
  check(state()==pristine,"idle art and audio cannot mutate preparation %d"%kind)
  main.reset_specimen();await settle(3)
  check(state()==pristine,"reset restores exact initial gameplay %d"%kind)
  # Archive contract: use real tool changes, then persist/reload the frozen mesh.
  for n in range(4):native_impact(Vector2(515,330),1)
  await settle(10)
  main.controller.cancel_stroke();main.feedback.proxies_enabled=false
  main.block.show_cursor({"inside":false},1)
  main.controller._pointer_inside=false
  main.controller._process(0.0)
  main.feedback.reset()
  main.block.show_cursor({"inside":false},1)
  main.mesh_view._process(0.0)
  main._sync_visuals()
  main.process_mode=Node.PROCESS_MODE_DISABLED
  await create_timer(.8).timeout
  var live:Image=await frame_image()
  live.save_png(out+"archive-%d-live.png"%kind)
  var frozen=preload("res://scripts/collection/exhibit_snapshot.gd").new().capture(main)
  var packed:=PackedScene.new()
  check(packed.pack(frozen)==OK,"snapshot packs %d"%kind)
  frozen.free()
  var archive:=out+"render-%d.scn"%kind
  check(ResourceSaver.save(packed,archive,ResourceSaver.FLAG_COMPRESS)==OK,"snapshot saves %d"%kind)
  var restored=load(archive).instantiate()
  root.add_child(restored);restored.global_transform=main.block.global_transform
  main.block.hide();main.mesh_view.hide()
  await settle(5)
  var restored_pixels:Image=await frame_image()
  restored_pixels.save_png(out+"archive-%d-restored.png"%kind)
  check(same_render(live,restored_pixels),"serialized block matches live preparation within 1/255 %d"%kind)
  var bytes:=FileAccess.get_sha256(archive)
  preload("res://scripts/collection/exhibit_display.gd").apply(restored)
  await settle(3)
  check(FileAccess.get_sha256(archive)==bytes,"museum adaptation never rewrites archive %d"%kind)
  restored.free();main.block.show();main.mesh_view.show()
  main.process_mode=Node.PROCESS_MODE_INHERIT
 var result:={"checks":checks,"failures":failures,"renderer":RenderingServer.get_current_rendering_method(),"gpu":RenderingServer.get_video_adapter_name(),"window":str(root.size),"samples":samples}
 FileAccess.open(out+"validation.json",FileAccess.WRITE).store_string(JSON.stringify(result,"  "))
 print("ATELIER VALIDATION ",JSON.stringify(result))
 suite.queue_free();await process_frame;quit(0 if failures.is_empty() else 1)
