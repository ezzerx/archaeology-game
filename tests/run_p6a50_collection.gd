extends "res://tests/run_p6a49_pocket_finish.gd"
var flow:Node
var clicks:=0
func click(button:Button) -> void:
 var event:=InputEventMouseButton.new();event.button_index=MOUSE_BUTTON_LEFT;event.pressed=true;event.position=button.get_global_rect().get_center()
 root.push_input(event,true);await process_frame
 event=InputEventMouseButton.new();event.button_index=MOUSE_BUTTON_LEFT;event.pressed=false;event.position=button.get_global_rect().get_center()
 root.push_input(event,true);await process_frame
 clicks+=1
func idle() -> void:
 for frame in range(2400):
  if not flow.busy:break
  await process_frame
 check(not flow.busy,"asynchronous flow finishes")
func _expected_source_pieces() -> int:return 1 if main.specimen_id=="M08" else 49
func _selected_native(_field:FossilField,_native:FossilField,_i:int) -> bool:return true
func _output_directory() -> String:return "res://work/test-logs/p6a50/"
func shot(name:String) -> void:
 await process_frame;await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(out+name+".png")
func run() -> void:
 out=_output_directory();DirAccess.make_dir_recursive_absolute(out)
 mode=OS.get_cmdline_user_args()[0] if not OS.get_cmdline_user_args().is_empty() else "smoke"
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--distinction-store="):DirAccess.make_dir_recursive_absolute(arg.trim_prefix("--distinction-store=").get_base_dir())
 AudioServer.set_bus_mute(0,true)
 root.size=Vector2i(1280,720)
 flow=load("res://scenes/collection.tscn").instantiate();root.add_child(flow)
 flow.store=preload("res://scripts/collection/collection_store.gd").new(out+"flow-"+str(Time.get_ticks_usec())+"/records.json",out+"no-legacy.json")
 flow.hub.store=flow.store
 if mode!="tests":await shot("01-depot")
 await flow.open_specimen("M08")
 main=flow.preparation
 main.display.persist=false
 root.mode=Window.MODE_WINDOWED;root.size=Vector2i(1280,720)
 main.controller.set_physics_process(false)
 await settle()
 if mode=="tests":
  geometry_checks()
  var s:WorkingSurface=main.block.working_map
  var initial:=state()
  var uncovered:=0
  for i in range(s.fossil.field.component_ids.size()):
   if s.fossil.field.component_ids[i]>0 and s._heights[i]<=s.structural_ceilings[i]+.0001:uncovered+=1
  check(uncovered==0,"M08 starts entirely buried")
  check(s.fossil.field.total_cells>18000 and s.fossil.field.total_cells<30000,"M08 field is the authored compact fossil")
  check(main.pocket.layout.present,"M08 admits a safe buried pocket")
  check(main.session.snapshot().classification=="Indéterminé","M08 starts unidentified")
  flow.show_hub();flow.resume()
  check(initial==state(),"visiting collection and resuming preserves complete excavation state")
  var outside:=0
  for i in main.block.footprint.outside:
   if s.fossil.field.component_ids[i]!=0 or s._heights[i]!=0:outside+=1
  check(outside==0,"compact footprint contains the full fossil and no material outside")
  var unsafe:=0
  for i in main.pocket.layout.cells:
   if main.pocket.floors[i]<s.structural_ceilings[i]+.018 or s._heights[i]<main.pocket.roofs[i]:unsafe+=1
  check(unsafe==0,"marine pocket stays covered and above every shell ceiling")
  check(main.controller.tools[1].radius==26 and is_equal_approx(main.controller.tools[1].power,.84),"Chisel feeling is unchanged")
  check(main.controller.tools[3].radius==11 and is_equal_approx(main.controller.tools[3].power,.44),"Pick feeling is unchanged")
  check(is_equal_approx(s.bone_film.moving_clear_multiplier,2.4) and is_equal_approx(s.bone_film.stationary_clear_multiplier,.35),"validated Brush movement remains unchanged")
  check(s.fossil.field.component_name(1)=="Tour extérieur" and s.fossil.field.component_name(4)=="Ouverture","shell feedback names its own anatomy")
  P5Fixture.reveal(s,[100,100,100,100]);main.block.flush_texture();main.session.flush()
  var point:=Vector2(480,350)
  var index:=s.fossil.field.index_at_map(point)
  if s.fossil.field.component_ids[index]==0:
   for i in range(s.fossil.field.component_ids.size()):
    if s.fossil.field.component_ids[i]!=1:continue
    index=i;point=Vector2(i%1024,i/1024);break
  native_impact(point,1)
  check(s.fossil.condition==100,"first direct shell contact retains the protection rule")
  native_impact(point,1)
  check(s.fossil.condition<100 and main.local_damage.marks.size()==1,"damaging contact creates one local shell scar")
  var remote:PackedByteArray=main.local_damage.image.get_region(Rect2i(650,100,150,150)).get_data()
  check(remote.count(0)==remote.size(),"local shell damage does not crack remote matrix")
  main.reset_specimen();await settle()
  check(main.local_damage.marks.is_empty() and s.fossil.condition==100,"reset clears localized marks and restores condition")
  flow.show_hub("gallery");flow.choose_specimen("B17")
  check(flow.confirmation!=null and main.specimen_id=="M08","switching an unfinished preparation requires an explicit in-game choice")
  flow.close_confirmation();flow.resume()
  check(main.specimen_id=="M08" and not flow.hub.root_control.visible,"cancelling another crate returns safely to existing work")
 else:
  await shot("02-m08-covered")
  if mode=="visual":await loop_visual()
  else:await art_visual()
 evidence.collection_path=flow.store.path
 evidence.checks=checks;evidence.failures=failures
 FileAccess.open(out+mode+".json",FileAccess.WRITE).store_string(JSON.stringify(evidence,"  "))
 print("P6A50 ",mode," ",checks," checks ",failures.size()," failures")
 flow.queue_free();await create_timer(.3).timeout
 quit(0 if failures.is_empty() else 1)
