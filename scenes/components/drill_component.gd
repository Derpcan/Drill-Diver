extends Node
class_name DrillComponent

## The characterbody2d that is able to drill
@export var parent:CharacterBody2D


@export var drill_speed:float
@export var turn_speed:float

@export var drill_detector:Area2D
@export var drill_shape_cast:ShapeCast2D 
@export var bump_detector:Area2D

signal rotate
signal bounce
signal entered_drill_mode()

var can_move:bool = true
var can_bounce:bool = false
var last_dash:Vector2

var drill_enabled:bool = false:
	set(new_val):
		drill_enabled = new_val
		if drill_enabled:
			#print("Drill Enabled")
			#print_rich("[color=#42ED59]Drill Enabled", "[/color]")
			pass
			
		else:
			#print("Drill Disabled")
			#print_rich("[color=#EDA451]Drill Disabled", "[/color]")
			pass
		
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


func _physics_process(_delta: float) -> void:
	# If the parent exists and is in the drilling state
	if parent and drill_enabled:
		
		#if parent.get_node("AnimationSprite").flip_h == true :
			#parent.get_node("AnimationSprite").flip_h = false
			#turn_speed*=-1
		var direction = Vector2(cos(parent.rotation), sin(parent.rotation))
		parent.velocity = direction * drill_speed
		
		
		parent.move_and_slide()


# Calculates the rotation based on the input received
func _calulate_rotation(direction:Vector2):
	if direction != Vector2.ZERO and can_move and drill_enabled:
		rotate_player(direction.angle())
		#emit_signal("rotate", direction.angle())



# Rotates the character when drill_enabled
func rotate_player(rot:float):
	if parent.get_node("AnimationSprite").flip_h == true :
		parent.get_node("AnimationSprite").flip_h = false
		#rot = -1 *(PI-rot)
	
	# Rotate the character
	parent.rotation = lerp_angle(parent.rotation, rot, turn_speed)


# Disables the drill detector
func _disable_drill_detector():
	#var sprite = get_parent().animated_sprite
	
	if not drill_enabled:
		var collision: CollisionShape2D = drill_detector.get_child(0)
		collision.set_deferred("disabled", true)
		collision.position.y = 1.0


# Enable the drill detector
func _enable_drill_detector(_vel:Vector2):
	var collision: CollisionShape2D = drill_detector.get_child(0)
	var sprite = get_parent().animated_sprite
	collision.disabled = false
	
	_vel = _vel.normalized()
	
	drill_detector.rotation = _vel.angle() 
	#collision.rotation = _vel.angle() + PI
	sprite.rotation = _vel.angle()
	#if sprite.flip_h == true:
		##sprite.flip_h = false
		#sprite.rotation += PI
	
	if abs(_vel.y) > 0 and _vel.x == 0:
		if sprite.flip_h == true:
			sprite.flip_h = false
	elif sprite.flip_h == true:
		sprite.rotation += PI
	
	if _vel.y > 0 and _vel.x < 0:
		collision.position.y = -4.0
	
		#sprite.rotation += PI
	
	# Allows drilling from  at weird angles
	if _vel.angle() >= -2.35619449615479 && _vel.angle() <= -0.78539818525314:
		#collision.rotation += PI
		#collision.position.y = 2.0
		pass

# Re-enable movement after a bounce
func _enable_movement_after_bounce():
	#var bump: CollisionShape2D = bump_detector.get_child(0)
	can_move = true


