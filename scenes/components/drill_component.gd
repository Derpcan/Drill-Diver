extends Node
class_name DrillComponent

@export var drill_speed:float
@export var turn_raduis:float
 
signal rotate
signal bounce
var parent = get_parent()
var canmove = true

func _calulate_rotation(direction:Vector2):
	if direction != Vector2.ZERO and canmove:
		emit_signal("rotate", direction.angle())
		
	


	
