extends RefCounted
## Bounded two-entry collection. A photograph records the actual preparation.
## Commit the image first, then an atomic JSON manifest. Never overwrite on error.
const Catalog=preload("res://scripts/p6a50/catalog.gd")
var path:String
var records:Dictionary={}
var legacy_badges:Dictionary={}
var error:=OK
var recovered:=false
var load_failed:=false
func _init(storage:="user://collection/records.json",legacy:="user://preparation_distinctions.json") -> void:
 path=storage
 var data:=_read(path)
 if data.is_empty() and FileAccess.file_exists(path):
  data=_read(path+".bak")
  recovered=not data.is_empty()
  load_failed=not recovered
 if not data.is_empty():records=data.records
 if FileAccess.file_exists(legacy):
  var old:Variant=JSON.parse_string(FileAccess.get_file_as_string(legacy))
  if old is Dictionary and old.get("records") is Dictionary:
   for id in Catalog.IDS:
    var previous:Variant=old.records.get(Catalog.entry(id).legacy,{})
    if previous is Dictionary and previous.get("integral_preparation",false)==true:legacy_badges[id]=true
 if load_failed:error=ERR_FILE_CORRUPT
func _read(file_path:String) -> Dictionary:
 if not FileAccess.file_exists(file_path):return {}
 var file:=FileAccess.open(file_path,FileAccess.READ)
 if file==null or file.get_length()>262144:return {}
 var parser:=JSON.new()
 if parser.parse(file.get_as_text())!=OK:return {}
 var data:Variant=parser.data
 if not data is Dictionary or data.get("version")!=1 or not data.get("records") is Dictionary:return {}
 for id in data.records:
  if not id in Catalog.IDS:return {}
  var record:Variant=data.records[id]
  if not record is Dictionary or not record.get("snapshot") is Dictionary or not valid_snapshot(record.snapshot):return {}
  if not record.get("photo") is String or not safe_photo(record.photo,id):return {}
  if not record.get("attempts") is float and not record.get("attempts") is int:return {}
  if record.attempts<1:return {}
  if not record.get("integral_preparation",false) is bool:return {}
 return data
static func safe_photo(filename:String,id:String) -> bool:
 return filename.is_valid_filename() and filename.begins_with(id+"-") and filename.ends_with(".png")
static func valid_snapshot(snapshot:Dictionary) -> bool:
 for key in ["condition","exposure","cleanliness"]:
  if not snapshot.get(key) is float and not snapshot.get(key) is int:return false
  var value:float=snapshot[key]
  if not is_finite(value) or value<0 or value>100:return false
 return snapshot.exposure>=85 and snapshot.cleanliness>=85 and snapshot.get("coverage_passed",false)==true
static func better(candidate:Dictionary,current:Dictionary) -> bool:
 if current.is_empty():return true
 # Preserve Condition first; at equal care, prefer the more complete finish.
 if not is_equal_approx(candidate.condition,current.condition):return candidate.condition>current.condition
 return candidate.exposure+candidate.cleanliness>current.exposure+current.cleanliness+.001
func badge(id:String) -> bool:return legacy_badges.get(id,false) or records.get(id,{}).get("integral_preparation",false)
func photo_path(record:Dictionary) -> String:return path.get_base_dir().path_join(record.photo)
func archive(id:String,snapshot:Dictionary,photo:Image) -> Dictionary:
 if load_failed:return {"ok":false,"error":ERR_FILE_CORRUPT}
 if not id in Catalog.IDS or not valid_snapshot(snapshot) or photo==null or photo.is_empty():return {"ok":false,"error":ERR_INVALID_DATA}
 error=DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
 if error!=OK or not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(path.get_base_dir())):
  error=ERR_CANT_CREATE;return {"ok":false,"error":error}
 var next:=records.duplicate(true)
 var previous:Dictionary=next.get(id,{})
 var improved:=better(snapshot,previous.get("snapshot",{}))
 var filename:=""
 if improved:
  filename=id+"-"+str(Time.get_unix_time_from_system()).replace(".","-")+"-"+str(Time.get_ticks_usec())+".png"
  error=photo.save_png(path.get_base_dir().path_join(filename))
  if error!=OK:return {"ok":false,"error":error}
  next[id]={"snapshot":snapshot.duplicate(true),"photo":filename}
 next[id].attempts=int(previous.get("attempts",0))+1
 next[id].integral_preparation=badge(id) or (snapshot.exposure>=99 and snapshot.cleanliness>=99 and snapshot.coverage_passed)
 next[id].archived_at=Time.get_datetime_string_from_system()
 error=_commit({"version":1,"records":next})
 if error!=OK:
  if not filename.is_empty():DirAccess.remove_absolute(ProjectSettings.globalize_path(path.get_base_dir().path_join(filename)))
  return {"ok":false,"error":error}
 records=next
 return {"ok":true,"improved":improved,"new":previous.is_empty()}
func _commit(data:Dictionary) -> Error:
 var tmp:=path+".tmp"
 var file:=FileAccess.open(tmp,FileAccess.WRITE)
 if file==null:return FileAccess.get_open_error()
 file.store_string(JSON.stringify(data,"  "));file.flush()
 var result:=file.get_error();file.close()
 if result!=OK:return result
 var absolute:=ProjectSettings.globalize_path(path)
 var backup:=absolute+".bak"
 if FileAccess.file_exists(path):
  if recovered:
   # Keep the readable backup; quarantine the damaged primary on a new commit.
   result=DirAccess.rename_absolute(absolute,absolute+".damaged-"+str(Time.get_ticks_usec()))
  else:
   if FileAccess.file_exists(backup):
    result=DirAccess.remove_absolute(backup)
    if result!=OK:return result
   result=DirAccess.rename_absolute(absolute,backup)
  if result!=OK:return result
 result=DirAccess.rename_absolute(ProjectSettings.globalize_path(tmp),absolute)
 if result!=OK and FileAccess.file_exists(backup):DirAccess.copy_absolute(backup,absolute)
 if result==OK:recovered=false
 return result
