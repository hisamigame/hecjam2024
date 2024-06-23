extends Node2D


@export var mobType : PackedScene = preload('res://otter.tscn')
var idstr : String

enum STATE {ALIVE, DEAD, REMOVED}

@export var state : STATE = STATE.ALIVE
# Called when the node enters the scene tree for the first time.
signal obj_state_update(idstr, state)

var dead:
	get:
		return state !=STATE.ALIVE

@export var hp = 200
@export var confused = false
@export var spawnTime = 2.0

var overlapping_bodies = 0

@onready var spawnTimer = $VisibleOnScreenEnabler2D/spawnTimer

@export var wiltTime1 = 0.5
@export var wiltTime2 = 1.0


func _ready():
	idstr = name
	set_initial_state(state)
	spawnTimer.start(spawnTime)
	
			
func set_initial_state(_state : STATE):
	# NOTE: do not use this outside of initializing
	# it does not animate transition between states
	state = _state
	match state:
		STATE.ALIVE:
			$AnimatedSprite2D.play('default')
		STATE.DEAD:
			$AnimatedSprite2D.play('dead')
			$AnimatedSprite2D.frame = 0
			spawnTimer.stop()
			$StaticBody2D.queue_free()
func die():
	state = STATE.DEAD
	emit_signal('obj_state_update', idstr, state)
	spawnTimer.stop()
	$StaticBody2D.queue_free()
	$AnimatedSprite2D.play('dead')

func _on_hitbox_area_entered(area):
	if state == STATE.ALIVE:
		hp = hp - area.damage
		if area.confuse:
			confused = true
		area.queue_free()
		if hp <= 0:
			die()


func spawn_mob():
	var mob = mobType.instantiate()
	mob.position = position - Vector2(8,8)
	global.world_node().add_child(mob)

func _on_overlap_detector_body_entered(body):
	if body.is_in_group('mobileEnemy'):
		overlapping_bodies = overlapping_bodies + 1
	#print("added body " + str(body) +" " + str(overlapping_bodies))


func _on_overlap_detector_body_exited(body):
	if body.is_in_group('mobileEnemy'):
		overlapping_bodies = overlapping_bodies - 1
	#print("removed body " + str(body) +" " + str(overlapping_bodies))

func _on_spawn_timer_timeout():
	if overlapping_bodies == 0:
		spawn_mob()
