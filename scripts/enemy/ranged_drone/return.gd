extends Node

var entity : Node2D = null
@onready var state_machine = self.get_parent()

func enter() -> void:
	entity.sprites.play("move")

func update(delta: float) -> void:
	var to_start_pos = entity.start_position - entity.global_position
	var dist = to_start_pos.length()
	# The entity is back to the starting position, transition to idle
	if abs(dist) <= entity.EPSILON:
		state_machine.change_state(state_machine.idle_state)
		return
	
	# The entity is not back to the starting position, keep moving towards it
	if abs(dist) > entity.EPSILON:
		# move towards starting position
		var desired_dir = to_start_pos.normalized()
		entity.velocity = desired_dir * entity.return_speed
		return
