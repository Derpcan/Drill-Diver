extends Camera2D
class_name GameCamera


signal back_at_checkpoint

var move_to_position:Vector2 = Vector2.ZERO


func _ready() -> void:
	pass

func _move_back_to_checkpoint(new_position:Vector2) -> void:
	print_rich("[color=#E2ED4E]Checkpoint Position: ", new_position,"[/color]")
	print_rich("[color=#5AED49]Current Position: ", position,"[/color]")
	#print(new_position)
	#print(global_position)
	var tween:Tween = get_tree().create_tween()
	tween.tween_property(self, "position", new_position, 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.play()
	
	tween.finished.connect(tween_finished)
	

func tween_finished() -> void:
	print_rich("[color=#49EDC1]Returned to Checkpoint","[/color]")
	emit_signal("back_at_checkpoint")
