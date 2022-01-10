extends CanvasLayer

# UI Vars
onready var oh_shit_indicator = $"Oh Shit Indicator"
onready var oh_shit_animation_player = $"Oh Shit Indicator/Oh Shit Indicator Animation Player"

onready var player = $"../../"
onready var player_timer = $"../../Player_Timer"

func _ready():
	oh_shit_indicator.color.a = 0
	update_Game_UI()

func _process(_delta):
	if get_tree().has_network_peer():
		if is_network_master():
			update_Game_UI()

func update_Game_UI():
		update_Time_UI()
		update_Coins_UI()

func update_Coins_UI():
	$CoinsLabel.text = "Coins: %s" % player.coins

func update_Time_UI():
	var time = player_timer.time
	$TimeLabel.text = "Time: %s" % time
	if time < 11 and time > 0 and Global.alive_players.size() != 1:
		play_oh_shit_animation()

func play_oh_shit_animation():
	oh_shit_animation_player.play("Oh Shit")

func hide_UI():
	$TimeLabel.hide()
	$CoinsLabel.hide()

func show_UI():
	$TimeLabel.show()
	$CoinsLabel.show()
