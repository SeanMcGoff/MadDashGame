extends CanvasLayer

# UI Vars
export (int) var time = 120
export (int) var coins = 0

func _ready():
	update_UI()
	
func _on_Timer_timeout():
	time -= 1
	update_UI()

# UI Update Function
func update_UI():
	$TimeLabel.text = "Time: %s" % time
	$CoinsLabel.text = "Coins: %s" % coins



