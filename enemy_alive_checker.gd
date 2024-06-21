extends Node

var emitted = false

signal all_enemies_dead
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var enemies = get_tree().get_nodes_in_group('enemy')
	var nalive = 0
	for enemy in enemies:
		if !enemy.dead:
			nalive = nalive + 1
	if nalive == 0 and !emitted:
		emitted = true
		emit_signal("all_enemies_dead")
		process_mode = Node.PROCESS_MODE_DISABLED
