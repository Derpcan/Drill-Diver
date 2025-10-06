extends Node
class_name MovementComponent

# Start with a Zero Velocity
var velocity:Vector2 = Vector2.ZERO

@export var friction:float
@export var accel:float

## Determines the max speed of the character
@export var max_speed:float

@export var parent:CharacterBody2D

var prevent_vel_x_clamp:bool = false

var isdrilling:bool = false

var instrot: bool = false


func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if parent && !isdrilling:
		instrot = false
		if not prevent_vel_x_clamp:
			# Clamp the X Velocity so the character doesn't speed up really fast
			velocity.x = clampf(velocity.x, -max_speed, max_speed)
		parent.velocity = velocity
		#print("Velocity.x:",velocity.x)
		#print("Velocity.y:",velocity.y)
		parent.move_and_slide()
	elif parent:
		
		var turn_speed = 150
		if parent.get_node("AnimationSprite").flip_h == true :
			turn_speed*=-1
		
		var direction = Vector2(cos(parent.rotation), sin(parent.rotation))
		parent.velocity = direction * turn_speed
		
		
		parent.move_and_slide()
		

		

func _accelerate_in_direction(dir:Vector2, delta:float) -> void:
	if prevent_vel_x_clamp || isdrilling:
		return
	if dir != Vector2.ZERO:
		velocity += dir * accel * delta
	else:
		velocity = velocity.lerp(Vector2(0, velocity.y), friction)

func _accelerate_in_direction_with_accel(acceleration:Vector2, dir:Vector2, delta:float) -> void:
	if prevent_vel_x_clamp || isdrilling:
		return
	if dir != Vector2.ZERO:
		velocity += dir * acceleration * delta
	else:
		velocity = velocity.lerp(Vector2(0, velocity.y), friction)

func force_velocity(vel:Vector2) -> void:
	velocity = vel

func force_velocity_y(vel:Vector2) -> void:
	velocity.y = vel.y

func _disable_vel_x_clamp(value = 0) -> void:
	prevent_vel_x_clamp = true

func _enable_vel_x_clamp() -> void:
	prevent_vel_x_clamp = false
	velocity.x *= 0.2
	velocity.y *= 0.2

func _rotate_player(rot:float):
	if isdrilling:
		print("rotation")
		
		print(parent.rotation)
		if parent.get_node("AnimationSprite").flip_h == true :
			rot = -1 *(PI-rot)
		#print(rot)
		
		
		parent.rotation = lerp_angle(parent.rotation, rot, 0.1)
			
		#print("rotating", parent.rotation)
		
