class_name ReactionProfile
extends Resource
## Prototype values, separate from the historical work/resistance kernel.

@export var seed := 417
@export var clay_patch_size := 9.0
@export var stone_patch_size := 5.0
@export var clay_stress_threshold := 0.12
@export var stone_stress_threshold := 0.13
@export var clay_chunk_depth := 0.15
@export var stone_chunk_depth := 0.08
@export_range(8, 128, 1) var particles_per_family := 48
@export_range(0.1, 2.0) var particle_lifetime := 0.65
@export_range(0.0, 3.0) var particle_amount := 1.0
@export_range(0.0, 0.03) var recoil := 0.012
@export_range(0.0, 0.1) var pitch_variation := 0.04
@export_range(-40.0, 0.0) var audio_volume_db := -15.0

func patch_size(layer: int) -> float:
	return maxf(2.0, clay_patch_size if layer == 1 else stone_patch_size)

func threshold(layer: int) -> float:
	return maxf(0.001, clay_stress_threshold if layer == 1 else stone_stress_threshold)

func chunk_depth(layer: int) -> float:
	return clampf(clay_chunk_depth if layer == 1 else stone_chunk_depth, 0.001, 1.0)
