extends SceneTree
## Offline authoring command: godot --headless --path . --script res://scripts/workshop/polish/bake_atelier.gd
func _initialize() -> void:
 var art = preload("res://scripts/workshop/polish/atelier_geometry.gd").new()
 root.add_child(art)
 var marine := "--marine" in OS.get_cmdline_user_args()
 art.build(marine)
 # The runtime scene contains only static MeshInstances and saved mesh LODs.
 print("ATELIER triangles=",art.triangle_count," materials=",art.get_child_count()," LODs=",art.lod_counts)
 if art.triangle_count<10000 or art.triangle_count>45000 or art.get_child_count()>16:
  push_error("Atelier geometry exceeds the declared budget or is incomplete")
  art.free(); quit(1); return
 art.set_script(null)
 var packed := PackedScene.new()
 var result := packed.pack(art)
 if result == OK:
  result = ResourceSaver.save(packed,"res://assets/workshop/polish/atelier_marine.scn" if marine else "res://assets/workshop/polish/atelier_still_life.scn",ResourceSaver.FLAG_COMPRESS)
 print("ATELIER BAKE ",result)
 art.free()
 quit(0 if result==OK else 1)
