extends Node2D

@export var track_object: Node2D = null
@export var sprite: Texture2D = null
# Called when the node enters the scene tree for the first time.
var angle_threshold0 = 0.0
var angle_threshold1 = 0.0

var width = 16
var draw_pos = Vector2.ZERO
var angle = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _ready():
	var ratio = global.y_width/float(global.x_width)
	angle_threshold0 = atan(ratio)
	angle_threshold1 = PI - angle_threshold0
	$face.texture = sprite

func get_draw_pos():
	var cpos = global.get_camera_pos()
	if cpos:
		var pos = track_object.position
		angle = (pos - cpos).angle()
		
		if angle < angle_threshold0 and angle > -angle_threshold0:
			draw_pos.x = global.x_width/2.0 - width
			draw_pos.y = clamp(tan(angle) * draw_pos.x, -global.y_width/2.0 + width, global.y_width/2.0 - width)
		elif angle > angle_threshold0 and angle < angle_threshold1:
			draw_pos.y = global.y_width/2.0 - width
			draw_pos.x = clamp(draw_pos.y/tan(angle),-global.x_width/2.0 + width, global.x_width/2.0 - width)
		elif angle < -angle_threshold0 and angle > -angle_threshold1:
			draw_pos.y = -global.y_width/2.0 + width
			draw_pos.x = clamp(draw_pos.y/tan(angle), -global.x_width/2.0 + width, global.x_width/2.0 - width)
		else:
			draw_pos.x = -global.x_width/2.0 + width
			draw_pos.y = clamp(tan(angle) * draw_pos.x, -global.y_width/2.0 + width, global.y_width/2.0 - width)
		draw_pos = draw_pos
		draw_pos = cpos + draw_pos

func _physics_process(_delta):
	get_draw_pos()
	position = draw_pos
	$arrow.rotation = angle
