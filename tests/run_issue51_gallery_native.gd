extends SceneTree
var gallery:Node3D
var failed:Array[String]=[]
var checks:=0
var frames:Dictionary={}
var stores:Dictionary={}
func _initialize() -> void:call_deferred("run")
func check(value:bool,message:String) -> void:
 checks+=1
 if not value:failed.append(message);push_error(message)
func shot(name:String) -> void:
 await create_timer(1.3).timeout
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://work/issue51/"+name+".png")
func key(code:Key) -> void:
 var event:=InputEventKey.new();event.physical_keycode=code;event.pressed=true;root.push_input(event,true)
 event=InputEventKey.new();event.physical_keycode=code;event.pressed=false;root.push_input(event,true)
func click(point:Vector2) -> void:
 for pressed in [true,false]:
  var event:=InputEventMouseButton.new();event.position=point;event.button_index=MOUSE_BUTTON_LEFT;event.pressed=pressed;root.push_input(event,true)
func wheel(up:bool) -> void:
 var event:=InputEventMouseButton.new();event.position=Vector2(900,400)
 event.button_index=MOUSE_BUTTON_WHEEL_UP if up else MOUSE_BUTTON_WHEEL_DOWN
 event.pressed=true;root.push_input(event,true)
func sample(name:String) -> void:
 var times:Array[float]=[];var previous:=Time.get_ticks_usec()
 for n in range(180):
  await process_frame
  var now:=Time.get_ticks_usec();times.append((now-previous)/1000.0);previous=now
 times.sort();var sum:=0.
 for t in times:sum+=t
 frames[name]={"mean":sum/times.size(),"p95":times[int(times.size()*.95)]}
func run() -> void:
 DirAccess.make_dir_recursive_absolute("res://work/issue51")
 create_timer(70).timeout.connect(func():push_error("Gallery timeout");quit(2))
 for path in ["user://collection/records.json","user://preparation_distinctions.json","user://preparation_demos/distinctions.json"]:
  stores[path]=FileAccess.get_sha256(path) if FileAccess.file_exists(path) else "absent"
 root.mode=Window.MODE_WINDOWED;root.size=Vector2i(1440,810)
 gallery=load("res://scenes/experiments/exhibition_study.tscn").instantiate();root.add_child(gallery)
 while not gallery.fixtures_ready:await process_frame
 await shot("01-gallery");await sample("overview")
 check(gallery.examples.size()==2,"two museum examples loaded")
 var stand:Node3D=gallery.get_node("B17TripoStand")
 var stand_meshes:=stand.find_children("*","MeshInstance3D",true,false)
 check(stand_meshes.size()==1,"one imported B17 stand replaces the authored tray")
 var stand_material=stand_meshes[0].get_active_material(0)
 check(stand_material.albedo_texture!=null and stand_material.normal_texture!=null and stand_material.roughness_texture!=null and stand_material.metallic_texture!=null,"stand keeps all PBR maps")
 check(stand_material.albedo_texture.get_size()==Vector2(4096,4096),"stand source keeps 4K albedo")
 var fitted:Vector2=gallery.examples[0].get_meta("display_extent")*gallery.examples[0].scale.x
 var usable:Vector2=gallery.get_node("Mount0").get_meta("usable_extent")
 check(fitted.x<=usable.x+.001 and fitted.y<=usable.y+.001,"B17 matrix fits the usable cloth area")
 check(FileAccess.get_sha256("res://assets/museum/models/b17_stand.glb")==FileAccess.get_sha256("res://assets/museum/source/tripo-studio/b17/museum_b17_stand_pilot.glb"),"source GLB preserved byte for byte")
 for example in gallery.examples:
  check(example.get_meta("example_only",false),"fixture explicitly isolated")
  check(example.find_children("*","Camera3D",true,false).is_empty(),"no competing preparation camera")
 click(gallery.camera.unproject_position(gallery.centers[0]));await process_frame
 check(gallery.selected==0,"click on B17 opens inspection")
 await shot("02-b17");await sample("b17")
 key(KEY_RIGHT);await process_frame
 check(gallery.selected==1,"right key moves to ammonite")
 await shot("03-ammonite");await sample("ammonite")
 for n in range(30):wheel(true)
 check(is_equal_approx(gallery.target_size,1.3),"wheel reaches bounded close-up")
 for n in range(30):wheel(false)
 check(is_equal_approx(gallery.target_size,4.),"wheel reaches bounded wide view")
 key(KEY_ESCAPE);await process_frame
 check(gallery.selected==-1,"escape returns to overview")
 await create_timer(.9).timeout
 for i in range(gallery.nav_buttons.size()):
  click(gallery.nav_buttons[i].get_global_rect().get_center());await process_frame
  check(gallery.selected==i-1,"UI navigation %d"%i)
 # Native drag input: angle clamp and focus-loss cancellation.
 var press:=InputEventMouseButton.new();press.button_index=MOUSE_BUTTON_LEFT;press.pressed=true;press.position=Vector2(900,400);root.push_input(press,true)
 var motion:=InputEventMouseMotion.new();motion.position=Vector2(1700,600);motion.relative=Vector2(800,200);motion.button_mask=MOUSE_BUTTON_MASK_LEFT;root.push_input(motion,true)
 check(gallery.dragging and absf(gallery.target_angle.x)<=.1601 and absf(gallery.target_angle.y)<=.0601,"drag stays within authored inspection angles")
 gallery.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
 check(not gallery.dragging,"focus loss cancels drag")
 gallery.select(1);gallery.target_angle=Vector2(.16,.06);await shot("04-relief-angle")
 for dimensions in [Vector2i(1024,768),Vector2i(1680,720)]:
  root.size=dimensions;await create_timer(.3).timeout
  var bounds:=root.get_visible_rect()
  for button in gallery.nav_buttons:
   check(bounds.encloses(button.get_global_rect()),"navigation visible at "+str(dimensions))
  check(not gallery.heading.get_global_rect().intersects(gallery.nav_buttons[0].get_global_rect()),"caption clear of navigation at "+str(dimensions))
 root.size=Vector2i(1440,810);gallery.select(-1)
 for path in stores:
  var after:=FileAccess.get_sha256(path) if FileAccess.file_exists(path) else "absent"
  check(after==stores[path],"player storage unchanged: "+path)
 FileAccess.open("res://work/issue51/visual.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failed,"frame_ms":frames,"render":RenderingServer.get_current_rendering_method(),"engine":Engine.get_version_info().string,"window":Vector2i(1440,810),"examples_only":true},"  "))
 print("GALLERY ",checks," checks / ",failed.size()," failures")
 gallery.queue_free();await process_frame;quit(0 if failed.is_empty() else 1)
