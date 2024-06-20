extends Node

var buttons = []

signal all_buttons_pressed

# Called when the node enters the scene tree for the first time.
func _ready():
	for node in get_children():
		if node is MyButton:
			buttons.append(node)
			node.connect('button_pressed', update_button_states)

func update_button_states(_button_name, _button_state):
	var allpressed = true
	for button in buttons:
		if !button.pressed:
			allpressed = false
			break
	if allpressed:
		emit_signal('all_buttons_pressed')
