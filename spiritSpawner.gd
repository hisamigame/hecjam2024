extends Node

@export var spirit : PackedScene = preload('res://spirit.tscn')
@export var edge_buffer = 16.0

@export var timestep = 4.0
# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.start(timestep)


func spawn_spirit():
	var obj = spirit.instantiate()
	var cpos = global.get_camera_pos()
	var r = global.rng.randf()
	var pos = Vector2(global.x_width, global.y_width)
	
	if r < 0.25:
		# right edge
		pos.x = global.x_width/2.0 + edge_buffer
		pos.y = -global.y_width/2.0 + 4*(r) * global.y_width
		
	elif r < 0.5:
		# top edge
		pos.y = -global.y_width/2.0 - edge_buffer
		pos.x = -global.x_width/2.0 + 4*(r-0.25) * global.x_width
	elif r < 0.75:
		# left edge
		pos.x = -global.x_width/2.0 - edge_buffer
		pos.y = -global.y_width/2.0 + 4*(r-0.50) * global.y_width
	else:
		# bottom edge
		pos.y = global.y_width/2.0 + edge_buffer
		pos.x = -global.x_width/2.0 + 4*(r-0.75) * global.x_width
	
	obj.position = cpos + pos
	global.world_node().add_child(obj)

func _on_timer_timeout():
	spawn_spirit()
