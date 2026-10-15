extends "res://scripts/p6a49/final_profile.gd"
func _init(surface:WorkingSurface,shape:RefCounted,rim:RefCounted) -> void:
 super(surface,shape,rim)
 if surface.fossil.field.specimen_id!="M08":return
 # Uniform geological offset, independent of anatomy; no bone-shaped cover.
 for layer in limits:
  for i in range(surface.size.x*surface.size.y):
   layer[i*2]-=.10
   layer[i*2+1]-=.10
 for table in [substrates,thin_tops]:
  for data in table:
   for i in range(data.size()):data[i]=maxf(0,data[i]-.10)
 for i in range(fragmented_top.size()):fragmented_top[i]=maxf(0,fragmented_top[i]-.10)
 recipe=recipe.duplicate()
 recipe.envelopes=[Rect2(.46,.47,.06,.09)]
 recipe.axes_min=Vector2(44,28);recipe.axes_max=Vector2(55,34)
 recipe.cover_range=Vector2(.07,.085);recipe.depth_range=Vector2(.04,.055)
 cache.clear();set_variant(0)
