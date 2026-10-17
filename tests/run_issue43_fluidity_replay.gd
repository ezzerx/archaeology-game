extends "res://tests/run_issue33_demos.gd"
var label:="before"
var records:Array=[]
func run() -> void:
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--label="):label=arg.trim_prefix("--label=")
 out="res://work/issue43/";DirAccess.make_dir_recursive_absolute(out)
 AudioServer.set_bus_mute(0,true)
 suite=load("res://scenes/experiments/preparation_demos.tscn").instantiate();root.add_child(suite)
 while suite.busy:await process_frame
 for kind in range(3):
  if kind>0:await suite.open_demo(kind)
  main=suite.preparation;main.display.persist=false
  var c=main.controller;c.set_physics_process(false);c.set_process(false)
  main.feedback.set_physics_process(false);main.feedback.set_process(false)
  await zoom_to(2.0,Vector2(500,340));await settle(4)
  c._focused=true;c._pointer_inside=true
  var start:=state()
  var stages:Array=[]
  for tool in [1,2,3,0,4]:
   if tool>=c.tools.size():continue
   c.select_tool(tool);c._focused=true;c._pointer_inside=true
   c._held=true;c.impact_clock.reset();c._previous_valid=false
   var totals:=0;var costs:Array=[]
   var a:=Vector2(410,300);var b:=Vector2(585,395)
   if tool==4:
    a=Vector2(563,403) if kind==1 else Vector2(530,350)
    b=Vector2(601,430) if kind==1 else Vector2(570,367)
   for tick in range(120):
    var fraction:float=.5-.5*cos(float(tick)/119*TAU*2)
    c._screen=at(a.lerp(b,fraction))
    c._physics_process(1.0/60)
    main.session.flush()
    totals+=c.changed_texels
    if c.changed_texels>0:costs.append(c.last_edit_usec/1000.0)
    # Extra visual frames deliberately run between the same physics inputs.
    var original:Vector2=c._screen
    if c.has_method("_process"):
     for frame in range(3):
      c._screen=original+Vector2(frame+1,0);c.call("_process",1.0/240)
    c._screen=original
   c.cancel_stroke();main.block.flush_texture();main.session.flush()
   var snapshot:=state();var s=main.block.working_map
   snapshot.caps=digest(s.crust_caps.to_byte_array());snapshot.grains=s.grains_removed;snapshot.crust=s.crust_removed;snapshot.impacts=c.total_impacts
   costs.sort()
   stages.append({"tool":tool,"state":snapshot,"changed":totals,"edit_p95_ms":costs[floori(costs.size()*.95)] if not costs.is_empty() else 0})
  main.reset_specimen();await settle(3)
  check(state()==start,"deterministic route resets %d"%kind)
  if label!="before":
   c._screen=at(Vector2(450,330));c._focused=true;c._pointer_inside=true
   c._held=true;c._previous_valid=true;c._previous=Vector2(333,222)
   var pristine:=state();var impacts:int=c.total_impacts
   c.call("_process",1.0/240)
   check(c.hit.screen==c._screen and c.hit.inside,"presentation follows latest input before physics %d"%kind)
   main.feedback._process(0.0)
   var proxy=main.feedback.proxies[c.selected_index]
   check(proxy.visible and main.camera.unproject_position(proxy.global_position).distance_to(c._screen)<.05,"tool mesh follows the refreshed contact %d"%kind)
   check(state()==pristine and c.total_impacts==impacts and c._previous==Vector2(333,222) and c._previous_valid,"presentation never edits or breaks stroke continuity %d"%kind)
   c._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT);c.call("_process",0.0)
   check(not c._held and not c.hit.inside,"focus loss clears visual contact %d"%kind)
   c._focused=true;c._pointer_inside=true;c._screen=main.toolbar.get_global_rect().get_center();c.call("_process",0.0)
   check(not c.hit.inside,"toolbar blocks visual contact %d"%kind)
   c._screen=at(Vector2(450,330));c._pointer_inside=false;c.call("_process",0.0)
   check(not c.hit.inside,"window exit clears visual contact %d"%kind)
   c._pointer_inside=true;main.session.archived=true;c.call("_process",0.0)
   check(not c.hit.inside,"archived session blocks visual contact %d"%kind)
  records.append({"kind":kind,"stages":stages})
 if label!="before":
  var baseline:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://docs/dev/evidence/issue43/before-replay.json"))
  for k in range(records.size()):
   for n in range(records[k].stages.size()):
    var old:Dictionary=baseline.records[k].stages[n];var current:Dictionary=records[k].stages[n]
    check(JSON.parse_string(JSON.stringify(current.state))==old.state and current.changed==old.changed,"exact baseline state and removal %d tool %d"%[k,current.tool])
 var result:={"checks":checks,"failures":failures,"records":records}
 FileAccess.open(out+label+"-replay.json",FileAccess.WRITE).store_string(JSON.stringify(result,"  "))
 print("REPLAY ",label," ",checks," checks ",failures.size()," failures")
 suite.queue_free();await create_timer(.2).timeout;quit(0 if failures.is_empty() else 1)
