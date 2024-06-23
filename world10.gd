extends "res://world.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	print(state)
	if 'world10' in global.allWorldState:
		state = global.allWorldState['world10']['state']
	if state == 1:
		initial_dialog = null
		$multitrigger/soundTrigger.queue_free()
		$hisami.queue_free()
	super()
	print(state)
	#if state == 1:
		#$triggerHolder.switch()
		#print($triggerHolder.enabled)
		#$fairy.queue_free()
		
	

func bossDefeated():
	set_state(1)
	$multitrigger.switch_children()

