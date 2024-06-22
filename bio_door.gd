extends Node2D

@export var to_open = false

# frames: 0-7 opening animation
#         7-14 closing animation (15,16,17, 18 are bonus frames)

@onready var r1 = $StaticBody2D/CollisionShape2D
@onready var r2 = $StaticBody2D2/CollisionShape2D

@onready var frame: int = 0:
	set(v):
		frame = v
		var width
		var pos
		if v == 19:
			$Sprite2D.frame = 0
		else:
			$Sprite2D.frame = v
		match v:
			0, 14, 15, 16, 17, 18, 19:
				pos = 36
				width = 72
			1, 13:
				pos = 40
				width = 64
			2, 12:
				pos = 54
				width = 36
			3, 11:
				pos = 61
				width = 20
			4, 10:
				pos = 63
				width = 18
			5, 9:
				pos = 67
				width = 10
			6, 8:
				pos = 68
				width = 8
			7:
				pos = 72
				width = 0
		r1.position.x = -pos
		r1.shape.size.x = width
		r2.position.x = pos
		r2.shape.size.x = width

func switch():
	if to_open:
		close()
	else:
		open()
	$Timer.start()

# Called when the node enters the scene tree for the first time.
func _ready():
	if to_open:
		frame = 7
	else:
		frame = 0

func open():
	to_open = true
	if frame > 7:
		if frame>14:
			frame = 0
		else:
			frame = 14 -frame
	
func close():
	to_open = false
	if frame<7:
		frame = 14 -frame
	


func _on_timer_timeout():
	frame = frame + 1
	if to_open:
		# opening
		if frame == 7:
			$Timer.stop()
	else:
		# closing
		if frame == 19:
			$Timer.stop()
