extends "res://scripts/p6a37/mesh_fossil_field.gd"
var specimen_id:String
var metadata:Dictionary
func _init(resolution:=Vector2i(1024,640),id:="B17") -> void:
 specimen_id=id
 metadata=preload("res://scripts/p6a50/catalog.gd").entry(id)
 super(resolution)
func _patch_resource() -> Resource:return load(metadata.field)
func specimen_name() -> String:return metadata.legacy
func component_name(component:int) -> String:return metadata.components[component]
func classification_name(stage:int) -> String:return metadata.classifications[stage]
func discovery_notice() -> String:return "Un relief délicat apparaît — approchez au Pick (4)"
func classify(previous:int,overall:float,components:Array[float]) -> int:
 if specimen_id=="B17":return super.classify(previous,overall,components)
 var stage:=previous
 if overall>=5:stage=maxi(stage,1)
 if overall>=22 and components[0]>=18:stage=maxi(stage,2)
 if overall>=45 and components[1]>=25:stage=maxi(stage,3)
 return stage
