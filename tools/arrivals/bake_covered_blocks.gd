extends SceneTree
## Bake untouched real preparations into frozen, simulation-free arrival previews.
func _initialize() -> void:run.call_deferred()
func run() -> void:
 var suite=load("res://scenes/collection/exhibit_workshop.tscn").instantiate();root.add_child(suite)
 while suite.preparation==null or suite.busy:await process_frame
 var report:={}
 for kind in range(3):
  if "--resume" in OS.get_cmdline_user_args() and FileAccess.file_exists("res://assets/arrivals/covered_blocks/block_%d.scn"%kind):
   report[str(kind)]={"reused_completed_snapshot":true,"path":"res://assets/arrivals/covered_blocks/block_%d.scn"%kind}
   continue
  if suite.selected!=kind:await suite.open_demo(kind,2)
  print("Capturing covered preparation ",kind)
  var p=suite.preparation
  p.display.persist=false
  await process_frame
  assert(p.block.working_map.fossil.exposure_percent()==0)
  var frozen=preload("res://scripts/collection/exhibit_snapshot.gd").new().capture(p)
  preload("res://scripts/collection/exhibit_display.gd").apply(frozen)
  frozen.set_meta("arrival_kind",kind)
  frozen.set_meta("arrival_compact_variant",2)
  preload("res://tools/arrivals/covered_preview.gd").optimize(frozen)
  var pack:=PackedScene.new();assert(pack.pack(frozen)==OK)
  var path:="res://assets/arrivals/covered_blocks/block_%d.scn"%kind
  assert(ResourceSaver.save(pack,path,ResourceSaver.FLAG_COMPRESS)==OK)
  report[str(kind)]={"exposure":p.block.working_map.fossil.exposure_percent(),"extent":str(frozen.get_meta("display_extent")),"center":str(frozen.get_meta("display_center")),"path":path}
  frozen.free()
 FileAccess.open("res://assets/arrivals/covered_blocks/provenance.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 suite.queue_free();await process_frame;quit()
