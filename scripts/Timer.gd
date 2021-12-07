extends Timer

export (float) var speed = 1

func _ready():
	#Will be changed later
	start(1 / speed)


func _on_Timer_timeout():
	start(1 / speed)
