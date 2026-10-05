extends Node
class_name JumpComponent


## The character body the component should check to see is on the floor
@export var charcter_body:CharacterBody2D

## The jump height of the character
@export var jump_speed:float

# The amount of time after falling off a ledge that the character can still jump
@export var input_jump_delay:float = 0.3


var can_still_jump:bool = false:
	set(new_val):
		can_still_jump = new_val

# Timer to keep track of whether the character can still jump
var timer:Timer

signal jump(vel:Vector2)
signal change_gravity_scale(scale:float)

func _ready() -> void:
	timer = Timer.new()
	timer.timeout.connect(_can_no_longer_jump) # Connect timer's timeout to turning off jump ability
	timer.one_shot = true # Make sure the timer doesn't keep starting itself
	add_child(timer) # Add the timer to the Node Tree so it is processed properly


# Calculates the jump of the character. Takes in variable of whether the jump button is being pressed or not
func _calculate_jump(dir:Vector2, is_pressed:bool) -> void:
	if not charcter_body:
		return
	
	# Create variable to reduce function calls
	var on_floor:bool = charcter_body.is_on_floor()
	
	# If the character is on the floor and jump is pressed
	if can_still_jump and is_pressed:
		emit_signal("jump", jump_speed*dir) # Jump into the air
		can_still_jump = false
	# If the character is in the air and jump is pressed
	elif not on_floor and is_pressed:
		emit_signal("change_gravity_scale", 0.6) # Lower the gravity scale
	# If the character is in the air and jump is not pressed
	elif not on_floor and not is_pressed:
		emit_signal("change_gravity_scale", 1) # Reset the gravity scale
	
	# Checks if the character is on the floor
	if on_floor:
		can_still_jump = true # Allow the character to be able to jump if they are on the floor
		timer.stop() # Stop the timer so it doesn't cause an issue with stopping jumping
	elif not on_floor: # Check if the character is in the air
		if timer.is_stopped() and can_still_jump: # Check if the timer is stopped and that character can still jump
			timer.start(input_jump_delay) # Start the timer to turn off jumping after a time while character is falling
		

# Turns off the ability to jump once the timer timesout
func _can_no_longer_jump() -> void:
	can_still_jump = false
