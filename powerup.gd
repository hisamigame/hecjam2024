extends Node2D

enum KIND {HP, ATK, SPL, BMB}
@export var kind = KIND.HP
@export var cycle = false
@export var cycle_time = 1.0

@export var maxhp_plus = 5
@export var atk_plus = 2
@export var spl_plus = 1
@export var bmb_plus = 1


func set_kind(k : KIND):
	kind = k
	match kind:
		KIND.HP:
			$AnimatedSprite2D.play('hp')
		KIND.ATK:
			$AnimatedSprite2D.play('atk')
		KIND.SPL:
			$AnimatedSprite2D.play('spl')
		KIND.BMB:
			$AnimatedSprite2D.play('bmb')

# Called when the node enters the scene tree for the first time.
func _ready():
	if cycle:
		$Timer.start(cycle_time)
	set_kind(kind)


func _on_timer_timeout():
	var new_kind = (kind+1) % KIND.BMB
	set_kind(new_kind)


func _on_area_2d_body_entered(body):
	if body is Hecatia:
		match kind:
			KIND.HP:
				global.set_maxhp(body.hectype, global.maxhp[body.hectype] +maxhp_plus)
				global.set_hp(body.hectype, global.hp[body.hectype] +maxhp_plus) 
			KIND.ATK:
				global.set_atk(body.hectype, global.atk[body.hectype] +atk_plus) 
			KIND.SPL:
				global.set_spl(body.hectype, global.spl[body.hectype] +spl_plus) 
			KIND.BMB:
				global.set_bombs(global.bombs + 1)
		queue_free()
