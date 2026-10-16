class_name FriablePocketRecipe
extends Resource
## Reusable admission recipe. Geometry is sampled before Bone validation; an
## unsafe candidate is rejected whole, never reshaped around hidden anatomy.
@export_range(0,1) var occurrence_probability:=.8
@export var envelopes:Array[Rect2]=[Rect2(.384,.623,.035,.040),Rect2(.477,.302,.035,.035),Rect2(.455,.588,.035,.038)]
@export var axes_min:=Vector2(55,31)
@export var axes_max:=Vector2(74,41)
@export var cover_range:=Vector2(.155,.210)
@export var depth_range:=Vector2(.075,.125)
@export var safe_cover:=.018
@export var max_attempts:=24
func build(surface:WorkingSurface,limits:PackedFloat32Array,seed_value:int) -> RefCounted:
 var layout=preload("res://scripts/p6a49/pocket_layout.gd").new()
 layout.seed_value=seed_value
 layout.resolution=surface.size
 var random:=RandomNumberGenerator.new()
 random.seed=seed_value
 if random.randf()>=occurrence_probability:return layout
 for attempt in range(max_attempts):
  layout.attempts=attempt+1
  layout.sample(self,random)
  var valid:=true
  var covered_bone:=0
  for slot in range(layout.cells.size()):
   var i:int=layout.cells[slot]
   var roof:float=limits[i*2]-layout.cover[slot]
   var floor:float=roof-layout.depth[slot]
   layout.roofs[i]=roof
   layout.floors[i]=floor
   if surface.structural_ceilings[i]>0:covered_bone+=1
   if floor<=.02 or floor<surface.structural_ceilings[i]+safe_cover or layout.depth[slot]<.013:
    valid=false;break
  if valid and covered_bone>=400:
   layout.present=true
   layout.covered_bone=covered_bone
   return layout
 layout.clear_shape()
 return layout
