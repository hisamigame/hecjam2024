extends Node2D
class_name MyButton

enum STATE {UNPRESSED, PRESSED}

signal button_pressed(idstr, state)
var npressed = 0
var state = STATE.UNPRESSED

var pressed = false:
	get:
		return state == STATE.PRESSED

func set_pressed():
	$AnimatedSprite2D.play("pressed")
	state = STATE.PRESSED
	emit_signal('button_pressed', name, state)

func set_unpressed():
	$AnimatedSprite2D.play("default")
	state = STATE.UNPRESSED
	emit_signal('button_pressed', name, state)

func _on_area_2d_body_entered(_body):
	npressed = npressed + 1
	if npressed >0:
		set_pressed()
		


func _on_area_2d_body_exited(_body):
	npressed = npressed - 1
	if npressed <=0:
		npressed = 0
		set_unpressed()
	
