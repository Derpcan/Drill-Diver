extends CharacterBody2D
class_name Ghost


@export var movement_component:MovementComponent
@export var jump_component:JumpComponent
@export var input_component:KeyLogLoader
@export var animated_sprite:AnimationSprite
@export var state_machine:StateMachine
@export var gravity_component:GravityComponent
@export var dash_component:DashComponent
@export var drill_detector:Area2D
@export var drill_component:DrillComponent
@export var bump_detector:Area2D
@export var bounce_timer:Timer
@export var health_component:HealthComponent
@export var animation_play:AnimationPlay
@export var ray:ShapeCast2D

@onready var terrain :Terrain = get_tree().get_first_node_in_group("Terrain") as Terrain


signal on_floor()
signal rotate



var last_dash = null

func _ready() -> void:
	


	input_component.movement_inputs.connect(movement_component._accelerate_in_direction)
	input_component.movement_inputs.connect(_choose_state)
	input_component.jump_input.connect(_choose_state)
	
	input_component.jump_input.connect(jump_component._calculate_jump)
	jump_component.change_gravity_scale.connect(gravity_component._change_gravity_scale)
	jump_component.jump.connect(movement_component.force_velocity_y)
	
	input_component.dash_inputs.connect(dash_component._calculate_dash)
	input_component.dash_inputs.connect(_set_last_dash)
	dash_component.dash_start.connect(movement_component.force_velocity)
	dash_component.dash_start.connect(movement_component._disable_vel_x_clamp)
	dash_component.dash_start.connect(_enable_drill_detector)
	dash_component.dash_start.connect(movement_component._not_exiting_ground)
	dash_component.dash_end.connect(movement_component._enable_vel_x_clamp)
	dash_component.dash_end.connect(_disable_drill_detector)
	on_floor.connect(dash_component._enable_dash)
	input_component.drill_inputs.connect(drill_component._calulate_rotation)
	
	
	health_component.died.connect(input_component._disable_inputs)
	health_component.died.connect(movement_component._disable_movement)
	health_component.died.connect(drill_component._disable_drill)
	health_component.died.connect(_choose_state)
	
	
	health_component.healed_fully.connect(input_component._enable_inputs)
	health_component.healed_fully.connect(movement_component._enable_movement)







func _physics_process(delta: float) -> void:
	if is_on_floor():
		emit_signal("on_floor")


func _choose_state(dir:Vector2=Vector2.ZERO, _pressed:bool=false, _delta:float=0.0) -> void:
	
	if health_component.current_hp == 0:
		state_machine._enter_state("death")
		return
	
	# Flip the character Sprite depending on which direction is being pressed
	if dir.x > 0 and (not drill_component.drill_enabled):
		animated_sprite.flip_h = false
	elif dir.x < 0 and (not drill_component.drill_enabled):
		animated_sprite.flip_h = true
	
	# If the speed is greater than 0 in the y direction
	if abs(velocity.y) > 0:
		pass
	
	# If the character is falling or jumping, enter the jump state
	if (abs(dir.y) > 0 and (!drill_component.drill_enabled)) or abs(velocity.y) > 0 and (!drill_component.drill_enabled) :
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
	
# test harness for terrain API
#func _unhandled_input(event):
	#if event.is_action_pressed("ui_select"):
		#_dev_drill()
	#if event.is_action_pressed("ui_focus_next"):
		#_dev_super()

func _aim_dir() -> Vector2:
	return Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down")
	)

	
func _dev_super():
	if terrain == null: return
	var dir := _aim_dir(); if dir == Vector2.ZERO: dir = Vector2.RIGHT
	var front = terrain.forward_cells(global_position, dir, 1)
	if front.is_empty(): return
	terrain.drill_super_one(front[0])
	

func _on_area_2d_body_entered(body):
	if not drill_component.drill_enabled and health_component.current_hp > 0:
		
		print("Drill")
		set_collision_layer_value(1, false)
		set_collision_mask_value(1, false)
		var speed = 150
		var angle = last_dash.angle()
		
		if animated_sprite.flip_h == true:
			speed *=-1
			angle = (PI-angle)*-1
			
		rotation = lerp_angle(rotation, angle, 1)
		velocity = speed*Vector2.from_angle(angle)
		
		move_and_slide()
		print("Last dash: ",last_dash)
		
		var shape:CollisionShape2D = drill_detector.get_child(0)
		var bump: CollisionShape2D = bump_detector.get_child(0)
		bump.set_deferred("disabled", false)
		
		drill_component.drill_enabled = true
		movement_component.disable_movement_component = true
		


