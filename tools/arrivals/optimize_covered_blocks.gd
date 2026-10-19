extends SceneTree
func _initialize() -> void:run.call_deferred()
func run() -> void:
 var report:={}
 for i in range(3):
  var path:="res://assets/arrivals/covered_blocks/block_%d.scn"%i
  var frozen=load(path).instantiate()
  report[str(i)]=preload("res://tools/arrivals/covered_preview.gd").optimize(frozen)
  var pack:=PackedScene.new();assert(pack.pack(frozen)==OK)
  assert(ResourceSaver.save(pack,path,ResourceSaver.FLAG_COMPRESS)==OK)
  frozen.free();print("Optimized covered preview ",i)
 FileAccess.open("res://assets/arrivals/covered_blocks/budgets.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 quit()
