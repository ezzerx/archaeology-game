extends SceneTree
func _initialize() -> void:run.call_deferred()
func run() -> void:
 root.size=Vector2i(1280,720)
 var scene=load("res://scenes/arrivals/receiving_room.tscn").instantiate();root.add_child(scene)
 while not scene.ready_for_input:await process_frame
 scene.select(0);scene.crates[0].release_latch();scene.crates[0].set_opening(1.)
 scene._process(1.0)
 for i in range(2):await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://work/issue27/open-final.png")
 print("Final open framing captured")
 scene.queue_free();await process_frame;quit()
