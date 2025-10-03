extends Node
class_name DrillComponent

@export var drill_speed:float
@export var turn_raduis:float
 
signal rotate
signal bounce


func _calulate_rotation(direction:Vector2):
	if direction != Vector2.ZERO:
		var current:float = get_parent().rotation
		var max_angle = PI*2
		var difference = fmod(direction.angle() - current, max_angle)
		var rotate = (fmod(2 * difference, max_angle) - difference) * turn_raduis
		emit_signal("rotate", rotate)
	

	
