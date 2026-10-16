extends SceneTree
var checks:=0
var failures:Array[String]=[]
var flow:Node
var view:Control
const OUT="res://work/issue27/"
func _initialize() -> void:run.call_deferred()
func check(ok:bool,message:String) -> void:
 checks+=1
 if not ok:failures.append(message);push_error(message)
func settle(count:=5) -> void:
 for n in range(count):await process_frame
func key(code:int,shift:=false) -> void:
 var event:=InputEventKey.new();event.physical_keycode=code;event.keycode=code;event.shift_pressed=shift;event.pressed=true;root.push_input(event,true)
 await process_frame
 event=InputEventKey.new();event.physical_keycode=code;event.keycode=code;event.shift_pressed=shift;event.pressed=false;root.push_input(event,true)
 await process_frame
func click_at(point:Vector2) -> void:
 for down in [true,false]:
  var event:=InputEventMouseButton.new();event.button_index=MOUSE_BUTTON_LEFT;event.pressed=down;event.position=point;root.push_input(event,true)
  await process_frame
func click(button:Button) -> void:await click_at(button.get_global_rect().get_center())
func idle() -> void:
 for n in range(2400):
  if not flow.busy:break
  await process_frame
 check(not flow.busy,"loading completes")
func shot(name:String) -> void:
 await settle();await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(OUT+name+".png")
func run() -> void:
 DirAccess.make_dir_recursive_absolute(OUT)
 root.size=Vector2i(1280,720)
 flow=load("res://scenes/collection.tscn").instantiate();root.add_child(flow)
 view=flow.hub.arrivals
 await settle(20);await physics_frame
 check(flow.preparation==null,"arrivals do not instantiate a fossil or excavation")
 check(view.viewport.world_3d!=root.world_3d,"arrivals lighting has its own world")
 check(view.stage.crates.size()==2 and view.selected=="M08","two physical crates and initial selection")
 await key(KEY_RIGHT)
 check(view.selected=="B17" and view.item_buttons.B17.visible,"keyboard selection updates the opening action")
 await key(KEY_LEFT)
 check(view.selected=="M08","keyboard selection works in both directions")
 for dimensions:Vector2i in [Vector2i(960,540),Vector2i(1024,768),Vector2i(1440,900),Vector2i(1280,720)]:
  root.size=dimensions;await settle()
  var pixel:Vector2=view.stage.camera.unproject_position(view.stage.crates.B17.to_global(Vector3(0,.40,0)))
  var logical:Vector2=view.get_global_transform_with_canvas()*(pixel*view.size/Vector2(view.viewport.size))
  await click_at(logical)
  check(view.selected=="B17","physical crate ray selection at "+str(dimensions))
  check(root.get_visible_rect().encloses(view.item_buttons.B17.get_global_rect()),"opening action fits "+str(dimensions))
  check(view.description.text.contains("Ravin des Ocres"),"provenance follows physical selection "+str(dimensions))
  await shot("arrivals-"+str(dimensions.x)+"x"+str(dimensions.y))
  view.select_crate("M08")
 await shot("arrivals-final")
 await key(KEY_TAB)
 check(root.gui_get_focus_owner()==view.collection_button,"keyboard Tab starts with collection navigation")
 await key(KEY_TAB)
 check(root.gui_get_focus_owner()==view.item_buttons.M08,"Tab reaches the current crate action")
 await key(KEY_RIGHT)
 check(view.selected=="B17" and root.gui_get_focus_owner()==view.item_buttons.B17,"arrow selection transfers focus to the visible action")
 await key(KEY_LEFT)
 if root.gui_get_focus_owner()!=null:root.gui_get_focus_owner().release_focus()
 await key(KEY_TAB,true)
 check(root.gui_get_focus_owner()==view.item_buttons.M08,"reverse Tab from no focus selects the last visible action")
 if root.gui_get_focus_owner()!=null:root.gui_get_focus_owner().release_focus()
 await key(KEY_ENTER);await idle();await settle(10)
 check(flow.preparation!=null and flow.preparation.specimen_id=="M08","Enter opens the selected crate")
 if flow.preparation==null:
  finish();return
 check(not flow.hub.root_control.visible and view.viewport.render_target_update_mode==SubViewport.UPDATE_DISABLED,"arrivals stop rendering during excavation")
 var preparation=flow.preparation
 preparation.controller.set_physics_process(false)
 var initial:Dictionary=preparation.session.snapshot().duplicate(true)
 flow.show_hub("depot");await settle()
 check(view.item_buttons.M08.text.begins_with("Reprendre"),"active crate offers resume")
 view.select_crate("B17");await click(view.item_buttons.B17)
 check(flow.confirmation!=null and flow.preparation==preparation,"unfinished work requires confirmation")
 await key(KEY_LEFT)
 check(view.selected=="B17" and flow.preparation==preparation,"modal blocks crate keyboard shortcuts")
 await key(KEY_ENTER);await settle()
 check(flow.confirmation==null and not view.blocked,"cancel restores arrivals interaction")
 await click(view.resume_button)
 check(flow.preparation==preparation and not flow.hub.root_control.visible,"resume restores the same preparation")
 check(preparation.session.snapshot()==initial,"arrivals round trip preserves excavation snapshot")
 flow.show_hub("depot");view.select_crate("B17");await click(view.item_buttons.B17)
 await click(flow.confirm_button);await idle();await settle(10)
 check(flow.preparation.specimen_id=="B17","confirmed selection opens B17")
 check(flow.preparation.block.working_map.fossil.field.total_cells==25404,"B17 uses the validated fossil")
 flow.show_hub("depot");await click(view.collection_button);await settle()
 check(flow.hub.mode=="gallery" and not view.visible,"collection remains accessible")
 check(view.viewport.render_target_update_mode==SubViewport.UPDATE_DISABLED,"arrivals stop rendering behind the gallery")
 await click(flow.hub.depot_button);await settle()
 check(view.visible and flow.hub.mode=="depot","return to physical arrivals")
 await shot("arrivals-with-resume")
 finish()
func finish() -> void:
 FileAccess.open(OUT+"arrivals-tests.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures},"  "))
 print("ISSUE27 ARRIVALS ",checks," checks, ",failures.size()," failures")
 flow.queue_free();await process_frame
 quit(0 if failures.is_empty() else 1)
