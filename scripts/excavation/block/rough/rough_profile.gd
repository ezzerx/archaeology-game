extends "res://scripts/excavation/block/natural/natural_profile.gd"
func _init(surface: WorkingSurface, shape: RefCounted, rim: RefCounted) -> void:
	super(surface,shape)
	rim.build_caps(fragmented_top,surface.excavatable_depth)
	for i in rim.caps: assert(surface.fossil.field.component_ids[i] == 0,"Rough rim must stay outside every approved Bone cell")
	for table in [thin_tops,substrates]:
		for n in range(table.size()): table[n] = rim.capped(table[n])
	fragmented_top = rim.capped(fragmented_top)
