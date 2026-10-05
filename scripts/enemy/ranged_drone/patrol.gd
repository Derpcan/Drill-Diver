extends Node

var entity : Node2D = null
@onready var state_machine = self.get_parent()

var patrol_to_idle_timeout : float = 0.0
var direction : Vector2 = Vector2(1, 1)

func enter() -> void:
	entity.sprites.play("move")
	
	direction = Vector2(1, 1)
	patrol_to_idle_timeout = 0.0

func update(delta: float) -> void:
	var dist = entity.to_player.length()
	# The player is within detection range but outside fire range, transition to approach
	if (dist <= entity.detection_range) && (dist > entity.fire_range):
		state_machine.change_state(state_machine.approach_state)
		return
	
	# The player is within fire range, transition to engage
	if dist <= entity.fire_range:
		state_machine.change_state(state_machine.engage_state)
		return
	
	# If nothing else fired, occasionally switch to idle
	if patrol_to_idle_timeout >= entity.patrol_to_idle_delay:
		state_machine.change_state(state_machine.patrol_state)
		return
	
	patrol_to_idle_timeout += delta
	# Pace back and forth
	if (entity.position - entity.start_position).length() > entity.patrol_dist:
		direction = Vector2(-1, 1)
	if (entity.start_position - entity.position).length() > entity.patrol_dist:
		direction = Vector2(1, 1)
	
	entity.velocity = entity.velocity.move_toward(direction * Vector2(entity.patrol_speed, 0.0), entity.acceleration * delta)
