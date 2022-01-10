extends Node

const DEFAULT_PORT = 37625
const MAX_CLIENTS = 4

var server = null
var client = null

var ip_addr = ""
var ipv4_regex = RegEx.new()

var current_player_username = ""

var client_connected_to_server = false

onready var client_connection_timeout_timer = Timer.new()

func _ready():
	add_child(client_connection_timeout_timer)
	client_connection_timeout_timer.wait_time = 10
	client_connection_timeout_timer.one_shot = true
	
	client_connection_timeout_timer.connect("timeout", self, "_client_connection_timeout")
	
	ipv4_regex.compile("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$")
	# Finds the first IPv4 that isnt localhost
	for ip in IP.get_local_addresses():
		var ip_match = ipv4_regex.search(ip)
		var match_string = ""
		if ip_match: match_string = ip_match.get_string()
		if match_string == ip and match_string != "127.0.0.1":
			ip_addr = ip
	# Failsafe for if that doesn't happen
	if ip_addr == "":
		ip_addr = IP.get_local_addresses()[0]
	
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("connection_failed", self, "_connection_failed")

func create_server():
	server = NetworkedMultiplayerENet.new()
	server.create_server(DEFAULT_PORT, MAX_CLIENTS)
	get_tree().set_network_peer(server)

func join_server():
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip_addr, DEFAULT_PORT)
	get_tree().set_network_peer(client)
	
	client_connection_timeout_timer.start()
	
func _connected_to_server():
	print("Connected to Server!")
	
	client_connected_to_server = true

func _server_disconnected():
	print("Disconnected from Server!")
	
	for child in Persistent.get_children():
		if child.is_in_group("Net"):
			child.queue_free()
	
	reset_network_connection()
	
	if Global.ui != null:
		var prompt = Global.instance_node(load("res://scenes/Prompt.tscn"), Global.ui)
		prompt.set_text("Disconnected from server")

func _client_connection_timeout():
	if client_connected_to_server == false:
		print("Client has been timed out")
		
		reset_network_connection()
		
		var connection_timeout_prompt = Global.instance_node(load("res://scenes/Prompt.tscn"), get_tree().current_scene)
		connection_timeout_prompt.set_text("Connection timed out")

func _connection_failed():
	for child in Persistent.get_children():
		if child.is_in_group("Net"):
			child.queue_free()
	
	reset_network_connection()
	
	if Global.ui != null:
		var prompt = Global.instance_node(load("res://scenes/Prompt.tscn"), Global.ui)
		prompt.set_text("Connection failed")

func reset_network_connection():
	if get_tree().has_network_peer():
		get_tree().network_peer = null
