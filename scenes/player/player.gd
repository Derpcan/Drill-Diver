extends CharacterBody2D
class_name Player

@export var movement_component:MovementComponent
@export var jump_component:JumpComponent
@export var input_component:InputComponent
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
@export var super_drill_component:SuperDrillComponent
var play_jump = false



@onready var terrain :Terrain = get_tree().get_first_node_in_group("Terrain") as Terrain


signal on_floor()
signal on_floor_dirt()
signal rotate
signal super_drill_tile()
signal idling



var last_dash = null

func _ready() -> void:
	


	input_component.movement_inputs.connect(movement_component._accelerate_in_direction)
	input_component.movement_inputs.connect(_choose_state)
	input_component.jump_input.connect(_choose_state)
	
	input_component.jump_input.connect(jump_component._calculate_jump)
	jump_component.change_gravity_scale.connect(gravity_component._change_gravity_scale)
	jump_component.jump.connect(movement_component.force_velocity_y)
	
	input_component.dash_inputs.connect(dash_component._calculate_dash)
	
	dash_component.dash_start.connect(movement_component.force_velocity)
	dash_component.dash_start.connect(movement_component._disable_vel_x_clamp)
	
	
	
	dash_component.dash_start.connect(movement_component._not_exiting_ground)
	dash_component.dash_end.connect(movement_component._enable_vel_x_clamp)
	on_floor.connect(dash_component._enable_dash)
	

	
	
	
	
	
	on_floor.connect(super_drill_component._enable_dash)
	
	health_component.died.connect(input_component._disable_inputs)
	health_component.died.connect(movement_component._disable_movement)
	health_component.died.connect(drill_component._disable_drill)
	health_component.died.connect(_choose_state)
	
	
	health_component.healed_fully.connect(input_component._enable_inputs)
	health_component.healed_fully.connect(movement_component._enable_movement)
	
	
	# Drill Connections
	#dash_component.dash_start.connect(_enable_drill_detector)
	#dash_component.dash_end.connect(_disable_drill_detector)
	#on_floor_dirt.connect(_on_bump_detector_body_entered)
	
	input_component.drill_inputs.connect(drill_component._calulate_rotation)
	on_floor_dirt.connect(drill_component._start_bump)
	dash_component.dash_start.connect(drill_component._enable_drill_detector)
	dash_component.dash_end.connect(drill_component._disable_drill_detector)
	drill_detector.body_entered.connect(drill_component._enter_drill_state)
	drill_detector.body_exited.connect(drill_component._exit_drill_state)
	bump_detector.body_entered.connect(drill_component._start_bump)
	bounce_timer.timeout.connect(drill_component._enable_movement_after_bounce)
	drill_component.entered_drill_mode.connect(movement_component._disable_movement)
	input_component.dash_inputs.connect(drill_component._set_last_dash)
	
	# Super Drill Connections
	input_component.super_drill_inputs.connect(drill_component._set_last_dash)
	super_drill_component.super_drill_start.connect(drill_component._enable_drill_detector)
	super_drill_component.super_drill_end.connect(drill_component._disable_drill_detector)
	super_drill_component.super_drill_start.connect(super_drill_component._enable_super_drill_hitbox)
	super_drill_component.super_drill_end.connect(super_drill_component._disable_super_drill_hitbox)
	super_drill_component.super_drill_start.connect(movement_component._not_exiting_ground)
	super_drill_component.super_drill_end.connect(movement_component._enable_vel_x_clamp)
	super_drill_component.super_drill_start.connect(movement_component.force_velocity)
	super_drill_component.super_drill_start.connect(movement_component._disable_vel_x_clamp)
	input_component.super_drill_inputs.connect(super_drill_component._calculate_dash)
	input_component.super_drill_inputs.connect(_set_last_dash)
	
	#Sounds
	jump_component.jump.connect(_play_jump)
	dash_component.dash_start.connect(_play_dash)
	drill_detector.body_entered.connect(_play_drill)
	drill_detector.body_exited.connect(_stop_drill)
	drill_component.bounce.connect(_play_bounce)
	super_drill_component.super_drill_start.connect(_play_super_drill)

	



