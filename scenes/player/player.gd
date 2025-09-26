extends CharacterBody2D
class_name Player

@export var movement_component:MovementComponent
@export var jump_component:JumpComponent
@export var input_component:InputComponent
@export var animated_sprite:AnimationSprite
@export var state_machine:StateMachine
@export var gravity_component:GravityComponent

func _ready() -> void:
	input_component.movement_inputs.connect(movement_component._accelerate_in_direction)
	input_component.movement_inputs.connect(_choose_state)
	input_component.jump_input.connect(_choose_state)
	
	input_component.jump_input.connect(jump_component._calculate_jump)
	jump_component.change_gravity_scale.connect(gravity_component._change_gravity_scale)
	jump_component.jump.connect(movement_component.force_velocity_y)

func _choose_state(dir:Vector2, pressed:bool=false, delta:float=0.0) -> void:
	# Flip the character Sprite depending on which direction is being pressed
	if dir.x > 0:
		animated_sprite.flip_h = false
	elif dir.x < 0:
		animated_sprite.flip_h = true
	
	# If the character is falling or jumping, enter the jump state
	if abs(dir.y) > 0 or abs(velocity.y) > 0:
		state_machine._enter_state("jump")
		return
	
	# If the character is not moving on the x-axis and is not moving on y-axis enter idle state
	if velocity.x == 0:
		state_machine._enter_state("idle")
		return 
	
	# If the character is moving on the x-axis and not the y-axis enter the run state
	if abs(dir.x) > 0:
		state_machine._enter_state("run")
		return
	
	
	
	
