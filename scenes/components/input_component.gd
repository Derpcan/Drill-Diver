extends Node
class_name InputComponent


signal movement_inputs(direction:Vector2, delta:float)
signal jump_input(dir:Vector2, is_pressed:bool)

# Get inputs during each physics process frame
func _physics_process(delta: float) -> void:
	# Get the direction of the characters input
	var dir:Vector2 = Vector2(Input.get_action_strength("move_right")-Input.get_action_strength("move_left"), 0).normalized()
	var is_jump_pressed:bool = false
	var jump_direction:Vector2 = Vector2.ZERO
	if Input.is_action_pressed("jump"):
		is_jump_pressed = true
		jump_direction = Vector2.UP
	
	
	jump_input.emit(jump_direction, is_jump_pressed)
	movement_inputs.emit(dir, delta)
