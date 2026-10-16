extends "res://scripts/excavation/block/rough/rough_profile.gd"
var layout:RefCounted
var variant:=0
func _init(surface:WorkingSurface,shape:RefCounted,rim:RefCounted) -> void:
 super(surface,shape,rim)
 set_variant(0)
func set_variant(index:int) -> void:
 variant=posmod(index,3)
 layout=preload("res://scripts/excavation/pockets/buried_base/buried_layout.gd").new(variant)
 # Deliberately no edits to initial heights or boundaries: entirely buried.
