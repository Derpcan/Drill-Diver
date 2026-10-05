extends Node
class_name MovementComponent

# Start with a Zero Velocity
var velocity:Vector2 = Vector2.ZERO

@export var friction:float
@export var accel:float

## Determines the max speed of the character
@export var max_speed:float:
	set(new_val):
		max_speed = new_val

var og_max_speed:float

@export var parent:CharacterBody2D

var prevent_vel_x_clamp:bool = false

var exiting_ground: bool = false

var disable_movement_component:bool = false:
	set(new_val):
		disable_movement_component = new_val
		if disable_movement_component:
			pass
			#print_rich("[color=#EDA451]Movement Component is Disabled", "[/color]")
			#print("Movement Component is Disabled")
		else:
			#print_rich("[color=#42ED59]Movement Component is Enabled", "[/color]")
			pass
			#print("Movement Component is Enabled")
		
		# Enable or disable physics process depending on if the component is enabled
		set_physics_process(not disable_movement_component)


func _disable_movement() -> void:
	velocity = Vector2.ZERO
	parent.velocity = Vector2.ZERO
	disable_movement_component = true

func _enable_movement() -> void:
	disable_movement_component = false

var instrot: bool = false


func _ready() -> void:
	og_max_speed = max_speed

func _physics_process(delta: float) -> void:
	if parent and not disable_movement_component:
		instrot = false
		if not prevent_vel_x_clamp:
			# Clamp the X Velocity so the character doesn't speed up really fast
			#velocity.x = clampf(velocity.x, -max_speed, max_speed)
			if abs(velocity.x) > max_speed*1.5:
				velocity.x = lerpf(velocity.x, sign(velocity.x)*max_speed, 3.0*delta)
			elif abs(velocity.x) > max_speed:
				
				velocity.x = lerpf(velocity.x, sign(velocity.x)*max_speed, 6.0*delta)
		
		# If the character body hits the ceiling, it will set the y velocity to zero
		# So the character will fall after hitting the ceiling instead of attaching to it for a bit
		if parent.is_on_ceiling() and velocity.y < 0:
			velocity.y = 0
			
	
		if parent.is_on_floor() and max_speed != og_max_speed:
			max_speed = og_max_speed
			exiting_ground = false
		
		
		if exiting_ground == true:
			if velocity.x > 0:
				#print("Positive")
				velocity.x -= lerp(0.0 , parent.velocity.x, 0.1)
				#print(velocity.x) 
			elif velocity.x < 0:
				#print("Negative")
				velocity.x += lerp(0.0 , abs(parent.velocity.x), 0.1)
				#print(velocity.x)
			if velocity.x == 0.0:
				exiting_ground = false
				max_speed = og_max_speed
		
			
		
		#update the parent's velocity
		parent.velocity = velocity
		
		
		# Move the parent
		parent.move_and_slide()
		


func _accelerate_in_direction(dir:Vector2, delta:float) -> void:
	if prevent_vel_x_clamp or disable_movement_component:
		return
	if dir != Vector2.ZERO:
		if dir.x > 0 and velocity.x < 0:
			velocity.x *= 0.4
		if dir.x < 0 and velocity.x > 0:
			velocity.x *= 0.4
		if abs(velocity.x) < 80:
			delta *= 3
		velocity += dir * accel * delta
	else:
		velocity = velocity.lerp(Vector2(0, velocity.y), friction)

func _accelerate_in_direction_with_accel(acceleration:Vector2, dir:Vector2, delta:float) -> void:
	if prevent_vel_x_clamp or disable_movement_component:
		return
	if dir != Vector2.ZERO:
		velocity += dir * acceleration * delta
	else:
		velocity = velocity.lerp(Vector2(0, velocity.y), friction)

func force_velocity(vel:Vector2) -> void:
	velocity = vel

func force_velocity_y(vel:Vector2) -> void:
	velocity.y = vel.y

func _disable_vel_x_clamp(_value = 0) -> void:
	prevent_vel_x_clamp = true

func _enable_vel_x_clamp() -> void:
	prevent_vel_x_clamp = false
	#velocity.x *= 0.2
	#velocity.y *= 0.2
	
func _is_exiting_ground():
	exiting_ground = true

func _not_exiting_ground(_vel:Vector2) -> void:
	exiting_ground = false
