extends "res://spirit.gd"

# Store the angle so it's not calculated every time the enemy has to rotate
var rotation_angle_radians: float = deg_to_rad(90)

# Flag used to check the wall raycasts only if the enemy is next to a wall
var is_next_to_wall := false


func _ready() -> void:
	direction = Vector2.LEFT


func _physics_process(_delta: float) -> void:
	match state:
		STATE.NORMAL:
			velocity = direction * speed * global.TARGET_FPS
			
			move_and_slide()
		STATE.DYING:
			velocity = dying_direction * speed * global.TARGET_FPS
			
			move_and_slide()
	
	if $WallRayCasts/FrontRayCast2D.is_colliding() or $WallRayCasts/RearRayCast2D.is_colliding():
		is_next_to_wall = true
	
	if is_next_to_wall:
		if $DirectionRayCast2D.is_colliding():
			_rotate_ray_casts(rotation_angle_radians)
		elif not $WallRayCasts/FrontRayCast2D.is_colliding() and not $WallRayCasts/RearRayCast2D.is_colliding():
			_rotate_ray_casts(-rotation_angle_radians)
			
			is_next_to_wall = false
	else:
		if $DirectionRayCast2D.is_colliding():
			_rotate_ray_casts(rotation_angle_radians)


func _rotate_ray_casts(angle_radians: float) -> void:
	direction = direction.rotated(angle_radians)
	
	$WallRayCasts.rotate(angle_radians)
	$DirectionRayCast2D.rotate(angle_radians)
