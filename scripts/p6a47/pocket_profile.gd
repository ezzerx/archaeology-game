extends "res://scripts/p6a41/rough_profile.gd"
var layout: RefCounted
func _init(surface: WorkingSurface, shape: RefCounted, rim: RefCounted) -> void:
 super(surface,shape,rim)
 layout = preload("res://scripts/p6a47/pocket_layout.gd").new()
 # An authored initial weathered crust, not a cosmetic shape over intact Soil.
 # The feathered cap stays above the granular roof, so air alone cannot start it.
 for n in range(layout.cells.size()):
  var i: int = layout.cells[n]
  var w: float = layout.weights[n]
  var upper: float = limits[1][i*2]
  fragmented_top[i] = lerpf(fragmented_top[i],upper-.004*(.5+layout.noise_values[n]),w*.95)
