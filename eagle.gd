extends CharacterBody2D

class_name Eagle

var direction = Vector2.DOWN
var speed = 0.5
var attack_speed = 1.0
@export var hp = 200
@export var damage = 7
@onready var animationState = $AnimationTree.get('parameters/playback')

@export var confused = false
@export var frozen = false

@export var attack_time = 1.0
var coinflip = 1

var dying_direction = Vector2.ZERO
@export var raycast_len = 16.0

enum STATE {FORTH, BACK, ATTACK, DYING}
var state = STATE.FORTH

var dead:
	get:
		return state == STATE.DYING
		

func set_direction(dir):
	direction = dir
	$RayCast2D.target_position = dir * raycast_len

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
	pass # Replace with function body.

func switch_direction():
	if state == STATE.FORTH:
		state = STATE.BACK
	elif state == STATE.BACK:
		state = STATE.FORTH
	set_direction(-direction)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	match state:
		STATE.FORTH, STATE.BACK:
			if not frozen:
				$AnimationTree.set("parameters/walk/blend_position", direction)
				velocity = direction * speed * global.TARGET_FPS
				move_and_slide()
				if $RayCast2D.is_colliding():
					switch_direction()
		STATE.ATTACK:
			if not frozen:
				var hecpos = get_nearest_hec_pos()
				if hecpos:
					direction = position.direction_to(hecpos)
				if confused:
					direction = -direction
				$AnimationTree.set("parameters/walk/blend_position", direction)
				velocity = direction * attack_speed * global.TARGET_FPS
				move_and_slide()
			
		STATE.DYING:
			velocity = dying_direction * speed * global.TARGET_FPS
			move_and_slide()

func die(dir):
	global.play_death()
	state = STATE.DYING
	#process_mode =Node.PROCESS_MODE_DISABLED
	$AnimationTree.active = true
	animationState.travel("die")
	dying_direction = dir
	collision_layer = 0
	collision_mask = 0

func get_confused():
	confused = true
	#material = load('res://confusion_material.tres')
	$moonconfused.visible = true
	$moonconfused.process_mode = Node.PROCESS_MODE_INHERIT
	$moonconfused.play('default')
	
func get_frozen():
	frozen = true
	material = load('res://frozen_material.tres')
	$AnimationTree.active = false
	
func to_attack():
	state = STATE.ATTACK
	$Timer.start(attack_time)

func _on_hitbox_area_entered(area):
	if area.instakill:
		hp = 0
	else:
		hp = hp - area.damage
		
	area.queue_free()
	if hp <= 0 and state != STATE.DYING:
		die(area.direction)
	elif state != STATE.DYING:
		global.play_hurt()
		to_attack()
		if area.confuse:
			get_confused()
		if area.freeze:
			get_frozen()


func _on_animation_tree_animation_finished(anim_name):
	if anim_name == 'die':
		queue_free()

func to_normal():
	state = STATE.FORTH
	$Timer.stop()

func _on_timer_timeout():
	# probably redundant if clause
	if state == STATE.ATTACK:
		to_normal()
