extends SceneTree
func _initialize() -> void:run.call_deferred()
func run() -> void:
 assert(ProjectSettings.get_setting("application/run/main_scene")=="res://scenes/arrivals/receiving_room.tscn")
 assert(not FileAccess.file_exists("res://assets/arrivals/source/tripo-studio/crate_body/original.glb"))
 for path in ["res://scenes/arrivals/receiving_room.tscn","res://scenes/collection/exhibit_workshop.tscn","res://scenes/collection/prepared_gallery.tscn"]:
  assert(ResourceLoader.exists(path));assert(load(path)!=null)
 var arrival=load("res://scenes/arrivals/receiving_room.tscn").instantiate();root.add_child(arrival)
 while not arrival.ready_for_input:await process_frame
 assert(arrival.crates.size()==3)
 for c in arrival.crates:assert(is_instance_valid(c.covered) and not c.covered.visible)
 print("ISSUE27 PACK OK: entry scene, three covered blocks, workshop and gallery load; source masters excluded")
 arrival.queue_free();await process_frame;quit()
