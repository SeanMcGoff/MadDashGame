extends Control

var player = load("res://scenes/Player.tscn")

onready var multiplayer_config = $mutliplayer_config
onready var device_IP_address = $Network_UI/device_IP
onready var username_edit = $mutliplayer_config/interactables/username
onready var start_game_button = $Network_UI/Start_Game
onready var player_count = $Network_UI/Player_Count
onready var pnum = 1

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	player_count.hide()
	start_game_button.hide()
	start_game_button.disabled = true
	device_IP_address.text = "IP ADDRESS: " + Network.ip_addr
	if get_tree().network_peer != null:
		multiplayer_config.hide()
		player_count.show()
		if get_tree().is_network_server():
			start_game_button.show()
		for child in Persistent.get_children():
			if child.is_in_group("Player"):
				child.rpc("enable")
				var pos = get_node("Spawn_Points/"+str(pnum)).position
				child.rpc("update_position", pos)
				pnum += 1
	update_Lobby_UI()

func _on_Back_pressed():
	get_tree().change_scene_to(load('res://scenes/Menu.tscn'))

func _player_connected(id):
	print("Player " + str(id) + " has connected!")
	
	instance_player(id)
	update_Lobby_UI()
	
func _player_disconnected(id):
	print("Player " + str(id) + " has disconnected!")
	
	if Persistent.has_node(str(id)):
		Persistent.get_node(str(id)).username_text_instance.queue_free()
		Persistent.get_node(str(id)).queue_free()
	pnum -= 1
	update_Lobby_UI()
	

func _on_Create_Server_pressed():
	if username_edit.text != "":
		Network.current_player_username = username_edit.text
		multiplayer_config.hide()
		Network.create_server()
		instance_player(get_tree().get_network_unique_id())
		player_count.show()
		start_game_button.show()
		update_Lobby_UI()

func _on_Join_Server_pressed():
	if username_edit.text != "":
		multiplayer_config.hide()
		username_edit.hide()
		Global.instance_node(load("res://scenes/Server_Browser.tscn"), self)

func _connected_to_server():
	yield(get_tree().create_timer(0.1), "timeout")
	instance_player(get_tree().get_network_unique_id())
	player_count.show()
	update_Lobby_UI()

func instance_player(id):
	var player_instance = Global.instance_node_at_location(player, Persistent, Vector2(512, 300))
	player_instance.name = str(id)
	player_instance.set_z_index(100)
	player_instance.set_network_master(id)
	var pos = get_node("Spawn_Points/"+str(pnum)).position
	player_instance.rpc("update_position", pos)
	pnum += 1
	if get_tree().has_network_peer():
		if player_instance.is_network_master():
			player_instance.username_set(username_edit.text)
		else:
			player_instance.puppet_username_set(username_edit.text)

func update_Lobby_UI() -> void:
	var numofplayers = 0
	if get_tree().has_network_peer():
		numofplayers = get_tree().multiplayer.get_network_connected_peers().size() + 1
	else:
		numofplayers = 1
	player_count.text = "PLAYERS: " + str(numofplayers)
	if numofplayers > 1:
		start_game_button.disabled = false
	else:
		start_game_button.disabled = true

sync func switch_to_game():
	get_tree().change_scene_to(load("res://scenes/Game.tscn"))

func _on_Start_Game_pressed():
	rpc("switch_to_game")
