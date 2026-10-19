extends SceneTree
var checks:=0
var failures:Array[String]=[]
func _initialize() -> void:run.call_deferred()
func check(ok:bool,message:String) -> void:
 checks+=1
 if not ok:failures.append(message);push_error(message)
func run() -> void:
 var suite=load("res://scenes/collection/exhibit_workshop.tscn").instantiate();root.add_child(suite)
 while suite.busy:await process_frame
 check(suite.selected==2,"Launch argument selects concretions immediately")
 check(suite.preparation.demo_kind==2 and suite.preparation.specimen_id=="M08","Concrete preparation matches selected crate")
 check(not suite.buttons[0].get_parent().visible and not suite.compact_bar.visible,"Arrival loop hides demo selectors")
 check(is_instance_valid(suite.arrivals_button) and suite.arrivals_button.visible,"Return action available")
 for kind in [2,0,1]:
  if kind!=2:await suite.open_demo(kind)
  var prep=suite.preparation
  check(prep.demo_kind==kind,"Real preparation mapping %d"%kind)
  check(suite.compact_selected==2,"Validated compact variant C retained")
  check(prep.controller.ui_blockers.has(suite.arrivals_return),"Return modal blocks excavation %d"%kind)
  var surface=prep.block.working_map
  var before:=hash(surface.fossil.exposed)
  suite._request_arrivals()
  check(suite.arrivals_return.visible and not suite.busy,"Unfinished work asks before leaving %d"%kind)
  suite.arrivals_return.hide()
  check(hash(surface.fossil.exposed)==before and not suite.saved,"Cancelling return preserves live work %d"%kind)
  prep.session.archived=true;suite.saved=false
  suite._request_arrivals()
  check(not suite.arrivals_return.visible,"Unsaved archive cannot be abandoned %d"%kind)
  prep.session.archived=false
 var out:="res://work/issue27/qa/workshop.json"
 FileAccess.open(out,FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures},"  "))
 print("ISSUE27 WORKSHOP ",checks," checks ",failures.size()," failures")
 suite.queue_free();await process_frame;quit(0 if failures.is_empty() else 1)
