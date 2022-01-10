extends StaticBody2D

onready var NBox = $"Box N"
onready var SBox = $"Box S"
onready var EBox = $"Box E"
onready var WBox = $"Box W"
onready var Boxes = [NBox, SBox, EBox, WBox]
onready var sprite = $"Machine Sprite"
onready var current_speed = 1
onready var local_player = null
onready var player_at_machine = false
onready var anti_spam = $Anti_Spam

func _ready():
	local_player = Global.get_local_player()
	local_player.player_timer.connect("timeout", self, "_on_Player_Countdown")

func _process(_delta):
	# Speed only Local to players
	for player in Global.alive_players:
		if get_tree().has_network_peer():
			if player.is_network_master():
				if player.player_timer.speed != current_speed:
					current_speed = player.player_timer.speed
					sprite.speed_scale = player.player_timer.speed
					sprite.frame = 1
	if player_at_machine and Input.is_action_just_pressed("mine_coin"):
		if in_click_window() and anti_spam.time_left == 0:
			local_player.rpc("mine_coin")
		else:
			anti_spam.start(0.1)

func _on_Box_body_entered(body):
	if get_tree().has_network_peer():
		if body.is_in_group("Player") and body.is_network_master():
			player_at_machine = true
		else:
			player_at_machine = false


func _on_Box_body_exited(body):
	if get_tree().has_network_peer():
		if body.is_in_group("Player") and body.is_network_master():
			player_at_machine = false

func _on_Player_Countdown():
	sprite.frame = 9
	if player_at_machine:
		$"../AnimationPlayer".play("Press E!")

func in_click_window():
	# Needs to be changed if the animation frames change
	if sprite.frame >= 7 and sprite.frame <= 11:
		return true
	elif sprite.frame >= 18 or sprite.frame <= 1:
		return true
	else:
		return false
