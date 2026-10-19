extends RefCounted
## Original background natural-history collection. No player state or GLB replacement.
static func install(g:Node3D) -> void:
 var assets:=preload("res://assets/museum/polish/collections.scn").instantiate()
 assets.name="EnvironmentAssets";g.add_child(assets)
