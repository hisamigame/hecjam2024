extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	global.hide_ui()
	# TODO: comment this out
	global.start_game()

func _unhandled_input(event):
	if event.is_action_pressed('bomb'):
		global.start_game()


