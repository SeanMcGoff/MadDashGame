extends Node

var player_master = null

var alive_players = []

var ui = null

func instance_node_at_location(node: Object, parent: Object, location: Vector2) -> Object:
	var node_instance = instance_node(node, parent)
	node_instance.global_position = location
	return node_instance

func instance_node(node: Object, parent: Object) -> Object:
	var node_instance = node.instance()
	parent.add_child(node_instance)
	return node_instance

func get_player_by_number(number):
	for child in Persistent.get_children():
		if child.is_in_group("Player"):
			if child.player_number == number:
				return child
	return null

func get_local_player():
	for child in Persistent.get_children():
		if get_tree().has_network_peer() and child.is_in_group("Player"):
			if child.is_network_master():
				return child
	return null
