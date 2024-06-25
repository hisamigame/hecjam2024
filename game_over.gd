extends Control

var wait = 0.1
var t = 0

var active = false

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED

func activate():
	global.pause()
	active = true
	global.canbomb = false
	visible = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func deactivate():
	global.unpause()
	active = false
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if t < wait:
		t = t + delta
	else:
		if any_input():
			global.to_title()

func any_input():
	return Input.is_action_just_pressed('hell') or Input.is_action_just_pressed('earth') or Input.is_action_just_pressed('moon') or Input.is_action_just_pressed('bomb')
