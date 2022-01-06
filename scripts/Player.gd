extends KinematicBody2D

var MAX_SPEED = 300
var ACCELERATION = 900
var motion = Vector2.ZERO
onready var animated_sprite = get_node("AnimatedSprite")
onready var tween = $Tween

puppet var puppet_position = Vector2(0,0) setget puppet_position_set
puppet var puppet_rotation = 0

func _physics_process(delta):
	if is_network_master():
		var axis = get_input_axis()
		# if is_network_master():
		if axis == Vector2.ZERO:
			apply_friction(ACCELERATION * delta)
			animated_sprite.playing = false
		else:
			apply_movement(axis * ACCELERATION * delta)
			animated_sprite.playing = true
		motion = move_and_slide(motion)
		rotation = axis.angle()	
	else:
		rotation_degrees = lerp(rotation_degrees, puppet_rotation, delta * 8)

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

func puppet_position_set(pos):
	puppet_position = pos

	tween.interpolate_property(self, "global_position", global_position, puppet_position, 0.1)
	tween.start()

func _on_network_tick_rate_timeout():
	if is_network_master():
		rset_unreliable("puppet_position", global_position)
		rset_unreliable("puppet_rotation", rotation_degrees)
