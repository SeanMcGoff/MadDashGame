extends Node2D

onready var local_player_clocknum
onready var player_at_clock = 0
onready var players_clock = null
onready var local_player = null
onready var Speed_Clock_Label = $"../CanvasLayer/Clock_Shop/Speed_Clock_Label"
onready var Slow_Clock_Label = $"../CanvasLayer/Clock_Shop/Slow_Clock_Label"
onready var Not_Enough_Label = $"../CanvasLayer/Clock_Shop/Not_Enough_Label"

func _ready():
	Slow_Clock_Label.hide()
	Speed_Clock_Label.hide()
	Not_Enough_Label.hide()
	local_player = Global.get_local_player()
	local_player_clocknum = local_player.player_number
	for i in range(1,5):
		get_node(str(i)).hide()
	for player in Global.alive_players:
		get_node(str(player.player_number)).show()
	update_Clocks()

func _process(_delta):
	#Slow Down Code
	if Input.is_action_just_pressed("slow_down") and player_at_clock > 0:
		if local_player.coins < 3:
			$"../AnimationPlayer".play("Not Enough Coins")
		else:
			players_clock = Global.get_player_by_number(player_at_clock)
			if players_clock != null:
				local_player.coins -= 3
				players_clock.player_timer.rpc("slow_down")
	
	#Speed Up Code
	if Input.is_action_just_pressed("speed_up") and player_at_clock > 0 and player_at_clock != local_player_clocknum:
		if local_player.coins < 5:
			$"../AnimationPlayer".play("Not Enough Coins")
		else:
			players_clock = Global.get_player_by_number(player_at_clock)
			if players_clock != null:
				local_player.coins -= 5
				players_clock.player_timer.rpc("speed_up")
	update_Clocks()
	
func update_Clocks():
	var player_number = null
	var player_time = null
	for player in Global.alive_players:
		player_number = player.player_number
		if get_tree().has_network_peer():
			if player.is_network_master():
				player_time = player.player_timer.time
			else:
				player_time = player.player_timer.puppet_time
			if player_time > 0:
				get_node(str(player_number)+"/TimeLabel").text = str(player_time)
			else:
				get_node(str(player_number)+"/TimeLabel").text = "0"
				get_node(str(player_number)+"/Speed_Box").hide()

func on_clock_entered(body, clocknum):
	if body == local_player:
		player_at_clock = clocknum
		if clocknum == local_player_clocknum:
			Slow_Clock_Label.show()
			Speed_Clock_Label.hide()
		else:
			Slow_Clock_Label.show()
			Speed_Clock_Label.show()
		$"../AnimationPlayer".play("Clock Shop")

func on_clock_exited(body, _clocknum):
	if body == local_player and $"../".game_in_session:
		player_at_clock = 0
		Slow_Clock_Label.hide()
		Speed_Clock_Label.hide()
		$"../AnimationPlayer".stop()

func _on_P1_Clock_entered(body):
	on_clock_entered(body, 1)

func _on_P1_Clock_exited(body):
	on_clock_exited(body, 1)

func _on_P2_Clock_entered(body):
	on_clock_entered(body, 2)

func _on_P2_Clock_exited(body):
	on_clock_exited(body, 2)

func _on_P3_Clock_entered(body):
	on_clock_entered(body, 3)

func _on_P3_Clock_exited(body):
	on_clock_exited(body, 3)

func _on_P4_Clock_entered(body):
	on_clock_entered(body, 4)

func _on_P4_Clock_exited(body):
	on_clock_exited(body, 4)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Not Enough Coins" and player_at_clock > 0:
		$"../AnimationPlayer".play("Clock Shop")
