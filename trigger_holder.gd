extends Node2D

@export var enabled = false
# Called when the node enters the scene tree for the first time.
func _ready():
	if enabled:
		enable_children()
	else:
		disable_children()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func switch():
	print('switch')
	if enabled:
		disable_children()
	else:
		enable_children()

func disable_children():
	print('disabling')
	enabled = false
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
	
func enable_children():
	print('enabling')
	enabled = true
	visible = true
	process_mode = Node.PROCESS_MODE_PAUSABLE
