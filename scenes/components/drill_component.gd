extends Node
class_name DrillComponent

## The characterbody2d that is able to drill
@export var parent:CharacterBody2D


@export var drill_speed:float
@export var turn_raduis:float
 
signal rotate
signal bounce

var canmove = true

var drill_enabled:bool = false:
	set(new_val):
		drill_enabled = new_val
		if drill_enabled:
			print("Drill Enabled")
			
		else:
			print("Drill Disabled")
		
		# Enable or disable the physics_process call depending on 
		# if the character is in the drilling state
		set_physics_process(drill_enabled)



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
	if direction != Vector2.ZERO and canmove and drill_enabled:
		rotate_player(direction.angle())
		#emit_signal("rotate", direction.angle())



# Rotates the character when drill_enabled
func rotate_player(rot:float):
	
	
	if parent.get_node("AnimationSprite").flip_h == true :
		rot = -1 *(PI-rot)
	
	# Rotate the character
	parent.rotation = lerp_angle(parent.rotation, rot, 0.1)
	
		



	
