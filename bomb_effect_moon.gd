extends BombEffect

@export var mystery = true
@export var damage = 0
var t = 0.0;
# Called when the node enters the scene tree for the first time.
func _ready():
	z_index = 0
	material = preload("res://bomb_effect_moon.tres")
	
	$AnimatedSprite2D.play("moon")
	$hurtbox.mystery = mystery
	$hurtbox.damage = 0
	material.set_shader_parameter("t0", t)

func _process(delta):
	t = t + delta
	material.set_shader_parameter("delta", t)
	
