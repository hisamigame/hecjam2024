extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	# set defaults so the game loops correctly
	# if the player gets taken back to title after ending
	global.current_world = 'world12'
	global.change_music('res://title.ogg')
	global.hide_ui()
	global.allWorldState = {}
	# TODO: comment this out
	#global.start_game()

func _unhandled_input(event):
	if event.is_action_pressed('bomb'):
		global.start_game()


