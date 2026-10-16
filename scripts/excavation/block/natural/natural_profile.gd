extends "res://scripts/workshop/playtest_soil_profile.gd"
var footprint: RefCounted
func _init(surface: WorkingSurface, shape: RefCounted) -> void:
	super(surface)
	footprint = shape
	# Cached voids contain no excavatable material, no hidden rectangular floor.
	for tops in [thin_tops,substrates]:
		for data in tops:
			for i in footprint.outside: data[i] = 0.0
	for i in footprint.outside: fragmented_top[i] = 0.0
