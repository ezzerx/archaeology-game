extends RefCounted
## Static leafy courtyard, separate rendering layer, no shadowing of the window beam.
static func install(_g:Node3D,parent:Node3D) -> void:
 var garden:=preload("res://assets/museum/polish/garden.scn").instantiate()
 garden.name="WindowCourtyard";parent.add_child(garden)
