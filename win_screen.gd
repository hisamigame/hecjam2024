extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	# set defaults so the game loops correctly
	# if the player gets taken back to title after ending
	global.change_music('res://title.ogg') # WIN
	global.hide_ui()
	# TODO: comment this out
	#global.start_game()

func _unhandled_input(event):
	if event.is_action_pressed('bomb'):
		get_tree().change_scene_to_file('res://title_screen.tscn')
