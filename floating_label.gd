extends Node2D


enum HEC {EARTH, HELL, MOON}
enum KIND {HP, ATK, SPL, BMB}

@export var hell_color: Color
@export var earth_color: Color
@export var moon_color: Color

@export var bomb_color: Color

func _ready() -> void:
	$AnimationPlayer.play("float_up")


func set_text(hectype, powerup_kind: KIND, value: int) -> void:
	if powerup_kind == KIND.BMB:
		_set_label_text("BOMBS", value)
		
		$Label.modulate = bomb_color
	else:
		_set_label_text(KIND.keys()[powerup_kind], value)
		
		match hectype:
			HEC.EARTH:
				$Label.modulate = earth_color
			HEC.HELL:
				$Label.modulate = hell_color
			HEC.MOON:
				$Label.modulate = moon_color


func _set_label_text(stat: String, value: int) -> void:
	$Label.text = "%s +%d" % [stat, value]
