extends Node3D
signal set_cam_rotation(_cam_rotation : float)
@export var player : CharacterBody3D
@onready var yaw_node = $CamYaw
@onready var pitch_node = $CamYaw/CamPitch
@onready var camera = $CamYaw/CamPitch/Camera3D
var yaw : float = 0
var pitch : float = 0
var yaw_sensitivity : float = 0.07
var pitch_sensitivity : float = 0.07
var yaw_acceleration : float = 15
var pitch_acceleration : float = 15
var pitch_max : float = 75
var pitch_min : float = -55
var tween : Tween
var position_offset : Vector3 = Vector3(0, 1.3, 0)
var position_offset_target : Vector3 = Vector3(0, 1.3, 0)

func _ready():
	# Mouse input disabled - removed Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	top_level = true

func _input(event):
	# Mouse input completely ignored - function left empty
	pass

func _physics_process(delta):
	position_offset = lerp(position_offset, position_offset_target, 4 * delta)
	global_position = lerp(global_position, player.global_position + position_offset, 5 * delta)
	
	# Camera rotation disabled - pitch and yaw remain at 0
	# pitch = clamp(pitch, pitch_min, pitch_max)
	
	# Rotation lerping disabled - camera stays in default orientation
	# yaw_node.rotation_degrees.y = lerp(yaw_node.rotation_degrees.y, yaw, yaw_acceleration * delta)
	# pitch_node.rotation_degrees.x = lerp(pitch_node.rotation_degrees.x, pitch, pitch_acceleration * delta)
	
	# Signal still emitted but will always be 0
	set_cam_rotation.emit(yaw_node.rotation.y)

func _on_set_movement_state(_movement_state : MovementState):
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(camera, "fov", _movement_state.camera_fov, 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_set_stance(_stance : Stance):
	position_offset_target.y = _stance.camera_height
