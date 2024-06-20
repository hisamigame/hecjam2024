extends Area2D


@export var toScene : String = 'worldX'

@export var spawnID : int = 0

var sprite : Texture2D

func _on_body_entered(_body):
	print(_body)
	global.change_level(toScene, spawnID)

