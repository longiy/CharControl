extends Node
@export var player : CharacterBody3D
@export var mesh_root : Node3D
@export var rotation_speed : float = 8
@export var fall_gravity : float = 45
var jump_gravity : float = fall_gravity
var direction : Vector3
var velocity : Vector3
var acceleration : float
var speed : float
var cam_rotation : float = 0
var player_init_rotation : float

func _ready():
	player_init_rotation = player.rotation.y

func _physics_process(delta):
	velocity.x = speed * direction.normalized().x
	velocity.z = speed * direction.normalized().z
	
	if not player.is_on_floor():
		if velocity.y >= 0:
			velocity.y -= jump_gravity * delta
		else:
			velocity.y -= fall_gravity * delta
	
	player.velocity = player.velocity.lerp(velocity, acceleration * delta)
	player.move_and_slide()
	
	# 8-directional rotation system
	if direction.length() > 0:  # Only rotate if there's movement input
		var raw_rotation = atan2(direction.x, direction.z) - player_init_rotation
		var target_rotation = snap_to_8_directions(raw_rotation)
		#mesh_root.rotation.y = lerp_angle(mesh_root.rotation.y, target_rotation, rotation_speed * delta)
		mesh_root.rotation.y = target_rotation

func snap_to_8_directions(angle: float) -> float:
	# Convert angle to degrees for easier calculation
	var degrees = rad_to_deg(angle)
	
	# Normalize to 0-360 range
	while degrees < 0:
		degrees += 360
	while degrees >= 360:
		degrees -= 360
	
	# Define 8 directions (in degrees)
	# 0=North, 45=NE, 90=East, 135=SE, 180=South, 225=SW, 270=West, 315=NW
	var directions = [0, 45, 90, 135, 180, 225, 270, 315]
	
	# Find closest direction
	var closest_direction = 0
	var min_difference = 180
	
	for dir in directions:
		var difference = abs(degrees - dir)
		# Handle wrap-around (e.g., 350° is close to 0°)
		if difference > 180:
			difference = 360 - difference
		
		if difference < min_difference:
			min_difference = difference
			closest_direction = dir
	
	# Convert back to radians
	return deg_to_rad(closest_direction)

func _jump(jump_state : JumpState):
	velocity.y = 2 * jump_state.jump_height / jump_state.apex_duration
	jump_gravity = velocity.y / jump_state.apex_duration

func _on_set_movement_state(_movement_state : MovementState):
	speed = _movement_state.movement_speed
	acceleration = _movement_state.acceleration

func _on_set_movement_direction(_movement_direction : Vector3):
	direction = _movement_direction.rotated(Vector3.UP, cam_rotation + player_init_rotation)

func _on_set_cam_rotation(_cam_rotation : float):
	cam_rotation = _cam_rotation
