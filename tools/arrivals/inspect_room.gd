extends SceneTree
## Art-only staging of imported props before the frozen preparation previews are baked.
func _initialize() -> void:run.call_deferred()
func run() -> void:
 root.size=Vector2i(1280,720);root.content_scale_mode=Window.CONTENT_SCALE_MODE_CANVAS_ITEMS;root.msaa_3d=Viewport.MSAA_4X
 var scene:=Node3D.new();root.add_child(scene)
 var room=preload("res://scripts/arrivals/room.gd");room.install(scene);room.lighting(scene)
 for i in range(3):
  var pivot:=Node3D.new();scene.add_child(pivot);pivot.position=Vector3([0.,-.91,.91][i],.85,[.45,.25,.25][i])
  if i>0:pivot.scale=Vector3.ONE*.83;pivot.rotation_degrees.y=5 if i==1 else -5
  for name in ["crate_body","crate_lid"]:
   var model=load("res://assets/arrivals/models/"+name+".glb").instantiate();pivot.add_child(model)
   if name=="crate_lid":model.position.y=.267
   preload("res://scripts/experiments/exhibition/gallery_furniture.gd")._materials(model,Color(.86,.88,.88),.4)
 var cam:=Camera3D.new();scene.add_child(cam);cam.projection=Camera3D.PROJECTION_ORTHOGONAL;cam.current=true;cam.size=3.15
 var focus:=Vector3(0,1.18,-.15);cam.position=focus+Vector3(.28,3.2,5.6);cam.look_at(focus)
 for i in range(4):await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://work/issue27/room-inspection.png")
 print("Room art capture saved")
 scene.queue_free();await process_frame;quit()
