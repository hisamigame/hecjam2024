extends BombEffect

@export var damage = 10
@export var instakill = false
# Called when the node enters the scene tree for the first time.
func _ready():
	$hurtbox.damage = damage
	$hurtbox.instakill = instakill
	$AnimatedSprite2D.play('hell')

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _physics_process(delta):
#	# only active for one frame?$AnimatedSprite2D.play("hell")
#	$hurtbox.call_deferred('queue_free')
