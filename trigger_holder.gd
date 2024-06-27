extends Node2D

@export var enabled = false

@export var can_revert = true
var nswitches = 0

enum STATE {DEFAULT, NONDEFAULT}
var state = STATE.DEFAULT

signal obj_state_update(idstr, state)

func set_initial_state(_state : STATE):
	state = _state
	if (state == STATE.NONDEFAULT) and !can_revert and nswitches ==0:
		# has been flipped before
		# and cannot revert
		nswitches = 1
		enabled = !enabled
	if enabled:
		enable_children()
	else:
		disable_children()


# Called when the node enters the scene tree for the first time.
func _ready():
	set_initial_state(state)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func switch():
	if not can_revert:
		# persistent gate
		if nswitches == 0:
			state =STATE.NONDEFAULT
			emit_signal('obj_state_update', name, state)
			nswitches = 1
			if enabled:
				disable_children()
			else:
				enable_children()
			for child in get_children():
				if child is SoundTrigger:
					child.switch()
	else:
		if enabled:
			disable_children()
		else:
			enable_children()
		for child in get_children():
			if child is SoundTrigger:
				child.switch()

func disable_children():
	enabled = false
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
	
func enable_children():
	enabled = true
	visible = true
	process_mode = Node.PROCESS_MODE_PAUSABLE
