extends SceneTree
func _initialize() -> void:run.call_deferred()
func run() -> void:
 assert(ProjectSettings.get_setting("application/run/main_scene")=="res://scenes/arrivals/receiving_room.tscn")
 assert(not FileAccess.file_exists("res://assets/arrivals/source/tripo-studio/crate_body/original.glb"))
 for path in ["res://scenes/arrivals/receiving_room.tscn","res://scenes/collection/exhibit_workshop.tscn","res://scenes/collection/prepared_gallery.tscn"]:
  assert(ResourceLoader.exists(path))
 var arrival=load("res://scenes/arrivals/receiving_room.tscn").instantiate();root.add_child(arrival)
 while not arrival.ready_for_input:await process_frame
 assert(arrival.crates.size()==3)
 for c in arrival.crates:
  assert(is_instance_valid(c.covered) and not c.covered.visible)
  assert(c.covered.get_node("SurfaceMesh").mesh.subdivide_width==255)
  assert(c.covered.get_node_or_null("ProductionBoneBatch")==null)
 arrival.select(0);arrival.crates[0].release_latch();arrival.crates[0].set_opening(1.)
 arrival._process(1.)
 assert(is_equal_approx(arrival.target_size,1.65))
 print("ISSUE27 PACK OK: entry scene and three optimized covered blocks load; workshop/gallery resources present; source masters excluded")
 arrival.queue_free();await process_frame;quit()
