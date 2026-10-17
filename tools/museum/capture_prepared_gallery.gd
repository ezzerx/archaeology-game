extends SceneTree
var gallery:Node3D
var output:="res://work/issue28/gallery/"
var checks:=0
var failures:Array[String]=[]
func _initialize() -> void:run.call_deferred()
func check(ok:bool,label:String) -> void:
 checks+=1
 if not ok:failures.append(label);push_error(label)
func capture(label:String) -> void:
 await create_timer(.95).timeout
 for n in range(4):await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(output+label+".png")
func run() -> void:
 var empty:bool="--empty" in OS.get_cmdline_user_args()
 if empty:output="res://work/issue28/empty/"
 DirAccess.make_dir_recursive_absolute(output)
 AudioServer.set_bus_mute(0,true)
 root.size=Vector2i(1920,1080)
 gallery=load("res://scenes/collection/prepared_gallery.tscn").instantiate();root.add_child(gallery)
 while not gallery.fixtures_ready:await process_frame
 await capture("01-overview")
 if empty:
  check(gallery.examples==[null,null],"empty collection has no perfect stand-ins")
  check(gallery.nav_buttons[1].disabled and gallery.nav_buttons[2].disabled,"empty slots cannot be inspected")
  gallery.select(0);check(gallery.selected==-1,"keyboard and clicks cannot reveal missing specimens")
  check(gallery.subtitle.text.contains("première préparation"),"empty state explains the next action")
  FileAccess.open(output+"native.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures}))
  gallery.queue_free();await process_frame;await process_frame;quit(0 if failures.is_empty() else 1);return
 check(gallery.examples[0]!=null and gallery.examples[1]!=null,"both actual specimens loaded")
 check(gallery.exhibition_note.text=="COLLECTION · VOS PRÉPARATIONS","real collection is labelled")
 for i in range(2):
  gallery.select(i)
  await capture("02-b17" if i==0 else "03-ammonite")
  check(gallery.selected==i,"real exhibit can be inspected")
  check(gallery.subtitle.text.contains("État"),"distinct preparation metrics displayed")
  check(gallery.examples[i].get_meta("snapshot_version",0)==1,"display comes from an archived preparation")
 gallery.select(0);gallery.target_size=1.6;gallery.target_angle=Vector2(-.10,.05)
 await capture("04-b17-close")
 gallery.select(1);gallery.target_size=1.3;gallery.target_angle=Vector2(.12,.05)
 await capture("05-ammonite-close")
 # Show the alternate real M08 archive without changing anything on disk.
 for record in gallery.exhibit_store.manifest.attempts:
  if int(record.get("kind",-1))!=1:continue
  gallery.exhibit_store.manifest.latest.M08=record
  var marine:Node3D=gallery._build_exhibit("M08")
  check(marine!=null,"marine archive reloads its own modeled shell")
  if marine==null:break
  gallery.examples[1].queue_free()
  var pivot:=gallery.get_node("Mount1")
  pivot.add_child(marine);gallery.examples[1]=marine
  var extent:Vector2=marine.get_meta("display_extent")
  var usable:Vector2=pivot.get_meta("usable_extent")
  var fit:=minf(usable.x/extent.x,usable.y/extent.y)
  fit*=.92
  marine.scale=Vector3.ONE*fit;marine.position=-Vector3(marine.get_meta("display_center",Vector3.ZERO))*fit
  gallery.select(1);await capture("06-marine")
  gallery.target_size=1.3;await capture("07-marine-close")
  break
 # Native-resolution evidence plus a bounded idle sample, no permanent FPS change.
 gallery.select(-1)
 for n in range(100):await process_frame
 Engine.max_fps=0
 var samples:Array[float]=[];var previous:=Time.get_ticks_usec()
 for n in range(180):
  await process_frame
  var now:=Time.get_ticks_usec();samples.append((now-previous)/1000.0);previous=now
 Engine.max_fps=240;samples.sort()
 var report:={"checks":checks,"failures":failures,"render_size":str(root.get_texture().get_image().get_size()),
  "frame_p50_ms":samples[90],"frame_p95_ms":samples[171],"archive":gallery.exhibit_store.directory}
 FileAccess.open(output+"native.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("PREPARED GALLERY ",JSON.stringify(report))
 gallery.queue_free();await process_frame;await process_frame;quit(0 if failures.is_empty() else 1)
