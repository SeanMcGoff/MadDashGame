extends Node

const DEFAULT_PORT = 37625
const MAX_CLIENTS = 4

var server = null
var client = null

var ip_addr = ""

func _ready():
	# Finds the first IP with 192.168.
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168."):
			ip_addr = ip
	# Failsafe for if that doesn't happen
	if ip_addr == "":
		ip_addr = IP.get_local_addresses()[0]
	
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func create_server():
	server = NetworkedMultiplayerENet.new()
	server.create_server(DEFAULT_PORT, MAX_CLIENTS)
	get_tree().set_network_peer(server)

func join_server():
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip_addr, DEFAULT_PORT)
	get_tree().set_network_peer(client)
	
func _connected_to_server():
	print("Connected to Server!")

func _server_disconnected():
	print("Disconnected from Server!")
