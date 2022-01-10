extends Node2D

var current_spawn_location_instance_number = 1
var current_player_for_spawn_location_number = null

var game_in_session = false

func _ready() -> void:
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	$AnimationPlayer.clear_queue()
	$AnimationPlayer.play("Reset")
	if get_tree().is_network_server():
		setup_players()
		rpc("playStartAnimation")

func _process(_delta: float) -> void:
	if Global.alive_players.size() == 1 and get_tree().has_network_peer() and game_in_session:
		rpc("end_game")

sync func end_game():
	game_in_session = false
	if get_tree().is_network_server():
		for player in Persistent.get_children():
			if player.is_in_group("Player"):
				player.rpc("end_game")
	# Fixes I've tried but dont work
	# $AnimationPlayer.clear_queue()
	# $AnimationPlayer.play("Reset")
	# Global.get_local_player().animation_player.clear_queue()
	# Global.get_local_player().animation_player.play("Reset")
	$AnimationPlayer.stop()
	$AnimationPlayer.clear_caches()
	$AnimationPlayer.play("Reset")
	if Global.alive_players[0].name == str(get_tree().get_network_unique_id()):
		# This won't play
		$AnimationPlayer.play("Winner Cutscene")
		Global.alive_players[0].rpc("destroy")
	else:
		# Neither will this
		$AnimationPlayer.play("Loser Cutscene")

func setup_players() -> void:
	var pnum = 1
	for player in Persistent.get_children():
		if player.is_in_group("Player"):
			player.rpc("set_player_number", pnum)
			player.rpc("set_movement_enabled", false)
			var pos = get_node("Spawn_Points/"+str(pnum)).position
			player.rpc("update_position", pos)
			pnum += 1

func start_game():
	game_in_session = true
	for player in Persistent.get_children():
		if player.is_in_group("Player"):
			player.rpc("start_game")

func _player_disconnected(id) -> void:
	if Persistent.has_node(str(id)):
		Persistent.get_node(str(id)).username_text_instance.queue_free()
		Persistent.get_node(str(id)).queue_free()

sync func playStartAnimation():
	$AnimationPlayer.play("Pregame Cutscene")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Pregame Cutscene":
		$AnimationPlayer.play("Go!")
		if get_tree().is_network_server():
			start_game()
	if anim_name == "Winner Cutscene" or anim_name == "Loser Cutscene":
		if get_tree().is_network_server():
			rpc("return_to_lobby")

sync func return_to_lobby():
	get_tree().change_scene_to(load("res://scenes/Network_setup.tscn"))
