extends Sprite2D

class_name Prompt

@export var default_texture : Texture = null
@export var pressed_texture : Texture = null

# Called when the node enters the scene tree for the first time.
func _ready():
	texture = default_texture

func set_pressed():
	texture = pressed_texture
	
	$AudioStreamPlayer.play()
	
func set_unpressed():
	texture = default_texture
