extends "res://scripts/p6a41/rough_profile.gd"
const TRIAL_SEEDS:=[49301,49302,49303,49304,49305]
var recipe:FriablePocketRecipe=preload("res://config/p6a49_pocket.tres")
var layout:RefCounted
var variant:=0
var context:WorkingSurface
var cache:Dictionary={}
func _init(surface:WorkingSurface,shape:RefCounted,rim:RefCounted) -> void:
 super(surface,shape,rim)
 context=surface
 set_variant(0)
func set_variant(index:int) -> void:
 variant=posmod(index,TRIAL_SEEDS.size())
 var seed_value:int=TRIAL_SEEDS[variant]
 if not cache.has(seed_value):cache[seed_value]=recipe.build(context,limits[1],seed_value)
 layout=cache[seed_value]
