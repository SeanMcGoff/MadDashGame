extends Timer

export (float) var speed = 1
export (int) var time = 120
onready var UI = $"../Player_Camera/Game_UI"
var effectCount = 0

func _ready():
	#Will be changed later
	# start(1)
	UI.update_UI(time)


func _on_Timer_timeout():
	time -= 1
	UI.update_UI(time)
	if effectCount == 0:
		speed = 1
		start(1)
	else:
		effectCount -= 1
		start(1 / speed)
