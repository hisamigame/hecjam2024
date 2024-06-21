extends TileMap

class_name FairySpawner

@export var fairyType : PackedScene = preload('res://fairy.tscn')
var idstr : String

enum STATE {ALIVE, DEAD, REMOVED}

@export var state : STATE = STATE.ALIVE
# Called when the node enters the scene tree for the first time.
signal obj_state_update(idstr, state)

var dead:
	get:
		return state !=STATE.ALIVE

@export var hp = 100

@export var spawnTime = 2.0

var overlapping_bodies = 0

@onready var spawnTimer = $VisibleOnScreenEnabler2D/spawnTimer

@export var wiltTime1 = 0.5
@export var wiltTime2 = 1.0

@export var deadframe = 0:
	set(v):
		var cells = get_used_cells(0)
		for cell in cells:
			var ac = get_cell_atlas_coords(0,cell)
			set_cell(0, cell,v+1, ac)
			
			#print(data.get_terrain())
	get:
		return deadframe

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
			$AnimatedSprite2D.frame = 1
			deadframe = 1
			spawnTimer.stop()
			$StaticBody2D.queue_free()

func die():
	state = STATE.DEAD
	emit_signal('obj_state_update', idstr, state)
	spawnTimer.stop()
	$StaticBody2D.queue_free()
	$AnimatedSprite2D.play('dead')
	await get_tree().create_timer(wiltTime1).timeout
	deadframe = 0
	await get_tree().create_timer(wiltTime2).timeout
	deadframe = 1


func _on_hitbox_area_entered(area):
	if state == STATE.ALIVE:
		hp = hp - area.damage
		area.queue_free()
		if hp <= 0:
			die()


func spawn_fairy():
	print("spawn")
	var fairy = fairyType.instantiate()
	fairy.position = position - Vector2(8,8)
	global.world_node().add_child(fairy)

func _on_overlap_detector_body_entered(body):
	if body is Fairy:
		overlapping_bodies = overlapping_bodies + 1
	#print("added body " + str(body) +" " + str(overlapping_bodies))


func _on_overlap_detector_body_exited(body):
	if body is Fairy:
		overlapping_bodies = overlapping_bodies - 1
	#print("removed body " + str(body) +" " + str(overlapping_bodies))

func _on_spawn_timer_timeout():
	if overlapping_bodies == 0:
		spawn_fairy()
