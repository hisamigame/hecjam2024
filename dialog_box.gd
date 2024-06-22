extends Control
@onready var label = $Label


var Nmessages = 0 # total messages
var nmessage = 0 # current message
var messages
var portraits1
var status1
var portraits2
var status2


var lapsed = 0
var maxchar = 1
var active = false
var fastfactor = 4
var char_per_sec = 10
var oldcanbomb

var current_chatbox : TalkBox

func set_message(m):
	label.text = m
	
# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
	label.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	

func activate(chatbox : TalkBox):
	current_chatbox = chatbox
	current_chatbox.update_dict()
	global.pause()
	active = true
	oldcanbomb = global.canbomb
	global.canbomb = false
	nmessage = 0
	visible = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	messages = current_chatbox.messages
	status1 = current_chatbox.status1
	status2 = current_chatbox.status2
	portraits1 = current_chatbox.portraits1
	portraits2 = current_chatbox.portraits2
	Nmessages = len(messages)
	next_message(nmessage)
	
	
func next_message(n):
	if n >= Nmessages:
		deactivate()
	else:
		lapsed = 0.0
		label.text = tr(messages[n])
		$portrait1.set_portrait(current_chatbox.expression_dict[portraits1[n]])
		$portrait2.set_portrait(current_chatbox.expression_dict[portraits2[n]])
		$portrait1.set_status(current_chatbox.status_dict[status1[n]])
		$portrait2.set_status(current_chatbox.status_dict[status2[n]])
		maxchar = len(label.text)
		label.visible_characters = 1
	
func deactivate():
	active = false
	#oldcanbomb seems to not work properly for dialogs
	# at start of level. Probably fine to just set to true
	# you should always be able to bomb after dialog
	# (game checks for number of bombs separately)
	global.canbomb = true 
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
	global.unpause()
	current_chatbox.next_message()

#func _unhandled_input(event):
#	print("in dialog!!")
#	print(event)
	
func any_input():
	return Input.is_action_just_pressed('hell') or Input.is_action_just_pressed('earth') or Input.is_action_just_pressed('moon') or Input.is_action_just_pressed('bomb')

func any_input_pressed():
	return Input.is_action_pressed('hell') or Input.is_action_pressed('earth') or Input.is_action_pressed('moon') or Input.is_action_pressed('bomb')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if any_input():
		if (label.visible_characters >= maxchar):
			nmessage = nmessage + 1
			next_message(nmessage)
		else:
			lapsed += fastfactor*delta
	elif any_input_pressed() and label.visible_characters<maxchar:
		lapsed += fastfactor*delta
	else:
		lapsed += delta
	label.visible_characters = lapsed * char_per_sec
