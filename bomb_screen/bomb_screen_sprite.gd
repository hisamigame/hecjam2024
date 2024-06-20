extends Sprite2D

@export var inactive_texture: Texture
@export var default_alpha: float = 0.5

@onready var default_texture := texture


func activate() -> void:
	texture = default_texture
	
	modulate.a = 1.0


func deactivate() -> void:
	texture = inactive_texture
	
	modulate.a = default_alpha
