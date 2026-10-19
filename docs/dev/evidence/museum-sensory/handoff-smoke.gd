extends SceneTree
func _initialize() -> void: run.call_deferred()
func run() -> void:
 create_timer(90).timeout.connect(func():push_error("Native audio handoff timeout");quit(2))
 root.size=Vector2i(1600,900)
 var from_gallery:bool="--museum-return" in OS.get_cmdline_user_args()
 var scene:Node=load("res://scenes/collection/prepared_gallery.tscn" if from_gallery else "res://scenes/collection/exhibit_workshop.tscn").instantiate()
 root.add_child(scene)
 if from_gallery:
  while not scene.fixtures_ready:await process_frame
 else:
  while scene.busy:await process_frame
 await create_timer(1.5).timeout
 if not from_gallery:
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://work/museum-polish/atelier-no-lamp.png")
 var started:=Time.get_ticks_usec()
 if from_gallery:
  await scene._return_to_workshop()
 else:
  # Existing copied archives already exist. Exercise the actual transition,
  # without completing or saving a substitute player preparation.
  scene.saved=true
  await scene._after_archive()
 var result:={"source":"gallery" if from_gallery else "workshop","seconds":float(Time.get_ticks_usec()-started)/1e6,"handler_returned":true}
 FileAccess.open("res://work/museum-polish/handoff-"+result.source+".json",FileAccess.WRITE).store_string(JSON.stringify(result,"  "))
 print("NATIVE AUDIO HANDOFF ",result)
