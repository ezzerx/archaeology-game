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
  var field=main.block.working_map.fossil.field
  var mask:=PackedByteArray();mask.resize(field.component_ids.size())
  for i in range(mask.size()):mask[i]=1 if field.component_ids[i]>0 else 0
  # Golden silhouette of the accepted compact M08 at main 0f505af.
  check(digest(mask)=="aea779caec991bc4586c5eed422c3c7bcdbf23f3cb4c2526f16ee26d720d104e","original compact spiral footprint is exactly preserved")
 await super.complete_demo(kind)
 if kind==1:
  var s=main.block.working_map
  var crest:=-1;var trough:=-1
  # Short arc across adjacent costae on ONE whorl, not between spiral turns.
  for n in range(81):
   var t:=lerpf(20.26,20.49,float(n)/80)
   var r:=4.0*exp(.13*t);var theta:=t-1.05
   var p:=Vector2i(roundi(532+r*cos(theta)),roundi(333+r*sin(theta)))
   var i:=p.y*1024+p.x
   if crest<0 or s.structural_ceilings[i]>s.structural_ceilings[crest]:crest=i
   if trough<0 or s.structural_ceilings[i]<s.structural_ceilings[trough]:trough=i
  var levels:Array[float]=[]
  var contacts:Array[Dictionary]=[]
  main.feedback.proxies_enabled=true
  await zoom_to(3.5,Vector2(535,350))
  for i in [crest,trough]:
   var p:=Vector2(i%1024,i/1024)
   native_impact(p,3);await settle(4)
   var hit:Dictionary=main.controller.hit
   check(hit.get("inside",false) and hit.map.distance_to(p)<2,"native Pick reaches the intended small rib or trough")
   levels.append(main.block.to_local(hit.world).y)
   check(main.feedback.proxies[3].global_position.distance_to(hit.world)<.0001,"visible Pick tip stays at the actual contact")
   contacts.append({"map":str(p),"local_height_m":levels[-1],"baked_height_m":.018+s.structural_ceilings[i]*.102})
  var distance:=Vector2(crest%1024,crest/1024).distance_to(Vector2(trough%1024,trough/1024))
  check(distance>=4 and distance<=16,"measured crest and trough are neighboring small waves")
  check(levels[0]-levels[1]>.005,"at least 5 mm of real Pick descent between adjacent costae")
  check(s.fossil.condition==100,"following the small ribs preserves shell condition")
  evidence.rib_contacts=contacts;evidence.rib_contact_distance_texels=distance
  await shot("small-ribs-pick-contact-native")
  main.feedback.proxies_enabled=false
