extends Node
class_name MovementComponent

# Start with a Zero Velocity
var velocity:Vector2 = Vector2.ZERO

@export var friction:float
@export var accel:float

## Determines the max speed of the character
@export var max_speed:float

@export var parent:CharacterBody2D


func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if parent:
		# Clamp the X Velocity so the character doesn't speed up really fast
		velocity.x = clampf(velocity.x, -max_speed, max_speed)
		parent.velocity = velocity
		#print("Velocity.x:",velocity.x)
		#print("Velocity.y:",velocity.y)
		parent.move_and_slide()

func _accelerate_in_direction(dir:Vector2, delta:float) -> void:
	if dir != Vector2.ZERO:
		velocity += dir * accel * delta
	else:
		velocity = velocity.lerp(Vector2(0, velocity.y), friction)

func _accelerate_in_direction_with_accel(acceleration:Vector2, dir:Vector2, delta:float) -> void:
	if dir != Vector2.ZERO:
		velocity += dir * acceleration * delta
	else:
		velocity = velocity.lerp(Vector2(0, velocity.y), friction)

func force_velocity(vel:Vector2) -> void:
	velocity = vel

func force_velocity_y(vel:Vector2) -> void:
	velocity.y = vel.y
