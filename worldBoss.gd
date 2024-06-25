extends "res://world.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	if 'world5' in global.allWorldState:
		state = global.allWorldState['world5']['state']
	if state == 1:
		initial_dialog = null
		$multitrigger/soundTrigger.queue_free()
	super()
	#if state == 1:
		#$triggerHolder.switch()
		#print($triggerHolder.enabled)
		#$fairy.queue_free()
		
	

func bossDefeated():
	set_state(1)
	$multitrigger.switch_children()

