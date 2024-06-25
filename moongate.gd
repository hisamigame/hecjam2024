extends StaticBody2D


enum STATE {ALIVE, DEAD}
var state = STATE.ALIVE

signal obj_state_update(idstr, state)

func _ready():
	set_initial_state(state)

func set_initial_state(_state : STATE):
	state = _state
	match state:
		STATE.ALIVE:
			pass
		STATE.DEAD:
			queue_free()

func die():
	state = STATE.DEAD
	emit_signal('obj_state_update', name, state)
	for c in get_children():
		c.queue_free()
	queue_free()

func _on_hitbox_area_entered(area):
	if area.mystery:
		die()
