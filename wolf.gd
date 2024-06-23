extends CharacterBody2D

class_name Wolf

@export var direction = Vector2.LEFT
var speed = 0.75
var back_speed = 1.0
@export var hp = 200
@export var damage = 2
@onready var animationState = $AnimationTree.get('parameters/playback')

@export var confused = false
@export var frozen = false

@export var evade_time = 1.0
@export var raycast_len = 16.0
var coinflip = 1

var dying_direction = Vector2.ZERO

enum STATE {FORTH, BACK, DYING}
var state = STATE.FORTH

var dead:
	get:
		return state == STATE.DYING


func set_direction(dir):
	direction = dir
	$RayCast2D.target_position = dir * raycast_len
	
# Called when the node enters the scene tree for the first time.
func _ready():
	set_direction(direction)
	

func switch_direction():
	if state == STATE.FORTH:
		state = STATE.BACK
	elif state == STATE.BACK:
		state = STATE.FORTH
	set_direction(-direction)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	match state:
		STATE.FORTH:
			if not frozen:
				$AnimationTree.set("parameters/walk/blend_position", direction)
				velocity = direction * speed * global.TARGET_FPS
				move_and_slide()
				if $RayCast2D.is_colliding():
					switch_direction()
		STATE.BACK:
			if not frozen:
				$AnimationTree.set("parameters/walk/blend_position", direction)
				velocity = direction * speed * global.TARGET_FPS
				move_and_slide()
				if $RayCast2D.is_colliding():
					switch_direction()
			
		STATE.DYING:
			velocity = dying_direction * speed * global.TARGET_FPS
			move_and_slide()

func die(dir):
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
	


func _on_hitbox_area_entered(area):
	if area.instakill:
		hp = 0
	else:
		hp = hp - area.damage
		
	area.queue_free()
	if hp <= 0 and state != STATE.DYING:
		die(area.direction)
	else:
		if area.confuse:
			get_confused()
		if area.freeze:
			get_frozen()


func _on_animation_tree_animation_finished(anim_name):
	if anim_name == 'die':
		queue_free()
