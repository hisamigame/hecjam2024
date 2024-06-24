extends Node2D

enum STATE {ALIVE, DEAD}
enum KIND {HP, ATK, SPL, BMB}
@export var kind = KIND.HP
@export var cycle = false
@export var cycle_time = 1.0

@export var maxhp_plus = 5
@export var atk_plus = 2
@export var spl_plus = 1
@export var bmb_plus = 1

@export var state = STATE.ALIVE

@export var floating_label_scene: PackedScene

signal obj_state_update(idstr, state)

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
	$AnimationPlayer.play('bob')
	set_initial_state(state)
	
func set_initial_state(s):
	state = s
	match state:
		STATE.ALIVE:
			if cycle:
				$Timer.start(cycle_time)
			set_kind(kind)
		STATE.DEAD:
			queue_free()

func _on_timer_timeout():
	var new_kind = (kind+1) % KIND.BMB
	set_kind(new_kind)

func _on_area_2d_body_entered(body):
	if body is Hecatia:
		# TODO: Get HEC type, set color of text accordingly
		
		var floating_label: Node2D = floating_label_scene.instantiate()
		floating_label.position = position
		get_parent().add_child(floating_label)
		
		match kind:
			KIND.HP:
				global.set_maxhp(body.hectype, global.maxhp[body.hectype] +maxhp_plus)
				global.set_hp(body.hectype, global.hp[body.hectype] +maxhp_plus) 
				
				show_label(floating_label, body.hectype, maxhp_plus)
			KIND.ATK:
				global.set_atk(body.hectype, global.atk[body.hectype] +atk_plus)
				
				show_label(floating_label, body.hectype, atk_plus)
			KIND.SPL:
				global.set_spl(body.hectype, global.spl[body.hectype] +spl_plus) 
				
				show_label(floating_label, body.hectype, spl_plus)
			KIND.BMB:
				global.set_bombs(global.bombs + 1)
				
				show_label(floating_label, body.hectype, 1)
		state = STATE.DEAD
		emit_signal('obj_state_update', name, state)
		queue_free()


func show_label(floating_label: Node2D, hectype, value) -> void:
	floating_label.set_text(hectype, kind, value)