# When the bump detector detects an object to bump off of
func _start_bump(_body):
	if not drill_enabled:
		return
	
	# Force updates the shape cast that searches for bounces
	drill_shape_cast.force_shapecast_update()
	
	# Check if the shape cast is colliding with anything
	if drill_shape_cast.is_colliding():
		
		var normal = drill_shape_cast.get_collision_normal(0)
		
		var new_velocity = parent.velocity.bounce(normal) * 0.8  
		
		var normal_component = new_velocity.dot(normal)
		var MIN_LAUNCH_SPEED = 100
		
		# Checks if the bounce is a high enough velocity
		# this will prevent getting stuck on a surface
		if abs(normal_component) < MIN_LAUNCH_SPEED:
			var tangential_velocity = new_velocity.slide(normal)
			new_velocity = tangential_velocity + (normal * MIN_LAUNCH_SPEED)		#if parent.velocity.x == 0.0 and parent.velocity.y != 0.0 :
				#parent.velocity = Vector2(parent.velocity.y/8,parent.velocity.y)
				#
		#elif parent.velocity.y == 0.0 and parent.velocity.x != 0.0:
			#parent.velocity = Vector2(parent.velocity.x,parent.velocity.x/8)
		parent.velocity = new_velocity
		if parent.animated_sprite.flip_h == true:
			parent.rotation = -1*(PI-parent.velocity.angle())
		else:
			parent.rotation = parent.velocity.angle()
		
		
		can_move = false
		parent.bounce_timer.start(0.2)
		drill_shape_cast.force_shapecast_update()
		bounce.emit()



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
	
	#parent.velocity.x += delta_x*cos(momentum) * 0.4
	parent.velocity.x += delta_x*cos(momentum) * 0.2
	parent.velocity.y += delta_y*sin(momentum) * 0.6
	#parent.velocity.y += delta_y*sin(momentum) * 0.6
	
	#print(velocity.x, velocity.y)
	#parent.movement_component.max_speed = abs(parent.velocity.x)
	#parent.movement_component.exiting_ground = true
	if allow_exit_launch:
		parent.movement_component.force_velocity(parent.velocity)
	else:
		parent.movement_component.force_velocity(Vector2(0,0))
	
	parent.rotation=0
	parent.dash_component.can_dash = true
	parent.super_drill_component.can_super_drill = true 



func allow_exit_launching() -> void:
	allow_exit_launch = true
	timer.queue_free()
	timer = null

var allow_exit_launch:bool = false
var timer:Timer
# Enters the drill state. Called by the drill detector _on_body_entered signal. Connected in player script
func _enter_drill_state(_body) -> void:
	# Check if drill is enabled, and if the parent has a health component and is alive
	if not drill_enabled and (("health_component" in parent and parent.health_component.current_hp > 0) or not "health_component" in parent):
		if timer == null:
			allow_exit_launch = false
			timer = Timer.new()
			add_child(timer)
			timer.start(0.05)
			timer.timeout.connect(allow_exit_launching)
		
		
		# Turn off world collision with player
		parent.set_collision_mask_value(1, false)
		
		# Set the speed of the player
		var angle:float = 0
		
		# Check if the parent has a last_dash variable
		if last_dash:
			angle = last_dash.angle() # if it does set it to the angle
		
		# Check if the parent has an animated sprite, and see if it is flipped
		if "animated_sprite" in parent and parent.animated_sprite.flip_h == true:
			parent.animated_sprite.flip_h = false
			#speed *=-1
			#angle = (PI-angle)*-1
			
			# Drill vertically
			if last_dash.x == 0 and abs(last_dash.y) > 0:
				angle = -PI/2
				parent.rotation = -PI/2
			# Drill horizontally
			elif abs(last_dash.x) > 0 and last_dash.y == 0:
				angle = PI
				parent.rotation = PI
			# Drill diagonal up left
			elif last_dash.y < 0:
				angle = -3*PI/4
				parent.rotation = -3*PI/4
			# Drill diagonal down left
			elif last_dash.y > 0:
				angle = 3*PI/4
				parent.rotation = 3*PI/4
		
		
		
		# Give a boost in position to each dash direction
		if last_dash.y > 0:
			parent.global_position.y += 4
		elif last_dash.y < 0:
			parent.global_position.y -= 4
		
		
		if last_dash.x > 0:
			parent.global_position.x += 5
		elif last_dash.x < 0:
			parent.global_position.x -= 5
		
		
		# Change the parent's rotation and velocity
		parent.rotation = lerp_angle(parent.rotation, angle, 1)
		parent.velocity = drill_speed*Vector2.from_angle(angle)
		
		#print(angle)
		#parent.move_and_slide()
		
		# Get the shape and bump
		#var shape:CollisionShape2D = drill_detector.get_child(0)
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
		
		can_bounce = true
