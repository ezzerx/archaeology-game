extends SceneTree
var gallery:Node3D
const OUTPUT="res://work/issue51-b17/"
func _initialize() -> void:call_deferred("run")
func shot(name:String) -> void:
 await create_timer(1.25).timeout
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(OUTPUT+name+".png")
func run() -> void:
 DirAccess.make_dir_recursive_absolute(OUTPUT)
 create_timer(60).timeout.connect(func():push_error("B17 pilot capture timeout");quit(2))
 root.mode=Window.MODE_WINDOWED;root.size=Vector2i(1440,810)
 gallery=load("res://scenes/experiments/exhibition_study.tscn").instantiate();root.add_child(gallery)
 while not gallery.fixtures_ready:await process_frame
 await shot("01-gallery")
 gallery.select(0);await shot("02-b17")
 gallery.examples[0].hide();await shot("03-empty-stand")
 gallery.examples[0].show();gallery.target_angle=Vector2(-.16,.06);await shot("04-b17-angle")
 gallery.target_size=1.85;gallery.target_focus=gallery.centers[0]+Vector3(-.30,-.02,.04);await shot("05-b17-detail")
 gallery.queue_free();await process_frame;quit()
