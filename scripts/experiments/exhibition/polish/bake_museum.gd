extends SceneTree
func _initialize() -> void:
 var total:=0
 var draws:=0
 for category in ["architecture","furniture","collections","garden"]:
  var source=preload("res://scripts/experiments/exhibition/polish/museum_geometry.gd").new()
  root.add_child(source);source.make(category)
  total+=source.triangle_count;draws+=source.get_child_count()
  print("MUSEUM ",category," tris=",source.triangle_count," batches=",source.get_child_count()," LODs=",source.lod_counts)
  if category=="garden":
   for mesh:MeshInstance3D in source.get_children():
    mesh.layers=2;mesh.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  source.set_script(null)
  var packed:=PackedScene.new();packed.pack(source)
  var error:=ResourceSaver.save(packed,"res://assets/museum/polish/"+category+".scn",ResourceSaver.FLAG_COMPRESS)
  source.free()
  if error!=OK:push_error("Museum scene save failed");quit(1);return
 print("MUSEUM BUDGET ",total," triangles / ",draws," material batches")
 if total>280000 or draws>44:push_error("Museum exceeds production budget");quit(1);return
 quit()
