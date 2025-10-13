extends Node
class_name DrillComponent

## The characterbody2d that is able to drill
@export var parent:CharacterBody2D


@export var drill_speed:float
@export var turn_raduis:float

@export var drill_detector:Area2D
@export var drill_shape_cast:ShapeCast2D 
@export var bump_detector:Area2D

signal rotate
signal bounce
signal entered_drill_mode()

var can_move:bool = true
var can_bounce:bool = true
var last_dash:Vector2

var drill_enabled:bool = false:
	set(new_val):
		drill_enabled = new_val
		if drill_enabled:
			#print("Drill Enabled")
			print_rich("[color=#42ED59]Drill Enabled", "[/color]")
			
		else:
			#print("Drill Disabled")
			print_rich("[color=#EDA451]Drill Disabled", "[/color]")
		
		# Enable or disable the physics_process call depending on 
		# if the character is in the drilling state
		set_physics_process(drill_enabled)




func _set_last_dash(dir: Vector2):
	if dir != Vector2.ZERO:
		last_dash = dir


func _disable_drill() -> void:
	drill_enabled = false


func _enable_drill() -> void:
	drill_enabled = true


func _physics_process(delta: float) -> void:
	# If the parent exists and is in the drilling state
	if parent and drill_enabled:
		var turn_speed = 150
		if parent.get_node("AnimationSprite").flip_h == true :
			turn_speed*=-1
		
		var direction = Vector2(cos(parent.rotation), sin(parent.rotation))
		parent.velocity = direction * turn_speed
		
		
		parent.move_and_slide()


# Calculates the rotation based on the input received
func _calulate_rotation(direction:Vector2):
	if direction != Vector2.ZERO and can_move and drill_enabled:
		rotate_player(direction.angle())
		#emit_signal("rotate", direction.angle())



# Rotates the character when drill_enabled
func rotate_player(rot:float):
	if parent.get_node("AnimationSprite").flip_h == true :
		rot = -1 *(PI-rot)
	
	# Rotate the character
	parent.rotation = lerp_angle(parent.rotation, rot, 0.1)


# Disables the drill detector
func _disable_drill_detector():
	if not drill_enabled:
		var collision: CollisionShape2D = drill_detector.get_child(0)
		collision.set_deferred("disabled", true)
		collision.position.y = 1.0


# Enable the drill detector
func _enable_drill_detector(_vel:Vector2):
	var collision: CollisionShape2D = drill_detector.get_child(0)
	
	collision.disabled = false
	
	_vel = _vel.normalized()
	collision.rotation = _vel.angle() + PI/2
	
	# Allows drilling from dash at weird angles
	if _vel.angle() >= -2.35619449615479 && _vel.angle() <= -0.78539818525314:
		collision.rotation += PI
		collision.position.y = -1.0


# Re-enable movement after a bounce
func _enable_movement_after_bounce():
	var bump: CollisionShape2D = bump_detector.get_child(0)
	can_move = true


# When the bump detector detects an object to bump off of
func _start_bump(_body):
	if not drill_enabled:
		return
	
	# Force updates the shape cast that searches for bounces
	drill_shape_cast.force_shapecast_update()
	
	# Check if the shape cast is colliding with anything
	if drill_shape_cast.is_colliding() and can_bounce:
		
		var normal = drill_shape_cast.get_collision_normal(0)
		
		parent.velocity = parent.velocity.bounce(normal) * 0.8  # 0.8 for energy loss
		
		if parent.animated_sprite.flip_h == true:
			parent.rotation = -1* (PI-parent.velocity.angle())
		else:
			parent.rotation = parent.velocity.angle()
		
		
		can_move = false
		parent.bounce_timer.start(0.2)
		drill_shape_cast.force_shapecast_update()
		if drill_shape_cast.is_colliding():
			var rot = (PI/2 + parent.get_angle_to(drill_shape_cast.get_collision_point(0)))
			rotate_player(rot)
			if parent.animated_sprite.flip_h == true:
				rot *= -1
			if parent.velocity.y == 0.0:
				rot = (PI - parent.get_angle_to(drill_shape_cast.get_collision_point(0)))
				if parent.animated_sprite.flip_h == true:
					rot *= -1
				rotate_player(rot)
	



# Exits the drill state.
func _exit_drill_state(_body) -> void:
	can_bounce = false
	
	drill_shape_cast.enabled = false
	bump_detector.set_deferred("disabled", false)
	drill_shape_cast.scale = Vector2(0.2,0.2)
	bump_detector.scale  = Vector2(0.2,0.2)
	
	parent.set_collision_mask_value(1, true)
	
	drill_enabled = false
	
	var collision: CollisionShape2D = drill_detector.get_child(0)
	_disable_drill_detector()
	collision.rotation = 0
	if parent.health_component.current_hp > 0:
		parent.movement_component._enable_movement()
		parent.gravity_component._enable_gravity()
	var momentum = parent.rotation
	
	var delta_y = 300
	var delta_x = 500
	if parent.animated_sprite.flip_h == true:
		delta_y *=-1
		delta_x *=-1
	#print(momentum)
	
	parent.velocity.x += delta_x*cos(momentum) * 0.4
	parent.velocity.y += delta_y*sin(momentum) * 0.6
	
	#print(velocity.x, velocity.y)
	parent.movement_component.max_speed = abs(parent.velocity.x)
	parent.movement_component.exiting_ground = true
	parent.movement_component.force_velocity(parent.velocity)
	
	parent.rotation=0
	parent.dash_component.can_dash = true


# Enters the drill state. Called by the drill detector _on_body_entered signal. Connected in player script
func _enter_drill_state(_body) -> void:
	# Check if drill is enabled, and if the parent has a health component and is alive
	if not drill_enabled and (("health_component" in parent and parent.health_component.current_hp > 0) or not "health_component" in parent):
		# Turn off world collision with player
		parent.set_collision_mask_value(1, false)
		
		# Set the speed of the player
		var speed:float = 150
		var angle:float = 0
		
		# Check if the parent has a last_dash variable
		if last_dash:
			angle = last_dash.angle() # if it does set it to the angle
		
		# Check if the parent has an animated sprite, and see if it is flipped
		if "animated_sprite" in parent and parent.animated_sprite.flip_h == true:
			speed *=-1
			angle = (PI-angle)*-1
		
		# Change the parent's rotation and velocity
		parent.rotation = lerp_angle(parent.rotation, angle, 1)
		parent.velocity = speed*Vector2.from_angle(angle)
		
		parent.move_and_slide()
		
		# Get the shape and bump
		var shape:CollisionShape2D = drill_detector.get_child(0)
		var bump: CollisionShape2D = bump_detector.get_child(0)
		
		# Enable drill
		drill_enabled = true
		
		emit_signal("entered_drill_mode")
		# Disable movement in the parent
		#parent.movement_component.disable_movement_component = true
		
		# wait 9 physics frames
		for i in range(9):
			await get_tree().physics_frame
		
		# Enable the drill shape cast and scale it up
		drill_shape_cast.enabled = true
		drill_shape_cast.scale = Vector2(1.1,1.1)
		bump_detector.scale  = Vector2(1.1,1.1)
		bump.set_deferred("disabled", false) # disable the bump collision
		
		# Wait 5 physics frames
		for i in range(5):
			await get_tree().physics_frame
		
		# enable can_bounce
		can_bounce = true
