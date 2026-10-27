extends Node3D
## Cosmetic atelier dressing. No collision, processing, gameplay or new lights.
## Call setup(host) after the preparation scene's inherited _ready has completed.
var _host: Node3D
var _legacy_visible := false
var _still_life: Node3D

func setup(host: Node3D) -> void:
 name = "AtelierSetDressing"
 _host = host
 if host.specimen_id == "M08":
  _still_life = preload("res://assets/workshop/polish/atelier_marine.scn").instantiate()
  # M08 footprint is 53% wide / 78% deep with a +2% map-center offset.
  # Props keep uniform proportions; the baked textile alone fits that footprint.
  _still_life.scale = Vector3.ONE*.75
  _still_life.position = Vector3(.022,0,.014)
 else:
  _still_life = preload("res://assets/workshop/polish/atelier_still_life.scn").instantiate()
 add_child(_still_life)
 if is_instance_valid(host.desk_art):
  _legacy_visible = host.desk_art.visible
  host.desk_art.hide()
 set_process(false)

func set_enabled(enabled: bool) -> void:
 visible = enabled
 if is_instance_valid(_host) and is_instance_valid(_host.desk_art):
  _host.desk_art.visible = not enabled and _legacy_visible
