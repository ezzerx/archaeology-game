extends SceneTree
const Store=preload("res://scripts/collection/exhibit_store.gd")
const Handoff=preload("res://scripts/collection/exhibit_handoff.gd")
func _initialize() -> void:run.call_deferred()
func run() -> void:
 var to_gallery:bool=not "--to-workshop" in OS.get_cmdline_user_args()
 var directory:=Store.configured_directory()
 DirAccess.make_dir_recursive_absolute(directory)
 var started:=Time.get_ticks_usec()
 var ok:bool=await Handoff.transfer(self,to_gallery,directory,-1)
 FileAccess.open(directory.path_join("handoff-gallery.json" if to_gallery else "handoff-workshop.json"),FileAccess.WRITE).store_string(JSON.stringify({"ok":ok,"seconds":float(Time.get_ticks_usec()-started)/1e6}))
 if not ok:quit(1)
