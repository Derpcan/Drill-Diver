extends Node

var entity : Node2D = null
@onready var state_machine = self.get_parent()

func enter() -> void:
	entity.sprites.play("move")

func update(delta: float) -> void:
	var dist = entity.to_player.length()
	# The player is outside of detection range, transition to return
	if dist > entity.detection_range:
		state_machine.change_state(state_machine.return_state)
		return
	
	# The player is still outside of fire range, continue moving toward them
	if dist > entity.fire_range:
		# Move toward player
		var desired_dir = entity.to_player.normalized()
		entity.velocity = desired_dir * entity.approach_speed
		return
	
	# The player is within fire range, transition to engage
	if dist <= entity.fire_range:
		state_machine.change_state(state_machine.engage_state)
		return
