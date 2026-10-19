extends SceneTree
const Handoff=preload("res://scripts/collection/exhibit_handoff.gd")
var checks:=0
var failures:Array[String]=[]
var scene:Node3D
var out:="res://work/issue27/qa"
var captures:=false
func _initialize() -> void:run.call_deferred()
func check(ok:bool,message:String) -> void:
 checks+=1
 if not ok:failures.append(message);push_error(message)
func settle() -> void:
 for i in range(5):await process_frame
func shot(name:String) -> void:
 if not captures:return
 print("Capturing ",name);await settle();await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(out+"/"+name+".png")
func mouse(point:Vector2,pressed:bool) -> void:
 var e:=InputEventMouseButton.new();e.position=point;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=pressed;scene._unhandled_input(e)
func run() -> void:
 captures="--capture" in OS.get_cmdline_user_args()
 for argument in OS.get_cmdline_user_args():
  if argument.begins_with("--capture-dir="):out=argument.trim_prefix("--capture-dir=")
 DirAccess.make_dir_recursive_absolute(out)
 root.size=Vector2i(1280,720)
 print("Loading arrivals scene")
 scene=load("res://scenes/arrivals/receiving_room.tscn").instantiate();root.add_child(scene)
 print("Arrivals scene assembled")
 while not scene.ready_for_input:await process_frame
 check(scene.crates.size()==3,"Three crate assemblies")
 check(scene.selected==-1,"Start at overview")
 check(scene.gallery_button.visible,"Museum accessible before choosing")
 check(Engine.physics_ticks_per_second==60,"Physics remains 60 Hz")
 await shot("01-overview")
 for i in range(3):
  var c=scene.crates[i]
  check(not c.covered.visible,"Covered preview hidden in sealed crate %d"%i)
  check(not c.unlocked and c.opening==0,"Sealed initial state %d"%i)
  check(c.covered.get_meta("arrival_kind")==i,"Exact preparation preview mapping %d"%i)
  check(c.covered.find_children("*","MeshInstance3D",true,false).size()>0,"Frozen real mesh available %d"%i)
  check(c.covered.get_node_or_null("ProductionBoneBatch")==null,"No buried bones loaded into preview %d"%i)
  check(c.covered.get_node("SurfaceMesh").mesh.subdivide_width==255,"Preview mesh budget bounded %d"%i)
  var extent:Vector2=c.covered.get_meta("display_extent")*c.covered.scale.x
  check(extent.x<=.721 and extent.y<=.431,"Covered preparation fits interior %d"%i)
  check(c.label.text.contains(c.LOTS[i]) and not c.label.text.contains("Ammonite") and not c.label.text.contains("B17"),"Label does not identify species %d"%i)
  c.set_opening(1);check(c.opening==0,"Latch blocks lid movement %d"%i)
  scene.select(i);scene.focus=scene.target_focus;scene.view_size=scene.target_size;scene._camera()
  await physics_frame
  check(scene.start_button.disabled,"Cannot begin sealed preparation %d"%i)
  if i==0:await shot("02-focused")
  var latch_point:Vector2=scene.camera.unproject_position(c.to_global(Vector3(-.13,.225,.37)))
  var hit:Dictionary=scene.hit(latch_point)
  check(not hit.is_empty() and hit.collider.get_meta("part","")=="latch","Ray reaches latch %d"%i)
  mouse(latch_point,true);mouse(latch_point,false)
  check(c.unlocked,"Mouse releases latch %d"%i)
  # Drag from the upper surface, not an abstract screen button.
  var lid_point:Vector2=scene.camera.unproject_position(c.to_global(Vector3(0,.315,.08)))
  mouse(lid_point,true)
  check(scene.dragging_lid,"Mouse grabs lid %d"%i)
  var motion:=InputEventMouseMotion.new();motion.position=lid_point+Vector2(0,-235);motion.relative=Vector2(0,-235);scene._unhandled_input(motion)
  mouse(motion.position,false)
  check(c.opening>.99 and c.covered.visible,"Mouse drag opens lid and reveals covered block %d"%i)
  scene._refresh();check(not scene.start_button.disabled,"Preparation available after opening %d"%i)
  check(c.lid.rotation.x< -1.8,"Lid clears the working area %d"%i)
  scene._process(1.0)
  var lid_top:Vector2=scene.camera.unproject_position(c.lid.to_global(Vector3(0,.04,.636)))
  check(lid_top.y>20 and scene.get_viewport().get_visible_rect().has_point(lid_top),"Open lid stays within framing %d"%i)
  await shot("03-open-%d"%i)
  scene.dragging_lid=true;scene._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
  check(not scene.dragging_lid,"Focus loss cancels manipulation %d"%i)
  var args:=Handoff.launch_arguments("workshop","user://issue27-tests",i,true)
  check("--arrival-kind="+str(i) in args and "gl_compatibility" in args,"Correct preparation and renderer for crate %d"%i)
  c.reset();check(not c.unlocked and not c.covered.visible and c.opening==0,"Reset restores safe sealed state %d"%i)
 scene.select(-1);scene.focus=scene.target_focus;scene.view_size=scene.target_size;scene._camera()
 check(not scene.start_button.visible and not scene.back.visible,"Overview hides opening controls")
 for size in [Vector2i(1024,768),Vector2i(1680,720)]:
  root.size=size;await settle();scene._camera()
  for c in scene.crates:
   var screen:Vector2=scene.camera.unproject_position(c.global_position+Vector3(0,.15,0))
   check(root.get_visible_rect().has_point(screen),"Crate in view at "+str(size))
  await shot("04-aspect-%d"%size.x)
 check(Handoff.launch_arguments("invalid","user://issue27-tests",0,true).is_empty(),"Invalid destination rejected")
 var museum:=Handoff.launch_arguments("gallery","user://issue27-tests",1,true)
 check("--arrivals-loop" in museum and "forward_plus" in museum and "--exhibit-focus=1" in museum,"Gallery keeps loop context and focus")
 var legacy:=Handoff.launch_arguments("workshop","user://issue27-tests",-1,false)
 check(not "--arrivals-loop" in legacy and not "--arrival-kind=0" in legacy,"Legacy launch unchanged")
 check(FileAccess.file_exists("res://assets/arrivals/source/.gdignore"),"Source GLBs excluded from runtime imports")
 var report:={"checks":checks,"failures":failures,"engine":Engine.get_version_info().string,"renderer":RenderingServer.get_current_rendering_method(),"captures":captures}
 FileAccess.open(out+"/result.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "));print(JSON.stringify(report))
 scene.queue_free();await process_frame;quit(0 if failures.is_empty() else 1)
