extends SceneTree
const OUT="res://work/issue51-environment/"
func _initialize() -> void:call_deferred("run")
func run() -> void:
 root.size=Vector2i(1100,1000)
 var stage:=Node3D.new();root.add_child(stage)
 var world:=WorldEnvironment.new();var env:=Environment.new()
 env.background_mode=Environment.BG_COLOR;env.background_color=Color("#45484a")
 env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;env.ambient_light_energy=.65;env.ambient_light_color=Color("#d8d7cc")
 env.tonemap_mode=Environment.TONE_MAPPER_FILMIC;world.environment=env;stage.add_child(world)
 var key:=DirectionalLight3D.new();stage.add_child(key);key.rotation_degrees=Vector3(-35,-30,0);key.light_energy=.8
 var cam:=Camera3D.new();stage.add_child(cam);cam.projection=Camera3D.PROJECTION_ORTHOGONAL;cam.current=true
 var report:={}
 for id in ["wall_niche","arched_window","potted_fern","field_books","mineral_sample"]:
  var asset:Node3D=load("res://assets/museum/models/"+id+".glb").instantiate();stage.add_child(asset)
  var mesh:MeshInstance3D=asset.find_children("*","MeshInstance3D",true,false)[0]
  var bounds:AABB=mesh.global_transform*mesh.get_aabb();var center:=bounds.get_center()
  report[id]={"bounds":str(bounds),"material":str(mesh.get_active_material(0))}
  for view in ["front","angle"]:
   cam.position=center+Vector3(0,0,2) if view=="front" else center+Vector3(.8,.35,2)
   cam.look_at(center);cam.size=maxf(bounds.size.y,bounds.size.x)*1.22
   await create_timer(.5).timeout;await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png(OUT+id+"-"+view+".png")
  if id=="wall_niche":
   var plain:=StandardMaterial3D.new();plain.albedo_color=Color(.7,.7,.7);mesh.material_override=plain
   cam.position=center+Vector3(0,0,2);cam.look_at(center)
   await create_timer(.3).timeout;await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png(OUT+"niche-geometry.png")
  asset.queue_free();await process_frame
 FileAccess.open(OUT+"native-inspection.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 stage.queue_free();await process_frame;quit()
