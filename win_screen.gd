extends Node2D

var wait = 0.1
var t = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	# set defaults so the game loops correctly
	# if the player gets taken back to title after ending
	global.change_music('res://title.ogg') # WIN
	global.hide_ui()
	# TODO: comment this out
	#global.start_game()

func any_input():
	return Input.is_action_just_pressed('hell') or Input.is_action_just_pressed('earth') or Input.is_action_just_pressed('moon') or Input.is_action_just_pressed('bomb')


func _process(delta):
	if t < wait:
		t = t + delta
	else:
		if any_input():
			global.to_title()
