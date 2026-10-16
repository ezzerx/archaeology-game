extends "res://tests/run_issue33_demos.gd"
## Art references use an explicitly staged identical cut. Native runs are separate.
func _output_directory() -> String:return "res://work/issue35/"
func run() -> void:
 if "--native" in OS.get_cmdline_user_args():
  await super.run();return
 out=_output_directory();DirAccess.make_dir_recursive_absolute(out)
 AudioServer.set_bus_mute(0,true)
 root.size=Vector2i(1440,810)
 main=load("res://scenes/experiments/demo_preparation.tscn").instantiate()
 main.specimen_id="M08";main.demo_kind=1
 main.get_node("ExcavationBlock").specimen_id="M08";main.get_node("ExcavationBlock").demo_kind=1
 root.add_child(main)
 main.display.persist=false;main.controller.set_physics_process(false)
 root.mode=Window.MODE_WINDOWED;root.size=Vector2i(1440,810)
 await settle(15);await zoom_to(2.5,Vector2(520,350))
 await art_reference()
 main.queue_free();await create_timer(.2).timeout;quit()
func art_reference() -> void:
 var s=main.block.working_map
 var exposed:=PackedInt32Array()
 for y in range(240,448):
  for x in range(398,639):
   if ((Vector2(x,y)-Vector2(518,344))/Vector2(120,103)).length()>1:continue
   var i:=y*1024+x
   s._heights[i]=s.structural_ceilings[i] if s.structural_ceilings[i]>0 else .12
   if s.structural_ceilings[i]>0:exposed.append(i)
 s.image.set_data(1024,640,false,Image.FORMAT_RF,s._heights.to_byte_array());s.dirty=true
 s.fossil.expose_cells(exposed);P5Fixture.clean(s)
 main.controller._pointer_inside=false;main.controller._focused=false
 main.feedback.proxies_enabled=false;main.session_ui.notice_label.hide();main.material_hint.hide()
 main.block.show_cursor({"inside":false},1)
 await settle(20)
 var label:="candidate"
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--art-label="):label=arg.trim_prefix("--art-label=")
 await shot(label+"-art-reference-staged")

func complete_demo(kind:int) -> void:
 if kind==1:
  geometry_checks()
  var s=main.block.working_map
  var target:=-1
  for y in range(300,370):
   for x in range(495,568):
    var i:=y*1024+x
    if s.structural_ceilings[i]>0 and s.structural_ceilings[i]<.19 and s.fossil.exposed[i]==0:
     target=i;break
   if target>=0:break
  check(target>=0,"marine air leaves a real recessed shell flank to finish with Pick")
  if target>=0:
   var p:=Vector2(target%1024,target/1024)
   var before:float=s._heights[target]
   for n in range(20):
    if s.fossil.exposed[target]!=0:break
    native_impact(p,3);await process_frame
   check(s.fossil.exposed[target]!=0 and s._heights[target]<before,"native Pick reaches a recessed flank after air")
   check(absf(s._heights[target]-s.structural_ceilings[target])<.00002,"recess stops at its actual shell height")
   main.feedback.proxies_enabled=true
   await settle(8);await shot("marine-pick-recess-native")
 await super.complete_demo(kind)
 if kind==1:
  var s=main.block.working_map
  var outer:=-1;var inner:=-1
  for i in range(s.structural_ceilings.size()):
   var region:int=s.fossil.field.component_ids[i]
   if region==1 and (outer<0 or s.structural_ceilings[i]>s.structural_ceilings[outer]):outer=i
   if region==3 and (inner<0 or s.structural_ceilings[i]>s.structural_ceilings[inner]):inner=i
  var levels:Array[float]=[]
  var contacts:Array[Dictionary]=[]
  for i in [outer,inner]:
   var p:=Vector2(i%1024,i/1024)
   native_impact(p,3)
   var hit:Dictionary=main.controller.hit
   check(hit.get("inside",false) and hit.map.distance_to(p)<2,"native Pick ray reaches the intended whorl")
   levels.append(main.block.to_local(hit.world).y)
   contacts.append({"map":str(p),"local_height_m":levels[-1],"baked_height_m":.018+s.structural_ceilings[i]*.102})
  check(levels[0]-levels[1]>.020,"outer whorl stands at least 20 mm above the umbilical turn at actual tool contact")
  check(s.fossil.condition==100,"recess and crest Pick contacts preserve shell condition")
  evidence.relief_contacts=contacts
