extends SceneTree
## Reproducible native lookdev views and uncapped static render samples.
var gallery:Node3D
var output:="res://work/issue51-lookdev/current"
var metrics:Dictionary={}
func _initialize() -> void:call_deferred("run")
func shot(label:String) -> void:
 await create_timer(1.6).timeout
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(output+"/"+label+".png")
func sample(label:String) -> void:
 var cap:=Engine.max_fps
 Engine.max_fps=0
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 RenderingServer.viewport_set_measure_render_time(root.get_viewport_rid(),true)
 for n in range(90):await process_frame
 var times:Array[float]=[];var gpu:Array[float]=[];var previous:=Time.get_ticks_usec()
 for n in range(240):
  await process_frame
  var now:=Time.get_ticks_usec();times.append((now-previous)/1000.0);previous=now
  gpu.append(RenderingServer.viewport_get_measured_render_time_gpu(root.get_viewport_rid()))
 times.sort();gpu.sort()
 var sum:=0.;var gpu_sum:=0.
 for t in times:sum+=t
 for t in gpu:gpu_sum+=t
 metrics[label]={"mean_ms":sum/times.size(),"p95_ms":times[int(times.size()*.95)],"gpu_mean_ms":gpu_sum/gpu.size(),"gpu_p95_ms":gpu[int(gpu.size()*.95)]}
 Engine.max_fps=cap
func run() -> void:
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--out="):output="res://"+arg.trim_prefix("--out=")
 DirAccess.make_dir_recursive_absolute(output)
 create_timer(100).timeout.connect(func():push_error("Lookdev capture timeout");quit(2))
 root.size=Vector2i(1440,810)
 gallery=load("res://scenes/experiments/exhibition_study.tscn").instantiate();root.add_child(gallery)
 while not gallery.fixtures_ready:await process_frame
 await shot("01-gallery");await sample("overview")
 gallery.select(0);await shot("02-b17");await sample("b17")
 gallery.select(1);await shot("03-ammonite");await sample("ammonite")
 gallery.target_angle=Vector2(.16,.06);await shot("04-ammonite-angle")
 gallery.select(-1);gallery.target_focus=Vector3(-2.8,1.9,-1.9);gallery.target_size=3.7;await shot("05-niche-window")
 gallery.target_focus=Vector3(.05,1.7,-1.7);gallery.target_size=3.0;await shot("06-cabinet")
 FileAccess.open(output+"/metrics.json",FileAccess.WRITE).store_string(JSON.stringify({"engine":Engine.get_version_info().string,"renderer":RenderingServer.get_current_rendering_method(),"image_size":root.get_texture().get_size(),"window_size":root.size,"uncapped_static_frames":metrics},"  "))
 gallery.queue_free();await process_frame;quit()
