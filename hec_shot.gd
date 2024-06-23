extends Shot

enum HEC {EARTH, HELL, MOON}

@export var hectype : HEC = HEC.HELL

@export var on_hit_speed_multiplier: float = 0.1

signal explode_animation_finished


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
	_explode()


func _on_hurtbox_area_entered(_area):
	_explode()


func _on_hurtbox_tree_exiting():
	_explode()


func _explode() -> void:
	$hurtbox/CollisionShape2D.set_deferred("disabled", true)
	
	speed *= on_hit_speed_multiplier
	
	$AnimationTree.get('parameters/playback').travel(_get_explosion_animation_name()) 
	
	await explode_animation_finished
	
	queue_free()


func _get_explosion_animation_name() -> String:
	match hectype:
		HEC.HELL:
			return 'explode_hell'
		HEC.EARTH:
			return 'explode_earth'
		_:
			return 'explode_moon'
