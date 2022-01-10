extends KinematicBody2D

var START_TIME = 120
var MAX_SPEED = 300
var ACCELERATION = 900
var motion = Vector2.ZERO
var current_rotation = 0
onready var animated_sprite = get_node("AnimatedSprite")
onready var animation_player = $AnimationPlayer
onready var player_timer = $Player_Timer
onready var tween = $Tween
onready var Coin_Particle = $Coin_Particle
onready var UI = $Player_Camera/Game_UI
onready var Player_Camera = $Player_Camera
onready var Player_Colors = [Color("ff8600"), Color("e4110c"), Color("4dea08"), Color("0d8ce4")];
onready var player_number = null
onready var movement_enabled = true
puppet var puppet_position = Vector2(0,0) setget puppet_position_set
puppet var puppet_rotation = 0

onready var coins = 0
puppet var puppet_coins = 0


onready var eligible_to_get_coin = false

var username_text = load("res://scenes/Username_Text.tscn")
var username setget username_set
puppet var puppet_username = "" setget puppet_username_set
var username_text_instance = null

var camera_hotfix = false

func _ready():
	get_tree().connect("network_peer_connected", self, "_network_peer_connected")
	
	UI.hide_UI()
	username_text_instance = Global.instance_node_at_location(username_text, Persistent, global_position)
	username_text_instance.set_z_index(100)
	username_text_instance.visible = true
	username_text_instance.player_following = self
	Global.alive_players.append(self)
	set_player_number(Global.alive_players.size())
	yield(get_tree(), "idle_frame")
	if get_tree().has_network_peer():
		if is_network_master():
			Global.player_master = self

func _physics_process(delta):
	if username_text_instance != null:
		username_text_instance.name = "username" + name
	# For some reason, is_network_master() returns true in _ready(), so this is my stupid solution
	if not camera_hotfix:
		Player_Camera.current = is_network_master()
		camera_hotfix = true
	if movement_enabled and get_tree().has_network_peer():
		if is_network_master():
			var axis = get_input_axis()
			if axis == Vector2.ZERO:
				apply_friction(ACCELERATION * delta)
				animated_sprite.playing = false
			else:
				apply_movement(axis * ACCELERATION * delta)
				animated_sprite.playing = true
			motion = move_and_slide(motion)
			rotation = lerp_angle(rotation, axis.angle(), delta * 8)
		else:
			rotation = lerp_angle(rotation, puppet_rotation, delta * 8)

		if eligible_to_get_coin and Global.get_local_player().coins > 0:
			$Give_Coin_Label.modulate.a = 255
		else:
			$Give_Coin_Label.modulate.a = 0

		if Input.is_action_just_pressed("give_coin"):
			if eligible_to_get_coin and Global.get_local_player().coins > 0:
				Global.get_local_player().coins -= 1
				rpc("mine_coin")
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
	if get_tree().has_network_peer():
		if is_network_master():
			rset_unreliable("puppet_position", global_position)
			rset_unreliable("puppet_rotation", rotation)

func username_set(new_value) -> void:
	username = new_value
	
	if get_tree().has_network_peer():
		if is_network_master() and username_text_instance != null:
			username_text_instance.text = username
			rset("puppet_username", username)

func puppet_username_set(new_value) -> void:
	puppet_username = new_value
	
	if get_tree().has_network_peer():
		if not is_network_master() and username_text_instance != null:
			username_text_instance.text = puppet_username

func _network_peer_connected(id) -> void:
	rset_id(id, "puppet_username", username)

sync func end_game():
	set_movement_enabled(false)
	if get_tree().has_network_peer():
		if is_network_master():
			UI.hide_UI()
			player_timer.stop()

sync func start_game():
	set_movement_enabled(true)
	player_timer.time = START_TIME
	if get_tree().has_network_peer():
		if is_network_master():
			Player_Camera.make_current()
			UI.show_UI()
			player_timer.start_timer()

sync func set_movement_enabled(enabled):
	movement_enabled = enabled

sync func update_position(pos):
	global_position = pos
	puppet_position = pos

sync func destroy() -> void:
	username_text_instance.visible = false
	visible = false
	$CollisionShape2D.disabled = true
	player_timer.time = 0
	coins = 0
	player_timer.stop()
	Global.alive_players.erase(self)
	if get_tree().has_network_peer():
		if is_network_master():
			Global.player_master = null

func _exit_tree() -> void:
	Global.alive_players.erase(self)
	if get_tree().has_network_peer():
		if is_network_master():
			Global.player_master = null

sync func set_player_number(number):
	assert(number > 0 and number < 5)
	player_number = number
	animated_sprite.material.set("shader_param/NEWCOLOR", Player_Colors[player_number-1])

sync func mine_coin():
	coins += 1
	Coin_Particle.restart()
	if get_tree().has_network_peer():
		if is_network_master():
			rset("puppet_coins", coins)

sync func enable() -> void:
	username_text_instance.visible = true
	visible = true
	$CollisionShape2D.disabled = false
	player_timer.time = START_TIME
	player_timer.speed = 1
	coins = 0
	UI.update_Game_UI()
	if get_tree().has_network_peer():
		if is_network_master():
			Player_Camera.make_current()
			movement_enabled = true
			Global.player_master = self
	
	if not Global.alive_players.has(self):
		Global.alive_players.append(self)

sync func kill():
	UI.hide_UI()
	rpc("destroy")
	if get_tree().has_network_peer() and Global.alive_players.size() != 1:
			if is_network_master():
				animation_player.play("Reset")
				animation_player.play("Out Of Time")
			elif animation_player.current_animation != "Out Of Time":
				$CanvasLayer/Death_Label.text = "PLAYER\nELIMINATED!"
				animation_player.play("Player Eliminated")

func _on_MouseOverArea_mouse_entered():
	if get_tree().has_network_peer():
		if not is_network_master():
			eligible_to_get_coin = true


func _on_MouseOverArea_mouse_exited():
	eligible_to_get_coin = false
