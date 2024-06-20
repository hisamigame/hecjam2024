extends Control

@export var default_alpha = 0.5

@export var max_held_time = 1.0

@export var held_time_substraction_factor: float = 2

@export_category("Progress bar")
@export var hell_color: Color
@export var earth_color: Color
@export var moon_color: Color

@export var hell_and_earth_color: Color
@export var earth_and_moon_color: Color
@export var moon_and_hell_color: Color

@export var all_color: Color
@export var not_enough_bombs_color: Color

@export var progress_bar_color_transition_time_seconds: float = 0.1

var held_time = 0.0

var color_tween: Tween = null

## Colors of individual Hecatias
## Dictionary[Color]
var colors: Dictionary

@onready var hecSprites = [$Sprites/Hell, $Sprites/Earth, $Sprites/Moon]
@onready var progress_bar := $TextureProgressBarBorder/TextureProgressBar

const hell_messages = ['\n', 'DAMAGE to ALL\n', 'DAMAGE+ to ALL\n', 'DEATH+++ to ALL\n']
const earth_messages = ['\n','HEAL', 'HEAL+\n', 'OVERHEAL\n']
const moon_messages = ['\n','MYSTERIOUS POWERS\n', 'MYSTERIOUS POWERS+\n', 'MYSTERIOUS POWERS++\n']


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
	
	for sprite in hecSprites:
		sprite.modulate.a = default_alpha
	
	colors['hell'] = hell_color
	colors['earth'] = earth_color
	colors['moon'] = moon_color


func activate():
	# Reset values
	progress_bar.value = 0
	_reset_label_text()
	
	visible = true
	
	$AnimationPlayer.play("fade_in")
	
	# Enable process to allow animation to play, but only enable process for this node
	# after the animation finishes
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(false)
	
	await $AnimationPlayer.animation_finished
	
	set_process(true)


func deactivate():
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED


func _process(delta):
	var any_active = false
	var i = 0
	var level = 0
	for n in global.actives.values():
		level = level + int(n)
	
	_reset_label_text()
	
	var can_bomb := true
	
	if level > global.bombs:
		# TODO:
		# cannot bomb this hard. Notify player
		hecSprites[0].modulate.a = 0.5
		hecSprites[1].modulate.a = 0.5
		hecSprites[2].modulate.a = 0.5
		$Label.text='NOT ENOUGH BOMBS'
		
		can_bomb = false
	else:
		$Label.text='POWER YOUR BOMB'
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
	elif can_bomb:
		# No active, but can bomb, lower the progress gradually and clamp to 0
		held_time = max(held_time - delta * held_time_substraction_factor, 0)
		
		# If you can't bomb then held time will not change
	
	var color: Color = _get_progress_bar_color(level, can_bomb)
	
	if color != Color.BLACK:
		var current_color: Color = progress_bar.material.get_shader_parameter("color")
		
		if color_tween != null and color_tween.is_running():
			color_tween.kill()
		
		color_tween = create_tween()
		
		color_tween.set_ease(Tween.EASE_IN_OUT)
		
		color_tween.tween_method(set_progress_bar_color,
			current_color,
			color,
			progress_bar_color_transition_time_seconds)
	
	progress_bar.value = 100 * held_time/max_held_time
	
	if held_time > max_held_time:
		held_time = 0.0
		deactivate()
		global.unpause()
		global.set_bombs(global.bombs - level)
		global.world_node().bomb(global.actives, level)


func _reset_label_text() -> void:
	$LabelHell.text = ''
	$LabelEarth.text = ''
	$LabelMoon.text = ''


## Gets the color of the progress bar depending on the currently active Hecatias.
## Returns black color if there are no active Hecatias.
func _get_progress_bar_color(level: int, can_bomb: bool) -> Color:
	if not can_bomb:
		return not_enough_bombs_color
	elif level == 3:
		return all_color
	elif level == 2:
		if _is_pair_active('hell', 'earth'):
			return hell_and_earth_color
		elif _is_pair_active('earth', 'moon'):
			return earth_and_moon_color
		else:
			return moon_and_hell_color
	else:
		for key in global.actives:
			if global.actives[key]:
				return colors[key]
	
	return Color.BLACK


func _is_pair_active(key_1: String, key_2: String) -> bool:
	return global.actives[key_1] and global.actives[key_2]


func set_progress_bar_color(color: Color) -> void:
	$TextureProgressBarBorder/TextureProgressBar.material.set_shader_parameter("color", color)
