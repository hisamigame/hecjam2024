extends Node


@export var dialog : TalkBox  = null

func switch():
	global.dialogBox.activate(dialog)
	await get_tree().create_timer(5.0).timeout
	global.win()
