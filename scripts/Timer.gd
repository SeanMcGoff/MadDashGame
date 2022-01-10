extends Timer

var speed = 1
var time = 120
puppet var puppet_time = 120
onready var UI = $"../Player_Camera/Game_UI"
onready var player = get_parent()
var effectCount = 0

func _on_Timer_timeout():
	time -= 1
	if effectCount == 0:
		speed = 1
		start(1)
	else:
		effectCount -= 1
		start(1.0 / speed)
	rset("puppet_time", time)
	if time == -1:
		stop()
		player.rpc("kill")

sync func start_timer():
	if get_tree().has_network_peer():
		if is_network_master():
			start(1)

sync func speed_up():
	if get_tree().has_network_peer():
		if is_network_master():
			$"../AnimationPlayer".play("Sped Up")
		if speed >= 1:
			effectCount += 5
			speed = 2.0
		elif effectCount >= 5:
			effectCount -= 5
		else:
			effectCount = 0

sync func slow_down():
	if get_tree().has_network_peer():
		if is_network_master():
			$"../AnimationPlayer".play("Slowed Down")
		if speed <= 1:
			effectCount += 5
			speed = 0.5
		elif effectCount >= 5:
			effectCount -= 5
		else:
			effectCount = 0

func time_set(new_time):
	time = new_time
	if get_tree().has_network_peer():
		if is_network_master():
			rset("puppet_time", time)

sync func puppet_time_set(new_time):
	puppet_time = new_time
	if get_tree().has_network_peer():
		if not is_network_master():
			time = puppet_time
