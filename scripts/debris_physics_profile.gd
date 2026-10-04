class_name DebrisPhysicsProfile
extends Resource
## Persistent crumb motion only. Units: metres, seconds; never structural work.
@export var gravity := 0.65
@export var restitution := Vector2(0.12, 0.22) # Clay / Sandstone.
@export var friction := Vector2(14.0, 9.0) # Contact drag, per second.
@export var angular_damping := 12.0
@export var slope_sample_distance := 0.002
@export var slide_threshold := 0.08 # Height gradient, not degrees.
@export var slide_acceleration := 0.65
@export var slide_speed_limit := 0.06
@export var slide_duration := 0.65 # Cumulative contact time before settling.
@export var sleep_speed := 0.008
@export var sleep_angular_speed := 0.4
@export var sleep_delay := 0.15
@export var bounce_min_speed := 0.018 # Post-restitution speed.
@export var contact_skin := 0.00015
@export var spawn_lateral_speed := 0.035
@export var spawn_lift := 0.025
# Integrated over the actual tool delta; independent of frame/tick frequency.
@export var crumb_blower_impulse := 5.0 # m/s of lateral velocity per second.
@export var crumb_blower_lift := 1.8 # m/s of upward velocity per second.
@export var blower_speed_limit := 0.80
@export var blower_lift_limit := 0.22
