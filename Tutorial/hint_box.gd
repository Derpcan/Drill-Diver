extends Node2D

var triggered = false




func _on_area_2d_body_entered(body):
	if triggered == false:
		$DisplayPicker.play("jump")
		$Open.play("open")
		triggered=true
		
