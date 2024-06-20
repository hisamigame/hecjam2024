extends Shot

enum HEC {EARTH, HELL, MOON}

@export var hectype : HEC = HEC.HELL

func _ready():
	$hurtbox.damage = damage
	$hurtbox.direction = direction
	match hectype:
		HEC.HELL:
			$sprite.animation = 'hell'
		HEC.EARTH:
			$sprite.animation = 'earth'
		HEC.MOON:
			$sprite.animation = 'moon'
			
	$AnimationTree.set("parameters/idle/blend_position", direction)


func _on_hurtbox_body_entered(_body):
	remove()

func _on_hurtbox_area_entered(_area):
	remove()


func _on_hurtbox_tree_exiting():
	queue_free()
