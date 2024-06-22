extends Node2D


enum PORTRAITS {HELLNEUTRAL, HELLHAPPY, HELLANGRY,
	EARTHNEUTRAL, EARTHHAPPY, EARTHANGRY,
	MOONNEUTRAL, MOONHAPPY, MOONANGRY,
	JUNKONEUTRAL, JUNKOHAPPY, JUNKOANGRY,
	HISAMINEUTRAL, HISAMIHAPPY, HISAMIANGRY}

enum PORTRAITSTATUS {HIDDEN, INACTIVE, ACTIVE}

@export var inactive_color : Color = Color('464646')

@export var portrait : PORTRAITS = PORTRAITS.HELLNEUTRAL
@export var status : PORTRAITSTATUS = PORTRAITSTATUS.ACTIVE

func set_portrait(v):
	$Sprite2D.frame = v

func set_status(s):
	status = s
	match s:
		PORTRAITSTATUS.HIDDEN:
			visible = false
		PORTRAITSTATUS.INACTIVE:
			visible = true
			$Sprite2D.modulate = inactive_color
		PORTRAITSTATUS.ACTIVE:
			visible = true
			$Sprite2D.modulate = Color.WHITE

func _ready():
	set_status(status)
	set_portrait(portrait)
