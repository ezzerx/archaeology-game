extends SceneTree
const Store=preload("res://scripts/p6a50/collection_store.gd")
var checks:=0
var failures:Array[String]=[]
func check(ok:bool,label:String) -> void:
 checks+=1
 if not ok:failures.append(label);push_error(label)
func _initialize() -> void:run.call_deferred()
func run() -> void:
 var directory:="res://work/test-logs/p6a50/store-"+str(Time.get_ticks_usec())
 DirAccess.make_dir_recursive_absolute(directory)
 var path:=directory+"/records.json"
 var legacy:=directory+"/legacy.json"
 FileAccess.open(legacy,FileAccess.WRITE).store_string(JSON.stringify({"records":{"Specimen B-17":{"integral_preparation":true}}}))
 var store=Store.new(path,legacy)
 check(store.records.is_empty() and store.badge("B17") and not store.badge("M08"),"legacy integral badge migrates without inventing a gallery preparation")
 var image:=Image.create(64,48,false,Image.FORMAT_RGB8);image.fill(Color(.6,.4,.2))
 var values:={"exposure":91.0,"cleanliness":92.0,"condition":100.0,"coverage_passed":true,"fine_preparation":false}
 var bad:=values.duplicate();bad.exposure=84.999
 check(not store.archive("M08",bad,image).ok and not FileAccess.file_exists(path),"incomplete specimens cannot be archived")
 bad=values.duplicate();bad.coverage_passed=false
 check(not store.archive("M08",bad,image).ok,"a large hidden region cannot bypass the archive guard")
 bad=values.duplicate();bad.condition=NAN
 check(not store.archive("M08",bad,image).ok,"invalid numeric state cannot corrupt persisted collection")
 check(not store.archive("UNKNOWN",values,image).ok,"only the two catalog specimens can be archived")
 check(store.archive("M08",values,image).ok,"ordinary complete preparation saves even without integral distinction")
 var first:String=store.records.M08.photo
 check(FileAccess.file_exists(store.photo_path(store.records.M08)),"persisted record references an actual photograph")
 var loaded=Store.new(path,legacy)
 check(loaded.records.M08.snapshot.condition==100 and loaded.records.M08.attempts==1,"cold reload restores real metrics and attempt count")
 bad=values.duplicate();bad.condition=80;bad.exposure=100;bad.cleanliness=100
 var result:Dictionary=store.archive("M08",bad,image)
 check(result.ok and not result.improved and store.records.M08.photo==first,"less preserved replay cannot replace the better gallery piece")
 check(store.badge("M08") and store.records.M08.snapshot.exposure==91,"integral achievement is retained separately from selected gallery specimen")
 var better:=values.duplicate();better.exposure=99;better.cleanliness=99
 check(store.archive("M08",better,image).improved and store.records.M08.photo!=first,"equal condition and better preparation replaces the exhibit")
 check(store.records.M08.attempts==3,"all successful archives count exactly once")
 check(store.archive("B17",values,image).ok and store.records.size()==2,"second specimen fills its own collection place")
 loaded=Store.new(path,legacy)
 check(loaded.records.size()==2 and loaded.badge("B17") and loaded.badge("M08"),"two specimens and distinctions survive a cold load")
 check(FileAccess.file_exists(path+".bak"),"previous valid manifest retained as backup")
 FileAccess.open(path,FileAccess.WRITE).store_string("interrupted file")
 loaded=Store.new(path,legacy)
 check(loaded.recovered and not loaded.load_failed and loaded.records.size()==1,"damaged primary recovers last committed backup")
 check(loaded.archive("B17",values,image).ok,"recovered collection can be committed safely")
 var quarantined:=false
 for name in DirAccess.get_files_at(directory):
  if name.contains(".damaged-"):quarantined=true
 check(quarantined,"damaged primary preserved instead of silently overwritten")
 var corrupt:=directory+"/unrecoverable.json"
 FileAccess.open(corrupt,FileAccess.WRITE).store_string("keep me")
 var broken=Store.new(corrupt,legacy)
 check(broken.load_failed and not broken.archive("M08",values,image).ok,"unrecoverable save blocks destructive replacement")
 check(FileAccess.get_file_as_string(corrupt)=="keep me","failed load retains original bytes")
 var blocked:=directory+"/blocked"
 FileAccess.open(blocked,FileAccess.WRITE).store_string("file, not a directory")
 var unwritable=Store.new(blocked+"/records.json",legacy)
 check(not unwritable.archive("M08",values,image).ok and unwritable.records.is_empty(),"write failure reports error and awards no in-memory archive")
 check(FileAccess.get_file_as_string(blocked)=="file, not a directory","failed write never modifies unrelated file")
 check(not Store.safe_photo("../outside.png","M08") and not Store.safe_photo("B17-1.png","M08"),"persisted image paths are bounded to their specimen and directory")
 var payload:={"version":1,"records":{"M08":{"snapshot":values,"attempts":1,"photo":"../outside.png"}}}
 FileAccess.open(directory+"/bad-path.json",FileAccess.WRITE).store_string(JSON.stringify(payload))
 check(Store.new(directory+"/bad-path.json",legacy).load_failed,"tampered image reference is rejected on load")
 FileAccess.open("res://work/test-logs/p6a50/store-tests.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"directory":directory},"  "))
 print("P6A50 STORE ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
