extends Node

@export var dialog : TalkBox  = null

func switch():
	global.dialogBox.activate(dialog)

