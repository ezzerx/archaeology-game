extends "res://tests/run_issue33_runtime.gd"
const ExhibitStore=preload("res://scripts/collection/exhibit_store.gd")
const Freeze=preload("res://scripts/collection/exhibit_snapshot.gd")
var archive_reports:Array=[]
var test_dir:String
func _output_directory() -> String:return "res://work/issue28/"
func run() -> void:
 out=_output_directory();DirAccess.make_dir_recursive_absolute(out)
 create_timer(600).timeout.connect(func():push_error("Exhibit test timeout");quit(2))
 AudioServer.set_bus_mute(0,true)
 test_dir=out+"archives-"+str(Time.get_ticks_usec())
 suite=load("res://scenes/collection/exhibit_workshop.tscn").instantiate();root.add_child(suite)
 while suite.busy:await process_frame
 suite.exhibit_store=ExhibitStore.new(test_dir)
 main=suite.preparation
 root.mode=Window.MODE_WINDOWED;root.size=Vector2i(1440,810)
 var first_file:=""
 for kind in range(3):
  if kind>0:await suite.open_demo(kind)
  main=suite.preparation;main.display.persist=false;main.controller.set_physics_process(false)
  root.size=Vector2i(1440,810)
  await settle(6)
  check(not suite.exhibit_store.archive(main).ok,"unfinished block cannot be archived "+str(kind))
  var covered:=Freeze.new().capture(main)
  check(covered.find_children("*","MeshInstance3D",true,false).size()>=3,"frozen block includes matrix and bones")
  var bone:=covered.get_node("ProductionBoneBatch") as MeshInstance3D
  check(bone!=null and bone.cast_shadow==GeometryInstance3D.SHADOW_CASTING_SETTING_OFF,"buried source geometry cannot cast shadows")
  main.process_mode=Node.PROCESS_MODE_DISABLED
  root.add_child(covered);covered.global_transform=main.block.global_transform
  main.block.hide();main.mesh_view.hide()
  await settle(5)
  var buried_before:Image=await frame_image()
  bone.hide()
  for mesh:MeshInstance3D in covered.find_children("*","MeshInstance3D",true,false):
   if mesh.cast_shadow==GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY:mesh.hide()
  await settle(5)
  check(buried_before.get_data()==(await frame_image()).get_data(),"buried frozen bones and their shadows produce no pixels "+str(kind))
  covered.free();main.block.show();main.mesh_view.show()
  main.process_mode=Node.PROCESS_MODE_INHERIT
  await complete_demo(kind)
  # Preserve a recognizable local injury; the rest of the piece remains unchanged.
  var s=main.block.working_map
  var contact:=-1
  for i in range(s.fossil.exposed.size()):
   if s.fossil.exposed[i]!=0 and s.fossil.field.component_ids[i]==1:
    contact=i;break
  if contact>=0:s.fossil.damage_at(contact,5.0)
  await settle(6)
  main.controller.cancel_stroke();main.block.show_cursor({"inside":false},1)
  await click(main.session_ui.archive_button)
  while suite.busy:await process_frame
  check(suite.saved and main.session.archived,"finish button saves actual preparation "+str(kind))
  if not suite.saved:break
  var entry:Dictionary=suite.exhibit_store.entry(main.specimen_id)
  check(entry.kind==kind and entry.snapshot.condition==s.fossil.condition,"provenance and real condition saved")
  if kind==0:first_file=entry.file
  var reloaded:=ExhibitStore.new(test_dir)
  var frozen:=reloaded.load_block(main.specimen_id)
  check(frozen!=null,"new store reloads the finished block "+str(kind))
  if frozen==null:break
  var surface:=frozen.get_node("SurfaceMesh") as MeshInstance3D
  var recorded_height:Texture2D=surface.material_override.get_shader_parameter("working_map")
  check(recorded_height.get_image().get_data()==main.block.texture.get_image().get_data(),"relief pixels survive serialization exactly")
  var frozen_bone:=frozen.get_node("ProductionBoneBatch") as MeshInstance3D
  for uniform in ["fossil_map","bone_film_map","local_damage_map","production_coverage"]:
   var live:Texture2D=main.mesh_view.material.get_shader_parameter(uniform)
   var saved_map:Texture2D=frozen_bone.material_override.get_shader_parameter(uniform)
   check(live.get_image().get_data()==saved_map.get_image().get_data(),"exact "+uniform+" "+str(kind))
  check(frozen_bone.material_override.get_shader_parameter("cursor_visible")==false,"tool ring not archived")
  check(frozen_bone.material_override.get_shader_parameter("inspection")!=true,"burial clipping retained")
  # Compare live and serialized renders under the same workshop camera and light.
  for canvas:CanvasLayer in main.find_children("*","CanvasLayer",true,false):canvas.hide()
  for canvas:CanvasLayer in suite.find_children("*","CanvasLayer",false,false):canvas.hide()
  main.feedback.proxies_enabled=false
  for proxy in main.feedback.proxies:proxy.hide()
  main.process_mode=Node.PROCESS_MODE_DISABLED
  await settle(12)
  await shot("workshop-"+str(kind))
  var before:Image=await frame_image()
  root.add_child(frozen);frozen.global_transform=main.block.global_transform
  main.block.hide();main.mesh_view.hide()
  await settle(12)
  var after:Image=await frame_image();after.save_png(out+"frozen-"+str(kind)+".png")
  var equal:bool=before.get_data()==after.get_data()
  check(equal,"same-camera serialized render equals live preparation "+str(kind))
  var hash_before:=hash(recorded_height.get_image().get_data())
  main.reset_specimen();await settle(4)
  check(hash(recorded_height.get_image().get_data())==hash_before,"new preparation cannot mutate frozen relief")
  archive_reports.append({"kind":kind,"file":entry.file,"bytes":FileAccess.get_file_as_bytes(test_dir.path_join(entry.file)).size(),"exact_render":equal,"snapshot":entry.snapshot})
  frozen.queue_free();await process_frame
  main.process_mode=Node.PROCESS_MODE_INHERIT
  # Reset is QA-only; permit the test selector to open the next specimen.
  main.session.archived=true;suite.saved=true
  for canvas:CanvasLayer in suite.find_children("*","CanvasLayer",false,false):canvas.show()
 var store:=ExhibitStore.new(test_dir)
 check(store.manifest.attempts.size()==3,"all three preparation families have an archive")
 check(store.entry("M08").get("kind",-1)==2,"latest M08 replaces the marine display independently of best score")
 check(FileAccess.file_exists(test_dir.path_join(first_file)),"earlier B17 scene retained")
 # Broken primary index recovers the preceding commit; total corruption blocks writes.
 var index:=test_dir.path_join("latest.json")
 var original:=FileAccess.get_file_as_string(index)
 FileAccess.open(index,FileAccess.WRITE).store_string("{broken")
 var recovered:=ExhibitStore.new(test_dir)
 check(recovered.recovered and not recovered.load_failed,"previous verified index recovers corruption")
 FileAccess.open(index+".bak",FileAccess.WRITE).store_string("{broken")
 var damaged:=ExhibitStore.new(test_dir)
 check(damaged.load_failed and not damaged.archive(main).ok,"unreadable collection refuses destructive overwrite")
 FileAccess.open(index,FileAccess.WRITE).store_string(original)
 suite.queue_free();await process_frame;await process_frame
 FileAccess.open(out+"archive-directory.txt",FileAccess.WRITE).store_string(ProjectSettings.globalize_path(test_dir))
 FileAccess.open(out+"exhibits.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"archives":archive_reports,"directory":test_dir},"  "))
 print("ISSUE28 EXHIBITS ",checks," checks ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
