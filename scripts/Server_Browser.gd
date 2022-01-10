extends Control

onready var server_listener = $Server_Listener
onready var server_container = $Server_Container
onready var server_ip_text_edit = $Manual/server_IP
onready var manual_setup_button = $Manual_Setup_Button
onready var manual_setup = $Manual

func _ready() -> void:
	manual_setup.hide()

func _on_Manual_Setup_pressed():
	if manual_setup_button.text != "EXIT SETUP":
		manual_setup.show()
		manual_setup_button.text = "EXIT SETUP"
		server_container.hide()
		server_ip_text_edit.call_deferred("grab_focus")
	else:
		server_ip_text_edit.text = ""
		manual_setup.hide()
		manual_setup_button.text = "MANUAL SETUP"
		server_container.show()
		


func _on_Back_pressed():
	get_tree().reload_current_scene()


func _on_Server_Listener_new_server(serverInfo):
	var server_node = Global.instance_node(load("res://scenes/Server_Display.tscn"), server_container)
	server_node.text = "%s - %s" % [serverInfo.ip, serverInfo.name]
	server_node.ip_address = str(serverInfo.ip)


func _on_Server_Listener_remove_server(serverIp):
	for serverNode in server_container.get_children():
		if serverNode.is_in_group("Server_display"):
			if serverNode.ip_address == serverIp:
				serverNode.queue_free()
				break


func _on_Join_Server_pressed():
	if server_ip_text_edit.text != "":
		Network.ip_addr = server_ip_text_edit.text
		hide()
		Network.join_server()
