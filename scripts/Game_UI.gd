extends CanvasLayer

# UI Vars
onready var oh_shit_indicator = $"Oh Shit Indicator"
onready var oh_shit_animation_player = $"Oh Shit Indicator/Oh Shit Indicator Animation Player"

var current_time = 999
var current_coins = 0

func _ready():
	oh_shit_indicator.color.a = 0
	update_UI()

# UI Update Function
func update_UI(time = current_time, coins = current_coins):
	$TimeLabel.text = "Time: %s" % time
	$CoinsLabel.text = "Coins: %s" % coins
	if time < 11 and time > -1:
		play_oh_shit_animation()

func play_oh_shit_animation():
	oh_shit_animation_player.play("Oh Shit")
