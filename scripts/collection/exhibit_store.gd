extends RefCounted
## Separate from legacy best-score/photo records: the latest finished block is exhibited.
const Snapshot=preload("res://scripts/collection/exhibit_snapshot.gd")
const IDS=["B17","M08"]
var directory:String
var manifest:Dictionary={"version":1,"latest":{},"attempts":[]}
var load_failed:=false
var recovered:=false
var error_message:=""

func _init(folder:String="user://prepared_exhibits") -> void:
 directory=folder.trim_suffix("/")
 _load_manifest()

static func configured_directory() -> String:
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--exhibit-store="):return arg.trim_prefix("--exhibit-store=")
 return "user://prepared_exhibits"

func _load_manifest() -> void:
 load_failed=false;recovered=false;error_message=""
 var path:=directory.path_join("latest.json")
 if not FileAccess.file_exists(path) and not FileAccess.file_exists(path+".bak"):return
 for candidate in [path,path+".bak"]:
  var data=_read(candidate)
  if _valid(data):
   manifest=data;recovered=candidate.ends_with(".bak")
   return
 load_failed=true;error_message="Les archives ne peuvent pas être lues. Elles ont été conservées."

func _read(path:String):
 if not FileAccess.file_exists(path):return null
 var file:=FileAccess.open(path,FileAccess.READ)
 if file==null or file.get_length()>8*1024*1024:return null
 var parser:=JSON.new()
 if parser.parse(file.get_as_text())!=OK:return null
 return parser.data

func _valid(data) -> bool:
 if not data is Dictionary or data.get("version")!=1:return false
 if not data.get("latest") is Dictionary or not data.get("attempts") is Array:return false
 for id in data.latest:
  if id not in IDS or not _valid_entry(data.latest[id]) or data.latest[id].specimen_id!=id:return false
 for entry in data.attempts:
  if not _valid_entry(entry):return false
 return true

func _valid_entry(entry) -> bool:
 if not entry is Dictionary or entry.get("specimen_id","") not in IDS:return false
 var file=entry.get("file","")
 if not file is String or file!=file.get_file() or not file.begins_with(entry.specimen_id+"-") or not file.ends_with(".scn"):return false
 if not entry.get("sha256") is String or entry.sha256.length()!=64:return false
 if not entry.get("snapshot") is Dictionary:return false
 for metric in ["exposure","cleanliness","condition"]:
  var value=entry.snapshot.get(metric)
  if not (value is float or value is int) or not is_finite(float(value)) or value<0 or value>100:return false
 return entry.snapshot.exposure>=85 and entry.snapshot.cleanliness>=85 and entry.snapshot.get("coverage_passed",false)==true

func archive(preparation:Node3D) -> Dictionary:
 var err:=DirAccess.make_dir_recursive_absolute(directory)
 if err!=OK:return {"ok":false,"error":err}
 # An atomic directory lock prevents two workshop windows from losing each other's index.
 var lock_path:=directory.path_join(".writing")
 err=_acquire_lock(lock_path)
 if err!=OK:return {"ok":false,"error":err}
 _load_manifest()
 var result:=_archive_locked(preparation)
 DirAccess.remove_absolute(lock_path.path_join("owner"))
 DirAccess.remove_absolute(lock_path)
 return result

func _archive_locked(preparation:Node3D) -> Dictionary:
 if load_failed:return {"ok":false,"error":ERR_FILE_CORRUPT}
 var id:String=preparation.specimen_id
 if id not in IDS or not preparation.session.archived or not preparation.session.preparation_complete:return {"ok":false,"error":ERR_INVALID_DATA}
 var snapshot:Dictionary=preparation.session.archive_snapshot.duplicate(true)
 var name:String=id+"-"+str(int(Time.get_unix_time_from_system()))+"-"+Crypto.new().generate_random_bytes(12).hex_encode()+".scn"
 var entry:Dictionary={"specimen_id":id,"file":name,"sha256":"0".repeat(64),"snapshot":snapshot,
  "kind":preparation.demo_kind,"compact_variant":preparation.compact_variant,
  "archived_at":Time.get_datetime_string_from_system(),"integral":snapshot.exposure>=99.0 and snapshot.cleanliness>=99.0}
 if not _valid_entry(entry):return {"ok":false,"error":ERR_INVALID_DATA}
 var err:=DirAccess.make_dir_recursive_absolute(directory)
 if err!=OK:return {"ok":false,"error":err}
 var frozen:=Snapshot.new().capture(preparation)
 var scene:=PackedScene.new()
 err=scene.pack(frozen);frozen.free()
 if err!=OK or not Snapshot.valid_scene(scene):return {"ok":false,"error":ERR_INVALID_DATA}
 var temporary:=directory.path_join(name+".tmp.scn")
 var target:=directory.path_join(name)
 err=ResourceSaver.save(scene,temporary,ResourceSaver.FLAG_COMPRESS)
 if err!=OK:return {"ok":false,"error":err}
 # Verify serialization before committing the index; never replace the last exhibit on failure.
 var reloaded:=ResourceLoader.load(temporary,"PackedScene",ResourceLoader.CACHE_MODE_IGNORE) as PackedScene
 if not Snapshot.valid_scene(reloaded):
  DirAccess.remove_absolute(temporary);return {"ok":false,"error":ERR_FILE_CORRUPT}
 err=DirAccess.rename_absolute(temporary,target)
 if err!=OK:return {"ok":false,"error":err}
 entry.sha256=FileAccess.get_sha256(target)
 var next:=manifest.duplicate(true)
 next.latest[id]=entry;next.attempts.append(entry)
 err=_commit(next)
 if err!=OK:
  DirAccess.remove_absolute(target);return {"ok":false,"error":err}
 manifest=next;recovered=false
 return {"ok":true,"entry":entry}

