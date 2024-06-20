extends Node2D


func switch_children():
	for node in get_children():
		node.switch()