func _physics_process(delta: float) -> void:
	$Label.text = "Speed: " + str(movement_component.velocity.x)
	
	if (is_on_floor() or is_on_wall() or is_on_ceiling()) and drill_component.drill_enabled:
	
		emit_signal("on_floor_dirt",null)
	if is_on_floor():
		emit_signal("on_floor")
		play_jump = true
		


func _choose_state(dir:Vector2=Vector2.ZERO, _pressed:bool=false, _delta:float=0.0) -> void:
	animated_sprite.scale = Vector2(0.5, 0.5)
	
	animated_sprite.position.y = -2.0
	if health_component.current_hp == 0:
		state_machine._enter_state("death")
		$DeathSound.play()
		$MovementSound.stop()
		
		return
		
	# Drill state
	if drill_component.drill_enabled:
		state_machine._enter_state("drill")
		
		
		
		$MovementSound.stop()
		
		# Set scale of the animated sprite for the drill so it's normal size
		
		# Correct the drill angle depending on sprite flip
		if animated_sprite.flip_h == false:
			animated_sprite.rotation = PI/2
		else:
			animated_sprite.rotation = -PI/2
	
	# Flip the character Sprite depending on which direction is being pressed
	if dir.x > 0 and (not drill_component.drill_enabled):
		animated_sprite.flip_h = false
	elif dir.x < 0 and (not drill_component.drill_enabled):
		animated_sprite.flip_h = true
		
	# Drill transition lags when this logic is running
	#if dash_component.is_dashing():            
		#state_machine._enter_state("run") 
		#return
	
	if dash_component.is_dashing() and not drill_component.drill_enabled:
		$MovementSound.stop()
		
		state_machine._enter_state("dash")
		return
	
	if super_drill_component.is_dashing() and not drill_component.drill_enabled:
		$MovementSound.stop()
		
		state_machine._enter_state("superdrill")
		return
		
		
	# If the speed is greater than 0 in the y direction
	if abs(velocity.y) > 0:
		pass
	
	# If the character is falling or jumping, enter the jump state
	if (abs(dir.y) > 0 and not drill_component.drill_enabled) or abs(velocity.y) > 0 and (!drill_component.drill_enabled):
		
		if animation_play.current_animation == "dash":
			await animation_play.animation_finished
			
		
		
		state_machine._enter_state("jump")
		
		$MovementSound.stop()
		animated_sprite.rotation = 0
		return
	
	# If the character is not moving on the x-axis and is not moving on y-axis enter idle state
	if velocity.x == 0 and not drill_component.drill_enabled:
		
		if animation_play.current_animation == "dash":
			await  animation_play.animation_finished
		
		state_machine._enter_state("idle")
		
		$MovementSound.stop()
		idling.emit()
		animated_sprite.rotation = 0
		return 
	
	# If the character is moving on the x-axis and not the y-axis enter the run state
	if abs(dir.x) > 0 and not drill_component.drill_enabled and not dash_component.is_dashing() and is_on_floor():
		
		# Prevent run state while dashing
		if  animation_play.current_animation == "dash":
			await animation_play.animation_finished
			
		state_machine._enter_state("run")
		
		if $MovementSound.playing == false:
			$MovementSound.play()
		animated_sprite.rotation = 0
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
	



func _set_last_dash(dir: Vector2):
	if dir != Vector2.ZERO:
		last_dash = dir

func _end_level():
	
	await dash_component.dash_end
	state_machine._enter_state("idle")
	movement_component._disable_movement()
	input_component._disable_inputs()
	
func _enter_dialogue():
	state_machine._enter_state("idle")
	movement_component._disable_movement()
	input_component._disable_inputs()
	
func _leave_dialogue():
	movement_component._enable_movement()
	input_component._enable_inputs()
	
func _play_jump(vel:Vector2):
	$JumpSound.play()

func _play_dash(vel:Vector2):
	$DashSound.play()
	
func _play_drill(_body):
	$DrillStartSound.play()
	$DirtSound.play()
	$DrillSound.play()
	
func _stop_drill(_body):
	$DrillSound.stop()
	$DirtSound.play()

func _play_bounce():
	$BounceSound.play()
	
func _play_super_drill(vel:Vector2):
	$SuperDrillSound.play()
	
func _play_item_collect():
	$ItemCollect.play()