func _disable_drill_detector():
	if not drill_component.drill_enabled:
		var collision: CollisionShape2D = drill_detector.get_child(0)
		collision.set_deferred("disabled", true)
		
		collision.position.y = 1.0
		
		print("Collision Disabled")


func _enable_drill_detector(_vel:Vector2):
	var collision: CollisionShape2D = drill_detector.get_child(0)
	
	collision.disabled = false
	
	_vel = _vel.normalized()
	collision.rotation = _vel.angle() + PI/2
	if _vel.angle() >= -2.35619449615479 && _vel.angle() <= -0.78539818525314:
		collision.rotation += PI
		collision.position.y = -1.0
	
	print(collision.rotation)
	





func _on_drill_detector_body_exited(body):
	
		set_collision_layer_value(1, true)
		set_collision_mask_value(1, true)
		
		drill_component.drill_enabled = false
		
		var collision: CollisionShape2D = drill_detector.get_child(0)
		_disable_drill_detector()
		collision.rotation = 0
		if health_component.current_hp > 0:
			movement_component._enable_movement()
			gravity_component._enable_gravity()
		var momentum = rotation
		
		var delta_y = 300
		var delta_x = 500
		if animated_sprite.flip_h == true:
			delta_y *=-1
			delta_x *=-1
		print(momentum)
		
		velocity.x += delta_x*cos(momentum)
		velocity.y += delta_y*sin(momentum)
		velocity.x *= 0.4
		velocity.y *= 0.6
		print(velocity.x, velocity.y)
		movement_component.max_speed = abs(velocity.x)
		movement_component.exiting_ground = true
		movement_component.force_velocity(velocity)
		
		rotation=0
	
		print("exit")
		dash_component.can_dash = true
		
		
		
		


func _set_last_dash(dir: Vector2):
	if dir != Vector2.ZERO:
		last_dash = dir


func _on_bump_detector_body_entered(body):
	if not drill_component.drill_enabled:
		return
	
	
	# Perform a raycast from the Area2D's position to the body
	

	
	
		# Do something with the normal
	ray.force_shapecast_update()
	print(ray.is_colliding())
	if ray.is_colliding():
		
		var normal = ray.get_collision_normal(0)
		

		if abs(normal.x) > abs(normal.y):
			# Wall: reverse X
			velocity.x *= -1
		elif abs(normal.x) < abs(normal.y):
			# Floor or ceiling: reverse Y
			velocity.y *= -1
		elif abs(abs(normal.x) - abs(normal.y)) <1 :
			velocity *=-1
			
		

		
		if animated_sprite.flip_h == true:
			rotation = -1* (PI-velocity.angle())
			velocity *= -0.8
		else:
			rotation = velocity.angle()
			velocity *= 0.8
		move_and_slide()
		var bump: CollisionShape2D = bump_detector.get_child(0)
		bump.set_deferred("disabled", true)
		drill_component.canmove = false
		bump.call_deferred("set_deferred", "disabled", false)
		bounce_timer.start(0.2)
		
	
	


func _on_bounce_timer_timeout():
	var bump: CollisionShape2D = bump_detector.get_child(0)
	drill_component.canmove = true
	

	


func _on_drill_detector_body_entered(body: Node2D) -> void:
	if not drill_component.drill_enabled and health_component.current_hp > 0:
		
		print("Drill")
		set_collision_layer_value(1, false)
		set_collision_mask_value(1, false)
		var speed = 150
		var angle = last_dash.angle()
		
		if animated_sprite.flip_h == true:
			speed *=-1
			angle = (PI-angle)*-1
			
		rotation = lerp_angle(rotation, angle, 1)
		velocity = speed*Vector2.from_angle(angle)
		
		move_and_slide()
		print("Last dash: ",last_dash)
		
		var shape:CollisionShape2D = drill_detector.get_child(0)
		var bump: CollisionShape2D = bump_detector.get_child(0)
		bump.set_deferred("disabled", false)
		
		drill_component.drill_enabled = true
		movement_component.disable_movement_component = true
		
