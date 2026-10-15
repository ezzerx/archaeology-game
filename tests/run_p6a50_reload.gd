extends SceneTree
func _initialize() -> void:run.call_deferred()
func run() -> void:
 AudioServer.set_bus_mute(0,true)
 root.size=Vector2i(1280,720)
 var flow=load("res://scenes/p6a50_collection_loop.tscn").instantiate();root.add_child(flow)
 flow.hub.show_page("gallery")
 for n in range(12):await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://work/test-logs/p6a50/12-cold-reload.png")
 var ok:bool=flow.store.records.size()==2 and flow.hub.photos.size()==2 and flow.store.badge("M08") and flow.store.badge("B17")
 FileAccess.open("res://work/test-logs/p6a50/reload.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":1,"failures":[] if ok else ["cold process collection reload"],"collection_path":flow.store.path}))
 print("P6A50 COLD RELOAD ","PASS" if ok else "FAIL")
 flow.queue_free();await create_timer(.2).timeout;quit(0 if ok else 1)
