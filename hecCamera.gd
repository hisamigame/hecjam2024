extends Node2D

var limit_lower = Vector2(-10000000, -10000000)
var limit_upper = Vector2(10000000, 10000000)

@export var limit_left = -10000000:
	set(v):
		$Camera2D.limit_left = v
		limit_lower.x = v + global.x_width/2.0
@export var limit_top = -10000000:
	set(v):
		$Camera2D.limit_top = v
		limit_lower.y = v + global.y_width/2.0
@export var limit_right = 10000000:
	set(v):
		$Camera2D.limit_right = v
		limit_upper.x = v - global.x_width/2.0
@export var limit_bottom = 10000000:
	set(v):
		$Camera2D.limit_bottom = v
		limit_upper.y = v - global.y_width/2.0

var hecatias = []

func update_camera_position():
	var pos = Vector2.ZERO
	var n = 0
	var ndead = 0
	for h in hecatias:
		if not h.dead:
			pos = pos + h.position
			n = n+1
		else:
			ndead = ndead + 1
	if ndead != 3:
		$Camera2D.position = (pos/n).clamp(limit_lower, limit_upper)
	else:
		global.gameover()
# Called when the node enters the scene tree for the first time.
func _ready():
	hecatias = [$hecatia1, $hecatia2, $hecatia3]
	update_camera_position()
	
	

func cam_position():
	return $Camera2D.position
	
func set_cam_position(pos):
	$Camera2D.position = pos.clamp(limit_lower, limit_upper)
