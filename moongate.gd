extends StaticBody2D


func _on_hitbox_area_entered(area):
	if area.mystery:
		queue_free()
