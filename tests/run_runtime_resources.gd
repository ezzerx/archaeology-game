extends SceneTree
# Load the retained runtime and regression resources, including binary field data.
var checked := 0
var failures: Array[String] = []
var dependencies := {}
func _initialize() -> void:
 run.call_deferred()
func scan(directory: String) -> void:
 for file in DirAccess.get_files_at(directory):
  var path := directory.path_join(file)
  if file.get_extension() not in ["gd", "tscn", "tres", "res", "gdshader"]: continue
  var links: Array[String] = []
  for dependency in ResourceLoader.get_dependencies(path):
   var parts := dependency.split("::")
   var target := parts[parts.size() - 1]
   if target.begins_with("res://"): links.append(target.trim_prefix("res://"))
  dependencies[path.trim_prefix("res://")] = links
  var resource := ResourceLoader.load(path)
  if resource == null or (resource is Script and not resource.can_instantiate()): failures.append(path)
  checked += 1
 for child in DirAccess.get_directories_at(directory): scan(directory.path_join(child))
func run() -> void:
 for directory in ["scripts", "scenes", "config", "shaders", "materials", "assets", "tests"]:
  scan("res://" + directory)
 DirAccess.make_dir_recursive_absolute("res://work/issue26")
 FileAccess.open("res://work/issue26/resources.json", FileAccess.WRITE).store_string(JSON.stringify({"checks": checked, "failures": failures, "dependencies": dependencies}, "  "))
 print("Runtime resources: %d checks, %d failures" % [checked, failures.size()])
 quit(0 if failures.is_empty() else 1)