func _commit(next:Dictionary) -> Error:
 var path:=directory.path_join("latest.json")
 var file:=FileAccess.open(path+".tmp",FileAccess.WRITE)
 if file==null:return FileAccess.get_open_error()
 file.store_string(JSON.stringify(next,"  "));file.flush()
 var err:=file.get_error();file.close()
 if err!=OK:return err
 if not _valid(_read(path+".tmp")):return ERR_FILE_CORRUPT
 # Copy the verified in-memory previous index, including recovery from a damaged main file.
 var backup:=FileAccess.open(path+".bak.tmp",FileAccess.WRITE)
 if backup==null:return FileAccess.get_open_error()
 backup.store_string(JSON.stringify(manifest,"  "));backup.flush()
 err=backup.get_error();backup.close()
 if err!=OK:return err
 err=DirAccess.rename_absolute(path+".bak.tmp",path+".bak")
 if err!=OK:return err
 return DirAccess.rename_absolute(path+".tmp",path)

func entry(id:String) -> Dictionary:
 return manifest.latest.get(id,{})

func load_block(id:String) -> Node3D:
 var record:=entry(id)
 if record.is_empty():return null
 var path:=directory.path_join(record.file)
 if not FileAccess.file_exists(path) or FileAccess.get_sha256(path)!=record.sha256:
  error_message="La pièce "+id+" est indisponible. Son archive est conservée."
  return null
 var scene:=ResourceLoader.load(path,"PackedScene",ResourceLoader.CACHE_MODE_IGNORE) as PackedScene
 if not Snapshot.valid_scene(scene):
  error_message="L’archive "+id+" n’est pas compatible.";return null
 var node:=scene.instantiate() as Node3D
 if node.get_meta("snapshot_version",0)!=1 or not node.get_meta("display_extent") is Vector2:
  node.free();error_message="Format de préparation inconnu.";return null
 return node


func _acquire_lock(path:String) -> Error:
 var err:=DirAccess.make_dir_absolute(path)
 var owner_path:=path.path_join("owner")
 if err!=OK:
  if not FileAccess.file_exists(owner_path):return ERR_BUSY
  var previous:=FileAccess.get_file_as_string(owner_path).to_int()
  if previous<=0 or _writer_is_running(previous):return ERR_BUSY
  # A crashed writer leaves its unique scene unindexed, never an overwritten exhibit.
  DirAccess.remove_absolute(owner_path)
  if DirAccess.remove_absolute(path)!=OK:return ERR_BUSY
  err=DirAccess.make_dir_absolute(path)
  if err!=OK:return ERR_BUSY
 var owner_file:=FileAccess.open(owner_path,FileAccess.WRITE)
 if owner_file==null:
  DirAccess.remove_absolute(path);return ERR_CANT_CREATE
 owner_file.store_string(str(OS.get_process_id()));owner_file.flush()
 err=owner_file.get_error();owner_file.close()
 if err!=OK:
  DirAccess.remove_absolute(owner_path);DirAccess.remove_absolute(path)
 return err

func _writer_is_running(pid:int) -> bool:
 if pid==OS.get_process_id():return true
 # Godot's Unix process API only tracks children started by this process.
 # Independent workshop instances must not steal one another's live lock.
 if OS.get_name()=="Linux":return DirAccess.dir_exists_absolute("/proc/"+str(pid))
 return OS.is_process_running(pid)
