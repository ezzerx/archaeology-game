class_name DebrisProfile
extends Resource
## P4 presentation/retention only. Never changes tool work or fracture thresholds.
@export_range(1, 8, 1) var bucket_tiles := 3 # 3 * 8 = 24 height texels.
@export var crumbs_per_bucket := Vector2i(3, 4) # Clay / Sandstone per 24x24 zone.
@export_range(0.0, 1.0, 0.01) var retained_fraction := 0.08
@export_range(0.001, 0.1, 0.001) var crumb_capacity := 0.02
@export_range(32, 512, 1) var matrix_crumb_cap := 256 # Clay + Sandstone, including flight.
@export_range(0.001, 0.008, 0.0001) var matrix_crumb_width := 0.0045 # P4-V1 visual baseline; physics changes motion only.
# Transient spectacle is independent of retention, occupancy and cleanup mass.
@export var chunk_width := Vector2(0.003, 0.006)
@export_range(1, 30, 1) var chunk_cells_per_particle := 10
@export_range(1, 8, 1) var chunk_particles_per_patch := 5
@export_range(0.1, 2.0, 0.1) var chunk_lifetime := 0.6

# Small disconnected remnants only; no general hard-material Brush work.
@export var micro_depth_m := 0.0015
@export var micro_max_cells := 4
@export var micro_probe_budget := 64
@export var micro_min_weight := 0.25
# Cleanup commitment, independent from the diagnostic terrain motion kernel.
@export var eject_min_weight := 0.25
@export var eject_exposure := 0.075 # Weighted seconds; centred pass ~0.08-0.1 s.
@export var eject_memory := 0.15 # Forget disconnected glances.
@export var eject_fx_lifetime := 0.35
@export var eject_fx_speed := 0.65
@export var eject_fx_lift := 0.08
@export var eject_fx_cap := 256
