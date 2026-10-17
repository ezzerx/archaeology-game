extends SceneTree
const Store=preload("res://scripts/collection/exhibit_store.gd")
var checks:=0
var failures:Array[String]=[]
var suite:Node
var out:="res://work/issue28/storage/"
func _initialize() -> void:run.call_deferred()
func check(ok:bool,label:String) -> void:
 checks+=1
 if not ok:failures.append(label);push_error(label)
func hash_legacy() -> Dictionary:
 var data:={}
 for path in ["user://collection/records.json","user://preparation_distinctions.json","user://p6a2_display.cfg"]:
  data[path]=FileAccess.get_sha256(path) if FileAccess.file_exists(path) else "absent"
 return data
func run() -> void:
 DirAccess.make_dir_recursive_absolute(out)
 FileAccess.open(out+".gdignore",FileAccess.WRITE).close()
 create_timer(120).timeout.connect(func():quit(2))
 var legacy:=hash_legacy()
 suite=load("res://scenes/collection/exhibit_workshop.tscn").instantiate();root.add_child(suite)
 while suite.busy:await process_frame
 var prep=suite.preparation;prep.display.persist=false;prep.controller.set_physics_process(false)
 var surface=prep.block.working_map
 # Fixture stresses incomplete cleaning and scattered buried margins at the real finish gate.
 P5Fixture.distributed(surface,94.0)
 var brush:ToolDefinition=load("res://config/soft_brush.tres")
 for y in range(0,641,12):
  surface.bone_film.clean(Vector2(0,y),Vector2(1024,y),brush,2.0)
  if surface.bone_film.cleanliness_percent()>91:break
 prep.block.flush_texture();prep.session.invalidate();prep.session.flush()
 check(prep.session.preparation_complete,"non-integral fixture meets the real finish gate")
 check(surface.bone_film.cleanliness_percent()<99,"fixture retains visible bone film")
 var folder:=out+"attempts-"+str(Time.get_ticks_usec())
 suite.exhibit_store=Store.new(folder)
 DirAccess.make_dir_recursive_absolute(folder)
 # Simulate another active writer: failing the finish must not discard the playable result.
 DirAccess.make_dir_absolute(folder+"/.writing")
 FileAccess.open(folder+"/.writing/owner",FileAccess.WRITE).store_string(str(OS.get_process_id()))
 prep.session_ui.archive_button.pressed.emit()
 while suite.busy:await process_frame
 check(prep.session.archived and not suite.saved and prep.session_ui.archive_state=="failed","save failure keeps finished preparation for retry")
 suite.choose(1)
 check(suite.selected==0,"failed save blocks replacing the only live copy")
 DirAccess.remove_absolute(folder+"/.writing/owner");DirAccess.remove_absolute(folder+"/.writing")
 suite._after_archive()
 while suite.busy:await process_frame
 check(suite.saved,"retry commits the same finished preparation")
 var first:Dictionary=suite.exhibit_store.entry("B17").duplicate(true)
 var node:Node3D=suite.exhibit_store.load_block("B17")
 check(node!=null,"non-integral preparation reloads")
 if node!=null:
  var bone:=node.get_node("ProductionBoneBatch") as MeshInstance3D
  var film:Texture2D=bone.material_override.get_shader_parameter("bone_film_map")
  check(film.get_image().get_data()==prep.block.bone_film_texture.get_image().get_data(),"nonzero adherent dirt is preserved")
  var mask:Texture2D=bone.material_override.get_shader_parameter("fossil_map")
  check(mask.get_image().get_data()==prep.block.fossil_texture.get_image().get_data(),"scattered buried cells remain clipped")
  node.free()
 check(not first.integral,"partial finish is not marked integral")
 # Model a later worse result using the same finished test scene.
 prep.session.archive_snapshot.condition=70.0
 var second:Dictionary=suite.exhibit_store.archive(prep)
 check(second.ok and suite.exhibit_store.entry("B17").snapshot.condition==70,"latest result wins even with a worse condition")
 check(FileAccess.file_exists(folder.path_join(first.file)),"previous scene retained after replacement")
 check(suite.exhibit_store.manifest.attempts.size()==2,"attempt history retained")
 # A stale in-memory writer must reload the just-committed index under the lock.
 var stale:=Store.new(folder)
 var third:Dictionary=suite.exhibit_store.archive(prep)
 var fourth:Dictionary=stale.archive(prep)
 check(third.ok and fourth.ok and Store.new(folder).manifest.attempts.size()==4,"stale store cannot lose another committed attempt")
 # Interrupted writer recovery.
 DirAccess.make_dir_absolute(folder+"/.writing")
 FileAccess.open(folder+"/.writing/owner",FileAccess.WRITE).store_string("2147483647")
 var recovered:Dictionary=stale.archive(prep)
 check(recovered.ok,"interrupted writer lock can be recovered")
 # A blocked destination leaves the index and previous scene untouched.
 var index:=folder+"/latest.json"
 var before:=FileAccess.get_file_as_string(index)
 DirAccess.make_dir_absolute(index+".tmp")
 var failed:Dictionary=stale.archive(prep)
 check(not failed.ok and FileAccess.get_file_as_string(index)==before,"failed index write preserves the last exhibit")
 DirAccess.remove_absolute(index+".tmp")
 check(stale.archive(prep).ok,"retry works after an I/O failure")
 # Corrupt model is reported, never replaced by a perfect example.
 var current:Dictionary=stale.entry("B17")
 FileAccess.open(folder.path_join(current.file),FileAccess.WRITE).store_string("damaged")
 check(Store.new(folder).load_block("B17")==null,"damaged model is rejected by integrity hash")
 check(hash_legacy()==legacy,"legacy scores distinctions and preferences unchanged")
 var report:={"checks":checks,"failures":failures,"legacy":legacy,"fixture":first.snapshot}
 FileAccess.open(out+"result.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("ISSUE28 STORAGE ",checks," checks ",failures.size()," failures")
 suite.queue_free();await process_frame;await process_frame;quit(0 if failures.is_empty() else 1)
