extends Timer

export (float) var speed = 1

var effectCount = 0

func _ready():
	#Will be changed later
	start(1)


func _on_Timer_timeout():
	if effectCount == 0:
		speed = 1
		start(1)
	else:
		effectCount -= 1
		start(1 / speed)
