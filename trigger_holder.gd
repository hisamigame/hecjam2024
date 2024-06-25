extends Node2D

@export var enabled = false

@export var can_revert = true
var nswitches = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if enabled:
		enable_children()
	else:
		disable_children()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func switch():
	if can_revert == true or nswitches == 0:
		nswitches = nswitches + 1
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
