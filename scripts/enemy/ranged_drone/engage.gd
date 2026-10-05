extends Node

var entity : Node2D = null
@onready var state_machine = self.get_parent()

var engage_to_action_timeout : float = 0.0

func enter() -> void:
	entity.velocity = Vector2.ZERO
	
	entity.sprites.play("idle")
	
	engage_to_action_timeout = 0.0

func update(delta: float) -> void:
	var dist = entity.to_player.length()
	# The player moved out of detection range, transition to return
	if dist > entity.detection_range:
		state_machine.change_state(state_machine.return_state)
		return
	
	# The player moved out of fire range but is still in detection range, transition to approach
	if (dist <= entity.detection_range) && (dist > entity.fire_range):
		state_machine.change_state(state_machine.approach_state)
		return
	
	# On action timeout, randomly choose between reposition and fire
	if engage_to_action_timeout >= entity.engage_to_action_delay:
		var decision = randf()
		if decision <= entity.fire_probability:
			# Chose to fire
			state_machine.change_state(state_machine.fire_state)
		else:
			# Chose to reposition
			state_machine.change_state(state_machine.reposition_state)
		return

	engage_to_action_timeout += delta
