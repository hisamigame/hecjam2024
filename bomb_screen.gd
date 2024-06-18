extends Control


@export var default_alpha = 0.5

@export var max_held_time = 1.0
@export var progressBarLen = 160
var held_time = 0.0

@onready var hecSprites = [$Hell, $Earth, $Moon]

const hell_messages = ['\n', 'DAMAGE to ALL\n', 'DAMAGE+ to ALL\n', 'DEATH+++ to ALL\n']
const earth_messages = ['\n','HEAL', 'HEAL+\n', 'OVERHEAL\n']
const moon_messages = ['\n','MYSTERIOUS POWERS\n', 'MYSTERIOUS POWERS+\n', 'MYSTERIOUS POWERS++\n']


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
	$Hell.modulate.a = default_alpha
	$Earth.modulate.a = default_alpha
	$Moon.modulate.a = default_alpha


func activate():
	visible = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func deactivate():
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
	
	
func _process(delta):
	var any_active = false
	var i = 0
	var level = 0
	for n in global.actives.values():
		level = level + int(n)
	$LabelHell.text = ''
	$LabelEarth.text = ''
	$LabelMoon.text = ''
	
	for k in global.actives:
		if global.actives[k]:
			any_active = true
			hecSprites[i].modulate.a = 1.0
			if k == 'hell':
				$LabelHell.text = hell_messages[level]
			elif k == 'earth':
				$LabelEarth.text = earth_messages[level]
			elif k == 'moon':
				$LabelMoon.text =  moon_messages[level]
		else:
			hecSprites[i].modulate.a = default_alpha
		i = i + 1
		
	if any_active:
		held_time = held_time + delta
	else:
		held_time = 0.0
	$progressBar.size.x = progressBarLen * held_time/max_held_time
	if held_time > max_held_time:
		held_time = 0.0
		deactivate()
		global.unpause()
		global.world_node().bomb(global.actives, level)