func art_visual() -> void:
  await zoom_to(1.8,Vector2(515,365))
  main.prepare_native_skeleton_review()
  await settle(15)
  await shot("03-m08-native-pick")
  var s:WorkingSurface=main.block.working_map
  # Clearly staged clean-art review, independent from the real stroke pacing run.
  P5Fixture.clean(s);main.block.flush_texture();main.session.flush()
  await shot("04-m08-art-review")

func loop_visual() -> void:
 var s:WorkingSurface=main.block.working_map
 var baseline:=state()
 main.feedback.proxies_enabled=false
 main.block.show_cursor({"inside":false},1)
 main.session_ui.notice_label.hide()
 await settle(20)
 var before:Image=await skull_picture("sealed-mesh")
 main.toggle_mesh()
 var after:Image=await skull_picture("sealed-relief")
 check(before.get_data()==after.get_data(),"M08 buried mesh and exposed-only shadows reveal no pixels")
 main.toggle_mesh();main.session_ui.notice_label.show()
 check(state()==baseline,"visibility comparison leaves all working state unchanged")
 var impacts:=0
 for n in range(8):
  native_impact(Vector2(495,327));impacts+=1
  if s.fossil.exposed_cells>0:break
 await settle(15)
 check(impacts<=4 and s.fossil.exposed_cells>0,"first real chisel contact finds the shell within four blows")
 check(s.fossil.condition==100,"first discovery remains protected")
 evidence.first_contact_impacts=impacts
 await shot("05-first-discovery")
 # Ordered sweep uses real Pick contacts; no reveal/clean fixtures in this path.
 var picks:=0
 for y in range(264,430,8):
  for x in range(420,610,8):
   var i:=y*1024+x
   if s.fossil.field.component_ids[i]==0:continue
   for repeat in range(3):
    if s.fossil.exposed[i]!=0:break
    native_impact(Vector2(x,y),3);picks+=1
 for i in range(s.fossil.exposed.size()):
  if s.fossil.field.component_ids[i]==0 or s.fossil.exposed[i]!=0:continue
  @warning_ignore("integer_division")
  var point:=Vector2(i%1024,i/1024)
  for repeat in range(4):
   if s.fossil.exposed[i]!=0:break
   native_impact(point,3);picks+=1
 await settle(20)
 check(s.fossil.exposure_percent()>=99,"native Pick can expose the entire second asset including its tight centre")
 check(s.fossil.condition==100,"native Pick preserves shell condition")
 check(main.session.snapshot().classification=="Ammonite côtelée","classification recognizes shell anatomy rather than a vertebrate")
 evidence.pick_impacts=picks
 main.feedback.proxies_enabled=true
 for row in [275,300,325,350,375,400,425]:
  await brush_sweep(Vector2(430,row),Vector2(610,row),.8)
  await brush_sweep(Vector2(610,row),Vector2(430,row),.8)
 await settle(35)
 check(s.bone_film.cleanliness_percent()>=99,"short back-and-forth Brush traces finish real shell film")
 check(main.session.preparation_complete and main.distinction.earned,"second specimen earns integral distinction through real tools")
 evidence.native_snapshot=main.session.snapshot()
 await zoom_to(2.5,Vector2(520,350))
 main.feedback.proxies_enabled=false;main.controller.cancel_stroke();main.block.show_cursor({"inside":false},1)
 await shot("06-native-ammonite-complete")
 var prepared:=state()
 await click(main.collection_button)
 check(flow.hub.root_control.visible,"actual Collection click opens gallery")
 await shot("07-empty-gallery-during-work")
 await click(flow.hub.resume_button)
 check(not flow.hub.root_control.visible and state()==prepared,"actual return click restores current work without losing any state")
 var good_path:String=flow.store.path
 DirAccess.make_dir_recursive_absolute(good_path.get_base_dir())
 var blocker:String=good_path.get_base_dir()+"/blocked"
 FileAccess.open(blocker,FileAccess.WRITE).store_string("deliberately unwritable destination")
 flow.store.path=blocker+"/records.json"
 await click(main.session_ui.archive_button)
 await idle()
 check(main.session.archived and not flow.saved_archive and main.session_ui.another_button.text.begins_with("Réessayer"),"save failure retains finished work and offers an explicit retry")
 flow.show_hub("gallery")
 await click(flow.hub.item_buttons.B17)
 check(flow.preparation==main and flow.hub.resume_button.visible,"failed save cannot be discarded by choosing the next crate")
 await click(flow.hub.resume_button)
 flow.store.path=good_path
 await click(main.session_ui.another_button)
 await idle()
 check(main.session.archived and flow.saved_archive,"actual archive click persists M08 before permitting the next crate")
 check(flow.store.records.has("M08") and flow.store.records.M08.snapshot.condition==100,"collection receives actual preserved state")
 await shot("08-archive-confirmation")
 await click(main.session_ui.another_button)
 check(flow.hub.root_control.visible and flow.hub.photos.has("M08"),"actual end-of-preparation action shows the player's photograph")
 await shot("09-first-collection")
 var photo:TextureRect=flow.hub.photos.M08
 var photo_click:=InputEventMouseButton.new();photo_click.button_index=MOUSE_BUTTON_LEFT;photo_click.pressed=true;photo_click.position=photo.get_global_rect().get_center()
 root.push_input(photo_click,true);await process_frame
 photo_click=InputEventMouseButton.new();photo_click.button_index=MOUSE_BUTTON_LEFT;photo_click.pressed=false;photo_click.position=photo.get_global_rect().get_center();root.push_input(photo_click,true)
 check(flow.hub.viewer!=null,"clicking the archived photograph opens a readable detail view")
 await shot("09b-archived-detail")
 await click(flow.hub.view_close)
 check(flow.hub.viewer==null,"detail view closes back to the same collection")
 root.size=Vector2i(1440,900)
 await process_frame;await process_frame
 var chosen_window:Vector2i=root.size
 await click(flow.hub.item_buttons.B17)
 await idle()
 check(root.size==chosen_window and root.mode==Window.MODE_WINDOWED,"switching crates preserves the player's actual window size and mode")
 main=flow.preparation;main.display.persist=false;main.controller.set_physics_process(false)
 root.mode=Window.MODE_WINDOWED;root.size=Vector2i(1280,720)
 await settle(10)
 check(main.specimen_id=="B17" and main.block.working_map.fossil.field.total_cells==25404,"actual next-crate click loads the unchanged B17 source")
 await shot("10-next-b17")
 # QA completion fixture to verify the second archive, separately from native M08 work.
 main.prepare_native_skeleton_review()
 P5Fixture.clean(main.block.working_map);main.block.flush_texture();main.session.flush()
 await settle(8)
 await click(main.session_ui.archive_button);await idle()
 check(flow.saved_archive and flow.store.records.size()==2,"both specimen types archive to independent collection places")
 await click(main.session_ui.another_button)
 await shot("11-two-piece-collection")
 var restored=preload("res://scripts/collection/collection_store.gd").new(flow.store.path,out+"no-legacy.json")
 check(restored.records.size()==2 and restored.badge("M08"),"cold store recreation retains the full collection and earned distinction")
 main.introduction_seen=true
 await click(flow.hub.item_buttons.M08);await idle()
 main=flow.preparation;main.controller.set_physics_process(false)
 check(main.specimen_id=="M08" and main.profile.variant==1,"a new archived-specimen attempt selects the next admitted pocket layout")
 check(main.introduction_seen,"pocket hint is not repeated across preparations in the same launch")
 var layout_seed:int=main.pocket.layout.seed_value
 main.reset_specimen()
 check(main.pocket.layout.seed_value==layout_seed,"reset retains the chosen pocket case")
 evidence.native_ui_clicks=clicks
func brush_sweep(a:Vector2,b:Vector2,seconds:float) -> void:
 main.controller.select_tool(0);main.controller._focused=true;main.controller._pointer_inside=true
 var press:=InputEventMouseButton.new();press.button_index=MOUSE_BUTTON_LEFT;press.pressed=true;press.position=at(a)
 root.push_input(press,true)
 var frames_count:=roundi(seconds*60)
 for n in range(frames_count):
  main.block.flush_texture()
  var motion:=InputEventMouseMotion.new();motion.position=at(a.lerp(b,float(n+1)/frames_count));motion.button_mask=MOUSE_BUTTON_MASK_LEFT
  root.push_input(motion,true);main.controller._physics_process(1.0/60);await process_frame
 var release:=InputEventMouseButton.new();release.button_index=MOUSE_BUTTON_LEFT;release.pressed=false;release.position=main.controller._screen
 root.push_input(release,true)
