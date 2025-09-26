extends Node
class_name JumpComponent


## The character body the component should check to see is on the floor
@export var charcter_body:CharacterBody2D

## The jump height of the character
@export var jump_speed:float



signal jump(vel:Vector2)
signal change_gravity_scale(scale:float)

# Calculates the jump of the character. Takes in variable of whether the jump button is being pressed or not
func _calculate_jump(dir:Vector2, is_pressed:bool) -> void:
	if not charcter_body:
		return
	
	# If the character is on the floor and jump is pressed
	if charcter_body.is_on_floor() and is_pressed:
		emit_signal("jump", jump_speed*dir) # Jump into the air
	# If the character is in the air and jump is pressed
	elif not charcter_body.is_on_floor() and is_pressed:
		emit_signal("change_gravity_scale", 0.5) # Lower the gravity scale
	# If the character is in the air and jump is not pressed
	elif not charcter_body.is_on_floor() and not is_pressed:
		emit_signal("change_gravity_scale", 1) # Reset the gravity scale
		
