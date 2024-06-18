extends Area2D
class_name TalkBox

enum LOOPMODE {LOOP, NOLOOP, LASTONLY, REMOVESELF}

@export var message_list_list : Array[String]
var messages : Array[String]
var n_message_list : int
var this_message_i = 0
@export var loopmode = LOOPMODE.LOOP

func _ready():
	pass
	

func set_messages(t_message_list_list):
	message_list_list = t_message_list_list
	n_message_list = len(message_list_list)
	if n_message_list > 0:
		this_message_i = 0
		messages.assign(message_list_list[this_message_i].split('|'))
	else:
		# this chat box has no dialog.
		# pointless. Should probably never happen?
		monitorable = false
		
func next_message():
	match loopmode:
		LOOPMODE.LOOP:
			this_message_i = (this_message_i + 1)%n_message_list
			messages.assign(message_list_list[this_message_i].split('|'))
		LOOPMODE.NOLOOP:
			this_message_i = clampi(this_message_i+1,0,n_message_list-1)
			messages.assign(message_list_list[this_message_i].split('|'))
		LOOPMODE.LASTONLY:
			this_message_i = this_message_i + 1
			if this_message_i == n_message_list:
				this_message_i = n_message_list - 1
				messages.assign([message_list_list[this_message_i].split('|')[-1]])
			else:
				messages.assign(message_list_list[this_message_i].split('|'))
		LOOPMODE.REMOVESELF:
			this_message_i = this_message_i + 1
			if this_message_i == n_message_list:
				# safe to do since
				# next_message() is called
				# after the previous message just closed
				# and not while the next message is about
				# to be displayed.
				queue_free()
			else:
				messages.assign(message_list_list[this_message_i].split('|'))
