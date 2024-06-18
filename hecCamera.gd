extends Node2D

@export var limit_left = -10000000:
	set(v):
		$Camera2D.limit_left = v
@export var limit_top = -10000000:
	set(v):
		$Camera2D.limit_top = v
@export var limit_right = 10000000:
	set(v):
		$Camera2D.limit_right = v
@export var limit_bottom = 10000000:
	set(v):
		$Camera2D.limit_bottom = v

var hecatias = []

func update_camera_position():
	var pos = Vector2.ZERO
	var n = 0
	for h in hecatias:
		if not h.dead:
			pos = pos + h.position
			n = n+1
	$Camera2D.position = pos/n
# Called when the node enters the scene tree for the first time.
func _ready():
	hecatias = [$hecatia1, $hecatia2, $hecatia3]
	update_camera_position()
	
	

func cam_position():
	return $Camera2D.position
	
func set_cam_position(pos):
	$Camera2D.position = pos
