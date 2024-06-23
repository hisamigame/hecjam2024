extends Node2D

@export var damage = 10
@export var maxhp = 100
var hp = 100
# Called when the node enters the scene tree for the first time.
func _ready():
	hp = maxhp
	$hurtbox.damage = damage
	$AnimationPlayer.play('emerge')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_hp(v):
	hp = v
	var fraction = hp/maxhp
	if fraction > 0.66:
		$Sprite2D.frame = 7
	elif fraction > 0.33:
		$Sprite2D.frame = 8
	else:
		$Sprite2D.frame = 9
			

func _on_hitbox_area_entered(area):
	set_hp(hp - area.damage)
	if hp <=0:
		$AnimationPlayer.play('die')


func _on_animation_player_animation_finished(anim_name):
	if anim_name == 'die':
		queue_free()
