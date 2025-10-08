extends Node
class_name GravityComponent

## The character body that will be affected by gravity
@export var character_body:CharacterBody2D

## The movement component that will be used to accelerate character with gravity
@export var movement_component:MovementComponent

var disabled_gravity:bool = false:
	set(new_val):
		disabled_gravity = new_val
		
		set_physics_process(not disabled_gravity)

func _disable_gravity() -> void:
	disabled_gravity = true

func _enable_gravity() -> void:
	disabled_gravity = false

var gravity_scale:float = 1.0

func _physics_process(delta: float) -> void:
	_add_gravity(delta)
	
func _add_gravity(delta:float) -> void:
	# Check if the character is in the air
	if not character_body.is_on_floor():
		# If it is in the air, then accelerate with gravity downwards
		movement_component._accelerate_in_direction_with_accel(character_body.get_gravity()*gravity_scale, Vector2.DOWN, delta)
	# If character is on the floor and has left over downward velocity
	elif character_body.is_on_floor() and movement_component.velocity.y > 0:
		movement_component.force_velocity_y(Vector2.ZERO) # Set y-velocity to 0
		

# Change the gravity scale to allow character to jump higher when holding jump button
func _change_gravity_scale(new_scale:float) -> void:
	gravity_scale = new_scale
