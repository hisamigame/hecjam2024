extends CharacterBody2D

class_name Boss1

var direction = Vector2.DOWN
var speed = 0.5
@export var hp = 500
@export var damage = 14
@onready var animationState = $AnimationTree.get('parameters/playback')

var dying_direction = Vector2.ZERO

enum STATE {NORMAL, DYING}
var state = STATE.NORMAL

var bullet = preload('res://vineshot.tscn')

@export var fire_direction = Vector2.DOWN

var dead:
	get:
		return state == STATE.DYING

func get_nearest_hec_pos():
	var hecspos = global.world_node().get_alive_hec_positions()
	var mindist = INF
	var minindex = null
	var i = 0
	for pos in hecspos:
		var dist = position.distance_squared_to(pos)
		if  dist < mindist:
			minindex = i 
			mindist = dist
		i = i + 1
	
	if (minindex != null) and mindist > 1:
		return hecspos[minindex]
	else:
		return null

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.speed_scale = speed/2.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	match state:
		STATE.NORMAL:
			var hecpos = get_nearest_hec_pos()
			if hecpos:
				direction = position.direction_to(hecpos)
			$AnimationTree.set("parameters/walk/blend_position", direction)
			velocity = direction * speed * global.TARGET_FPS
			move_and_slide()
		STATE.DYING:
			velocity = dying_direction * speed * global.TARGET_FPS
			move_and_slide()

func die(dir):
	global.play_death()
	state = STATE.DYING
	#process_mode =Node.PROCESS_MODE_DISABLED
	animationState.travel("die")
	dying_direction = dir
	collision_layer = 0
	collision_mask = 0

func _on_hitbox_area_entered(area):
	hp = hp - area.damage
	area.queue_free()
	if hp <= 0 and state == STATE.NORMAL:
		die(area.direction)
	else:
		global.play_hurt()


func _on_animation_tree_animation_finished(anim_name):
	if anim_name == 'die':
		queue_free()


func _on_timer_timeout():
	var obj = bullet.instantiate()
	obj.direction = fire_direction
	match fire_direction:
		Vector2.DOWN:
			obj.position.x = position.x
			obj.position.y = global.get_camera_pos().y - global.y_width
			obj.rotation = PI/2
	global.world_node().add_child(obj)
