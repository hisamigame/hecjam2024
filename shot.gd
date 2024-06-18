extends Node2D
class_name Shot

var direction = Vector2.UP
@export var damage = 1
@export var speed = 4



# Called when the node enters the scene tree for the first time.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position = position + direction * speed * global.TARGET_FPS * delta
	check_camera_limits()

func remove():
	queue_free()

func check_camera_limits():
	var cpos = global.get_camera_pos()
	var to_remove = false
	if direction.y > 0:
		if position.y > cpos.y + global.y_width/2.0:
			to_remove  = true
	elif direction.y < 0:
		if position.y < cpos.y - global.y_width/2.0:
			to_remove = true
	if direction.x > 0:
		if position.x > cpos.x + global.x_width/2.0:
			to_remove = true
	elif direction.x < 0:
		if position.x < cpos.x - global.x_width/2.0:
			to_remove = true
	if to_remove:
		remove()
