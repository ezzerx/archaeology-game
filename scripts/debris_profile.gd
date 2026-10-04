class_name DebrisProfile
extends Resource
## P4 presentation/retention only. Never changes tool work or fracture thresholds.
@export_range(1, 8, 1) var bucket_tiles := 3 # 3 * 8 = 24 height texels.
@export_range(1, 8, 1) var crumbs_per_bucket := 2 # Shared across all materials.
@export_range(0.0, 1.0, 0.01) var retained_fraction := 0.08
@export_range(0.001, 0.1, 0.001) var crumb_capacity := 0.02
@export_range(32, 192, 1) var global_crumb_cap := 128 # Resting + moving, never evict visible dirt.
@export_range(0.0005, 0.003, 0.0001) var crumb_width := 0.0014
@export_range(0.001, 0.008, 0.0001) var matrix_crumb_width := 0.0045 # P4-V1 visual baseline; physics changes motion only.
# Transient spectacle is independent of retention, occupancy and cleanup mass.
@export var chunk_width := Vector2(0.003, 0.006)
@export_range(1, 30, 1) var chunk_cells_per_particle := 10
@export_range(1, 8, 1) var chunk_particles_per_patch := 5
@export_range(0.1, 2.0, 0.1) var chunk_lifetime := 0.6
