extends RefCounted
## Renderer choice is process-wide. Keep the validated workshop and gallery settings.
const WORKSHOP="res://scenes/collection/exhibit_workshop.tscn"
const GALLERY="res://scenes/collection/prepared_gallery.tscn"

static func ready(directory:String) -> void:
 for argument in OS.get_cmdline_user_args():
  if not argument.begins_with("--handoff-ready="):continue
  var name:=argument.trim_prefix("--handoff-ready=")
  if name!=name.get_file() or not name.begins_with(".handoff-") or not name.ends_with(".ready"):continue
  var file:=FileAccess.open(directory.path_join(name),FileAccess.WRITE)
  if file!=null:file.store_string("ready");file.close()

static func transfer(tree:SceneTree,to_gallery:bool,directory:String,selected:int=-1) -> bool:
 if DirAccess.make_dir_recursive_absolute(directory)!=OK:return false
 var token:=".handoff-"+str(Time.get_ticks_usec())+".ready"
 var path:=directory.path_join(token)
 var window:=tree.root
 var args:=PackedStringArray(["--path",ProjectSettings.globalize_path("res://"),
  "--resolution","%dx%d"%[window.size.x,window.size.y],
  "--position","%d,%d"%[window.position.x,window.position.y],"--screen",str(window.current_screen),
  "--rendering-method","forward_plus" if to_gallery else "gl_compatibility",
  GALLERY if to_gallery else WORKSHOP,"--","--exhibit-store="+ProjectSettings.globalize_path(directory),
  "--handoff-ready="+token,"--exhibit-focus="+str(selected)])
 if window.mode in [Window.MODE_FULLSCREEN,Window.MODE_EXCLUSIVE_FULLSCREEN]:args.insert(0,"--fullscreen")
 elif window.mode==Window.MODE_MAXIMIZED:args.insert(0,"--maximized")
 if "--qa" in OS.get_cmdline_user_args():
  args.append("--qa")
  for argument in OS.get_cmdline_user_args():
   if argument.begins_with("--distinction-store="):args.append(argument)
 var pid:=OS.create_process(OS.get_executable_path(),args)
 if pid<0:return false
 var started:=Time.get_ticks_msec()
 while Time.get_ticks_msec()-started<45000:
  if FileAccess.file_exists(path):
   DirAccess.remove_absolute(path);tree.quit();return true
  if not OS.is_process_running(pid):return false
  await tree.create_timer(.15).timeout
 # Only the child created by this transition is stopped; keep the finished block open.
 if OS.is_process_running(pid):OS.kill(pid)
 return false
