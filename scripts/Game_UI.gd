extends Control

# UI Vars
export (int) var time = 120
export (int) var coins = 0

func _ready():
	$TimeLabel.text = time_format(time)
	$CoinsLabel.text = coins_format(coins)

func _process(delta):
	$TimeLabel.text = time_format(time)
	$CoinsLabel.text = coins_format(coins)

func time_format(time_param: int):
	return "Time: %s" % time_param

func coins_format(coins_param: int):
	return "Coins: %s" % coins_param
