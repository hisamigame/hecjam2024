extends ColorRect

var timer = 0.0 

@export var x_resolution = 128.0
@export var max_offset = 2.0
@export var melt_speed = 0.02

signal transition_done
# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	#Node.PROCESS_MODE_DISABLED
	process_mode = Node.PROCESS_MODE_DISABLED
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	timer += melt_speed
	self.material.set_shader_parameter("timer", timer)
	if timer > 1.0:
		emit_signal('transition_done')

# Call this before transitioning, creates a copy of the screen texture so changes
# can be made underneath before melting to show the new screen.
func generate_offsets():
	process_mode = Node.PROCESS_MODE_ALWAYS
	var offsets = []
	for i in x_resolution:
		offsets.append(randf_range(1.0, max_offset))
	self.material.set_shader_parameter("y_offsets", offsets)
	
	#var img = global.viewport().get_texture().get_image()
	var img = get_viewport().get_texture().get_image()
	var tex = ImageTexture.create_from_image(img)
	self.material.set_shader_parameter("melt_tex", tex)
	
	show()

# Call this after generate_offsets
func transition():
	self.material.set_shader_parameter("melting", true)

	
func reset():
	process_mode = Node.PROCESS_MODE_DISABLED
	visible = false
	timer = 0.0


func _on_transition_done():
	global.transition_done()
