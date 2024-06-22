extends Node2D
class_name Vineshot

@export var direction = Vector2.RIGHT
@export var damage = 5
@export var speed = 0.5

@export var length = 3
const tilesize = 16
@export var camera_slack = 64.0


func _ready():
	$TextureRect.size.x = length * tilesize
	$AnimatedSprite2D.position = Vector2(8 + tilesize*length,0)
	$hurtbox.position.x = length * tilesize/2.0
	$hurtbox.scale.x = 2 * length
	$hurtbox.damage = damage

func _physics_process(delta): 
	position = position + direction * speed * global.TARGET_FPS * delta
	check_camera_limits()

func remove():
	queue_free()

func check_camera_limits():
	var cpos = global.get_camera_pos()
	var to_remove = false
	if direction.y > 0:
		if position.y > cpos.y + global.y_width/2.0 + camera_slack:
			to_remove  = true
	elif direction.y < 0:
		if position.y < cpos.y - global.y_width/2.0 - camera_slack:
			to_remove = true
	if direction.x > 0:
		if position.x > cpos.x + global.x_width/2.0 + camera_slack:
			to_remove = true
	elif direction.x < 0:
		if position.x < cpos.x - global.x_width/2.0 - camera_slack:
			to_remove = true
	if to_remove:
		remove()


