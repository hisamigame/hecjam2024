extends CharacterBody2D

class_name Hecatia

enum HEC {HELL, EARTH, MOON}
enum STATE {NORMAL, DEAD, KNOCKBACK}
var state = STATE.NORMAL

@export var hectype : HEC = HEC.HELL
# Called when the node enters the scene tree for the first time.
var press_event

@export var direction = Vector2.DOWN
var last_direction = Vector2.DOWN
var fire_direction = Vector2.DOWN
var speed = 2
var bullet_offset = 0
@export var hold_direction_thresh = 0.04 # ~2 frame

@onready var animationState = $AnimationTree.get('parameters/playback')
@onready var bullet = preload("res://hec_shot.tscn")
@export var bullet_dt = 0.2
var t_same_direction = 0.0

var knockback_direction : Vector2 = Vector2.ZERO
@export var knockback_speed = 2.0
@export var knockback_duration = 0.2
@export var invinc_duration = 2.3
var invincible = false
var nodoublechat = false

var dead:
	get:
		return state == STATE.DEAD

func setup_type():
	# hectype never changes, so this is just called in the _ready() function
	match hectype:
		HEC.HELL:
			$AnimatedSprite2D.sprite_frames = load("res://hell_spriteframes.tres")
			press_event = 'hell'
		HEC.EARTH:
			$AnimatedSprite2D.sprite_frames = load("res://earth_spriteframes.tres")
			press_event = 'earth'
		HEC.MOON:
			$AnimatedSprite2D.sprite_frames = load("res://moon_spriteframes.tres")
			press_event = 'moon'
	
func just_pressed_any_direction():
	if global.actives[press_event]:
		return Input.is_action_just_pressed('ui_down') or Input.is_action_just_pressed('ui_up') or Input.is_action_just_pressed('ui_right') or Input.is_action_just_pressed('ui_left')   
	else:
		return false
		
func _ready():
	setup_type()
	$AnimatedSprite2D.animation='down'
	$AnimatedSprite2D.frame=1
	$bulletTimer.wait_time = bullet_dt
	#$AnimationPlayer.play('down_idle')
	$AnimationTree.set("parameters/walk/blend_position", direction)
	$AnimationTree.set("parameters/idle/blend_position", direction)
	fire_direction = direction
	last_direction = direction

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	match state:
		STATE.NORMAL:
			var input_vector = get_input_direction()
			if global.actives[press_event] and input_vector != Vector2.ZERO:
				direction = input_vector
				velocity = input_vector * speed * global.TARGET_FPS
				animationState.travel("walk")
				#update_fire_direction = true
			else:
				animationState.travel("idle")
				t_same_direction = 0.0
				velocity = Vector2.ZERO
				#direction = Vector2.ZERO
				#nodoublechat = false
			check_if_same_direction(delta)
			$AnimationTree.set("parameters/walk/blend_position", fire_direction)
			$AnimationTree.set("parameters/idle/blend_position", fire_direction)
			move_and_slide()
			
			# check if we chat
			$RayCast2D.target_position = fire_direction * 10.0
			if $RayCast2D.is_colliding() and !global.dialogBox.active and fire_direction == input_vector and global.actives[press_event]:
				if !nodoublechat or just_pressed_any_direction():
					nodoublechat = true
					var chatbox = $RayCast2D.get_collider()
					global.dialogBox.activate(chatbox)
					#chatbox.call_deferred('next_message')
					#chatbox.next_message()
				#print($RayCast2D.get_collider())
	
		STATE.DEAD:
			pass
		STATE.KNOCKBACK:
			velocity = knockback_direction * global.TARGET_FPS * knockback_speed
			move_and_slide()
		
			
	
func check_if_same_direction(delta):
	# the player has to hold direction for a certain time
	# in order to change firing the direction.
	# This is to make diagonal inputs more lenient,
	# as it is hard to release (for example) up and left on the same frame.
	# As a side effect, the player can tap a direction to move without changing
	# firing direction. Might want to make this a feature and make it
	# even more lenient?
	if direction == last_direction:
		t_same_direction = t_same_direction + delta
	else:
		t_same_direction = 0.0
		nodoublechat = false
	if t_same_direction > hold_direction_thresh:
		fire_direction = direction
	last_direction = direction

func get_input_direction():
	# TODO need some kind of input buffer
	# for diagonals so that up+left dont have to be released at the same frame
	# look at how guantlet etc does it.
	var input_vector = Vector2.ZERO
	input_vector = Input.get_vector("ui_left","ui_right", "ui_up", "ui_down")
	return input_vector.normalized()


func die():
	state = STATE.DEAD
	global.world_node().hide_oob(hectype)
	$bulletTimer.stop()
	collision_layer = 0
	
func enter_knockback(dir):
	state = STATE.KNOCKBACK
	knockback_direction = dir
	invincible = true
	$hitbox.set_deferred('monitoring', false)
	modulate.a = 0.5
	await get_tree().create_timer(knockback_duration).timeout
	state = STATE.NORMAL
	await get_tree().create_timer(invinc_duration).timeout
	invincible = false
	#$hitbox.monitoring = true
	$hitbox.set_deferred('monitoring', true)
	modulate.a = 1.0

func _on_bullet_timer_timeout():
	var obj = bullet.instantiate()
	obj.direction = fire_direction
	obj.position = position + fire_direction * bullet_offset
	obj.hectype = hectype
	obj.damage = global.atk[hectype]
	global.world_node().add_child(obj)

	


func _on_visible_on_screen_notifier_2d_screen_exited():
	if not dead:
		var tmp = global.world_node()
		if tmp:
			tmp.show_oob(hectype)


func _on_visible_on_screen_notifier_2d_screen_entered():
	var tmp = global.world_node()
	if tmp:
		tmp.hide_oob(hectype)

func healing_animation():
	#modulate = Color(0.5, 0.5, 1.0)
	material = preload("res://waterheal.tres")
	await get_tree().create_timer(0.5).timeout
	material = null
	

func _on_hitbox_body_entered(body):
	if state == STATE.NORMAL:
		if true:
			global.set_hp(hectype, global.hp[hectype] - body.damage)
			if global.hp[hectype] > 0:
				var dir = body.position.direction_to(position)
				enter_knockback(dir)
			else:
				die()
		
			