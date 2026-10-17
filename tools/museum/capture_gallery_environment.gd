extends SceneTree
var gallery:Node3D
const OUTPUT="res://work/issue51-environment/"
func _initialize() -> void:call_deferred("run")
func shot(name:String) -> void:
 await create_timer(1.4).timeout;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(OUTPUT+name+".png")
func run() -> void:
 DirAccess.make_dir_recursive_absolute(OUTPUT)
 create_timer(65).timeout.connect(func():push_error("Environment capture timeout");quit(2))
 root.size=Vector2i(1440,810)
 gallery=load("res://scenes/experiments/exhibition_study.tscn").instantiate();root.add_child(gallery)
 while not gallery.fixtures_ready:await process_frame
 await shot("01-gallery")
 gallery.select(0);await shot("02-b17")
 gallery.select(1);await shot("03-ammonite")
 gallery.target_angle=Vector2(.16,.06);await shot("04-ammonite-angle")
 gallery.select(-1);gallery.target_focus=Vector3(-2.8,1.9,-1.9);gallery.target_size=3.7;await shot("05-niche-window")
 gallery.target_focus=Vector3(.05,1.7,-1.7);gallery.target_size=3.0;await shot("06-cabinet")
 gallery.queue_free();await process_frame;quit()
