extends KinematicBody2D

# Similar to player, but works offline
var MAX_SPEED = 300
var ACCELERATION = 900
var motion = Vector2.ZERO
var current_rotation = 0

onready var animated_sprite = get_node("AnimatedSprite")

func _physics_process(delta):
	var axis = get_input_axis()
	# if is_network_master():
	if axis == Vector2.ZERO:
		apply_friction(ACCELERATION * delta)
		animated_sprite.playing = false
	else:
		apply_movement(axis * ACCELERATION * delta)
		animated_sprite.playing = true
	motion = move_and_slide(motion)
	rotation = lerp_angle(rotation, axis.angle(), delta * 8)

func get_input_axis():
	var axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	axis.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	return axis.normalized()

func apply_friction(amt):
	if motion.length() > amt:
		motion -= motion.normalized() * amt
	else:
		motion = Vector2.ZERO

func apply_movement(acceleration):
	motion += acceleration
	motion = motion.clamped(MAX_SPEED)
