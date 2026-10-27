extends "res://tests/run_issue33_demos.gd"
func _output_directory() -> String:return "res://work/sensory/"
func run() -> void:
 out=_output_directory();DirAccess.make_dir_recursive_absolute(out)
 var label:="before"
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--label="):label=arg.trim_prefix("--label=")
 AudioServer.set_bus_mute(0,true)
 suite=load("res://scenes/collection/exhibit_workshop.tscn").instantiate();root.add_child(suite)
 while suite.busy:await process_frame
 root.mode=Window.MODE_WINDOWED;root.size=Vector2i(1440,810)
 for kind in range(3):
  if kind>0:await suite.open_demo(kind)
  main=suite.preparation;main.display.persist=false;main.controller.set_physics_process(false)
  main.feedback.proxies_enabled=false;main.block.show_cursor({"inside":false},1)
  await settle(16)
  await shot(label+"-%d-covered"%kind)
  await zoom_to(1.5 if kind==0 else 1.15,Vector2(515,330));await settle(10)
  for y in range(260,391,26):
   for x in range(420,601,26):
    for n in range(3):native_impact(Vector2(x,y),1)
   await process_frame
  if kind>0:
   for y in [280,330,380]:await tool_sweep(Vector2(425,y),Vector2(610,y),.4,2)
  main.controller.cancel_stroke();main.feedback.proxies_enabled=false;main.block.show_cursor({"inside":false},1)
  await create_timer(.7).timeout;await shot(label+"-%d-working"%kind)
 print("SENSORY CAPTURE ",label," complete")
 suite.queue_free();await process_frame;quit()
