extends Control

var player = load("res://scenes/Player.tscn")

onready var multiplayer_config = $mutliplayer_config
onready var server_IP = $mutliplayer_config/interactables/server_IP
onready var device_IP_address = $CanvasLayer/device_IP

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	
	device_IP_address.text = "IP ADDRESS: " + Network.ip_addr

func _on_Back_pressed():
	get_tree().change_scene_to(load('res://scenes/Menu.tscn'))

func _player_connected(id):
	print("Player " + str(id) + " has connected!")
	
	instance_player(id)

func _player_disconnected(id):
	print("Player " + str(id) + " has disconnected!")
	
	if Players.has_node(str(id)):
		Players.get_node(str(id)).queue_free()
	

func _on_Create_Server_pressed():
	multiplayer_config.hide()
	Network.create_server()

	instance_player(get_tree().get_network_unique_id())

func _on_Join_Server_pressed():
	if server_IP.text != "":
		multiplayer_config.hide()
		Network.ip_addr = server_IP.text
		Network.join_server()

func _connected_to_server():
	yield(get_tree().create_timer(0.1), "timeout")
	instance_player(get_tree().get_network_unique_id())

func instance_player(id):
	var player_instance = Global.instance_node_at_location(player, Players, Vector2(0,0))
	player_instance.name = str(id)
	player_instance.set_z_index(100)
	player_instance.set_network_master(id)
		