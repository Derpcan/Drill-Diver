extends Node

var entity : Node2D = null
@onready var state_machine = self.get_parent()

var idle_to_patrol_timeout : float = 0.0

func enter() -> void:
	entity.sprites.play("idle")
	
	idle_to_patrol_timeout = 0.0

func update(delta: float) -> void:
	var dist = entity.to_player.length()
	# If nothing else fired, occasionally switch to patrol
	if idle_to_patrol_timeout >= entity.idle_to_patrol_delay:
		state_machine.change_state(state_machine.patrol_state)
		return
	
	idle_to_patrol_timeout += delta
