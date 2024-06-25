extends Node2D

enum DIR {DOWN, UP}

@export var stairtype : DIR = DIR.UP

@export var toScene : String = 'worldX'

@export var spawnID : int = 0

var sprite : Texture2D

# Called when the node enters the scene tree for the first time.
func _ready():
	match stairtype:
		DIR.UP:
			sprite = preload('res://stairUp.png')
			z_index = 2
		DIR.DOWN:
			sprite = preload('res://stairDown.png')
	$Sprite2D.texture = sprite


func _on_area_2d_body_entered(_body):
	global.change_level(toScene, spawnID)
	
