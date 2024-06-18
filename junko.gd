extends StaticBody2D

enum LOOPMODE {LOOP, NOLOOP, LASTONLY, REMOVESELF}

@export var message_list_list : Array[String]
var messages : Array[String]
var n_message_list : int
var this_message_i = 0

@export var loopmode : LOOPMODE =  LOOPMODE.LOOP

@onready var talkBox = $talkBox
# Called when the node enters the scene tree for the first time.
func _ready():
	print(message_list_list)
	$AnimatedSprite2D.play('default')
	#talkBox.message_list_list = message_list_list
	talkBox.set_messages(message_list_list)
	talkBox.loopmode = loopmode
	
